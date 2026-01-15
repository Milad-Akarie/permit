import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class ManageExternalStorageHandler extends KotlinHandlerSnippet {
  ManageExternalStorageHandler(int requestCode)
    : super(
        key: 'manage_external_storage',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.manageExternalStorage],
        imports: {'android.os.Environment'},
      );

  @override
  String generate() {
    return '''@SuppressLint("InlinedApi")
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
    override fun getStatus(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return if (Environment.isExternalStorageManager()) 1 else 0
        }
        return 2 // RESTRICTED
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(2) // RESTRICTED
            return
        }

        if (Environment.isExternalStorageManager()) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
