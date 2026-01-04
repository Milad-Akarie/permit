import 'package:permit/generate/templates/template.dart';

class PluginPubspecTemp extends Template {
  PluginPubspecTemp({this.dartConstraint = defaultDartConstraint});
  final String dartConstraint;

  static const packageName = 'permit_plugin';
  static const defaultDartConstraint = '^3.0.0';

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
        package: local.app.permit_plugin
        pluginClass: PermitPlugin
      ios:
        pluginClass: PermitPlugin
''';
  }
}
