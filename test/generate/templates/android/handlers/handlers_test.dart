import 'package:permit/generate/templates/android/handlers/ignore_battery_optimizations_handler.dart';
import 'package:permit/generate/templates/android/handlers/manage_external_storage_handler.dart';
import 'package:permit/generate/templates/android/handlers/request_install_packages_handler.dart';
import 'package:permit/generate/templates/android/handlers/schedule_exact_alarm_handler.dart';
import 'package:permit/generate/templates/android/handlers/system_alert_window_handler.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:test/test.dart';

void main() {
  group('Android Permission Handlers', () {
    test('IgnoreBatteryOptimizationsHandler generates correct code', () {
      final handler = IgnoreBatteryOptimizationsHandler();
      expect(
        handler.key,
        equals(AndroidPermissions.ignoreBatteryOptimizations.group),
      );
      expect(handler.imports, contains('android.os.PowerManager'));

      final code = handler.generate(1001);
      expect(code, contains('class IgnoreBatteryOptimizationsHandler'));
      expect(code, contains('ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'));
      expect(code, contains('PermissionHandler(1001, arrayOf())'));
    });

    test('ManageExternalStorageHandler generates correct code', () {
      final handler = ManageExternalStorageHandler();
      expect(
        handler.key,
        equals(AndroidPermissions.manageExternalStorage.group),
      );
      expect(handler.imports, contains('android.os.Environment'));

      final code = handler.generate(1002);
      expect(code, contains('class ManageExternalStorageHandler'));
      expect(code, contains('ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'));
      // This permission is special and shouldn't satisfy the default check in permissions array
      // But generate() method modifies permissions list locally? No, permissions is final in parent.
      // Wait, the generate method in ManageExternalStorageHandler does: permissions.removeWhere
      // We check if code reflects that.
      expect(code, contains('Environment.isExternalStorageManager()'));
    });

    test('RequestInstallPackagesHandler generates correct code', () {
      final handler = RequestInstallPackagesHandler();
      expect(
        handler.key,
        equals(AndroidPermissions.requestInstallPackages.group),
      );
      expect(handler.imports, contains('androidx.core.net.toUri'));

      final code = handler.generate(1003);
      expect(code, contains('class RequestInstallPackagesHandler'));
      expect(code, contains('ACTION_MANAGE_UNKNOWN_APP_SOURCES'));
      expect(code, contains('canRequestPackageInstalls()'));
    });

    test('ScheduleExactAlarmHandler generates correct code', () {
      final handler = ScheduleExactAlarmHandler();
      expect(handler.key, equals(AndroidPermissions.scheduleExactAlarm.group));
      expect(handler.imports, contains('android.app.AlarmManager'));

      final code = handler.generate(1004);
      expect(code, contains('class ScheduleExactAlarmHandler'));
      expect(code, contains('ACTION_REQUEST_SCHEDULE_EXACT_ALARM'));
      expect(code, contains('canScheduleExactAlarms()'));
    });

    test('SystemAlertWindowHandler generates correct code', () {
      final handler = SystemAlertWindowHandler();
      expect(handler.key, equals(AndroidPermissions.systemAlertWindow.group));
      expect(handler.imports, contains('androidx.core.net.toUri'));

      final code = handler.generate(1005);
      expect(code, contains('class SystemAlertWindowHandler'));
      expect(code, contains('ACTION_MANAGE_OVERLAY_PERMISSION'));
      expect(code, contains('Settings.canDrawOverlays(activity)'));
    });
  });
}
