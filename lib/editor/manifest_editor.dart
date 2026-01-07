part of 'xml_editor.dart';

/// Android Manifest-specific editor
class ManifestEditor extends XmlEditor {
  ManifestEditor(super.content);

  /// Add a tag to the manifest
  void addTag({
    required String path,
    required String tag,
    List<String>? comments,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      throw Exception('Parent element not found: $path');
    }

    // Extract the tag name from the tag string
    final tagNameMatch = RegExp(r'<(\w+[\w:-]*)').firstMatch(tag);
    final tagName = tagNameMatch?.group(1) ?? '';

    // If override is true, check if a tag with the same attributes exists
    if (override && tagName.isNotEmpty) {
      try {
        final wrappedTag = tag.contains('<?xml') ? tag : '<?xml version="1.0"?>\n<root>$tag</root>';
        final doc = XmlDocument.parse(wrappedTag);
        final parsedEl = doc.findAllElements(tagName).firstOrNull;

        if (parsedEl != null && parsedEl.attributes.isNotEmpty) {
          final nameAttr = parsedEl.getAttribute('android:name');
          if (nameAttr != null) {
            // Find existing element with same attribute
            final existing = parent.children.whereType<XmlElement>().firstWhereOrNull(
              (e) => e.name.qualified == tagName && e.getAttribute('android:name') == nameAttr,
            );

            if (existing != null) {
              _removeElement(existing, shouldRemoveComment: shouldRemoveComment);
            }
          }
        }
      } catch (_) {
        // If parsing fails, continue with normal insertion
      }
    }

    // Find where to insert (after last sibling of same type)
    final lastSiblingOfType = _findLastSiblingOfType(parent, tagName);

    // Add the element
    _addElement(parent, tag, comments: comments, afterSibling: lastSiblingOfType);
  }

  List<ManifestPermissionEntry> getPermissions() {
    final manifest = _findElementByPath('manifest');
    if (manifest == null) {
      throw Exception('Manifest element not found');
    }

    final permissionEntries = <ManifestPermissionEntry>[];

    for (final permission in manifest.findElements('uses-permission')) {
      final name = permission.getAttribute('android:name');
      if (name != null) {
        permissionEntries.add(
          ManifestPermissionEntry(
            key: name,
            comments: getCommentsOf(permission),
          ),
        );
      }
    }

    return permissionEntries;
  }

  /// Adds a permission to the manifest
  void addPermission({
    required String name,
    List<String>? comments,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    addTag(
      path: 'manifest',
      tag: '<uses-permission android:name="$name" />',
      comments: comments,
      override: override,
      shouldRemoveComment: shouldRemoveComment,
    );
  }

  void removeTag({
    required String path,
    required String tagName,
    required (String, String) attribute,
    CommentRemoverPredicate? removeComments,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      throw Exception('Parent element not found: $path');
    }

    final element = parent.children.whereType<XmlElement>().firstWhereOrNull(
      (e) => e.name.qualified == tagName && e.getAttribute(attribute.$1) == attribute.$2,
    );

    if (element == null) {
      throw Exception('Element not found: $tagName with attribute $attribute');
    }

    _removeElement(element, shouldRemoveComment: removeComments);
  }

  void removePermission({
    required String permissionName,
    CommentRemoverPredicate? removeComments,
  }) {
    removeTag(
      path: 'manifest',
      tagName: 'uses-permission',
      attribute: ('android:name', permissionName),
      removeComments: removeComments,
    );
  }
}
