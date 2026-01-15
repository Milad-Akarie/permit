import 'dart:io';

import 'package:collection/collection.dart';
import 'package:permit/editor/pubspec_editor.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/generate/templates/android/kotlin_handler_snippet.dart';
import 'package:permit/generate/templates/android/plugin_gradle_temp.dart';
import 'package:permit/generate/templates/android/plugin_kotlin_class_temp.dart';
import 'package:permit/generate/templates/android/plugin_manifest_temp.dart';
import 'package:permit/generate/templates/ios/plugin_pod_temp.dart';
import 'package:permit/generate/templates/ios/plugin_privacy_manifest.dart';
import 'package:permit/generate/templates/ios/plugin_swift_class_temp.dart';
import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/generate/templates/plugin_dart_temp.dart';
import 'package:permit/generate/templates/plugin_pubspec_temp.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/path/path_finder.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';
import 'package:path/path.dart' as p;

const String _toolRoot = 'tools/permit_plugin';
const String _androidDir = '$_toolRoot/android/';
const String _iosDir = '$_toolRoot/ios/';

class PluginGenerator {
  final PathFinder pathFinder;

  PluginGenerator({required this.pathFinder});

  List<Template>? _getAndroidTemplates() {
    final manifest = pathFinder.getManifest();
    if (manifest == null) return null;
    final editor = ManifestEditor(manifest.readAsStringSync());
    final permissionsInManifest = editor.getPermissions().where((e) => e.generatesCode);
    if (permissionsInManifest.isEmpty) return null;

    final entryLookUp = EntriesLookup.forDefaults(androidOnly: true);

    final runtimeEntries = permissionsInManifest
        .map((e) => entryLookUp.lookupByKey(e.key))
        .whereType<AndroidPermissionDef>()
        .where((e) => e.runtime);

    if (runtimeEntries.isNotEmpty) {
      final snippets = <KotlinHandlerSnippet>[];
      final entryGroups = runtimeEntries.groupListsBy((e) => e.group);
      int requestCode = 1010;
      for (var group in entryGroups.entries) {
        if (customHandlers[group.key] != null) {
          snippets.add(customHandlers[group.key]!(requestCode++));
          continue;
        }
        snippets.add(
          KotlinHandlerSnippet(
            key: group.key,
            requestCode: '${requestCode++}',
            permissions: List.of(group.value.whereType<AndroidPermissionDef>()),
          ),
        );
      }
      if (snippets.isNotEmpty) {
        return [
          PluginManifestTemp(),
          PluginGradleTemp(),
          PluginKotlinClassTemp(handlers: snippets),
        ];
      }
    }
    return null;
  }

  List<Template>? _getIosTemplates() {
    final plist = pathFinder.getInfoPlist();
    if (plist == null) return null;
    final editor = PListEditor(plist.readAsStringSync());
    final permissionsInPlist = editor.getUsageDescriptions();
    if (permissionsInPlist.isEmpty) return null;
    final entryLookUp = EntriesLookup.forDefaults(iosOnly: true);
    final groups = permissionsInPlist
        .where((e) => e.generatesCode)
        .map((e) => entryLookUp.lookupByKey(e.key))
        .whereType<IosPermissionDef>()
        .map((e) => e.group)
        .toSet();

    if (groups.isEmpty) return null;
    final handlers = <SwiftHandlerSnippet>[];
    for (var group in groups) {
      final handler = swiftPermissionHandlers[group]?.call();
      if (handler != null) {
        handlers.add(handler);
      } else {
        throw Exception('No Swift handler found for iOS permission group: $group');
      }
    }

    return [
      PluginPodTemp(),
      PluginPrivacyManifestTemp(),
      PluginSwiftClassTemp(List.of(handlers)),
    ];
  }

  void generate() {
    final androidTemplates = _getAndroidTemplates();

    final templates = <Template>[];
    if (androidTemplates != null) {
      templates.addAll(androidTemplates);
    } else {
      _deleteDir(_androidDir);
    }

    final iosTemplates = _getIosTemplates();
    if (iosTemplates != null) {
      templates.addAll(iosTemplates);
    } else {
      _deleteDir(_iosDir);
    }

    final rootPath = pathFinder.root.path;
    if (templates.isEmpty) {
      _deleteDir(_toolRoot, message: 'Deleted existing plugin generation directory.');
      final toolDir = Directory(p.join(rootPath, 'tools'));
      if (toolDir.existsSync() && toolDir.listSync().isEmpty) {
        toolDir.deleteSync();
      }
      // remove dependency from pubspec.yaml
      final pubspecFile = pathFinder.getPubspec();
      if (pubspecFile != null) {
        final pubspecEditor = PubspecEditor(pubspecFile.readAsStringSync());
        if (pubspecEditor.removeDependency('permit_plugin')) {
          if (pubspecEditor.save(pubspecFile)) {
            Logger.info('Removed permit_plugin dependency from pubspec.yaml');
          }
        }
      }
      return;
    }

    templates.add(
      PluginPubspecTemp(
        android: androidTemplates != null,
        ios: iosTemplates != null,
      ),
    );

    final kotlinSnippets = androidTemplates?.whereType<PluginKotlinClassTemp>().firstOrNull?.handlers ?? [];
    final swiftSnippets = iosTemplates?.whereType<PluginSwiftClassTemp>().firstOrNull?.handlers ?? [];

    final allKeys = {...kotlinSnippets.map((e) => e.key), ...swiftSnippets.map((e) => e.key)};

    final snippets = allKeys.map((key) {
      final kotlinHandler = kotlinSnippets.firstWhereOrNull((h) => h.key == key);
      final swiftHandler = swiftSnippets.firstWhereOrNull((h) => h.key == key);

      final platform = (kotlinHandler != null && swiftHandler != null)
          ? null
          : (kotlinHandler != null ? 'android' : 'ios');

      return PermissionGetterSnippet(
        key,
        platform,
        hasService:
            kotlinHandler?.permissions.any((e) => e.service != null) == true ||
            swiftHandler?.entry.service != null ||
            false,
      );
    }).toList();

    templates.add(PluginDartTemp(snippets));

    for (var template in templates) {
      try {
        final file = File(p.join(rootPath, _toolRoot, template.path));
        file.createSync(recursive: true);
        file.writeAsStringSync(template.generate());
      } catch (e) {
        Logger.error('Failed to generate ${template.path}: $e');
      }
    }

    final pubspecFile = pathFinder.getPubspec();
    if (pubspecFile == null) {
      Logger.error('Pubspec.yaml not found. Cannot update dependencies.');
      return;
    }
    final pubspecEditor = PubspecEditor(pubspecFile.readAsStringSync());
    if (!pubspecEditor.hasDependency('permit_plugin')) {
      pubspecEditor.addPathDependency('permit_plugin', _toolRoot);
      if (pubspecEditor.save(pubspecFile)) {
        Logger.info(
          'pubspec.yaml updated, run ${Logger.mutedPen("flutter pub get")} then hard-reload App.',
        );
      } else {
        Logger.error('Failed to update pubspec.yaml with permit_plugin dependency.');
      }
    } else {
      Logger.info('Plugin code updated, hard-reload is required.');
    }
  }

  void _deleteDir(String path, {String? message}) {
    try {
      final target = Directory(p.join(pathFinder.root.path, path));
      if (target.existsSync()) {
        target.deleteSync(recursive: true);
        if (message != null) {
          Logger.info(message);
        }
      }
    } catch (e) {
      Logger.error('Failed to delete directory: $e');
    }
  }
}
