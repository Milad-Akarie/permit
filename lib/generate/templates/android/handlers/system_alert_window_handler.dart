import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

/// Handler for system alert window permission.
class SystemAlertWindowHandler extends KotlinHandlerSnippet {
  /// Constructor for [SystemAlertWindowHandler].
  SystemAlertWindowHandler()
    : super(
        key: AndroidPermissions.systemAlertWindow.group,
        permissions: [AndroidPermissions.systemAlertWindow],
        imports: {'androidx.core.net.toUri'},
      );

  @override
  String generate(int requestCode) {
    return '''class $className : PermissionHandler($requestCode, arrayOf()) {
    override fun getStatus(activity: Activity): Int {
        return if (Settings.canDrawOverlays(activity)) 1 else 0
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Settings.canDrawOverlays(activity)) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
            data = "package:\${activity.packageName}".toUri()
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
