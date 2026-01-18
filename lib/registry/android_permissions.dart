import 'models.dart';

abstract class AndroidPermissions {
  // Camera
  static const camera = AndroidPermissionDef(
    'android.permission.CAMERA',
    runtime: true,
    group: 'camera',
    keywords: {'capture', 'record'},
    docNotes: {'Required to access the device camera for photo and video capture'},
  );

  // Microphone
  static const microphone = AndroidPermissionDef(
    'android.permission.RECORD_AUDIO',
    runtime: true,
    group: 'microphone',
    keywords: {'record', 'voice', 'speech', 'recognition'},
    docNotes: {'Required to access the device microphone for audio recording'},
  );

  // Location
  static const accessFineLocation = AndroidPermissionDef(
    'android.permission.ACCESS_FINE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
    docNotes: {'Required for precise location access using GPS'},
  );
  static const accessCoarseLocation = AndroidPermissionDef(
    'android.permission.ACCESS_COARSE_LOCATION',
    runtime: true,
    group: 'location',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
    docNotes: {'Required for approximate location access using Wi-Fi and cellular networks'},
  );
  static const accessBackgroundLocation = AndroidPermissionDef(
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    runtime: true,
    sinceSDK: 29,
    group: 'location_always',
    service: AssociatedService.location,
    keywords: {'gps', 'maps', 'geolocation'},
    legacyKeys: {
      'android.permission.ACCESS_FINE_LOCATION': 28,
    },
    docNotes: {
      'Required for location access while the app is in the background',
      'You need to request either ACCESS_FINE_LOCATION or ACCESS_COARSE_LOCATION permission first before requesting ACCESS_BACKGROUND_LOCATION.',
    },
  );

  // Contacts
  static const readContacts = AndroidPermissionDef(
    'android.permission.READ_CONTACTS',
    runtime: true,
    group: 'contacts',
    keywords: {'address', 'phone'},
    docNotes: {'Required to access the user\'s contacts'},
  );
  static const writeContacts = AndroidPermissionDef(
    'android.permission.WRITE_CONTACTS',
    runtime: true,
    group: 'contacts',
    keywords: {'address', 'phone'},
    docNotes: {'Required to modify the user\'s contacts'},
  );
  static const getAccounts = AndroidPermissionDef(
    'android.permission.GET_ACCOUNTS',
    group: 'contacts',
    keywords: {'address', 'phone'},
    docNotes: {'Required to access the list of accounts in the Accounts Service'},
  );

  // Calendar
  static const readCalendar = AndroidPermissionDef(
    'android.permission.READ_CALENDAR',
    runtime: true,
    group: 'calendar',
    keywords: {'events'},
    docNotes: {'Required to access the user\'s calendar events'},
  );

  // this is grouped with calendar if readCalendar is also requested
  static const writeCalendar = AndroidPermissionDef(
    'android.permission.WRITE_CALENDAR',
    runtime: true,
    group: 'calendar_write_only',
    keywords: {'events'},
    docNotes: {'Required to modify the user\'s calendar events'},
  );

  // Phone
  static const readPhoneState = AndroidPermissionDef(
    'android.permission.READ_PHONE_STATE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'state', 'identity', 'carrier'},
    docNotes: {'Required to access phone state information such as network, SIM, and call status'},
  );
  static const readPhoneNumbers = AndroidPermissionDef(
    'android.permission.READ_PHONE_NUMBERS',
    sinceSDK: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'state', 'identity', 'carrier'},
    legacyKeys: {'android.permission.READ_PHONE_STATE': 25},
    docNotes: {'Required to access the phone numbers associated with the device'},
  );
  static const callPhone = AndroidPermissionDef(
    'android.permission.CALL_PHONE',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'dial', 'call', 'outgoing'},
    docNotes: {'Required to initiate phone calls without user intervention'},
  );
  static const answerPhoneCalls = AndroidPermissionDef(
    'android.permission.ANSWER_PHONE_CALLS',
    sinceSDK: 26,
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'answer', 'incoming', 'call'},
    legacyKeys: {'android.permission.READ_PHONE_STATE': 25},
    docNotes: {'Required to answer incoming phone calls programmatically'},
  );
  static const readCallLog = AndroidPermissionDef(
    'android.permission.READ_CALL_LOG',
    runtime: true,
    sinceSDK: 16,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'history', 'log', 'missed'},
    docNotes: {'Required to access the user\'s call log'},
  );
  static const writeCallLog = AndroidPermissionDef(
    'android.permission.WRITE_CALL_LOG',
    runtime: true,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'modify', 'log', 'history'},
    docNotes: {'Required to modify the user\'s call log'},
  );
  static const addVoicemail = AndroidPermissionDef(
    'android.permission.ADD_VOICEMAIL',
    runtime: true,
    sinceSDK: 14,
    group: 'phone',
    service: AssociatedService.phone,
    keywords: {'voicemail', 'message', 'voice'},
    docNotes: {'Required to add voicemails to the voicemail content provider'},
  );

  // SMS
  static const sendSms = AndroidPermissionDef(
    'android.permission.SEND_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'send', 'text', 'message'},
    docNotes: {'Required to send SMS messages from the device'},
  );
  static const receiveSms = AndroidPermissionDef(
    'android.permission.RECEIVE_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'receive', 'message'},
    docNotes: {'Required to receive SMS messages on the device'},
  );
  static const readSms = AndroidPermissionDef(
    'android.permission.READ_SMS',
    runtime: true,
    group: 'sms',
    keywords: {'read', 'inbox', 'message'},
    docNotes: {'Required to read SMS messages stored on the device'},
  );
  static const receiveWapPush = AndroidPermissionDef(
    'android.permission.RECEIVE_WAP_PUSH',
    runtime: true,
    group: 'sms',
    keywords: {'wap', 'push', 'mms'},
    docNotes: {'Required to receive WAP push messages on the device'},
  );
  static const receiveMms = AndroidPermissionDef(
    'android.permission.RECEIVE_MMS',
    runtime: true,
    group: 'sms',
    keywords: {'mms', 'multimedia', 'message'},
    docNotes: {'Required to receive MMS messages on the device'},
  );

  static const accessMediaLocation = AndroidPermissionDef(
    'android.permission.ACCESS_MEDIA_LOCATION',
    runtime: true,
    sinceSDK: 29,
    group: 'media_location',
    keywords: {'metadata', 'location', 'geotag'},
    legacyKeys: {'android.permission.READ_EXTERNAL_STORAGE': 28},
    docNotes: {'Required to access location metadata of media files'},
  );

  // Media
  static const readMediaImages = AndroidPermissionDef(
    'android.permission.READ_MEDIA_IMAGES',
    sinceSDK: 33,
    runtime: true,
    group: 'photos',
    keywords: {'images', 'media', 'storage', 'gallery'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
    docNotes: {
      'Required to read image files from external storage',
      'On Pre-Android 13 devices, this permission is mapped to READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE',
    },
  );
  static const readMediaVideo = AndroidPermissionDef(
    'android.permission.READ_MEDIA_VIDEO',
    sinceSDK: 33,
    runtime: true,
    group: 'videos',
    keywords: {'video', 'playback', 'media', 'storage', 'gallery'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
    docNotes: {
      'Required to read video files from external storage',
      'On Pre-Android 13 devices, this permission is mapped to READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE',
    },
  );
  static const readMediaAudio = AndroidPermissionDef(
    'android.permission.READ_MEDIA_AUDIO',
    sinceSDK: 33,
    runtime: true,
    group: 'audio',
    keywords: {'playback', 'media', 'storage', 'music'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 32,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
    docNotes: {
      'Required to read audio files from external storage',
      'On Pre-Android 13 devices, this permission is mapped to READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE',
    },
  );

  // Manage External Storage (Android 11+)
  static const manageExternalStorage = AndroidPermissionDef(
    'android.permission.MANAGE_EXTERNAL_STORAGE',
    runtime: true,
    sinceSDK: 30,
    group: 'manage_external_storage',
    keywords: {'files', 'manage', 'access'},
    legacyKeys: {
      'android.permission.READ_EXTERNAL_STORAGE': 29,
      'android.permission.WRITE_EXTERNAL_STORAGE': 29,
    },
    docNotes: {
      'Required for broad access to external storage on Android 11 and above',
      'Use with caution as this permission may lead to Play Store policy violations',
    },
  );

  // Battery
  static const ignoreBatteryOptimizations = AndroidPermissionDef(
    'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    sinceSDK: 23,
    group: 'ignore_battery_optimizations',
    keywords: {'battery', 'opt_out', 'power'},
    docNotes: {
      'Allows the app to request exclusion from battery optimizations',
    },
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
    sinceSDK: 33,
    group: 'nearby_wifi_devices',
    keywords: {'nearby', 'scan', 'wifi'},
    docNotes: {
      'Required to discover and connect to nearby Wi-Fi devices',
    },
  );

  // Bluetooth
  static const bluetoothConnect = AndroidPermissionDef(
    'android.permission.BLUETOOTH_CONNECT',
    sinceSDK: 31,
    runtime: true,
    group: 'bluetooth_connect',
    service: AssociatedService.bluetooth,
    keywords: {'connect', 'device'},
    legacyKeys: {
      'android.permission.BLUETOOTH': 30,
      'android.permission.BLUETOOTH_ADMIN': 30,
    },
    docNotes: {
      'Required to connect to paired Bluetooth devices',
      'On Pre-Android 12 devices, this permission is mapped to BLUETOOTH and BLUETOOTH_ADMIN',
      'May also require location permission depending on Android version',
    },
  );
  static const bluetoothScan = AndroidPermissionDef(
    'android.permission.BLUETOOTH_SCAN',
    sinceSDK: 31,
    runtime: true,
    group: 'bluetooth_scan',
    service: AssociatedService.bluetooth,
    keywords: {'scan', 'discover', 'le'},
    legacyKeys: {'android.permission.BLUETOOTH_ADMIN': 30},
    docNotes: {
      'Required to discover and scan for Bluetooth devices',
      'On Pre-Android 12 devices, this permission is mapped to BLUETOOTH_ADMIN',
      'May also require location permission depending on Android version',
    },
  );
  static const bluetoothAdvertise = AndroidPermissionDef(
    'android.permission.BLUETOOTH_ADVERTISE',
    sinceSDK: 31,
    runtime: true,
    group: 'bluetooth_advertise',
    service: AssociatedService.bluetooth,
    keywords: {'advertise', 'broadcast', 'beacon'},
    legacyKeys: {'android.permission.BLUETOOTH_ADMIN': 30},
    docNotes: {
      'Required to advertise the device over Bluetooth',
      'On Pre-Android 12 devices, this permission is mapped to BLUETOOTH_ADMIN',
    },
  );

  // Sensors
  static const bodySensors = AndroidPermissionDef(
    'android.permission.BODY_SENSORS',
    runtime: true,
    sinceSDK: 20,
    group: 'sensors',
    keywords: {'heart', 'bio', 'bpm'},
    docNotes: {'Required to access data from body sensors such as heart rate monitors'},
  );
  static const bodySensorsBackground = AndroidPermissionDef(
    'android.permission.BODY_SENSORS_BACKGROUND',
    runtime: true,
    sinceSDK: 33,
    group: 'sensors_background',
    keywords: {'motion', 'activity', 'sensor'},
    docNotes: {
      'Required to access body sensor data while the app is in the background',
      'You need to request BODY_SENSORS permission first before requesting BODY_SENSORS_BACKGROUND.',
    },
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
    sinceSDK: 23,
    group: 'system_alert_window',
    keywords: {'overlay', 'draw', 'window'},
    docNotes: {
      'Required to display overlays on top of other apps',
      'Also known as "Draw over other apps" permission',
    },
  );
  static const foregroundService = AndroidPermissionDef(
    'android.permission.FOREGROUND_SERVICE',
    sinceSDK: 28,
    group: 'foreground_service',
    keywords: {'service', 'persistent', 'foreground'},
  );
  static const scheduleExactAlarm = AndroidPermissionDef(
    'android.permission.SCHEDULE_EXACT_ALARM',
    sinceSDK: 31,
    group: 'schedule_exact_alarm',
    keywords: {'alarm', 'timer', 'exact'},
  );
  static const postNotifications = AndroidPermissionDef(
    'android.permission.POST_NOTIFICATIONS',
    sinceSDK: 33,
    runtime: true,
    group: 'notifications',
    keywords: {'push', 'alerts'},
    docNotes: {'Required to post notifications to the user on Android 13 and above'},
  );
  static const requestInstallPackages = AndroidPermissionDef(
    'android.permission.REQUEST_INSTALL_PACKAGES',
    sinceSDK: 26,
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
    sinceSDK: 29,
    group: 'activity_recognition',
    keywords: {'activity', 'fitness', 'motion'},
    docNotes: {'Required to access physical activity data such as step count and movement recognition'},
  );

  static final Set<AndroidPermissionDef> all = {
    // Camera
    camera,
    // Microphone
    microphone,
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
