import 'package:permit/editor/models.dart';
import 'package:test/test.dart';

void main() {
  group('PListUsageDescription', () {
    test('equality should work correctly', () {
      final desc1 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );
      final desc2 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );
      final desc3 = PListUsageDescription(
        key: 'NSMicrophoneUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );
      final desc4 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Different description',
        comments: ['@permit'],
      );
      final desc5 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@other'],
      );

      expect(desc1, equals(desc2));
      expect(desc1, isNot(equals(desc3)));
      expect(desc1, isNot(equals(desc4)));
      expect(desc1, isNot(equals(desc5)));
    });

    test('hashCode should work correctly', () {
      final desc1 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );
      final desc2 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );

      expect(desc1.hashCode, equals(desc2.hashCode));
    });

    test('toString should return correct format', () {
      final desc = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );
      expect(
        desc.toString(),
        equals(
          '(key: NSCameraUsageDescription, description: Camera access, comments: [@permit])',
        ),
      );
    });

    test('generatesCode should return true when @permit:code is present', () {
      final desc = PListUsageDescription(
        key: 'key',
        description: 'desc',
        comments: ['@permit:code'],
      );
      expect(desc.generatesCode, isTrue);
    });

    test('generatesCode should return false when @permit:code is absent', () {
      final desc = PListUsageDescription(
        key: 'key',
        description: 'desc',
        comments: ['@permit'],
      );
      expect(desc.generatesCode, isFalse);
    });

    test('isLegacy should return true when @permit:legacy is present', () {
      final desc = PListUsageDescription(
        key: 'key',
        description: 'desc',
        comments: ['@permit:legacy'],
      );
      expect(desc.isLegacy, isTrue);
    });
  });

  group('ManifestPermissionEntry', () {
    test('equality should work correctly', () {
      final entry1 = ManifestPermissionEntry(
        key: 'android.permission.CAMERA',
        comments: ['@permit'],
      );
      final entry2 = ManifestPermissionEntry(
        key: 'android.permission.CAMERA',
        comments: ['@permit'],
      );
      final entry3 = ManifestPermissionEntry(
        key: 'android.permission.INTERNET',
        comments: ['@permit'],
      );
      final entry4 = ManifestPermissionEntry(
        key: 'android.permission.CAMERA',
        comments: ['@other'],
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
      expect(entry1, isNot(equals(entry4)));
    });

    test('hashCode should work correctly', () {
      final entry1 = ManifestPermissionEntry(
        key: 'android.permission.CAMERA',
        comments: ['@permit'],
      );
      final entry2 = ManifestPermissionEntry(
        key: 'android.permission.CAMERA',
        comments: ['@permit'],
      );

      expect(entry1.hashCode, equals(entry2.hashCode));
    });
  });
}
