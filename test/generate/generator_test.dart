import 'dart:io';

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
}
