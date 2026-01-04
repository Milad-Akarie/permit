import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:permit/path/path_finder.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';
import 'package:permit/utils/utils.dart';
import 'package:permit/xml_editor/models.dart';
import 'package:permit/xml_editor/xml_editor.dart';

class DeletePermissionCommand extends Command {
  @override
  String get name => 'remove';

  @override
  String get description => 'Remove an existing permission';

  DeletePermissionCommand() {
    argParser.addFlag('android', abbr: 'a', help: 'Remove permission from Android platform only', defaultsTo: false);
    argParser.addFlag('ios', abbr: 'i', help: 'Remove permission from iOS platform only', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    var key = argResults?.rest.isNotEmpty == true ? argResults!.rest[0] : '';

    // Read existing permissions from both platforms
    final manifestFile = PathFinder.getManifest(Directory.current);
    final plistFile = PathFinder.getInfoPlist(Directory.current);
    if (manifestFile == null && plistFile == null) {
      Logger.error('Could not locate AndroidManifest.xml or Info.plist in the current directory.');
      return;
    }

    final manifestEditor = manifestFile == null ? null : ManifestEditor(manifestFile.readAsStringSync());
    final plistEditor = plistFile == null ? null : PListEditor(plistFile.readAsStringSync());

    final existingEntries = [
      ...?manifestEditor?.getPermissions(),
      ...?plistEditor?.getUsageDescriptions(),
    ];

    if (existingEntries.isEmpty) {
      Logger.info('No permissions found to remove.');
      return;
    }

    void onEntriesSelected(List<XmlEntry> entries) {
      final androidEntries = entries.whereType<ManifestPermissionEntry>();
      final iosEntries = entries.whereType<PListUsageDescription>();

      if (androidEntries.isNotEmpty) {
        removeAndroidPermissions(androidEntries.toList(), manifestEditor!, manifestFile!);
      }
      if (iosEntries.isNotEmpty) {
        removeIosPermissions(iosEntries.toList(), plistEditor!, plistFile!);
      }
    }

    // If no key provided, show multi-select of all existing permissions
    if (key.isEmpty) {
      final selectedEntries = multiSelect(
        'Select permissions to remove',
        options: existingEntries,
        display: (entry) {
          final platform = entry is ManifestPermissionEntry ? 'Android' : 'iOS';
          return '[$platform]: ${entry.key}';
        },
      );

      if (selectedEntries.isEmpty) {
        Logger.info('No permissions selected.');
        return;
      }

      onEntriesSelected(selectedEntries);
      return;
    }

    // If key provided, lookup matching entries
    final entriesLookup = EntriesLookup.forDefaults(
      androidOnly: argResults?['android'] == true,
      iosOnly: argResults?['ios'] == true,
    );

    final definitions = entriesLookup.lookup(key);

    if (definitions.isEmpty) {
      Logger.info('No permission definitions found for: $key');
      return;
    }

    // Filter existing entries by the looked-up definitions
    final matchingEntries = existingEntries.where((entry) {
      return definitions.any((def) => def.key == entry.key);
    }).toList();

    if (matchingEntries.isEmpty) {
      Logger.info('No installed permissions found matching: $key');
      return;
    }

    var selected = matchingEntries;
    if (matchingEntries.length > 1) {
      selected = multiSelect(
        'Select which permissions to remove',
        options: matchingEntries,
        display: (entry) {
          final platform = entry is ManifestPermissionEntry ? 'Android' : 'iOS';
          return '[$platform]: ${entry.key}';
        },
      );
    }

    onEntriesSelected(selected);
  }

  void removeAndroidPermissions(List<ManifestPermissionEntry> entries, ManifestEditor manifestEditor, File file) {
    for (var entry in entries) {
      try {
        manifestEditor.removePermission(
          permissionName: entry.key,
          removeComments: (c) => c.startsWith('@permit'),
        );
        Logger.success('Removed Android permission: ${entry.key}');
      } catch (e) {
        Logger.error('Failed to remove Android permission ${entry.key}: $e');
      }
    }

    manifestEditor.save(file);
  }

  void removeIosPermissions(List<PListUsageDescription> entries, PListEditor plistEditor, File file) {
    for (var entry in entries) {
      try {
        plistEditor.removeUsageDescription(
          key: entry.key,
          removeComments: (c) => c.startsWith('@permit'),
        );
        Logger.success('Removed iOS permission: ${entry.key}');
      } catch (e) {
        Logger.error('Failed to remove iOS permission ${entry.key}: $e');
      }
    }

    plistEditor.save(file);
  }
}
