import 'package:permit/commands/permit_runner.dart';
import 'package:permit/generate/plugin_generator.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';
import 'package:permit/utils/utils.dart';
import 'package:permit/editor/models.dart';
import 'package:permit/editor/xml_editor.dart';

class AddPermissionCommand extends PermitCommand {
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
    argParser.addFlag('code', abbr: 'c', help: 'Generate code for permission handling', defaultsTo: false);
    argParser.addFlag('android', abbr: 'a', help: 'Add permission for Android platform', defaultsTo: false);
    argParser.addFlag('ios', abbr: 'i', help: 'Add permission for iOS platform', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    var key = argResults?.rest.isNotEmpty == true ? argResults!.rest[0] : '';
    final entriesLookup = EntriesLookup.forDefaults(
      androidOnly: argResults?['android'] == true,
      iosOnly: argResults?['ios'] == true,
    );

    if (key.isEmpty) {
      key = singleSelect(
        'Select a permission group',
        options: List.of(entriesLookup.groups),
        display: (group) => group,
      );
    }
    if (key.isEmpty) {
      Logger.info('No permission key provided.');
      return;
    }

    final entries = entriesLookup.find(key);

    if (entries.isNotEmpty) {
      final resolved = _resolveEntries(List.of(entries));
      onAddEntries(resolved);
    } else {
      Logger.info('No permission entries found for key: $key');
      return;
    }
  }

  void onAddEntries(List<XmlEntry> entries) {
    final androidEntries = entries.whereType<ManifestPermissionEntry>();
    final iosEntries = entries.whereType<PListUsageDescription>();
    if (androidEntries.isNotEmpty) {
      addAndroidPermissions(androidEntries.toList());
    }
    if (iosEntries.isNotEmpty) {
      addIosPermissions(iosEntries.toList());
    }

    /// Generate plugin code
    PluginGenerator(pathFinder: pathFinder).generate();
  }

  void addAndroidPermissions(List<ManifestPermissionEntry> entries) {
    final file = pathFinder.getManifest();
    if (file == null) {
      Logger.error('Could not locate AndroidManifest.xml');
      return;
    }
    final manifestEditor = ManifestEditor(file.readAsStringSync());

    for (var entry in entries) {
      manifestEditor.addPermission(
        name: entry.key,
        comments: entry.comments,
        removeCommentsOnUpdate: (c) => c.startsWith('@permit'),
      );
    }

    if (manifestEditor.save(file)) {
      for (var entry in entries) {
        Logger.android('Added Android permission: ${Logger.mutedPen.write(entry.key)}');
      }
    }
  }

  void addIosPermissions(List<PListUsageDescription> entries) {
    final file = pathFinder.getInfoPlist();
    if (file == null) {
      Logger.error('Could not locate Info.plist');
      return;
    }
    final plistEditor = PListEditor(file.readAsStringSync());
    for (var entry in entries) {
      plistEditor.addUsageDescription(
        key: entry.key,
        description: entry.description,
        keyComments: entry.comments,
        removeCommentsOnUpdate: (c) => c.startsWith('@permit'),
      );
    }
    if (plistEditor.save(file)) {
      for (var entry in entries) {
        Logger.ios('Added iOS usage description: ${Logger.mutedPen.write(entry.key)}');
      }
    }
  }

  List<XmlEntry> _resolveEntries(List<PermissionDef> entries) {
    final generateCode = argResults?['code'] == true;
    final desc = argResults?['desc'] as String?;
    var selectedEntries = entries;
    if (entries.length > 1) {
      selectedEntries = multiSelect(
        'Select the permission to add',
        options: entries,
        display: (entry) {
          return '${entry is AndroidPermissionDef ? 'Android' : 'iOS'}: ${entry.key}';
        },
      );
    }

    final resolvedEntries = <XmlEntry>[];
    for (final androidEntry in selectedEntries.android) {
      resolvedEntries.add(
        ManifestPermissionEntry(
          key: androidEntry.key,
          comments: [generateCode && androidEntry.runtime ? '@permit:code' : '@permit'],
        ),
      );
    }

    final iosEntries = selectedEntries.ios;

    if (iosEntries.length == 1 && desc != null && desc.isNotEmpty) {
      final entry = iosEntries.first;
      resolvedEntries.add(
        PListUsageDescription(
          key: entry.key,
          description: desc,
          comments: [generateCode ? '@permit:code' : '@permit'],
        ),
      );
      return resolvedEntries;
    }

    for (var entry in iosEntries) {
      final desc = prompt(
        'Enter usage description for "${entry.key}"',
        defaultValue: argResults?['desc'] ?? '',
        validatorErrorMessage: 'Description cannot be empty',
      );
      resolvedEntries.add(
        PListUsageDescription(
          key: entry.key,
          description: desc,
          comments: [generateCode ? '@permit:code' : '@permit'],
        ),
      );
    }
    return resolvedEntries;
  }
}
