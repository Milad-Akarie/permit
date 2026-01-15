import 'models.dart';

/// Complete iOS Permissions
abstract class IosPermissions {
  // CAMERA
  static const camera = IosPermissionDef(
    'NSCameraUsageDescription',
    group: 'camera',
    sinceApi: 7.0,
  );

  // MICROPHONE
  static const microphone = IosPermissionDef(
    'NSMicrophoneUsageDescription',
    group: 'microphone',
    sinceApi: 7.0,
  );

  // CONTACTS
  static const contacts = IosPermissionDef(
    'NSContactsUsageDescription',
    group: 'contacts',
    sinceApi: 6.0,
  );

  // LOCATION
  static const locationWhenInUse = IosPermissionDef(
    'NSLocationWhenInUseUsageDescription',
    group: 'location',
    service: AssociatedService.location,
    sinceApi: 11.0,
  );

  static const locationAlways = IosPermissionDef(
    'NSLocationAlwaysUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
    untilApi: 11.0,
  );

  static const locationAlwaysAndWhenInUse = IosPermissionDef(
    'NSLocationAlwaysAndWhenInUseUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
    sinceApi: 11.0,
  );

  // MEDIA LIBRARY & MUSIC
  static const mediaLibrary = IosPermissionDef(
    'NSAppleMusicUsageDescription',
    group: 'media',
    sinceApi: 2.0,
  );

  // PHOTOS & MEDIA
  static const photoLibrary = IosPermissionDef(
    'NSPhotoLibraryUsageDescription',
    group: 'photos',
    sinceApi: 6.0,
  );

  static const photoLibraryAdd = IosPermissionDef(
    'NSPhotoLibraryAddUsageDescription',
    group: 'photos_add_only',
    sinceApi: 11.0,
  );

  // CALENDARS & EVENTS
  static const calendars = IosPermissionDef(
    'NSCalendarsFullAccessUsageDescription',
    group: 'calendar',
    sinceApi: 17.0,
  );

  static const calendarsDeprecated = IosPermissionDef(
    'NSCalendarsUsageDescription',
    group: 'calendar',
    untilApi: 17.0,
  );
  static const calendarsWriteOnly = IosPermissionDef(
    'NSCalendarsWriteOnlyAccessUsageDescription',
    scope: AccessScope.writeOnly,
    group: 'calendar_write_only',
    sinceApi: 17.0,
  );

  // REMINDERS
  static const reminders = IosPermissionDef(
    'NSRemindersFullAccessUsageDescription',
    group: 'reminders',
    sinceApi: 17.0,
  );

  static const remindersDeprecated = IosPermissionDef(
    'NSRemindersUsageDescription',
    group: 'reminders',
    untilApi: 17.0,
  );

  // BLUETOOTH
  static const bluetooth = IosPermissionDef(
    'NSBluetoothAlwaysUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
    sinceApi: 13.0,
  );

  static const bluetoothPeripheralDeprecated = IosPermissionDef(
    'NSBluetoothPeripheralUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
    untilApi: 13.0,
  );

  // SPEECH & SIRI
  static const speech = IosPermissionDef(
    'NSSpeechRecognitionUsageDescription',
    group: 'speech',
    sinceApi: 10.0,
  );

  static const assistant = IosPermissionDef(
    'NSSiriUsageDescription',
    group: 'assistant',
    sinceApi: 10.0,
  );

  // MOTION & FITNESS
  static const sensors = IosPermissionDef(
    'NSMotionUsageDescription',
    group: 'sensors',
    sinceApi: 7.0,
  );

  // TRACKING
  static const userTracking = IosPermissionDef(
    'NSUserTrackingUsageDescription',
    group: 'tracking',
    sinceApi: 14.5,
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
    calendarsDeprecated,
    reminders,
    remindersDeprecated,
    bluetooth,
    bluetoothPeripheralDeprecated,
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
