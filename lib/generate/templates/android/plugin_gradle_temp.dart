import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginGradleTemp extends Template {
  final String androidPackageName;

  PluginGradleTemp({this.androidPackageName = kAndroidPackageName});

  @override
  String get path => 'android/build.gradle.kts';

  @override
  String generate() {
    return '''
    plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "$androidPackageName"
}
''';
  }
}
