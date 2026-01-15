import 'package:test/test.dart';
import 'package:permit/registry/models.dart';

void main() {
  group('AndroidPermissionDef', () {
    test('matches full key and short key case-insensitive', () {
      final def = AndroidPermissionDef('android.permission.CAMERA', group: 'camera');
      expect(def.matches('android.permission.CAMERA'), isTrue);
      expect(def.matches('camera'), isTrue);
      expect(def.matches('Camera'), isTrue);
      expect(def.matches('android.permission.camera'), isTrue);
      expect(def.matches('somethingelse'), isFalse);
    });

    test('promptNote returns API sinceSDK when set', () {
      final def = AndroidPermissionDef('android.permission.SOMETHING', group: 'misc', sinceSDK: 21);
      expect(def.promptNote, equals('API 21+'));

      final def2 = AndroidPermissionDef('android.permission.SOMETHING', group: 'misc');
      expect(def2.promptNote, isNull);
    });
  });

  group('IosPermissionDef', () {
    test('toString returns key and matches is case-insensitive', () {
      final def = IosPermissionDef('NSCameraUsageDescription', group: 'camera');
      expect(def.toString(), equals('NSCameraUsageDescription'));
      expect(def.matches('nscamerause'), isFalse);
      expect(def.matches('NSCameraUsageDescription'), isTrue);
      // verify case-insensitivity using actual key
      expect(def.matches(def.key.toUpperCase()), isTrue);
    });

    test('promptNote for sinceApi > 10', () {
      final def = IosPermissionDef('NSFoo', group: 'foo', sinceApi: 13.0);
      expect(def.promptNote, equals('iOS 13+'));

      final def2 = IosPermissionDef('NSBar', group: 'bar', sinceApi: 9.0);
      expect(def2.promptNote, isNull);
    });

    test('promptNote for untilApi shows deprecated', () {
      final def = IosPermissionDef('NSOld', group: 'old', untilApi: 12.0);
      expect(def.isDeprecated, isTrue);
      expect(def.promptNote, equals('deprecated, ios < 12'));
    });

    test('equality and hashCode', () {
      final a = IosPermissionDef('NSX', group: 'g', scope: AccessScope.writeOnly, sinceApi: 11.0);
      final b = IosPermissionDef('NSX', group: 'g', scope: AccessScope.writeOnly, sinceApi: 11.0);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('AssociatedService', () {
    test('toString capitalizes name and platform support checks', () {
      expect(AssociatedService.location.toString(), equals('Location'));
      expect(AssociatedService.location.isAndroidSupported, isTrue);
      expect(AssociatedService.location.isIosSupported, isTrue);

      expect(AssociatedService.phone.toString(), equals('Phone'));
      expect(AssociatedService.phone.isAndroidSupported, isTrue);
      expect(AssociatedService.phone.isIosSupported, isFalse);
    });
  });
}
