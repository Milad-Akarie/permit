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
        final handler = SystemAlertWindowHandler();
        final code = handler.generate(1001);

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
        final handler = SystemAlertWindowHandler();
        final code = handler.generate(1001);
        final filePath = path.join(tempDir.path, 'SystemAlertWindowHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
        expect(File(filePath).readAsStringSync(), equals(code));
      });

      test('should use correct request code', () {
        final handler = SystemAlertWindowHandler();
        final code = handler.generate(1001);

        expect(code, contains('1001,'));
      });

      test('should include correct permission', () {
        final handler = SystemAlertWindowHandler();
        final code = handler.generate(2001);

        expect(code, contains('Permission(android.Manifest.permission.SYSTEM_ALERT_WINDOW, sinceSDK = 23)'));
      });

      test('should have valid Kotlin syntax structure', () {
        final handler = SystemAlertWindowHandler();
        final code = handler.generate(1001);

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
        final handler = IgnoreBatteryOptimizationsHandler();
        final code = handler.generate(1002);

        expect(code, contains('class IgnoreBatteryOptimizationsHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.M'));
        expect(code, contains('PowerManager'));
        expect(code, contains('isIgnoringBatteryOptimizations(activity.packageName)'));
        expect(code, contains('Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'));
        expect(code, contains('2 // RESTRICTED'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = IgnoreBatteryOptimizationsHandler();
        final code = handler.generate(1002);
        final filePath = path.join(tempDir.path, 'IgnoreBatteryOptimizationsHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
        final fileContent = File(filePath).readAsStringSync();
        expect(fileContent, equals(code));
      });

      test('should include getStatus override', () {
        final handler = IgnoreBatteryOptimizationsHandler();
        final code = handler.generate(1002);

        expect(code, contains('override fun getStatus(activity: Activity): Int {'));
        expect(code, contains('val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager'));
      });

      test('should check Android version before using PowerManager', () {
        final handler = IgnoreBatteryOptimizationsHandler();
        final code = handler.generate(1002);

        expect(code, contains('if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {'));
        expect(code, contains('return 2 // RESTRICTED'));
      });

      test('should have valid Kotlin syntax', () {
        final handler = IgnoreBatteryOptimizationsHandler();
        final code = handler.generate(1002);

        final openBraces = '{'.allMatches(code).length;
        final closeBraces = '}'.allMatches(code).length;
        expect(openBraces, equals(closeBraces));
      });
    });

    group('ManageExternalStorageHandler', () {
      test('should generate valid Kotlin code with Environment checks', () {
        final handler = ManageExternalStorageHandler();
        final code = handler.generate(1003);

        expect(code, contains('class ManageExternalStorageHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.R'));
        expect(code, contains('Environment.isExternalStorageManager()'));
        expect(code, contains('Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = ManageExternalStorageHandler();
        final code = handler.generate(1003);
        final filePath = path.join(tempDir.path, 'ManageExternalStorageHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 11+', () {
        final handler = ManageExternalStorageHandler();
        final code = handler.generate(1003);

        expect(code, contains('Build.VERSION_CODES.R'));
      });
    });

    group('RequestInstallPackagesHandler', () {
      test('should generate valid Kotlin code with PackageManager checks', () {
        final handler = RequestInstallPackagesHandler();
        final code = handler.generate(1004);

        expect(code, contains('class RequestInstallPackagesHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.O'));
        expect(code, contains('activity.packageManager.canRequestPackageInstalls()'));
        expect(code, contains('Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = RequestInstallPackagesHandler();
        final code = handler.generate(1004);
        final filePath = path.join(tempDir.path, 'RequestInstallPackagesHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 8+', () {
        final handler = RequestInstallPackagesHandler();
        final code = handler.generate(1004);

        expect(code, contains('Build.VERSION_CODES.O'));
      });
    });

    group('ScheduleExactAlarmHandler', () {
      test('should generate valid Kotlin code with AlarmManager checks', () {
        final handler = ScheduleExactAlarmHandler();
        final code = handler.generate(1005);

        expect(code, contains('class ScheduleExactAlarmHandler : PermissionHandler('));
        expect(code, contains('Build.VERSION.SDK_INT >= Build.VERSION_CODES.S'));
        expect(code, contains('AlarmManager'));
        expect(code, contains('alarmManager.canScheduleExactAlarms()'));
        expect(code, contains('Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM'));
      });

      test('should write valid Kotlin code to file', () {
        final handler = ScheduleExactAlarmHandler();
        final code = handler.generate(1005);
        final filePath = path.join(tempDir.path, 'ScheduleExactAlarmHandler.kt');

        File(filePath).writeAsStringSync(code);

        expect(File(filePath).existsSync(), isTrue);
      });

      test('should check for Android 12+', () {
        final handler = ScheduleExactAlarmHandler();
        final code = handler.generate(1005);

        expect(code, contains('Build.VERSION_CODES.S'));
      });

      test('should default to GRANTED for older versions', () {
        final handler = ScheduleExactAlarmHandler();
        final code = handler.generate(1005);

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
        final sawHandler = customKotlinHandlers['system_alert_window']!();
        expect(sawHandler, isA<SystemAlertWindowHandler>());
        expect(sawHandler.className, equals('SystemAlertWindowHandler'));

        final bioHandler = customKotlinHandlers['ignore_battery_optimizations']!();
        expect(bioHandler, isA<IgnoreBatteryOptimizationsHandler>());
        expect(bioHandler.className, equals('IgnoreBatteryOptimizationsHandler'));

        final mesHandler = customKotlinHandlers['manage_external_storage']!();
        expect(mesHandler, isA<ManageExternalStorageHandler>());
        expect(mesHandler.className, equals('ManageExternalStorageHandler'));

        final ripHandler = customKotlinHandlers['request_install_packages']!();
        expect(ripHandler, isA<RequestInstallPackagesHandler>());
        expect(ripHandler.className, equals('RequestInstallPackagesHandler'));

        final seaHandler = customKotlinHandlers['schedule_exact_alarm']!();
        expect(seaHandler, isA<ScheduleExactAlarmHandler>());
        expect(seaHandler.className, equals('ScheduleExactAlarmHandler'));
      });
    });

    group('Code generation to temp directory', () {
      test('should generate all handler files successfully', () {
        final handlers = [
          SystemAlertWindowHandler(),
          IgnoreBatteryOptimizationsHandler(),
          ManageExternalStorageHandler(),
          RequestInstallPackagesHandler(),
          ScheduleExactAlarmHandler(),
        ];

        final files = <String>[];
        for (var i = 0; i < handlers.length; i++) {
          final handler = handlers[i];
          final code = handler.generate(1001 + i);
          final filePath = path.join(tempDir.path, '${handler.className}.kt');
          files.add(filePath);
          File(filePath).writeAsStringSync(code);
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
          SystemAlertWindowHandler(),
          IgnoreBatteryOptimizationsHandler(),
          ManageExternalStorageHandler(),
          RequestInstallPackagesHandler(),
          ScheduleExactAlarmHandler(),
        ];

        for (var i = 0; i < handlers.length; i++) {
          final handler = handlers[i];
          buffer.writeln(handler.generate(1001 + i));
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
          SystemAlertWindowHandler(),
          IgnoreBatteryOptimizationsHandler(),
          ManageExternalStorageHandler(),
          RequestInstallPackagesHandler(),
          ScheduleExactAlarmHandler(),
        ];

        for (var i = 0; i < handlers.length; i++) {
          final handler = handlers[i];
          final code = handler.generate(1001 + i);

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
          SystemAlertWindowHandler(),
          IgnoreBatteryOptimizationsHandler(),
          ManageExternalStorageHandler(),
          RequestInstallPackagesHandler(),
          ScheduleExactAlarmHandler(),
        ];

        for (var i = 0; i < handlers.length; i++) {
          final handler = handlers[i];
          final code = handler.generate(1001 + i);

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
        final sawHandler = SystemAlertWindowHandler();
        final sawCode = sawHandler.generate(1001);
        expect(sawCode, contains('1 else 0')); // GRANTED: 1, DENIED: 0

        final bioHandler = IgnoreBatteryOptimizationsHandler();
        final bioCode = bioHandler.generate(1002);
        expect(bioCode, contains('2 // RESTRICTED')); // Return RESTRICTED for unsupported

        final seaHandler = ScheduleExactAlarmHandler();
        final seaCode = seaHandler.generate(1005);
        expect(seaCode, contains('1 // GRANTED for older versions')); // Default to GRANTED
      });

      test('should use correct Settings actions', () {
        expect(SystemAlertWindowHandler().generate(1001), contains('Settings.ACTION_MANAGE_OVERLAY_PERMISSION'));
        expect(
          IgnoreBatteryOptimizationsHandler().generate(1002),
          contains('Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
        );
        expect(
          ManageExternalStorageHandler().generate(1003),
          contains('Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'),
        );
        expect(RequestInstallPackagesHandler().generate(1004), contains('Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES'));
        expect(ScheduleExactAlarmHandler().generate(1005), contains('Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM'));
      });
    });
  });
}
