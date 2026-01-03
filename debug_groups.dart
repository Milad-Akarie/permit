import 'lib/registry/permit_registry.dart';
import 'lib/registry/android_permissions.dart';
import 'lib/registry/ios_permissions.dart';

void main() {
  final lookup = EntriesLookup.forDefaults();
  final groups = lookup.groups.toList()..sort();
  print('Total groups: ${groups.length}');
  print('All groups: $groups');

  print('\nAndroid + iOS groups lookup contains phone: ${groups.contains("phone")}');

  // Check if phone group is in Android
  final androidOnly = EntriesLookup.forDefaults(androidOnly: true);
  final androidGroups = androidOnly.groups.toList()..sort();
  print('Android only groups: $androidGroups');
  print('Android only contains phone: ${androidGroups.contains("phone")}');

  // Check entries with phone group
  int phoneCount = 0;
  for (var entry in lookup.entries) {
    if (entry.group == 'phone') {
      phoneCount++;
    }
  }
  print('Entries with phone group: $phoneCount');
}
