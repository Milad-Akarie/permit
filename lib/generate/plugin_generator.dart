import 'dart:io';

import 'package:collection/collection.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/generate/templates/android/handler_snippet.dart';
import 'package:permit/generate/templates/android/plugin_gradle_temp.dart';
import 'package:permit/generate/templates/android/plugin_kotlin_class_temp.dart';
import 'package:permit/generate/templates/android/plugin_manifest_temp.dart';
import 'package:permit/generate/templates/plugin_pubspec_temp.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/path/path_finder.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';

class PluginGenerator {
  final PathFinder pathFinder;

  PluginGenerator({required this.pathFinder});

  List<Template> _getTemplates() {
    final templates = <Template>[
      PluginPubspecTemp(),
      PluginManifestTemp(),
      PluginGradleTemp(),
    ];

    final manifest = pathFinder.getManifest();
    final infoPlist = pathFinder.getInfoPlist();
    final entryLookUp = EntriesLookup.forDefaults(androidOnly: infoPlist == null, iosOnly: manifest == null);
    if (manifest != null) {
      final editor = ManifestEditor(manifest.readAsStringSync());
      final permissionsInManifest = editor.getPermissions().where((e) => e.generatesCode);
      if (permissionsInManifest.isNotEmpty) {
        final entries = permissionsInManifest.map((e) => entryLookUp.lookupByKey(e.key)).nonNulls;
        if (entries.isNotEmpty) {
          final snippets = <HandlerSnippet>[];
          final entryGroups = entries.groupListsBy((e) => e.group);
          int requestCode = 1000;
          for (var group in entryGroups.entries) {
            if (customHandlers[group.key] != null) {
              snippets.add(customHandlers[group.key]!(requestCode++));
              continue;
            }
            snippets.add(
              HandlerSnippet(
                key: group.key,
                requestCode: '${requestCode++}',
                permissions: List.of(group.value.whereType<AndroidPermissionDef>()),
              ),
            );
          }
          if (snippets.isNotEmpty) {
            templates.add(
              PluginKotlinClassTemp(
                handlers: snippets,
              ),
            );
          }
          Logger.info('Generating plugin manifest with ${permissionsInManifest.length} permissions.');
        }
      }
    }

    return templates;
  }

  void generate() {
    final rootPath = pathFinder.root.path;
    for (var template in _getTemplates()) {
      try {
        final file = File('$rootPath/tools/permit/${template.path}');
        file.createSync(recursive: true);
        file.writeAsStringSync(template.generate());
      } catch (e) {
        Logger.error('Failed to generate ${template.path}: $e');
      }
    }
  }
}
