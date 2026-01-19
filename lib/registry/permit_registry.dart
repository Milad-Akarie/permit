import 'android_permissions.dart';
import 'ios_permissions.dart';
import 'models.dart';

/// A utility class for creating and looking up permission definitions.
class EntriesLookup {
  /// The set of available permission definitions.
  final Set<PermissionDef> entries;

  /// Default constructor.
  const EntriesLookup(this.entries);

  /// Creates a lookup instance initialized with default permissions.
  ///
  /// [androidOnly] If true, only Android permissions are included.
  /// [iosOnly] If true, only iOS permissions are included.
  factory EntriesLookup.forDefaults({
    bool androidOnly = false,
    bool iosOnly = false,
  }) {
    final allEntries = switch ((androidOnly, iosOnly)) {
      (true, false) => AndroidPermissions.all,
      (false, true) => IosPermissions.all,
      _ => {...AndroidPermissions.all, ...IosPermissions.all},
    };
    return EntriesLookup(allEntries);
  }

  /// Finds permissions matching the given [input] string.
  ///
  /// Matches can be by key, group, or keywords.
  Set<PermissionDef> find(String input) {
    final matches = <PermissionDef>{};
    for (var entry in entries) {
      if (entry.matches(input)) {
        matches.add(entry);
      } else if ({
        entry.group,
        ...entry.keywords,
      }.any((e) => e.startsWith(input))) {
        matches.add(entry);
      }
    }

    return matches;
  }

  /// Finds a specific permission definition by its [key].
  PermissionDef? findByKey(String key) {
    for (var entry in entries) {
      if (entry.key == key) {
        return entry;
      }
    }
    return null;
  }

  /// Returns all unique permission groups.
  Set<String> get groups {
    final groups = <String>{};
    for (var entry in entries) {
      groups.add(entry.group);
    }
    return groups;
  }
}

/// Extension methods for sets of [PermissionDef].
extension PermissionEntrySet on Iterable<PermissionDef> {
  /// Checks if the set contains a permission with the given [key].
  bool containsKey(String key) {
    return any((entry) => entry.key == key);
  }

  /// Checks if the set contains any Android permissions.
  bool get hasAndroid => any((entry) => entry is AndroidPermissionDef);

  /// Checks if the set contains any iOS permissions.
  bool get hasIos => any((entry) => entry is IosPermissionDef);

  /// Returns a set of all iOS permission definitions in this collection.
  Set<IosPermissionDef> get ios => whereType<IosPermissionDef>().toSet();

  /// Returns a set of all Android permission definitions in this collection.
  Set<AndroidPermissionDef> get android =>
      whereType<AndroidPermissionDef>().toSet();
}
