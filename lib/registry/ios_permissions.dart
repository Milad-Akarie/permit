import 'models.dart';

/// Complete iOS Permissions
abstract class IosPermissions {
  // CAMERA
  static const camera = IosPermission(
    'NSCameraUsageDescription',
    group: 'camera',
  );

  // MICROPHONE
  static const microphone = IosPermission(
    'NSMicrophoneUsageDescription',
    group: 'microphone',
  );

  // CONTACTS
  static const contacts = IosPermission(
    'NSContactsUsageDescription',
    group: 'contacts',
  );

  // LOCATION
  static const locationWhenInUse = IosPermission(
    'NSLocationWhenInUseUsageDescription',
    group: 'location',
  );

  static const locationAlways = IosPermission(
    'NSLocationAlwaysUsageDescription',
    group: 'location',
  );

  static const locationAlwaysAndWhenInUse = IosPermission(
    'NSLocationAlwaysAndWhenInUseUsageDescription',
    group: 'location',
  );

  // MEDIA LIBRARY & MUSIC
  static const mediaLibrary = IosPermission(
    'NSAppleMusicUsageDescription',
    group: 'media',
  );

  // PHOTOS & MEDIA
  static const photoLibrary = IosPermission(
    'NSPhotoLibraryUsageDescription',
    group: 'photos',
  );

  static const photoLibraryAdd = IosPermission(
    'NSPhotoLibraryAddUsageDescription',
    minimumIosVersion: '11.0',
    group: 'photos',
  );

  // CALENDARS & EVENTS
  static const calendars = IosPermission(
    'NSCalendarsFullAccessUsageDescription',
    minimumIosVersion: '17.0',
    successorOf: 'NSCalendarsUsageDescription',
    group: 'calendar',
  );
  static const calendarsWriteOnly = IosPermission(
    'NSCalendarsWriteOnlyAccessUsageDescription',
    scope: AccessScope.writeOnly,
    minimumIosVersion: '17.0',
    group: 'calendar',
  );

  // REMINDERS
  static const reminders = IosPermission(
    'NSRemindersFullAccessUsageDescription',
    minimumIosVersion: '17.0',
    successorOf: 'NSRemindersUsageDescription',
    group: 'reminders',
  );

  // BLUETOOTH
  static const bluetoothAlways = IosPermission(
    'NSBluetoothAlwaysUsageDescription',
    minimumIosVersion: '13.0',
    successorOf: 'NSBluetoothPeripheralUsageDescription',
    group: 'bluetooth',
  );

  // MOTION & FITNESS
  static const motion = IosPermission(
    'NSMotionUsageDescription',
    group: 'motion',
  );

  // HEALTH
  static const healthShare = IosPermission(
    'NSHealthShareUsageDescription',
    group: 'health',
  );
  static const healthUpdate = IosPermission(
    'NSHealthUpdateUsageDescription',
    group: 'health',
  );
  static const healthClinicalRecords = IosPermission(
    'NSHealthClinicalHealthRecordsShareUsageDescription',
    group: 'health',
  );

  // SPEECH & SIRI
  static const speechRecognition = IosPermission('NSSpeechRecognitionUsageDescription', group: 'speech');

  static const siri = IosPermission('NSSiriUsageDescription', group: 'siri');

  // FACE ID & BIOMETRICS
  static const faceId = IosPermission('NSFaceIDUsageDescription', group: 'biometrics');

  // HOMEKIT
  static const homeKit = IosPermission('NSHomeKitUsageDescription', group: 'homekit');

  // NFC
  static const nfcReader = IosPermission('NFCReaderUsageDescription', group: 'nfc');

  // TRACKING
  static const userTracking = IosPermission(
    'NSUserTrackingUsageDescription',
    minimumIosVersion: '14.5',
    group: 'tracking',
  );

  // LOCAL NETWORK
  static const localNetwork = IosPermission(
    'NSLocalNetworkUsageDescription',
    minimumIosVersion: '14.0',
    group: 'network',
  );

  // NEARBY INTERACTION
  static const nearbyInteraction = IosPermission(
    'NSNearbyInteractionUsageDescription',
    minimumIosVersion: '14.0',
    group: 'nearby',
  );

  // SENSORS & FOCUS
  static const focusStatus = IosPermission(
    'NSFocusStatusUsageDescription',
    minimumIosVersion: '15.0',
    group: 'focus',
  );

  /// Get all permissions
  static Set<IosPermission> get all => {
    camera,
    microphone,
    photoLibrary,
    photoLibraryAdd,
    locationWhenInUse,
    locationAlways,
    locationAlwaysAndWhenInUse,
    contacts,
    calendarsWriteOnly,
    reminders,
    bluetoothAlways,
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
  static IosPermission? getByKey(String key) {
    try {
      return all.firstWhere((permission) => permission.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Get permissions that require specific iOS version or higher
  static List<IosPermission> getByMinimumVersion(String version) {
    return all.where((p) => p.minimumIosVersion == version).toList();
  }
}
