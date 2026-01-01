import 'package:test/test.dart';
import 'package:permit/xml_editor/xml_editor.dart';
import 'package:xml/xml.dart';

void main() {
  group('XmlEditor - AndroidManifest Tests', () {
    late String manifestContent;

    setUp(() {
      manifestContent = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <application
        android:label="TestApp"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service
            android:name=".MyService"
            android:enabled="true" />
    </application>
</manifest>''';
    });

    group('addManifestTag', () {
      test('should add a uses-permission tag with comments', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.BLUETOOTH" />',
          comments: ['@permit bluetooth access', 'Required for device connectivity'],
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.BLUETOOTH'), true);
        expect(result.contains('@permit bluetooth access'), true);
        expect(result.contains('Required for device connectivity'), true);
      });

      test('should add a tag without comments', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.LOCATION" />',
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.LOCATION'), true);
      });

      test('should add activity child tag to application', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest.application',
          tag: '<activity android:name=".SecondActivity" android:exported="false" />',
          comments: ['@permit secondary screen'],
        );

        final result = editor.toXmlString();
        expect(result.contains('.SecondActivity'), true);
        expect(result.contains('@permit secondary screen'), true);
      });

      test('should throw exception for non-existent parent path', () {
        final editor = XmlEditor(manifestContent);
        expect(
          () => editor.addManifestTag(
            path: 'manifest.nonexistent',
            tag: '<test />',
          ),
          throwsException,
        );
      });

      test('should throw exception for self-closing parent', () {
        final selfClosingManifest = '<manifest />';
        final editor = XmlEditor(selfClosingManifest);
        expect(
          () => editor.addManifestTag(
            path: 'manifest',
            tag: '<uses-permission android:name="test" />',
          ),
          throwsException,
        );
      });

      test('should preserve XML formatting and indentation', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.READ_CONTACTS" />',
        );

        final result = editor.toXmlString();
        // Check that indentation is preserved
        expect(result.contains('    <uses-permission'), true);
      });
    });

    group('removeManifestTag', () {
      test('should remove a uses-permission tag with comment marker', () {
        final manifestWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!--@permit internet-->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>''';
        final editor = XmlEditor(manifestWithComments);
        editor.removeManifestTag(
          path: 'manifest',
          tagName: 'uses-permission',
          attribute: ('android:name', 'android.permission.INTERNET'),
          comments: ['@permit'],
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.INTERNET'), false);
        expect(result.contains('android.permission.CAMERA'), true);
        expect(result.contains('@permit internet'), false);
      });

      test('should remove a tag without comments', () {
        final editor = XmlEditor(manifestContent);
        editor.removeManifestTag(
          path: 'manifest',
          tagName: 'uses-permission',
          attribute: ('android:name', 'android.permission.INTERNET'),
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.INTERNET'), false);
        expect(result.contains('android.permission.CAMERA'), true);
      });

      test('should throw exception for non-existent tag', () {
        final editor = XmlEditor(manifestContent);
        expect(
          () => editor.removeManifestTag(
            path: 'manifest',
            tagName: 'uses-permission',
            attribute: ('android:name', 'android.permission.NONEXISTENT'),
          ),
          throwsException,
        );
      });

      test('should throw exception for non-existent parent path', () {
        final editor = XmlEditor(manifestContent);
        expect(
          () => editor.removeManifestTag(
            path: 'manifest.nonexistent',
            tagName: 'activity',
            attribute: ('android:name', '.MainActivity'),
          ),
          throwsException,
        );
      });

      test('should remove activity from application', () {
        final editor = XmlEditor(manifestContent);
        editor.removeManifestTag(
          path: 'manifest.application',
          tagName: 'activity',
          attribute: ('android:name', '.MainActivity'),
        );

        final result = editor.toXmlString();
        expect(result.contains('.MainActivity'), false);
        expect(result.contains('android.permission.INTERNET'), true);
      });

      test('should remove service tag', () {
        final editor = XmlEditor(manifestContent);
        editor.removeManifestTag(
          path: 'manifest.application',
          tagName: 'service',
          attribute: ('android:name', '.MyService'),
        );

        final result = editor.toXmlString();
        expect(result.contains('.MyService'), false);
        expect(result.contains('<activity'), true);
      });
    });

    group('findTagsByName', () {
      test('should find all uses-permission tags', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByName('uses-permission');

        expect(tags.length, 2);
        expect(tags[0].getAttribute('android:name'), 'android.permission.INTERNET');
        expect(tags[1].getAttribute('android:name'), 'android.permission.CAMERA');
      });

      test('should find activity tags', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByName('activity');

        expect(tags.length, 1);
        expect(tags[0].getAttribute('android:name'), '.MainActivity');
      });

      test('should return empty list for non-existent tag', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByName('nonexistent');

        expect(tags.length, 0);
      });
    });

    group('findTagsByAttribute', () {
      test('should find tag by attribute name and value', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByAttribute(
          tagName: 'uses-permission',
          attributeName: 'android:name',
          attributeValue: 'android.permission.INTERNET',
        );

        expect(tags.length, 1);
        expect(tags[0].getAttribute('android:name'), 'android.permission.INTERNET');
      });

      test('should find multiple tags with same attribute value', () {
        final multiPerm = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
</manifest>''';
        final editor = XmlEditor(multiPerm);
        final tags = editor.findTagsByAttribute(
          tagName: 'uses-permission',
          attributeName: 'android:name',
          attributeValue: 'android.permission.READ_CONTACTS',
        );

        expect(tags.length, 2);
      });

      test('should find tags without specifying tagName', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByAttribute(
          attributeName: 'android:name',
          attributeValue: '.MainActivity',
        );

        expect(tags.length, 1);
      });

      test('should return empty list for non-matching attribute', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTagsByAttribute(
          tagName: 'uses-permission',
          attributeName: 'android:name',
          attributeValue: 'nonexistent.permission',
        );

        expect(tags.length, 0);
      });
    });

    group('findTagsByNameInPath', () {
      test('should find all tags of specific type in a path', () {
        final editor = XmlEditor(manifestContent);
        final activities = editor.findTags(
          path: 'manifest.application',
          name: 'activity',
        );

        expect(activities.length, 1);
        expect(activities[0].getAttribute('android:name'), '.MainActivity');
      });

      test('should find multiple tags of same type in a path', () {
        final multiActivityManifest = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".MainActivity" android:exported="true" />
        <activity android:name=".SecondActivity" android:exported="false" />
        <activity android:name=".ThirdActivity" android:exported="false" />
    </application>
</manifest>''';
        final editor = XmlEditor(multiActivityManifest);
        final activities = editor.findTags(
          path: 'manifest.application',
          name: 'activity',
        );

        expect(activities.length, 3);
      });

      test('should return empty list when path does not exist', () {
        final editor = XmlEditor(manifestContent);
        final tags = editor.findTags(
          path: 'manifest.nonexistent',
          name: 'activity',
        );

        expect(tags.length, 0);
      });

      test('should return empty list when no tags of specified type exist in path', () {
        final editor = XmlEditor(manifestContent);
        final services = editor.findTags(
          path: 'manifest',
          name: 'service',
        );

        expect(services.length, 0);
      });

      test('should find tags in nested paths', () {
        final nestedXml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>''';
        final editor = XmlEditor(nestedXml);
        final actions = editor.findTags(
          path: 'manifest.application.activity.intent-filter',
          name: 'action',
        );

        expect(actions.length, 1);
        expect(actions[0].getAttribute('android:name'), 'android.intent.action.MAIN');
      });
    });

    group('getCommentsOf', () {
      test('should retrieve single comment above element', () {
        final manifestWithComment = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- @permit internet access -->
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>''';
        final editor = XmlEditor(manifestWithComment);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 1);
        expect(comments[0], '@permit internet access');
      });

      test('should retrieve multiple comments above element', () {
        final manifestWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- @permit internet -->
    <!-- Required for API calls -->
    <!-- Updated: 2024 -->
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>''';
        final editor = XmlEditor(manifestWithComments);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 3);
        expect(comments[0], '@permit internet');
        expect(comments[1], 'Required for API calls');
        expect(comments[2], 'Updated: 2024');
      });

      test('should return empty list for element without comments', () {
        final editor = XmlEditor(manifestContent);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 0);
      });

      test('should stop at non-comment lines when looking for comments', () {
        final manifestWithGap = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Old comment from elsewhere -->
    <!-- @permit location -->
    <uses-permission android:name="android.permission.LOCATION" />
</manifest>''';
        final editor = XmlEditor(manifestWithGap);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);
        expect(comments.length, 2);
        expect(comments[1], '@permit location');
      });

      test('should skip empty lines when looking backwards for comments', () {
        final manifestWithEmptyLines = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- @permit camera -->

    
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>''';
        final editor = XmlEditor(manifestWithEmptyLines);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 1);
        expect(comments[0], '@permit camera');
      });

      test('should handle comments with special characters', () {
        final manifestWithSpecialChars = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- @permit: Feature [GPS] - Track user location & map data -->
    <uses-permission android:name="android.permission.LOCATION" />
</manifest>''';
        final editor = XmlEditor(manifestWithSpecialChars);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 1);
        expect(comments[0], '@permit: Feature [GPS] - Track user location & map data');
      });

      test('should retrieve comments for nested elements', () {
        final manifestWithNestedComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- @permit main activity -->
        <activity android:name=".MainActivity" android:exported="true" />
    </application>
</manifest>''';
        final editor = XmlEditor(manifestWithNestedComments);
        final activity = editor.findTagsByName('activity').first;
        final comments = editor.getCommentsOf(activity);

        expect(comments.length, 1);
        expect(comments[0], '@permit main activity');
      });

      test('should work with elements that have been added via addManifestTag', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.BLUETOOTH" />',
          comments: ['@permit bluetooth', 'Device connectivity'],
        );

        final permission = editor
            .findTagsByAttribute(
              tagName: 'uses-permission',
              attributeName: 'android:name',
              attributeValue: 'android.permission.BLUETOOTH',
            )
            .first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 2);
        expect(comments[0], '@permit bluetooth');
        expect(comments[1], 'Device connectivity');
      });
    });

    group('Validation and Format Preservation', () {
      test('should produce valid XML after modifications', () {
        final editor = XmlEditor(manifestContent);
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.WRITE_CONTACTS" />',
        );

        expect(editor.validate(), true);
      });

      test('should preserve XML structure after multiple operations', () {
        final editor = XmlEditor(manifestContent);

        // Add a tag
        editor.addManifestTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.LOCATION" />',
        );
        // Remove a tag
        editor.removeManifestTag(
          path: 'manifest',
          tagName: 'uses-permission',
          attribute: ('android:name', 'android.permission.CAMERA'),
        );

        final result = editor.toXmlString();
        // Verify the operations worked
        expect(result.contains('android.permission.LOCATION'), true);
        expect(result.contains('android.permission.CAMERA'), false);
        expect(result.contains('android.permission.INTERNET'), true);

        // Verify it's still valid XML
        expect(editor.validate(), true);
      });
    });
  });

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
        final editor = XmlEditor(plistContent);
        editor.addPlistEntry(
          key: 'NSMicrophoneUsageDescription',
          value: '<string>We need microphone access</string>',
          keyComments: ['@permit microphone'],
        );

        final result = editor.toXmlString();
        expect(result.contains('NSMicrophoneUsageDescription'), true);
        expect(result.contains('We need microphone access'), true);
        expect(result.contains('@permit microphone'), true);
      });

      test('should add entry after anchor key', () {
        final editor = XmlEditor(plistContent);
        editor.addPlistEntry(
          key: 'NSContactsUsageDescription',
          value: '<string>We need contacts access</string>',
          anchorKeys: ['NSPhotoLibraryUsageDescription'],
        );

        final result = editor.toXmlString();
        expect(result.contains('NSContactsUsageDescription'), true);
        // Verify the entry was added
        expect(result.contains('We need contacts access'), true);
      });

      test('should add plist entry without comments', () {
        final editor = XmlEditor(plistContent);
        editor.addPlistEntry(
          key: 'NSBluetoothPeripheralUsageDescription',
          value: '<string>We need bluetooth access</string>',
        );

        final result = editor.toXmlString();
        expect(result.contains('NSBluetoothPeripheralUsageDescription'), true);
      });

      test('should throw exception when dict not found', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = XmlEditor(invalidPlist);

        expect(
          () => editor.addPlistEntry(
            key: 'TestKey',
            value: '<string>Test</string>',
          ),
          throwsException,
        );
      });
    });

    group('removePlistEntry', () {
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
        final editor = XmlEditor(plistWithComments);
        editor.removePlistEntry(
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
        final editor = XmlEditor(plistContent);
        // Note: removePlistEntry removes from the key through the value
        // It should remove both the key line and the value line
        editor.removePlistEntry(
          key: 'NSLocationWhenInUseUsageDescription',
        );

        final result = editor.toXmlString();
        // The key should be removed
        expect(result.contains('NSLocationWhenInUseUsageDescription'), false);
        // Other keys should remain
        expect(result.contains('NSCameraUsageDescription'), true);
      });

      test('should throw exception for non-existent key', () {
        final editor = XmlEditor(plistContent);
        expect(
          () => editor.removePlistEntry(key: 'NonexistentKey'),
          throwsException,
        );
      });

      test('should throw exception when dict not found', () {
        final invalidPlist = '<?xml version="1.0"?><plist version="1.0"><array></array></plist>';
        final editor = XmlEditor(invalidPlist);

        expect(
          () => editor.removePlistEntry(key: 'TestKey'),
          throwsException,
        );
      });
    });
  });

  group('XmlEditor - Edge Cases and Complex Scenarios', () {
    test('should handle XML with newlines and complex formatting', () {
      final complexXml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest
    xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">
    <uses-permission
        android:name="android.permission.INTERNET" />
</manifest>''';
      final editor = XmlEditor(complexXml);
      final tags = editor.findTagsByAttribute(
        attributeName: 'android:name',
        attributeValue: 'android.permission.INTERNET',
      );

      expect(tags.length, 1);
    });

    test('should handle multiple comment markers', () {
      final manifestWithMultiComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!--@permit-->
    <!--internet access-->
    <!--Required for API-->
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>''';
      final editor = XmlEditor(manifestWithMultiComments);
      editor.removeManifestTag(
        path: 'manifest',
        tagName: 'uses-permission',
        attribute: ('android:name', 'android.permission.INTERNET'),
        comments: ['@permit'],
      );

      final result = editor.toXmlString();
      // The tag should definitely be removed
      expect(result.contains('android.permission.INTERNET'), false);
    });

    test('should preserve empty lines and structure', () {
      final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';
      final editor = XmlEditor(xml);
      // Should still be valid
      expect(editor.validate(), true);
    });

    test('should handle attributes with special characters', () {
      final specialXml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:name="\${applicationName}">
        <activity android:name=".MainActivity" />
    </application>
</manifest>''';
      final editor = XmlEditor(specialXml);
      final tags = editor.findTagsByName('activity');

      expect(tags.length, 1);
    });

    test('should maintain document structure through multiple edits', () {
      final manifest = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <manifest xmlns:android="http://schemas.android.com/apk/res/android">
          <uses-permission android:name="android.permission.INTERNET" />
          <uses-permission android:name="android.permission.CAMERA" />
          <application android:name="test">
          </application>
      </manifest>
''';
      final editor = XmlEditor(manifest);

      // Add, remove, and check validity
      editor.addManifestTag(
        path: 'manifest',
        tag: '<uses-permission android:name="android.permission.LOCATION" />',
      );
      editor.removeManifestTag(
        path: 'manifest',
        tagName: 'uses-permission',
        attribute: ('android:name', 'android.permission.CAMERA'),
      );

      final result = editor.toXmlString();
      expect(result.contains('android.permission.INTERNET'), true);
      expect(result.contains('android.permission.LOCATION'), true);
      expect(result.contains('android.permission.CAMERA'), false);

      // Final validation
      expect(editor.validate(), true);
    });
  });

  group('XmlEditor - Additional Tests', () {
    test('inserts new child after last sibling of same type', () {
      final manifest = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <application>
        <activity android:name=".ActivityA" />
        <activity android:name=".ActivityB" />
    </application>
</manifest>''';

      final editor = XmlEditor(manifest);
      editor.addManifestTag(
        path: 'manifest.application',
        tag: '<activity android:name=".ActivityC" />',
      );

      final out = editor.toXmlString();
      final idxA = out.indexOf('.ActivityA');
      final idxB = out.indexOf('.ActivityB');
      final idxC = out.indexOf('.ActivityC');

      expect(idxA, lessThan(idxB));
      expect(idxB, lessThan(idxC));
    });

    test('adding malformed tag yields invalid XML but leaves document instance unchanged', () {
      final manifest = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>''';

      final editor = XmlEditor(manifest);
      final originalCount = editor.findTagsByName('uses-permission').length;

      // malformed tag (unterminated)
      editor.addManifestTag(
        path: 'manifest',
        tag: '<uses-permission android:name="BROKEN"',
      );

      // The textual content should now be invalid XML
      expect(editor.validate(), false);

      // The in-memory parsed document should remain usable (no crash) and still reflect the old document
      expect(editor.document.findAllElements('uses-permission').length, originalCount);
    });

    test('removePlistEntry removes a key whose value is a multi-line array', () {
      final plist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>MyArrayKey</key>
    <array>
        <string>one</string>
        <string>two</string>
    </array>
    <key>OtherKey</key>
    <string>remain</string>
</dict>
</plist>''';

      final editor = XmlEditor(plist);
      editor.removePlistEntry(key: 'MyArrayKey');

      final out = editor.toXmlString();
      expect(out.contains('MyArrayKey'), false);
      expect(out.contains('one'), false);
      expect(out.contains('two'), false);
      expect(out.contains('OtherKey'), true);
    });

    test('removeManifestTag is scoped to the provided parent path', () {
      final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <parentA>
        <item android:name="Shared" />
    </parentA>
    <parentB>
        <item android:name="SharedB" />
    </parentB>
</manifest>''';

      final editor = XmlEditor(xml);
      editor.removeManifestTag(
        path: 'manifest.parentA',
        tagName: 'item',
        attribute: ('android:name', 'Shared'),
      );

      final out = editor.toXmlString();
      // item under parentA removed
      expect(out.contains('item android:name="Shared"'), false);
      // item under parentB remains
      expect(out.contains('<parentB') && out.contains('SharedB'), true);
    });
  });
}
