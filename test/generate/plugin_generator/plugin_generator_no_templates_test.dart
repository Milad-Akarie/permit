import 'dart:io';

import 'package:test/test.dart';
import 'package:permit/generate/plugin_generator.dart';
import 'package:permit/path/path_finder.dart';

void main() {
  group('PathFinder.findRootDirectory', () {
    test('finds ancestor with pubspec.yaml', () {
      final root = Directory.systemTemp.createTempSync('permit_root_');
      try {
        final pubspec = File('${root.path}/pubspec.yaml')..createSync();
        pubspec.writeAsStringSync('name: test_project');

        final nested = Directory('${root.path}/a/b/c')..createSync(recursive: true);

        final found = PathFinder.findRootDirectory(nested);
        expect(found, isNotNull);
        expect(found!.path, equals(root.path));
      } finally {
        try {
          root.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('returns null when no pubspec in ancestors', () {
      final root = Directory.systemTemp.createTempSync('no_pubspec_root_');
      try {
        final nested = Directory('${root.path}/x/y')..createSync(recursive: true);
        final found = PathFinder.findRootDirectory(nested);
        expect(found, isNull);
      } finally {
        try {
          root.deleteSync(recursive: true);
        } catch (_) {}
      }
    });
  });

  group('PathFinderImpl.getPubspec', () {
    test('returns pubspec file when present', () {
      final root = Directory.systemTemp.createTempSync('permit_pubspec_root_');
      try {
        final pubspec = File('${root.path}/pubspec.yaml')..createSync();
        pubspec.writeAsStringSync('name: with_pubspec');

        final pf = PathFinderImpl(root);
        final result = pf.getPubspec();
        expect(result, isNotNull);
        expect(result!.path, contains('pubspec.yaml'));
      } finally {
        try {
          root.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('returns null when pubspec missing', () {
      final root = Directory.systemTemp.createTempSync('permit_no_pubspec_root_');
      try {
        final pf = PathFinderImpl(root);
        final result = pf.getPubspec();
        expect(result, isNull);
      } finally {
        try {
          root.deleteSync(recursive: true);
        } catch (_) {}
      }
    });
  });

  group('PluginGenerator.generate (no templates)', () {
    test('deletes existing tools/permit_plugin and removes dependency from pubspec', () {
      final root = Directory.systemTemp.createTempSync('permit_gen_root_');
      try {
        // create pubspec with permit_plugin dependency
        final pubspec = File('${root.path}/pubspec.yaml')..createSync();
        pubspec.writeAsStringSync('''
name: test_proj

dependencies:
  flutter:
    sdk: flutter
  permit_plugin:
    path: tools/permit_plugin
''');

        // create tools/permit_plugin directory to be deleted
        final toolDir = Directory('${root.path}/tools/permit_plugin')..createSync(recursive: true);
        File('${toolDir.path}/dummy.txt')
          ..createSync()
          ..writeAsStringSync('hello');

        final pf = PathFinderImpl(root);
        final generator = PluginGenerator(pathFinder: pf);

        // run generate - should detect no templates and delete the tool dir and remove dependency
        generator.generate();

        // tools/permit_plugin should no longer exist
        expect(Directory('${root.path}/tools/permit_plugin').existsSync(), isFalse);

        // pubspec should have been updated to remove permit_plugin
        final updated = File('${root.path}/pubspec.yaml').readAsStringSync();
        expect(updated.contains('permit_plugin'), isFalse);
      } finally {
        try {
          root.deleteSync(recursive: true);
        } catch (_) {}
      }
    });
  });
}
