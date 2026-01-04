import 'dart:async';
import 'dart:io';
import 'package:permit/commands/delete_permission_command.dart';
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

  group('DeletePermissionCommand', () {
    test('should have correct name and description', () {
      final command = DeletePermissionCommand();
      expect(command.name, equals('remove'));
      expect(command.description, equals('Remove an existing permission'));
    });

    test('should support all expected flags', () {
      final command = DeletePermissionCommand();
      expect(command.argParser.options.containsKey('android'), isTrue);
      expect(command.argParser.options.containsKey('ios'), isTrue);

      // Check abbreviations
      expect(command.argParser.options['android']?.abbr, equals('a'));
      expect(command.argParser.options['ios']?.abbr, equals('i'));
    });

    test('should have correct default values', () {
      final command = DeletePermissionCommand();
      expect(command.argParser.options['android']?.defaultsTo, isFalse);
      expect(command.argParser.options['ios']?.defaultsTo, isFalse);
    });

    test('should remove Android permission when --android flag is used', () async {
      // Add permission first
      pathFinder.createMockManifest(
        content: '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
  <!-- @permit -->
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
</manifest>
''',
      );

      final runner = PermitRunner(pathFinder)..addCommand(DeletePermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(print: (self, parent, zone, line) => output.writeln(line));

      await runZoned(() async {
        await runner.run(['remove', '--android', 'microphone']);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Removed Android permissions successfully'));
      expect(output.toString(), contains('android.permission.RECORD_AUDIO'));

      // Check the manifest file was updated
      final manifestFile = pathFinder.getManifest()!;
      final content = manifestFile.readAsStringSync();
      expect(content, isNot(contains('android.permission.RECORD_AUDIO')));
      expect(content, contains('android.permission.CAMERA')); // Other permission remains
    });

    test('should remove iOS usage description when --ios flag is used', () async {
      // Add permission first
      pathFinder.createMockInfoPlist(
        content: '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access</string>
  <!-- @permit -->
  <key>NSAppleMusicUsageDescription</key>
  <string>Music access</string>
</dict>
</plist>
''',
      );

      final runner = PermitRunner(pathFinder)..addCommand(DeletePermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(print: (self, parent, zone, line) => output.writeln(line));

      await runZoned(() async {
        await runner.run(['remove', '--ios', 'media']);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Removed iOS permissions successfully'));
      expect(output.toString(), contains('NSAppleMusicUsageDescription'));

      // Check the plist file was updated
      final plistFile = pathFinder.getInfoPlist()!;
      final content = plistFile.readAsStringSync();
      expect(content, isNot(contains('NSAppleMusicUsageDescription')));
      expect(content, contains('NSCameraUsageDescription')); // Other remains
    });

    test('should print error when no files found', () async {
      // Delete files
      File('${pathFinder.root.path}/AndroidManifest.xml').deleteSync();
      File('${pathFinder.root.path}/Info.plist').deleteSync();

      final runner = PermitRunner(pathFinder)..addCommand(DeletePermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(print: (self, parent, zone, line) => output.writeln(line));

      await runZoned(() async {
        await runner.run(['remove', 'microphone']);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Could not locate AndroidManifest.xml or Info.plist'));
    });
  });
}
