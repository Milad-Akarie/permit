import 'package:test/test.dart';
import 'package:permit/xml_editor/xml_editor.dart';

void main() {
  group('XmlEditor - Plist Tests', () {
    late String plistContent;

    setUp(() {
      plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for photos</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location for mapping</string>
</dict>
</plist>''';
    });

    group('addPlistEntry', () {
      test('should add a new plist entry with comments', () {
        final editor = PlistEditor(plistContent);
        editor.addUsageDescription(
          key: 'NSMicrophoneUsageDescription',
          description: 'We need microphone access',
          keyComments: ['@permit microphone'],
        );

        final result = editor.toXmlString();
        expect(result.contains('NSMicrophoneUsageDescription'), true);
        expect(result.contains('We need microphone access'), true);
        expect(result.contains('@permit microphone'), true);
      });

      test('should add entry after anchor key', () {
        final editor = PlistEditor(plistContent);
        editor.addUsageDescription(
          key: 'NSContactsUsageDescription',
          description: 'We need contacts access',
          anchorKeys: ['NSPhotoLibraryUsageDescription'],
        );

        final result = editor.toXmlString();
        expect(result.contains('NSContactsUsageDescription'), true);
        // Verify the entry was added
        expect(result.contains('We need contacts access'), true);
      });

      test('should add plist entry without comments', () {
        final editor = PlistEditor(plistContent);
        editor.addEntry(
          path: 'plist.dict',
          key: 'NSBluetoothPeripheralUsageDescription',
          value: '<string>We need bluetooth access</string>',
        );

        final result = editor.toXmlString();
        expect(result.contains('NSBluetoothPeripheralUsageDescription'), true);
      });

      test('should add plist entry with null value (key only)', () {
        final editor = PlistEditor(plistContent);
        editor.addEntry(
          path: 'plist.dict',
          key: 'TestKeyOnly',
          value: null,
          keyComments: ['@permit test key'],
        );

        final result = editor.toXmlString();
        expect(result.contains('TestKeyOnly'), true);
        expect(result.contains('@permit test key'), true);
        // Value should not be present after the key
        final lines = result.split('\n');
        final keyLine = lines.indexWhere((line) => line.contains('TestKeyOnly'));
        expect(keyLine, greaterThanOrEqualTo(0));
        // Check next non-comment line is not a string/value
        int nextLineIdx = keyLine + 1;
        while (nextLineIdx < lines.length && lines[nextLineIdx].trim().startsWith('<!--')) {
          nextLineIdx++;
        }
        expect(lines[nextLineIdx].contains('<string>'), false);
      });

      test('should add entry at specified path', () {
        final plistWithArray = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>ArrayKey</key>
    <array>
    </array>
</dict>
</plist>''';
        final editor = PlistEditor(plistWithArray);
        editor.addEntry(
          path: 'plist.dict',
          key: 'NewKey',
          value: '<string>new value</string>',
        );

        final result = editor.toXmlString();
        expect(result.contains('NewKey'), true);
        expect(result.contains('new value'), true);
      });

      test('should throw exception when dict not found at path', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = PlistEditor(invalidPlist);

        expect(
          () => editor.addEntry(
            path: 'plist.dict',
            key: 'TestKey',
            value: '<string>Test</string>',
          ),
          throwsException,
        );
      });

      test('should throw exception when specified path not found', () {
        final editor = PlistEditor(plistContent);
        expect(
          () => editor.addEntry(
            path: 'plist.dict.nonexistent',
            key: 'TestKey',
            value: '<string>Test</string>',
          ),
          throwsException,
        );
      });
    });

    group('removeEntry', () {
      test('should remove a plist entry with comment marker', () {
        final plistWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!--@permit camera-->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access</string>
</dict>
</plist>''';
        final editor = PlistEditor(plistWithComments);
        editor.removeUsageDescription(
          key: 'NSCameraUsageDescription',
          commentMarkers: ['@permit'],
        );

        final result = editor.toXmlString();
        expect(result.contains('NSCameraUsageDescription'), false);
        expect(result.contains('We need camera access'), false);
        expect(result.contains('NSPhotoLibraryUsageDescription'), true);
        expect(result.contains('@permit camera'), false);
      });

      test('should remove plist entry without comments', () {
        final editor = PlistEditor(plistContent);
        // Note: removePlistEntry removes from the key through the value
        // It should remove both the key line and the value line
        editor.removeUsageDescription(
          key: 'NSLocationWhenInUseUsageDescription',
        );

        final result = editor.toXmlString();
        // The key should be removed
        expect(result.contains('NSLocationWhenInUseUsageDescription'), false);
        // Other keys should remain
        expect(result.contains('NSCameraUsageDescription'), true);
      });

      test('should throw exception for non-existent key', () {
        final editor = PlistEditor(plistContent);
        expect(
          () => editor.removeUsageDescription(key: 'NonexistentKey'),
          throwsException,
        );
      });

      test('should throw exception when dict not found', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = PlistEditor(invalidPlist);

        expect(
          () => editor.removeUsageDescription(key: 'TestKey'),
          throwsException,
        );
      });
    });
  });

  group('addArrayEntry', () {
    final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for photos</string>
</dict>
</plist>''';

    test('should create new array if it does not exist', () {
      final editor = PlistEditor(plistContent);
      editor.addArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>location</string>',
        keyComments: ['@permit background'],
      );

      final result = editor.toXmlString();
      expect(result.contains('<key>UIBackgroundModes</key>'), true);
      expect(result.contains('<array>'), true);
      expect(result.contains('<string>location</string>'), true);
      expect(result.contains('@permit background'), true);
    });

    test('should append to existing array', () {
      final plistWithArray = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
</dict>
</plist>''';

      final editor = PlistEditor(plistWithArray);
      editor.addArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>fetch</string>',
      );

      final result = editor.toXmlString();
      expect(result.contains('<string>location</string>'), true);
      expect(result.contains('<string>fetch</string>'), true);
      // Should only have one key
      final keyCount = result.split('\n').where((l) => l.contains('<key>UIBackgroundModes</key>')).length;
      expect(keyCount, equals(1));
    });

    test('should append multiple entries to array', () {
      final editor = PlistEditor(plistContent);
      editor.addArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>location</string>',
      );
      editor.addArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>fetch</string>',
      );
      editor.addArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>voip</string>',
      );

      final result = editor.toXmlString();
      expect(result.contains('<string>location</string>'), true);
      expect(result.contains('<string>fetch</string>'), true);
      expect(result.contains('<string>voip</string>'), true);
    });
  });

  group('removeArrayEntry', () {
    test('should remove entry from array', () {
      final plistWithArray = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>fetch</string>
    </array>
</dict>
</plist>''';

      final editor = PlistEditor(plistWithArray);
      editor.removeArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>location</string>',
      );

      final result = editor.toXmlString();
      expect(result.contains('<string>location</string>'), false);
      expect(result.contains('<string>fetch</string>'), true);
      expect(result.contains('<key>UIBackgroundModes</key>'), true);
      expect(result.contains('<array>'), true);
    });

    test('should remove key and array if it becomes empty', () {
      final plistWithArray = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
</dict>
</plist>''';

      final editor = PlistEditor(plistWithArray);
      editor.removeArrayEntry(
        path: 'plist.dict',
        key: 'UIBackgroundModes',
        entry: '<string>location</string>',
      );

      final result = editor.toXmlString();
      expect(result.contains('UIBackgroundModes'), false);
      expect(result.contains('<array>'), false);
      expect(result.contains('<string>location</string>'), false);
    });

    test('should throw exception if entry not found', () {
      final plistWithArray = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
</dict>
</plist>''';

      final editor = PlistEditor(plistWithArray);
      expect(
        () => editor.removeArrayEntry(
          path: 'plist.dict',
          key: 'UIBackgroundModes',
          entry: '<string>nonexistent</string>',
        ),
        throwsException,
      );
    });

    test('should throw exception if key not found', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for photos</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);
      expect(
        () => editor.removeArrayEntry(
          path: 'plist.dict',
          key: 'UIBackgroundModes',
          entry: '<string>location</string>',
        ),
        throwsException,
      );
    });
  });

  group('override functionality', () {
    test('should override existing key with new comments', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for photos</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);

      // Add a usage description with initial comments
      editor.addUsageDescription(
        key: 'NSLocationWhenInUseUsageDescription',
        description: 'Old location description',
        keyComments: ['@permit old location comment'],
      );

      String result = editor.toXmlString();
      expect(result.contains('NSLocationWhenInUseUsageDescription'), true);
      expect(result.contains('Old location description'), true);
      expect(result.contains('@permit old location comment'), true);

      // Override with new comments
      editor.addUsageDescription(
        key: 'NSLocationWhenInUseUsageDescription',
        description: 'New location description',
        keyComments: ['@permit new location comment', 'Updated for feature X'],
        override: true,
      );

      result = editor.toXmlString();
      expect(result.contains('NSLocationWhenInUseUsageDescription'), true);
      expect(result.contains('New location description'), true);
      expect(result.contains('@permit new location comment'), true);
      expect(result.contains('Updated for feature X'), true);
      expect(result.contains('Old location description'), false);
      expect(result.contains('@permit old location comment'), false);

      // Should only have one NSLocationWhenInUseUsageDescription key
      final keyCount = result.split('<key>NSLocationWhenInUseUsageDescription</key>').length - 1;
      expect(keyCount, equals(1));
    });

    test('should override existing entry with new comments using addEntry', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit bluetooth v1 -->
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Old bluetooth description</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);

      // Override with new comments
      editor.addEntry(
        path: 'plist.dict',
        key: 'NSBluetoothPeripheralUsageDescription',
        value: '<string>New bluetooth description</string>',
        keyComments: ['@permit bluetooth v2', 'Enhanced bluetooth support'],
        override: true,
      );

      final result = editor.toXmlString();
      expect(result.contains('NSBluetoothPeripheralUsageDescription'), true);
      expect(result.contains('New bluetooth description'), true);
      expect(result.contains('@permit bluetooth v2'), true);
      expect(result.contains('Enhanced bluetooth support'), true);
      expect(result.contains('Old bluetooth description'), false);
      expect(result.contains('@permit bluetooth v1'), false);

      // Should only have one NSBluetoothPeripheralUsageDescription key
      final keyCount = result.split('<key>NSBluetoothPeripheralUsageDescription</key>').length - 1;
      expect(keyCount, equals(1));
    });

    test('should remove old @permit comments when overriding', () {
      final plistWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit old comment line 1 -->
    <!-- @permit old comment line 2 -->
    <key>NSCameraUsageDescription</key>
    <string>Old camera description</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistWithComments);

      // Override with new comments
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New camera description',
        keyComments: ['@permit new camera permission'],
        override: true,
      );

      final result = editor.toXmlString();
      expect(result.contains('NSCameraUsageDescription'), true);
      expect(result.contains('New camera description'), true);
      expect(result.contains('@permit new camera permission'), true);
      expect(result.contains('Old camera description'), false);
      expect(result.contains('@permit old comment line 1'), false);
      expect(result.contains('@permit old comment line 2'), false);
    });

    test('should override key-only entry (no value)', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit old key -->
    <key>TestKey</key>
    <string>some value</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);

      // Override with new key and value
      editor.addEntry(
        path: 'plist.dict',
        key: 'TestKey',
        value: '<string>new value</string>',
        keyComments: ['@permit new key'],
        override: true,
      );

      final result = editor.toXmlString();
      expect(result.contains('TestKey'), true);
      expect(result.contains('new value'), true);
      expect(result.contains('@permit new key'), true);
      expect(result.contains('some value'), false);
      expect(result.contains('@permit old key'), false);
    });

    test('should not override when override=false and key exists', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>Existing camera description</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);

      // This should not throw because we're checking existence differently
      // But we expect duplicate keys if override=false
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New camera description',
        keyComments: ['@permit new camera'],
        override: false,
      );

      final result = editor.toXmlString();
      // Both descriptions should exist
      expect(result.contains('Existing camera description'), true);
      expect(result.contains('New camera description'), true);

      // Should have TWO NSCameraUsageDescription keys
      final keyCount = result.split('<key>NSCameraUsageDescription</key>').length - 1;
      expect(keyCount, equals(2));
    });

    test('should handle override with valueComments', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>TestKey</key>
    <string>old value</string>
</dict>
</plist>''';

      final editor = PlistEditor(plistContent);

      // Override with both key and value comments
      editor.addEntry(
        path: 'plist.dict',
        key: 'TestKey',
        value: '<string>new value</string>',
        keyComments: ['@permit new key comment'],
        valueComments: ['@permit new value comment'],
        override: true,
      );

      final result = editor.toXmlString();
      expect(result.contains('TestKey'), true);
      expect(result.contains('new value'), true);
      expect(result.contains('@permit new key comment'), true);
      expect(result.contains('@permit new value comment'), true);
      expect(result.contains('old value'), false);
    });
  });
}
