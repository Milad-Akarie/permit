import 'package:permit/commands/permit_runner.dart';
import 'package:permit/utils/logger.dart';
import 'package:permit/editor/models.dart';
import 'package:permit/editor/xml_editor.dart';

class ListPermissionsCommand extends PermitCommand {
  @override
  String get name => 'list';

  @override
  String get description => 'List all existing permissions';

  ListPermissionsCommand() {
    argParser.addFlag('android', abbr: 'a', help: 'Show only Android permissions', defaultsTo: false);
    argParser.addFlag('ios', abbr: 'i', help: 'Show only iOS permissions', defaultsTo: false);
    argParser.addFlag('code', abbr: 'c', help: 'Show only permissions that generate code', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final androidOnly = argResults?['android'] == true;
    final iosOnly = argResults?['ios'] == true;
    final codeOnly = argResults?['code'] == true;

    // Minimize I/O by reading files only when needed
    final manifestFile = (!iosOnly) ? pathFinder.getManifest() : null;
    final plistFile = (!androidOnly) ? pathFinder.getInfoPlist() : null;

    if (manifestFile == null && plistFile == null) {
      Logger.error('Could not locate AndroidManifest.xml or Info.plist in the current directory.');
      return;
    }

    final allEntries = <XmlEntry>[];

    // Read Android permissions only if needed
    if (manifestFile != null) {
      try {
        final manifestEditor = ManifestEditor(manifestFile.readAsStringSync());
        final androidEntries = manifestEditor.getPermissions();
        allEntries.addAll(androidEntries);
      } catch (e) {
        Logger.error('Failed to read AndroidManifest.xml: $e');
      }
    }

    // Read iOS permissions only if needed
    if (plistFile != null) {
      try {
        final plistEditor = PListEditor(plistFile.readAsStringSync());
        final iosEntries = plistEditor.getUsageDescriptions();
        allEntries.addAll(iosEntries);
      } catch (e) {
        Logger.error('Failed to read Info.plist: $e');
      }
    }

    // Filter by code generation if requested
    final filteredEntries = codeOnly ? allEntries.where((entry) => entry.generatesCode).toList() : allEntries;

    if (filteredEntries.isEmpty) {
      Logger.info('No permissions found.');
      return;
    }

    final androidEntries = filteredEntries.whereType<ManifestPermissionEntry>().toList();
    final iosEntries = filteredEntries.whereType<PListUsageDescription>().toList();
    print('');
    if (androidEntries.isNotEmpty) {
      Logger.android('Uses Permissions (${androidEntries.length}):');
      for (final entry in androidEntries) {
        final codeIndicator = entry.generatesCode ? ' [CODE]' : '';

        Logger.listed('${Logger.mutedPen.write(entry.key)}$codeIndicator');
      }
      if (iosEntries.isNotEmpty) print('');
    }

    if (iosEntries.isNotEmpty) {
      Logger.ios('Usage Descriptions (${iosEntries.length}):');
      for (final entry in iosEntries) {
        final codeIndicator = entry.generatesCode ? ' [CODE]' : '';

        Logger.listed('${Logger.mutedPen.write(entry.key)}: ${entry.description}$codeIndicator');
      }
    }
  }
}
