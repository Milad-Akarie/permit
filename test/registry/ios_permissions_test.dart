import 'package:test/test.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';

void main() {
  group('IosPermissions defaults', () {
    test('camera permission has default (null) minimumIosVersion and default scope', () {
      final p = IosPermissions.camera;
      expect(p.key, equals('NSCameraUsageDescription'));
      expect(p.group, equals('camera'));
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, equals(AccessScope.standardOrFull));
    });

    test('photoLibraryAdd has a minimumIosVersion set', () {
      final p = IosPermissions.photoLibraryAdd;
      expect(p.key, equals('NSPhotoLibraryAddUsageDescription'));
      expect(p.minimumIosVersion, equals('11.0'));
      expect(p.scope, equals(AccessScope.standardOrFull));
    });

    test('calendarsWriteOnly has writeOnly scope and minimumIosVersion', () {
      final p = IosPermissions.calendarsWriteOnly;
      expect(p.key, contains('CalendarsWriteOnly'));
      expect(p.scope, equals(AccessScope.writeOnly));
      expect(p.minimumIosVersion, equals('17.0'));
    });

    test('microphone permission defaults', () {
      final p = IosPermissions.microphone;
      expect(p.key, 'NSMicrophoneUsageDescription');
      expect(p.group, 'microphone');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('contacts permission defaults', () {
      final p = IosPermissions.contacts;
      expect(p.key, 'NSContactsUsageDescription');
      expect(p.group, 'contacts');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationWhenInUse permission defaults', () {
      final p = IosPermissions.locationWhenInUse;
      expect(p.key, 'NSLocationWhenInUseUsageDescription');
      expect(p.group, 'location');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationAlways permission defaults', () {
      final p = IosPermissions.locationAlways;
      expect(p.key, 'NSLocationAlwaysUsageDescription');
      expect(p.group, 'location_always');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('locationAlwaysAndWhenInUse permission defaults', () {
      final p = IosPermissions.locationAlwaysAndWhenInUse;
      expect(p.key, 'NSLocationAlwaysAndWhenInUseUsageDescription');
      expect(p.group, 'location_always');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('mediaLibrary permission defaults', () {
      final p = IosPermissions.mediaLibrary;
      expect(p.key, 'NSAppleMusicUsageDescription');
      expect(p.group, 'media');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('photoLibrary permission defaults', () {
      final p = IosPermissions.photoLibrary;
      expect(p.key, 'NSPhotoLibraryUsageDescription');
      expect(p.group, 'photos');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('calendars permission has minimumIosVersion and successorOf', () {
      final p = IosPermissions.calendars;
      expect(p.key, 'NSCalendarsFullAccessUsageDescription');
      expect(p.group, 'calendar');
      expect(p.minimumIosVersion, '17.0');
      expect(p.successorOf, 'NSCalendarsUsageDescription');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('reminders permission has minimumIosVersion and successorOf', () {
      final p = IosPermissions.reminders;
      expect(p.key, 'NSRemindersFullAccessUsageDescription');
      expect(p.group, 'reminders');
      expect(p.minimumIosVersion, '17.0');
      expect(p.successorOf, 'NSRemindersUsageDescription');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('bluetoothAlways permission has minimumIosVersion and successorOf', () {
      final p = IosPermissions.bluetoothAlways;
      expect(p.key, 'NSBluetoothAlwaysUsageDescription');
      expect(p.group, 'bluetooth');
      expect(p.minimumIosVersion, '13.0');
      expect(p.successorOf, 'NSBluetoothPeripheralUsageDescription');
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('motion permission defaults', () {
      final p = IosPermissions.motion;
      expect(p.key, 'NSMotionUsageDescription');
      expect(p.group, 'sensors');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('healthShare permission defaults', () {
      final p = IosPermissions.healthShare;
      expect(p.key, 'NSHealthShareUsageDescription');
      expect(p.group, 'health_share');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('healthUpdate permission defaults', () {
      final p = IosPermissions.healthUpdate;
      expect(p.key, 'NSHealthUpdateUsageDescription');
      expect(p.group, 'health_update');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('healthClinicalRecords permission defaults', () {
      final p = IosPermissions.healthClinicalRecords;
      expect(p.key, 'NSHealthClinicalHealthRecordsShareUsageDescription');
      expect(p.group, 'health_clinical_records');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('speechRecognition permission defaults', () {
      final p = IosPermissions.speechRecognition;
      expect(p.key, 'NSSpeechRecognitionUsageDescription');
      expect(p.group, 'speech');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('siri permission defaults', () {
      final p = IosPermissions.siri;
      expect(p.key, 'NSSiriUsageDescription');
      expect(p.group, 'assistant');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('faceId permission defaults', () {
      final p = IosPermissions.faceId;
      expect(p.key, 'NSFaceIDUsageDescription');
      expect(p.group, 'face_id');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('homeKit permission defaults', () {
      final p = IosPermissions.homeKit;
      expect(p.key, 'NSHomeKitUsageDescription');
      expect(p.group, 'home_kit');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('nfcReader permission defaults', () {
      final p = IosPermissions.nfcReader;
      expect(p.key, 'NFCReaderUsageDescription');
      expect(p.group, 'nfc');
      expect(p.minimumIosVersion, isNull);
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('userTracking permission has minimumIosVersion', () {
      final p = IosPermissions.userTracking;
      expect(p.key, 'NSUserTrackingUsageDescription');
      expect(p.group, 'tracking');
      expect(p.minimumIosVersion, '14.5');
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('localNetwork permission has minimumIosVersion', () {
      final p = IosPermissions.localNetwork;
      expect(p.key, 'NSLocalNetworkUsageDescription');
      expect(p.group, 'network');
      expect(p.minimumIosVersion, '14.0');
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('nearbyInteraction permission has minimumIosVersion', () {
      final p = IosPermissions.nearbyInteraction;
      expect(p.key, 'NSNearbyInteractionUsageDescription');
      expect(p.group, 'nearby_interaction');
      expect(p.minimumIosVersion, '14.0');
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });

    test('focusStatus permission has minimumIosVersion', () {
      final p = IosPermissions.focusStatus;
      expect(p.key, 'NSFocusStatusUsageDescription');
      expect(p.group, 'focus');
      expect(p.minimumIosVersion, '15.0');
      expect(p.successorOf, isNull);
      expect(p.scope, AccessScope.standardOrFull);
    });
  });
}
