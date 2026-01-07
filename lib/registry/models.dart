import 'package:permit/generate/utils.dart';

abstract class PermissionDef {
  final String key;
  final String group;
  final AssociatedService? service;

  const PermissionDef(
    this.key, {
    required this.group,
    this.service,
  });

  bool matches(String input);
}

class AndroidPermissionDef extends PermissionDef {
  final bool runtime;
  final int? sinceApi;

  const AndroidPermissionDef(
    super.key, {
    super.service,
    this.runtime = false,
    required super.group,
    this.sinceApi,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidPermissionDef &&
          key == other.key &&
          group == other.group &&
          service == other.service &&
          runtime == other.runtime &&
          runtimeType == other.runtimeType &&
          sinceApi == other.sinceApi;

  @override
  int get hashCode => Object.hash(runtime, sinceApi, key, group, service);

  @override
  bool matches(String input) {
    final lowerKey = key.toLowerCase();
    final lowerInput = input.toLowerCase();
    if (lowerKey == lowerInput) {
      return true;
    } else if (lowerKey.replaceAll('android.permission.', '') == lowerInput) {
      return true;
    }
    return false;
  }
}

/// iOS Permission class
class IosPermissionDef extends PermissionDef {
  final String? minimumIosVersion;
  final String? successorOf;
  final AccessScope scope;

  const IosPermissionDef(
    super.key, {
    super.service,
    required super.group,
    this.scope = .standardOrFull,
    this.minimumIosVersion,
    this.successorOf,
  });

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IosPermissionDef &&
          key == other.key &&
          group == other.group &&
          service == other.service &&
          minimumIosVersion == other.minimumIosVersion &&
          successorOf == other.successorOf &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(key, group, minimumIosVersion, successorOf, scope, service);

  @override
  bool matches(String input) {
    return key.toLowerCase() == input.toLowerCase();
  }
}

enum AccessScope { standardOrFull, writeOnly }

enum AssociatedService {
  location(),
  phone([SupportedPlatform.android]),
  bluetooth()
  ;

  final List<SupportedPlatform> platforms;

  const AssociatedService([this.platforms = const [SupportedPlatform.android, SupportedPlatform.ios]]);

  @override
  String toString() => name.capitalize();

  bool get isAndroidSupported => platforms.contains(SupportedPlatform.android);
  bool get isIosSupported => platforms.contains(SupportedPlatform.ios);
}

enum SupportedPlatform { android, ios }
