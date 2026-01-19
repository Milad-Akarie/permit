import 'package:test/test.dart';
import 'package:permit/generate/templates/ios/plugin_pod_temp.dart';
import 'package:permit/generate/templates/ios/plugin_privacy_manifest.dart';
import 'package:permit/generate/templates/ios/plugin_swift_class_temp.dart';

void main() {
  group('iOS templates generate', () {
    test('PluginPodTemp generates podspec with plugin name and min sdk', () {
      final pod = PluginPodTemp(pluginName: 'myplugin', minIosVersion: '14.0');
      final out = pod.generate();
      expect(out, contains('s.name             = \'myplugin\''));
      expect(out, contains("s.platform = :ios, '14.0'"));
      expect(pod.path, contains('ios/'));
    });

    test('PluginPrivacyManifestTemp generates xml content', () {
      final privacy = PluginPrivacyManifestTemp();
      final out = privacy.generate();
      expect(out, contains('<plist'));
      expect(privacy.path, contains('PrivacyInfo'));
    });

    test(
      'PluginSwiftClassTemp generates base plugin class even with no handlers',
      () {
        final swift = PluginSwiftClassTemp([]);
        final out = swift.generate();
        expect(out, contains('public class PermitPlugin'));
        expect(
          out,
          contains(
            'func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)',
          ),
        );
        expect(swift.path, contains('PermitPlugin.swift'));
      },
    );
  });
}
