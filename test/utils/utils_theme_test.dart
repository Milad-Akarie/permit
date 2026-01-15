import 'package:test/test.dart';
import 'package:permit/utils/utils.dart';

void main() {
  group('UI themes', () {
    test('radioTheme has expected prefixes', () {
      expect(radioTheme.inputPrefix, equals(''));
      expect(radioTheme.activeItemPrefix, equals('❯ ◉'));
      expect(radioTheme.inactiveItemPrefix, equals('  ○'));
    });

    test('checkboxTheme has expected prefixes', () {
      expect(checkboxTheme.checkedItemPrefix, equals('[✓]'));
      expect(checkboxTheme.uncheckedItemPrefix, equals('[ ]'));
      expect(checkboxTheme.inputPrefix, equals(''));
    });

    test('inputTheme has expected prefixes', () {
      expect(inputTheme.inputPrefix, equals(''));
    });
  });
}
