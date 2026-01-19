import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the iOS podspec file for a plugin package.
///
/// This file is used by CocoaPods to manage the iOS dependencies of the plugin.
class PluginPodTemp extends Template {
  /// Constructor for [PluginPodTemp].
  PluginPodTemp({
    this.pluginName = kDartPackageName,
    this.minIosVersion = '12.0',
  });

  /// The name of the plugin.
  final String pluginName;

  /// The minimum iOS version supported by the plugin.
  final String minIosVersion;

  @override
  String get path => 'ios/$pluginName.podspec';

  @override
  String generate() {
    return '''
# GENERATED FILE - DO NOT MODIFY BY HAND
Pod::Spec.new do |s|
  s.name             = '$pluginName'
  s.version          = '1.0.0'
  s.summary          = 'Native permission handling for Flutter.'
  s.homepage         = 'https://github.com/Milad-Akarie/permit'
  s.author           = { 'Codeness.ly' => 'support@codeness.ly' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '$minIosVersion'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
    ''';
  }
}
