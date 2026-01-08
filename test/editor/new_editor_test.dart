import 'package:xml/xml_events.dart';

void main() {
  final xml = '''
<root><!--coom-->
   <!-- Comment for first tag -->
   
   
   <body>
     <tag 
     atrr="hello"
     attr2="world"
    >Value1</tag>
    <!-- Comment for second tag -->
    <tag>Value2</tag>
  </body>
</root>''';

  final events = parseEvents(xml, withLocation: true).toList();
  final buffer = StringBuffer();

  final edits = <XmlEdit>[
    XmlAddElementEdit(
      path: 'root.body',
      tags: '<customTag>SomeValue</customTag>',
      comment: 'Adding custom tag',
      insertAfter: (event) => event.name == 'tag',
    ),
  ];

  void append(XmlEvent event) {
    if (event.start != null && event.stop != null) {
      buffer.write(xml.substring(event.start!, event.stop!));
    }
  }

  final currentPath = <String>[];
  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    append(event);
    if (event is XmlStartElementEvent) {
      currentPath.add(event.name);
      for (final edit in edits) {
        if (currentPath.join('.') == edit.path) {
          if (edit is XmlAddElementEdit) {
            // insert right before target element or before first child
          }
        }
      }
    }
  }
  print(buffer.toString());
}

String _getNextIndent(List<XmlEvent> events, int startIndex) {
  if (startIndex + 1 >= events.length) return '';
  for (final event in events) {
    if (event is XmlTextEvent && event.value.trim().isEmpty) {
      return event.value;
    }
  }
  return '';
}

typedef ElementStartPredicate = bool Function(XmlStartElementEvent event);

abstract class XmlEdit {
  final String path;

  XmlEdit({required this.path});
}

class XmlAddElementEdit extends XmlEdit {
  final String tags;
  final String? comment;
  final ElementStartPredicate? insertAfter;

  XmlAddElementEdit({
    required super.path,
    required this.tags,
    this.insertAfter,
    this.comment,
  });
}

class XmlRemoveElementEdit extends XmlEdit {
  bool Function(String)? commentRemover;

  XmlRemoveElementEdit({required super.path, this.commentRemover});
}

extension XmlTextEventX on XmlTextEvent {
  bool get isNewLine => value.codeUnits.every((unit) => unit == 10 || unit == 13);
  bool get isIndent => value.codeUnits.every((unit) => unit == 32 || unit == 9);
}
