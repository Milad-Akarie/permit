import 'dart:io';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'models.dart';
part 'plist_editor.dart';
part 'manifest_editor.dart';

typedef CommentRemoverPredicate = bool Function(String comment);

/// A node-based XML editor that preserves formatting
class XmlEditor {
  late XmlDocument document;

  XmlEditor(String content) {
    document = XmlDocument.parse(content);
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
    final parent = element.parent;
    if (parent == null) return [];

    final comments = <String>[];
    final elementIndex = parent.children.indexOf(element);

    // Look backwards from the element for comment nodes
    for (int i = elementIndex - 1; i >= 0; i--) {
      final node = parent.children[i];

      if (node is XmlComment) {
        comments.insert(0, node.value.trim());
      } else if (node is XmlText && node.value.trim().isEmpty) {
        // Skip whitespace
        continue;
      } else {
        // Hit a non-comment, non-whitespace node
        break;
      }
    }

    return comments;
  }

  /// Convert the document to XML string with custom formatting
  String toXmlString() {
    return _toXmlString(document.rootElement, 0);
  }

  String _toXmlString(XmlNode node, int depth) {
    if (node is XmlElement) {
      final indent = '    ' * depth;
      final attributes = node.attributes;
      final children = node.children.where((c) => c is! XmlText || c.value.trim().isNotEmpty);

      // For certain elements, put attributes on new lines
      final multiLineAttributes = [
        'application',
        'activity',
        'service',
        'intent-filter',
        'action',
        'category',
      ].contains(node.name.local);

      final attrString = attributes.isEmpty
          ? ''
          : multiLineAttributes
          ? '\n${attributes.map((a) => '$indent    ${a.name}="${a.value}"').join('\n')}\n$indent'
          : ' ${attributes.map((a) => '${a.name}="${a.value}"').join(' ')}';

      if (children.isEmpty) {
        return '$indent<${node.name}$attrString/>';
      } else {
        final childStrings = children.map((c) => _toXmlString(c, depth + 1)).where((s) => s.isNotEmpty).toList();
        final content = childStrings.isEmpty ? '' : '\n${childStrings.join('\n')}\n$indent';
        return '$indent<${node.name}$attrString>$content</${node.name}>';
      }
    } else if (node is XmlText) {
      return node.value.trim().isEmpty ? '' : '${'    ' * depth}${node.value.trim()}';
    } else if (node is XmlComment) {
      return '${'    ' * depth}<!--${node.value}-->';
    } else if (node is XmlProcessing) {
      return node.toXmlString();
    } else {
      return node.toXmlString();
    }
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

  /// Add an element to a parent with proper formatting
  void _addElement(
    XmlElement parent,
    String elementString, {
    List<String>? comments,
    XmlElement? afterSibling,
  }) {
    // Parse the element
    final fragment = XmlDocumentFragment.parse(elementString);
    final nodesToAdd = fragment.children.map((c) => c.copy()).toList();

    // Find insertion index
    int insertIndex;
    if (afterSibling != null) {
      insertIndex = parent.children.indexOf(afterSibling) + 1;
    } else {
      // Insert at the beginning (after any existing comments/whitespace at start)
      insertIndex = 0;
      for (var i = 0; i < parent.children.length; i++) {
        final child = parent.children[i];
        if (child is XmlElement) {
          insertIndex = i;
          break;
        }
        if (child is XmlText && child.value.trim().isNotEmpty) {
          insertIndex = i;
          break;
        }
      }
    }

    // Add whitespace before comments/element
    parent.children.insert(insertIndex++, XmlText('\n    '));

    // Add comments if provided
    if (comments != null && comments.isNotEmpty) {
      for (final comment in comments) {
        parent.children.insert(insertIndex++, XmlComment(comment));
        parent.children.insert(insertIndex++, XmlText('\n    '));
      }
    }

    // Add the nodes
    for (final node in nodesToAdd) {
      parent.children.insert(insertIndex++, node);
    }
  }

  /// Remove an element and optionally its preceding comments
  void _removeElement(XmlElement element, {CommentRemoverPredicate? shouldRemoveComment}) {
    final parent = element.parent;
    if (parent == null) return;

    final elementIndex = parent.children.indexOf(element);
    final nodesToRemove = <XmlNode>[element];

    // Find preceding whitespace
    if (elementIndex > 0 && parent.children[elementIndex - 1] is XmlText) {
      final text = parent.children[elementIndex - 1] as XmlText;
      if (text.value.trim().isEmpty) {
        nodesToRemove.insert(0, text);
      }
    }

    // Find and remove matching comments
    if (shouldRemoveComment != null) {
      for (int i = elementIndex - 1; i >= 0; i--) {
        final node = parent.children[i];

        if (node is XmlComment) {
          if (shouldRemoveComment(node.value.trim())) {
            nodesToRemove.insert(0, node);
            // Also remove whitespace before comment
            if (i > 0 && parent.children[i - 1] is XmlText) {
              final text = parent.children[i - 1] as XmlText;
              if (text.value.trim().isEmpty) {
                nodesToRemove.insert(0, text);
              }
            }
          }
        } else if (node is XmlText && node.value.trim().isEmpty) {
          continue;
        } else {
          break;
        }
      }
    }

    // Remove all collected nodes
    for (final node in nodesToRemove) {
      parent.children.remove(node);
    }
  }

  /// Find the last sibling of a specific tag name
  XmlElement? _findLastSiblingOfType(XmlElement parent, String tagName) {
    XmlElement? lastOfType;
    for (final child in parent.children.whereType<XmlElement>()) {
      if (child.name.qualified == tagName) {
        lastOfType = child;
      }
    }
    return lastOfType;
  }

  bool save(File file) {
    try {
      file.writeAsStringSync(toXmlString());
      return true;
    } catch (e) {
      return false;
    }
  }
}
