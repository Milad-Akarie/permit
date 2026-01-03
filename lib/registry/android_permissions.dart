import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const AndroidPermission camera = AndroidPermission(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
  );

  // Microphone
  static const AndroidPermission recordAudio = AndroidPermission(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
  );

  // Location
  static const AndroidPermission accessFineLocation = AndroidPermission(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
  );
  static const AndroidPermission accessCoarseLocation = AndroidPermission(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
  );
  static const AndroidPermission accessBackgroundLocation = AndroidPermission(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    group: 'location',
    minimumSdkVersion: '29',
  );

  // Contacts
  static const AndroidPermission readContacts = AndroidPermission(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const AndroidPermission writeContacts = AndroidPermission(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const AndroidPermission getAccounts = AndroidPermission(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
  );

  // Calendar
  static const AndroidPermission readCalendar = AndroidPermission(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
  );
  static const AndroidPermission writeCalendar = AndroidPermission(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar',
  );

  // Phone
  static const AndroidPermission readPhoneState = AndroidPermission(
    'android.permission.READ_PHONE_STATE',
    group: 'phone',
  );
  static const AndroidPermission readPhoneNumbers = AndroidPermission(
    'android.permission.READ_PHONE_NUMBERS',
    group: 'phone',
    minimumSdkVersion: '26',
  );
  static const AndroidPermission callPhone = AndroidPermission(
    'android.permission.CALL_PHONE',
    runtime: false,
    group: 'phone',
  );
  static const AndroidPermission answerPhoneCalls = AndroidPermission(
    'android.permission.ANSWER_PHONE_CALLS',
    group: 'phone',
    minimumSdkVersion: '26',
  );

  // Storage (legacy / media-scoped)
  static const AndroidPermission readExternalStorage = AndroidPermission(
    'android.permission.READ_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );
  static const AndroidPermission writeExternalStorage = AndroidPermission(
    'android.permission.WRITE_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );

  // Media (Android 13+)
  static const AndroidPermission readMediaImages = AndroidPermission(
    'android.permission.READ_MEDIA_IMAGES',
    group: 'storage',
    minimumSdkVersion: '33',
  );
  static const AndroidPermission readMediaVideo = AndroidPermission(
    'android.permission.READ_MEDIA_VIDEO',
    group: 'storage',
    minimumSdkVersion: '33',
  );
  static const AndroidPermission readMediaAudio = AndroidPermission(
    'android.permission.READ_MEDIA_AUDIO',
    group: 'storage',
    minimumSdkVersion: '33',
  );

  /// =====================
  /// No runtime permission
  /// =====================

  // Network
  static const AndroidPermission internet = AndroidPermission(
    'android.permission.INTERNET',
    runtime: false,
    group: 'network',
  );
  static const AndroidPermission accessNetworkState = AndroidPermission(
    'android.permission.ACCESS_NETWORK_STATE',
    group: 'network',
  );
  static const AndroidPermission accessWifiState = AndroidPermission(
    'android.permission.ACCESS_WIFI_STATE',
    group: 'network',
  );
  static const AndroidPermission changeWifiState = AndroidPermission(
    'android.permission.CHANGE_WIFI_STATE',
    group: 'network',
  );

  // Bluetooth
  static const AndroidPermission bluetooth = AndroidPermission(
    'android.permission.BLUETOOTH',
    runtime: false,
    group: 'bluetooth',
  );
  static const AndroidPermission bluetoothAdmin = AndroidPermission(
    'android.permission.BLUETOOTH_ADMIN',
    group: 'bluetooth',
  );
  static const AndroidPermission bluetoothConnect = AndroidPermission(
    'android.permission.BLUETOOTH_CONNECT',
    group: 'bluetooth',
    minimumSdkVersion: '31',
  );
  static const AndroidPermission bluetoothScan = AndroidPermission(
    'android.permission.BLUETOOTH_SCAN',
    group: 'bluetooth',
    minimumSdkVersion: '31',
  );

  // Sensors
  static const AndroidPermission bodySensors = AndroidPermission(
    'android.permission.BODY_SENSORS',
    runtime: true,
    group: 'sensors',
  );

  // System / Misc
  static const AndroidPermission vibrate = AndroidPermission(
    'android.permission.VIBRATE',
    runtime: false,
    group: 'system',
  );
  static const AndroidPermission wakeLock = AndroidPermission(
    'android.permission.WAKE_LOCK',
    runtime: false,
    group: 'system',
  );
  static const AndroidPermission foregroundService = AndroidPermission(
    'android.permission.FOREGROUND_SERVICE',
    group: 'system',
    minimumSdkVersion: '28',
  );
  static const AndroidPermission postNotifications = AndroidPermission(
    'android.permission.POST_NOTIFICATIONS',
    group: 'notifications',
    minimumSdkVersion: '33',
  );

  static final Set<AndroidPermission> all = {
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
