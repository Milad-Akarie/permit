import 'package:permit/generate/templates/template.dart';

class PluginPrivacyManifestTemp extends Template {
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
