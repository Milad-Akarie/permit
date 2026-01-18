import 'models.dart';

/// Complete iOS Permissions
abstract class IosPermissions {
  // CAMERA
  static const camera = IosPermissionDef(
    'NSCameraUsageDescription',
    group: 'camera',
    sinceApi: 7.0,
    keywords: {'capture', 'record'},
    docNotes: {'Required to access the device camera for photo and video capture'},
  );

  // MICROPHONE
  static const microphone = IosPermissionDef(
    'NSMicrophoneUsageDescription',
    group: 'microphone',
    sinceApi: 7.0,
    keywords: {'record', 'voice', 'speech'},
    docNotes: {'Required to access the device microphone for audio recording'},
  );

  // CONTACTS
  static const contacts = IosPermissionDef(
    'NSContactsUsageDescription',
    group: 'contacts',
    sinceApi: 6.0,
    keywords: {'address', 'phone', 'email'},
    docNotes: {'Required to access the user\'s AddressBook'},
  );

  // LOCATION
  static const locationWhenInUse = IosPermissionDef(
    'NSLocationWhenInUseUsageDescription',
    group: 'location',
    service: AssociatedService.location,
    sinceApi: 11.0,
    keywords: {'gps', 'geolocation', 'maps'},
    docNotes: {
      'iOS 11.0+: CoreLocation - WhenInUse. Allows location access only while app is in the foreground',
    },
  );

  static const locationAlways = IosPermissionDef(
    'NSLocationAlwaysUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
    untilApi: 11.0,
    keywords: {'gps', 'geolocation', 'maps'},
    docNotes: {
      'Deprecated in iOS 11+. Use locationAlwaysAndWhenInUse instead',
    },
  );

  static const locationAlwaysAndWhenInUse = IosPermissionDef(
    'NSLocationAlwaysAndWhenInUseUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
    sinceApi: 11.0,
    keywords: {'gps', 'geolocation', 'maps'},
    docNotes: {
      'Required for accessing location in the background',
      'Requires NSLocationWhenInUseUsageDescription for pre ios 11 compatibility',
      'Before requesting "Always" authorization, you must first request "When In Use" authorization',
    },
  );

  // MEDIA LIBRARY & MUSIC
  static const mediaLibrary = IosPermissionDef(
    'NSAppleMusicUsageDescription',
    group: 'media',
    sinceApi: 9.3,
    keywords: {'music', 'library'},
    docNotes: {
      'iOS 9.3+: Required to access the user\'s media library and Apple Music',
    },
  );

  // PHOTOS & MEDIA
  static const photoLibrary = IosPermissionDef(
    'NSPhotoLibraryUsageDescription',
    group: 'photos',
    sinceApi: 6.0,
    keywords: {'roll', 'gallery', 'picker', 'photo'},
    docNotes: {
      'iOS 14+ presents limited/full photo library access options to users',
    },
  );

  static const photoLibraryAdd = IosPermissionDef(
    'NSPhotoLibraryAddUsageDescription',
    group: 'photos_add_only',
    sinceApi: 11.0,
    keywords: {'roll', 'gallery', 'picker', 'photo'},
    docNotes: {
      'Write-only access: users cannot select existing photos, only add new ones',
    },
  );

  // CALENDARS & EVENTS
  static const calendars = IosPermissionDef(
    'NSCalendarsFullAccessUsageDescription',
    group: 'calendar',
    sinceApi: 17.0,
    keywords: {'events'},
    docNotes: {
      'iOS 17+: Full access includes read and write permissions.',
      'Prior versions use NSCalendarsUsageDescription',
    },
  );

  static const calendarsDeprecated = IosPermissionDef(
    'NSCalendarsUsageDescription',
    group: 'calendar',
    untilApi: 17.0,
    keywords: {'events'},
    docNotes: {
      'Deprecated in iOS 17+. Use calendars or calendarsWriteOnly instead',
    },
  );

  static const calendarsWriteOnly = IosPermissionDef(
    'NSCalendarsWriteOnlyAccessUsageDescription',
    scope: AccessScope.writeOnly,
    group: 'calendar_write_only',
    sinceApi: 17.0,
    keywords: {'events'},
    docNotes: {
      'Required for write-only access to calendars',
      'iOS 17+ distinguishes between full access and write-only access',
    },
  );

  // REMINDERS
  static const reminders = IosPermissionDef(
    'NSRemindersFullAccessUsageDescription',
    group: 'reminders',
    sinceApi: 17.0,
    keywords: {'tasks', 'todo'},
    docNotes: {
      'Required for full access to reminders',
      'iOS 17+: Full access includes read and write permissions.',
      'Prior versions use NSRemindersUsageDescription',
    },
  );

  static const remindersDeprecated = IosPermissionDef(
    'NSRemindersUsageDescription',
    group: 'reminders',
    untilApi: 17.0,
    keywords: {'tasks', 'todo'},
    docNotes: {
      'Deprecated in iOS 17+. Use reminders instead',
    },
  );

  // BLUETOOTH
  static const bluetooth = IosPermissionDef(
    'NSBluetoothAlwaysUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
    sinceApi: 13.0,
    keywords: {'peripheral', 'connect'},
    docNotes: {
      'Required for Bluetooth access',
      'iOS 13+: Replaces NSBluetoothPeripheralUsageDescription',
    },
  );

  static const bluetoothPeripheralDeprecated = IosPermissionDef(
    'NSBluetoothPeripheralUsageDescription',
    group: 'bluetooth',
    service: AssociatedService.bluetooth,
    untilApi: 13.0,
    keywords: {'peripheral', 'connect'},
    docNotes: {
      'iOS 13+: Requires NSBluetoothAlwaysUsageDescription instead of NSBluetoothPeripheralUsageDescription',
    },
  );

  // SPEECH & SIRI
  static const speech = IosPermissionDef(
    'NSSpeechRecognitionUsageDescription',
    group: 'speech',
    sinceApi: 10.0,
    keywords: {'recognition', 'voice'},
    docNotes: {
      'iOS 10.0+: Requests speech access (different from requesting microphone)',
    },
  );

  static const assistant = IosPermissionDef(
    'NSSiriUsageDescription',
    group: 'assistant',
    sinceApi: 10.0,
    keywords: {'siri', 'shortcut', 'voice'},
    docNotes: {
      'iOS 10.0+: Required to integrate with Siri and Siri Shortcuts',
    },
  );

  // MOTION & FITNESS
  static const sensors = IosPermissionDef(
    'NSMotionUsageDescription',
    group: 'sensors',
    sinceApi: 7.0,
    keywords: {'accelerometer', 'gyroscope', 'motion'},
    docNotes: {
      'Required to access motion and fitness data from device sensors',
    },
  );

  // TRACKING
  static const userTracking = IosPermissionDef(
    'NSUserTrackingUsageDescription',
    group: 'user_tracking',
    sinceApi: 14.5,
    keywords: {'ads', 'idfa', 'analytics'},
    docNotes: {
      'iOS 14.5+: App Tracking Transparency - Required to track users across other apps and websites',
    },
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
  };
}
