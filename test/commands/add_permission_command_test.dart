import 'dart:async';
import 'dart:io';

import 'package:permit/commands/add_permission_command.dart';
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

  group('AddPermissionCommand', () {
    test('should have correct name and description', () {
      final command = AddPermissionCommand();
      expect(command.name, equals('add'));
      expect(command.description, equals('Add a new permission'));
    });

    test('should support all expected options and flags', () {
      final command = AddPermissionCommand();
      expect(command.argParser.options.containsKey('desc'), isTrue);
      expect(command.argParser.options.containsKey('code'), isTrue);
      expect(command.argParser.options.containsKey('android'), isTrue);
      expect(command.argParser.options.containsKey('ios'), isTrue);

      // Check abbreviations
      expect(command.argParser.options['desc']?.abbr, equals('d'));
      expect(command.argParser.options['code']?.abbr, equals('c'));
      expect(command.argParser.options['android']?.abbr, equals('a'));
      expect(command.argParser.options['ios']?.abbr, equals('i'));
    });

    test('should have correct default values', () {
      final command = AddPermissionCommand();
      expect(command.argParser.options['desc']?.defaultsTo, equals(''));
      expect(command.argParser.options['code']?.defaultsTo, isFalse);
      expect(command.argParser.options['android']?.defaultsTo, isFalse);
      expect(command.argParser.options['ios']?.defaultsTo, isFalse);
    });

    test('should add Android permission when --android flag is used', () async {
      final runner = PermitRunner(pathFinder)
        ..addCommand(AddPermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(() async {
        await runner.run([
          'add',
          '--android',
          'android.permission.RECORD_AUDIO',
        ]);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Added Android permission'));
      expect(output.toString(), contains('android.permission.RECORD_AUDIO'));

      // Check the manifest file was updated
      final manifestFile = pathFinder.getManifest()!;
      final content = manifestFile.readAsStringSync();
      expect(content, contains('android.permission.RECORD_AUDIO'));
      expect(content, contains('@permit'));
    });

    test(
      'should add iOS usage description when --ios flag is used with desc',
      () async {
        final runner = PermitRunner(pathFinder)
          ..addCommand(AddPermissionCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) => output.writeln(line),
        );

        await runZoned(() async {
          await runner.run([
            'add',
            '--ios',
            '--desc',
            'Microphone access for recording',
            'NSMicrophoneUsageDescription',
          ]);
        }, zoneSpecification: spec);

        expect(output.toString(), contains('Added iOS usage description'));
        expect(output.toString(), contains('NSMicrophoneUsageDescription'));

        // Check the plist file was updated
        final plistFile = pathFinder.getInfoPlist()!;
        final content = plistFile.readAsStringSync();
        expect(content, contains('NSMicrophoneUsageDescription'));
        expect(content, contains('Microphone access for recording'));
        expect(content, contains('@permit'));
      },
    );

    test(
      'should add permission with code generation when --code flag is used',
      () async {
        final runner = PermitRunner(pathFinder)
          ..addCommand(AddPermissionCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) => output.writeln(line),
        );

        await runZoned(() async {
          await runner.run([
            'add',
            '--android',
            '--code',
            'android.permission.RECORD_AUDIO',
          ]);
        }, zoneSpecification: spec);

        expect(output.toString(), contains('Added Android permission'));
        expect(output.toString(), contains('android.permission.RECORD_AUDIO'));

        // Check the manifest file has @permit:code
        final manifestFile = pathFinder.getManifest()!;
        final content = manifestFile.readAsStringSync();
        expect(content, contains('@permit:code'));
      },
    );

    test('should print error when no manifest found for Android', () async {
      // Delete manifest
      File('${pathFinder.root.path}/AndroidManifest.xml').deleteSync();

      final runner = PermitRunner(pathFinder)
        ..addCommand(AddPermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) => output.writeln(line),
      );

      await runZoned(() async {
        await runner.run([
          'add',
          '--android',
          'android.permission.RECORD_AUDIO',
        ]);
      }, zoneSpecification: spec);

      expect(
        output.toString(),
        contains('Could not locate AndroidManifest.xml'),
      );
    });

    test('should print error when no plist found for iOS', () async {
      // Delete plist
      File('${pathFinder.root.path}/ios/Runner/Info.plist').deleteSync();

      final runner = PermitRunner(pathFinder)
        ..addCommand(AddPermissionCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) => output.writeln(line),
      );

      await runZoned(() async {
        await runner.run([
          'add',
          '--ios',
          '--desc',
          'test',
          'NSMicrophoneUsageDescription',
        ]);
      }, zoneSpecification: spec);

      expect(output.toString(), contains('Could not locate Info.plist'));
    });
  });
}
