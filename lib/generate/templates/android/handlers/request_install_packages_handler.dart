import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class RequestInstallPackagesHandler extends KotlinHandlerSnippet {
  RequestInstallPackagesHandler(int requestCode)
    : super(
        key: 'request_install_packages',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.requestInstallPackages],
      );

  @override
  String generate() {
    return '''
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
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
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
