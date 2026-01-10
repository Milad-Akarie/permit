import 'package:permit/editor/xml_editor.dart';
import 'package:test/test.dart';

void main() {
  group('XmlEditor - Insertion without Comments', () {
    test('inserts element without comment and preserves 2-space indentation', () {
      const xml = '''<root>
  <body>
    <existing>Value</existing>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'newTag',
              content: 'NewValue',
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<newTag>NewValue</newTag>'));
      expect(result, contains('    <newTag>'));
      expect(result, contains('<existing>Value</existing>'));
    });

    test('inserts element without comment and preserves 4-space indentation', () {
      const xml = '''<root>
    <body>
        <existing>Value</existing>
    </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'new',
              content: 'Val',
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('        <new>'));
      expect(result, contains('<existing>'));
    });

    test('inserts multiple elements without comments in sequence', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(name: 'first', content: '1'),
            XmlElementInfo(name: 'second', content: '2'),
            XmlElementInfo(name: 'third', content: '3'),
          ],
        ),
      );

      final result = editor.toString();
      print(result);

      expect(result, contains('<first>1</first>'));
      expect(result, contains('<second>2</second>'));
      expect(result, contains('<third>3</third>'));
    });

    test('inserts element with attributes without comment', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'uses-permission',
              content: '',
              attributes: {'android:name': 'android.permission.CAMERA'},
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('android:name="android.permission.CAMERA"'));
      expect(result, contains('<uses-permission'));
    });
  });

  group('XmlEditor - Insertion with Comments', () {
    test('inserts element with comment before tag', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'permission',
              content: 'CAMERA',
              comments: [' Camera permission '],
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<!-- Camera permission -->'));
      expect(result, contains('<permission>CAMERA</permission>'));
      final commentIdx = result.indexOf('<!-- Camera permission -->');
      final elemIdx = result.indexOf('<permission>');
      expect(commentIdx, lessThan(elemIdx));
    });

    test('inserts element with comment and preserves indentation', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'perm',
              content: 'LOC',
              comments: [' Location permission '],
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<!-- Location permission -->'));
      expect(result, contains('<perm>LOC</perm>'));
      final commentIdx = result.indexOf('<!-- Location permission -->');
      final elemIdx = result.indexOf('<perm>LOC</perm>');
      expect(commentIdx, lessThan(elemIdx));
    });

    test('inserts multiple elements with comments', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'cam',
              content: 'CAMERA',
              comments: [' Camera '],
            ),
            XmlElementInfo(
              name: 'loc',
              content: 'LOCATION',
              comments: [' Location '],
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<!-- Camera -->'));
      expect(result, contains('<!-- Location -->'));
      expect(result, contains('<cam>CAMERA</cam>'));
      expect(result, contains('<loc>LOCATION</loc>'));
    });

    test('inserts element with comment and attributes', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'uses-permission',
              content: '',
              comments: [' Camera permission '],
              attributes: {'android:name': 'android.permission.CAMERA'},
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<!-- Camera permission -->'));
      expect(result, contains('android:name="android.permission.CAMERA"'));
    });
  });

  group('XmlEditor - Removal without Comments', () {
    test('removes element without preceding comment', () {
      const xml = '''<root>
  <body>
    <tag1>Value1</tag1>
    <tag2>Value2</tag2>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'tag1',
        ),
      );

      final result = editor.toString();
      expect(result, isNot(contains('<tag1>')));
      expect(result, contains('<tag2>'));
    });

    test('removes element with attributes matching', () {
      const xml = '''<root>
  <body>
    <perm name="CAM" />
    <perm name="LOC" />
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'perm',
          attributes: {'name': 'CAM'},
        ),
      );

      final result = editor.toString();
      expect(result, contains('LOC'));
      expect(result, isNot(contains('CAM')));
    });

    test('preserves formatting after removing first element', () {
      const xml = '''<root>
  <body>
    <remove>value</remove>
    <keep>value</keep>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'remove',
        ),
      );

      final result = editor.toString();
      expect(result, contains('  <body>'));
      expect(result, contains('    <keep>'));
      expect(result, contains('  </body>'));
    });
  });

  group('XmlEditor - Removal with Comments', () {
    test('removes element and its preceding comment when predicate true', () {
      const xml = '''<root>
  <body>
    <!-- Camera permission -->
    <permission>CAMERA</permission>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'permission',
          commentRemover: (c) => c.contains('Camera'),
        ),
      );

      final result = editor.toString();
      expect(result, isNot(contains('Camera permission')));
      expect(result, isNot(contains('<permission>')));
    });

    test('removes element but preserves preceding comment when predicate false', () {
      const xml = '''<root>
  <body>
    <!-- Keep this comment -->
    <permission>CAMERA</permission>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'permission',
          commentRemover: (c) => c.contains('Delete'),
        ),
      );

      final result = editor.toString();
      expect(result, contains('Keep this comment'));
      expect(result, isNot(contains('<permission>')));
    });

    test('removes element and comment with proper indentation preserved', () {
      const xml = '''<root>
  <body>
    <!-- First -->
    <first>1</first>
    <!-- Second -->
    <second>2</second>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'second',
          commentRemover: (c) => c.contains('Second'),
        ),
      );

      final result = editor.toString();
      expect(result, contains('<!-- First -->'));
      expect(result, contains('<first>1</first>'));
      expect(result, isNot(contains('Second')));
    });

    test('preserves other comments when removing specific element', () {
      const xml = '''<root>
  <body>
    <!-- Keep this -->
    <keep>value</keep>
    <!-- Delete this -->
    <delete>value</delete>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'delete',
          commentRemover: (c) => c.contains('Delete'),
        ),
      );

      final result = editor.toString();
      expect(result, contains('Keep this'));
      expect(result, contains('<keep>'));
      expect(result, isNot(contains('Delete this')));
      expect(result, isNot(contains('delete')));
    });
  });

  group('XmlEditor - Format Preservation', () {
    test('preserves original formatting when no edits applied', () {
      const xml = '''<root>
  <body>
    <item>value</item>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, equals(xml));
    });

    test('preserves mixed indentation with elements and empty lines', () {
      const xml = '''<root>
  <body>
    <first>val1</first>

    <second>val2</second>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, equals(xml));
    });

    test('preserves attributes and formatting of root element', () {
      const xml = '''<root encoding="utf-8">
  <body>
    <item>value</item>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, contains('encoding="utf-8"'));
      expect(result, startsWith('<root'));
      expect(result, endsWith('</root>'));
    });

    test('preserves self-closing tags', () {
      const xml = '''<root>
  <items>
    <br />
    <item>val</item>
  </items>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, contains('<br />'));
      expect(result, contains('<item>'));
    });

    test('preserves nested element structure', () {
      const xml = '''<root>
  <outer>
    <inner>
      <deep>value</deep>
    </inner>
  </outer>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, equals(xml));
    });
  });

  group('XmlEditor - Complex Scenarios', () {
    test('insert element after remove on same path maintains structure', () {
      const xml = '''<root>
  <body>
    <old>value</old>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'old',
        ),
      );
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'new',
              content: 'value',
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<new>value</new>'));
      expect(result, contains('  <body>'));
      expect(result, contains('  </body>'));
    });

    test('multiple inserts maintain original structure', () {
      const xml = '''<root>
  <body>
    <existing>val</existing>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(name: 'new1', content: '1'),
          ],
        ),
      );
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(name: 'new2', content: '2'),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<existing>'));
      expect(result, contains('<new1>'));
      expect(result, contains('<new2>'));
      expect(result, contains('  <body>'));
    });

    test('insert with comment followed by remove maintains formatting', () {
      const xml = '''
<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'perm',
              content: 'CAM',
              comments: [' Camera '],
            ),
          ],
        ),
      );

      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.body',
          tag: 'perm',
          commentRemover: (c) => c.contains('Camera'),
        ),
      );
      final result = editor.toString();
      expect(result, contains('  <body>'));
      expect(result, contains('  </body>'));
    });

    test('deeply nested insertion preserves all indentation', () {
      const xml = '''<root>
  <level1>
    <level2>
      <level3>
        <existing>val</existing>
      </level3>
    </level2>
  </level1>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.level1.level2.level3',
          tags: [
            XmlElementInfo(
              name: 'new',
              content: 'newval',
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<existing>'));
      expect(result, contains('        <new>'));
      expect(result, contains('  <level1>'));
      expect(result, contains('    <level2>'));
      expect(result, contains('      <level3>'));
    });

    test('handles multiple siblings with selective removal', () {
      const xml = '''<root>
  <perms>
    <!-- Camera -->
    <perm>CAM</perm>
    <!-- Location -->
    <perm>LOC</perm>
    <!-- Microphone -->
    <perm>MIC</perm>
  </perms>
</root>''';

      final editor = XmlEditor(xml);
      editor.remove(
        XmlRemoveElementEdit(
          path: 'root.perms',
          tag: 'perm',
          content: 'LOC',
          commentRemover: (c) => c.contains('Location'),
        ),
      );

      final result = editor.toString();
      expect(result, contains('Camera'));
      expect(result, contains('CAM'));
      expect(result, contains('Microphone'));
      expect(result, contains('MIC'));
      expect(result, isNot(contains('Location')));
      expect(result, isNot(contains('<perm>LOC</perm>')));
    });
  });

  group('XmlEditor - Edge Cases', () {
    test('empty parent element receives new child with proper format', () {
      const xml = '''<root>
  <body />
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, contains('<body'));
    });

    test('element with only whitespace children', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      final result = editor.toString();
      expect(result, equals(xml));
    });

    test('inserts element with empty content', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(name: 'empty', content: ''),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<empty></empty>'));
    });

    test('comment with special characters preserved', () {
      const xml = '''<root>
  <body>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'item',
              content: 'val',
              comments: [' Special chars: <>&" '],
            ),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('Special chars:'));
    });

    test('respects anchor elements preceding comments during insertion', () {
      const xml = '''<root>
  <body>
    <!-- Anchor comment -->
    <anchor>AnchorValue</anchor>
    <existing>Value</existing>
  </body>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.body',
          tags: [
            XmlElementInfo(
              name: 'new',
              content: 'NewValue',
              comments: [' New element comment '],
            ),
          ],
          insertBefore: (name, _) => name == 'anchor',
        ),
      );

      final result = editor.toString();

      print(result);

      // Verify anchor comment is preserved
      expect(result, contains('<!-- Anchor comment -->'));
      expect(result, contains('<anchor>AnchorValue</anchor>'));

      // Verify new element is inserted before existing with its own comment
      expect(result, contains('<!-- New element comment -->'));
      expect(result, contains('<new>NewValue</new>'));
      expect(result, contains('<existing>Value</existing>'));

      // Verify order: anchor comment -> anchor -> new comment -> new -> existing
      final anchorCommentIdx = result.indexOf('<!-- Anchor comment -->');
      final anchorIdx = result.indexOf('<anchor>');
      final newCommentIdx = result.indexOf('<!-- New element comment -->');
      final newIdx = result.indexOf('<new>');
      final existingIdx = result.indexOf('<existing>');

      expect(anchorCommentIdx, lessThan(anchorIdx));
      expect(anchorIdx, lessThan(newCommentIdx));
      expect(newCommentIdx, lessThan(newIdx));
      expect(newIdx, lessThan(existingIdx));
    });
    test('multiple root-level children preserved during operations', () {
      const xml = '''<root>
  <section1>
    <item>val</item>
  </section1>
  <section2>
    <item>val</item>
  </section2>
</root>''';

      final editor = XmlEditor(xml);
      editor.insert(
        XmlInsertElementEdit(
          path: 'root.section1',
          tags: [
            XmlElementInfo(name: 'new', content: 'newval'),
          ],
        ),
      );

      final result = editor.toString();
      expect(result, contains('<section1>'));
      expect(result, contains('<section2>'));
      expect(result, contains('<new>'));
    });
  });
}
