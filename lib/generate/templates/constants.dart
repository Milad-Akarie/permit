/// Package name for the Android implementation.
const String kAndroidPackageName = 'permit.plugin';

/// Package name for the iOS implementation.
const String kDartPackageName = 'permit_plugin';

/// Default Dart SDK constraint for the generated pubspec.yaml.
///
/// Flutter 3.41+ (Dart 3.11+) is required for Swift Package Manager support
/// (specifically the `FlutterFramework` SwiftPM dependency).
const String kDefaultDartConstraint = '>=3.11.0 <4.0.0';

/// Default Flutter SDK constraint for the generated pubspec.yaml.
///
/// 3.41 is the first stable release that ships the `FlutterFramework`
/// Swift package the generated `Package.swift` depends on.
const String kDefaultFlutterConstraint = '>=3.41.0';

/// Default channel name for platform communication.
const String kDefaultChannelName = 'permit.plugin/permissions';
