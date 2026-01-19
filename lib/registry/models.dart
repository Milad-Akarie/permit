import 'package:collection/collection.dart';
import 'package:permit/generate/utils.dart';

/// Base class for all permission definitions.
abstract class PermissionDef {
  /// The unique key for the permission (e.g., 'android.permission.CAMERA' or 'NSCameraUsageDescription').
  final String key;

  /// The group this permission belongs to (e.g., 'Camera', 'Location').
  final String group;

  /// Keywords used to search for this permission.
  final Set<String> keywords;

  /// The service associated with this permission, if any.
  final AssociatedService? service;

  /// The platform this permission applies to ('android' or 'ios').
  final String platform;

  /// Additional notes for documentation purposes.
  final Set<String>? docNotes;

  /// Default constructor.
  const PermissionDef(
    this.key, {
    required this.group,
    required this.keywords,
    required this.platform,
    this.docNotes,
    this.service,
  });

  /// Checks if the input string matches this permission's key or common aliases.
  bool matches(String input);

  /// Returns the name (key) of the permission.
  String get name => key;

  /// Returns a note to prompt the user with, if applicable (e.g., version constraints).
  String? get promptNote;
}

/// Definition for an Android permission.
class AndroidPermissionDef extends PermissionDef {
  /// Whether this permission requires runtime requests (dangerous permissions).
  final bool runtime;

  /// The SDK version since which this permission is available.
  final int? sinceSDK;

  /// The API level until which this permission is valid (deprecated or removed after).
  final int? untilApi;

  /// Legacy keys that were used in older Android versions, mapped to their max SDK version.
  final Map<String, int>? legacyKeys;

  /// Default constructor.
  const AndroidPermissionDef(
    super.key, {
    super.service,
    this.runtime = false,
    super.keywords = const {},
    required super.group,
    this.untilApi,
    this.sinceSDK,
    this.legacyKeys,
    super.docNotes,
  }) : super(platform: 'android');

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
          const SetEquality().equals(docNotes, other.docNotes) &&
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
    const SetEquality().hash(docNotes),
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

/// Definition for an iOS permission (Info.plist usage description).
class IosPermissionDef extends PermissionDef {
  /// The scope of access this permission grants.
  final AccessScope scope;

  /// The iOS version since which this permission is required.
  final double? sinceApi;

  /// The iOS version until which this permission is required.
  final double? untilApi;

  /// Default constructor.
  const IosPermissionDef(
    super.key, {
    super.service,
    required super.group,
    this.scope = .standardOrFull,
    super.keywords = const {},
    this.sinceApi,
    this.untilApi,
    super.docNotes,
  }) : super(platform: 'ios');

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
          const SetEquality().equals(docNotes, other.docNotes) &&
          const SetEquality().equals(keywords, other.keywords);

  /// Whether this permission is considered deprecated.
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
    const SetEquality().hash(docNotes),
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

/// Defines the access level scope for iOS permissions.
enum AccessScope {
  /// Standard or full access.
  standardOrFull,

  /// Read-only access.
  writeOnly,
}

/// Represents a service associated with a permission.
enum AssociatedService {
  /// Location service.
  location(),

  /// phone service.
  phone([SupportedPlatform.android]),

  /// Bluetooth service.
  bluetooth()
  ;

  /// The platforms this service supports.
  final List<SupportedPlatform> platforms;

  const AssociatedService([
    this.platforms = const [SupportedPlatform.android, SupportedPlatform.ios],
  ]);

  @override
  String toString() => name.capitalize();

  /// Checks if Android is supported by this service.
  bool get isAndroidSupported => platforms.contains(SupportedPlatform.android);

  /// Checks if iOS is supported by this service.
  bool get isIosSupported => platforms.contains(SupportedPlatform.ios);
}

/// Supported platforms for services.
enum SupportedPlatform {
  /// Android platform.
  android,

  /// iOS platform.
  ios,
}
