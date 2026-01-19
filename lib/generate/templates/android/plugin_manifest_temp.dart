import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the AndroidManifest.xml for a plugin package.
class PluginManifestTemp extends Template {
  /// The Android package name for the plugin.
  final String packageName;

  /// Constructor for [PluginManifestTemp].
  PluginManifestTemp({this.packageName = kAndroidPackageName});

  @override
  String get path => 'android/src/main/AndroidManifest.xml';

  @override
  String generate() {
    return '<manifest package="$packageName" />';
  }
}
