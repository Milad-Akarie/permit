import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginManifestTemp extends Template {
  final String packageName;

  PluginManifestTemp({this.packageName = kAndroidPackageName});

  @override
  String get path => 'android/src/main/AndroidManifest.xml';

  @override
  String generate() {
    return '<manifest package="$packageName" />';
  }
}
