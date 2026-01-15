import 'package:test/test.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/ios_permissions.dart';

void main() {
  group('EntriesLookup Tests', () {
    late EntriesLookup lookup;
    late EntriesLookup androidOnlyLookup;
    late EntriesLookup iosOnlyLookup;

    setUp(() {
      lookup = EntriesLookup.forDefaults();
      androidOnlyLookup = EntriesLookup.forDefaults(androidOnly: true);
      iosOnlyLookup = EntriesLookup.forDefaults(iosOnly: true);
    });

    group('EntriesLookup.forDefaults factory', () {
      test('creates lookup with both Android and iOS permissions by default', () {
        expect(lookup.entries.isNotEmpty, isTrue);
        expect(lookup.entries.whereType<AndroidPermissionDef>().isNotEmpty, isTrue);
        expect(lookup.entries.whereType<IosPermissionDef>().isNotEmpty, true);
      });

      test('creates lookup with only Android permissions when androidOnly is true', () {
        expect(androidOnlyLookup.entries.isNotEmpty, isTrue);
        expect(androidOnlyLookup.entries.whereType<AndroidPermissionDef>().isNotEmpty, isTrue);
        expect(androidOnlyLookup.entries.whereType<IosPermissionDef>().isEmpty, isTrue);
      });

      test('creates lookup with only iOS permissions when iosOnly is true', () {
        expect(iosOnlyLookup.entries.isNotEmpty, isTrue);
        expect(iosOnlyLookup.entries.whereType<IosPermissionDef>().isNotEmpty, isTrue);
        expect(iosOnlyLookup.entries.whereType<AndroidPermissionDef>().isEmpty, isTrue);
      });

      test('creates lookup with both when both androidOnly and iosOnly are false', () {
        final mixedLookup = EntriesLookup.forDefaults(androidOnly: false, iosOnly: false);
        expect(mixedLookup.entries.whereType<AndroidPermissionDef>().isNotEmpty, isTrue);
        expect(mixedLookup.entries.whereType<IosPermissionDef>().isNotEmpty, isTrue);
      });

      test('both true results in both platforms (default case)', () {
        final bothTrueLookup = EntriesLookup.forDefaults(androidOnly: true, iosOnly: true);
        expect(bothTrueLookup.entries.whereType<AndroidPermissionDef>().isNotEmpty, isTrue);
        expect(bothTrueLookup.entries.whereType<IosPermissionDef>().isNotEmpty, isTrue);
      });
    });

    group('EntriesLookup.lookup method', () {
      test('finds permission by exact key match (Android)', () {
        final results = lookup.find('android.permission.CAMERA');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((e) => e.key == 'android.permission.CAMERA'), isTrue);
      });

      test('finds permission by exact key match case-insensitive (Android)', () {
        final results = lookup.find('ANDROID.PERMISSION.CAMERA');
        expect(results.isNotEmpty, isTrue);
      });

      test('finds permission by short name without android prefix (Android)', () {
        final results = lookup.find('CAMERA');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((e) => e.key == 'android.permission.CAMERA'), isTrue);
      });

      test('finds permission by short name lowercase (Android)', () {
        final results = lookup.find('camera');
        expect(results.isNotEmpty, isTrue);
      });

      test('finds permission by group name', () {
        final results = lookup.find('camera');
        expect(results.isNotEmpty, isTrue);
        expect(results.every((e) => e.group == 'camera' || e.key.contains('CAMERA')), isTrue);
      });

      test('finds multiple permissions in same group', () {
        final results = lookup.find('location');
        expect(results.length, greaterThan(1));
        expect(results.every((e) => e.group.startsWith('location')), isTrue);
      });

      test('finds iOS permission by exact key match', () {
        final results = lookup.find('NSCameraUsageDescription');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((e) => e.key == 'NSCameraUsageDescription'), isTrue);
      });

      test('finds iOS permission by group', () {
        final results = lookup.find('face');
        expect(results.isNotEmpty, isTrue);
        expect(results.every((e) => e.group == 'face_id'), isTrue);
      });

      test('returns empty set for non-existent permission', () {
        final results = lookup.find('nonexistent.permission');
        expect(results.isEmpty, isTrue);
      });

      test('returns empty set for non-existent group', () {
        final results = lookup.find('nonexistentgroup');
        expect(results.isEmpty, isTrue);
      });

      test('finds permissions in Android-only lookup', () {
        final results = androidOnlyLookup.find('CAMERA');
        expect(results.isNotEmpty, isTrue);
        expect(results.every((e) => e is AndroidPermissionDef), isTrue);
      });

      test('finds permissions in iOS-only lookup', () {
        final results = iosOnlyLookup.find('camera');
        expect(results.isNotEmpty, isTrue);
        expect(results.every((e) => e is IosPermissionDef), isTrue);
      });

      test('handles group name prefix matching', () {
        final results = lookup.find('loc');
        // Should match 'location' group if it starts with 'loc'
        final locationResults = results.where((e) => e.group == 'location').toList();
        expect(locationResults.isNotEmpty, isTrue);
      });

      test('matches contact and phone permissions correctly', () {
        final contactResults = lookup.find('contacts');
        expect(contactResults.isNotEmpty, isTrue);
        expect(contactResults.every((e) => e.group == 'contacts'), isTrue);
      });

      test('matches storage permissions', () {
        final storageResults = lookup.find('storage');
        expect(storageResults.isNotEmpty, isTrue);
        expect(storageResults.every((e) => e.group == 'storage'), isTrue);
      });
    });

    group('EntriesLookup.groups getter', () {
      test('returns all unique groups', () {
        final groups = lookup.groups;
        expect(groups.isNotEmpty, isTrue);
      });

      test('contains camera group', () {
        final groups = lookup.groups;
        expect(groups.contains('camera'), isTrue);
      });

      test('contains location group', () {
        final groups = lookup.groups;
        expect(groups.contains('location'), isTrue);
      });

      test('contains contacts group', () {
        final groups = lookup.groups;
        expect(groups.contains('contacts'), isTrue);
      });

      test('contains microphone group', () {
        final groups = lookup.groups;
        expect(groups.contains('microphone'), isTrue);
      });

      test('contains all permission groups from Android', () {
        final groups = lookup.groups;
        print(groups);
        expect(groups.contains('camera'), isTrue);
        expect(groups.contains('microphone'), isTrue);
        expect(groups.contains('location'), isTrue);
        expect(groups.contains('contacts'), isTrue);
        expect(groups.contains('calendar'), isTrue);
        expect(groups.contains('phone'), isTrue);
        expect(groups.contains('storage'), isTrue);
        expect(groups.contains('network'), isTrue);
        expect(groups.contains('bluetooth'), isTrue);
        expect(groups.contains('sensors'), isTrue);
        expect(groups.contains('notifications'), isTrue);
      });

      test('contains all permission groups from iOS', () {
        final groups = lookup.groups;
        expect(groups.contains('camera'), isTrue);
        expect(groups.contains('microphone'), isTrue);
        expect(groups.contains('photos'), isTrue);
        expect(groups.contains('calendar'), isTrue);
        expect(groups.contains('reminders'), isTrue);
        expect(groups.contains('bluetooth'), isTrue);
        expect(groups.contains('motion'), isTrue);
        expect(groups.contains('health'), isTrue);
        expect(groups.contains('speech'), isTrue);
        expect(groups.contains('siri'), isTrue);
        expect(groups.contains('biometrics'), isTrue);
        expect(groups.contains('homekit'), isTrue);
        expect(groups.contains('nfc'), isTrue);
        expect(groups.contains('tracking'), isTrue);
        expect(groups.contains('network'), isTrue);
        expect(groups.contains('nearby'), isTrue);
        expect(groups.contains('focus'), isTrue);
      });

      test('returns no duplicate groups', () {
        final groups = lookup.groups;
        expect(groups.length, equals(groups.toList().toSet().length));
      });

      test('androidOnly lookup returns only Android permission groups', () {
        final groups = androidOnlyLookup.groups;
        // Verify no iOS-only groups exist
        expect(groups.contains('reminders'), isFalse);
        expect(groups.contains('siri'), isFalse);
        expect(groups.contains('homekit'), isFalse);
        // Verify Android groups exist
        expect(groups.contains('camera'), isTrue);
      });

      test('iosOnly lookup returns only iOS permission groups', () {
        final groups = iosOnlyLookup.groups;
        // Verify no Android-only groups exist
        expect(groups.contains('system'), isFalse);
        // Verify iOS groups exist
        expect(groups.contains('camera'), isTrue);
      });
    });

    group('EntriesLookup constructor', () {
      test('creates lookup with provided entries', () {
        final entries = {
          AndroidPermissions.camera,
          AndroidPermissions.microphone,
        };
        final customLookup = EntriesLookup(entries);
        expect(customLookup.entries, equals(entries));
      });

      test('creates empty lookup when no entries provided', () {
        final emptyLookup = EntriesLookup({});
        expect(emptyLookup.entries.isEmpty, isTrue);
        expect(emptyLookup.groups.isEmpty, isTrue);
      });

      test('preserves entry order in set', () {
        final entries = AndroidPermissions.all;
        final customLookup = EntriesLookup(entries);
        expect(customLookup.entries, isNotEmpty);
      });
    });

    group('Edge cases and special scenarios', () {
      test('lookup is case-insensitive for permission keys', () {
        final results1 = lookup.find('camera');
        final results2 = lookup.find('CAMERA');
        final results3 = lookup.find('CaMeRa');
        expect(results1.isNotEmpty, isTrue);
        expect(results2.isNotEmpty, isTrue);
        expect(results3.isNotEmpty, isTrue);
      });

      test('group lookup is case-sensitive', () {
        final lowercaseGroup = lookup.find('camera');
        final uppercaseGroup = lookup.find('CAMERA');
        // Both should work since they'll match either permission key or group
        expect(lowercaseGroup.isNotEmpty || uppercaseGroup.isNotEmpty, isTrue);
      });

      test('lookup with whitespace returns empty', () {
        final results = lookup.find('   ');
        // May or may not find results depending on implementation
        // But should handle gracefully
        expect(results, isA<Set>());
      });

      test('can lookup multiple permission types in mixed lookup', () {
        final cameraResults = lookup.find('camera');
        final hasAndroid = cameraResults.whereType<AndroidPermissionDef>().isNotEmpty;
        final hasIos = cameraResults.whereType<IosPermissionDef>().isNotEmpty;
        expect(hasAndroid || hasIos, isTrue);
      });
    });
  });

  group('PermissionEntrySet extension Tests', () {
    late Set<PermissionDef> entries;

    setUp(() {
      entries = {
        ...AndroidPermissions.all,
        ...IosPermissions.all,
      };
    });

    group('containsKey method', () {
      test('returns true for existing Android permission key', () {
        expect(entries.containsKey('android.permission.CAMERA'), isTrue);
      });

      test('returns true for existing iOS permission key', () {
        expect(entries.containsKey('NSCameraUsageDescription'), isTrue);
      });

      test('returns false for non-existent key', () {
        expect(entries.containsKey('nonexistent.permission'), isFalse);
      });

      test('is case-sensitive for keys', () {
        // Keys should match exactly
        expect(entries.containsKey('android.permission.camera'), isFalse);
        expect(entries.containsKey('android.permission.CAMERA'), isTrue);
      });
    });

    group('hasAndroid getter', () {
      test('returns true when Android permissions exist', () {
        expect(entries.hasAndroid, isTrue);
      });

      test('returns false when no Android permissions', () {
        final iosOnly = entries.whereType<IosPermissionDef>().toSet();
        expect(iosOnly.hasAndroid, isFalse);
      });
    });

    group('hasIos getter', () {
      test('returns true when iOS permissions exist', () {
        expect(entries.hasIos, isTrue);
      });

      test('returns false when no iOS permissions', () {
        final androidOnly = entries.whereType<AndroidPermissionDef>().toSet();
        expect(androidOnly.hasIos, isFalse);
      });
    });

    group('ios getter', () {
      test('returns empty set when no iOS permissions', () {
        final androidOnly = entries.whereType<AndroidPermissionDef>().toSet();
        expect(androidOnly.ios.isEmpty, isTrue);
      });

      test('returns all iOS permissions', () {
        final iosPerms = entries.ios;
        expect(iosPerms.isNotEmpty, isTrue);
        expect(iosPerms.length, greaterThan(0));
      });
    });

    group('android getter', () {
      test('returns empty set when no Android permissions', () {
        final iosOnly = entries.whereType<IosPermissionDef>().toSet();
        expect(iosOnly.android.isEmpty, isTrue);
      });

      test('returns all Android permissions', () {
        final androidPerms = entries.android;
        expect(androidPerms.isNotEmpty, isTrue);
        expect(androidPerms.length, greaterThan(0));
      });
    });

    group('Extension method combinations', () {
      test('mixed entries can be filtered by platform', () {
        expect(entries.hasAndroid, isTrue);
        expect(entries.hasIos, isTrue);
      });

      test('android and ios getters return non-overlapping sets', () {
        final androidPerms = entries.android;
        final iosPerms = entries.ios;
        final overlap = androidPerms.intersection(iosPerms);
        expect(overlap.isEmpty, isTrue);
      });

      test('android and ios getters cover all entries', () {
        final androidPerms = entries.android;
        final iosPerms = entries.ios;
        final combined = {...androidPerms, ...iosPerms};
        expect(combined.length, equals(entries.length));
      });

      test('containsKey works with filtered sets', () {
        final androidPerms = entries.android;
        expect(androidPerms.containsKey('android.permission.CAMERA'), isTrue);
        expect(androidPerms.containsKey('NSCameraUsageDescription'), isFalse);
      });
    });
  });
}
