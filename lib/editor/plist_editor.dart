part of 'xml_editor.dart';

/// Plist-specific editor
class PListEditor extends XmlEditor {
  PListEditor(super.source);

  bool isNSUsageDesc(String? name) {
    if (name == null) return false;
    final trimmed = name.trim();
    return trimmed.startsWith('NS') && trimmed.endsWith('UsageDescription');
  }

  static const _mainDict = 'plist.dict';

  /// Add a plist usage description
  void addUsageDescription({
    required String key,
    required String description,
    List<String>? keyComments,
    List<String>? valueComments,
    RemoveComment? removeCommentsOnUpdate,
  }) {
    // Remove existing usage description if present
    removeUsageDescription(
      name: key,
      removeComments: removeCommentsOnUpdate,
    );

    insert(
      XmlInsertElementEdit(
        path: _mainDict,
        tags: [
          XmlElementInfo(name: 'key', content: key, comments: keyComments),
          XmlElementInfo(name: 'string', content: description, comments: valueComments),
        ],
        insertAfter: (key, content) => key == 'key' && isNSUsageDesc(content),
      ),
    );
  }

  @override
  (int, String) getInsertionAnchor(XmlInsertElementEdit insert) {
    final defaultIndent = '	 ';

    final range = _getElementScope(insert.path);
    if (range == null) return (-1, defaultIndent);

    int anchor = -1;

    if (insert.insertAfter != null) {
      for (var i = range.start; i <= range.end; i++) {
        final event = _events[i];
        if (event is! XmlStartElementEvent) continue;

        final content = (i + 1 <= range.end && _events[i + 1] is XmlTextEvent) ? _events[i + 1] as XmlTextEvent : null;

        if (!insert.insertAfter!(event.name, content?.value)) continue;

        if (event.name == 'key') {
          // Find the next value element start tag.
          var j = i + 1;
          while (j <= range.end && _events[j] is! XmlStartElementEvent) {
            j++;
          }

          if (j <= range.end) {
            final valueStart = j;

            // Find the matching end tag and set anchor to the index AFTER it.
            var depth = 0;
            for (var k = valueStart; k <= range.end; k++) {
              final e = _events[k];
              if (e is XmlStartElementEvent) depth++;
              if (e is XmlEndElementEvent) depth--;
              if (depth == 0) {
                anchor = k + 1; // insertion position (after value element)
                break;
              }
            }

            // If we couldn't find a clean end, fall back to after the value start tag.
            if (anchor == -1) anchor = valueStart + 1;
          } else {
            // No value element found; fall back to after the key node.
            anchor = i + 1;
          }
        } else {
          // Non-key match: insert after this element's start/text as before.
          anchor = i + 1;
        }
      }
    }

    if (anchor != -1) {
      return (anchor, _getPreviousElementIndent(max(0, anchor - 1)));
    }

    return (range.start, _getNextElementIndent(range.start));
  }

  /// Remove a plist usage description by key with its associated comments
  ///
  /// Example:
  /// ```dart
  /// editor.removeUsageDescription(
  ///   key: 'NSCameraUsageDescription',
  ///   removeComments: (comment) => comment.contains('@marker'),
  ///   );
  /// ```
  void removeUsageDescription({
    required String name,
    RemoveComment? removeComments,
  }) {
    remove(
      XmlRemoveElementEdit(
        path: 'plist.dict',
        tag: 'key',
        content: name,
        removeNextTag: 'string',
        commentRemover: removeComments,
      ),
    );
  }

  List<PListUsageDescription> getUsageDescriptions() {
    final descriptions = <PListUsageDescription>[];
    final range = _getElementScope(_mainDict);
    if (range == null) return descriptions;

    final comments = <String>[];
    for (var i = range.start; i <= range.end; i++) {
      final event = _events[i];
      if (event is XmlCommentEvent) {
        comments.add(event.value);
        continue;
      } else if (event is XmlStartElementEvent) {
        final content = (i + 1 < range.end && _events[i + 1] is XmlTextEvent) ? _events[i + 1] as XmlTextEvent : null;
        String? key;
        String? description;

        if (content != null && event.name == 'key' && isNSUsageDesc(content.value)) {
          key = content.value;
          // find next XmlStartElementEvent for string
          for (var j = i + 2; j <= range.end; j++) {
            final nextEvent = _events[j];

            if (nextEvent is XmlStartElementEvent) {
              final nextContent = (j + 1 < range.end && _events[j + 1] is XmlTextEvent)
                  ? _events[j + 1] as XmlTextEvent
                  : null;
              if (nextEvent.name == 'string' && nextContent != null) {
                description = nextContent.value;
              }
              break;
            }
          }
        }
        if (key != null) {
          descriptions.add(
            PListUsageDescription(
              key: key,
              description: description ?? '',
              comments: List.from(comments),
            ),
          );
        }
        comments.clear();
      }
    }

    return descriptions;
  }

  /// Add an entry to an array at a specific path
  void addArrayEntry({
    required String path,
    required String key,
    required String entry,
    String? keyComment,
  }) {}

  /// Remove an entry from an array at a specific path
  void removeArrayEntry({
    required String path,
    required String key,
    required String entry,
  }) {}
}
