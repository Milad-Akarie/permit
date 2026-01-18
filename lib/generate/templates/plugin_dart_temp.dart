import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/generate/utils.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';

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
  static Future<bool> openSettings() async {
    try {
      await _channel.invokeMethod<bool>('open_settings');
      return true;
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
  final Set<String> platforms;

  // ignore: unused_element_parameter
  const Permission._(this.name, this._channel, {this.platforms = const {}});

  bool get _isPlatformSupported {
    return platforms.contains(Platform.operatingSystem);
  }

  Future<PermissionStatus> get status async {
    if (!_isPlatformSupported) {
      return PermissionStatus.notApplicable;
    }
    final int statusValue = await _channel.invokeMethod<int>(
          'check_permission_status',
          {'permission': name},
        ) ??
        0;
    return PermissionStatus.fromValue(statusValue);
  }

  Future<PermissionStatus> request() async {
    if (!_isPlatformSupported) {
      return PermissionStatus.notApplicable;
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
  provisional(5),
  // Platform does not support this permission.
  notApplicable(6);

  final int value;

  const PermissionStatus(this.value);

  factory PermissionStatus.fromValue(int value) => values[value];

  bool get isDenied => this == PermissionStatus.denied;

  bool get isGranted => this == PermissionStatus.granted;

  bool get isRestricted => this == PermissionStatus.restricted;

  bool get isLimited => this == PermissionStatus.limited;

  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;

  bool get isProvisional => this == PermissionStatus.provisional;

  bool get isNotApplicable => this == PermissionStatus.notApplicable;
}

${getterSnippets.any((e) => e.hasService) ? _serviceStatusSnippet : ''}
''';
}

const _serviceStatusSnippet = '''
/// Represents a specific permission that has an associated service status.
class PermissionWithService extends Permission {
  const PermissionWithService._(String name, MethodChannel channel, {Set<String> platforms = const {}})
      : super._(name, channel, platforms: platforms);

  Future<ServiceStatus> get serviceStatus async {
    if (!_isPlatformSupported) {
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
  final List<PermissionDef> entries;

  PermissionGetterSnippet(this.name, {required this.entries});
  bool get hasService => entries.any((e) => e.service != null);
  late final Set<String> platforms = entries.map((e) => e.platform).toSet();

  String generate() {
    final docs = <String>[];
    docs.add('Permission to access $name.');

    if (entries.hasIos) {
      docs.add('');
      docs.add('**iOS:**');
    }
    for (final entry in entries.ios) {
      docs.add('- Info.plist key: ${entry.key} ${entry.promptNote ?? ''}');
      if (entry.docNotes != null) {
        for (final note in entry.docNotes!) {
          docs.add('- Note: $note');
        }
      }
    }
    if (entries.hasAndroid) {
      docs.add('');
      docs.add('**Android:**');
    }
    for (final entry in entries.android) {
      docs.add('- Manifest permission: ${entry.key} ${entry.promptNote ?? ''}');
      if (entry.docNotes != null) {
        for (final note in entry.docNotes!) {
          docs.add('- Note: $note');
        }
      }
    }

    final plat = platforms.isNotEmpty ? ", platforms: {${platforms.map((e) => "'$e'").join(', ')}}" : '';
    final className = hasService ? 'PermissionWithService' : 'Permission';
    return '''${docs.map((e) => '  /// $e').join('\n')}
  static const ${name.toCamelCase()} = $className._('$name', _channel$plat);
''';
  }
}
