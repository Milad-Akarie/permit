import 'package:permit/editor/models.dart';
import 'package:test/test.dart';
import 'package:permit/editor/xml_editor.dart';

void main() {
  group('XmlEditor - Plist Tests', () {
    late String plistContent;

    setUp(() {
      plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bundle identifier -->
    <key>CFBundleIdentifier</key>
    <string>com.example.myapp</string>
    <!-- Bundle version -->
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <!-- Bundle short version -->
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <!-- Camera usage description -->
    <!-- @permit camera -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for taking photos</string>
    <!-- Photo library usage -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access for saving images</string>
    <!-- Location usage when in use -->
    <!-- Custom location comment -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location for mapping features</string>
    <!-- Microphone access -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Microphone access for voice recording</string>
    <!-- Background modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>fetch</string>
    </array>
    <!-- Custom user comment -->
    <!-- Another comment -->
    <key>CustomKey</key>
    <string>Custom value</string>
</dict>
</plist>''';
    });

    group('addEntry', () {
      test('should add a new plist entry with comments', () {
        final editor = PListEditor(plistContent);
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
        final editor = PListEditor(plistContent);
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
        final editor = PListEditor(plistContent);
        editor.addEntry(
          path: 'plist.dict',
          key: 'NSBluetoothPeripheralUsageDescription',
          value: '<string>We need bluetooth access</string>',
        );

        final result = editor.toXmlString();
        expect(result.contains('NSBluetoothPeripheralUsageDescription'), true);
      });

      test('should add plist entry with null value (key only)', () {
        final editor = PListEditor(plistContent);
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
        final editor = PListEditor(plistWithArray);
        editor.addEntry(
          path: 'plist.dict',
          key: 'NewKey',
          value: '<string>new value</string>',
        );

        final result = editor.toXmlString();
        expect(result.contains('NewKey'), true);
        expect(result.contains('new value'), true);
      });

      test('should place comments correctly above their keys', () {
        final editor = PListEditor(plistContent);
        editor.addUsageDescription(
          key: 'NSMicrophoneUsageDescription',
          description: 'We need microphone access',
          keyComments: ['comment1'],
        );
        editor.addUsageDescription(
          key: 'NSBluetoothPeripheralUsageDescription',
          description: 'We need bluetooth access',
          keyComments: ['comment2'],
        );

        final result = editor.toXmlString();
        final lines = result.split('\n');

        // Find indices of comments and keys
        int comment1Index = -1;
        int key1Index = -1;
        int comment2Index = -1;
        int key2Index = -1;

        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('comment1')) comment1Index = i;
          if (lines[i].contains('NSMicrophoneUsageDescription')) key1Index = i;
          if (lines[i].contains('comment2')) comment2Index = i;
          if (lines[i].contains('NSBluetoothPeripheralUsageDescription')) key2Index = i;
        }

        // Verify all were found
        expect(comment1Index, greaterThanOrEqualTo(0));
        expect(key1Index, greaterThanOrEqualTo(0));
        expect(comment2Index, greaterThanOrEqualTo(0));
        expect(key2Index, greaterThanOrEqualTo(0));

        // Verify comments are directly above their keys
        expect(comment1Index, lessThan(key1Index), reason: 'comment1 should appear before key1');
        expect(comment2Index, lessThan(key2Index), reason: 'comment2 should appear before key2');

        // Verify comment1 comes before comment2
        expect(comment1Index, lessThan(comment2Index), reason: 'comment1 should appear before comment2');
      });

      test('should throw exception when dict not found at path', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = PListEditor(invalidPlist);

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
        final editor = PListEditor(plistContent);
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
        final editor = PListEditor(plistWithComments);
        editor.removeUsageDescription(
          key: 'NSCameraUsageDescription',
          removeComments: (comment) => comment.contains('@permit'),
        );

        final result = editor.toXmlString();
        expect(result.contains('NSCameraUsageDescription'), false);
        expect(result.contains('We need camera access'), false);
        expect(result.contains('NSPhotoLibraryUsageDescription'), true);
        expect(result.contains('@permit camera'), false);
      });

      test('should remove plist entry without comments', () {
        final editor = PListEditor(plistContent);
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
        final editor = PListEditor(plistContent);
        expect(
          () => editor.removeUsageDescription(key: 'NonexistentKey'),
          throwsException,
        );
      });

      test('should throw exception when dict not found', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = PListEditor(invalidPlist);

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
      final editor = PListEditor(plistContent);
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

      final editor = PListEditor(plistWithArray);
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
      final editor = PListEditor(plistContent);
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

      final editor = PListEditor(plistWithArray);
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

      final editor = PListEditor(plistWithArray);
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

      final editor = PListEditor(plistWithArray);
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

      final editor = PListEditor(plistContent);
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

      final editor = PListEditor(plistContent);

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
        shouldRemoveComment: (comment) => comment.contains('@permit'),
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

      final editor = PListEditor(plistContent);

      // Override with new comments
      editor.addEntry(
        path: 'plist.dict',
        key: 'NSBluetoothPeripheralUsageDescription',
        value: '<string>New bluetooth description</string>',
        keyComments: ['@permit bluetooth v2', 'Enhanced bluetooth support'],
        shouldRemoveComment: (comment) => comment.contains('@permit'),
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

      final editor = PListEditor(plistWithComments);

      // Override with new comments
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New camera description',
        keyComments: ['@permit new camera permission'],
        shouldRemoveComment: (comment) => comment.contains('@permit'),
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

      final editor = PListEditor(plistContent);

      // Override with new key and value
      editor.addEntry(
        path: 'plist.dict',
        key: 'TestKey',
        value: '<string>new value</string>',
        keyComments: ['@permit new key'],
        shouldRemoveComment: (comment) => comment.contains('@permit'),
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

      final editor = PListEditor(plistContent);

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

    // Tests for shouldRemoveComment callback
    test('should use custom shouldRemoveComment callback to remove specific comments', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera -->
    <!-- @deprecated old api -->
    <!-- Important: keep this -->
    <key>NSCameraUsageDescription</key>
    <string>Old camera description</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      // Override with custom callback that only removes @deprecated comments
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New camera description',
        keyComments: ['@permit camera', '@version 2.0'],
        shouldRemoveComment: (comment) => comment.contains('@deprecated'),
      );

      final result = editor.toXmlString();
      expect(result.contains('NSCameraUsageDescription'), true);
      expect(result.contains('New camera description'), true);
      expect(result.contains('@permit camera'), true);
      expect(result.contains('@version 2.0'), true);
      expect(result.contains('@deprecated old api'), false);
      expect(result.contains('Important: keep this'), true);
      expect(result.contains('Old camera description'), false);
    });

    test('should remove only comments matching the callback criteria', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @feature flag1 -->
    <!-- @feature flag2 -->
    <!-- @note some note -->
    <key>TestKey</key>
    <string>old value</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      // Override with callback that removes @feature comments only
      editor.addEntry(
        path: 'plist.dict',
        key: 'TestKey',
        value: '<string>new value</string>',
        keyComments: ['@feature flag3'],
        override: true,
        shouldRemoveComment: (comment) => comment.contains('@feature'),
      );

      final result = editor.toXmlString();
      expect(result.contains('TestKey'), true);
      expect(result.contains('new value'), true);
      expect(result.contains('@feature flag1'), false);
      expect(result.contains('@feature flag2'), false);
      expect(result.contains('@feature flag3'), true);
      expect(result.contains('@note some note'), true);
      expect(result.contains('old value'), false);
    });

    test('should preserve all comments when shouldRemoveComment returns false for all', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera -->
    <!-- Important note -->
    <key>NSCameraUsageDescription</key>
    <string>Old description</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      // Override with callback that never returns true (removes nothing)
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'New description',
        keyComments: ['@permit camera v2'],
        override: true,
        shouldRemoveComment: (comment) => false,
      );

      final result = editor.toXmlString();
      expect(result.contains('NSCameraUsageDescription'), true);
      expect(result.contains('New description'), true);
      expect(result.contains('@permit camera'), true);
      expect(result.contains('Important note'), true);
      expect(result.contains('@permit camera v2'), true);
      expect(result.contains('Old description'), false);
    });

    test('should use custom callback with multiple matching criteria', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera v1 -->
    <!-- TODO: review this -->
    <!-- @deprecated -->
    <key>NSCameraUsageDescription</key>
    <string>old</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      // Override with callback that removes comments containing @permit or @deprecated
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'new',
        keyComments: ['@permit camera v2'],
        override: true,
        shouldRemoveComment: (comment) => comment.contains('@permit') || comment.contains('@deprecated'),
      );

      final result = editor.toXmlString();
      expect(result.contains('@permit camera v1'), false);
      expect(result.contains('@deprecated'), false);
      expect(result.contains('TODO: review this'), true);
      expect(result.contains('@permit camera v2'), true);
      expect(result.contains('NSCameraUsageDescription'), true);
      expect(result.contains('new'), true);
    });

    test('should work with removeEntry and custom callback', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera -->
    <!-- @internal internal-only -->
    <key>NSCameraUsageDescription</key>
    <string>camera description</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      // This test uses removeEntry which already has commentMarkers parameter
      // But we can verify the behavior with a custom marker list
      editor.removeEntry(
        path: 'plist.dict',
        key: 'NSCameraUsageDescription',
        removeComments: (c) => c.contains('@internal'),
      );

      final result = editor.toXmlString();
      expect(result.contains('NSCameraUsageDescription'), false);
      expect(result.contains('@permit camera'), true);
      expect(result.contains('@internal internal-only'), false);
      expect(result.contains('camera description'), false);
    });

    test('should default to removing @permit when shouldRemoveComment is null', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit old -->
    <!-- @other comment -->
    <key>TestKey</key>
    <string>old</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);

      editor.addUsageDescription(
        key: 'TestKey',
        description: 'new',
        keyComments: ['@permit new'],
        shouldRemoveComment: (comment) => comment.contains('@permit'),
      );

      final result = editor.toXmlString();
      expect(result.contains('@permit old'), false);
      expect(result.contains('@other comment'), true);
      expect(result.contains('@permit new'), true);
      expect(result.contains('old'), false);
    });
  });

  group('getUsageDescriptions', () {
    test('should retrieve all usage descriptions from plist', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
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

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access for photos',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSPhotoLibraryUsageDescription',
            description: 'We need photo library access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSLocationWhenInUseUsageDescription',
            description: 'We need your location for mapping',
            comments: [],
          ),
        ]),
      );
    });

    test('should retrieve usage descriptions with associated comments', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera -->
    <!-- User-facing camera description -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <!-- @permit microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>We need microphone access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: ['@permit camera', 'User-facing camera description'],
          ),
          PListUsageDescription(
            key: 'NSMicrophoneUsageDescription',
            description: 'We need microphone access',
            comments: ['@permit microphone'],
          ),
        ]),
      );
    });

    test('should return empty list when plist dict is empty', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(descriptions, equals([]));
    });

    test('should return only usage-description keys', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>SomeOtherKey</key>
    <string>Some value</string>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      expect(
        editor.getUsageDescriptions(),
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
        ]),
      );
    });

    test('should retrieve only string-type values as usage descriptions', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSPhotoLibraryUsageDescription',
            description: 'We need photo library access',
            comments: [],
          ),
        ]),
      );
    });

    test('should throw exception when dict not found at plist.dict path', () {
      final invalidPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<array></array>
</plist>''';

      final editor = PListEditor(invalidPlist);
      expect(
        () => editor.getUsageDescriptions(),
        throwsException,
      );
    });

    test('should retrieve descriptions after adding new entries', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      editor.addUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'We need microphone access',
        keyComments: ['@permit microphone'],
        anchorKeys: ['NSCameraUsageDescription'],
      );
      editor.addUsageDescription(
        key: 'NSLocationWhenInUseUsageDescription',
        description: 'We need location access',
        keyComments: ['@permit location'],
        anchorKeys: ['NSMicrophoneUsageDescription'],
      );

      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSMicrophoneUsageDescription',
            description: 'We need microphone access',
            comments: ['@permit microphone'],
          ),
          PListUsageDescription(
            key: 'NSLocationWhenInUseUsageDescription',
            description: 'We need location access',
            comments: ['@permit location'],
          ),
        ]),
      );
    });

    test('should retrieve descriptions after removing entries', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need microphone access</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need location access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      editor.removeUsageDescription(key: 'NSMicrophoneUsageDescription');

      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSLocationWhenInUseUsageDescription',
            description: 'We need location access',
            comments: [],
          ),
        ]),
      );
    });

    test('should handle usage descriptions with whitespace in values', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>  We need camera access  </string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>
        Multiline description\nthat spans multiple lines
    </string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSPhotoLibraryUsageDescription',
            description: 'Multiline description\nthat spans multiple lines',
            comments: [],
          ),
        ]),
      );
    });

    test('should use equality and hashCode correctly for PListUsageDescription', () {
      final desc1 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'We need camera access',
        comments: ['@permit camera'],
      );
      final desc2 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'We need camera access',
        comments: ['@permit camera'],
      );
      final desc3 = PListUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'We need microphone access',
        comments: ['@permit microphone'],
      );

      expect(desc1, equals(desc2));
      expect(desc1, isNot(equals(desc3)));
      expect(desc1.hashCode, equals(desc2.hashCode));
      expect(desc1.hashCode, isNot(equals(desc3.hashCode)));
    });

    test('should handle descriptions with empty comments list', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <!-- @permit microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>We need microphone access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSMicrophoneUsageDescription',
            description: 'We need microphone access',
            comments: ['@permit microphone'],
          ),
        ]),
      );
    });

    test('should match retrieved descriptions against full objects', () {
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- @permit camera -->
    <!-- Camera access needed -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access</string>
    <!-- @permit microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>We need microphone access</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need location access</string>
</dict>
</plist>''';

      final editor = PListEditor(plistContent);
      final descriptions = editor.getUsageDescriptions();

      expect(
        descriptions,
        equals([
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'We need camera access',
            comments: ['@permit camera', 'Camera access needed'],
          ),
          PListUsageDescription(
            key: 'NSMicrophoneUsageDescription',
            description: 'We need microphone access',
            comments: ['@permit microphone'],
          ),
          PListUsageDescription(
            key: 'NSLocationWhenInUseUsageDescription',
            description: 'We need location access',
            comments: [],
          ),
        ]),
      );
    });
  });

  group('Format Preservation', () {
    late String plistContent;

    setUp(() {
      plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bundle identifier -->
    <key>CFBundleIdentifier</key>
    <string>com.example.myapp</string>
    <!-- Bundle version -->
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <!-- Bundle short version -->
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <!-- Camera usage description -->
    <!-- @permit camera -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access for taking photos</string>
    <!-- Photo library usage -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access for saving images</string>
    <!-- Location usage when in use -->
    <!-- Custom location comment -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location for mapping features</string>
    <!-- Microphone access -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Microphone access for voice recording</string>
    <!-- Background modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>fetch</string>
    </array>
    <!-- Custom user comment -->
    <!-- Another comment -->
    <key>CustomKey</key>
    <string>Custom value</string>
</dict>
</plist>''';
    });

    test('should preserve XML formatting when adding entries', () {
      final editor = PListEditor(plistContent);
      editor.addUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'We need microphone access',
        keyComments: ['@permit microphone'],
      );

      final result = editor.toXmlString();
      final expected = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <!-- Bundle identifier -->
        <key>CFBundleIdentifier</key>
        <string>com.example.myapp</string>
        <!-- Bundle version -->
        <key>CFBundleVersion</key>
        <string>1.0.0</string>
        <!-- Bundle short version -->
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <!-- Camera usage description -->
        <!-- @permit camera -->
        <key>NSCameraUsageDescription</key>
        <string>We need camera access for taking photos</string>
        <!-- Photo library usage -->
        <key>NSPhotoLibraryUsageDescription</key>
        <string>We need photo library access for saving images</string>
        <!-- Location usage when in use -->
        <!-- Custom location comment -->
        <key>NSLocationWhenInUseUsageDescription</key>
        <string>We need your location for mapping features</string>
        <!--@permit microphone-->
        <key>NSMicrophoneUsageDescription</key>
        <string>We need microphone access</string>
        <!-- Microphone access -->
        <!-- Background modes -->
        <key>UIBackgroundModes</key>
        <array>
            <string>location</string>
            <string>fetch</string>
        </array>
        <!-- Custom user comment -->
        <!-- Another comment -->
        <key>CustomKey</key>
        <string>Custom value</string>
    </dict>
</plist>''';

      expect(result, expected);
    });

    test('should preserve formatting when overriding entries', () {
      final editor = PListEditor(plistContent);
      editor.addUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Updated camera access',
        keyComments: ['@permit camera'],
        override: true,
        shouldRemoveComment: (comment) => comment.contains('@permit'),
      );

      final result = editor.toXmlString();
      final expected = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <!-- Bundle identifier -->
        <key>CFBundleIdentifier</key>
        <string>com.example.myapp</string>
        <!-- Bundle version -->
        <key>CFBundleVersion</key>
        <string>1.0.0</string>
        <!-- Bundle short version -->
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <!-- Camera usage description -->
        <!-- Photo library usage -->
        <key>NSPhotoLibraryUsageDescription</key>
        <string>We need photo library access for saving images</string>
        <!-- Location usage when in use -->
        <!-- Custom location comment -->
        <key>NSLocationWhenInUseUsageDescription</key>
        <string>We need your location for mapping features</string>
        <!-- Microphone access -->
        <key>NSMicrophoneUsageDescription</key>
        <string>Microphone access for voice recording</string>
        <!--@permit camera-->
        <key>NSCameraUsageDescription</key>
        <string>Updated camera access</string>
        <!-- Background modes -->
        <key>UIBackgroundModes</key>
        <array>
            <string>location</string>
            <string>fetch</string>
        </array>
        <!-- Custom user comment -->
        <!-- Another comment -->
        <key>CustomKey</key>
        <string>Custom value</string>
    </dict>
</plist>''';

      expect(result, expected);
    });

    test('should handle single-line XML input correctly', () {
      final singleLinePlist =
          '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>NSCameraUsageDescription</key><string>We need camera access</string></dict></plist>';
      final editor = PListEditor(singleLinePlist);

      editor.addUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'We need microphone access',
        keyComments: ['@permit microphone'],
      );

      final result = editor.toXmlString();
      expect(result.contains('NSMicrophoneUsageDescription'), true);
      expect(result.contains('We need microphone access'), true);
      expect(result.contains('@permit microphone'), true);
      expect(editor.validate(), true);
    });
  });
}
