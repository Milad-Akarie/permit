part of 'xml_editor.dart';

/// Plist-specific editor
class PListEditor extends XmlEditor {
  PListEditor(super.content);

  bool isNSUsageDesc(String key) {
    return key.startsWith('NS') && key.endsWith('UsageDescription');
  }

  /// Add a key-value pair to a plist file at a specific path
  void addEntry({
    required String path,
    required String key,
    String? value,
    List<String>? keyComments,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    // If override is true, remove existing key
    if (override) {
      final existingKey = _findPlistKey(dict, key);
      if (existingKey != null) {
        final valueElement = _getNextSiblingElement(existingKey);
        // Remove key
        _removeElement(existingKey, shouldRemoveComment: shouldRemoveComment);
        // Remove value if exists
        if (valueElement != null) {
          _removeElement(valueElement);
        }
      }
    }

    // Find last NS*UsageDescription key to anchor after
    XmlElement? anchorElement;
    final dictChildren = dict.children.whereType<XmlElement>().toList();
    for (int i = dictChildren.length - 1; i >= 0; i--) {
      final child = dictChildren[i];
      if (child.name.qualified == 'key') {
        final keyName = child.innerText.trim();
        if (isNSUsageDesc(keyName)) {
          // Find its value element to anchor after
          anchorElement = _getNextSiblingElement(child);
          break;
        }
      }
    }

    // Build key-value string
    final keyElement = '<key>$key</key>';
    final combined = value != null ? '$keyElement$value' : keyElement;

    _addElement(dict, combined, comments: keyComments, afterSibling: anchorElement);
  }

  /// Add a plist usage description
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
      override: override,
      shouldRemoveComment: shouldRemoveComment,
    );
  }

  /// Remove a plist key-value pair with its associated comments
  void removeEntry({
    required String path,
    required String key,
    CommentRemoverPredicate? removeComments,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    final keyElement = _findPlistKey(dict, key);
    if (keyElement == null) {
      throw Exception('Key not found: $key');
    }

    final valueElement = _getNextSiblingElement(keyElement);

    // Remove key with its comments
    _removeElement(keyElement, shouldRemoveComment: removeComments);

    // Remove value if exists
    if (valueElement != null) {
      _removeElement(valueElement);
    }
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
    removeEntry(path: 'plist.dict', key: key, removeComments: removeComments);
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
        if (!isNSUsageDesc(keyName)) continue;
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
        // Array exists, parse and add entry
        final wrappedEntry = entry.contains('<?xml') ? entry : '<?xml version="1.0"?>\n<root>$entry</root>';
        final tempDoc = XmlDocument.parse(wrappedEntry);
        final newElement = tempDoc.rootElement.children.whereType<XmlElement>().first.copy();

        // Add to end of array
        existingValue.children.add(XmlText('\n        '));
        existingValue.children.add(newElement);
        existingValue.children.add(XmlText('\n    '));
        return;
      }
    }

    // Array doesn't exist, create new key-array pair
    final arrayContent = '<key>$key</key>\n    <array>\n        $entry\n    </array>';
    _addElement(dict, arrayContent, comments: keyComments);
  }

  /// Remove an entry from an array at a specific path
  void removeArrayEntry({
    required String path,
    required String key,
    required String entry,
  }) {
    final dict = _findElementByPath(path);
    if (dict == null) {
      throw Exception('Could not find <dict> element at path: $path');
    }

    final keyElement = _findPlistKey(dict, key);
    if (keyElement == null) {
      throw Exception('Key not found: $key');
    }

    final arrayElement = _getNextSiblingElement(keyElement);
    if (arrayElement == null || arrayElement.name.qualified != 'array') {
      throw Exception('Array not found for key: $key');
    }

    // Find and remove the entry element by matching inner text
    final entryToRemove = arrayElement.children.whereType<XmlElement>().firstWhereOrNull(
      (e) => e.toXmlString().trim() == entry.trim(),
    );

    if (entryToRemove == null) {
      throw Exception('Entry not found in array: $entry');
    }

    // Remove the element
    final index = arrayElement.children.indexOf(entryToRemove);
    arrayElement.children.removeAt(index);

    // Also remove preceding whitespace
    if (index > 0 && arrayElement.children[index - 1] is XmlText) {
      arrayElement.children.removeAt(index - 1);
    }

    // Check if array is now empty
    final remainingElements = arrayElement.children.whereType<XmlElement>().toList();
    if (remainingElements.isEmpty) {
      // Remove the entire key-array pair
      _removeElement(keyElement);
      _removeElement(arrayElement);
    }
  }
}
