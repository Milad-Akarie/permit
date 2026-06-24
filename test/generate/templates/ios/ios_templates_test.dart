import 'package:test/test.dart';
import 'package:permit/generate/templates/ios/plugin_package_swift_temp.dart';
import 'package:permit/generate/templates/ios/plugin_privacy_manifest.dart';
import 'package:permit/generate/templates/ios/plugin_swift_class_temp.dart';

void main() {
  group('iOS templates generate', () {
    test(
      'PluginPackageSwiftTemp generates Package.swift with plugin name and min iOS',
      () {
        final pkg = PluginPackageSwiftTemp(
          pluginName: 'myplugin',
          minIosVersion: '14.0',
        );
        final out = pkg.generate();
        expect(out, contains('// swift-tools-version: 5.9'));
        expect(out, contains('name: "myplugin"'));
        expect(out, contains('.iOS("14.0")'));
        expect(out, contains('.library(name: "myplugin", targets: ["myplugin"])'));
        expect(
          out,
          contains(
            '.package(name: "FlutterFramework", path: "../FlutterFramework")',
          ),
        );
        expect(pkg.path, equals('ios/myplugin/Package.swift'));
      },
    );

    test('PluginPrivacyManifestTemp generates xml content', () {
      final privacy = PluginPrivacyManifestTemp();
      final out = privacy.generate();
      expect(out, contains('<plist'));
      expect(privacy.path, contains('PrivacyInfo'));
      expect(
        privacy.path,
        equals('ios/permit_plugin/Sources/permit_plugin/PrivacyInfo.xcprivacy'),
      );
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
        expect(
          swift.path,
          equals('ios/permit_plugin/Sources/permit_plugin/PermitPlugin.swift'),
        );
      },
    );
  });
}
