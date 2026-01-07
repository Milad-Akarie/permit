import 'android_permissions.dart';
import 'ios_permissions.dart';
import 'models.dart';

class EntriesLookup {
  final Set<PermissionDef> entries;

  const EntriesLookup(this.entries);

  factory EntriesLookup.forDefaults({bool androidOnly = false, bool iosOnly = false}) {
    final allEntries = switch ((androidOnly, iosOnly)) {
      (true, false) => AndroidPermissions.all,
      (false, true) => IosPermissions.all,
      _ => {...AndroidPermissions.all, ...IosPermissions.all},
    };
    return EntriesLookup(allEntries);
  }

  Set<PermissionDef> lookup(String input) {
    final matches = <PermissionDef>{};
    for (var entry in entries) {
      if (entry.matches(input)) {
        matches.add(entry);
      } else if (entry.group.startsWith(input)) {
        matches.add(entry);
      }
    }

    return matches;
  }

  PermissionDef? lookupByKey(String key) {
    for (var entry in entries) {
      if (entry.key == key) {
        return entry;
      }
    }
    return null;
  }

  Set<String> get groups {
    final groups = <String>{};
    for (var entry in entries) {
      groups.add(entry.group);
    }
    return groups;
  }
}

extension PermissionEntrySet on Iterable<PermissionDef> {
  bool containsKey(String key) {
    return any((entry) => entry.key == key);
  }

  bool get hasAndroid => any((entry) => entry is AndroidPermissionDef);

  bool get hasIos => any((entry) => entry is IosPermissionDef);

  Set<IosPermissionDef> get ios => whereType<IosPermissionDef>().toSet();

  Set<AndroidPermissionDef> get android => whereType<AndroidPermissionDef>().toSet();
}
