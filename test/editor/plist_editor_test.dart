import 'package:permit/editor/xml_editor.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('PListEditor - Critical Edge Cases', () {
    test('handles malformed plist gracefully', () {
      const malformedPlist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <key>NSCameraUsageDescription</key>
  </dict>
  </plist>''';

      final editor = PListEditor(malformedPlist);
      final descriptions = editor.getUsageDescriptions();
      // Should handle missing string value
      expect(descriptions, hasLength(1));
      expect(descriptions[0].description, equals(''));
    });

    test('handles comments without following NS description', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <!-- Orphaned comment -->
   <key>CFBundleName</key>
   <string>MyApp</string>
   <key>NSCameraUsageDescription</key>
   <string>Camera</string>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      final descriptions = editor.getUsageDescriptions();
      expect(descriptions, hasLength(1));
      expect(descriptions[0].comments, isEmpty);
    });

    test('preserves comments that precede non-NS keys', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <!-- Bundle name comment -->
   <key>CFBundleName</key>
   <string>MyApp</string>
   <!-- Camera permission -->
   <key>NSCameraUsageDescription</key>
   <string>Camera</string>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      editor.addUsageDescription(
        key: 'NSPhotoLibraryUsageDescription',
        description: 'Photos',
      );

      final result = editor.toString();
      expect(result, contains('Bundle name comment'));
      expect(result, contains('CFBundleName'));
    });

    test('throws when plist has invalid XML syntax', () {
      const invalidPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
 <key>NSCameraUsageDescription</key>
 <string>Camera</string>
 <!-- Unclosed comment
</dict>
</plist>''';

      expect(
        () => PListEditor(invalidPlist),
        throwsA(isA<XmlParserException>()),
      );
    });

    test('handles Unicode characters in descriptions', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <key>NSCameraUsageDescription</key>
   <string>Camera — 📷</string>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions[0].description, contains('📷'));
    });

    test('handles very long descriptions', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Location</string>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      final longDescription = 'A' * 1000;

      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: longDescription,
      );

      final result = editor.toString();
      expect(result, contains(longDescription));
    });

    test('adding description when dict is empty', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();
      expect(result, contains('NSCameraUsageDescription'));
      expect(result, contains('Camera'));
    });

    test('multiple consecutive comments before NS key', () {
      const plist = '''<?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0">
  <dict>
   <!-- Line 1 -->
   <!-- Line 2 -->
   <!-- Line 3 -->
   <key>NSCameraUsageDescription</key>
   <string>Camera</string>
  </dict>
  </plist>''';

      final editor = PListEditor(plist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions[0].comments, hasLength(3));
    });
  });

  group('PListEditor - Adding Usage Descriptions', () {
    test('adds camera usage description to real plist file', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>Runner</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs access to your location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'This app needs camera access to take photos',
        keyComments: [' Camera permission '],
      );

      final result = editor.toString();
      expect(result, contains('NSCameraUsageDescription'));
      expect(result, contains('This app needs camera access to take photos'));
      expect(result, contains('<!-- Camera permission -->'));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
    });

    test('adds multiple NS usage descriptions in sequence', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access needed</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);

      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
      );

      editor.addUsageDescription(
        key: 'NSPhotoLibraryUsageDescription',
        description: 'Photo library access',
      );

      final result = editor.toString();

      expect(result, contains('NSCameraUsageDescription'));
      expect(result, contains('NSPhotoLibraryUsageDescription'));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));

      final cameraIdx = result.indexOf('NSCameraUsageDescription');
      final photoIdx = result.indexOf('NSPhotoLibraryUsageDescription');

      expect(cameraIdx, greaterThan(photoIdx));
    });

    test('adds usage description with both key and value comments', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'Microphone access for recording',
        keyComments: [' Microphone permission '],
        valueComments: [' Required for audio recording '],
      );

      final result = editor.toString();
      expect(result, contains('<!-- Microphone permission -->'));
      expect(result, contains('NSMicrophoneUsageDescription'));
      expect(result, contains('<!-- Required for audio recording -->'));
      expect(result, contains('Microphone access for recording'));
    });

    test('preserves plist file structure after adding description', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>MyApp</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access needed</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
      );

      final result = editor.toString();
      // Verify XML structure is intact
      expect(result, startsWith('<?xml version'));
      expect(result, contains('<!DOCTYPE plist'));
      expect(result, contains('<plist version="1.0">'));
      expect(result, contains('</dict>'));
      expect(result, contains('</plist>'));
      expect(result, contains('<key>CFBundleDisplayName</key>'));
    });

    test('replaces existing usage description with same key', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSCameraUsageDescription</key>
	<string>Old description</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New camera description',
      );

      final result = editor.toString();
      expect(result, contains('New camera description'));
      expect(result, isNot(contains('Old description')));
      expect(result, contains('NSCameraUsageDescription'));
      // Should only have one instance of NSCameraUsageDescription
      expect(
        RegExp('NSCameraUsageDescription').allMatches(result).length,
        equals(1),
      );
    });

    test('inserts after last NS usage description', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Photos</string>
	<key>CFBundleName</key>
	<string>App</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();
      final cameraIdx = result.indexOf('NSCameraUsageDescription');
      final bundleIdx = result.indexOf('CFBundleName');
      // Camera should be before CFBundleName (after NS descriptions)
      expect(cameraIdx, lessThan(bundleIdx));
    });
  });

  group('PListEditor - Removing Usage Descriptions', () {
    test('removes camera usage description from real plist', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSCameraUsageDescription</key>
	<string>Camera access needed</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access needed</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(name: 'NSCameraUsageDescription');

      final result = editor.toString();
      expect(result, isNot(contains('NSCameraUsageDescription')));
      expect(result, isNot(contains('Camera access needed')));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
      expect(result, contains('Location access needed'));
    });

    test('removes usage description and its preceding comment', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<!-- Camera permission for photos -->
	<key>NSCameraUsageDescription</key>
	<string>Camera access</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(
        name: 'NSCameraUsageDescription',
        removeComments: (comment) => comment.contains('Camera'),
      );

      final result = editor.toString();
      expect(result, isNot(contains('NSCameraUsageDescription')));
      expect(result, isNot(contains('Camera permission for photos')));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
    });

    test('handles orphaned key without string value', () {
      const plistWithOrphanedKey = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
 <key>NSCameraUsageDescription</key>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>Location needed</string>
</dict>
</plist>''';

      final editor = PListEditor(plistWithOrphanedKey);

      // Should handle orphaned key gracefully
      editor.removeUsageDescription(name: 'NSCameraUsageDescription');

      final result = editor.toString();
      expect(result, isNot(contains('NSCameraUsageDescription')));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
      expect(result, contains('Location needed'));
    });

    test('preserves other comments when removing specific description', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<!-- Location permission marker -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access</string>
	<!-- Camera permission marker -->
	<key>NSCameraUsageDescription</key>
	<string>Camera access</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(
        name: 'NSCameraUsageDescription',
        removeComments: (comment) => comment.contains('Camera'),
      );

      final result = editor.toString();
      expect(result, contains('Location permission marker'));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
      expect(result, isNot(contains('Camera permission marker')));
      expect(result, isNot(contains('NSCameraUsageDescription')));
    });

    test('preserves plist structure after removing description', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>NSCameraUsageDescription</key>
	<string>Camera access</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(name: 'NSCameraUsageDescription');

      final result = editor.toString();
      expect(result, startsWith('<?xml version'));
      expect(result, contains('<!DOCTYPE plist'));
      expect(result, contains('<plist version="1.0">'));
      expect(result, contains('</dict>'));
      expect(result, contains('</plist>'));
      expect(result, contains('CFBundleName'));
      expect(result, contains('CFBundleVersion'));
    });

    test('handles removing non-existent description gracefully', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(
        name: 'NSCameraUsageDescription',
      );

      // Should not crash and location description should remain
      expect(editor.toString(), contains('NSLocationWhenInUseUsageDescription'));
    });

    test('removes multiple descriptions one by one', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSCameraUsageDescription</key>
	<string>Camera</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Photos</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.removeUsageDescription(name: 'NSCameraUsageDescription');
      editor.removeUsageDescription(name: 'NSPhotoLibraryUsageDescription');

      final result = editor.toString();
      expect(result, isNot(contains('NSCameraUsageDescription')));
      expect(result, isNot(contains('NSPhotoLibraryUsageDescription')));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
    });
  });

  group('PListEditor - Querying Usage Descriptions', () {
    test('retrieves all usage descriptions from plist', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs your location</string>
	<key>NSCameraUsageDescription</key>
	<string>This app needs camera access</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>This app needs photo library access</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, hasLength(3));
      expect(descriptions[0].key, equals('NSLocationWhenInUseUsageDescription'));
      expect(descriptions[0].description, equals('This app needs your location'));
      expect(descriptions[1].key, equals('NSCameraUsageDescription'));
      expect(descriptions[1].description, equals('This app needs camera access'));
      expect(descriptions[2].key, equals('NSPhotoLibraryUsageDescription'));
      expect(descriptions[2].description, equals('This app needs photo library access'));
    });

    test('retrieves usage descriptions with associated comments', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<!-- Location permission for maps -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location needed</string>
	<!-- Camera for video calls -->
	<key>NSCameraUsageDescription</key>
	<string>Camera needed</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, hasLength(2));
      expect(descriptions[0].comments, isNotEmpty);
      expect(descriptions[0].comments[0], contains('Location permission'));
      expect(descriptions[1].comments, isNotEmpty);
      expect(descriptions[1].comments[0], contains('Camera for video'));
    });

    test('handles plist with no usage descriptions', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, isEmpty);
    });

    test('filters only NS usage descriptions', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>NSCameraUsageDescription</key>
	<string>Camera</string>
	<key>SomeOtherKey</key>
	<string>Value</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
	<key>NotAnUsageDescription</key>
	<string>Other</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, hasLength(2));
      expect(descriptions[0].key, equals('NSCameraUsageDescription'));
      expect(descriptions[1].key, equals('NSLocationWhenInUseUsageDescription'));
    });

    test('preserves description order from original plist', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Photos</string>
	<key>NSCameraUsageDescription</key>
	<string>Camera</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>Microphone</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions[0].key, equals('NSPhotoLibraryUsageDescription'));
      expect(descriptions[1].key, equals('NSCameraUsageDescription'));
      expect(descriptions[2].key, equals('NSLocationWhenInUseUsageDescription'));
      expect(descriptions[3].key, equals('NSMicrophoneUsageDescription'));
    });

    test('retrieves descriptions with multiple preceding comments', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<!-- Marker: permit-auto -->
	<!-- Camera permission for photo capture -->
	<key>NSCameraUsageDescription</key>
	<string>Camera access</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, hasLength(1));
      expect(descriptions[0].comments, hasLength(2));
      expect(descriptions[0].comments[0], contains('Marker'));
      expect(descriptions[0].comments[1], contains('Camera permission'));
    });
  });

  group('PListEditor - Format Preservation', () {
    test('preserves original indentation after modifications', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();
      // Should maintain tab indentation
      expect(result, contains('\t<key>'));
      expect(result, contains('\t<string>'));
    });

    test('preserves DOCTYPE declaration', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Test</key>
	<string>Value</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();
      expect(
        result,
        contains('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"'),
      );
    });

    test('preserves XML declaration', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>Test</key>
	<string>Value</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();
      expect(result, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
    });

    test('preserves exact spacing and newlines', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>First</key>
	<string>Value1</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
	<key>Last</key>
	<string>Value2</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      final result = editor.toString();

      // Verify structure is intact
      final lines = result.split('\n');
      expect(lines[0], equals('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(lines[1], equals('<plist version="1.0">'));
      expect(lines[2], equals('<dict>'));
      expect(lines[lines.length - 1], equals('</plist>'));
    });

    test('no format changes when querying only', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSCameraUsageDescription</key>
	<string>Camera</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.getUsageDescriptions();

      final result = editor.toString();
      expect(result, equals(realPlist));
    });

    test('preserves format through add and remove operations', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);

      // Add a permission
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera',
      );

      // Remove it
      editor.removeUsageDescription(name: 'NSCameraUsageDescription');

      final result = editor.toString();
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
      expect(result, startsWith('<?xml version'));
      expect(result, contains('</dict>'));
      expect(result, contains('</plist>'));
    });
  });

  group('PListEditor - Complex Real-world Scenarios', () {
    test('comprehensive example with multiple operations', () {
      const complexPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>Runner</string>
	<key>CFBundleIdentifier</key>
	<string>com.example.app</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location access needed</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>''';

      final editor = PListEditor(complexPlist);

      // Add permissions
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access for photos',
      );
      editor.addUsageDescription(
        key: 'NSPhotoLibraryUsageDescription',
        description: 'Photo library access',
      );
      editor.addUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'Microphone access for audio',
      );

      // Query all
      var descriptions = editor.getUsageDescriptions();
      expect(descriptions, hasLength(4)); // 1 existing + 3 added

      // Remove one
      editor.removeUsageDescription(name: 'NSPhotoLibraryUsageDescription');

      descriptions = editor.getUsageDescriptions();
      expect(descriptions, hasLength(3));

      // Verify structure
      final result = editor.toString();
      expect(result, startsWith('<?xml version'));
      expect(result, contains('<!DOCTYPE plist'));
      expect(result, contains('CFBundleIdentifier'));
      expect(result, contains('NSCameraUsageDescription'));
      expect(result, contains('NSMicrophoneUsageDescription'));
      expect(result, isNot(contains('NSPhotoLibraryUsageDescription')));
    });

    test('handles commented permissions correctly', () {
      const plistWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<!-- @permit:code location -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location needed</string>
	<!-- @permit:code camera -->
	<key>NSCameraUsageDescription</key>
	<string>Camera needed</string>
</dict>
</plist>''';

      final editor = PListEditor(plistWithComments);

      // Remove with specific comment marker
      editor.removeUsageDescription(
        name: 'NSCameraUsageDescription',
        removeComments: (c) => c.contains('@permit:code camera'),
      );

      final result = editor.toString();
      expect(result, contains('@permit:code location'));
      expect(result, isNot(contains('@permit:code camera')));
      expect(result, contains('NSLocationWhenInUseUsageDescription'));
    });
  });

  group('PListEditor - Edge Cases', () {
    test('handles descriptions with special characters', () {
      const realPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location</string>
</dict>
</plist>''';

      final editor = PListEditor(realPlist);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access & photo taking (requires permission)',
      );

      final result = editor.toString();
      // XML encodes special characters like & to &amp;
      expect(result, contains('Camera access &amp; photo taking (requires permission)'));
    });

    test('detects NS usage description keys correctly', () {
      final editor = PListEditor('<plist></plist>');

      expect(editor.isNSUsageDesc('NSCameraUsageDescription'), true);
      expect(editor.isNSUsageDesc('NSLocationWhenInUseUsageDescription'), true);
      expect(editor.isNSUsageDesc('NSPhotoLibraryUsageDescription'), true);
      expect(editor.isNSUsageDesc('NSMicrophoneUsageDescription'), true);

      expect(editor.isNSUsageDesc('CFBundleName'), false);
      expect(editor.isNSUsageDesc('SomeRandomKey'), false);
      expect(editor.isNSUsageDesc('NSCameraPermission'), false);
      expect(editor.isNSUsageDesc('NSUsageDescription'), true); // Matches the pattern
    });

    test('handles whitespace in key detection', () {
      final editor = PListEditor('<plist></plist>');

      expect(editor.isNSUsageDesc('  NSCameraUsageDescription  '), true);
      expect(editor.isNSUsageDesc('\tNSLocationWhenInUseUsageDescription\t'), true);
    });
  });
}
