import 'dart:io';
import 'package:xml/xml.dart';

/// A surgical XML editor that preserves the original file format
class XmlEditor {
  final String originalContent;
  late XmlDocument document;
  final List<String> lines;

  XmlEditor(this.originalContent) : lines = originalContent.split('\n') {
    document = XmlDocument.parse(originalContent);
  }

  /// Add a tag to an Android manifest file
  ///
  /// Example:
  /// ```dart
  /// editor.addManifestTag(
  ///   path: 'manifest.application',
  ///   tag: '<uses-permission android:name="android.permission.INTERNET" />',
  ///   comments: ['@permit internet access', 'Required for API calls'],
  /// );
  /// ```
  void addManifestTag({
    required String path,
    required String tag,
    List<String>? comments,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      throw Exception('Parent element not found: $path');
    }

    // Extract the tag name from the tag string
    final tagNameMatch = RegExp(r'<(\w+[\w:-]*)').firstMatch(tag);
    final tagName = tagNameMatch?.group(1) ?? '';

    // Find insertion position based on siblings of the same type
    final insertInfo = _findManifestInsertPosition(parent, tagName: tagName);
    if (insertInfo == null) {
      throw Exception('Could not find insertion point for: $path');
    }

    // Build the content to insert
    final insertLines = <String>[];

    // Add comments if provided
    if (comments != null && comments.isNotEmpty) {
      for (final comment in comments) {
        insertLines.add('${insertInfo.indent}<!-- $comment -->');
      }
    }
    insertLines.add('${insertInfo.indent}$tag');

    // Insert at the appropriate position
    lines.insertAll(insertInfo.lineIndex, insertLines);

    // Reparse document so subsequent operations see the change
    _updateDocument();
  }

  /// Add a manifest permission
  void addManifestPermission({
    required String permissionName,
    List<String>? comments,
  }) {
    addManifestTag(
      path: 'manifest',
      tag: '<uses-permission android:name="$permissionName" />',
      comments: comments,
    );
  }

  /// Add a key-value pair to a plist file at a specific path
  ///
  /// The value parameter is optional. If null, only the key will be added.
  /// The path parameter is required and specifies where to add the entry.
  ///
  /// Example with root dict:
  /// ```dart
  /// editor.addPlistEntry(
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
  void addPlistEntry({
    required String path,
    required String key,
    String? value,
    List<String>? keyComments,
    List<String>? valueComments,
    List<String>? anchorKeys,
  }) {
    // Find the target dict element at the specified path
    final dict = _findElementByPath(path);

    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // Find insertion position
    final insertInfo = _findPlistInsertPosition(dict, anchorKeys: anchorKeys);
    if (insertInfo == null) {
      throw Exception('Could not find insertion point in plist');
    }

    // Build the content to insert
    final insertLines = <String>[];

    // Add key comments if provided
    if (keyComments != null && keyComments.isNotEmpty) {
      for (final comment in keyComments) {
        insertLines.add('${insertInfo.indent}<!-- $comment -->');
      }
    }
    insertLines.add('${insertInfo.indent}<key>$key</key>');

    // Add value only if provided
    if (value != null) {
      // Add value comments if provided
      if (valueComments != null && valueComments.isNotEmpty) {
        for (final comment in valueComments) {
          insertLines.add('${insertInfo.indent}<!-- $comment -->');
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
  void addPlistUsageDescription({
    required String key,
    required String description,
    List<String>? keyComments,
    List<String>? valueComments,
    List<String>? anchorKeys,
  }) {
    addPlistEntry(
      path: 'plist.dict',
      key: key,
      value: '<string>$description</string>',
      keyComments: keyComments,
      valueComments: valueComments,
      anchorKeys: anchorKeys,
    );
  }

  /// Remove a tag from manifest with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removeManifestTag(
  ///   path: 'manifest.application.activity',
  ///   tagName: 'activity',
  ///   attribute: {'android:name': 'com.example.MainActivity'},
  ///   comments: ['@permit'],
  /// );
  /// ```
  void removeManifestTag({
    required String path,
    required String tagName,
    required (String, String) attribute,
    List<String>? comments,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      throw Exception('Parent element not found: $path');
    }

    // Try to locate the element's line range directly in the file, searching within the parent
    final elementInfo = _findElementLinesByTagAndAttribute(parent, tagName, attribute);
    if (elementInfo == null) {
      throw Exception('Element not found: $tagName with attribute $attribute');
    }

    // Compute start line including optional comment block
    int startLine = elementInfo.startLine;
    if (comments != null && comments.isNotEmpty) {
      startLine = _findCommentBlockStart(elementInfo.startLine, comments);
    }

    // Remove from start of comments (if any) to end of element
    lines.removeRange(startLine, elementInfo.endLine + 1);

    // Reparse document after removal so subsequent operations see the change
    _updateDocument();
  }

  /// Remove a manifest permission by name with its associated comments
  void removeManifestPermission({
    required String permissionName,
    List<String>? comments,
  }) {
    removeManifestTag(
      path: 'manifest',
      tagName: 'uses-permission',
      attribute: ('android:name', permissionName),
      comments: comments,
    );
  }

  /// Find the line range of a child element by tag name and attribute within a parent element
  _ElementLines? _findElementLinesByTagAndAttribute(
    XmlElement parent,
    String tagName,
    (String, String) attribute,
  ) {
    // Get the parent's line range so we only search within it
    final parentInfo = _findElementLines(parent);
    if (parentInfo == null) return null;

    // Search for the opening tag of the child inside the parent's lines
    for (var i = parentInfo.startLine; i <= parentInfo.endLine; i++) {
      final line = lines[i];
      if (!line.contains('<$tagName')) continue;

      // Find end of opening tag (may span multiple lines)
      int j = i;
      for (; j < lines.length; j++) {
        if (lines[j].contains('>')) break;
      }
      if (j >= lines.length) continue;

      // Determine if self-closing
      final openingSegment = lines.sublist(i, j + 1).join('\n');
      final isSelfClosingOpening = openingSegment.contains('/>');

      int endLine = j;
      if (isSelfClosingOpening) {
        // build snippet and parse to confirm attribute
        final snippet = openingSegment;
        try {
          final doc = XmlDocument.parse(
            snippet.contains('<?xml') ? snippet : '<?xml version="1.0"?>\n<root>$snippet</root>',
          );
          // Extract the element from the wrapper
          final parsedEl = doc.findAllElements(tagName).firstOrNull;
          if (parsedEl != null && parsedEl.getAttribute(attribute.$1) == attribute.$2) {
            return _ElementLines(startLine: i, endLine: j, indent: _getLineIndent(i));
          }
        } catch (_) {
          // ignore parse errors for snippet
        }
        continue;
      }

      // Not self-closing: find corresponding closing tag
      int depth = 0;
      bool inOpenTag = true;
      for (var k = j; k < lines.length; k++) {
        final currentLine = lines[k];
        if (inOpenTag) {
          if (currentLine.contains('>') && !currentLine.contains('/>')) {
            inOpenTag = false;
            depth = 1;
            continue;
          }
        } else {
          if (currentLine.contains('<$tagName')) depth++;
          if (currentLine.contains('</$tagName>')) {
            depth--;
            if (depth == 0) {
              endLine = k;
              break;
            }
          }
        }
      }

      // Build full element text and parse it to accurately check attributes
      final elementText = lines.sublist(i, endLine + 1).join('\n');
      try {
        final wrapped = '<?xml version="1.0"?>\n<root>\n$elementText\n</root>';
        final doc = XmlDocument.parse(wrapped);
        final parsedEl = doc.findAllElements(tagName).firstOrNull;
        if (parsedEl != null && parsedEl.getAttribute(attribute.$1) == attribute.$2) {
          return _ElementLines(startLine: i, endLine: endLine, indent: _getLineIndent(i));
        }
      } catch (_) {
        // ignore parse errors and continue
      }
    }

    return null;
  }

  /// Remove a plist key-value pair with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removePlistEntry(
  ///   path: 'plist.dict',
  ///   key: 'NSCameraUsageDescription',
  ///   commentMarkers: ['@permit'],
  /// );
  /// ```
  void removePlistEntry({
    required String path,
    required String key,
    List<String>? commentMarkers,
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

    // Find all comments above the key
    int startLine = keyInfo.startLine;
    if (commentMarkers != null && commentMarkers.isNotEmpty) {
      startLine = _findCommentBlockStart(keyInfo.startLine, commentMarkers);
    }

    // Remove from start of comments to end of value
    lines.removeRange(startLine, valueInfo.endLine + 1);

    // Reparse document after removal so subsequent operations see the change
    _updateDocument();
  }

  /// Remove a plist usage description by key with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removePlistUsageDescription(
  ///   key: 'NSCameraUsageDescription',
  ///   commentMarkers: ['@permit'],
  /// );
  void removePlistUsageDescription({
    required String key,
    List<String>? commentMarkers,
  }) {
    removePlistEntry(
      path: 'plist.dict',
      key: key,
      commentMarkers: commentMarkers,
    );
  }

  /// Find all tags by name within a specific path
  ///
  /// Example:
  /// ```dart
  /// final activities = editor.findTagsByNameInPath(
  ///   path: 'manifest.application',
  ///   tagName: 'activity',
  /// );
  /// ```
  List<XmlElement> findTags({
    required String path,
    required String name,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      return [];
    }

    return parent.findElements(name).toList();
  }

  /// Find all tags by tag name
  ///
  /// Example:
  /// ```dart
  /// final permissions = editor.findTagsByName('uses-permission');
  /// ```
  List<XmlElement> findTagsByName(String tagName) {
    return document.findAllElements(tagName).toList();
  }

  /// Find tags by name and attribute value
  ///
  /// Example:
  /// ```dart
  /// final internetPerm = editor.findTagsByAttribute(
  ///   tagName: 'uses-permission',
  ///   attributeName: 'android:name',
  ///   attributeValue: 'android.permission.INTERNET',
  /// );
  /// ```
  List<XmlElement> findTagsByAttribute({
    String? tagName,
    required String attributeName,
    required String attributeValue,
  }) {
    final elements = tagName != null ? document.findAllElements(tagName) : document.descendants.whereType<XmlElement>();

    return elements.where((e) => e.getAttribute(attributeName) == attributeValue).toList();
  }

  /// Get comments associated with an XML element
  ///
  /// This searches backward from the element's position to find any
  /// comment lines that immediately precede it.
  ///
  /// Example:
  /// ```dart
  /// final permission = editor.findTagsByAttribute(
  ///   tagName: 'uses-permission',
  ///   attributeName: 'android:name',
  ///   attributeValue: 'android.permission.INTERNET',
  /// ).first;
  ///
  /// final comments = editor.getCommentsOf(permission);
  /// // Returns: ['@permit internet access', 'Required for API calls']
  /// ```
  List<String> getCommentsOf(XmlElement element) {
    final elementInfo = _findElementLines(element);
    if (elementInfo == null) {
      return [];
    }

    final comments = <String>[];

    // Look backwards from the element's line for comment lines
    for (int i = elementInfo.startLine - 1; i >= 0; i--) {
      final line = lines[i].trim();

      // Check if this is a comment line
      if (line.startsWith('<!--') && line.endsWith('-->')) {
        final commentText = line.replaceFirst('<!--', '').replaceFirst('-->', '').trim();
        comments.insert(0, commentText); // Insert at beginning to maintain order
      } else if (line.isEmpty) {
        // Empty line, continue looking
        continue;
      } else {
        // Non-comment, non-empty line, stop here
        break;
      }
    }

    return comments;
  }

  /// Find an element by dot-separated path
  XmlElement? _findElementByPath(String path) {
    final parts = path.split('.');
    XmlElement? current;

    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];

      if (i == 0) {
        current = document.findElements(part).firstOrNull;
      } else {
        current = current?.findElements(part).firstOrNull;
      }

      if (current == null) break;
    }

    return current;
  }

  /// Find a specific key in a plist dict
  XmlElement? _findPlistKey(XmlElement dict, String keyName) {
    final keys = dict.findElements('key');
    for (final key in keys) {
      if (key.innerText.trim() == keyName) {
        return key;
      }
    }
    return null;
  }

  /// Get the next sibling element
  XmlElement? _getNextSiblingElement(XmlElement element) {
    final parent = element.parent;
    if (parent == null) return null;

    bool foundCurrent = false;
    for (final child in parent.children) {
      if (foundCurrent && child is XmlElement) {
        return child;
      }
      if (child == element) {
        foundCurrent = true;
      }
    }
    return null;
  }

  /// Find insertion position for manifest tags
  _InsertPosition? _findManifestInsertPosition(
    XmlElement parent, {
    String tagName = '',
  }) {
    final parentName = parent.name.qualified;

    // Find parent element's opening tag
    int? parentLineIndex;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('<$parentName')) {
        parentLineIndex = i;
        break;
      }
    }

    if (parentLineIndex == null) return null;

    // Check if parent is self-closing
    if (lines[parentLineIndex].contains('/>')) {
      throw Exception('Cannot add child to self-closing tag: $parentName');
    }

    // Find where the opening tag ends
    int openTagEndLine = parentLineIndex;
    while (openTagEndLine < lines.length && !lines[openTagEndLine].contains('>')) {
      openTagEndLine++;
    }

    // If a specific tag name was provided, find siblings of that type
    if (tagName.isNotEmpty) {
      final siblingsOfType = parent.children.whereType<XmlElement>().where((e) => e.name.qualified == tagName).toList();

      if (siblingsOfType.isNotEmpty) {
        // Insert after the last sibling of the same type
        final lastSiblingOfType = siblingsOfType.last;
        final lastSiblingInfo = _findElementLines(lastSiblingOfType);

        if (lastSiblingInfo != null) {
          return _InsertPosition(
            lineIndex: lastSiblingInfo.endLine + 1,
            indent: lastSiblingInfo.indent,
          );
        }
      }
    }

    // No same-type siblings, insert at top (after opening tag)
    final children = parent.children.whereType<XmlElement>().toList();
    if (children.isNotEmpty) {
      final firstChild = children.first;
      final firstChildInfo = _findElementLines(firstChild);
      if (firstChildInfo != null) {
        return _InsertPosition(
          lineIndex: firstChildInfo.startLine,
          indent: firstChildInfo.indent,
        );
      }
    }

    // No children, insert right after the opening tag
    final baseIndent = _getLineIndent(parentLineIndex);
    return _InsertPosition(
      lineIndex: openTagEndLine + 1,
      indent: '$baseIndent    ',
    );
  }

  /// Find insertion position for plist entries
  _InsertPosition? _findPlistInsertPosition(
    XmlElement dict, {
    List<String>? anchorKeys,
  }) {
    // If anchor keys provided, try to find them
    if (anchorKeys != null && anchorKeys.isNotEmpty) {
      for (final anchorKey in anchorKeys) {
        final keyElement = _findPlistKey(dict, anchorKey);
        if (keyElement != null) {
          final valueElement = _getNextSiblingElement(keyElement);
          if (valueElement != null) {
            final valueInfo = _findElementLines(valueElement);
            if (valueInfo != null) {
              return _InsertPosition(
                lineIndex: valueInfo.endLine + 1,
                indent: valueInfo.indent,
              );
            }
          }
        }
      }
    }

    // No anchor found, insert at top of dict
    final dictInfo = _findElementLines(dict);
    if (dictInfo == null) return null;

    // Find first key in dict
    final firstKey = dict.findElements('key').firstOrNull;
    if (firstKey != null) {
      final firstKeyInfo = _findElementLines(firstKey);
      if (firstKeyInfo != null) {
        return _InsertPosition(
          lineIndex: firstKeyInfo.startLine,
          indent: firstKeyInfo.indent,
        );
      }
    }

    // Empty dict, insert after opening tag
    final baseIndent = _getLineIndent(dictInfo.startLine);
    return _InsertPosition(
      lineIndex: dictInfo.startLine + 1,
      indent: '$baseIndent    ',
    );
  }

  /// Find the start of a comment block above a line
  int _findCommentBlockStart(int lineIndex, List<String> commentMarkers) {
    int startLine = lineIndex;

    // Look backwards for comments with matching markers
    for (int i = lineIndex - 1; i >= 0; i--) {
      final line = lines[i].trim();

      // Check if this is a comment line
      if (line.startsWith('<!--') && line.endsWith('-->')) {
        // Check if it contains any of the markers
        bool hasMarker = commentMarkers.any((marker) => line.contains(marker));
        if (hasMarker) {
          startLine = i;
        } else {
          // Non-matching comment, stop here
          break;
        }
      } else if (line.isEmpty) {
        // Empty line, continue looking
        continue;
      } else {
        // Non-comment, non-empty line, stop here
        break;
      }
    }

    return startLine;
  }

  /// Find the line range of an element in the original content
  _ElementLines? _findElementLines(XmlElement element) {
    final tagName = element.name.qualified;
    final isSelfClosing =
        element.children.whereType<XmlElement>().isEmpty &&
        element.children.whereType<XmlText>().every((t) => t.value.trim().isEmpty);

    // Build a pattern to match this specific element by its attributes
    final attributes = element.attributes.map((a) => '${a.name.qualified}="${a.value}"').toList();

    // For elements with text content, get the content
    final elementText = element.innerText.trim();

    // Only use occurrence counting for leaf elements (no child elements)
    final hasChildElements = element.children.whereType<XmlElement>().isNotEmpty;

    // Find which occurrence this element is among siblings of the same type
    int elementIndex = 0;
    if (!hasChildElements) {
      final parent = element.parent;
      if (parent != null) {
        for (final child in parent.children) {
          if (child is XmlElement && child.name.qualified == tagName) {
            if (child == element) break;
            elementIndex++;
          }
        }
      }
    }

    // Find the element in lines
    int occurrenceCount = 0;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('<$tagName')) {
        // Verify this is the right element by checking attributes
        bool allAttributesMatch =
            attributes.isEmpty ||
            attributes.every((attr) {
              // Check only within the element's opening tag (don't scan arbitrary following lines)
              for (var j = i; j < lines.length; j++) {
                final current = lines[j];
                if (current.contains(attr)) return true;
                // If we've reached the end of the opening tag, stop searching further
                if (current.contains('>') || current.contains('/>')) {
                  break;
                }
              }
              return false;
            });

        if (!allAttributesMatch) continue;

        // For text-based leaf elements, verify we have the right occurrence
        if (elementText.isNotEmpty && attributes.isEmpty && !hasChildElements) {
          // Check if this element's text content matches
          bool textMatches = false;
          for (var j = i; j < i + 20 && j < lines.length; j++) {
            if (lines[j].contains(elementText)) {
              textMatches = true;
              break;
            }
          }
          if (!textMatches) continue;

          // Only use this if it's the right occurrence
          if (occurrenceCount != elementIndex) {
            occurrenceCount++;
            continue;
          }
        }

        // Found the element, now find its end
        if (isSelfClosing || line.contains('/>')) {
          // Self-closing tag
          int endLine = i;
          while (!lines[endLine].contains('/>')) {
            endLine++;
            if (endLine >= lines.length) break;
          }
          return _ElementLines(
            startLine: i,
            endLine: endLine,
            indent: _getLineIndent(i),
          );
        } else {
          // Find closing tag
          int endLine = i;
          int depth = 0;
          bool inOpenTag = true;

          for (var j = i; j < lines.length; j++) {
            final currentLine = lines[j];

            if (inOpenTag) {
              if (currentLine.contains('>') && !currentLine.contains('/>')) {
                inOpenTag = false;
                depth = 1;
              }
            } else {
              if (currentLine.contains('<$tagName')) depth++;
              if (currentLine.contains('</$tagName>')) {
                depth--;
                if (depth == 0) {
                  endLine = j;
                  break;
                }
              }
            }
          }

          return _ElementLines(
            startLine: i,
            endLine: endLine,
            indent: _getLineIndent(i),
          );
        }
      }
    }

    return null;
  }

  /// Get the indentation of a line
  String _getLineIndent(int lineIndex) {
    if (lineIndex >= lines.length) return '';
    final line = lines[lineIndex];
    final match = RegExp(r'^(\s*)').firstMatch(line);
    return match?.group(1) ?? '';
  }

  /// Get the modified content as a string
  String toXmlString() => lines.join('\n');

  /// Save to file
  Future<void> saveToFile(String path) async {
    final file = File(path);
    await file.writeAsString(toXmlString());
  }

  /// Validate that the modified content is still valid XML
  bool validate() {
    try {
      XmlDocument.parse(toXmlString());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update the document instance after edits
  void _updateDocument() {
    try {
      document = XmlDocument.parse(toXmlString());
    } catch (e) {
      // If parsing fails, keep the old document
    }
  }
}

class _InsertPosition {
  final int lineIndex;
  final String indent;

  _InsertPosition({required this.lineIndex, required this.indent});
}

class _ElementLines {
  final int startLine;
  final int endLine;
  final String indent;

  _ElementLines({
    required this.startLine,
    required this.endLine,
    required this.indent,
  });
}
