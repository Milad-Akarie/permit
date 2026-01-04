import 'lib/registry/permit_registry.dart';
import 'lib/registry/android_permissions.dart';

void main() {
  final lookup = EntriesLookup.forDefaults();
  final groups = lookup.groups;
  print('Total groups: ${groups.length}');
  print('Groups: ${groups.toList()..sort()}');

  print('\nChecking Android groups:');
  final requiredAndroidGroups = [
    'camera',
    'microphone',
    'location',
    'contacts',
    'calendar',
    'phone',
    'storage',
    'network',
    'bluetooth',
    'sensors',
    'system',
    'notifications',
  ];
  for (var group in requiredAndroidGroups) {
    print('  $group: ${groups.contains(group)}');
  }

  final androidGroups = AndroidPermissions.all.map((p) => p.group).toSet();
  print('\nActual Android groups: ${androidGroups.toList()..sort()}');
}
