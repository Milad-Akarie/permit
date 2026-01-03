abstract class PermissionDef {
  final String key;
  final String group;

  const PermissionDef(this.key, {required this.group});

  bool matches(String input);
}

class AndroidPermissionDef extends PermissionDef {
  final bool runtime;
  final String? minimumSdkVersion;

  const AndroidPermissionDef(
    super.key, {
    this.runtime = false,
    required super.group,
    this.minimumSdkVersion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidPermissionDef &&
          key == other.key &&
          group == other.group &&
          runtimeType == other.runtimeType &&
          minimumSdkVersion == other.minimumSdkVersion;

  @override
  int get hashCode => Object.hash(runtime, minimumSdkVersion, key, group);

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
          minimumIosVersion == other.minimumIosVersion &&
          successorOf == other.successorOf &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(key, group, minimumIosVersion, successorOf, scope);

  @override
  bool matches(String input) {
    return key.toLowerCase() == input.toLowerCase();
  }
}

enum AccessScope {
  standardOrFull,
  writeOnly,
}
