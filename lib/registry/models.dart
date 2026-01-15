import 'package:collection/collection.dart';
import 'package:permit/generate/utils.dart';

abstract class PermissionDef {
  final String key;
  final String group;
  final Set<String> keywords;
  final AssociatedService? service;

  const PermissionDef(
    this.key, {
    required this.group,
    required this.keywords,
    this.service,
  });

  bool matches(String input);

  String get name => key;

  String? get promptNote;
}

class AndroidPermissionDef extends PermissionDef {
  final bool runtime;
  final int? sinceSDK;
  final int? untilApi;
  final Map<String, int>? legacyKeys;

  const AndroidPermissionDef(
    super.key, {
    super.service,
    this.runtime = false,
    super.keywords = const {},
    required super.group,
    this.untilApi,
    this.sinceSDK,
    this.legacyKeys,
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
          sinceSDK == other.sinceSDK &&
          untilApi == other.untilApi &&
          const SetEquality().equals(keywords, keywords) &&
          const MapEquality().equals(legacyKeys, other.legacyKeys);

  @override
  int get hashCode => Object.hash(
    runtime,
    sinceSDK,
    untilApi,
    key,
    group,
    service,
    const SetEquality().hash(keywords),
    const MapEquality().hash(legacyKeys),
  );

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

  @override
  String? get promptNote {
    if (sinceSDK != null) {
      return 'SDK $sinceSDK+';
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
    super.keywords = const {},
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
          scope == other.scope &&
          runtimeType == other.runtimeType &&
          const SetEquality().equals(keywords, other.keywords);

  bool get isDeprecated => untilApi != null;

  @override
  int get hashCode => Object.hash(
    key,
    group,
    sinceApi,
    untilApi,
    scope,
    service,
    const SetEquality().hash(keywords),
  );

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
