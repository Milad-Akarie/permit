import 'package:test/test.dart';
import 'package:permit/xml_editor/xml_editor.dart';

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
        android:name="\\${applicationName}"
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

    group('addTag', () {
      test('should add a uses-permission tag with comments', () {
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
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
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.LOCATION" />',
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.LOCATION'), true);
      });

      test('should add activity child tag to application', () {
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
          path: 'manifest.application',
          tag: '<activity android:name=".SecondActivity" android:exported="false" />',
          comments: ['@permit secondary screen'],
        );

        final result = editor.toXmlString();
        expect(result.contains('.SecondActivity'), true);
        expect(result.contains('@permit secondary screen'), true);
      });

      test('should throw exception for non-existent parent path', () {
        final editor = ManifestEditor(manifestContent);
        expect(
          () => editor.addTag(
            path: 'manifest.nonexistent',
            tag: '<test />',
          ),
          throwsException,
        );
      });

      test('should throw exception for self-closing parent', () {
        final selfClosingManifest = '<manifest />';
        final editor = ManifestEditor(selfClosingManifest);
        expect(
          () => editor.addTag(
            path: 'manifest',
            tag: '<uses-permission android:name="test" />',
          ),
          throwsException,
        );
      });

      test('should preserve XML formatting and indentation', () {
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.READ_CONTACTS" />',
        );

        final result = editor.toXmlString();
        // Check that indentation is preserved
        expect(result.contains('    <uses-permission'), true);
      });
    });

    group('removeTag', () {
      test('should remove a uses-permission tag with comment marker', () {
        final manifestWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!--@permit internet-->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>''';
        final editor = ManifestEditor(manifestWithComments);
        editor.removeTag(
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
        final editor = ManifestEditor(manifestContent);
        editor.removeTag(
          path: 'manifest',
          tagName: 'uses-permission',
          attribute: ('android:name', 'android.permission.INTERNET'),
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.INTERNET'), false);
        expect(result.contains('android.permission.CAMERA'), true);
      });

      test('should throw exception for non-existent tag', () {
        final editor = ManifestEditor(manifestContent);
        expect(
          () => editor.removeTag(
            path: 'manifest',
            tagName: 'uses-permission',
            attribute: ('android:name', 'android.permission.NONEXISTENT'),
          ),
          throwsException,
        );
      });

      test('should throw exception for non-existent parent path', () {
        final editor = ManifestEditor(manifestContent);
        expect(
          () => editor.removeTag(
            path: 'manifest.nonexistent',
            tagName: 'activity',
            attribute: ('android:name', '.MainActivity'),
          ),
          throwsException,
        );
      });

      test('should remove activity from application', () {
        final editor = ManifestEditor(manifestContent);
        editor.removeTag(
          path: 'manifest.application',
          tagName: 'activity',
          attribute: ('android:name', '.MainActivity'),
        );

        final result = editor.toXmlString();
        expect(result.contains('.MainActivity'), false);
        expect(result.contains('android.permission.INTERNET'), true);
      });

      test('should remove service tag', () {
        final editor = ManifestEditor(manifestContent);
        editor.removeTag(
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
        final editor = ManifestEditor(manifestContent);
        final tags = editor.findTagsByName('uses-permission');

        expect(tags.length, 2);
        expect(tags[0].getAttribute('android:name'), 'android.permission.INTERNET');
        expect(tags[1].getAttribute('android:name'), 'android.permission.CAMERA');
      });

      test('should find activity tags', () {
        final editor = ManifestEditor(manifestContent);
        final tags = editor.findTagsByName('activity');

        expect(tags.length, 1);
        expect(tags[0].getAttribute('android:name'), '.MainActivity');
      });

      test('should return empty list for non-existent tag', () {
        final editor = ManifestEditor(manifestContent);
        final tags = editor.findTagsByName('nonexistent');

        expect(tags.length, 0);
      });
    });

    group('findTagsByAttribute', () {
      test('should find tag by attribute name and value', () {
        final editor = ManifestEditor(manifestContent);
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
        final editor = ManifestEditor(multiPerm);
        final tags = editor.findTagsByAttribute(
          tagName: 'uses-permission',
          attributeName: 'android:name',
          attributeValue: 'android.permission.READ_CONTACTS',
        );

        expect(tags.length, 2);
      });

      test('should find tags without specifying tagName', () {
        final editor = ManifestEditor(manifestContent);
        final tags = editor.findTagsByAttribute(
          attributeName: 'android:name',
          attributeValue: '.MainActivity',
        );

        expect(tags.length, 1);
      });

      test('should return empty list for non-matching attribute', () {
        final editor = ManifestEditor(manifestContent);
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
        final editor = ManifestEditor(manifestContent);
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
        final editor = ManifestEditor(multiActivityManifest);
        final activities = editor.findTags(
          path: 'manifest.application',
          name: 'activity',
        );

        expect(activities.length, 3);
      });

      test('should return empty list when path does not exist', () {
        final editor = ManifestEditor(manifestContent);
        final tags = editor.findTags(
          path: 'manifest.nonexistent',
          name: 'activity',
        );

        expect(tags.length, 0);
      });

      test('should return empty list when no tags of specified type exist in path', () {
        final editor = ManifestEditor(manifestContent);
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
        final editor = ManifestEditor(nestedXml);
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
        final editor = ManifestEditor(manifestWithComment);
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
        final editor = ManifestEditor(manifestWithComments);
        final permission = editor.findTagsByName('uses-permission').first;
        final comments = editor.getCommentsOf(permission);

        expect(comments.length, 3);
        expect(comments[0], '@permit internet');
        expect(comments[1], 'Required for API calls');
        expect(comments[2], 'Updated: 2024');
      });

      test('should return empty list for element without comments', () {
        final editor = ManifestEditor(manifestContent);
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
        final editor = ManifestEditor(manifestWithGap);
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
        final editor = ManifestEditor(manifestWithEmptyLines);
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
        final editor = ManifestEditor(manifestWithSpecialChars);
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
        final editor = ManifestEditor(manifestWithNestedComments);
        final activity = editor.findTagsByName('activity').first;
        final comments = editor.getCommentsOf(activity);

        expect(comments.length, 1);
        expect(comments[0], '@permit main activity');
      });

      test('should work with elements that have been added via addTag', () {
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
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
        final editor = ManifestEditor(manifestContent);
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.WRITE_CONTACTS" />',
        );

        expect(editor.validate(), true);
      });

      test('should preserve XML structure after multiple operations', () {
        final editor = ManifestEditor(manifestContent);

        // Add a tag
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.LOCATION" />',
        );
        // Remove a tag
        editor.removeTag(
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

    group('override functionality', () {
      test('should override existing permission with new comments', () {
        final editor = ManifestEditor(manifestContent);

        // Add a permission with initial comments
        editor.addPermission(
          permissionName: 'android.permission.LOCATION',
          comments: ['@permit old location comment'],
        );

        String result = editor.toXmlString();
        expect(result.contains('android.permission.LOCATION'), true);
        expect(result.contains('@permit old location comment'), true);

        // Override with new comments
        editor.addPermission(
          permissionName: 'android.permission.LOCATION',
          comments: ['@permit new location comment', 'Updated for new feature'],
          override: true,
        );

        result = editor.toXmlString();
        expect(result.contains('android.permission.LOCATION'), true);
        expect(result.contains('@permit new location comment'), true);
        expect(result.contains('Updated for new feature'), true);
        expect(result.contains('@permit old location comment'), false);

        // Should only have one LOCATION permission
        final count = result.split('android.permission.LOCATION').length - 1;
        expect(count, equals(1));
      });

      test('should override existing tag with new comments using addTag', () {
        final editor = ManifestEditor(manifestContent);

        // Add a uses-permission with initial comments
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.BLUETOOTH" />',
          comments: ['@permit bluetooth v1'],
        );

        String result = editor.toXmlString();
        expect(result.contains('android.permission.BLUETOOTH'), true);
        expect(result.contains('@permit bluetooth v1'), true);

        // Override with new comments
        editor.addTag(
          path: 'manifest',
          tag: '<uses-permission android:name="android.permission.BLUETOOTH" />',
          comments: ['@permit bluetooth v2', 'Enhanced bluetooth support'],
          override: true,
        );

        result = editor.toXmlString();
        expect(result.contains('android.permission.BLUETOOTH'), true);
        expect(result.contains('@permit bluetooth v2'), true);
        expect(result.contains('Enhanced bluetooth support'), true);
        expect(result.contains('@permit bluetooth v1'), false);

        // Should only have one BLUETOOTH permission
        final count = result.split('android.permission.BLUETOOTH').length - 1;
        expect(count, equals(1));
      });

      test('should override existing feature with new comments', () {
        final manifestWithFeature = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:label="TestApp">
        <!-- @permit camera v1 -->
        <uses-feature android:name="android.hardware.camera" android:required="true" />
    </application>
</manifest>''';

        final editor = ManifestEditor(manifestWithFeature);

        // Override with new comments and different required value
        editor.addFeature(
          name: 'android.hardware.camera',
          required: false,
          comments: ['@permit camera v2', 'Camera is now optional'],
          override: true,
        );

        final result = editor.toXmlString();
        expect(result.contains('android.hardware.camera'), true);
        expect(result.contains('@permit camera v2'), true);
        expect(result.contains('Camera is now optional'), true);
        expect(result.contains('@permit camera v1'), false);
        expect(result.contains('android:required="false"'), true);

        // Should only have one camera feature
        final count = result.split('android.hardware.camera').length - 1;
        expect(count, equals(1));
      });

      test('should not override when override=false', () {
        final editor = ManifestEditor(manifestContent);

        // Add a permission
        editor.addPermission(
          permissionName: 'android.permission.LOCATION',
          comments: ['@permit first location'],
        );

        // Add same permission with override=false (should create duplicate)
        editor.addPermission(
          permissionName: 'android.permission.LOCATION',
          comments: ['@permit second location'],
          override: false,
        );

        final result = editor.toXmlString();
        // Both permissions should exist
        expect(result.contains('@permit first location'), true);
        expect(result.contains('@permit second location'), true);

        // Should have TWO LOCATION permissions
        final count = result.split('android.permission.LOCATION').length - 1;
        expect(count, equals(2));
      });

      test('should remove old @permit comments when overriding', () {
        final manifestWithComments = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- @permit old comment line 1 -->
    <!-- @permit old comment line 2 -->
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>''';

        final editor = ManifestEditor(manifestWithComments);

        // Override with new comments
        editor.addPermission(
          permissionName: 'android.permission.CAMERA',
          comments: ['@permit new camera permission'],
          override: true,
        );

        final result = editor.toXmlString();
        expect(result.contains('android.permission.CAMERA'), true);
        expect(result.contains('@permit new camera permission'), true);
        expect(result.contains('@permit old comment line 1'), false);
        expect(result.contains('@permit old comment line 2'), false);
      });
    });
  });
}
