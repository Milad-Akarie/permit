import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class SystemAlertWindowHandler extends KotlinHandlerSnippet {
  SystemAlertWindowHandler()
    : super(
        key: 'system_alert_window',
        permissions: [AndroidPermissions.systemAlertWindow],
      );

  @override
  String generate(int requestCode) {
    return '''@SuppressLint("InlinedApi")
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
    override fun getStatus(activity: Activity): Int {
        return if (Settings.canDrawOverlays(activity)) 1 else 0
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Settings.canDrawOverlays(activity)) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
