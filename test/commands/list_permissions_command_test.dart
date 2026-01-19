import 'dart:async';
import 'dart:io';

import 'package:permit/commands/list_permissions_command.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late MockPathFinder pathFinder;
  setUp(() {
    final tempDir = Directory.systemTemp.createTempSync('permit_test_');
    pathFinder = MockPathFinder(tempDir);
    pathFinder.createMockManifest();
    pathFinder.createMockInfoPlist();
  });

  tearDown(() {
    pathFinder.root.deleteSync(recursive: true);
  });

  group('ListPermissionsCommand', () {
    test('should have correct name and description', () {
      final command = ListPermissionsCommand();
      expect(command.name, equals('list'));
      expect(command.description, equals('List all existing permissions'));
    });

    test('should support all expected flags', () {
      final command = ListPermissionsCommand();
      expect(command.argParser.options.containsKey('android'), isTrue);
      expect(command.argParser.options.containsKey('ios'), isTrue);
      expect(command.argParser.options.containsKey('code'), isTrue);

      // Check abbreviations
      expect(command.argParser.options['android']?.abbr, equals('a'));
      expect(command.argParser.options['ios']?.abbr, equals('i'));
      expect(command.argParser.options['code']?.abbr, equals('c'));
    });

    test('should have correct default values', () {
      final command = ListPermissionsCommand();
      expect(command.argParser.options['android']?.defaultsTo, isFalse);
      expect(command.argParser.options['ios']?.defaultsTo, isFalse);
      expect(command.argParser.options['code']?.defaultsTo, isFalse);
    });

    test(
      'should list Android permissions when manifest has permissions',
      () async {
        pathFinder.createMockManifest(
          content: '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
''',
        );

        final runner = PermitRunner(pathFinder)
          ..addCommand(ListPermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) => output.writeln(line),
        );

        await runZoned(() async {
          await runner.run(['list']);
        }, zoneSpecification: spec);

        expect(output.toString(), contains('Uses Permissions (2):'));
        expect(output.toString(), contains('android.permission.CAMERA'));
        expect(
          output.toString(),
          contains('android.permission.ACCESS_FINE_LOCATION'),
        );
        expect(output.toString(), isNot(contains('Usage Descriptions')));
      },
    );

    test(
      'should list iOS usage descriptions when plist has descriptions',
      () async {
        pathFinder.createMockInfoPlist(
          content: '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Location access</string>
</dict>
</plist>
''',
        );

        final runner = PermitRunner(pathFinder)
          ..addCommand(ListPermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) => output.writeln(line),
        );

        await runZoned(() async {
          await runner.run(['list']);
        }, zoneSpecification: spec);

        expect(output.toString(), contains('Usage Descriptions (2):'));
        expect(output.toString(), contains('NSCameraUsageDescription'));
        expect(output.toString(), contains('Camera access'));
        expect(
          output.toString(),
          contains('NSLocationWhenInUseUsageDescription'),
        );
        expect(output.toString(), contains('Location access'));
        expect(output.toString(), isNot(contains('Uses Permissions')));
      },
    );

    test('should filter to Android only when --android flag is used', () async {
      pathFinder.createMockManifest(
        content: '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
</manifest>
''',
      );
      pathFinder.createMockInfoPlist(
        content: '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access</string>
</dict>
</plist>
''',
      );

      final runner = PermitRunner(pathFinder)
        ..addCommand(ListPermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) => output.writeln(line),
      );

      await runZoned(() async {
        await runner.run(['list', '--android']);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Uses Permissions'));
      expect(output.toString(), contains('android.permission.CAMERA'));
      expect(output.toString(), isNot(contains('Usage Descriptions')));
    });

    test('should filter to iOS only when --ios flag is used', () async {
      pathFinder.createMockManifest(
        content: '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
</manifest>
''',
      );
      pathFinder.createMockInfoPlist(
        content: '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access</string>
</dict>
</plist>
''',
      );

      final runner = PermitRunner(pathFinder)
        ..addCommand(ListPermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) => output.writeln(line),
      );

      await runZoned(() async {
        await runner.run(['list', '--ios']);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Usage Descriptions'));
      expect(output.toString(), contains('NSCameraUsageDescription'));
      expect(output.toString(), isNot(contains('Uses Permissions')));
    });

    test(
      'should show only permissions that generate code when --code flag is used',
      () async {
        pathFinder.createMockManifest(
          content: '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- @permit:code -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
''',
        );
        pathFinder.createMockInfoPlist(
          content: '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <!-- @permit:code -->
  <key>NSCameraUsageDescription</key>
  <string>Camera access</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Location access</string>
</dict>
</plist>
''',
        );

        final runner = PermitRunner(pathFinder)
          ..addCommand(ListPermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) => output.writeln(line),
        );

        await runZoned(() async {
          await runner.run(['list', '--code']);
        }, zoneSpecification: spec);

        expect(output.toString(), contains('Uses Permissions (1):'));
        expect(output.toString(), contains('android.permission.CAMERA'));
        expect(output.toString(), contains('[CODE]'));
        expect(
          output.toString(),
          isNot(contains('android.permission.ACCESS_FINE_LOCATION')),
        );
        expect(output.toString(), contains('Usage Descriptions (1):'));
        expect(output.toString(), contains('NSCameraUsageDescription'));
        expect(output.toString(), contains('Camera access'));
        expect(output.toString(), contains('[CODE]'));
        expect(
          output.toString(),
          isNot(contains('NSLocationWhenInUseUsageDescription')),
        );
      },
    );

    test('should print error when no files are found', () async {
      // Delete the created files to simulate no files
      File('${pathFinder.root.path}/AndroidManifest.xml').deleteSync();
      File('${pathFinder.root.path}/ios/Runner/Info.plist').deleteSync();

      final runner = PermitRunner(pathFinder)
        ..addCommand(ListPermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) => output.writeln(line),
      );

      await runZoned(() async {
        await runner.run(['list']);
      }, zoneSpecification: spec);

      expect(
        output.toString(),
        contains('Could not locate AndroidManifest.xml or Info.plist'),
      );
    });
  });
}
