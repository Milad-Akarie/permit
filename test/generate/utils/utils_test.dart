import 'package:test/test.dart';
import 'package:permit/generate/utils.dart';

void main() {
  group('StringExtensions.capitalize', () {
    test('empty string returns empty', () {
      expect(''.capitalize(), equals(''));
    });

    test('single letter capitalized', () {
      expect('a'.capitalize(), equals('A'));
    });

    test('already capitalized remains same', () {
      expect('Abc'.capitalize(), equals('Abc'));
    });

    test('lowercase word capitalized', () {
      expect('hello'.capitalize(), equals('Hello'));
    });
  });

  group('StringExtensions.toCamelCase', () {
    test('snake_case to camelCase', () {
      expect('hello_world'.toCamelCase(), equals('helloWorld'));
    });

    test('space separated to camelCase', () {
      expect('Hello World'.toCamelCase(), equals('helloWorld'));
    });

    test('hyphen separated to camelCase and multiple separators', () {
      expect('multi-part_name test'.toCamelCase(), equals('multiPartNameTest'));
    });

    test('single word stays lowercase first', () {
      expect('Single'.toCamelCase(), equals('single'));
    });

    test('empty string returns empty', () {
      expect(''.toCamelCase(), equals(''));
    });
  });

  group('StringExtensions.toPascalCase', () {
    test('snake_case to PascalCase', () {
      expect('hello_world'.toPascalCase(), equals('HelloWorld'));
    });

    test('space separated to PascalCase', () {
      expect('hello world'.toPascalCase(), equals('HelloWorld'));
    });

    test('hyphen separated to PascalCase', () {
      expect('multi-part_name'.toPascalCase(), equals('MultiPartName'));
    });

    test('empty string returns empty', () {
      expect(''.toPascalCase(), equals(''));
    });
  });

  group('DoubleExt.toShortString', () {
    test('integer-like double returns integer string', () {
      expect(2.0.toShortString(), equals('2'));
      expect(0.0.toShortString(), equals('0'));
      expect((-3.0).toShortString(), equals('-3'));
    });

    test('fractional doubles return full string', () {
      expect(2.5.toShortString(), equals('2.5'));
      expect(2.25.toShortString(), equals('2.25'));
    });
  });
}
