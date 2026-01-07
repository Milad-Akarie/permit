import 'package:permit/generate/utils.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/models.dart';

const indent = '    ';

class HandlerSnippet {
  final String key;
  final String requestCode;
  final List<AndroidPermissionDef> permissions;
  final Set<String>? imports;
  HandlerSnippet({
    required this.key,
    required this.requestCode,
    required this.permissions,
    this.imports,
  });

  late final AssociatedService? service = permissions.firstOrNull?.service;

  String get className => '${key.toPascalCase()}Handler';

  late final permissionsArray = permissions.map((perm) {
    final sinceApiParam = perm.sinceApi != null ? ', sinceApi = ${perm.sinceApi}' : '';
    return 'Permission(${perm.key.replaceFirst('android.permission', 'android.Manifest.permission')}$sinceApiParam)';
  });

  String generate() {
    final buffer = StringBuffer();
    buffer.writeln('class $className : PermissionHandler(');
    buffer.writeln('$indent$requestCode, arrayOf(');

    final permissionsArray = permissions.map((perm) {
      final sinceApiParam = perm.sinceApi != null ? ', sinceApi = ${perm.sinceApi}' : '';
      return 'Permission(${perm.key.replaceFirst('android.permission', 'android.Manifest.permission')}$sinceApiParam)';
    });

    for (final perm in permissionsArray) {
      buffer.writeln('$indent$indent$perm,');
    }
    buffer.writeln('$indent)');
    buffer.writeln(')');
    if (service != null) {
      buffer.writeln(' {');
      buffer.writeln('$indent override fun handleServiceStatus(activity: Activity, result: MethodChannel.Result) {');
      buffer.writeln('$indent$indent result.success(ServiceChecker.check${service}Status(activity))');
      buffer.writeln('$indent }');
      buffer.writeln('}');
    }
    return buffer.toString();
  }
}

final customHandlers = <String, HandlerSnippet Function(int requestCode)>{
  AndroidPermissions.systemAlertWindow.group: (requestCode) => SystemAlertWindowHandler(requestCode),
  AndroidPermissions.ignoreBatteryOptimizations.group: (requestCode) => IgnoreBatteryOptimizationsHandler(requestCode),
  AndroidPermissions.manageExternalStorage.group: (requestCode) => ManageExternalStorageHandler(requestCode),
  AndroidPermissions.requestInstallPackages.group: (requestCode) => RequestInstallPackagesHandler(requestCode),
  AndroidPermissions.scheduleExactAlarm.group: (requestCode) => ScheduleExactAlarmHandler(requestCode),
};

class SystemAlertWindowHandler extends HandlerSnippet {
  SystemAlertWindowHandler(int requestCode)
    : super(
        key: 'system_alert_window',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.systemAlertWindow],
      );

  @override
  String generate() {
    return '''
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

class IgnoreBatteryOptimizationsHandler extends HandlerSnippet {
  IgnoreBatteryOptimizationsHandler(int requestCode)
    : super(
        key: 'ignore_battery_optimizations',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.ignoreBatteryOptimizations],
        imports: {'android.os.PowerManager'},
      );

  @override
  String generate() {
    return '''
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

class ManageExternalStorageHandler extends HandlerSnippet {
  ManageExternalStorageHandler(int requestCode)
    : super(
        key: 'manage_external_storage',
        requestCode: '$requestCode',
        permissions: [AndroidPermissions.manageExternalStorage],
        imports: {'android.os.Environment'},
      );

  @override
  String generate() {
    return '''
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

class RequestInstallPackagesHandler extends HandlerSnippet {
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

class ScheduleExactAlarmHandler extends HandlerSnippet {
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
