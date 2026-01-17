import 'dart:io';
import 'package:path/path.dart' as path;
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
        expect(code, contains(r'Uri.parse("package:${activity.packageName}")'));
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

    // ...remaining content copied from original handler_templates_test.dart...
  });
}
