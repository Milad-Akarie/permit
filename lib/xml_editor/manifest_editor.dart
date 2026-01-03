part of 'xml_editor.dart';

/// Android Manifest-specific editor
class ManifestEditor extends XmlEditor {
  ManifestEditor(super.originalContent);

  /// New canonical methods
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
      // Parse the tag to extract its attributes
      try {
        final wrappedTag = tag.contains('<?xml') ? tag : '<?xml version="1.0"?>\n<root>$tag</root>';
        final doc = XmlDocument.parse(wrappedTag);
        final parsedEl = doc.findAllElements(tagName).firstOrNull;

        if (parsedEl != null && parsedEl.attributes.isNotEmpty) {
          // Try to find an existing tag with the same primary attribute
          // For Android manifest tags, typically the "android:name" attribute is the key identifier
          final nameAttr = parsedEl.getAttribute('android:name');
          if (nameAttr != null) {
            final existingElementInfo = _findElementLinesByTagAndAttribute(
              parent,
              tagName,
              ('android:name', nameAttr),
            );

            if (existingElementInfo != null) {
              // Remove existing tag including comments that match our criteria
              // Default to removing @permit comments if no callback specified
              _removeElementAndMatchingComments(existingElementInfo, shouldRemoveComment);

              // Re-find parent after document update
              final updatedParent = _findElementByPath(path);
              if (updatedParent == null) {
                throw Exception('Parent element not found after override: $path');
              }
            }
          }
        }
      } catch (_) {
        // If parsing fails, continue with normal insertion
      }
    }

    // Re-find parent to ensure we have fresh reference
    final currentParent = _findElementByPath(path);
    if (currentParent == null) {
      throw Exception('Parent element not found: $path');
    }

    // Find insertion position based on siblings of the same type
    final insertInfo = _findManifestInsertPosition(currentParent, tagName: tagName);
    if (insertInfo == null) {
      throw Exception('Could not find insertion point for: $path');
    }

    // Build the content to insert
    final insertLines = <String>[];

    // Add comments if provided
    if (comments != null && comments.isNotEmpty) {
      for (final comment in comments) {
        insertLines.add('${insertInfo.indent}<!--$comment-->');
      }
    }
    insertLines.add('${insertInfo.indent}$tag');

    // Insert at the appropriate position
    lines.insertAll(insertInfo.lineIndex, insertLines);

    // Reparse document so subsequent operations see the change
    _updateDocument();
  }

  /// adds a feature to application tag
  void addFeature({
    required String name,
    bool required = false,
    List<String>? comments,
    bool override = true,
    CommentRemoverPredicate? shouldRemoveComment,
  }) {
    addTag(
      path: 'manifest.application',
      tag: '<uses-feature android:name="$name" android:required="${required.toString().toLowerCase()}" />',
      comments: comments,
      override: override,
      shouldRemoveComment: shouldRemoveComment,
    );
  }

  // removes a feature from application tag
  void removeFeature({
    required String name,
    List<String>? comments,
  }) {
    removeTag(
      path: 'manifest.application',
      tagName: 'uses-feature',
      attribute: ('android:name', name),
      comments: comments,
    );
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
    List<String>? comments,
  }) {
    final parent = _findElementByPath(path);
    if (parent == null) {
      throw Exception('Parent element not found: $path');
    }

    final elementInfo = _findElementLinesByTagAndAttribute(parent, tagName, attribute);
    if (elementInfo == null) {
      throw Exception('Element not found: $tagName with attribute $attribute');
    }

    if (comments != null && comments.isNotEmpty) {
      bool predicate(String c) => comments.any((marker) => c.contains(marker));
      _removeElementAndMatchingComments(elementInfo, predicate);
      return;
    }
    // No comment markers provided: remove the element itself (but keep existing comments)
    _removeElementAndMatchingComments(elementInfo, null);
  }

  void removePermission({
    required String permissionName,
    List<String>? comments,
  }) {
    removeTag(
      path: 'manifest',
      tagName: 'uses-permission',
      attribute: ('android:name', permissionName),
      comments: comments,
    );
  }

  // Internal helper used by removeTag
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
}
