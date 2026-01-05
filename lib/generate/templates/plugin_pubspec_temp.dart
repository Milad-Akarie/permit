import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginPubspecTemp extends Template {
  PluginPubspecTemp({
    this.dartConstraint = kDefaultDartConstraint,
    this.packageName = kDartPackageName,
    this.androidPackageName = kAndroidPackageName,
  });

  final String dartConstraint;
  final String packageName;
  final String androidPackageName;

  @override
  String get path => 'pubspec.yaml';

  @override
  String generate() {
    return '''
name: $packageName
description: Handles native App permissions.
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: '$dartConstraint'

dependencies:
  flutter:
    sdk: flutter
    
flutter:
  plugin:
    platforms:
      android:
        package: $androidPackageName
        pluginClass: PermitPlugin
      ios:
        pluginClass: PermitPlugin
''';
  }
}
