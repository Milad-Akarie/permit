import 'package:permit/generate/templates/android/plugin_class_temp.dart';
import 'package:permit/generate/templates/android/plugin_gradle_temp.dart';
import 'package:permit/generate/templates/android/plugin_manifest_temp.dart';
import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/plugin_pubspec_temp.dart';
import 'package:test/test.dart';

void main() {
  group('Templates', () {
    group('PluginPubspecTemp', () {
      test('should generate pubspec.yaml with default values', () {
        final template = PluginPubspecTemp();
        final content = template.generate();

        expect(content, contains('name: $kDartPackageName'));
        expect(content, contains('sdk: \'$kDefaultDartConstraint\''));
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
        expect(content, contains('sdk: \'^2.19.0\''));
        expect(content, contains('package: com.custom.plugin'));
      });

      test('should have correct path', () {
        final template = PluginPubspecTemp();
        expect(template.path, equals('pubspec.yaml'));
      });
    });

    group('PluginClassTemp', () {
      test('should generate Kotlin class with default package', () {
        final template = PluginClassTemp();
        final content = template.generate();

        expect(content, contains('package $kAndroidPackageName'));
        expect(content, contains('class PermitPlugin'));
        expect(content, contains('MethodChannel(binding.binaryMessenger, "$kChannelName")'));
        expect(content, contains('PermissionRegistry.getHandler(permission)'));
      });

      test('should generate Kotlin class with custom package', () {
        final template = PluginClassTemp(packageName: 'com.example.custom');
        final content = template.generate();

        expect(content, contains('package com.example.custom'));
      });

      test('should have correct path', () {
        final template = PluginClassTemp();
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
        expect(content, contains('<manifest xmlns:android="http://schemas.android.com/apk/res/android"'));
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
  });
}
