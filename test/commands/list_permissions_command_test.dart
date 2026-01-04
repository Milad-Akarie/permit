import 'package:permit/commands/list_permissions_command.dart';
import 'package:test/test.dart';

void main() {
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
      expect(command.argParser.options.containsKey('quiet'), isTrue);

      // Check abbreviations
      expect(command.argParser.options['android']?.abbr, equals('a'));
      expect(command.argParser.options['ios']?.abbr, equals('i'));
      expect(command.argParser.options['code']?.abbr, equals('c'));
      expect(command.argParser.options['quiet']?.abbr, equals('q'));
    });

    test('should have correct default values', () {
      final command = ListPermissionsCommand();

      expect(command.argParser.options['android']?.defaultsTo, isFalse);
      expect(command.argParser.options['ios']?.defaultsTo, isFalse);
      expect(command.argParser.options['code']?.defaultsTo, isFalse);
      expect(command.argParser.options['quiet']?.defaultsTo, isFalse);
    });
  });
}
