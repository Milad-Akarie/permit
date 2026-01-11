import 'package:permit/generate/templates/ios/handlers/bluetooth_permission_handler.dart';
import 'package:permit/generate/utils.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';

import 'camera_permission_handler.dart';
import 'contacts_permission_handler.dart';
import 'location_permission_handler.dart';
import 'media_library_permission_handler.dart';
import 'microphone_permission_handler.dart';
import 'photos_permission_handler.dart';

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
};
