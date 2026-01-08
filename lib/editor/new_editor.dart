import 'package:xml/xml_events.dart';

typedef CommentRemoverPredicate = bool Function(String comment);

class SourceEdit {
  final int offset;
  final int length;
  final String replacement;
  SourceEdit(this.offset, this.length, this.replacement);
}

class XmlEditor {
  String _source;
  final List<SourceEdit> _edits = [];
  String _indent = '  ';

  XmlEditor(this._source) {
    _detectIndentation();
  }

  String get source => _source;

  void _detectIndentation() {
    final match = RegExp(r'\n(\s+)<').firstMatch(_source);
    if (match != null) {
      _indent = match.group(1)!;
    }
  }

  List<SourceEdit> get edits => List.unmodifiable(_edits);

  bool get hasPendingEdits => _edits.isNotEmpty;

  /// Finds the precise character range of an element using a path.
  /// Refreshes offsets against the current source.
  _ElementPosition? _findElementPosition(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final normalizedParts = (parts.isNotEmpty && parts.first == 'root') ? parts.sublist(1) : parts;

    final events = parseEvents(_source, withLocation: true).toList();
    final List<String> currentPath = [];
    final Map<String, int> tagCountsAtDepth = {};
    int lastStop = 0;

    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      // Find where the tag actually starts in the raw source
      final int startOffset = _source.indexOf('<', lastStop);

      if (event is XmlStartElementEvent) {
        final String tagName = event.name;
        final depthKey = '${currentPath.join('/')}/$tagName';
        final int index = tagCountsAtDepth[depthKey] ?? 0;
        tagCountsAtDepth[depthKey] = index + 1;

        final String currentSegment = index == 0 ? tagName : '$tagName[$index]';
        currentPath.add(currentSegment);

        if (_pathsMatch(currentPath, normalizedParts)) {
          return _resolveFullElementRange(events, i, startOffset);
        }
        if (event.isSelfClosing) currentPath.removeLast();
      } else if (event is XmlEndElementEvent) {
        if (currentPath.isNotEmpty) currentPath.removeLast();
      }
      lastStop = event.stop ?? lastStop;
    }
    return null;
  }

  bool _pathsMatch(List<String> current, List<String> target) {
    if (current.length != target.length) return false;
    for (int i = 0; i < current.length; i++) {
      if (current[i] != target[i] && '${target[i]}[0]' != current[i]) return false;
    }
    return true;
  }

  _ElementPosition _resolveFullElementRange(List<XmlEvent> events, int startIndex, int startOffset) {
    final startEvent = events[startIndex] as XmlStartElementEvent;
    int endOffset = startEvent.stop ?? startOffset;

    if (!startEvent.isSelfClosing) {
      int depth = 1;
      for (int i = startIndex + 1; i < events.length; i++) {
        final e = events[i];
        if (e is XmlStartElementEvent && !e.isSelfClosing && e.name == startEvent.name) depth++;
        if (e is XmlEndElementEvent && e.name == startEvent.name) {
          depth--;
          if (depth == 0) {
            endOffset = e.stop ?? endOffset;
            break;
          }
        }
      }
    }
    return _ElementPosition(
      offset: startOffset,
      length: endOffset - startOffset,
      tagName: startEvent.name,
      indentLevel: _calculateIndentLevel(startOffset),
    );
  }

  // --- Public Editing Methods ---

  void addTag({required String path, required String tag, List<String>? comments}) {
    final pos = _findElementPosition(path);
    if (pos == null) return;

    final insertText = _buildTagString(pos.indentLevel + 1, tag, comments);
    final closingTagStart = _source.lastIndexOf('</', pos.offset + pos.length);

    if (closingTagStart > pos.offset) {
      _edits.add(SourceEdit(closingTagStart, 0, insertText));
    }
    applyEdits(); // Update "DOM" state immediately for subsequent queries
  }

  void addMultipleTags({required String path, required List<String> tags, List<String>? comments}) {
    final pos = _findElementPosition(path);
    if (pos == null) return;

    final buffer = StringBuffer();
    for (var tag in tags) {
      buffer.write(_buildTagString(pos.indentLevel + 1, tag, tags.indexOf(tag) == 0 ? comments : null));
    }

    final closingTagStart = _source.lastIndexOf('</', pos.offset + pos.length);
    if (closingTagStart > pos.offset) {
      _edits.add(SourceEdit(closingTagStart, 0, buffer.toString()));
    }
    applyEdits();
  }

  void appendToArray({required String arrayPath, required String elementTag, List<String>? comments}) {
    var arrayPos = _findElementPosition(arrayPath);

    if (arrayPos == null) {
      // Create array logic: find parent and insert new container
      final parentPath = arrayPath.split('/').where((s) => s.isNotEmpty).toList()..removeLast();
      final arrayName = arrayPath.split('/').last.replaceAll(RegExp(r'\[\d+\]'), '');
      final parentPos = _findElementPosition(parentPath.join('/'));

      if (parentPos != null) {
        final indent = _indent * (parentPos.indentLevel + 1);
        final newArray =
            '\n$indent<$arrayName>\n${_buildTagString(parentPos.indentLevel + 2, elementTag, comments)}$indent</$arrayName>';
        addTag(path: parentPath.join('/'), tag: newArray);
      }
    } else {
      // Append to existing
      addTag(path: arrayPath, tag: elementTag, comments: comments);
    }
  }

  void removeFromArray({required String elementPath, CommentRemoverPredicate? shouldRemoveComment}) {
    final pos = _findElementPosition(elementPath);
    if (pos == null) return;

    int start = _findLineStart(pos.offset);
    int end = _findLineEnd(pos.offset + pos.length);

    // Optional comment removal
    if (shouldRemoveComment != null) {
      final comments = _findCommentsBefore(pos.offset);
      for (var comment in comments.reversed) {
        if (shouldRemoveComment(comment.content)) {
          start = _findLineStart(comment.offset);
        }
      }
    }

    _edits.add(SourceEdit(start, end - start, ''));
    applyEdits();
  }

  // --- Core Logic ---

  String _buildTagString(int level, String tag, List<String>? comments) {
    final indent = _indent * level;
    final buffer = StringBuffer('\n');
    if (comments != null) {
      for (var c in comments) {
        buffer.writeln(indent);
      }
    }
    buffer.write('$indent$tag');
    return buffer.toString();
  }

  String applyEdits() {
    if (_edits.isEmpty) return _source;
    final sorted = List<SourceEdit>.from(_edits)..sort((a, b) => b.offset.compareTo(a.offset));
    for (var edit in sorted) {
      _source = _source.replaceRange(edit.offset, edit.offset + edit.length, edit.replacement);
    }
    _edits.clear();
    return _source;
  }

  // --- Helper methods for formatting ---

  int _calculateIndentLevel(int offset) {
    int lineStart = _findLineStart(offset);
    final whitespace = _source.substring(lineStart, offset);
    return (RegExp(r'^\s*').firstMatch(whitespace)?.group(0)?.length ?? 0) ~/ _indent.length;
  }

  int _findLineStart(int offset) {
    int pos = offset;
    while (pos > 0 && _source[pos - 1] != '\n') {
      pos--;
    }
    return pos;
  }

  int _findLineEnd(int offset) {
    int pos = offset;
    while (pos < _source.length && _source[pos] != '\n') {
      pos++;
    }
    return pos < _source.length ? pos + 1 : pos;
  }

  List<_CommentPosition> _findCommentsBefore(int offset) {
    final results = <_CommentPosition>[];
    final lookback = _source.substring(0, offset);
    final matches = RegExp(r'').allMatches(lookback);
    for (var m in matches) {
      results.add(_CommentPosition(m.start, m.group(1)!.trim()));
    }
    return results;
  }
}

class _ElementPosition {
  final int offset;
  final int length;
  final String tagName;
  final int indentLevel;
  _ElementPosition({required this.offset, required this.length, required this.tagName, required this.indentLevel});
}

class _CommentPosition {
  final int offset;
  final String content;
  _CommentPosition(this.offset, this.content);
}
