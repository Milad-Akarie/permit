import 'package:test/test.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';

void main() {
  group('IosPermissions defaults', () {
    test('camera permission has default (null) minimumIosVersion and default scope', () {
      final p = IosPermissions.camera;
      expect(p.key, equals('NSCameraUsageDescription'));
      expect(p.group, equals('camera'));
      expect(p.scope, equals(AccessScope.standardOrFull));
    });

    test('photoLibraryAdd has a minimumIosVersion set', () {
      final p = IosPermissions.photoLibraryAdd;
      expect(p.key, equals('NSPhotoLibraryAddUsageDescription'));
      expect(p.scope, equals(AccessScope.standardOrFull));
    });

    test('calendarsWriteOnly has writeOnly scope and minimumIosVersion', () {
      final p = IosPermissions.calendarsWriteOnly;
      expect(p.key, contains('CalendarsWriteOnly'));
      expect(p.scope, equals(AccessScope.writeOnly));
    });

    test('microphone permission defaults', () {
      final p = IosPermissions.microphone;
      expect(p.key, 'NSMicrophoneUsageDescription');
      expect(p.group, 'microphone');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('contacts permission defaults', () {
      final p = IosPermissions.contacts;
      expect(p.key, 'NSContactsUsageDescription');
      expect(p.group, 'contacts');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationWhenInUse permission defaults', () {
      final p = IosPermissions.locationWhenInUse;
      expect(p.key, 'NSLocationWhenInUseUsageDescription');
      expect(p.group, 'location');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationAlways permission defaults', () {
      final p = IosPermissions.locationAlways;
      expect(p.key, 'NSLocationAlwaysUsageDescription');
      expect(p.group, 'location_always');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationAlwaysAndWhenInUse permission defaults', () {
      final p = IosPermissions.locationAlwaysAndWhenInUse;
      expect(p.key, 'NSLocationAlwaysAndWhenInUseUsageDescription');
      expect(p.group, 'location_always');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('mediaLibrary permission defaults', () {
      final p = IosPermissions.mediaLibrary;
      expect(p.key, 'NSAppleMusicUsageDescription');
      expect(p.group, 'media');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('photoLibrary permission defaults', () {
      final p = IosPermissions.photoLibrary;
      expect(p.key, 'NSPhotoLibraryUsageDescription');
      expect(p.group, 'photos');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('calendars permission has minimumIosVersion and successorOf', () {
      final p = IosPermissions.calendars;
      expect(p.key, 'NSCalendarsFullAccessUsageDescription');
      expect(p.group, 'calendar');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('reminders permission has minimumIosVersion and successorOf', () {
      final p = IosPermissions.reminders;
      expect(p.key, 'NSRemindersFullAccessUsageDescription');
      expect(p.group, 'reminders');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('speechRecognition permission defaults', () {
      final p = IosPermissions.speech;
      expect(p.key, 'NSSpeechRecognitionUsageDescription');
      expect(p.group, 'speech');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('siri permission defaults', () {
      final p = IosPermissions.assistant;
      expect(p.key, 'NSSiriUsageDescription');
      expect(p.group, 'assistant');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('userTracking permission has minimumIosVersion', () {
      final p = IosPermissions.userTracking;
      expect(p.key, 'NSUserTrackingUsageDescription');
      expect(p.group, 'tracking');
      expect(p.scope, AccessScope.standardOrFull);
    });
  });
}
