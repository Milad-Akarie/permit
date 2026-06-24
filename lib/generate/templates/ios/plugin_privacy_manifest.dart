import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the iOS PrivacyInfo.xcprivacy file for a plugin package.
///
/// This file is required to comply with Apple's privacy requirements.
/// Lives next to the Swift sources so SwiftPM's `.process` resource rule
/// can pick it up.
class PluginPrivacyManifestTemp extends Template {
  /// Constructor for [PluginPrivacyManifestTemp].
  const PluginPrivacyManifestTemp({this.pluginName = kDartPackageName});

  /// The snake_case name of the plugin package — used to build the SwiftPM
  /// source directory path.
  final String pluginName;

  @override
  String get path => 'ios/$pluginName/Sources/$pluginName/PrivacyInfo.xcprivacy';

  @override
  String generate() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyAccessedAPITypes</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
	<key>NSPrivacyTracking</key>
	<false/>
</dict>
</plist>
  ''';
  }
}
