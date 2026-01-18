import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class IgnoreBatteryOptimizationsHandler extends KotlinHandlerSnippet {
  IgnoreBatteryOptimizationsHandler()
    : super(
        key: AndroidPermissions.ignoreBatteryOptimizations.group,
        permissions: [AndroidPermissions.ignoreBatteryOptimizations],
        imports: {'android.os.PowerManager', 'androidx.core.net.toUri'},
      );

  @override
  String generate(int requestCode) {
    return '''@SuppressLint("ObsoleteSdkInt","BatteryLife")
class $className : PermissionHandler($requestCode, arrayOf()) {

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
            data = "package:\${activity.packageName}".toUri()
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
