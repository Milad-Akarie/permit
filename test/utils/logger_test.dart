import 'dart:async';
import 'package:test/test.dart';
import 'package:permit/utils/logger.dart';

void main() {
  group('Logger', () {
    test('log prints messages at or above set level', () {
      final printed = <String>[];
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      );

      // Set level to warning to suppress info and below
      Logger.level = LogLevel.warning;

      runZoned(() {
        Logger.info('this should NOT appear');
        Logger.warning('this should appear');
        Logger.error('error happened');
      }, zoneSpecification: spec);

      expect(printed.any((s) => s.contains('this should NOT appear')), isFalse);
      expect(printed.any((s) => s.contains('this should appear')), isTrue);
      expect(printed.any((s) => s.contains('error happened')), isTrue);

      // Reset to default
      Logger.level = LogLevel.info;
    });

    test('platform helpers print with prefix', () {
      final printed = <String>[];
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      );

      runZoned(() {
        Logger.android('hello android');
        Logger.ios('hello ios');
        Logger.listed('item');
      }, zoneSpecification: spec);

      expect(printed.any((s) => s.contains('Android:') && s.contains('hello android')), isTrue);
      expect(printed.any((s) => s.contains('iOS:') && s.contains('hello ios')), isTrue);
      expect(printed.any((s) => s.contains('- item')), isTrue);
    });
  });
}
