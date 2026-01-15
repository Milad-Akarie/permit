import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class ScheduleExactAlarmHandler extends KotlinHandlerSnippet {
  ScheduleExactAlarmHandler(int requestCode)
    : super(
        key: 'schedule_exact_alarm',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.scheduleExactAlarm],
        imports: {'android.app.AlarmManager'},
      );

  @override
  String generate() {
    return '''
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
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
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
