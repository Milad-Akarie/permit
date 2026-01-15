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
    group: 'photos_add_only',
  );

  // CALENDARS & EVENTS
  static const calendars = IosPermissionDef(
    'NSCalendarsFullAccessUsageDescription',
    successorOf: 'NSCalendarsUsageDescription',
    group: 'calendar',
  );
  static const calendarsWriteOnly = IosPermissionDef(
    'NSCalendarsWriteOnlyAccessUsageDescription',
    scope: AccessScope.writeOnly,
    group: 'calendar_write_only',
  );

  // REMINDERS
  static const reminders = IosPermissionDef(
    'NSRemindersFullAccessUsageDescription',
    successorOf: 'NSRemindersUsageDescription',
    group: 'reminders',
  );

  // BLUETOOTH
  static const bluetooth = IosPermissionDef(
    'NSBluetoothAlwaysUsageDescription',
    successorOf: 'NSBluetoothPeripheralUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
  );

  // SPEECH & SIRI
  static const speech = IosPermissionDef(
    'NSSpeechRecognitionUsageDescription',
    group: 'speech',
  );

  static const assistant = IosPermissionDef(
    'NSSiriUsageDescription',
    group: 'assistant',
  );

  // MOTION & FITNESS
  static const sensors = IosPermissionDef(
    'NSMotionUsageDescription',
    group: 'sensors',
  );

  // TRACKING
  static const userTracking = IosPermissionDef(
    'NSUserTrackingUsageDescription',
    group: 'tracking',
  );

  // // HEALTH
  // static const healthShare = IosPermissionDef(
  //   'NSHealthShareUsageDescription',
  //   group: 'health_share',
  // );
  // static const healthUpdate = IosPermissionDef(
  //   'NSHealthUpdateUsageDescription',
  //   group: 'health_update',
  // );
  // static const healthClinicalRecords = IosPermissionDef(
  //   'NSHealthClinicalHealthRecordsShareUsageDescription',
  //   group: 'health_clinical_records',
  // );

  // // FACE ID & BIOMETRICS
  // static const faceId = IosPermissionDef('NSFaceIDUsageDescription', group: 'face_id');
  //
  // // HOMEKIT
  // static const homeKit = IosPermissionDef('NSHomeKitUsageDescription', group: 'home_kit');
  //
  // // NFC
  // static const nfcReader = IosPermissionDef(
  //   'NFCReaderUsageDescription',
  //   group: 'nfc',
  // );
  //
  // // LOCAL NETWORK
  // static const localNetwork = IosPermissionDef(
  //   'NSLocalNetworkUsageDescription',
  //    //   group: 'network',
  // );
  //
  // static const nearbyInteraction = IosPermissionDef(
  //   'NSNearbyInteractionUsageDescription',
  //    //   group: 'nearby_interaction',
  // );
  //
  // // SENSORS & FOCUS
  // static const focusStatus = IosPermissionDef(
  //   'NSFocusStatusUsageDescription',
  //    //   group: 'focus',
  // );

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
    sensors,
    speech,
    assistant,
    mediaLibrary,
    userTracking,
    // healthShare,
    // healthUpdate,
    // healthClinicalRecords,
    // faceId,
    // homeKit,
    // nfcReader,
    // localNetwork,
    // nearbyInteraction,
    // focusStatus,
  };
}
