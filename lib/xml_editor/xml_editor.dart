import 'dart:io';
import 'package:xml/xml.dart';
part 'plist_editor.dart';
part 'manifest_editor.dart';

typedef CommentRemoverPredicate = bool Function(String comment);

/// A surgical XML editor that preserves the original file format
class XmlEditor {
  final String originalContent;
  late XmlDocument document;
  final List<String> lines;

  XmlEditor(this.originalContent) : lines = originalContent.split('\n') {
    document = XmlDocument.parse(originalContent);
  }

  /// Find all tags by name within a specific path
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
  List<XmlElement> findTagsByName(String tagName) {
    return document.findAllElements(tagName).toList();
  }

  /// Find tags by name and attribute value
  List<XmlElement> findTagsByAttribute({
    String? tagName,
    required String attributeName,
    required String attributeValue,
  }) {
    final elements = tagName != null ? document.findAllElements(tagName) : document.descendants.whereType<XmlElement>();

    return elements.where((e) => e.getAttribute(attributeName) == attributeValue).toList();
  }

  /// Get comments associated with an XML element
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

  // --- Private helper methods used by subclasses ---

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
  /// Use [shouldRemoveComment] callback to determine which comments to include in removal
  int _findCommentBlockStart(
    int lineIndex, {
    bool Function(String comment)? shouldRemoveComment,
  }) {
    if (shouldRemoveComment == null) return lineIndex;

    int startLine = lineIndex;

    // Look backwards for comments that match the removal criteria
    for (int i = lineIndex - 1; i >= 0; i--) {
      final line = lines[i].trim();

      // Check if this is a comment line
      if (line.startsWith('<!--') && line.endsWith('-->')) {
        // Extract the comment text (without <!-- and -->)
        final commentText = line.substring(4, line.length - 3).trim();

        // Check if this comment should be removed
        if (shouldRemoveComment(commentText)) {
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

  /// Remove an element (given by its line range) and selectively remove
  /// any preceding comment lines for which [shouldRemoveComment] returns true.
  ///
  /// This removes only the matching comment lines and the element itself.
  /// Non-matching comments are left in place.
  void _removeElementAndMatchingComments(_ElementLines elementInfo, CommentRemoverPredicate? shouldRemoveComment) {
    // Collect indices to remove: the element's lines plus any matching comment lines above
    final indicesToRemove = <int>[];

    // Add element lines
    for (int i = elementInfo.startLine; i <= elementInfo.endLine; i++) {
      indicesToRemove.add(i);
    }

    if (shouldRemoveComment != null) {
      // Scan upward for contiguous comment lines (skip empty lines)
      for (int i = elementInfo.startLine - 1; i >= 0; i--) {
        final line = lines[i].trim();
        if (line.isEmpty) {
          // skip empty lines but continue scanning
          continue;
        }

        if (line.startsWith('<!--') && line.endsWith('-->')) {
          final commentText = line.substring(4, line.length - 3).trim();
          if (shouldRemoveComment(commentText)) {
            indicesToRemove.add(i);
            // continue scanning; we want to collect other matching comments even if non-matching ones exist
            continue;
          } else {
            // Non-matching comment: continue scanning upward because there may be matching comments further up
            continue;
          }
        }

        // Non-comment, non-empty line: stop scanning
        break;
      }
    }

    // Remove indices in descending order to avoid shifting issues
    indicesToRemove.sort((a, b) => b.compareTo(a));
    for (final idx in indicesToRemove) {
      if (idx >= 0 && idx < lines.length) {
        lines.removeAt(idx);
      }
    }

    _updateDocument();
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
