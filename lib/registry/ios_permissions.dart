import 'models.dart';

/// Complete iOS permission definitions used by the project.
///
/// Each constant is an `IosPermissionDef` representing a single Info.plist key
/// (or related iOS permission) and includes metadata such as the permission
/// key string, the logical group, the iOS API level where it was introduced
/// (`sinceApi`), any deprecation (`untilApi`), an associated service when
/// applicable, and short notes intended for dartdoc consumers.
abstract class IosPermissions {
  // CAMERA
  /// NSCameraUsageDescription
  ///
  /// Required to access the device camera for taking photos or recording video.
  /// Group: camera
  /// Since API: 7.0
  /// Doc: "Required to access the device camera for photo and video capture"
  static const camera = IosPermissionDef(
    'NSCameraUsageDescription',
    group: 'camera',
    sinceApi: 7.0,
    keywords: {'capture', 'record'},
    docNotes: {'Required to access the device camera for photo and video capture'},
  );

  // MICROPHONE
  /// NSMicrophoneUsageDescription
  ///
  /// Required to access the device microphone for audio recording.
  /// Group: microphone
  /// Since API: 7.0
  /// Doc: "Required to access the device microphone for audio recording"
  static const microphone = IosPermissionDef(
    'NSMicrophoneUsageDescription',
    group: 'microphone',
    sinceApi: 7.0,
    keywords: {'record', 'voice', 'speech'},
    docNotes: {'Required to access the device microphone for audio recording'},
  );

  // CONTACTS
  /// NSContactsUsageDescription
  ///
  /// Required to access the user's contacts/address book.
  /// Group: contacts
  /// Since API: 6.0
  /// Doc: "Required to access the user's AddressBook"
  static const contacts = IosPermissionDef(
    'NSContactsUsageDescription',
    group: 'contacts',
    sinceApi: 6.0,
    keywords: {'address', 'phone', 'email'},
    docNotes: {'Required to access the user\'s AddressBook'},
  );

  // LOCATION
  /// NSLocationWhenInUseUsageDescription
  ///
  /// Allows the app to access the user's location while the app is in use
  /// (foreground). Use this when you need location for maps, navigation, or
  /// location-based features that only run while the app is active.
  /// Group: location
  /// Since API: 11.0
  /// Service: location
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

  /// NSLocationAlwaysUsageDescription
  ///
  /// Legacy key for requesting background (always) location access. This key
  /// was used prior to iOS 11.0 and is considered deprecated for newer
  /// systems. Prefer `NSLocationAlwaysAndWhenInUseUsageDescription` on iOS 11+.
  /// Group: location_always
  /// Until API: 11.0 (deprecated)
  /// Service: location
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

  /// NSLocationAlwaysAndWhenInUseUsageDescription
  ///
  /// Required when an app needs both foreground (WhenInUse) and background
  /// (Always) location access on iOS 11.0 and later. On older iOS versions
  /// you must still include the legacy keys for compatibility.
  /// Group: location_always
  /// Since API: 11.0
  /// Service: location
  static const locationAlwaysAndWhenInUse = IosPermissionDef(
    'NSLocationAlwaysAndWhenInUseUsageDescription',
    group: 'location_always',
    service: AssociatedService.location,
    sinceApi: 11.0,
    keywords: {'gps', 'geolocation', 'maps'},
    docNotes: {
      'Required for accessing location in the background',
      'Requires NSLocationWhenInUseUsageDescription for pre iOS 11 compatibility',
      'Before requesting "Always" authorization, you must first request "When In Use" authorization',
    },
  );

  // MEDIA LIBRARY & MUSIC
  /// NSAppleMusicUsageDescription
  ///
  /// Required to access the user's media library and Apple Music features.
  /// Group: media
  /// Since API: 9.3
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
  /// NSPhotoLibraryUsageDescription
  ///
  /// Required to access the user's photo library for read access. On iOS 14+
  /// users may grant limited or full photo library access.
  /// Group: photos
  /// Since API: 6.0
  static const photoLibrary = IosPermissionDef(
    'NSPhotoLibraryUsageDescription',
    group: 'photos',
    sinceApi: 6.0,
    keywords: {'roll', 'gallery', 'picker', 'photo'},
    docNotes: {
      'iOS 14+ presents limited/full photo library access options to users',
    },
  );

  /// NSPhotoLibraryAddUsageDescription
  ///
  /// Required when the app only needs to add photos to the library (write
  /// access) without reading existing photos. Use this for write-only flows
  /// such as saving a captured photo to the user\'s library.
  /// Group: photos_add_only
  /// Since API: 11.0
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
  /// NSCalendarsFullAccessUsageDescription
  ///
  /// Required on iOS 17+ for full calendaring access (read and write).
  /// Group: calendar
  /// Since API: 17.0
  /// Note: Prior iOS versions used `NSCalendarsUsageDescription`.
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

  /// NSCalendarsUsageDescription (deprecated)
  ///
  /// Legacy key used prior to iOS 17.0 for calendar access. Keep for
  /// compatibility with older systems but prefer the newer `calendars`
  /// permission on iOS 17+.
  static const calendarsDeprecated = IosPermissionDef(
    'NSCalendarsUsageDescription',
    group: 'calendar',
    untilApi: 17.0,
    keywords: {'events'},
    docNotes: {
      'Deprecated in iOS 17+. Use calendars or calendarsWriteOnly instead',
    },
  );

  /// NSCalendarsWriteOnlyAccessUsageDescription
  ///
  /// iOS 17+ write-only access for calendars. Use when the app should only
  /// create or modify events without reading existing calendar entries.
  /// Scope: write-only
  /// Group: calendar_write_only
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
  /// NSRemindersFullAccessUsageDescription
  ///
  /// iOS 17+ full access for reminders (read and write). Prior versions used
  /// `NSRemindersUsageDescription`.
  /// Group: reminders
  /// Since API: 17.0
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

  /// NSRemindersUsageDescription (deprecated)
  ///
  /// Legacy reminders permission used prior to iOS 17.0. Keep for backward
  /// compatibility but prefer `reminders` on iOS 17+.
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
  /// NSBluetoothAlwaysUsageDescription
  ///
  /// Required to access Bluetooth when the app needs to interact with
  /// nearby peripherals. Available on iOS 13+ and replaces older
  /// peripheral-specific keys.
  /// Group: bluetooth
  /// Since API: 13.0
  /// Service: bluetooth
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

  /// NSBluetoothPeripheralUsageDescription (deprecated)
  ///
  /// Legacy Bluetooth peripheral usage key used prior to iOS 13.0. Keep for
  /// older OS compatibility; prefer `NSBluetoothAlwaysUsageDescription` on
  /// newer OS versions.
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
  /// NSSpeechRecognitionUsageDescription
  ///
  /// Required to perform on-device speech recognition (distinct from
  /// microphone permission). Available on iOS 10+.
  /// Group: speech
  /// Since API: 10.0
  static const speech = IosPermissionDef(
    'NSSpeechRecognitionUsageDescription',
    group: 'speech',
    sinceApi: 10.0,
    keywords: {'recognition', 'voice'},
    docNotes: {
      'iOS 10.0+: Requests speech access (different from requesting microphone)',
    },
  );

  /// NSSiriUsageDescription
  ///
  /// Required to integrate with Siri and Siri Shortcuts. Available on
  /// iOS 10+.
  /// Group: assistant
  /// Since API: 10.0
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
  /// NSMotionUsageDescription
  ///
  /// Required to access motion and fitness data from device sensors such as
  /// accelerometer and gyroscope. Used for activity tracking and motion-driven
  /// features.
  /// Group: sensors
  /// Since API: 7.0
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
  /// NSUserTrackingUsageDescription
  ///
  /// App Tracking Transparency (ATT) key. Required on iOS 14.5+ when an
  /// app requests permission to track users across apps and websites for
  /// advertising or analytics purposes.
  /// Group: user_tracking
  /// Since API: 14.5
  static const userTracking = IosPermissionDef(
    'NSUserTrackingUsageDescription',
    group: 'user_tracking',
    sinceApi: 14.5,
    keywords: {'ads', 'idfa', 'analytics'},
    docNotes: {
      'iOS 14.5+: App Tracking Transparency - Required to track users across other apps and websites',
    },
  );

  /// Set of all iOS permission definitions
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
