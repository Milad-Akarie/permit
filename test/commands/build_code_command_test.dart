import 'package:permit/commands/build_code_command.dart';
import 'package:test/test.dart';

void main() {
  group('BuildCodeCommand', () {
    test('should have correct name and description', () {
      final command = BuildCodeCommand();
      expect(command.name, equals('build'));
      expect(
        command.description,
        equals('Synchronize permissions metadata and generated code'),
      );
    });
  });
}
