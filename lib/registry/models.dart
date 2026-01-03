abstract class PermissionEntry {
  final String key;
  final String group;

  const PermissionEntry(this.key, {required this.group});

  bool matches(String input);
}

class AndroidPermission extends PermissionEntry {
  final bool runtime;
  final String? minimumSdkVersion;

  const AndroidPermission(
    super.key, {
    this.runtime = false,
    required super.group,
    this.minimumSdkVersion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidPermission &&
          runtimeType == other.runtimeType &&
          runtime == other.runtime &&
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
class IosPermission extends PermissionEntry {
  final String? minimumIosVersion;
  final String? successorOf;
  final AccessScope scope;

  const IosPermission(
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
      other is IosPermission &&
          runtimeType == other.runtimeType &&
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
