import 'package:test/test.dart';
import 'package:permit/registry/models.dart';

void main() {
  group('PermissionDef models', () {
    test('AndroidPermissionDef.matches handles full and short keys (case-insensitive)', () {
      const def = AndroidPermissionDef(
        'android.permission.CAMERA',
        runtime: true,
        group: 'camera',
        unifiedName: 'camera',
      );
      expect(def.matches('android.permission.CAMERA'), isTrue);
      expect(def.matches('ANDROID.PERMISSION.CAMERA'), isTrue);
      expect(def.matches('CAMERA'), isTrue);
      expect(def.matches('camera'), isTrue);
      expect(def.matches('android.permission.SOMETHING_ELSE'), isFalse);
    });

    test('AndroidPermissionDef equality and hashCode', () {
      const a = AndroidPermissionDef(
        'android.permission.INTERNET',
        runtime: false,
        group: 'network',
        unifiedName: 'internet',
      );
      const b = AndroidPermissionDef(
        'android.permission.INTERNET',
        runtime: false,
        group: 'network',
        unifiedName: 'internet',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      const c = AndroidPermissionDef(
        'android.permission.INTERNET',
        runtime: true,
        group: 'network',
        unifiedName: 'internet',
      );
      expect(a == c, isFalse);
    });

    test('IosPermissionDef.matches and toString', () {
      const ios = IosPermissionDef('NSCameraUsageDescription', group: 'camera', unifiedName: 'camera');
      expect(ios.matches('NSCameraUsageDescription'), isTrue);
      expect(ios.matches('nscamerausagedescription'), isTrue);
      expect(ios.toString(), equals('NSCameraUsageDescription'));
    });

    test('IosPermissionDef equality and hashCode', () {
      const x = IosPermissionDef(
        'NSFoo',
        group: 'misc',
        minimumIosVersion: '13.0',
        successorOf: 'NSBar',
        unifiedName: 'foo',
      );
      const y = IosPermissionDef(
        'NSFoo',
        group: 'misc',
        minimumIosVersion: '13.0',
        successorOf: 'NSBar',
        unifiedName: 'foo',
      );
      expect(x, equals(y));
      expect(x.hashCode, equals(y.hashCode));
    });
  });
}
