import 'package:permit/editor/pubspec_editor.dart';
import 'package:test/test.dart';

void main() {
  group('PubspecEditor', () {
    late String pubspecContent;

    setUp(() {
      pubspecContent = '''
name: test_app
description: A test application
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.0
  path_provider: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
''';
    });

    group('hasDependency', () {
      test('should return true when dependency exists', () {
        final editor = PubspecEditor(pubspecContent);
        expect(editor.hasDependency('flutter'), true);
        expect(editor.hasDependency('cupertino_icons'), true);
        expect(editor.hasDependency('path_provider'), true);
      });

      test('should return false when dependency does not exist', () {
        final editor = PubspecEditor(pubspecContent);
        expect(editor.hasDependency('nonexistent_package'), false);
        expect(editor.hasDependency('http'), false);
      });

      test('should return false when dependencies section does not exist', () {
        final pubspecWithoutDeps = '''
name: test_app
description: A test application
version: 1.0.0
''';
        final editor = PubspecEditor(pubspecWithoutDeps);
        expect(editor.hasDependency('flutter'), false);
      });
    });

    group('addPathDependency', () {
      test('should add path dependency when dependencies section exists', () {
        final editor = PubspecEditor(pubspecContent);
        editor.addPathDependency('my_package', '../my_package');

        final result = editor.toYamlString();
        expect(result.contains('my_package:'), true);
        expect(result.contains('path: ../my_package'), true);
      });

      test('should create dependencies section when it does not exist', () {
        final pubspecWithoutDeps = '''
name: test_app
description: A test application
version: 1.0.0
''';
        final editor = PubspecEditor(pubspecWithoutDeps);
        editor.addPathDependency('my_package', '../my_package');

        final result = editor.toYamlString();
        expect(result.contains('dependencies:'), true);
        expect(result.contains('my_package:'), true);
        expect(result.contains('path: ../my_package'), true);
      });

      test('should throw exception when dependency already exists', () {
        final editor = PubspecEditor(pubspecContent);
        expect(
          editor.addPathDependency('flutter', '../flutter'),
          isFalse,
        );
      });

      test('should add multiple path dependencies', () {
        final editor = PubspecEditor(pubspecContent);
        editor.addPathDependency('package1', '../package1');
        editor.addPathDependency('package2', '../package2');

        final result = editor.toYamlString();
        expect(result.contains('package1:'), true);
        expect(result.contains('path: ../package1'), true);
        expect(result.contains('package2:'), true);
        expect(result.contains('path: ../package2'), true);
      });
    });

    group('removeDependency', () {
      test('should remove an existing dependency', () {
        final editor = PubspecEditor(pubspecContent);
        final result = editor.removeDependency('cupertino_icons');
        expect(result, true);

        final yamlString = editor.toYamlString();
        expect(yamlString.contains('cupertino_icons:'), false);
        expect(editor.hasDependency('cupertino_icons'), false);
      });

      test('should return false when dependency does not exist', () {
        final editor = PubspecEditor(pubspecContent);
        final result = editor.removeDependency('nonexistent_package');
        expect(result, false);
      });

      test('should return false when dependencies section does not exist', () {
        final pubspecWithoutDeps = '''
name: test_app
description: A test application
version: 1.0.0
''';
        final editor = PubspecEditor(pubspecWithoutDeps);
        final result = editor.removeDependency('any_package');
        expect(result, false);
      });

      test('should remove path dependency', () {
        final editor = PubspecEditor(pubspecContent);
        editor.addPathDependency('test_package', '../test_package');

        expect(editor.hasDependency('test_package'), true);

        final result = editor.removeDependency('test_package');
        expect(result, true);
        expect(editor.hasDependency('test_package'), false);

        final yamlString = editor.toYamlString();
        expect(yamlString.contains('test_package:'), false);
      });

      test('should remove sdk dependency', () {
        final editor = PubspecEditor(pubspecContent);
        final result = editor.removeDependency('flutter');
        expect(result, true);
        expect(editor.hasDependency('flutter'), false);
      });
    });
  });
}
