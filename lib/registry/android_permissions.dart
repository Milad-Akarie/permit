import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const camera = AndroidPermissionDef(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
  );

  // Microphone
  static const recordAudio = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
  );

  // Location
  static const accessFineLocation = AndroidPermissionDef(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
  );
  static const accessCoarseLocation = AndroidPermissionDef(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
  );
  static const accessBackgroundLocation = AndroidPermissionDef(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    sinceApi: 29,
    group: 'location_always',
    service: AssociatedService.location,
  );

  // Contacts
  static const readContacts = AndroidPermissionDef(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const writeContacts = AndroidPermissionDef(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
  );
  static const getAccounts = AndroidPermissionDef(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
  );

  // Calendar
  static const readCalendar = AndroidPermissionDef(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
  );
  static const writeCalendar = AndroidPermissionDef(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar',
  );

  // Phone
  static const readPhoneState = AndroidPermissionDef(
    'android.permission.READ_PHONE_STATE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const readPhoneNumbers = AndroidPermissionDef(
    'android.permission.READ_PHONE_NUMBERS',
    sinceApi: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const callPhone = AndroidPermissionDef(
    'android.permission.CALL_PHONE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const answerPhoneCalls = AndroidPermissionDef(
    'android.permission.ANSWER_PHONE_CALLS',
    sinceApi: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const readCallLog = AndroidPermissionDef(
    'android.permission.READ_CALL_LOG',
    runtime: true,
    sinceApi: 16,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const writeCallLog = AndroidPermissionDef(
    'android.permission.WRITE_CALL_LOG',
    runtime: true,
    sinceApi: 16,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const addVoicemail = AndroidPermissionDef(
    'android.permission.ADD_VOICEMAIL',
    runtime: true,
    sinceApi: 14,
    group: 'phone',
    service: AssociatedService.phone,
  );
  static const useSip = AndroidPermissionDef(
    'android.permission.USE_SIP',
    runtime: true,
    sinceApi: 9,
    group: 'phone',
    service: AssociatedService.phone,
  );

  // SMS
  static const sendSms = AndroidPermissionDef(
    'android.permission.SEND_SMS',
    runtime: true,
    group: 'sms',
  );
  static const receiveSms = AndroidPermissionDef(
    'android.permission.RECEIVE_SMS',
    runtime: true,
    group: 'sms',
  );
  static const readSms = AndroidPermissionDef(
    'android.permission.READ_SMS',
    runtime: true,
    group: 'sms',
  );
  static const receiveWapPush = AndroidPermissionDef(
    'android.permission.RECEIVE_WAP_PUSH',
    runtime: true,
    group: 'sms',
  );
  static const receiveMms = AndroidPermissionDef(
    'android.permission.RECEIVE_MMS',
    runtime: true,
    group: 'sms',
  );

  // Storage (legacy / media-scoped)
  static const readExternalStorage = AndroidPermissionDef(
    'android.permission.READ_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );
  static const writeExternalStorage = AndroidPermissionDef(
    'android.permission.WRITE_EXTERNAL_STORAGE',
    runtime: true,
    group: 'storage',
  );

  static const accessMediaLocation = AndroidPermissionDef(
    'android.permission.ACCESS_MEDIA_LOCATION',
    runtime: true,
    sinceApi: 29,
    group: 'media_location',
  );

  // Media (Android 13+)
  static const readMediaImages = AndroidPermissionDef(
    'android.permission.READ_MEDIA_IMAGES',
    sinceApi: 33,
    runtime: true,
    group: 'photos',
  );
  static const readMediaVideo = AndroidPermissionDef(
    'android.permission.READ_MEDIA_VIDEO',
    sinceApi: 33,
    runtime: true,
    group: 'videos',
  );
  static const readMediaAudio = AndroidPermissionDef(
    'android.permission.READ_MEDIA_AUDIO',
    sinceApi: 33,
    runtime: true,
    group: 'audio',
  );

  // Manage External Storage (Android 11+)
  static const manageExternalStorage = AndroidPermissionDef(
    'android.permission.MANAGE_EXTERNAL_STORAGE',
    runtime: true,
    sinceApi: 30,
    group: 'manage_external_storage',
  );

  // Battery
  static const ignoreBatteryOptimizations = AndroidPermissionDef(
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    group: 'ignore_battery_optimizations',
    runtime: true,
  );

  // Network
  static const internet = AndroidPermissionDef(
    'android.permission.INTERNET',
    runtime: false,
    group: 'internet',
  );
  static const accessNetworkState = AndroidPermissionDef(
    'android.permission.ACCESS_NETWORK_STATE',
    group: 'network_state',
  );
  static const accessWifiState = AndroidPermissionDef(
    'android.permission.ACCESS_WIFI_STATE',
    group: 'wifi_state',
  );
  static const changeWifiState = AndroidPermissionDef(
    'android.permission.CHANGE_WIFI_STATE',
    group: 'wifi_change',
  );
  static const nearbyWifiDevices = AndroidPermissionDef(
    'android.permission.NEARBY_WIFI_DEVICES',
    runtime: true,
    sinceApi: 33,
    group: 'nearby_wifi_devices',
  );

  // Bluetooth
  static const bluetooth = AndroidPermissionDef(
    'android.permission.BLUETOOTH',
    group: 'bluetooth',
  );
  static const bluetoothAdmin = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADMIN',
    group: 'bluetooth_admin',
  );
  static const bluetoothConnect = AndroidPermissionDef(
    'android.permission.BLUETOOTH_CONNECT',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_connect',
    service: AssociatedService.bluetooth,
  );
  static const bluetoothScan = AndroidPermissionDef(
    'android.permission.BLUETOOTH_SCAN',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_scan',
    service: AssociatedService.bluetooth,
  );
  static const bluetoothAdvertise = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADVERTISE',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_advertise',
    service: AssociatedService.bluetooth,
  );

  // Sensors
  static const bodySensors = AndroidPermissionDef(
    'android.permission.BODY_SENSORS',
    runtime: true,
    group: 'sensors',
  );
  static const bodySensorsBackground = AndroidPermissionDef(
    'android.permission.BODY_SENSORS_BACKGROUND',
    runtime: true,
    sinceApi: 33,
    group: 'body_sensors_background',
  );

  // System / Misc
  static const vibrate = AndroidPermissionDef(
    'android.permission.VIBRATE',
    group: 'vibrate',
  );
  static const wakeLock = AndroidPermissionDef(
    'android.permission.WAKE_LOCK',
    group: 'wake_lock',
  );
  static const systemAlertWindow = AndroidPermissionDef(
    'android.permission.SYSTEM_ALERT_WINDOW',
    runtime: true,
    group: 'system_alert_window',
  );
  static const foregroundService = AndroidPermissionDef(
    'android.permission.FOREGROUND_SERVICE',
    sinceApi: 28,
    group: 'foreground_service',
  );
  static const scheduleExactAlarm = AndroidPermissionDef(
    'android.permission.SCHEDULE_EXACT_ALARM',
    runtime: true,
    sinceApi: 31,
    group: 'schedule_exact_alarm',
  );
  static const postNotifications = AndroidPermissionDef(
    'android.permission.POST_NOTIFICATIONS',
    sinceApi: 33,
    runtime: true,
    group: 'notifications',
  );
  static const requestInstallPackages = AndroidPermissionDef(
    'android.permission.REQUEST_INSTALL_PACKAGES',
    runtime: true,
    sinceApi: 26,
    group: 'request_install_packages',
  );
  static const nfc = AndroidPermissionDef(
    'android.permission.NFC',
    group: 'nfc',
  );

  // Activity Recognition
  static const activityRecognition = AndroidPermissionDef(
    'android.permission.ACTIVITY_RECOGNITION',
    runtime: true,
    sinceApi: 29,
    group: 'activity_recognition',
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
    readCallLog,
    writeCallLog,
    addVoicemail,
    useSip,
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
    receiveSms,
    readSms,
    receiveWapPush,
    receiveMms,
    // Battery
    ignoreBatteryOptimizations,
    // Network
    internet,
    accessNetworkState,
    accessWifiState,
    changeWifiState,
    nearbyWifiDevices,
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
    requestInstallPackages,
    nfc,
    // Activity Recognition
    activityRecognition,
  };
}
