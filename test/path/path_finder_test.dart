import 'dart:io';
import 'package:test/test.dart';
import 'package:permit/path/path_finder.dart';

void main() {
  group('PathFinder', () {
    late PathFinder pathFinder;

    setUp(() {
      pathFinder = PathFinderImpl(
        Directory.systemTemp.createTempSync('permit_test_'),
      );
    });

    tearDown(() {
      try {
        pathFinder.root.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('getManifest returns null when android/app missing', () {
      final result = pathFinder.getManifest();
      expect(result, isNull);
    });

    test('getManifest finds conventional manifest', () {
      final androidApp = Directory('${pathFinder.root.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/src/main/AndroidManifest.xml')
        ..createSync(recursive: true)
        ..writeAsStringSync('<manifest><application></application></manifest>');

      final result = pathFinder.getManifest();
      expect(result, isNotNull);
      expect(result!.path, contains('AndroidManifest.xml'));
    });

    test('getManifest respects custom manifest in build.gradle', () {
      final androidApp = Directory('${pathFinder.root.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          "manifest.srcFile 'src/custom/AndroidManifest.xml'",
        );
      File('${androidApp.path}/src/custom/AndroidManifest.xml')
        ..createSync(recursive: true)
        ..writeAsStringSync('<manifest><application></application></manifest>');

      final result = pathFinder.getManifest();
      expect(result, isNotNull);
      expect(result!.path, contains('AndroidManifest.xml'));
    });

    test('getInfoPlist returns null when ios missing', () {
      final result = pathFinder.getInfoPlist();
      expect(result, isNull);
    });

    test('getInfoPlist finds conventional Info.plist', () {
      final iosRunner = Directory('${pathFinder.root.path}/ios/Runner')
        ..createSync(recursive: true);
      File('${iosRunner.path}/Info.plist')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<?xml version="1.0"?><plist><dict><key>CFBundle</key></dict></plist>',
        );

      final result = pathFinder.getInfoPlist();
      expect(result, isNotNull);
      expect(result!.path, contains('Info.plist'));
    });

    test(
      'getManifest respects custom manifest with parentheses (double quotes)',
      () {
        final androidApp = Directory('${pathFinder.root.path}/android/app')
          ..createSync(recursive: true);
        File('${androidApp.path}/build.gradle')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            'manifest.srcFile("src/custom/AndroidManifest.xml")',
          );

        File('${androidApp.path}/src/custom/AndroidManifest.xml')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<manifest><application></application></manifest>',
          );

        final result = pathFinder.getManifest();
        expect(result, isNotNull);
        expect(result!.path, endsWith('src/custom/AndroidManifest.xml'));
      },
    );

    test(
      'getManifest respects custom manifest with parentheses (single quotes)',
      () {
        final androidApp = Directory('${pathFinder.root.path}/android/app')
          ..createSync(recursive: true);
        File('${androidApp.path}/build.gradle')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            "manifest.srcFile('src/custom/AndroidManifest.xml')",
          );

        File('${androidApp.path}/src/custom/AndroidManifest.xml')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<manifest><application></application></manifest>',
          );

        final result = pathFinder.getManifest();
        expect(result, isNotNull);
        expect(result!.path, endsWith('src/custom/AndroidManifest.xml'));
      },
    );

    test('getManifest respects custom manifest with equals sign', () {
      final androidApp = Directory('${pathFinder.root.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          'manifest.srcFile = "src/custom/AndroidManifest.xml"',
        );

      File('${androidApp.path}/src/custom/AndroidManifest.xml')
        ..createSync(recursive: true)
        ..writeAsStringSync('<manifest><application></application></manifest>');

      final result = pathFinder.getManifest();
      expect(result, isNotNull);
      expect(result!.path, endsWith('src/custom/AndroidManifest.xml'));
    });

    test('getManifest respects custom manifest in build.gradle.kts', () {
      final androidApp = Directory('${pathFinder.root.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle.kts')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          'manifest.srcFile("src/custom/AndroidManifest.xml")',
        );

      File('${androidApp.path}/src/custom/AndroidManifest.xml')
        ..createSync(recursive: true)
        ..writeAsStringSync('<manifest><application></application></manifest>');

      final result = pathFinder.getManifest();
      expect(result, isNotNull);
      expect(result!.path, endsWith('src/custom/AndroidManifest.xml'));
    });

    test('getManifest handles whitespace variations', () {
      final androidApp = Directory('${pathFinder.root.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          'manifest.srcFile  (  "src/custom/AndroidManifest.xml"  )',
        );

      File('${androidApp.path}/src/custom/AndroidManifest.xml')
        ..createSync(recursive: true)
        ..writeAsStringSync('<manifest><application></application></manifest>');

      final result = pathFinder.getManifest();
      expect(result, isNotNull);
      expect(result!.path, endsWith('src/custom/AndroidManifest.xml'));
    });
    test('getInfoPlist finds custom INFOPLIST_FILE in project.pbxproj', () {
      final iosDir = Directory('${pathFinder.root.path}/ios')
        ..createSync(recursive: true);
      final xcodeproj = Directory('${iosDir.path}/Runner.xcodeproj')
        ..createSync(recursive: true);
      File('${xcodeproj.path}/project.pbxproj')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
/* Begin PBXProject */
	INFOPLIST_FILE = Runner/CustomInfo.plist;
''');
      File('${iosDir.path}/Runner/CustomInfo.plist')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<?xml version="1.0"?><plist><dict><key>CFBundle</key></dict></plist>',
        );

      final result = pathFinder.getInfoPlist();
      expect(result, isNotNull);
      expect(result!.path, contains('CustomInfo.plist'));
    });
  });
}
