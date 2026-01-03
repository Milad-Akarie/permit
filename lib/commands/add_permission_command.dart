import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';

class AddPermissionCommand extends Command {
  @override
  String get name => 'add';

  @override
  String get description => 'Add a new permission';

  AddPermissionCommand() {
    argParser.addOption(
      'desc',
      abbr: 'd',
      help: 'Usage description',
      defaultsTo: '',
    );
    argParser.addFlag('android', abbr: 'a', help: 'Add permission for Android platform', defaultsTo: false);
    argParser.addFlag('ios', abbr: 'i', help: 'Add permission for iOS platform', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    // validate key
    // permit add <key> --desc "description"
    final key = argResults?.rest.isNotEmpty == true ? argResults!.rest[0] : '';
    final entriesLookup = EntriesLookup.forDefaults(
      androidOnly: argResults?['android'] == true,
      iosOnly: argResults?['ios'] == true,
    );

    if (key.isEmpty) {
      // print('Error: Permission key is required.');

      final selected = Select(
        prompt: 'Select a permission group to add',
        options: entriesLookup.groups.toList(),
      ).interact();

      final selectedGroup = entriesLookup.groups.elementAt(selected);

      // final entries = entriesLookup.lookup(selectedGroup);
      return;
    }

    final entries = entriesLookup.lookup(key);

    if (entries.isNotEmpty) {
      // for (var entry in entries) {
      //   print('Found matching permission: ${entry.key} (group: ${entry.group})');
      // }

      var selectedEntries = entries;
      if (entries.length > 1) {
        final selected = MultiSelect(
          prompt: 'Select the permission to add',
          options: [
            for (var entry in entries) '[${entry is AndroidPermission ? 'Android' : 'iOS'}]: ${entry.key}',
          ],
        ).interact();
        selectedEntries = Set.of(selected.map((index) => entries.elementAt(index)));
      }
      final descriptions = <String, String>{};
      if (selectedEntries.hasIos) {
        final iosEntries = selectedEntries.whereType<IosPermission>();
        for (var entry in iosEntries) {
          final desc = Input(prompt: 'Enter usage description for "${entry.key}"').interact();
          descriptions[entry.key] = desc;
        }
      }
    } else {
      print('No matching permission found for key: $key');
      return;
    }

    // var desc = (argResults?['desc'] as String?) ?? '';
    //
    // if (entries.hasIos) {
    //   desc = Input(prompt: 'Enter usage description').interact();
    // }

    // print('Description: $desc');
  }
}
