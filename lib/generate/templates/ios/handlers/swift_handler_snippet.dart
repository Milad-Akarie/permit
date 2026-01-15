import 'package:permit/generate/utils.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';

import 'bluetooth_permission_handler.dart';
import 'calendar_permission_handler.dart';
import 'camera_permission_handler.dart';
import 'contacts_permission_handler.dart';
import 'location_permission_handler.dart';
import 'media_library_permission_handler.dart';
import 'microphone_permission_handler.dart';
import 'photos_permission_handler.dart';
import 'reminders_permission_handler.dart';
import 'sensors_permission_handler.dart';
import 'speech_permission_handler.dart';
import 'user_tracking_permission_handler.dart';
import 'assistant_permission_handler.dart';

abstract class SwiftHandlerSnippet {
  final IosPermissionDef entry;
  final Set<String> imports;

  SwiftHandlerSnippet({
    required this.entry,
    this.imports = const {},
  });

  String get key => entry.group;

  String get className => '${key.toPascalCase()}Handler';

  String get constructor => '$className()';

  String generate();
}

final swiftPermissionHandlers = <String, SwiftHandlerSnippet Function()>{
  IosPermissions.camera.group: () => CameraPermissionHandler(),
  IosPermissions.microphone.group: () => MicrophonePermissionHandler(),
  IosPermissions.contacts.group: () => ContactsPermissionHandler(),
  IosPermissions.mediaLibrary.group: () => MediaLibraryPermissionHandler(),
  IosPermissions.photoLibrary.group: () => PhotosPermissionHandler(),
  IosPermissions.photoLibraryAdd.group: () => PhotosPermissionHandler(addOnly: true),
  IosPermissions.bluetooth.group: () => BluetoothPermissionHandler(),
  IosPermissions.locationWhenInUse.group: () => LocationPermissionHandler(),
  IosPermissions.locationAlways.group: () => LocationPermissionHandler(forAlways: true),
  IosPermissions.calendars.group: () => CalendarPermissionHandler(),
  IosPermissions.calendarsWriteOnly.group: () => CalendarPermissionHandler(writeOnly: true),
  IosPermissions.reminders.group: () => RemindersPermissionHandler(),
  IosPermissions.sensors.group: () => SensorsPermissionHandler(),
  IosPermissions.speech.group: () => SpeechPermissionHandler(),
  IosPermissions.userTracking.group: () => UserTrackingPermissionHandler(),
  IosPermissions.assistant.group: () => AssistantPermissionHandler(),
};
