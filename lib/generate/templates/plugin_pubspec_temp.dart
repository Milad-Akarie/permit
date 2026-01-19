import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Template for generating the pubspec.yaml for a plugin package.
class PluginPubspecTemp extends Template {
  /// Constructor for [PluginPubspecTemp].
  PluginPubspecTemp({
    this.dartConstraint = kDefaultDartConstraint,
    this.packageName = kDartPackageName,
    this.androidPackageName = kAndroidPackageName,
    this.android = true,
    this.ios = true,
  });

  /// The Dart SDK constraint to use.
  final String dartConstraint;

  /// The name of the package.
  final String packageName;

  /// The Android package name for the plugin.
  final String androidPackageName;

  /// Whether to include Android platform support.
  final bool android;

  /// Whether to include iOS platform support.
  final bool ios;

  @override
  String get path => 'pubspec.yaml';

  @override
  String generate() {
    final YamlEditor editor = YamlEditor('{}');
    editor.update([], {
      'name': packageName,
      'description': 'Native permission handling for Flutter.',
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
