import 'package:permit/generate/templates/template.dart';

/// Template for generating the AndroidManifest.xml for a plugin package.
///
/// AGP 9 forbids the `package` attribute on `<manifest>` — the package is
/// declared via `android.namespace` in `build.gradle.kts` instead.
class PluginManifestTemp extends Template {
  /// Constructor for [PluginManifestTemp].
  const PluginManifestTemp();

  @override
  String get path => 'android/src/main/AndroidManifest.xml';

  @override
  String generate() {
    return '<manifest xmlns:android="http://schemas.android.com/apk/res/android" />';
  }
}
