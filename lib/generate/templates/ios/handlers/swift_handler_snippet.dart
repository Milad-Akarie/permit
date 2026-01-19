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

/// Abstract base class for Swift permission handler snippets.
abstract class SwiftHandlerSnippet {
  /// The iOS permission definition entry.
  final IosPermissionDef entry;

  /// Imports required for the handler.
  final Set<String> imports;

  /// Constructor for [SwiftHandlerSnippet].
  SwiftHandlerSnippet({
    required this.entry,
    this.imports = const {},
  });

  /// The key of the permission entry.
  String get key => entry.group;

  /// Builds the default class name for the handler.
  String get className => '${key.toPascalCase()}Handler';

  /// Builds the default constructor for the handler.
  String get constructor => '$className()';

  /// Generates the Swift code for the permission handler.
  String generate();
}

/// Mapping of iOS permission keys to their corresponding Swift handler snippets.
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
