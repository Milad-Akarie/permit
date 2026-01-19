import 'package:permit/generate/templates/android/handlers/request_install_packages_handler.dart';
import 'package:permit/generate/templates/android/handlers/schedule_exact_alarm_handler.dart';
import 'package:permit/generate/templates/android/handlers/system_alert_window_handler.dart';
import 'package:permit/generate/utils.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/models.dart';

import 'ignore_battery_optimizations_handler.dart';
import 'manage_external_storage_handler.dart';

/// Represents a Kotlin permission handler snippet.
const indent = '    ';

/// Represents a Kotlin permission handler snippet.
class KotlinHandlerSnippet {
  /// Constructor for [KotlinHandlerSnippet].
  final String key;

  /// The permissions associated with this handler.
  final List<AndroidPermissionDef> permissions;

  /// The imports required for this handler.
  final Set<String>? imports;

  /// Constructor for [KotlinHandlerSnippet].
  KotlinHandlerSnippet({
    required this.key,
    required this.permissions,
    this.imports,
  });

  /// The associated service, if any.
  late final AssociatedService? service = permissions.firstOrNull?.service;

  /// The class name for this handler.
  String get className => '${key.toPascalCase()}Handler';

  /// The array of permissions for this handler.
  late final permissionsArray = permissions
      .map<List<String>>((perm) {
        final sinceSDKParam = perm.sinceSDK != null ? ', sinceSDK = ${perm.sinceSDK}' : '';
        final array = [
          'Permission(${perm.key.replaceFirst('android.permission', 'android.Manifest.permission')}$sinceSDKParam)',
        ];
        if (perm.legacyKeys != null) {
          for (final legacyEntry in perm.legacyKeys!.entries) {
            final untilSdk = ', untilSDK = ${legacyEntry.value}';
            array.add(
              'Permission(${legacyEntry.key.replaceFirst('android.permission', 'android.Manifest.permission')}$untilSdk)',
            );
          }
        }
        return array;
      })
      .expand((e) => e);

  /// Generates the Kotlin code for this handler.
  String generate(int requestCode) {
    final buffer = StringBuffer();
    buffer.writeln('class $className : PermissionHandler(');
    buffer.writeln('$indent$requestCode, arrayOf(');

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

/// Custom Kotlin handlers for specific permissions.
final customKotlinHandlers = <String, KotlinHandlerSnippet Function()>{
  AndroidPermissions.systemAlertWindow.group: () => SystemAlertWindowHandler(),
  AndroidPermissions.ignoreBatteryOptimizations.group: () => IgnoreBatteryOptimizationsHandler(),
  AndroidPermissions.manageExternalStorage.group: () => ManageExternalStorageHandler(),
  AndroidPermissions.requestInstallPackages.group: () => RequestInstallPackagesHandler(),
  AndroidPermissions.scheduleExactAlarm.group: () => ScheduleExactAlarmHandler(),
};
