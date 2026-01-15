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
  String get name => key;
  String? get promptNote;
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

  // @override
  // String get name => key.replaceAll('android.permission.', '');

  @override
  String? get promptNote {
    if (sinceApi != null) {
      return 'api $sinceApi+';
    }
    return null;
  }
}

/// iOS Permission class
class IosPermissionDef extends PermissionDef {
  final AccessScope scope;
  final double? sinceApi;
  final double? untilApi;
  const IosPermissionDef(
    super.key, {
    super.service,
    required super.group,
    this.scope = .standardOrFull,
    this.sinceApi,
    this.untilApi,
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
          sinceApi == other.sinceApi &&
          untilApi == other.untilApi &&
          scope == other.scope;

  bool get isDeprecated => untilApi != null;

  @override
  int get hashCode => Object.hash(key, group, sinceApi, untilApi, scope, service);

  @override
  bool matches(String input) {
    return key.toLowerCase() == input.toLowerCase();
  }

  @override
  String? get promptNote {
    if (sinceApi != null && sinceApi! > 10.0) {
      return 'iOS ${sinceApi!.toShortString()}+';
    } else if (untilApi != null) {
      return 'deprecated, ios < ${untilApi!.toShortString()}';
    }
    return null;
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
