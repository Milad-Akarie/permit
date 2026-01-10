import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginPodTemp extends Template {
  PluginPodTemp({
    this.pluginName = kDartPackageName,
    this.minSdkVersion = '13.0',
  });
  final String pluginName;
  final String minSdkVersion;

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
  s.platform = :ios, '$minSdkVersion'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
    ''';
  }
}
