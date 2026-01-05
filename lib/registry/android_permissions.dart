import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const camera = AndroidPermissionDef(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
    unifiedName: 'camera',
  );

  // Microphone
  static const recordAudio = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
    unifiedName: 'microphone',
  );

  // Location
  static const accessFineLocation = AndroidPermissionDef(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
    unifiedName: 'location',
  );
  static const accessCoarseLocation = AndroidPermissionDef(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
    unifiedName: 'location',
  );
  static const accessBackgroundLocation = AndroidPermissionDef(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    group: 'location',
    sinceApi: 29,
    unifiedName: 'location_always',
  );

  // Contacts
  static const readContacts = AndroidPermissionDef(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
    unifiedName: 'contacts',
  );
  static const writeContacts = AndroidPermissionDef(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
    unifiedName: 'contacts',
  );
  static const getAccounts = AndroidPermissionDef(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
    unifiedName: 'contacts_accounts',
  );

  // Calendar
  static const readCalendar = AndroidPermissionDef(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
    unifiedName: 'calendar',
  );
  static const writeCalendar = AndroidPermissionDef(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar',
    unifiedName: 'calendar',
  );

  // Phone
  static const readPhoneState = AndroidPermissionDef(
    'android.permission.READ_PHONE_STATE',
    runtime: true,
    group: 'phone',
    unifiedName: 'phone',
  );
  static const readPhoneNumbers = AndroidPermissionDef(
    'android.permission.READ_PHONE_NUMBERS',
    group: 'phone',
    sinceApi: 26,
    runtime: true,
    unifiedName: 'phone_numbers',
  );
  static const callPhone = AndroidPermissionDef(
    'android.permission.CALL_PHONE',
    runtime: true,
    group: 'phone',
    unifiedName: 'phone_call',
  );
  static const answerPhoneCalls = AndroidPermissionDef(
    'android.permission.ANSWER_PHONE_CALLS',
    group: 'phone',
    sinceApi: 26,
    runtime: true,
    unifiedName: 'phone_answer',
  );

  // SMS
  static const sendSms = AndroidPermissionDef(
    'android.permission.SEND_SMS',
    runtime: true,
    group: 'sms',
    unifiedName: 'sms',
  );

  static const readSms = AndroidPermissionDef(
    'android.permission.READ_SMS',
    runtime: true,
    group: 'sms',
    unifiedName: 'sms',
  );

  // Storage (legacy / media-scoped)
  static const readExternalStorage = AndroidPermissionDef(
    'android.permission.READ_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
    unifiedName: 'storage',
  );
  static const writeExternalStorage = AndroidPermissionDef(
    'android.permission.WRITE_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
    unifiedName: 'storage_write',
  );

  static const accessMediaLocation = AndroidPermissionDef(
    'android.permission.ACCESS_MEDIA_LOCATION',
    runtime: true,
    group: 'storage',
    sinceApi: 29,
    unifiedName: 'media_location',
  );

  // Media (Android 13+)
  static const readMediaImages = AndroidPermissionDef(
    'android.permission.READ_MEDIA_IMAGES',
    group: 'storage',
    sinceApi: 33,
    runtime: true,
    unifiedName: 'photos',
  );
  static const readMediaVideo = AndroidPermissionDef(
    'android.permission.READ_MEDIA_VIDEO',
    group: 'storage',
    sinceApi: 33,
    runtime: true,
    unifiedName: 'videos',
  );
  static const readMediaAudio = AndroidPermissionDef(
    'android.permission.READ_MEDIA_AUDIO',
    group: 'storage',
    sinceApi: 33,
    runtime: true,
    unifiedName: 'audio',
  );

  // Manage External Storage (Android 11+)
  static const manageExternalStorage = AndroidPermissionDef(
    'android.permission.MANAGE_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
    sinceApi: 30,
    unifiedName: 'manage_external_storage',
  );

  // Battery
  static const ignoreBatteryOptimizations = AndroidPermissionDef(
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    group: 'battery',
    unifiedName: 'ignore_battery_optimizations',
  );

  // Network
  static const internet = AndroidPermissionDef(
    'android.permission.INTERNET',
    runtime: false,
    group: 'network',
    unifiedName: 'internet',
  );
  static const accessNetworkState = AndroidPermissionDef(
    'android.permission.ACCESS_NETWORK_STATE',
    group: 'network',
    unifiedName: 'network_state',
  );
  static const accessWifiState = AndroidPermissionDef(
    'android.permission.ACCESS_WIFI_STATE',
    group: 'network',
    unifiedName: 'wifi_state',
  );
  static const changeWifiState = AndroidPermissionDef(
    'android.permission.CHANGE_WIFI_STATE',
    group: 'network',
    unifiedName: 'wifi_change',
  );

  // Bluetooth
  static const bluetooth = AndroidPermissionDef(
    'android.permission.BLUETOOTH',
    group: 'bluetooth',
    unifiedName: 'bluetooth',
  );
  static const bluetoothAdmin = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADMIN',
    group: 'bluetooth',
    unifiedName: 'bluetooth_admin',
  );
  static const bluetoothConnect = AndroidPermissionDef(
    'android.permission.BLUETOOTH_CONNECT',
    group: 'bluetooth',
    sinceApi: 31,
    runtime: true,
    unifiedName: 'bluetooth_connect',
  );
  static const bluetoothScan = AndroidPermissionDef(
    'android.permission.BLUETOOTH_SCAN',
    group: 'bluetooth',
    sinceApi: 31,
    runtime: true,
    unifiedName: 'bluetooth_scan',
  );
  static const bluetoothAdvertise = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADVERTISE',
    group: 'bluetooth',
    sinceApi: 31,
    runtime: true,
    unifiedName: 'bluetooth_advertise',
  );

  // Sensors
  static const bodySensors = AndroidPermissionDef(
    'android.permission.BODY_SENSORS',
    runtime: true,
    group: 'sensors',
    unifiedName: 'sensors',
  );
  static const bodySensorsBackground = AndroidPermissionDef(
    'android.permission.BODY_SENSORS_BACKGROUND',
    runtime: true,
    group: 'sensors',
    sinceApi: 33,
    unifiedName: 'body_sensors_background',
  );

  // System / Misc
  static const vibrate = AndroidPermissionDef(
    'android.permission.VIBRATE',
    group: 'system',
    unifiedName: 'vibrate',
  );
  static const wakeLock = AndroidPermissionDef(
    'android.permission.WAKE_LOCK',
    group: 'system',
    unifiedName: 'wake_lock',
  );
  static const systemAlertWindow = AndroidPermissionDef(
    'android.permission.SYSTEM_ALERT_WINDOW',
    runtime: true,
    group: 'system',
    unifiedName: 'system_alert_window',
  );
  static const foregroundService = AndroidPermissionDef(
    'android.permission.FOREGROUND_SERVICE',
    group: 'system',
    sinceApi: 28,
    unifiedName: 'foreground_service',
  );
  static const scheduleExactAlarm = AndroidPermissionDef(
    'android.permission.SCHEDULE_EXACT_ALARM',
    runtime: true,
    group: 'system',
    sinceApi: 31,
    unifiedName: 'schedule_exact_alarm',
  );
  static const postNotifications = AndroidPermissionDef(
    'android.permission.POST_NOTIFICATIONS',
    group: 'notifications',
    sinceApi: 33,
    runtime: true,
    unifiedName: 'notification',
  );

  // Activity Recognition
  static const activityRecognition = AndroidPermissionDef(
    'android.permission.ACTIVITY_RECOGNITION',
    runtime: true,
    group: 'sensors',
    sinceApi: 29,
    unifiedName: 'activity_recognition',
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
    accessMediaLocation,
    // Media
    readMediaImages,
    readMediaVideo,
    readMediaAudio,
    // Manage External Storage
    manageExternalStorage,
    // SMS
    sendSms,
    readSms,
    // Battery
    ignoreBatteryOptimizations,
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
    bluetoothAdvertise,
    // Sensors
    bodySensors,
    bodySensorsBackground,
    // System / Misc
    vibrate,
    wakeLock,
    systemAlertWindow,
    foregroundService,
    scheduleExactAlarm,
    postNotifications,
    // Activity Recognition
    activityRecognition,
  };
}
