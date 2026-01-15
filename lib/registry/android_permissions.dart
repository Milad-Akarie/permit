import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const camera = AndroidPermissionDef(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
    keywords: {'capture'},
  );

  // Microphone
  static const microphone = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
    keywords: {'record', 'voice'},
  );

  // This is the same as microphone, but defined separately for
  // the unified permission groups.
  static const speech = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'speech',
    keywords: {'recognition', 'voice'},
  );

  // Location
  static const accessFineLocation = AndroidPermissionDef(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
  );
  static const accessCoarseLocation = AndroidPermissionDef(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
  );
  static const accessBackgroundLocation = AndroidPermissionDef(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    sinceApi: 29,
    group: 'location_always',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
    legacyKeys: {
      'android.permission.ACCESS_FINE_LOCATION': 28,
    },
  );

  // Contacts
  static const readContacts = AndroidPermissionDef(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
    keywords: {'address', 'phone'},
  );
  static const writeContacts = AndroidPermissionDef(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
    keywords: {'address', 'phone'},
  );
  static const getAccounts = AndroidPermissionDef(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
    keywords: {'address', 'phone'},
  );

  // Calendar
  static const readCalendar = AndroidPermissionDef(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
    keywords: {'events'},
  );
  static const writeCalendar = AndroidPermissionDef(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar',
    keywords: {'events'},
  );

  // Phone
  static const readPhoneState = AndroidPermissionDef(
    'android.permission.READ_PHONE_STATE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'state', 'identity', 'carrier'},
  );
  static const readPhoneNumbers = AndroidPermissionDef(
    'android.permission.READ_PHONE_NUMBERS',
    sinceApi: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'state', 'identity', 'carrier'},
    legacyKeys: {
      'android.permission.READ_PHONE_STATE': 25,
    },
  );
  static const callPhone = AndroidPermissionDef(
    'android.permission.CALL_PHONE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'dial', 'call', 'outgoing'},
  );
  static const answerPhoneCalls = AndroidPermissionDef(
    'android.permission.ANSWER_PHONE_CALLS',
    sinceApi: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'answer', 'incoming', 'call'},
    legacyKeys: {
      'android.permission.READ_PHONE_STATE': 25,
    },
  );
  static const readCallLog = AndroidPermissionDef(
    'android.permission.READ_CALL_LOG',
    runtime: true,
    sinceApi: 16,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'history', 'log', 'missed'},
  );
  static const writeCallLog = AndroidPermissionDef(
    'android.permission.WRITE_CALL_LOG',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'modify', 'log', 'history'},
  );
  static const addVoicemail = AndroidPermissionDef(
    'android.permission.ADD_VOICEMAIL',
    runtime: true,
    sinceApi: 14,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'voicemail', 'message', 'voice'},
  );

  // SMS
  static const sendSms = AndroidPermissionDef(
    'android.permission.SEND_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'send', 'text', 'message'},
  );
  static const receiveSms = AndroidPermissionDef(
    'android.permission.RECEIVE_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'receive', 'message'},
  );
  static const readSms = AndroidPermissionDef(
    'android.permission.READ_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'read', 'inbox', 'message'},
  );
  static const receiveWapPush = AndroidPermissionDef(
    'android.permission.RECEIVE_WAP_PUSH',
    runtime: true,
    group: 'sms',
    keywords: {'wap', 'push', 'mms'},
  );
  static const receiveMms = AndroidPermissionDef(
    'android.permission.RECEIVE_MMS',
    runtime: true,
    group: 'sms',
    keywords: {'mms', 'multimedia', 'message'},
  );

  static const accessMediaLocation = AndroidPermissionDef(
    'android.permission.ACCESS_MEDIA_LOCATION',
    runtime: true,
    sinceApi: 29,
    group: 'media_location',
    keywords: {'metadata', 'location', 'geotag'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 28,
    },
  );

  // Media
  static const readMediaImages = AndroidPermissionDef(
    'android.permission.READ_MEDIA_IMAGES',
    sinceApi: 33,
    runtime: true,
    group: 'photos',
    keywords: {'images', 'media'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
  );
  static const readMediaVideo = AndroidPermissionDef(
    'android.permission.READ_MEDIA_VIDEO',
    sinceApi: 33,
    runtime: true,
    group: 'videos',
    keywords: {'video', 'playback'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
  );
  static const readMediaAudio = AndroidPermissionDef(
    'android.permission.READ_MEDIA_AUDIO',
    sinceApi: 33,
    runtime: true,
    group: 'audio',
    keywords: {'playback', 'track'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
  );

  // Manage External Storage (Android 11+)
  static const manageExternalStorage = AndroidPermissionDef(
    'android.permission.MANAGE_EXTERNAL_STORAGE',
    runtime: true,
    sinceApi: 30,
    group: 'manage_external_storage',
    keywords: {'files', 'manage', 'access'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 29,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
  );

  // Battery
  static const ignoreBatteryOptimizations = AndroidPermissionDef(
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    sinceApi: 23,
    group: 'ignore_battery_optimizations',
    keywords: {'battery', 'opt_out', 'power'},
  );

  // Network
  static const internet = AndroidPermissionDef(
    'android.permission.INTERNET',
    runtime: false,
    group: 'internet',
    keywords: {'http', 'network', 'connect'},
  );
  static const accessNetworkState = AndroidPermissionDef(
    'android.permission.ACCESS_NETWORK_STATE',
    group: 'network_state',
    keywords: {'connectivity', 'state', 'network'},
  );
  static const accessWifiState = AndroidPermissionDef(
    'android.permission.ACCESS_WIFI_STATE',
    group: 'wifi_state',
    keywords: {'wifi', 'ssid', 'rssi'},
  );
  static const changeWifiState = AndroidPermissionDef(
    'android.permission.CHANGE_WIFI_STATE',
    group: 'wifi_change',
    keywords: {'toggle', 'configure', 'wifi'},
  );
  static const nearbyWifiDevices = AndroidPermissionDef(
    'android.permission.NEARBY_WIFI_DEVICES',
    runtime: true,
    sinceApi: 33,
    group: 'nearby_wifi_devices',
    keywords: {'nearby', 'scan', 'wifi'},
  );

  // Bluetooth
  static const bluetoothConnect = AndroidPermissionDef(
    'android.permission.BLUETOOTH_CONNECT',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_connect',
    service: AssociatedService.bluetooth,
    keywords: {'connect', 'device'},
    legacyKeys: {
      'android.permission.BLUETOOTH': 30,
      'android.permission.BLUETOOTH_ADMIN': 30,
    },
  );
  static const bluetoothScan = AndroidPermissionDef(
    'android.permission.BLUETOOTH_SCAN',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_scan',
    service: AssociatedService.bluetooth,
    keywords: {'scan', 'discover', 'le'},
    legacyKeys: {
      'android.permission.BLUETOOTH_ADMIN': 30,
    },
  );
  static const bluetoothAdvertise = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADVERTISE',
    sinceApi: 31,
    runtime: true,
    group: 'bluetooth_advertise',
    service: AssociatedService.bluetooth,
    keywords: {'advertise', 'broadcast', 'beacon'},
    legacyKeys: {
      'android.permission.BLUETOOTH_ADMIN': 30,
    },
  );

  // Sensors
  static const bodySensors = AndroidPermissionDef(
    'android.permission.BODY_SENSORS',
    runtime: true,
    sinceApi: 20,
    group: 'sensors',
    keywords: {'heart', 'bio', 'bpm'},
  );
  static const bodySensorsBackground = AndroidPermissionDef(
    'android.permission.BODY_SENSORS_BACKGROUND',
    runtime: true,
    sinceApi: 33,
    group: 'body_sensors_background',
    keywords: {'motion', 'activity', 'sensor'},
  );

  // System / Misc
  static const vibrate = AndroidPermissionDef(
    'android.permission.VIBRATE',
    group: 'vibrate',
    keywords: {'haptic'},
  );
  static const wakeLock = AndroidPermissionDef(
    'android.permission.WAKE_LOCK',
    group: 'wake_lock',
    keywords: {'keep_awake', 'wakelock'},
  );
  static const systemAlertWindow = AndroidPermissionDef(
    'android.permission.SYSTEM_ALERT_WINDOW',
    runtime: true,
    sinceApi: 23,
    group: 'system_alert_window',
    keywords: {'overlay', 'draw', 'window'},
  );
  static const foregroundService = AndroidPermissionDef(
    'android.permission.FOREGROUND_SERVICE',
    sinceApi: 28,
    group: 'foreground_service',
    keywords: {'service', 'persistent', 'foreground'},
  );
  static const scheduleExactAlarm = AndroidPermissionDef(
    'android.permission.SCHEDULE_EXACT_ALARM',
    sinceApi: 31,
    group: 'schedule_exact_alarm',
    keywords: {'alarm', 'timer', 'exact'},
  );
  static const postNotifications = AndroidPermissionDef(
    'android.permission.POST_NOTIFICATIONS',
    sinceApi: 33,
    runtime: true,
    group: 'notifications',
    keywords: {'push', 'alerts'},
  );
  static const requestInstallPackages = AndroidPermissionDef(
    'android.permission.REQUEST_INSTALL_PACKAGES',
    sinceApi: 26,
    group: 'request_install_packages',
    keywords: {'installer', 'apk', 'sideload'},
  );
  static const nfc = AndroidPermissionDef(
    'android.permission.NFC',
    group: 'nfc',
    keywords: {'tag', 'reader', 'tap'},
  );

  // Activity Recognition
  static const activityRecognition = AndroidPermissionDef(
    'android.permission.ACTIVITY_RECOGNITION',
    runtime: true,
    sinceApi: 29,
    group: 'activity_recognition',
    keywords: {'activity', 'fitness', 'motion'},
  );

  static final Set<AndroidPermissionDef> all = {
    // Camera
    camera,
    // Microphone
    microphone,
    speech,
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
    // Storage
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
