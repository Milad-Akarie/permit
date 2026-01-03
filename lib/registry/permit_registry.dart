import 'android_permissions.dart';
import 'ios_permissions.dart';
import 'models.dart';

class EntriesLookup {
  final Set<PermissionEntry> entries;

  const EntriesLookup(this.entries);

  factory EntriesLookup.forDefaults({bool androidOnly = false, bool iosOnly = false}) {
    final allEntries = switch ((androidOnly, iosOnly)) {
      (true, false) => AndroidPermissions.all,
      (false, true) => IosPermissions.all,
      _ => {...AndroidPermissions.all, ...IosPermissions.all},
    };
    return EntriesLookup(allEntries);
  }

  Set<PermissionEntry> lookup(String input) {
    final matches = <PermissionEntry>{};
    for (var entry in entries) {
      if (entry.matches(input)) {
        matches.add(entry);
      } else if (entry.group.startsWith(input)) {
        matches.add(entry);
      }
    }

    return matches;
  }

  Set<String> get groups {
    final groups = <String>{};
    for (var entry in entries) {
      groups.add(entry.group);
    }
    return groups;
  }
}

extension PermissionEntrySet on Iterable<PermissionEntry> {
  bool containsKey(String key) {
    return any((entry) => entry.key == key);
  }

  bool get hasAndroid => any((entry) => entry is AndroidPermission);
  bool get hasIos => any((entry) => entry is IosPermission);
  Set<PermissionEntry> get ios => whereType<IosPermission>().toSet();

  Set<PermissionEntry> get android => whereType<AndroidPermission>().toSet();
}
