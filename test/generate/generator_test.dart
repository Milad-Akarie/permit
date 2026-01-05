import 'dart:io';

import 'package:permit/generate/generator.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:test/test.dart';

class MockTemplate implements Template {
  final String mockPath;
  final String mockContent;

  MockTemplate(this.mockPath, this.mockContent);

  @override
  String get path => mockPath;

  @override
  String generate() => mockContent;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('generator_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Generator', () {
    test('should generate files for all templates', () {
      final template1 = MockTemplate('file1.txt', 'content1');
      final template2 = MockTemplate('subdir/file2.txt', 'content2');

      final generator = Generator(rootDir: tempDir, templates: [template1, template2]);
      generator.generate();

      final file1 = File('${tempDir.path}/file1.txt');
      final file2 = File('${tempDir.path}/subdir/file2.txt');

      expect(file1.existsSync(), isTrue);
      expect(file1.readAsStringSync(), equals('content1'));

      expect(file2.existsSync(), isTrue);
      expect(file2.readAsStringSync(), equals('content2'));
    });

    test('should create directories recursively', () {
      final template = MockTemplate('deep/nested/file.txt', 'nested content');

      final generator = Generator(rootDir: tempDir, templates: [template]);
      generator.generate();

      final file = File('${tempDir.path}/deep/nested/file.txt');
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), equals('nested content'));
    });

    // Note: Testing error logging might require mocking Logger, but for simplicity, we can assume it works if no exception is thrown.
  });
}
