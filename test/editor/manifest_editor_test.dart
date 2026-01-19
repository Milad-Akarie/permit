import 'package:permit/editor/xml_editor.dart';
import 'package:test/test.dart';

void main() {
  group('ManifestEditor - Adding Permissions', () {
    test('adds camera permission to real Android manifest', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:name=".MainApplication"
        android:label="@string/app_name">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
        comments: [' Camera permission '],
      );

      final result = editor.toString();

      expect(result, contains('android.permission.CAMERA'));
      expect(result, contains('<!-- Camera permission -->'));
      expect(result, contains('android.permission.INTERNET'));
    });

    test('adds multiple permissions in sequence', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);

      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      editor.addPermission(
        name: 'android.permission.WRITE_EXTERNAL_STORAGE',
      );

      final result = editor.toString();
      expect(result, contains('android.permission.CAMERA'));
      expect(result, contains('android.permission.INTERNET'));
      expect(result, contains('android.permission.WRITE_EXTERNAL_STORAGE'));
      // Verify order: permissions should be grouped
      final internetIdx = result.indexOf('android.permission.INTERNET');
      final cameraIdx = result.indexOf('android.permission.CAMERA');
      final storageIdx = result.indexOf(
        'android.permission.WRITE_EXTERNAL_STORAGE',
      );
      expect(internetIdx, lessThan(cameraIdx));
      expect(cameraIdx, lessThan(storageIdx));
    });

    // test adding permission to manifest with no existing permissions
    test('adds permission to manifest with no existing permissions', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">
    <application>
    </application>
</manifest>''';
      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      expect(result, contains('android.permission.CAMERA'));
      // make sure it was added inside the right parent
      expect(editor.getPermissions(), hasLength(1));
    });

    test('preserves manifest structure after adding permission', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:name=".MainApplication">
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      // Verify XML structure is intact
      expect(result, startsWith('<?xml version'));
      expect(result, contains('<manifest'));
      expect(result, contains('xmlns:android'));
      expect(result, contains('package="com.example.app"'));
      expect(result, contains('<application'));
      expect(result, contains('</application>'));
      expect(result, contains('</manifest>'));
    });

    test('replaces existing permission with same name', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      // Should only have one instance of CAMERA permission
      expect(
        RegExp('android.permission.CAMERA').allMatches(result).length,
        equals(1),
      );
      expect(result, contains('android.permission.INTERNET'));
    });

    test('inserts after last uses-permission', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      final cameraIdx = result.indexOf('android.permission.CAMERA');
      final appIdx = result.indexOf('<application>');
      // Camera should be before application (after permissions)
      expect(cameraIdx, lessThan(appIdx));
    });
  });

  group('ManifestEditor - Removing Permissions', () {
    test('removes camera permission from real manifest', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.removePermission(name: 'android.permission.CAMERA');

      final result = editor.toString();
      expect(result, isNot(contains('android.permission.CAMERA')));
      expect(result, contains('android.permission.INTERNET'));
    });

    // adding then removing a permission should leave manifest unchanged
    test('adds then removes permission leaves manifest unchanged', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"> 
    <application>
    </application>
</manifest>''';
      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );
      editor.removePermission(name: 'android.permission.CAMERA');

      final result = editor.toString();
      expect(result, equals(realManifest));
    });

    test('removes permission and its preceding comment', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Camera permission for photos -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.removePermission(
        name: 'android.permission.CAMERA',
        removeComments: (comment) => comment.contains('Camera'),
      );

      final result = editor.toString();
      expect(result, isNot(contains('android.permission.CAMERA')));
      expect(result, isNot(contains('Camera permission for photos')));
      expect(result, contains('android.permission.INTERNET'));
    });

    test('preserves other comments when removing specific permission', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Location permission marker -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <!-- Camera permission marker -->
    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.removePermission(
        name: 'android.permission.CAMERA',
        removeComments: (comment) => comment.contains('Camera'),
      );

      final result = editor.toString();
      expect(result, contains('Location permission marker'));
      expect(result, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(result, isNot(contains('Camera permission marker')));
      expect(result, isNot(contains('android.permission.CAMERA')));
    });

    test('preserves manifest structure after removing permission', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.removePermission(name: 'android.permission.CAMERA');

      final result = editor.toString();
      expect(result, startsWith('<?xml version'));
      expect(result, contains('<manifest'));
      expect(result, contains('xmlns:android'));
      expect(result, contains('package="com.example.app"'));
      expect(result, contains('<application'));
      expect(result, contains('</application>'));
      expect(result, contains('</manifest>'));
      expect(result, contains('android.permission.INTERNET'));
    });

    test('removes multiple permissions one by one', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.removePermission(name: 'android.permission.CAMERA');
      editor.removePermission(
        name: 'android.permission.WRITE_EXTERNAL_STORAGE',
      );

      final result = editor.toString();
      expect(result, isNot(contains('android.permission.CAMERA')));
      expect(
        result,
        isNot(contains('android.permission.WRITE_EXTERNAL_STORAGE')),
      );
      expect(result, contains('android.permission.INTERNET'));
    });
  });

  group('ManifestEditor - Querying Permissions', () {
    test('retrieves all permissions from manifest', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(3));
      expect(permissions[0].key, equals('android.permission.INTERNET'));
      expect(permissions[1].key, equals('android.permission.CAMERA'));
      expect(
        permissions[2].key,
        equals('android.permission.WRITE_EXTERNAL_STORAGE'),
      );
    });

    test('retrieves permissions with associated comments', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Network permission for API calls -->
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Camera for photo capture -->
    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(2));
      expect(permissions[0].comments, isNotEmpty);
      expect(permissions[0].comments[0], contains('Network permission'));
      expect(permissions[1].comments, isNotEmpty);
      expect(permissions[1].comments[0], contains('Camera for photo'));
    });

    test('handles manifest with no permissions', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application>
        <activity android:name=".MainActivity" />
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, isEmpty);
    });

    test('preserves permission order from original manifest', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(
        permissions[0].key,
        equals('android.permission.WRITE_EXTERNAL_STORAGE'),
      );
      expect(permissions[1].key, equals('android.permission.CAMERA'));
      expect(permissions[2].key, equals('android.permission.INTERNET'));
      expect(
        permissions[3].key,
        equals('android.permission.ACCESS_FINE_LOCATION'),
      );
    });

    test('retrieves permissions with multiple preceding comments', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- @permit:code camera -->
    <!-- Camera permission for photo capture -->
    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].comments, hasLength(2));
      expect(permissions[0].comments[0], contains('@permit:code'));
      expect(permissions[0].comments[1], contains('Camera permission'));
    });
  });

  group('ManifestEditor - Format Preservation', () {
    test('preserves original indentation after modifications', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();

      // Should maintain 4-space indentation
      expect(result, contains('    <uses-permission'));
    });

    test('preserves XML namespace declarations', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.example.app">
</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      expect(
        result,
        contains('xmlns:android="http://schemas.android.com/apk/res/android"'),
      );
      expect(
        result,
        contains('xmlns:tools="http://schemas.android.com/tools"'),
      );
      expect(result, contains('package="com.example.app"'));
    });

    test('preserves XML declaration', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();
      expect(result, startsWith('<?xml version="1.0" encoding="utf-8"?>'));
    });

    test('preserves exact spacing and newlines', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <application>
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      final result = editor.toString();

      // Verify structure is intact
      final lines = result.split('\n');
      expect(lines[0], equals('<?xml version="1.0" encoding="utf-8"?>'));
      expect(
        lines[1],
        equals(
          '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
        ),
      );
      expect(lines[2], equals(''));
      expect(lines.contains('</manifest>'), isTrue);
    });

    test('no format changes when querying only', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.getPermissions();

      final result = editor.toString();
      expect(result, equals(realManifest));
    });

    test('preserves format through add and remove operations', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);

      // Add a permission
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );

      // Remove it
      editor.removePermission(name: 'android.permission.CAMERA');

      final result = editor.toString();
      expect(result, contains('android.permission.INTERNET'));
      expect(result, startsWith('<?xml version'));
      expect(result, contains('</manifest>'));
    });
  });

  group('ManifestEditor - Complex Real-world Scenarios', () {
    test('comprehensive example with multiple operations', () {
      const complexManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:name=".MainApplication"
        android:label="@string/app_name">
        <activity android:name=".MainActivity" />
    </application>

</manifest>''';

      final editor = ManifestEditor(complexManifest);

      // Add permissions
      editor.addPermission(
        name: 'android.permission.CAMERA',
      );
      editor.addPermission(
        name: 'android.permission.WRITE_EXTERNAL_STORAGE',
      );
      editor.addPermission(
        name: 'android.permission.ACCESS_FINE_LOCATION',
      );

      // Query all
      var permissions = editor.getPermissions();
      expect(permissions, hasLength(4)); // 1 existing + 3 added

      // Remove one
      editor.removePermission(
        name: 'android.permission.WRITE_EXTERNAL_STORAGE',
      );

      permissions = editor.getPermissions();
      expect(permissions, hasLength(3));

      // Verify structure
      final result = editor.toString();
      expect(result, startsWith('<?xml version'));
      expect(result, contains('package="com.example.app"'));
      expect(result, contains('android.permission.CAMERA'));
      expect(result, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(
        result,
        isNot(contains('android.permission.WRITE_EXTERNAL_STORAGE')),
      );
    });

    test('handles commented permissions correctly', () {
      const manifestWithComments = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- @permit:code location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <!-- @permit:code camera -->
    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(manifestWithComments);

      // Remove with specific comment marker
      editor.removePermission(
        name: 'android.permission.CAMERA',
        removeComments: (comment) => comment.contains('@permit:code camera'),
      );

      final result = editor.toString();
      expect(result, contains('@permit:code location'));
      expect(result, isNot(contains('@permit:code camera')));
      expect(result, contains('android.permission.ACCESS_FINE_LOCATION'));
    });
  });

  group('ManifestEditor - Edge Cases', () {
    test('handles permissions with complex attribute values', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      editor.addPermission(
        name: 'android.permission.BIND_NOTIFICATION_LISTENER_SERVICE',
      );

      final result = editor.toString();
      expect(
        result,
        contains('android.permission.BIND_NOTIFICATION_LISTENER_SERVICE'),
      );
    });

    test('handles manifest with mixed content', () {
      const mixedManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <uses-sdk
        android:minSdkVersion="21"
        android:targetSdkVersion="30" />

    <uses-permission android:name="android.permission.CAMERA" />

    <application>
        <meta-data
            android:name="com.google.android.gms.version"
            android:value="@integer/google_play_services_version" />
    </application>

</manifest>''';

      final editor = ManifestEditor(mixedManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(2));
      expect(permissions[0].key, equals('android.permission.INTERNET'));
      expect(permissions[1].key, equals('android.permission.CAMERA'));
    });

    test('handles empty manifest gracefully', () {
      const emptyManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>''';

      final editor = ManifestEditor(emptyManifest);
      final permissions = editor.getPermissions();

      expect(permissions, isEmpty);

      // Should be able to add permissions
      editor.addPermission(name: 'android.permission.CAMERA');
      final result = editor.toString();
      expect(result, contains('android.permission.CAMERA'));
    });
  });

  group('ManifestEditor - Reading Permissions Edge Cases', () {
    test('retrieves permissions with extra attributes', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" android:maxSdkVersion="28" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals('android.permission.CAMERA'));
    });

    test('retrieves permissions with single quotes', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name='android.permission.CAMERA' />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals('android.permission.CAMERA'));
    });

    test('retrieves permissions with whitespace in attribute value', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name=" android.permission.CAMERA " />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals(' android.permission.CAMERA '));
    });

    test('ignores permissions not directly under manifest', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        <uses-permission android:name="android.permission.CAMERA" />
    </application>

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals('android.permission.INTERNET'));
    });

    test('handles permissions with multiple android:name attributes', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" android:name="android.permission.INTERNET" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals('android.permission.INTERNET'));
    });

    test('handles permissions with empty name attribute', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].key, equals(''));
    });

    test('retrieves permissions with special characters in comments', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Comment with <>&" -->
    <uses-permission android:name="android.permission.CAMERA" />

</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, hasLength(1));
      expect(permissions[0].comments, hasLength(1));
      expect(permissions[0].comments[0], equals(' Comment with <>&" '));
    });

    test('ignores permissions with tools:node="remove" attribute', () {
      const realManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.CAMERA" tools:node="remove" />
</manifest>''';

      final editor = ManifestEditor(realManifest);
      final permissions = editor.getPermissions();

      expect(permissions, isEmpty);
    });
  });
}
