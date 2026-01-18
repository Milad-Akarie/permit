import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class RequestInstallPackagesHandler extends KotlinHandlerSnippet {
  RequestInstallPackagesHandler()
    : super(
        key: AndroidPermissions.requestInstallPackages.group,
        permissions: [AndroidPermissions.requestInstallPackages],
        imports: {'androidx.core.net.toUri'},
      );

  @override
  String generate(int requestCode) {
    return '''class $className : PermissionHandler($requestCode, arrayOf()) {
    override fun getStatus(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return if (activity.packageManager.canRequestPackageInstalls()) 1 else 0
        }
        return 2 // RESTRICTED
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(2) // RESTRICTED
            return
        }

        if (activity.packageManager.canRequestPackageInstalls()) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
            data = "package:\${activity.packageName}".toUri()
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
