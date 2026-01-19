import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:xml/xml_events.dart';

import 'models.dart';

part 'manifest_editor.dart';
part 'plist_editor.dart';

/// A function type for determining whether to remove a comment.
typedef RemoveComment = bool Function(String comment);
const _defaultIndent = '  ';

/// A utility class for editing XML-like content (XML or Plist) while preserving formatting and comments.
class XmlEditor {
  final String _source;
  final List<XmlEvent> _events;

  /// Default constructor.
  XmlEditor(this._source) : _events = _parseIntoEvents(_source);

  static List<XmlEvent> _parseIntoEvents(String source) {
    final events = parseEvents(
      source,
      withLocation: true,
      withParent: true,
      validateDocument: true,
      validateNesting: true,
    );
    final eventList = <XmlEvent>[];
    for (final event in events) {
      if (event is XmlTextEvent) {
        final text = event.value;
        if (text.codeUnits.toSet().length != text.length) {
          final currentLine = <int>[];
          for (final char in text.codeUnits) {
            if (char == 10) {
              if (currentLine.isNotEmpty) {
                eventList.add(XmlTextEvent(String.fromCharCodes(currentLine)));
                currentLine.clear();
              }
              currentLine.add(char);
            } else {
              currentLine.add(char);
            }
          }
          if (currentLine.isNotEmpty) {
            eventList.add(XmlTextEvent(String.fromCharCodes(currentLine)));
          }
        } else {
          eventList.add(event);
        }
      } else {
        eventList.add(event);
      }
    }
    return eventList;
  }

  /// Inserts a new element based on the provided [insert] definition.
  void insert(XmlInsertElementEdit insert) {
    final (anchor, indent) = getInsertionAnchor(insert);
    if (anchor == -1) {
      throw ArgumentError('Insertion path not found: ${insert.path}');
    }

    _events.insertAll(anchor, insert.buildEvents(indent));
  }

  /// Removes an element based on the provided [remove] definition.
  ///
  /// Returns `true` if any elements were removed.
  bool remove(XmlRemoveElementEdit remove) {
    final indices = _getRemovableIndices(remove);
    if (indices.isEmpty) {
      return false;
    } else {
      for (final index in indices.reversed) {
        _events.removeAt(index);
      }
    }
    return true;
  }

  void _append(XmlEvent event, StringBuffer buffer) {
    if (event.start != null && event.stop != null) {
      buffer.write(_source.substring(event.start!, event.stop!));
    } else {
      buffer.write(event.toString());
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (final event in _events) {
      _append(event, buffer);
    }
    return buffer.toString();
  }

  Range? _getElementScope(String path) {
    int startIndex = -1;
    int endIndex = -1;
    final pathParts = <String>[];
    for (var i = 0; i < _events.length; i++) {
      final event = _events[i];
      if (event is XmlStartElementEvent) {
        pathParts.add(event.name);
        if (pathParts.join('.') == path) {
          startIndex = i;
          if (event.isSelfClosing) {
            pathParts.removeLast();
            endIndex = i;
            break;
          }
        } else if (event.isSelfClosing) {
          pathParts.removeLast();
        }
      } else if (event is XmlEndElementEvent) {
        if (pathParts.join('.') == path) {
          endIndex = i;
          break;
        } else {
          pathParts.removeLast();
        }
      }
    }
    if (startIndex != -1 && endIndex != -1) {
      return Range(startIndex + 1, endIndex - 1);
    }
    return null;
  }

  List<int> _getRemovableIndices(XmlRemoveElementEdit remove) {
    final removedIndices = <int>[];
    final range = _getElementScope(remove.path);
    if (range == null) return removedIndices;

    final mainTagIndices = _removeElement(range, remove);
    mainTagIndices.sort();
    removedIndices.addAll(mainTagIndices);
    if (remove.removeNextTag != null && mainTagIndices.isNotEmpty) {
      final newTagRange = Range(
        mainTagIndices.last + 1,
        range.end,
      );
      final nextTagIndices = _removeElement(
        newTagRange,
        XmlRemoveElementEdit(
          tag: remove.removeNextTag!,
          path: remove.path,
          commentRemover: remove.commentRemover,
        ),
        checkOnlyNext: true,
      );
      removedIndices.addAll(nextTagIndices);
    }
    final sorted = removedIndices.toSet().sorted((a, b) => a.compareTo(b));
    return sorted;
  }

  List<int> _removeElement(
    Range range,
    XmlRemoveElementEdit remove, {
    bool checkOnlyNext = false,
  }) {
    final removedIndices = <int>[];
    for (var i = range.start; i <= range.end; i++) {
      final event = _events[i];
      if (event is XmlStartElementEvent) {
        final nextEvent = _events.elementAtOrNull(i + 1);
        final content =
            (nextEvent is XmlTextEvent && nextEvent.value.trim().isNotEmpty)
            ? nextEvent
            : null;
        if (remove.matches(event, content)) {
          removedIndices.add(i);
          if (content != null) {
            removedIndices.add(i + 1);
          }

          // remove comments and whitespace before
          for (var j = i - 1; j >= range.start; j--) {
            final prevEvent = _events[j];
            if (prevEvent is XmlCommentEvent) {
              if (remove.commentRemover != null &&
                  remove.commentRemover!(prevEvent.value)) {
                removedIndices.add(j);
              }
            } else if (prevEvent is XmlTextEvent) {
              final isBeforeRemoved =
                  removedIndices.contains(j + 1) &&
                  _events.elementAtOrNull(j + 1) is! XmlTextEvent;
              if (isBeforeRemoved) {
                removedIndices.add(j);
              }
            } else {
              break;
            }
          }
          // remove element end if not self-closing
          if (!event.isSelfClosing) {
            for (var j = i + 1; j <= range.end; j++) {
              final nextEvent = _events[j];
              if (nextEvent is XmlEndElementEvent &&
                  nextEvent.name == remove.tag) {
                removedIndices.add(j);
                break;
              }
            }
          }
          break;
        } else if (checkOnlyNext) {
          break;
        }
      }
    }
    return removedIndices;
  }

  /// Determines the insertion anchor point for the given [insert] operation.
  /// Returns a tuple of (anchor index, indent string).
  (int, String) getInsertionAnchor(XmlInsertElementEdit insert) {
    final range = _getElementScope(insert.path);
    if (range == null) {
      return (-1, _defaultIndent);
    }
    int anchor = -1;
    if (insert.insertAfter != null) {
      for (var i = range.start; i <= range.end; i++) {
        final event = _events[i];
        if (event is XmlStartElementEvent) {
          final content = (i + 1 <= range.end && _events[i + 1] is XmlTextEvent)
              ? _events[i + 1] as XmlTextEvent
              : null;
          if (insert.insertAfter!(event.name, content?.value)) {
            anchor = i + 1;
          }
        }
        // Stop at the end of the range
        if (i == range.end) break;
      }
    }

    if (anchor != -1) {
      return (anchor, _getPreviousElementIndent(max(anchor - 1, 0)));
    }

    // Default to inserting at the start of the range
    return (range.start, _getNextElementIndent(range.start));
  }

  String _getNextElementIndent(int startIndex) {
    if (startIndex >= _events.length) return _defaultIndent;
    for (var i = startIndex; i < _events.length; i++) {
      final event = _events[i];
      if (event is XmlTextEvent && event.value.trim().isEmpty) {
        return event.value.split('\n').lastOrNull ?? _defaultIndent;
      }
    }
    return _defaultIndent;
  }

  String _getPreviousElementIndent(int startIndex) {
    if (startIndex <= 0) return _defaultIndent;
    for (var i = startIndex; i >= 0; i--) {
      final event = _events[i];
      if (event is XmlTextEvent && event.value.trim().isEmpty) {
        return event.value.split('\n').lastOrNull ?? _defaultIndent;
      }
    }
    return _defaultIndent;
  }

  /// Saves the current XML content to the specified [file].
  /// Returns `true` if successful, `false` otherwise.
  bool save(File file) {
    try {
      file.writeAsStringSync(toString());
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// A function type for determining the anchor point for element insertion.
typedef ElementAnchorPredicate = bool Function(String key, String? content);

/// An abstract class representing an XML edit operation.
abstract class XmlEdit {
  /// The XML path where the edit should be applied.
  final String path;

  /// Default constructor.
  XmlEdit({required this.path});
}

/// A class representing information about an XML element to be inserted.
class XmlElementInfo {
  /// The name of the XML element.
  final String name;

  /// The content of the XML element (if any).
  final String? content;

  /// Comments associated with the XML element (if any).
  final List<String>? comments;

  /// Whether the element is self-closing.
  final bool isSelfClosing;

  /// Attributes of the XML element.
  final Map<String, String> attributes;

  /// Default constructor.
  XmlElementInfo({
    required this.name,
    this.attributes = const {},
    this.content,
    this.comments,
    this.isSelfClosing = false,
  });

  /// Checks if the given event matches this element info.
  bool matches(XmlStartElementEvent event) {
    if (event.name.trim() != name) return false;
    final eventAttrs = Map.fromEntries(
      event.attributes.map((e) => MapEntry(e.name, e.value)),
    );
    for (final entry in attributes.entries) {
      if (eventAttrs[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Builds the XML events for this element.
  List<XmlEvent> buildEvents(String indent) {
    return [
      for (final comment in [...?comments]) ...[
        XmlTextEvent('\n$indent'),
        XmlCommentEvent(comment),
      ],
      XmlTextEvent('\n$indent'),
      XmlStartElementEvent(
        name,
        [
          for (final entry in attributes.entries)
            XmlEventAttribute(
              entry.key,
              entry.value,
              XmlAttributeType.DOUBLE_QUOTE,
            ),
        ],
        isSelfClosing,
      ),
      if (content != null) XmlTextEvent(content!),
      if (!isSelfClosing) XmlEndElementEvent(name),
    ];
  }
}

/// An edit operation to insert new XML elements.
class XmlInsertElementEdit extends XmlEdit {
  /// The list of elements to insert.
  final List<XmlElementInfo> tags;

  /// An optional predicate to determine the anchor point for insertion.
  final ElementAnchorPredicate? insertAfter;

  /// Default constructor.
  XmlInsertElementEdit({
    required super.path,
    required this.tags,
    this.insertAfter,
  });

  /// Builds the XML events for the elements to insert.
  List<XmlEvent> buildEvents(String indent) {
    return [for (final tag in tags) ...tag.buildEvents(indent)];
  }
}

/// An edit operation to remove XML elements.
class XmlRemoveElementEdit extends XmlEdit {
  /// The tag name of the element to remove.
  final String tag;

  /// Optional content to match for removal.
  final String? content;

  /// Optional attributes to match for removal.
  final Map<String, String>? attributes;

  /// An optional function to determine whether to remove associated comments.
  final RemoveComment? commentRemover;

  /// An optional tag name of the next element to remove after the main one.
  final String? removeNextTag;

  /// Default constructor.
  XmlRemoveElementEdit({
    required super.path,
    required this.tag,
    this.content,
    this.attributes,
    this.removeNextTag,
    this.commentRemover,
  });

  /// Checks if the given event matches the removal criteria.
  bool matches(XmlStartElementEvent event, XmlTextEvent? contentEvent) {
    if (event.name != tag) return false;
    if (content != null &&
        (contentEvent == null || contentEvent.value.trim() != content)) {
      return false;
    }
    if (attributes != null) {
      final eventAttrs = Map.fromEntries(
        event.attributes.map((e) => MapEntry(e.name, e.value)),
      );
      for (final entry in attributes!.entries) {
        if (eventAttrs[entry.key] != entry.value) {
          return false;
        }
      }
    }
    return true;
  }
}

/// A simple range class representing a start and end index.
class Range {
  /// The start index (inclusive).
  final int start;

  /// The end index (inclusive).
  final int end;

  /// Default constructor.
  Range(this.start, this.end);

  @override
  String toString() {
    return 'Range($start, $end)';
  }
}
