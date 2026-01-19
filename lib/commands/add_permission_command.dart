import 'dart:io';

import 'package:permit/commands/permit_runner.dart';
import 'package:permit/editor/models.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/generate/plugin_generator.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';
import 'package:permit/utils/utils.dart';

/// Command to add a new permission to the project.
///
/// Usage: `permit add &lt;permission_name&gt; [options]`
/// Args:
///  &lt;permission_name&gt : The key or keyword of the permission to add.
///  if specific key is provided, it will be added directly.
///  if a keyword is provided, user will be prompted to select from matching permissions.
///  Options:
///   -d, --desc &lt;description&gt : Usage description for iOS permissions. (default is null).
///   -c, --code : Generate code for permission handling. (default is false).
///   -a, --android : Add permission for Android platform only. (default is false).
///   -i, --ios : Add permission for iOS platform only. (default is false).
class AddPermissionCommand extends PermitCommand {
  @override
  String get name => 'add';

  @override
  String get description => 'Add a new permission';

  /// Creates an instance of [AddPermissionCommand].
  /// Default constructor.
  AddPermissionCommand() {
    argParser.addOption(
      'desc',
      abbr: 'd',
      help: 'Usage description',
      defaultsTo: '',
    );
    argParser.addFlag(
      'code',
      abbr: 'c',
      help: 'Generate code for permission handling',
      defaultsTo: false,
    );
    argParser.addFlag(
      'android',
      abbr: 'a',
      help: 'Add permission for Android platform',
      defaultsTo: false,
    );
    argParser.addFlag(
      'ios',
      abbr: 'i',
      help: 'Add permission for iOS platform',
      defaultsTo: false,
    );
  }

  late final (PListEditor editor, File file)? _infoPlist = () {
    final file = pathFinder.getInfoPlist();
    if (file == null) {
      return null;
    }
    return (PListEditor(file.readAsStringSync()), file);
  }();

  late final (ManifestEditor editor, File file)? _manifest = () {
    final file = pathFinder.getManifest();
    if (file == null) {
      return null;
    }
    return (ManifestEditor(file.readAsStringSync()), file);
  }();

  @override
  Future<void> run() async {
    var key = argResults?.rest.isNotEmpty == true ? argResults!.rest[0] : '';
    final lookup = EntriesLookup.forDefaults(
      androidOnly: argResults?['android'] == true,
      iosOnly: argResults?['ios'] == true,
    );

    if (key.isEmpty) {
      Logger.info(
        'No permission key or a search keyword provide. try permit add <permission_key|keyword>',
      );
      return;
    }

    final entries = lookup.find(key);

    if (entries.isNotEmpty) {
      final resolved = _resolveEntries(List.of(entries), key);
      _onAddEntries(resolved, lookup);
    } else {
      Logger.info('No permission entries found for key: $key');
      return;
    }
  }

  /// Handles the addition of resolved entries to the project files.
  void _onAddEntries(List<XmlEntry> entries, EntriesLookup lookup) {
    final androidEntries = entries.whereType<ManifestPermissionEntry>();
    final iosEntries = entries.whereType<PListUsageDescription>();
    if (androidEntries.isNotEmpty) {
      _addAndroidPermissions(androidEntries.toList(), lookup);
    }
    if (iosEntries.isNotEmpty) {
      _addIosPermissions(iosEntries.toList());
    }

    /// Generate plugin code
    PluginGenerator(pathFinder: pathFinder).generate();
  }

  void _addAndroidPermissions(
    List<ManifestPermissionEntry> entries,
    EntriesLookup lookup,
  ) {
    if (_manifest == null) {
      Logger.error('Could not locate AndroidManifest.xml');
      return;
    }

    final (editor, file) = _manifest;

    for (var entry in entries) {
      editor.addPermission(
        name: entry.key,
        comments: entry.comments,
        removeCommentsOnUpdate: (c) => c.startsWith('@permit'),
      );
      final permissionDef = lookup.findByKey(entry.key);
      if (permissionDef is AndroidPermissionDef && permissionDef.legacyKeys != null) {
        for (final legacyEntry in permissionDef.legacyKeys!.entries) {
          editor.addPermission(
            name: legacyEntry.key,
            comments: ['@permit:legacy DO-NOT-REMOVE'],
            maxSdkVersion: legacyEntry.value,
            removeCommentsOnUpdate: (c) => c.startsWith('@permit'),
          );
        }
      }
    }

    if (editor.save(file)) {
      for (var entry in entries) {
        Logger.android(
          'Added Android permission: ${Logger.mutedPen.write(entry.key)}',
        );
      }
    }
  }

  void _addIosPermissions(List<PListUsageDescription> entries) {
    if (_infoPlist == null) {
      Logger.error('Could not locate Info.plist');
      return;
    }
    final (editor, file) = _infoPlist;
    for (var entry in entries) {
      editor.addUsageDescription(
        key: entry.key,
        description: entry.description,
        keyComments: entry.comments,
        removeCommentsOnUpdate: (c) => c.startsWith('@permit'),
      );
    }
    if (editor.save(file)) {
      for (var entry in entries) {
        Logger.ios(
          'Added iOS usage description: ${Logger.mutedPen.write(entry.key)}',
        );
      }
    }
  }

  List<XmlEntry> _resolveEntries(
    List<PermissionDef> entries,
    String searchKey,
  ) {
    final generateCode = argResults?['code'] == true;
    final desc = argResults?['desc'] as String?;
    var selectedEntries = entries;

    final existingUsageDescriptions = Map<String, PListUsageDescription>.fromEntries(
      _infoPlist?.$1.getUsageDescriptions().map(
            (e) => MapEntry(e.key, e),
          ) ??
          [],
    );

    final canUpdateInfoPlist = entries.whereType<IosPermissionDef>().any(
      (e) => existingUsageDescriptions.containsKey(e.key),
    );
    // Prompt user to select permissions if multiple found or if the found entry does not exactly match the search key
    if (entries.length > 1 || !entries.first.matches(searchKey)) {
      final maxLineLength = entries.map((e) => e.name.length).reduce((a, b) => a > b ? a : b);

      selectedEntries = multiSelect(
        'Select permissions to add${canUpdateInfoPlist ? ' or update' : ''}',
        options: entries,
        display: (entry) {
          final platform = entry is AndroidPermissionDef ? 'Android: ' : 'iOS: ';
          var note = entry.promptNote != null ? '(${entry.promptNote})' : '';
          final option = platform + entry.name;
          if (entry is IosPermissionDef && existingUsageDescriptions.containsKey(entry.key)) {
            note += ' (Update)';
          }

          if (note.isEmpty) {
            return option;
          }
          return option.padRight(maxLineLength + 13) + Logger.mutedPen.write(note);
        },
      );
    }

    final resolvedEntries = <XmlEntry>[];
    for (final androidEntry in selectedEntries.android) {
      resolvedEntries.add(
        ManifestPermissionEntry(
          key: androidEntry.key,
          comments: [
            generateCode && androidEntry.runtime ? '@permit:code DO-NOT-REMOVE' : '@permit',
          ],
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
          comments: [generateCode ? '@permit:code DO-NOT-REMOVE' : '@permit'],
        ),
      );
      return resolvedEntries;
    }

    for (var entry in iosEntries) {
      final desc = prompt(
        'Usage description for "${entry.name}"',
        defaultValue: existingUsageDescriptions[entry.key]?.description ?? argResults?['desc'] ?? '',
        validatorErrorMessage: 'Description cannot be empty',
      );
      resolvedEntries.add(
        PListUsageDescription(
          key: entry.key,
          description: desc,
          comments: [generateCode ? '@permit:code DO-NOT-REMOVE' : '@permit'],
        ),
      );
    }
    return resolvedEntries;
  }
}
