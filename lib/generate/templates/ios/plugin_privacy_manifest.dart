import 'package:permit/generate/templates/template.dart';

/// Template for generating the iOS PrivacyInfo.xcprivacy file for a plugin package.
///
/// This file is required to comply with Apple's privacy requirements.
class PluginPrivacyManifestTemp extends Template {
  /// Constructor for [PluginPrivacyManifestTemp].
  const PluginPrivacyManifestTemp();

  @override
  String get path => 'ios/Resources/PrivacyInfo.xcprivacy';

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
