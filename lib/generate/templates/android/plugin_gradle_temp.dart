import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the build.gradle.kts for a plugin package.
///
/// Includes configuration for Android SDK versions and Java compatibility.
class PluginGradleTemp extends Template {
  /// The Android package name for the plugin.
  final String androidPackageName;

  /// The compile SDK version.
  final int compileSdk;

  /// The minimum SDK version.
  final int minSdk;

  /// Constructor for [PluginGradleTemp].
  PluginGradleTemp({
    this.androidPackageName = kAndroidPackageName,
    this.compileSdk = 35,
    this.minSdk = 16,
  });

  @override
  String get path => 'android/build.gradle.kts';

  @override
  String generate() {
    return '''
// ---- GENERATED CODE - DO NOT MODIFY BY HAND ---- 
plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "$androidPackageName"
    compileSdk = $compileSdk
      
    defaultConfig {
      minSdk = $minSdk 
    }
     
    compileOptions {
      sourceCompatibility = JavaVersion.VERSION_17
      targetCompatibility = JavaVersion.VERSION_17
   }
}
''';
  }
}
