import 'package:test/test.dart';
import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';

void main() {
  group('iOS Swift handler snippets', () {
    test('all registered swiftPermissionHandlers generate valid code', () {
      expect(swiftPermissionHandlers.isNotEmpty, isTrue);

      for (final entry in swiftPermissionHandlers.entries) {
        final key = entry.key;
        final factory = entry.value;
        final handler = factory();

        final code = handler.generate();

        // Basic sanity checks
        expect(code, isNotEmpty, reason: 'Handler $key returned empty code');

        // Should contain the handler class name
        expect(
          code,
          contains('class ${handler.className}'),
          reason:
              'Handler $key did not include class declaration for ${handler.className}',
        );

        // Should contain at least one Swift function keyword or brace from class
        expect(
          code.contains('func ') || code.contains('class ${handler.className}'),
          isTrue,
          reason: 'Handler $key output looks malformed',
        );
      }
    });

    test(
      'location handlers have correct className and constructor forAlways flag',
      () {
        // location (when in use)
        final whenInUseFactory = swiftPermissionHandlers['location'];
        final alwaysFactory = swiftPermissionHandlers['location_always'];

        if (whenInUseFactory != null) {
          final whenInUse = whenInUseFactory();
          expect(whenInUse.className, equals('LocationHandler'));
          expect(whenInUse.constructor, contains('forAlways: false'));
        }

        if (alwaysFactory != null) {
          final always = alwaysFactory();
          expect(always.className, equals('LocationHandler'));
          expect(always.constructor, contains('forAlways: true'));
        }
      },
    );
  });
}
