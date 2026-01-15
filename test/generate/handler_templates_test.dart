import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permit/generate/templates/android/handlers/ignore_battery_optimizations_handler.dart';
import 'package:permit/generate/templates/android/handlers/kotlin_handler_snippet.dart';
import 'package:permit/generate/templates/android/handlers/manage_external_storage_handler.dart';
import 'package:permit/generate/templates/android/handlers/request_install_packages_handler.dart';
import 'package:permit/generate/templates/android/handlers/schedule_exact_alarm_handler.dart';
import 'package:permit/generate/templates/android/handlers/system_alert_window_handler.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('handler_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Handler Templates - Code Generation', () {
    group('SystemAlertWindowHandler', () {
      test('should generate valid Kotlin code with getStatus and handleRequest', () {
        final handler = SystemAlertWindowHandler(1001);
        final code = handler.generate();

        expect(code, contains('class SystemAlertWindowHandler : PermissionHandler('));
        expect(code, contains('override fun getStatus(activity: Activity): Int {'));
        expect(code, contains('Settings.canDrawOverlays(activity)'));
        expect(code, contains('override fun handleRequest(activity: Activity, result: MethodChannel.Result)'));
        expect(code, contains('Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)'));
        expect(code, contains('Uri.parse("package:\${activity.packageName}")'));
        expect(code, contains('activity.startActivityForResult(intent, requestCode)'));
        expect(code, contains('pendingResult = result'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = SystemAlertWindowHandler(1001);
        final code = handler.generate();
        final filePath = path.join(tempDir.path, 'SystemAlertWindowHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
        expect(File(filePath).readAsStringSync(), equals(code));
      });

      test('should use correct request code', () {
        final handler = SystemAlertWindowHandler(1001);
        final code = handler.generate();

        expect(code, contains('1001,'));
      });

      test('should include correct permission', () {
        final handler = SystemAlertWindowHandler(2001);
        final code = handler.generate();

        expect(code, contains('Permission(android.Manifest.permission.SYSTEM_ALERT_WINDOW)'));
      });

      test('should have valid Kotlin syntax structure', () {
        final handler = SystemAlertWindowHandler(1001);
        final code = handler.generate();

        // Check balanced braces
        final openBraces = '{'.allMatches(code).length;
        final closeBraces = '}'.allMatches(code).length;
        expect(openBraces, equals(closeBraces), reason: 'Unbalanced braces in generated code');

        // Check balanced parentheses
        final openParens = '('.allMatches(code).length;
        final closeParens = ')'.allMatches(code).length;
        expect(openParens, equals(closeParens), reason: 'Unbalanced parentheses in generated code');
      });
    });

    group('IgnoreBatteryOptimizationsHandler', () {
      test('should generate valid Kotlin code with API level checks', () {
        final handler = IgnoreBatteryOptimizationsHandler(1002);
        final code = handler.generate();

        expect(code, contains('class IgnoreBatteryOptimizationsHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.M'));
        expect(code, contains('PowerManager'));
        expect(code, contains('isIgnoringBatteryOptimizations(activity.packageName)'));
        expect(code, contains('Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'));
        expect(code, contains('2 // RESTRICTED'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = IgnoreBatteryOptimizationsHandler(1002);
        final code = handler.generate();
        final filePath = path.join(tempDir.path, 'IgnoreBatteryOptimizationsHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
        final fileContent = File(filePath).readAsStringSync();
        expect(fileContent, equals(code));
      });

      test('should include getStatus override', () {
        final handler = IgnoreBatteryOptimizationsHandler(1002);
        final code = handler.generate();

        expect(code, contains('override fun getStatus(activity: Activity): Int {'));
        expect(code, contains('val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager'));
      });

      test('should check Android version before using PowerManager', () {
        final handler = IgnoreBatteryOptimizationsHandler(1002);
        final code = handler.generate();

        expect(code, contains('if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {'));
        expect(code, contains('return 2 // RESTRICTED'));
      });

      test('should have valid Kotlin syntax', () {
        final handler = IgnoreBatteryOptimizationsHandler(1002);
        final code = handler.generate();

        final openBraces = '{'.allMatches(code).length;
        final closeBraces = '}'.allMatches(code).length;
        expect(openBraces, equals(closeBraces));
      });
    });

    group('ManageExternalStorageHandler', () {
      test('should generate valid Kotlin code with Environment checks', () {
        final handler = ManageExternalStorageHandler(1003);
        final code = handler.generate();

        expect(code, contains('class ManageExternalStorageHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.R'));
        expect(code, contains('Environment.isExternalStorageManager()'));
        expect(code, contains('Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = ManageExternalStorageHandler(1003);
        final code = handler.generate();
        final filePath = path.join(tempDir.path, 'ManageExternalStorageHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 11+', () {
        final handler = ManageExternalStorageHandler(1003);
        final code = handler.generate();

        expect(code, contains('Build.VERSION_CODES.R'));
      });
    });

    group('RequestInstallPackagesHandler', () {
      test('should generate valid Kotlin code with PackageManager checks', () {
        final handler = RequestInstallPackagesHandler(1004);
        final code = handler.generate();

        expect(code, contains('class RequestInstallPackagesHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.O'));
        expect(code, contains('activity.packageManager.canRequestPackageInstalls()'));
        expect(code, contains('Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = RequestInstallPackagesHandler(1004);
        final code = handler.generate();
        final filePath = path.join(tempDir.path, 'RequestInstallPackagesHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 8+', () {
        final handler = RequestInstallPackagesHandler(1004);
        final code = handler.generate();

        expect(code, contains('Build.VERSION_CODES.O'));
      });
    });

    group('ScheduleExactAlarmHandler', () {
      test('should generate valid Kotlin code with AlarmManager checks', () {
        final handler = ScheduleExactAlarmHandler(1005);
        final code = handler.generate();

        expect(code, contains('class ScheduleExactAlarmHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.S'));
        expect(code, contains('AlarmManager'));
        expect(code, contains('alarmManager.canScheduleExactAlarms()'));
        expect(code, contains('Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = ScheduleExactAlarmHandler(1005);
        final code = handler.generate();
        final filePath = path.join(tempDir.path, 'ScheduleExactAlarmHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 12+', () {
        final handler = ScheduleExactAlarmHandler(1005);
        final code = handler.generate();

        expect(code, contains('Build.VERSION_CODES.S'));
      });

      test('should default to GRANTED for older versions', () {
        final handler = ScheduleExactAlarmHandler(1005);
        final code = handler.generate();

        expect(code, contains('return 1 // GRANTED for older versions'));
      });
    });

    group('customHandlers map', () {
      test('should have all 5 custom handlers', () {
        expect(customKotlinHandlers.length, equals(5));
      });

      test('should have system_alert_window handler', () {
        expect(customKotlinHandlers.containsKey('system_alert_window'), isTrue);
      });

      test('should have ignore_battery_optimizations handler', () {
        expect(customKotlinHandlers.containsKey('ignore_battery_optimizations'), isTrue);
      });

      test('should have manage_external_storage handler', () {
        expect(customKotlinHandlers.containsKey('manage_external_storage'), isTrue);
      });

      test('should have request_install_packages handler', () {
        expect(customKotlinHandlers.containsKey('request_install_packages'), isTrue);
      });

      test('should have schedule_exact_alarm handler', () {
        expect(customKotlinHandlers.containsKey('schedule_exact_alarm'), isTrue);
      });

      test('should create correct handler instances', () {
        final sawHandler = customKotlinHandlers['system_alert_window']!(1001);
        expect(sawHandler, isA<SystemAlertWindowHandler>());
        expect(sawHandler.className, equals('SystemAlertWindowHandler'));

        final bioHandler = customKotlinHandlers['ignore_battery_optimizations']!(1002);
        expect(bioHandler, isA<IgnoreBatteryOptimizationsHandler>());
        expect(bioHandler.className, equals('IgnoreBatteryOptimizationsHandler'));

        final mesHandler = customKotlinHandlers['manage_external_storage']!(1003);
        expect(mesHandler, isA<ManageExternalStorageHandler>());
        expect(mesHandler.className, equals('ManageExternalStorageHandler'));

        final ripHandler = customKotlinHandlers['request_install_packages']!(1004);
        expect(ripHandler, isA<RequestInstallPackagesHandler>());
        expect(ripHandler.className, equals('RequestInstallPackagesHandler'));

        final seaHandler = customKotlinHandlers['schedule_exact_alarm']!(1005);
        expect(seaHandler, isA<ScheduleExactAlarmHandler>());
        expect(seaHandler.className, equals('ScheduleExactAlarmHandler'));
      });
    });

    group('Code generation to temp directory', () {
      test('should generate all handler files successfully', () {
        final handlers = [
          SystemAlertWindowHandler(1001),
          IgnoreBatteryOptimizationsHandler(1002),
          ManageExternalStorageHandler(1003),
          RequestInstallPackagesHandler(1004),
          ScheduleExactAlarmHandler(1005),
        ];

        final files = <String>[];
        for (final handler in handlers) {
          final code = handler.generate();
          final filePath = path.join(tempDir.path, '${handler.className}.kt');
          File(filePath).writeAsStringSync(code);
          files.add(filePath);
        }

        // Verify all files were created
        expect(files.length, equals(5));
        for (final filePath in files) {
          expect(File(filePath).existsSync(), isTrue, reason: 'File $filePath was not created');
        }
      });

      test('should generate valid combined handler registry', () {
        final buffer = StringBuffer();
        buffer.writeln('package com.example.permit');
        buffer.writeln('');
        buffer.writeln('import android.app.Activity');
        buffer.writeln('import android.provider.Settings');
        buffer.writeln('import android.content.Intent');
        buffer.writeln('import android.net.Uri');
        buffer.writeln('import android.os.Build');
        buffer.writeln('import android.os.PowerManager');
        buffer.writeln('import android.os.Environment');
        buffer.writeln('import android.app.AlarmManager');
        buffer.writeln('import android.content.Context');
        buffer.writeln('import io.flutter.embedding.engine.FlutterEngine');
        buffer.writeln('import io.flutter.plugin.common.MethodChannel');
        buffer.writeln('');
        buffer.writeln('// Generated Handler Registry');
        buffer.writeln('object HandlerRegistry {');
        buffer.writeln('');

        final handlers = [
          SystemAlertWindowHandler(1001),
          IgnoreBatteryOptimizationsHandler(1002),
          ManageExternalStorageHandler(1003),
          RequestInstallPackagesHandler(1004),
          ScheduleExactAlarmHandler(1005),
        ];

        for (final handler in handlers) {
          buffer.writeln(handler.generate());
          buffer.writeln('');
        }

        buffer.writeln('}');

        final registryPath = path.join(tempDir.path, 'HandlerRegistry.kt');
        File(registryPath).writeAsStringSync(buffer.toString());

        expect(File(registryPath).existsSync(), isTrue);
        final content = File(registryPath).readAsStringSync();

        // Verify structure
        expect(content, contains('package com.example.permit'));
        expect(content, contains('object HandlerRegistry {'));
        expect(content, contains('class SystemAlertWindowHandler'));
        expect(content, contains('class IgnoreBatteryOptimizationsHandler'));
        expect(content, contains('class ManageExternalStorageHandler'));
        expect(content, contains('class RequestInstallPackagesHandler'));
        expect(content, contains('class ScheduleExactAlarmHandler'));
      });

      test('should verify all handler classes have correct structure', () {
        final handlers = [
          SystemAlertWindowHandler(1001),
          IgnoreBatteryOptimizationsHandler(1002),
          ManageExternalStorageHandler(1003),
          RequestInstallPackagesHandler(1004),
          ScheduleExactAlarmHandler(1005),
        ];

        for (final handler in handlers) {
          final code = handler.generate();

          // Every handler should have these methods
          expect(
            code,
            contains('override fun getStatus(activity: Activity): Int'),
            reason: '${handler.className} missing getStatus method',
          );
          expect(
            code,
            contains('override fun handleRequest(activity: Activity, result: MethodChannel.Result)'),
            reason: '${handler.className} missing handleRequest method',
          );

          // Verify permission is present
          expect(
            code,
            contains('Permission(android.Manifest.permission.'),
            reason: '${handler.className} missing permission declaration',
          );

          // Verify syntax
          final openBraces = '{'.allMatches(code).length;
          final closeBraces = '}'.allMatches(code).length;
          expect(openBraces, equals(closeBraces), reason: '${handler.className} has unbalanced braces');
        }
      });
    });

    group('Handler code patterns', () {
      test('should use consistent Intent pattern', () {
        final handlers = [
          SystemAlertWindowHandler(1001),
          IgnoreBatteryOptimizationsHandler(1002),
          ManageExternalStorageHandler(1003),
          RequestInstallPackagesHandler(1004),
          ScheduleExactAlarmHandler(1005),
        ];

        for (final handler in handlers) {
          final code = handler.generate();

          // All should use Intent and Uri for launching settings
          expect(code, contains('Intent('), reason: '${handler.className} missing Intent instantiation');
          expect(
            code,
            contains('Uri.parse("package:\${activity.packageName}")'),
            reason: '${handler.className} missing Uri parsing',
          );
          expect(
            code,
            contains('activity.startActivityForResult(intent, requestCode)'),
            reason: '${handler.className} missing startActivityForResult',
          );
        }
      });

      test('should include proper status codes', () {
        final sawHandler = SystemAlertWindowHandler(1001);
        final sawCode = sawHandler.generate();
        expect(sawCode, contains('1 else 0')); // GRANTED: 1, DENIED: 0

        final bioHandler = IgnoreBatteryOptimizationsHandler(1002);
        final bioCode = bioHandler.generate();
        expect(bioCode, contains('2 // RESTRICTED')); // Return RESTRICTED for unsupported

        final seaHandler = ScheduleExactAlarmHandler(1005);
        final seaCode = seaHandler.generate();
        expect(seaCode, contains('1 // GRANTED for older versions')); // Default to GRANTED
      });

      test('should use correct Settings actions', () {
        expect(SystemAlertWindowHandler(1001).generate(), contains('Settings.ACTION_MANAGE_OVERLAY_PERMISSION'));
        expect(
          IgnoreBatteryOptimizationsHandler(1002).generate(),
          contains('Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
        );
        expect(
          ManageExternalStorageHandler(1003).generate(),
          contains('Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'),
        );
        expect(RequestInstallPackagesHandler(1004).generate(), contains('Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES'));
        expect(ScheduleExactAlarmHandler(1005).generate(), contains('Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM'));
      });
    });
  });
}
