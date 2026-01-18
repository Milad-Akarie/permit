import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginGradleTemp extends Template {
  final String androidPackageName;
  final int compileSdk;
  final int minSdk;

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
      minSdk $minSdk 
    }
     
    compileOptions {
      sourceCompatibility = JavaVersion.VERSION_17
      targetCompatibility = JavaVersion.VERSION_17
   }
}
''';
  }
}
