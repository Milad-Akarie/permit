import 'dart:io';

import 'package:permit/generate/plugin_generator.dart';
import 'package:permit/path/path_finder.dart';
import 'package:test/test.dart';

void main() {
  group('PluginGenerator.generate (with templates)', () {
    late Directory root;
    late PathFinderImpl pf;

    setUp(() {
      root = Directory.systemTemp.createTempSync('permit_full_gen_');
      // Create pubspec
      File('${root.path}/pubspec.yaml').createSync();
      File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: test_app
dependencies:
  flutter:
    sdk: flutter
''');

      // Create AndroidManifest
      final androidMain = Directory('${root.path}/android/app/src/main')..createSync(recursive: true);
      File('${androidMain.path}/AndroidManifest.xml').writeAsStringSync('''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <!-- @permit:code -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <application android:label="test_app"/>
</manifest>
''');

      // Create Info.plist
      final iosRunner = Directory('${root.path}/ios/Runner')..createSync(recursive: true);
      File('${iosRunner.path}/Info.plist').writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.example.test_app</string>
    <!-- @permit:code -->
    <key>NSCameraUsageDescription</key>
    <string>Camera access</string>
</dict>
</plist>
''');

      pf = PathFinderImpl(root);
    });

    tearDown(() {
      try {
        root.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('generates plugin code structure and updates pubspec', () {
      final generator = PluginGenerator(pathFinder: pf);
      generator.generate();

      // Check tools/permit_plugin created
      final pluginDir = Directory('${root.path}/tools/permit_plugin');
      expect(pluginDir.existsSync(), isTrue);

      // Check Android generated code
      final androidDir = Directory('${pluginDir.path}/android');
      expect(androidDir.existsSync(), isTrue);
      // specific file checks
      // PluginGradleTemp generates .kts
      if (!File('${androidDir.path}/build.gradle.kts').existsSync()) {
        print('Android Dir contents:');
        if (androidDir.existsSync()) {
          androidDir.listSync(recursive: true).forEach((e) => print(e.path));
        } else {
          print('Android dir does not exist');
        }
      }
      expect(File('${androidDir.path}/build.gradle.kts').existsSync(), isTrue);

      if (!File(
        '${androidDir.path}/src/main/AndroidManifest.xml',
      ).existsSync()) {
        print('Manifest missing. Android Dir contents:');
        androidDir.listSync(recursive: true).forEach((e) => print(e.path));
      }
      expect(
        File('${androidDir.path}/src/main/AndroidManifest.xml').existsSync(),
        isTrue,
      );
      // Kotlin class should exist (Camera handler code generated)
      final kotlinFiles = androidDir.listSync(recursive: true).where((e) => e.path.endsWith('.kt'));
      expect(kotlinFiles, isNotEmpty);

      // Check iOS generated code
      final iosDir = Directory('${pluginDir.path}/ios');
      expect(iosDir.existsSync(), isTrue);
      expect(File('${iosDir.path}/permit_plugin.podspec').existsSync(), isTrue);
      // Swift class (Camera handler code generated)
      final swiftFiles = iosDir.listSync(recursive: true).where((e) => e.path.endsWith('.swift'));
      expect(swiftFiles, isNotEmpty);

      // Check lib/permit_plugin.dart generated
      expect(
        File('${pluginDir.path}/lib/permit.dart').existsSync(),
        isTrue,
      );

      // Check pubspec.yaml updated
      final pubspecContent = File(
        '${root.path}/pubspec.yaml',
      ).readAsStringSync();

      if (!pubspecContent.contains('tools/permit_plugin')) {
        print('Pubspec content mismatch. Actual content:\n$pubspecContent');
      }
      expect(pubspecContent, contains('permit_plugin:'));
      expect(pubspecContent, contains('tools/permit_plugin'));
    });
  });
}
