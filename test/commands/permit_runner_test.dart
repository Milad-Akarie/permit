import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:test/test.dart';

import 'helpers.dart';

class MockPermitCommand extends PermitCommand {
  @override
  String get name => 'mock';

  @override
  String get description => 'Mock command';

  @override
  Future<void> run() async {
    // Access pathFinder to test the getter
    pathFinder;
  }
}

void main() {
  group('PermitRunner', () {
    late MockPathFinder pathFinder;

    setUp(() {
      pathFinder = MockPathFinder(Directory.systemTemp);
    });

    test('should initialize with correct name and description', () {
      final runner = PermitRunner(pathFinder);
      expect(runner.executableName, equals('permit'));
      expect(
        runner.description,
        equals('A CLI tool to manage native app permissions'),
      );
    });

    test('should provide pathFinder to commands', () async {
      final runner = PermitRunner(pathFinder);
      final command = MockPermitCommand();
      runner.addCommand(command);

      // Verify command has access to pathFinder when run by PermitRunner
      await runner.run(['mock']);
      expect(command.pathFinder, equals(pathFinder));
    });
  });

  group('PermitCommand', () {
    test('should throw StateError if runner is not PermitRunner', () {
      final command = MockPermitCommand();
      // Add to standard CommandRunner, not PermitRunner
      final runner = CommandRunner('test', 'test description')
        ..addCommand(command);

      expect(
        () => runner.run(['mock']),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Runner is not a PermitRunner'),
          ),
        ),
      );
    });
  });
}
