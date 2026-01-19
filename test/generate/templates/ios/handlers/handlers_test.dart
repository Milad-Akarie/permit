import 'package:permit/generate/templates/ios/handlers/assistant_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/bluetooth_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/calendar_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/camera_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/contacts_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/location_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/media_library_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/microphone_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/photos_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/reminders_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/sensors_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/speech_permission_handler.dart';
import 'package:permit/generate/templates/ios/handlers/user_tracking_permission_handler.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:test/test.dart';

void main() {
  group('iOS Permission Handlers', () {
    test('AssistantPermissionHandler generates correct code', () {
      final handler = AssistantPermissionHandler();
      expect(handler.entry, equals(IosPermissions.assistant));
      expect(handler.imports, contains('Intents'));
      final code = handler.generate();
      expect(code, contains('INPreferences.requestSiriAuthorization'));
      expect(code, contains('class AssistantHandler: PermissionHandler'));
    });

    test('BluetoothPermissionHandler generates correct code', () {
      final handler = BluetoothPermissionHandler();
      expect(handler.entry, equals(IosPermissions.bluetooth));
      expect(handler.imports, contains('CoreBluetooth'));
      final code = handler.generate();
      expect(code, contains('CBCentralManager'));
      expect(
        code,
        contains(
          'class BluetoothHandler: NSObject, PermissionHandler, CBCentralManagerDelegate',
        ),
      );
    });

    // Explicit override: CalendarPermissionHandler
    test('CalendarPermissionHandler generates correct code', () {
      final handler = CalendarPermissionHandler();
      expect(handler.entry, equals(IosPermissions.calendars));
      expect(handler.imports, contains('EventKit'));
      final code = handler.generate();
      expect(code, contains('EKEventStore'));
      expect(
        code,
        contains('class CalendarPermissionHandler: PermissionHandler'),
      );
    });

    test('CameraPermissionHandler generates correct code', () {
      final handler = CameraPermissionHandler();
      expect(handler.entry, equals(IosPermissions.camera));
      expect(handler.imports, contains('AVFoundation'));
      final code = handler.generate();
      expect(code, contains('AVCaptureDevice'));
      expect(code, contains('class CameraHandler: PermissionHandler'));
    });

    test('ContactsPermissionHandler generates correct code', () {
      final handler = ContactsPermissionHandler();
      expect(handler.entry, equals(IosPermissions.contacts));
      expect(handler.imports, contains('Contacts'));
      final code = handler.generate();
      expect(code, contains('CNContactStore'));
      expect(code, contains('class ContactsHandler: PermissionHandler'));
    });

    // Explicit override: LocationHandler
    test('LocationPermissionHandler generates correct code', () {
      final handler = LocationPermissionHandler();
      expect(handler.entry, equals(IosPermissions.locationWhenInUse));
      expect(handler.imports, contains('CoreLocation'));
      final code = handler.generate();
      expect(code, contains('CLLocationManager'));
      expect(
        code,
        contains('class LocationHandler: NSObject, PermissionHandler'),
      );
    });

    test('MediaLibraryPermissionHandler generates correct code', () {
      final handler = MediaLibraryPermissionHandler();
      expect(handler.entry, equals(IosPermissions.mediaLibrary));
      expect(handler.imports, contains('MediaPlayer'));
      final code = handler.generate();
      expect(code, contains('MPMediaLibrary.requestAuthorization'));
      expect(code, contains('class MediaHandler: PermissionHandler'));
    });

    test('MicrophonePermissionHandler generates correct code', () {
      final handler = MicrophonePermissionHandler();
      expect(handler.entry, equals(IosPermissions.microphone));
      expect(handler.imports, contains('AVFoundation'));
      final code = handler.generate();
      expect(code, contains('AVCaptureDevice.requestAccess(for: .audio)'));
      expect(code, contains('class MicrophoneHandler: PermissionHandler'));
    });

    // Explicit override: PhotosPermissionHandler
    test('PhotosPermissionHandler generates correct code', () {
      final handler = PhotosPermissionHandler();
      expect(handler.entry, equals(IosPermissions.photoLibrary));
      expect(handler.imports, contains('Photos'));
      final code = handler.generate();
      expect(code, contains('PHPhotoLibrary.requestAuthorization'));
      expect(
        code,
        contains('class PhotosPermissionHandler: PermissionHandler'),
      );
    });

    test('RemindersPermissionHandler generates correct code', () {
      final handler = RemindersPermissionHandler();
      expect(handler.entry, equals(IosPermissions.reminders));
      expect(handler.imports, contains('EventKit'));
      final code = handler.generate();
      expect(code, contains('EKEventStore'));
      expect(code, contains('class RemindersHandler: PermissionHandler'));
    });

    // Explicit override: SensorsPermissionHandler
    test('SensorsPermissionHandler generates correct code', () {
      final handler = SensorsPermissionHandler();
      expect(handler.entry, equals(IosPermissions.sensors));
      expect(handler.imports, contains('CoreMotion'));
      final code = handler.generate();
      expect(code, contains('CMMotionActivityManager'));
      expect(
        code,
        contains('class SensorsPermissionHandler: PermissionHandler'),
      );
    });

    test('SpeechPermissionHandler generates correct code', () {
      final handler = SpeechPermissionHandler();
      expect(handler.entry, equals(IosPermissions.speech));
      expect(handler.imports, contains('Speech'));
      final code = handler.generate();
      expect(code, contains('SFSpeechRecognizer.requestAuthorization'));
      expect(code, contains('class SpeechHandler: PermissionHandler'));
    });

    test('UserTrackingPermissionHandler generates correct code', () {
      final handler = UserTrackingPermissionHandler();
      expect(handler.entry, equals(IosPermissions.userTracking));
      expect(handler.imports, contains('AppTrackingTransparency'));
      final code = handler.generate();
      expect(code, contains('ATTrackingManager.requestTrackingAuthorization'));
      expect(code, contains('class UserTrackingHandler: PermissionHandler'));
    });
  });
}
