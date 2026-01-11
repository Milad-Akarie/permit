import 'package:collection/collection.dart';

import 'models.dart';

/// Complete iOS Permissions
abstract class IosPermissions {
  // CAMERA
  static const camera = IosPermissionDef(
    'NSCameraUsageDescription',
    group: 'camera',
  );

  // MICROPHONE
  static const microphone = IosPermissionDef(
    'NSMicrophoneUsageDescription',
    group: 'microphone',
  );

  // CONTACTS
  static const contacts = IosPermissionDef(
    'NSContactsUsageDescription',
    group: 'contacts',
  );

  // LOCATION
  static const locationWhenInUse = IosPermissionDef(
    'NSLocationWhenInUseUsageDescription',
    group: 'location',
    service: AssociatedService.location,
  );

  static const locationAlways = IosPermissionDef(
    'NSLocationAlwaysUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
  );

  static const locationAlwaysAndWhenInUse = IosPermissionDef(
    'NSLocationAlwaysAndWhenInUseUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
  );

  // MEDIA LIBRARY & MUSIC
  static const mediaLibrary = IosPermissionDef(
    'NSAppleMusicUsageDescription',
    group: 'media',
  );

  // PHOTOS & MEDIA
  static const photoLibrary = IosPermissionDef(
    'NSPhotoLibraryUsageDescription',
    group: 'photos',
  );

  static const photoLibraryAdd = IosPermissionDef(
    'NSPhotoLibraryAddUsageDescription',
    minimumIosVersion: '11.0',
    group: 'photos_add_only',
  );

  // CALENDARS & EVENTS
  static const calendars = IosPermissionDef(
    'NSCalendarsFullAccessUsageDescription',
    minimumIosVersion: '17.0',
    successorOf: 'NSCalendarsUsageDescription',
    group: 'calendar',
  );
  static const calendarsWriteOnly = IosPermissionDef(
    'NSCalendarsWriteOnlyAccessUsageDescription',
    scope: AccessScope.writeOnly,
    minimumIosVersion: '17.0',
    group: 'calendar_write_only',
  );

  // REMINDERS
  static const reminders = IosPermissionDef(
    'NSRemindersFullAccessUsageDescription',
    minimumIosVersion: '17.0',
    successorOf: 'NSRemindersUsageDescription',
    group: 'reminders',
  );

  // BLUETOOTH
  static const bluetooth = IosPermissionDef(
    'NSBluetoothAlwaysUsageDescription',
    minimumIosVersion: '13.0',
    successorOf: 'NSBluetoothPeripheralUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
  );

  // MOTION & FITNESS
  static const motion = IosPermissionDef(
    'NSMotionUsageDescription',
    group: 'sensors',
  );

  // HEALTH
  static const healthShare = IosPermissionDef(
    'NSHealthShareUsageDescription',
    group: 'health_share',
  );
  static const healthUpdate = IosPermissionDef(
    'NSHealthUpdateUsageDescription',
    group: 'health_update',
  );
  static const healthClinicalRecords = IosPermissionDef(
    'NSHealthClinicalHealthRecordsShareUsageDescription',
    group: 'health_clinical_records',
  );

  // SPEECH & SIRI
  static const speechRecognition = IosPermissionDef(
    'NSSpeechRecognitionUsageDescription',
    group: 'speech',
  );

  static const siri = IosPermissionDef('NSSiriUsageDescription', group: 'assistant');

  // FACE ID & BIOMETRICS
  static const faceId = IosPermissionDef('NSFaceIDUsageDescription', group: 'face_id');

  // HOMEKIT
  static const homeKit = IosPermissionDef('NSHomeKitUsageDescription', group: 'home_kit');

  // NFC
  static const nfcReader = IosPermissionDef(
    'NFCReaderUsageDescription',
    group: 'nfc',
  );

  // TRACKING
  static const userTracking = IosPermissionDef(
    'NSUserTrackingUsageDescription',
    minimumIosVersion: '14.5',
    group: 'tracking',
  );

  // LOCAL NETWORK
  static const localNetwork = IosPermissionDef(
    'NSLocalNetworkUsageDescription',
    minimumIosVersion: '14.0',
    group: 'network',
  );

  static const nearbyInteraction = IosPermissionDef(
    'NSNearbyInteractionUsageDescription',
    minimumIosVersion: '14.0',
    group: 'nearby_interaction',
  );

  // SENSORS & FOCUS
  static const focusStatus = IosPermissionDef(
    'NSFocusStatusUsageDescription',
    minimumIosVersion: '15.0',
    group: 'focus',
  );

  /// Get all permissions
  static Set<IosPermissionDef> get all => {
    camera,
    microphone,
    photoLibrary,
    photoLibraryAdd,
    locationWhenInUse,
    locationAlways,
    locationAlwaysAndWhenInUse,
    contacts,
    calendarsWriteOnly,
    calendars,
    reminders,
    bluetooth,
    motion,
    healthShare,
    healthUpdate,
    healthClinicalRecords,
    speechRecognition,
    siri,
    faceId,
    mediaLibrary,
    homeKit,
    nfcReader,
    userTracking,
    localNetwork,
    nearbyInteraction,
    focusStatus,
  };

  /// Validate if a permission key exists
  static bool isValidKey(String key) {
    return all.any((permission) => permission.key == key);
  }

  /// Get permission by Info.plist key
  static IosPermissionDef? getByKey(String key) {
    return all.firstWhereOrNull((permission) => permission.key == key);
  }

  /// Get permissions that require specific iOS version or higher
  static List<IosPermissionDef> getByMinimumVersion(String version) {
    return all.where((p) => p.minimumIosVersion == version).toList();
  }
}
