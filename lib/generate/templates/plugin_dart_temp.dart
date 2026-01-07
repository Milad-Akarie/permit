import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/generate/utils.dart';

class PluginDartTemp extends Template {
  @override
  String get path => 'lib/permit.dart';

  final List<PermissionGetterSnippet> getterSnippets;
  final String channelName;

  PluginDartTemp(this.getterSnippets, {this.channelName = kDefaultChannelName});

  @override
  String generate() =>
      '''
// ---- GENERATED CODE - DO NOT MODIFY BY HAND ----     
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// A plugin to handle permissions in a cross-platform way.
abstract class Permit {
  static const _channel = MethodChannel('$channelName');

  /// Opens the app settings page.
  ///
  /// Returns [true] if the app settings page could be opened, otherwise [false].
  static Future<bool> openAppSettings() async {
    try {
      return await _channel.invokeMethod<bool>('open_settings') ?? false;
    } on PlatformException {
      return false;
    }
  }

${getterSnippets.map((snippet) => snippet.generate()).join('\n')}
 
}

/// Represents a specific permission that can be requested or checked.
class Permission {
  final String name;
  final MethodChannel _channel;
  final String? platform;
  // ignore: unused_element_parameter
  const Permission._(this.name, this._channel, {this.platform});

  Future<PermissionStatus> get status async {
    if (platform != null && platform != Platform.operatingSystem) {
      return PermissionStatus.denied;
    }
    final int statusValue = await _channel.invokeMethod<int>(
          'check_permission_status',
          {'permission': name},
        ) ??
        0;
    return PermissionStatus.fromValue(statusValue);
  }

  Future<PermissionStatus> request() async {
    if (platform != null && platform != Platform.operatingSystem) {
      return PermissionStatus.denied;
    }
    final int statusValue = await _channel.invokeMethod<int>(
          'request_permission',
          {'permission': name},
        ) ??
        0;
    return PermissionStatus.fromValue(statusValue);
  }

  Future<bool> get shouldShowRequestRationale async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>(
          'should_show_rationale',
          {'permission': name},
        ) ??
        false;
  }
}

/// Defines the different states a permission can be in.
enum PermissionStatus {
  // Permission is denied or has not been requested yet.
  denied(0),
  // Permission is granted.
  granted(1),
  // User is not allowed to use the requested feature.  *Only supported on iOS.*
  restricted(2),
  // User has authorized this application for limited access.  *Only supported on iOS (iOS14+).*
  limited(3),
  // Permission is permanently denied, the permission dialog will not be shown when requesting this permission.
  permanentlyDenied(4),
  // Permission is provisionally granted.   *Only supported on iOS.*
  provisional(5);

  final int value;

  const PermissionStatus(this.value);

  factory PermissionStatus.fromValue(int value) => values[value];

  bool get isDenied => this == PermissionStatus.denied;
  bool get isGranted => this == PermissionStatus.granted;
  bool get isRestricted => this == PermissionStatus.restricted;
  bool get isLimited => this == PermissionStatus.limited;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isProvisional => this == PermissionStatus.provisional;
}

${getterSnippets.any((e) => e.hasService) ? _serviceStatusSnippet : ''}
''';
}

const _serviceStatusSnippet = '''
/// Represents a specific permission that has an associated service status.
class PermissionWithService extends Permission {
  const PermissionWithService._(String name, MethodChannel channel, {String? platform})
      : super._(name, channel, platform: platform);

  Future<ServiceStatus> get serviceStatus async {
    if (platform != null && platform != Platform.operatingSystem) {
      return ServiceStatus.notApplicable;
    }
    final int statusValue = await _channel.invokeMethod<int>(
          'check_service_status',
          {'permission': name},
        ) ??
        2;
    return ServiceStatus.fromValue(statusValue);
  }
}

/// Defines the different states a service can be in.
enum ServiceStatus {
  // The service for the permission is disabled.
  disabled(0),
  // The service for the permission is enabled.
  enabled(1),
  // Platform does not have an associated service or the service is not applicable.
  notApplicable(2);

  final int value;

  const ServiceStatus(this.value);

  factory ServiceStatus.fromValue(int value) => values[value];

  bool get isDisabled => this == ServiceStatus.disabled;
  bool get isEnabled => this == ServiceStatus.enabled;
  bool get isNotApplicable => this == ServiceStatus.notApplicable;
}
''';

class PermissionGetterSnippet {
  final String name;
  final String? platform;
  final bool hasService;

  PermissionGetterSnippet(this.name, this.platform, {this.hasService = false});

  String generate() {
    final plat = platform != null ? ", platform: '$platform'" : '';
    final className = hasService ? 'PermissionWithService' : 'Permission';
    return '''
  /// Permission to access $name
  static const ${name.toCamelCase()} = $className._('$name', _channel$plat);
''';
  }
}
