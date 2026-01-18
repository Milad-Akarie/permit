import 'package:permit/registry/android_permissions.dart';

import 'kotlin_handler_snippet.dart';

class ManageExternalStorageHandler extends KotlinHandlerSnippet {
  ManageExternalStorageHandler()
    : super(
        key: AndroidPermissions.manageExternalStorage.group,
        permissions: [AndroidPermissions.manageExternalStorage],
        imports: {'android.os.Environment', 'androidx.core.net.toUri'},
      );

  @override
  Iterable<String> get permissionsArray => {};

  @override
  String generate(int requestCode) {
    // this permission requires special handling, it's not requested like normal permissions
    permissions.removeWhere((e) => e.key == AndroidPermissions.manageExternalStorage.key);
    return '''@SuppressLint("InlinedApi")
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
    override fun getStatus(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return if (Environment.isExternalStorageManager()) 1 else 0
        }
        return super.getStatus(activity)
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            super.handleRequest(activity, result)
            return
        }

        if (Environment.isExternalStorageManager()) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
            data = "package:\${activity.packageName}".toUri()
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
