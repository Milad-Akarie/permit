abstract class PermissionDef {
  final String key;
  final String unifiedName;
  final String group;

  const PermissionDef(
    this.key, {
    required this.group,
    required this.unifiedName,
  });

  bool matches(String input);
}

class AndroidPermissionDef extends PermissionDef {
  final bool runtime;
  final int? sinceApi;

  const AndroidPermissionDef(
    super.key, {
    this.runtime = false,
    required super.group,
    required super.unifiedName,
    this.sinceApi,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidPermissionDef &&
          key == other.key &&
          group == other.group &&
          runtime == other.runtime &&
          unifiedName == other.unifiedName &&
          runtimeType == other.runtimeType &&
          sinceApi == other.sinceApi;

  @override
  int get hashCode => Object.hash(runtime, sinceApi, key, group, unifiedName);

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
    required super.unifiedName,
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
          unifiedName == other.unifiedName &&
          minimumIosVersion == other.minimumIosVersion &&
          successorOf == other.successorOf &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(key, group, minimumIosVersion, successorOf, scope, unifiedName);

  @override
  bool matches(String input) {
    return key.toLowerCase() == input.toLowerCase();
  }
}

enum AccessScope {
  standardOrFull,
  writeOnly,
}
