import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class IgnoreBatteryOptimizationsHandler extends KotlinHandlerSnippet {
  IgnoreBatteryOptimizationsHandler()
    : super(
        key: 'ignore_battery_optimizations',
        permissions: [AndroidPermissions.ignoreBatteryOptimizations],
        imports: {'android.os.PowerManager'},
      );

  @override
  String generate(int requestCode) {
    return '''@SuppressLint("InlinedApi")
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
    override fun getStatus(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
            return if (pm.isIgnoringBatteryOptimizations(activity.packageName)) 1 else 0
        }
        return 2 // RESTRICTED
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success(2) // RESTRICTED
            return
        }

        val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        if (pm.isIgnoringBatteryOptimizations(activity.packageName)) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
