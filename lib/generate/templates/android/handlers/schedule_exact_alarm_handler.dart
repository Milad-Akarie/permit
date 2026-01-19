import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

/// Handler for schedule exact alarm permission.
class ScheduleExactAlarmHandler extends KotlinHandlerSnippet {

  /// Constructor for [ScheduleExactAlarmHandler].
  ScheduleExactAlarmHandler()
    : super(
        key: AndroidPermissions.scheduleExactAlarm.group,
        permissions: [AndroidPermissions.scheduleExactAlarm],
        imports: {'android.app.AlarmManager', 'androidx.core.net.toUri'},
      );

  @override
  String generate(int requestCode) {
    return '''class $className : PermissionHandler($requestCode, arrayOf()) {
    override fun getStatus(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            return if (alarmManager.canScheduleExactAlarms()) 1 else 0
        }
        return 1 // GRANTED for older versions
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            result.success(1) // GRANTED
            return
        }

        val alarmManager = activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (alarmManager.canScheduleExactAlarms()) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
            data = "package:\${activity.packageName}".toUri()
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
