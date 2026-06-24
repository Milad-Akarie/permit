import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the iOS Swift Package Manager manifest
/// (`Package.swift`) for a generated plugin package.
///
/// Replaces the legacy CocoaPods podspec — Flutter 3.41+ consumes plugins as
/// Swift packages. The produced layout matches Flutter's expectations:
///
/// ```
/// ios/
///   <plugin_name>/
///     Package.swift          ← this template
///     Sources/
///       <plugin_name>/
///         *.swift
///         PrivacyInfo.xcprivacy
/// ```
class PluginPackageSwiftTemp extends Template {
  /// Constructor for [PluginPackageSwiftTemp].
  PluginPackageSwiftTemp({
    this.pluginName = kDartPackageName,
    this.minIosVersion = '13.0',
    this.swiftToolsVersion = '5.9',
  });

  /// The snake_case name of the plugin package. Matches the target name
  /// and source directory.
  final String pluginName;

  /// The minimum iOS deployment target supported by the plugin.
  final String minIosVersion;

  /// `// swift-tools-version:` declaration at the top of the manifest.
  final String swiftToolsVersion;

  /// Library product name. SwiftPM requires kebab-case for product names
  /// while target / package names stay snake_case.
  String get _libraryName => pluginName.replaceAll('_', '-');

  @override
  String get path => 'ios/$pluginName/Package.swift';

  @override
  String generate() {
    return '''
// swift-tools-version: $swiftToolsVersion
// GENERATED FILE - DO NOT MODIFY BY HAND
import PackageDescription

let package = Package(
    name: "$pluginName",
    platforms: [
        .iOS("$minIosVersion"),
    ],
    products: [
        .library(name: "$_libraryName", targets: ["$pluginName"]),
    ],
    dependencies: [
        // Flutter injects the real path to FlutterFramework at build time.
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "$pluginName",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
''';
  }
}
