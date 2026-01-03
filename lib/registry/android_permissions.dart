import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const AndroidPermissionDef camera = AndroidPermissionDef(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
  );

  // Microphone
  static const AndroidPermissionDef recordAudio = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
  );

  // Location
  static const AndroidPermissionDef accessFineLocation = AndroidPermissionDef(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
  );
  static const AndroidPermissionDef accessCoarseLocation = AndroidPermissionDef(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
  );
  static const AndroidPermissionDef accessBackgroundLocation = AndroidPermissionDef(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    group: 'location',
    minimumSdkVersion: '29',
  );

  // Contacts
  static const AndroidPermissionDef readContacts = AndroidPermissionDef(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const AndroidPermissionDef writeContacts = AndroidPermissionDef(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const AndroidPermissionDef getAccounts = AndroidPermissionDef(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
  );

  // Calendar
  static const AndroidPermissionDef readCalendar = AndroidPermissionDef(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
  );
  static const AndroidPermissionDef writeCalendar = AndroidPermissionDef(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar',
  );

  // Phone
  static const AndroidPermissionDef readPhoneState = AndroidPermissionDef(
    'android.permission.READ_PHONE_STATE',
    group: 'phone',
  );
  static const AndroidPermissionDef readPhoneNumbers = AndroidPermissionDef(
    'android.permission.READ_PHONE_NUMBERS',
    group: 'phone',
    minimumSdkVersion: '26',
  );
  static const AndroidPermissionDef callPhone = AndroidPermissionDef(
    'android.permission.CALL_PHONE',
    runtime: false,
    group: 'phone',
  );
  static const AndroidPermissionDef answerPhoneCalls = AndroidPermissionDef(
    'android.permission.ANSWER_PHONE_CALLS',
    group: 'phone',
    minimumSdkVersion: '26',
  );

  // Storage (legacy / media-scoped)
  static const AndroidPermissionDef readExternalStorage = AndroidPermissionDef(
    'android.permission.READ_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );
  static const AndroidPermissionDef writeExternalStorage = AndroidPermissionDef(
    'android.permission.WRITE_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );

  // Media (Android 13+)
  static const AndroidPermissionDef readMediaImages = AndroidPermissionDef(
    'android.permission.READ_MEDIA_IMAGES',
    group: 'storage',
    minimumSdkVersion: '33',
  );
  static const AndroidPermissionDef readMediaVideo = AndroidPermissionDef(
    'android.permission.READ_MEDIA_VIDEO',
    group: 'storage',
    minimumSdkVersion: '33',
  );
  static const AndroidPermissionDef readMediaAudio = AndroidPermissionDef(
    'android.permission.READ_MEDIA_AUDIO',
    group: 'storage',
    minimumSdkVersion: '33',
  );

  /// =====================
  /// No runtime permission
  /// =====================

  // Network
  static const AndroidPermissionDef internet = AndroidPermissionDef(
    'android.permission.INTERNET',
    runtime: false,
    group: 'network',
  );
  static const AndroidPermissionDef accessNetworkState = AndroidPermissionDef(
    'android.permission.ACCESS_NETWORK_STATE',
    group: 'network',
  );
  static const AndroidPermissionDef accessWifiState = AndroidPermissionDef(
    'android.permission.ACCESS_WIFI_STATE',
    group: 'network',
  );
  static const AndroidPermissionDef changeWifiState = AndroidPermissionDef(
    'android.permission.CHANGE_WIFI_STATE',
    group: 'network',
  );

  // Bluetooth
  static const AndroidPermissionDef bluetooth = AndroidPermissionDef(
    'android.permission.BLUETOOTH',
    runtime: false,
    group: 'bluetooth',
  );
  static const AndroidPermissionDef bluetoothAdmin = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADMIN',
    group: 'bluetooth',
  );
  static const AndroidPermissionDef bluetoothConnect = AndroidPermissionDef(
    'android.permission.BLUETOOTH_CONNECT',
    group: 'bluetooth',
    minimumSdkVersion: '31',
  );
  static const AndroidPermissionDef bluetoothScan = AndroidPermissionDef(
    'android.permission.BLUETOOTH_SCAN',
    group: 'bluetooth',
    minimumSdkVersion: '31',
  );

  // Sensors
  static const AndroidPermissionDef bodySensors = AndroidPermissionDef(
    'android.permission.BODY_SENSORS',
    runtime: true,
    group: 'sensors',
  );

  // System / Misc
  static const AndroidPermissionDef vibrate = AndroidPermissionDef(
    'android.permission.VIBRATE',
    runtime: false,
    group: 'system',
  );
  static const AndroidPermissionDef wakeLock = AndroidPermissionDef(
    'android.permission.WAKE_LOCK',
    runtime: false,
    group: 'system',
  );
  static const AndroidPermissionDef foregroundService = AndroidPermissionDef(
    'android.permission.FOREGROUND_SERVICE',
    group: 'system',
    minimumSdkVersion: '28',
  );
  static const AndroidPermissionDef postNotifications = AndroidPermissionDef(
    'android.permission.POST_NOTIFICATIONS',
    group: 'notifications',
    minimumSdkVersion: '33',
  );

  static final Set<AndroidPermissionDef> all = {
    // Camera
    camera,
    // Microphone
    recordAudio,
    // Location
    accessFineLocation,
    accessCoarseLocation,
    accessBackgroundLocation,
    // Contacts
    readContacts,
    writeContacts,
    getAccounts,
    // Calendar
    readCalendar,
    writeCalendar,
    // Phone
    readPhoneState,
    readPhoneNumbers,
    callPhone,
    answerPhoneCalls,
    // Storage
    readExternalStorage,
    writeExternalStorage,
    // Media
    readMediaImages,
    readMediaVideo,
    readMediaAudio,
    // Network
    internet,
    accessNetworkState,
    accessWifiState,
    changeWifiState,
    // Bluetooth
    bluetooth,
    bluetoothAdmin,
    bluetoothConnect,
    bluetoothScan,
    // Sensors
    bodySensors,
    // System / Misc
    vibrate,
    wakeLock,
    foregroundService,
    postNotifications,
  };
}
