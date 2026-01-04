part of 'xml_editor.dart';

/// // Plist-specific editor
class PListEditor extends XmlEditor {
  PListEditor(super.originalContent);

  /// Add a key-value pair to a plist file at a specific path
  ///
  /// The value parameter is optional. If null, only the key will be added.
  /// The path parameter is required and specifies where to add the entry.
  ///
  /// Example with root dict:
  /// ```dart
  /// editor.addEntry(
  ///   path: 'plist.dict',
  ///   key: 'NSCameraUsageDescription',
  ///   value: '<string>We need camera access for photos</string>',
  ///   keyComments: ['@permit camera'],
  ///   valueComments: ['User-facing description'],
  ///   anchorKeys: ['NSPhotoLibraryUsageDescription', 'NSMicrophoneUsageDescription'],
  /// );
  /// ```
  ///
  /// Example with nested path:
  /// ```dart
  /// editor.addPlistEntry(
  ///   path: 'plist.dict.customDict',
  ///   key: 'item1',
  ///   value: '<string>value1</string>',
  /// );
  /// ```
  void addEntry({
    required String path,
    required String key,
    String? value,
    List<String>? keyComments,
    List<String>? valueComments,
    List<String>? anchorKeys,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    // Find the target dict element at the specified path
    final dict = _findElementByPath(path);

    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // If override is true, check if the key already exists and remove it
    if (override) {
      final existingKey = _findPlistKey(dict, key);
      if (existingKey != null) {
        // Key exists, remove it with its value and @permit comments
        final keyInfo = _findElementLines(existingKey);
        if (keyInfo != null) {
          // Find the value element (next element after key)
          final valueElement = _getNextSiblingElement(existingKey);
          if (valueElement != null) {
            final valueInfo = _findElementLines(valueElement);
            if (valueInfo != null) {
              // Remove both the key and its value; create a combined element range
              final combined = _ElementLines(
                startLine: keyInfo.startLine,
                endLine: valueInfo.endLine,
                indent: keyInfo.indent,
              );
              _removeElementAndMatchingComments(combined, shouldRemoveComment);

              // Reparse document after removal
              _updateDocument();
            }
          }
        }
      }
    }

    // Re-find the dict after potential removal
    final currentDict = _findElementByPath(path);
    if (currentDict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // Find insertion position
    final insertInfo = _findPlistInsertPosition(currentDict, anchorKeys: anchorKeys);
    if (insertInfo == null) {
      throw Exception('Could not find insertion point in plist');
    }

    // Build the content to insert
    final insertLines = <String>[];

    // Add key comments if provided
    if (keyComments != null && keyComments.isNotEmpty) {
      for (final comment in keyComments) {
        insertLines.add('${insertInfo.indent}<!--$comment-->');
      }
    }
    insertLines.add('${insertInfo.indent}<key>$key</key>');

    // Add value only if provided
    if (value != null) {
      // Add value comments if provided
      if (valueComments != null && valueComments.isNotEmpty) {
        for (final comment in valueComments) {
          insertLines.add('${insertInfo.indent}<!--$comment-->');
        }
      }
      insertLines.add('${insertInfo.indent}$value');
    }

    // Insert at the appropriate position
    lines.insertAll(insertInfo.lineIndex, insertLines);

    // Reparse document so subsequent operations see the change
    _updateDocument();
  }

  // add plistUsageDescription
  void addUsageDescription({
    required String key,
    required String description,
    List<String>? keyComments,
    List<String>? valueComments,
    List<String>? anchorKeys,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    addEntry(
      path: 'plist.dict',
      key: key,
      value: '<string>$description</string>',
      keyComments: keyComments,
      valueComments: valueComments,
      anchorKeys: anchorKeys,
      override: override,
      shouldRemoveComment: shouldRemoveComment,
    );
  }

  /// Remove a plist key-value pair with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removeEntry(
  ///   path: 'plist.dict',
  ///   key: 'NSCameraUsageDescription',
  ///   commentMarkers: ['@permit'],
  /// );
  /// ```
  void removeEntry({
    required String path,
    required String key,
    CommentRemoverPredicate? removeComments,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // Find the key element
    final keyElement = _findPlistKey(dict, key);
    if (keyElement == null) {
      throw Exception('Key not found: $key');
    }

    // Find the key and its value in the lines
    final keyInfo = _findElementLines(keyElement);
    if (keyInfo == null) {
      throw Exception('Could not locate key in file: $key');
    }

    // Find the value element (next element after key)
    final valueElement = _getNextSiblingElement(keyElement);
    if (valueElement == null) {
      throw Exception('Could not find value for key: $key');
    }

    final valueInfo = _findElementLines(valueElement);
    if (valueInfo == null) {
      throw Exception('Could not locate value in file');
    }
    int defaultStart = _findCommentBlockStart(keyInfo.startLine, shouldRemoveComment: removeComments);
    lines.removeRange(defaultStart, valueInfo.endLine + 1);

    _updateDocument();
  }

  /// Remove a plist usage description by key with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removeUsageDescription(
  ///   key: 'NSCameraUsageDescription',
  ///   commentMarkers: ['@permit'],
  /// );
  void removeUsageDescription({
    required String key,
    CommentRemoverPredicate? removeComments,
  }) {
    removeEntry(
      path: 'plist.dict',
      key: key,
      removeComments: removeComments,
    );
  }

  List<PListUsageDescription> getUsageDescriptions() {
    final descriptions = <PListUsageDescription>[];

    final dict = _findElementByPath('plist.dict');
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: plist.dict');
    }

    final children = dict.children.whereType<XmlElement>().toList();
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child.name.qualified == 'key') {
        final keyName = child.innerText.trim();
        // check if this is an NS*UsageDescription key
        if (!keyName.startsWith('NS') || !keyName.endsWith('UsageDescription')) {
          continue;
        }
        final valueElement = _getNextSiblingElement(child);
        if (valueElement != null && valueElement.name.qualified == 'string') {
          final description = valueElement.innerText.trim();
          descriptions.add(
            PListUsageDescription(
              key: keyName,
              description: description,
              comments: getCommentsOf(child),
            ),
          );
        }
      }
    }

    return descriptions;
  }

  /// Add an entry to an array at a specific path
  ///
  /// If the array does not exist at the path, creates a new key-array pair.
  /// If the array already exists, appends the entry to it.
  ///
  /// Example:
  /// ```dart
  /// editor.addArrayEntry(
  ///   path: 'plist.dict',
  ///   key: 'UIBackgroundModes',
  ///   entry: '<string>location</string>',
  ///   keyComments: ['@permit background'],
  /// );
  /// ```
  void addArrayEntry({
    required String path,
    required String key,
    required String entry,
    List<String>? keyComments,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // Check if key already exists
    final existingKey = _findPlistKey(dict, key);
    if (existingKey != null) {
      final existingValue = _getNextSiblingElement(existingKey);
      if (existingValue != null && existingValue.name.qualified == 'array') {
        // Array exists, append entry to it
        final arrayInfo = _findElementLines(existingValue);
        if (arrayInfo == null) {
          throw Exception('Could not locate existing array for key: $key');
        }

        // Insert before the closing </array> tag
        final insertIdx = arrayInfo.endLine;
        final childIndent = '${arrayInfo.indent}    ';
        lines.insert(insertIdx, '$childIndent$entry');

        _updateDocument();
        return;
      }
    }

    // Array doesn't exist, create new key-array pair
    final insertInfo = _findPlistInsertPosition(dict, anchorKeys: []);
    if (insertInfo == null) {
      throw Exception('Could not find insertion point in plist');
    }

    final insertLines = <String>[];

    // Add key comments if provided
    if (keyComments != null && keyComments.isNotEmpty) {
      for (final comment in keyComments) {
        insertLines.add('${insertInfo.indent}<!-- $comment -->');
      }
    }
    insertLines.add('${insertInfo.indent}<key>$key</key>');
    insertLines.add('${insertInfo.indent}<array>');
    insertLines.add('${insertInfo.indent}    $entry');
    insertLines.add('${insertInfo.indent}</array>');

    lines.insertAll(insertInfo.lineIndex, insertLines);

    _updateDocument();
  }

  /// Remove an entry from an array at a specific path
  ///
  /// If the array becomes empty after removal, removes the entire array and key.
  ///
  /// Example:
  /// ```dart
  /// editor.removeArrayEntry(
  ///   path: 'plist.dict',
  ///   key: 'UIBackgroundModes',
  ///   entry: '<string>location</string>',
  /// );
  /// ```
  void removeArrayEntry({
    required String path,
    required String key,
    required String entry,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // Find the key element
    final keyElement = _findPlistKey(dict, key);
    if (keyElement == null) {
      throw Exception('Key not found: $key');
    }

    // Find the array element
    final arrayElement = _getNextSiblingElement(keyElement);
    if (arrayElement == null || arrayElement.name.qualified != 'array') {
      throw Exception('Array not found for key: $key');
    }

    // Find the entry line in the array
    final arrayInfo = _findElementLines(arrayElement);
    if (arrayInfo == null) {
      throw Exception('Could not locate array in file: $key');
    }

    // Find and remove the entry from the array
    int entryLine = -1;
    for (int i = arrayInfo.startLine + 1; i < arrayInfo.endLine; i++) {
      if (lines[i].trim() == entry.trim()) {
        entryLine = i;
        break;
      }
    }

    if (entryLine == -1) {
      throw Exception('Entry not found in array: $entry');
    }

    // Remove the entry line
    lines.removeAt(entryLine);

    _updateDocument();

    // Check if array is now empty
    // Re-find the dict since document was updated
    final updatedDict = _findElementByPath(path);
    if (updatedDict != null) {
      final updatedArrayElement = _findPlistKey(updatedDict, key);
      if (updatedArrayElement != null) {
        final updatedArrayValue = _getNextSiblingElement(updatedArrayElement);
        if (updatedArrayValue != null && updatedArrayValue.name.qualified == 'array') {
          final arrayChildren = updatedArrayValue.children.whereType<XmlElement>().toList();
          if (arrayChildren.isEmpty) {
            // Array is empty, remove the entire key-array pair
            // Re-find the element lines since they've changed after the entry removal
            final keyInfo = _findElementLines(updatedArrayElement);
            final arrayInfo2 = _findElementLines(updatedArrayValue);
            if (keyInfo != null && arrayInfo2 != null) {
              // Ensure the range is valid - end index must not exceed lines.length
              final safeEndLine = (arrayInfo2.endLine + 1) > lines.length ? lines.length : (arrayInfo2.endLine + 1);
              if (keyInfo.startLine >= 0 && keyInfo.startLine <= safeEndLine && safeEndLine <= lines.length) {
                lines.removeRange(keyInfo.startLine, safeEndLine);
                _updateDocument();
              }
            }
          }
        }
      }
    }
  }
}
