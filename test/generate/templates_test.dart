import 'package:permit/generate/templates/android/plugin_gradle_temp.dart';
import 'package:permit/generate/templates/android/plugin_kotlin_class_temp.dart';
import 'package:permit/generate/templates/android/plugin_manifest_temp.dart';
import 'package:permit/generate/templates/android/handlers/kotlin_handler_snippet.dart';
import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/plugin_pubspec_temp.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/models.dart';
import 'package:test/test.dart';

void main() {
  group('Templates', () {
    group('PluginPubspecTemp', () {
      test('should generate pubspec.yaml with default values', () {
        final template = PluginPubspecTemp();
        final content = template.generate();

        expect(content, contains('name: $kDartPackageName'));
        // YamlEditor formats this as `sdk: ">=..."`.
        expect(content, contains('sdk: "$kDefaultDartConstraint"'));
        expect(content, contains('package: $kAndroidPackageName'));
        expect(content, contains('pluginClass: PermitPlugin'));
      });

      test('should generate pubspec.yaml with custom values', () {
        final template = PluginPubspecTemp(
          packageName: 'custom_plugin',
          androidPackageName: 'com.custom.plugin',
          dartConstraint: '^2.19.0',
        );
        final content = template.generate();

        expect(content, contains('name: custom_plugin'));
        expect(content, contains("sdk: ^2.19.0"));
        expect(content, contains('package: com.custom.plugin'));
      });

      test('should have correct path', () {
        final template = PluginPubspecTemp();
        expect(template.path, equals('pubspec.yaml'));
      });

      test('should generate pubspec.yaml with only android platform', () {
        final template = PluginPubspecTemp(android: true, ios: false);
        final content = template.generate();
        expect(content, contains('android:'));
        expect(content, isNot(contains('ios:')));
      });

      test('should generate pubspec.yaml with only ios platform', () {
        final template = PluginPubspecTemp(android: false, ios: true);
        final content = template.generate();
        expect(content, contains('ios:'));
        expect(content, isNot(contains('android:')));
      });
    });

    group('PluginKotlinClassTemp', () {
      final handlers = [
        KotlinHandlerSnippet(
          key: 'camera',
          permissions: [AndroidPermissionDef('android.permission.CAMERA', group: 'camera', runtime: true)],
        ),
        KotlinHandlerSnippet(
          key: 'microphone',
          permissions: [AndroidPermissionDef('android.permission.RECORD_AUDIO', group: 'microphone', runtime: true)],
        ),
      ];

      test('should generate Kotlin class with default package', () {
        final template = PluginKotlinClassTemp(handlers: handlers);
        final content = template.generate();

        expect(content, contains('package $kAndroidPackageName'));
        expect(content, contains('class PermitPlugin'));
        expect(content, contains('MethodChannel(binding.binaryMessenger, "$kDefaultChannelName")'));
        expect(content, contains('PermissionRegistry.getHandler(permission)'));
      });

      test('should generate Kotlin class with custom package', () {
        final template = PluginKotlinClassTemp(packageName: 'com.example.custom', handlers: handlers);
        final content = template.generate();

        expect(content, contains('package com.example.custom'));
      });

      test('should have correct path', () {
        final template = PluginKotlinClassTemp(handlers: handlers);
        expect(
          template.path,
          equals('android/src/main/kotlin/${kAndroidPackageName.replaceAll('.', '/')}/PermitPlugin.kt'),
        );
      });
    });

    group('PluginGradleTemp', () {
      test('should generate build.gradle.kts with default namespace', () {
        final template = PluginGradleTemp();
        final content = template.generate();

        expect(content, contains('namespace = "$kAndroidPackageName"'));
      });

      test('should generate build.gradle.kts with custom namespace', () {
        final template = PluginGradleTemp(androidPackageName: 'com.custom.namespace');
        final content = template.generate();

        expect(content, contains('namespace = "com.custom.namespace"'));
      });

      test('should have correct path', () {
        final template = PluginGradleTemp();
        expect(template.path, equals('android/build.gradle.kts'));
      });
    });

    group('PluginManifestTemp', () {
      test('should generate AndroidManifest.xml with default package', () {
        final template = PluginManifestTemp();
        final content = template.generate();

        expect(content, contains('package="$kAndroidPackageName"'));
      });

      test('should generate AndroidManifest.xml with custom package', () {
        final template = PluginManifestTemp(packageName: 'com.custom.manifest');
        final content = template.generate();

        expect(content, contains('package="com.custom.manifest"'));
      });

      test('should have correct path', () {
        final template = PluginManifestTemp();
        expect(template.path, equals('android/src/main/AndroidManifest.xml'));
      });
    });

    group('HandlerSnippet', () {
      test('should have correct className', () {
        final handler = KotlinHandlerSnippet(
          key: 'camera',
          permissions: [AndroidPermissionDef('android.permission.CAMERA', group: 'camera', runtime: true)],
        );
        expect(handler.className, equals('CameraHandler'));
      });

      test('should generate Kotlin handler class', () {
        final handler = KotlinHandlerSnippet(
          key: 'camera',
          permissions: [AndroidPermissionDef('android.permission.CAMERA', group: 'camera', runtime: true)],
        );
        final content = handler.generate(1001);

        expect(content, contains('class CameraHandler : PermissionHandler('));
        expect(content, contains('1001, arrayOf('));
        expect(content, contains('Permission(android.Manifest.permission.CAMERA)'));
      });

      test('should generate handler with multiple permissions', () {
        final handler = KotlinHandlerSnippet(
          key: 'location',
          permissions: [
            AndroidPermissionDef('android.permission.ACCESS_FINE_LOCATION', group: 'location', runtime: true),
            AndroidPermissionDef('android.permission.ACCESS_COARSE_LOCATION', group: 'location', runtime: true),
          ],
        );
        final content = handler.generate(1002);

        expect(content, contains('class LocationHandler : PermissionHandler('));
        expect(content, contains('Permission(android.Manifest.permission.ACCESS_FINE_LOCATION),'));
        expect(content, contains('Permission(android.Manifest.permission.ACCESS_COARSE_LOCATION),'));
      });

      test('should generate handler with sinceApi', () {
        final handler = KotlinHandlerSnippet(
          key: AndroidPermissions.bluetoothScan.group,
          permissions: [AndroidPermissions.bluetoothScan],
        );
        final content = handler.generate(1003);

        expect(content, contains('Permission(android.Manifest.permission.BLUETOOTH_SCAN, sinceSDK = 31)'));
      });
    });
  });
}
