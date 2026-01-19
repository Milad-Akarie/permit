import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:permit/editor/pubspec_editor.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/generate/templates/android/handlers/kotlin_handler_snippet.dart';
import 'package:permit/generate/templates/android/plugin_gradle_temp.dart';
import 'package:permit/generate/templates/android/plugin_kotlin_class_temp.dart';
import 'package:permit/generate/templates/android/plugin_manifest_temp.dart';
import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/generate/templates/ios/plugin_pod_temp.dart';
import 'package:permit/generate/templates/ios/plugin_privacy_manifest.dart';
import 'package:permit/generate/templates/ios/plugin_swift_class_temp.dart';
import 'package:permit/generate/templates/plugin_dart_temp.dart';
import 'package:permit/generate/templates/plugin_pubspec_temp.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/path/path_finder.dart';
import 'package:permit/registry/android_permissions.dart';
import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';
import 'package:permit/registry/permit_registry.dart';
import 'package:permit/utils/logger.dart';

const String _toolRoot = 'tools/permit_plugin';
const String _androidDir = '$_toolRoot/android/';
const String _iosDir = '$_toolRoot/ios/';

/// Generates platform-specific code (Kotlin/Swift/Dart) to handle permissions.
class PluginGenerator {
  /// Path finder to locate project files.
  final PathFinder pathFinder;

  /// Default constructor.
  PluginGenerator({required this.pathFinder});

  List<KotlinHandlerSnippet> _getKotlinHandlers() {
    final manifest = pathFinder.getManifest();
    final handlers = <KotlinHandlerSnippet>[];
    if (manifest == null) return handlers;
    final editor = ManifestEditor(manifest.readAsStringSync());
    final permissionsInManifest = editor.getPermissions().where(
      (e) => e.generatesCode,
    );
    if (permissionsInManifest.isEmpty) return handlers;

    final entryLookUp = EntriesLookup.forDefaults(androidOnly: true);

    final runtimeEntries = permissionsInManifest
        .map((e) => entryLookUp.findByKey(e.key))
        .whereType<AndroidPermissionDef>()
        .where((e) => e.runtime);

    if (runtimeEntries.isNotEmpty) {
      final allKeys = runtimeEntries.map((e) => e.key).toSet();
      final entryGroups = runtimeEntries.groupListsBy((e) => e.group);
      for (var group in entryGroups.entries) {
        if (customKotlinHandlers[group.key] != null) {
          handlers.add(customKotlinHandlers[group.key]!());
          continue;
        }

        final permissions = List.of(group.value);
        if (group.key == AndroidPermissions.readCalendar.group &&
            allKeys.contains(AndroidPermissions.writeCalendar.key)) {
          permissions.add(AndroidPermissions.writeCalendar);
        }

        handlers.add(
          KotlinHandlerSnippet(
            key: group.key,
            permissions: permissions,
          ),
        );
      }
    }
    return handlers;
  }

  List<SwiftHandlerSnippet> _getSwiftHandlers() {
    final handlers = <SwiftHandlerSnippet>[];
    final plist = pathFinder.getInfoPlist();

    if (plist == null) return handlers;
    final editor = PListEditor(plist.readAsStringSync());
    final permissionsInPlist = editor.getUsageDescriptions();
    if (permissionsInPlist.isEmpty) return handlers;
    final entryLookUp = EntriesLookup.forDefaults(iosOnly: true);
    final groups = permissionsInPlist
        .where((e) => e.generatesCode)
        .map((e) => entryLookUp.findByKey(e.key))
        .whereType<IosPermissionDef>()
        .map((e) => e.group)
        .toSet();

    for (var group in groups) {
      final handler = swiftPermissionHandlers[group]?.call();
      if (handler != null) {
        handlers.add(handler);
      } else {
        throw Exception(
          'No Swift handler found for iOS permission group: $group',
        );
      }
    }

    return handlers;
  }

  /// Generates the plugin code based on the current permissions in manifest and plist.
  ///
  /// This method:
  /// 1. Scans manifest/plist for permissions that require code generation.
  /// 2. Creates necessary Android/iOS platform code (Kotlin/Swift).
  /// 3. Updates the `tools/permit_plugin` directory.
  /// 4. Updates `pubspec.yaml` to include the generated local plugin.
  void generate() {
    final templates = <Template>[];
    final swiftHandlers = _getSwiftHandlers();
    if (swiftHandlers.isNotEmpty) {
      templates.addAll([
        PluginPodTemp(),
        PluginPrivacyManifestTemp(),
        PluginSwiftClassTemp(List.of(swiftHandlers)),
      ]);
    } else {
      _deleteDir(_iosDir);
    }

    final kotlinHandlers = _getKotlinHandlers();

    // adds Bluetooth handler if iOS Bluetooth permission is requested
    // granular handlers will still be generated
    if (swiftHandlers.any((e) => e.key == IosPermissions.bluetooth.group)) {
      final androidPermissionKeys = kotlinHandlers
          .expand((handler) => handler.permissions.map((e) => e.key))
          .toSet();
      final androidBluetoothPermissions = <AndroidPermissionDef>{};
      if (androidPermissionKeys.contains(
        AndroidPermissions.bluetoothScan.key,
      )) {
        androidBluetoothPermissions.add(AndroidPermissions.bluetoothScan);
      }
      if (androidPermissionKeys.contains(
        AndroidPermissions.bluetoothConnect.key,
      )) {
        androidBluetoothPermissions.add(AndroidPermissions.bluetoothConnect);
      }
      if (androidBluetoothPermissions.isNotEmpty) {
        kotlinHandlers.add(
          KotlinHandlerSnippet(
            key: IosPermissions.bluetooth.group,
            permissions: List.of(androidBluetoothPermissions),
          ),
        );
      }
    }

    if (kotlinHandlers.isNotEmpty) {
      templates.addAll([
        PluginManifestTemp(),
        PluginGradleTemp(),
        PluginKotlinClassTemp(handlers: kotlinHandlers),
      ]);
    } else {
      _deleteDir(_androidDir);
    }

    final rootPath = pathFinder.root.path;
    if (templates.isEmpty) {
      _deleteDir(
        _toolRoot,
        message: 'Deleted existing plugin generation directory.',
      );
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
        android: kotlinHandlers.isNotEmpty,
        ios: swiftHandlers.isNotEmpty,
      ),
    );

    final allKeys = {
      ...kotlinHandlers.map((e) => e.key),
      ...swiftHandlers.map((e) => e.key),
    };

    final snippets = allKeys.map((key) {
      final kotlinHandler = kotlinHandlers.firstWhereOrNull(
        (h) => h.key == key,
      );
      final swiftHandler = swiftHandlers.firstWhereOrNull((h) => h.key == key);
      return PermissionGetterSnippet(
        key,
        entries: [
          ...?kotlinHandler?.permissions,
          if (swiftHandler != null) swiftHandler.entry,
        ],
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
        Logger.error(
          'Failed to update pubspec.yaml with permit_plugin dependency.',
        );
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
