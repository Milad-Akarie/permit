import 'package:permit/generate/templates/android/handlers/request_install_packages_handler.dart';
import 'package:permit/generate/templates/android/handlers/schedule_exact_alarm_handler.dart';
import 'package:permit/generate/templates/android/handlers/system_alert_window_handler.dart';
import 'package:permit/generate/utils.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/models.dart';

import 'ignore_battery_optimizations_handler.dart';
import 'manage_external_storage_handler.dart';

const indent = '    ';

class KotlinHandlerSnippet {
  final String key;
  final String requestCode;
  final List<AndroidPermissionDef> permissions;
  final Set<String>? imports;

  KotlinHandlerSnippet({
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

final customKotlinHandlers = <String, KotlinHandlerSnippet Function(int requestCode)>{
  AndroidPermissions.systemAlertWindow.group: (requestCode) => SystemAlertWindowHandler(requestCode),
  AndroidPermissions.ignoreBatteryOptimizations.group: (requestCode) => IgnoreBatteryOptimizationsHandler(requestCode),
  AndroidPermissions.manageExternalStorage.group: (requestCode) => ManageExternalStorageHandler(requestCode),
  AndroidPermissions.requestInstallPackages.group: (requestCode) => RequestInstallPackagesHandler(requestCode),
  AndroidPermissions.scheduleExactAlarm.group: (requestCode) => ScheduleExactAlarmHandler(requestCode),
};
