import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PluginPubspecTemp extends Template {
  PluginPubspecTemp({
    this.dartConstraint = kDefaultDartConstraint,
    this.packageName = kDartPackageName,
    this.androidPackageName = kAndroidPackageName,
    this.android = true,
    this.ios = true,
  });

  final String dartConstraint;
  final String packageName;
  final String androidPackageName;
  final bool android;
  final bool ios;

  @override
  String get path => 'pubspec.yaml';

  @override
  String generate() {
    final YamlEditor editor = YamlEditor('{}');
    editor.update([], {
      'name': packageName,
      'description': 'Handles native App permissions',
      'publish_to': 'none',
      'version': '1.0.0+1',
      'environment': {
        'sdk': dartConstraint,
      },
      'dependencies': {
        'flutter': {'sdk': 'flutter'},
      },
      'flutter': {
        'plugin': {
          'platforms': {
            if (android)
              'android': {
                'package': androidPackageName,
                'pluginClass': 'PermitPlugin',
              },
            if (ios)
              'ios': {
                'pluginClass': 'PermitPlugin',
              },
          },
        },
      },
    });
    return editor.toString();
  }
}
