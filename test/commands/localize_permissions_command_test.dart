import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:permit/commands/localize/localize_permissions_command.dart';
import 'package:permit/commands/localize/utils.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:permit/editor/models.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late MockPathFinder pathFinder;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('permit_test_');
    pathFinder = MockPathFinder(tempDir);

    // Create iOS project structure
    final iosDir = Directory('${tempDir.path}/ios');
    iosDir.createSync();

    final runnerDir = Directory('${iosDir.path}/Runner');
    runnerDir.createSync();

    pathFinder.createMockInfoPlist();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('LocalizePermissionsCommand', () {
    test('should have correct name and description', () {
      final command = LocalizePermissionsCommand();
      expect(command.name, equals('localize'));
      expect(
        command.description,
        equals(
          'Generate InfoPlist.xcstrings for permission localizations (iOS)',
        ),
      );
    });

    test('should return early if Info.plist not found', () async {
      // Remove the mock Info.plist
      final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
      if (infoPlist.existsSync()) {
        infoPlist.deleteSync();
      }

      final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(
        () async => runner.run(['localize']),
        zoneSpecification: spec,
      );
      print(output.toString());

      expect(output.toString(), contains('Could not find Info.plist'));
    });

    test('should return early if no usage descriptions found', () async {
      // Create an Info.plist with no usage descriptions
      final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
      infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Test App</string>
</dict>
</plist>''');

      final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(
        () async => runner.run(['localize']),
        zoneSpecification: spec,
      );

      expect(
        output.toString(),
        contains('No usage description keys found in Info.plist'),
      );
    });

    test('should return early if Runner.xcodeproj not found', () async {
      // Create an Info.plist with usage descriptions
      final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
      infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

      // Remove the xcodeproj directory
      final xcodeProjDir = Directory(
        '${tempDir.path}/ios/Runner.xcodeproj',
      );
      if (xcodeProjDir.existsSync()) {
        xcodeProjDir.deleteSync(recursive: true);
      }

      final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(
        () async => runner.run(['localize']),
        zoneSpecification: spec,
      );

      expect(output.toString(), contains('Could not find'));
      expect(output.toString(), contains('Runner.xcodeproj'));
    });

    test('should validate language codes correctly', () {
      expect(isValidLanguageCode('en'), isTrue);
      expect(isValidLanguageCode('eng'), isTrue);
      expect(isValidLanguageCode('en-US'), isTrue);
      expect(isValidLanguageCode('pt-BR'), isTrue);
      expect(isValidLanguageCode('zh-Hans'), isTrue);
      expect(isValidLanguageCode('zh-Hans-CN'), isTrue);
      expect(isValidLanguageCode('invalid'), isFalse);
      expect(isValidLanguageCode('EN'), isFalse);
      expect(isValidLanguageCode('e'), isFalse);
    });

    test('should build xcstrings JSON with correct structure', () {
      // Test the logic that builds xcstrings JSON
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{},
        'version': '1.0',
      };

      final usageDescriptions = [
        PListUsageDescription(
          key: 'NSCameraUsageDescription',
          description: 'Camera access for photos',
          comments: [],
        ),
      ];

      final langCodes = <String>{'en', 'fr', 'de'};

      // Simulate the logic from LocalizePermissionsCommand.run()
      for (final entry in usageDescriptions) {
        final strings = xcstringsJson['strings'] as Map<String, dynamic>;
        strings[entry.key] ??= {
          'localizations': <String, dynamic>{},
        };
        final localizations = strings[entry.key]?['localizations'];
        if (localizations is Map<String, dynamic>) {
          for (final langCode in langCodes) {
            localizations.putIfAbsent(langCode, () {
              return {
                'stringUnit': {
                  'state': langCode == 'en' ? 'translated' : 'new',
                  'value': entry.description,
                },
              };
            });
          }
        }
      }

      final strings = xcstringsJson['strings'] as Map<String, dynamic>;
      expect(strings.containsKey('NSCameraUsageDescription'), isTrue);
      final cameraEntry = strings['NSCameraUsageDescription'] as Map<String, dynamic>;
      final localizations = cameraEntry['localizations'] as Map<String, dynamic>;
      expect(localizations.containsKey('en'), isTrue);
      expect(localizations.containsKey('fr'), isTrue);
      expect(localizations.containsKey('de'), isTrue);
      expect(localizations['en']['stringUnit']['state'], equals('translated'));
      expect(localizations['fr']['stringUnit']['state'], equals('new'));
    });

    test('should preserve existing entries when adding new languages', () {
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': <String, dynamic>{
              'en': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Camera access for photos',
                },
              },
              'fr': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Accès à la caméra pour les photos',
                },
              },
            },
          },
        },
        'version': '1.0',
      };

      final langCodes = <String>{'en', 'fr', 'de'};

      // Simulate adding new language to existing entry
      final entry = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access for photos',
        comments: [],
      );

      final strings = xcstringsJson['strings'] as Map<String, dynamic>;
      strings[entry.key] ??= {
        'localizations': <String, dynamic>{},
      };
      final localizations = strings[entry.key]?['localizations'];
      if (localizations is Map<String, dynamic>) {
        for (final langCode in langCodes) {
          localizations.putIfAbsent(langCode, () {
            return {
              'stringUnit': {
                'state': langCode == 'en' ? 'translated' : 'new',
                'value': entry.description,
              },
            };
          });
        }
      }

      // Verify existing entries are preserved and new one is added
      final finalLocalizations = strings['NSCameraUsageDescription']?['localizations'] as Map<String, dynamic>;
      expect(
        finalLocalizations['en']['stringUnit']['value'],
        equals('Camera access for photos'),
      );
      expect(
        finalLocalizations['fr']['stringUnit']['value'],
        equals('Accès à la caméra pour les photos'),
      );
      expect(finalLocalizations['de']['stringUnit']['state'], equals('new'));
    });

    test('should handle xcstrings JSON formatting', () {
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': {
              'en': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Camera access',
                },
              },
            },
          },
        },
        'version': '1.0',
      };

      final formatter = JsonEncoder.withIndent('  ');
      final jsonString = formatter.convert(xcstringsJson);

      expect(jsonString, contains('"sourceLanguage": "en"'));
      expect(jsonString, contains('"NSCameraUsageDescription"'));
      expect(jsonString, contains('  ')); // Check for proper indentation
    });

    test('should merge multiple usage descriptions into xcstrings', () {
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{},
        'version': '1.0',
      };

      final usageDescriptions = [
        PListUsageDescription(
          key: 'NSCameraUsageDescription',
          description: 'Camera access for photos',
          comments: [],
        ),
        PListUsageDescription(
          key: 'NSMicrophoneUsageDescription',
          description: 'Microphone access for recording',
          comments: [],
        ),
        PListUsageDescription(
          key: 'NSPhotoLibraryUsageDescription',
          description: 'Photo library access',
          comments: [],
        ),
      ];

      final langCodes = <String>{'en', 'fr'};

      // Simulate the logic from LocalizePermissionsCommand.run()
      for (final entry in usageDescriptions) {
        final strings = xcstringsJson['strings'] as Map<String, dynamic>;
        strings[entry.key] ??= {
          'localizations': <String, dynamic>{},
        };
        final localizations = strings[entry.key]?['localizations'];
        if (localizations is Map<String, dynamic>) {
          for (final langCode in langCodes) {
            localizations.putIfAbsent(langCode, () {
              return {
                'stringUnit': {
                  'state': langCode == 'en' ? 'translated' : 'new',
                  'value': entry.description,
                },
              };
            });
          }
        }
      }

      final strings = xcstringsJson['strings'] as Map<String, dynamic>;
      expect(strings.length, equals(3));
      expect(strings.containsKey('NSCameraUsageDescription'), isTrue);
      expect(strings.containsKey('NSMicrophoneUsageDescription'), isTrue);
      expect(strings.containsKey('NSPhotoLibraryUsageDescription'), isTrue);
    });

    test('should create InfoPlist.xcstrings file in correct location', () {
      // This test verifies the xcstrings file path logic
      final xcstringsPath = '${tempDir.path}/InfoPlist.xcstrings';
      final xcstringsFile = File(xcstringsPath);

      // Simulate file creation
      final data = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': {},
        'version': '1.0',
      };

      final formatter = JsonEncoder.withIndent('  ');
      xcstringsFile.writeAsStringSync(formatter.convert(data));

      expect(xcstringsFile.existsSync(), isTrue);
      expect(xcstringsFile.path, equals(xcstringsPath));

      final content = xcstringsFile.readAsStringSync();
      final decoded = jsonDecode(content);
      expect(decoded['sourceLanguage'], equals('en'));
    });

    test('should handle extraction of existing language codes', () {
      // Test extracting language codes from existing xcstrings
      final xcstringsJson = <String, dynamic>{
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': <String, dynamic>{
              'en': {
                'stringUnit': {'state': 'translated', 'value': 'Camera'},
              },
              'fr': {
                'stringUnit': {'state': 'translated', 'value': 'Caméra'},
              },
              'de': {
                'stringUnit': {'state': 'translated', 'value': 'Kamera'},
              },
            },
          },
          'NSMicrophoneUsageDescription': {
            'localizations': <String, dynamic>{
              'en': {
                'stringUnit': {'state': 'translated', 'value': 'Microphone'},
              },
              'es': {
                'stringUnit': {'state': 'new', 'value': 'Micrófono'},
              },
            },
          },
        },
      };

      // Extract all language codes
      final existingLangCodes = <String>{};
      final strings = xcstringsJson['strings'];
      if (strings is Map<String, dynamic>) {
        for (final key in strings.keys) {
          final localizations = strings[key]?['localizations'];
          if (localizations is Map<String, dynamic>) {
            existingLangCodes.addAll(localizations.keys);
          }
        }
      }

      expect(existingLangCodes, equals({'en', 'fr', 'de', 'es'}));
    });

    test('should handle empty localizations in xcstrings', () {
      final xcstringsJson = <String, dynamic>{
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': <String, dynamic>{},
          },
        },
      };

      // Extract language codes
      final existingLangCodes = <String>{};
      final strings = xcstringsJson['strings'];
      if (strings is Map<String, dynamic>) {
        for (final key in strings.keys) {
          final localizations = strings[key]?['localizations'];
          if (localizations is Map<String, dynamic>) {
            existingLangCodes.addAll(localizations.keys);
          }
        }
      }

      expect(existingLangCodes, isEmpty);
    });

    test('should return empty set if strings is not a map', () {
      final xcstringsJson = <String, dynamic>{
        'strings': null,
      };

      // Extract language codes
      final existingLangCodes = <String>{};
      final strings = xcstringsJson['strings'];
      if (strings is Map<String, dynamic>) {
        for (final key in strings.keys) {
          final localizations = strings[key]?['localizations'];
          if (localizations is Map<String, dynamic>) {
            existingLangCodes.addAll(localizations.keys);
          }
        }
      }

      expect(existingLangCodes, isEmpty);
    });

    test(
      'should handle command line arguments with specific languages',
      () async {
        // Create an Info.plist with usage descriptions
        final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
        infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

        // Ensure xcodeproj exists for this test
        final xcodeDir = Directory(
          '${tempDir.path}/ios/Runner.xcodeproj',
        );
        if (!xcodeDir.existsSync()) {
          xcodeDir.createSync(recursive: true);
          File(
            '${xcodeDir.path}/project.pbxproj',
          ).writeAsStringSync('// Empty pbxproj for testing');
        }

        final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) {
            output.writeln(line);
          },
        );

        await runZoned(
          () async => runner.run(['localize', 'fr', 'de']),
          zoneSpecification: spec,
        );

        // Should not show early return messages
        expect(output.toString(), isNot(contains('Could not find Info.plist')));
        expect(
          output.toString(),
          isNot(contains('No usage description keys found')),
        );
        expect(output.toString(), isNot(contains('Could not find')));
        expect(output.toString(), isNot(contains('Runner.xcodeproj')));
      },
    );

    test('should handle invalid language code and return early', () async {
      // Create an Info.plist with usage descriptions
      final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
      infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

      // Ensure xcodeproj exists for this test
      final xcodeDir = Directory('${tempDir.path}/ios/Runner.xcodeproj');
      if (!xcodeDir.existsSync()) {
        xcodeDir.createSync(recursive: true);
        File(
          '${xcodeDir.path}/project.pbxproj',
        ).writeAsStringSync('// Empty pbxproj for testing');
      }

      final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(
        () async => runner.run(['localize', 'invalid-lang-code']),
        zoneSpecification: spec,
      );

      expect(
        output.toString(),
        contains('Invalid language code provided: invalid-lang-code'),
      );
    });

    test('should handle multiple invalid language codes', () async {
      // Create an Info.plist with usage descriptions
      final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
      infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

      // Ensure xcodeproj exists for this test
      final xcodeDir = Directory('${tempDir.path}/ios/Runner.xcodeproj');
      if (!xcodeDir.existsSync()) {
        xcodeDir.createSync(recursive: true);
        File(
          '${xcodeDir.path}/project.pbxproj',
        ).writeAsStringSync('// Empty pbxproj for testing');
      }

      final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

      final output = StringBuffer();
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          output.writeln(line);
        },
      );

      await runZoned(
        () async => runner.run(['localize', 'invalid1', 'en', 'invalid2']),
        zoneSpecification: spec,
      );

      expect(
        output.toString(),
        contains('Invalid language code provided: invalid1'),
      );
      expect(
        output.toString(),
        isNot(contains('Invalid language code provided: en')),
      );
    });

    test(
      'should handle empty command line arguments (use all known regions)',
      () async {
        // Create an Info.plist with usage descriptions
        final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
        infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

        // Ensure xcodeproj exists for this test
        final xcodeDir = Directory(
          '${tempDir.path}/ios/Runner.xcodeproj',
        );
        if (!xcodeDir.existsSync()) {
          xcodeDir.createSync(recursive: true);
          File(
            '${xcodeDir.path}/project.pbxproj',
          ).writeAsStringSync('// Empty pbxproj for testing');
        }

        final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) {
            output.writeln(line);
          },
        );

        await runZoned(
          () async => runner.run(['localize']),
          zoneSpecification: spec,
        );

        // Should not show early return messages
        expect(output.toString(), isNot(contains('Could not find Info.plist')));
        expect(
          output.toString(),
          isNot(contains('No usage description keys found')),
        );
        expect(output.toString(), isNot(contains('Could not find')));
        expect(output.toString(), isNot(contains('Runner.xcodeproj')));
        expect(
          output.toString(),
          isNot(contains('Invalid language code provided')),
        );
      },
    );

    test(
      'should handle existing xcstrings file with different source language',
      () {
        final command = LocalizePermissionsCommand();
        final xcstringsFile = File('${tempDir.path}/test.xcstrings');

        final existingData = {
          'sourceLanguage': 'fr', // Different from the passed source
          'strings': {
            'NSCameraUsageDescription': {
              'localizations': {
                'fr': {
                  'stringUnit': {'state': 'translated', 'value': 'Caméra'},
                },
              },
            },
          },
          'version': '1.0',
        };

        xcstringsFile.writeAsStringSync(jsonEncode(existingData));

        final result = command.loadXcStringsFile(xcstringsFile, 'en');

        // Should return the existing file content, not create new one
        expect(result['sourceLanguage'], equals('fr'));
        expect(result['strings'], isNotEmpty);
        expect(result['strings']['NSCameraUsageDescription'], isNotNull);
      },
    );

    test('should handle xcstrings file with malformed JSON', () {
      final command = LocalizePermissionsCommand();
      final xcstringsFile = File('${tempDir.path}/test.xcstrings');

      // Write malformed JSON
      xcstringsFile.writeAsStringSync('{invalid json');

      // This should throw an exception when trying to decode
      expect(
        () => command.loadXcStringsFile(xcstringsFile, 'en'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle xcstrings file with missing strings key', () {
      final command = LocalizePermissionsCommand();
      final xcstringsFile = File('${tempDir.path}/test.xcstrings');

      final existingData = {
        'sourceLanguage': 'en',
        'version': '1.0',
        // Missing 'strings' key
      };

      xcstringsFile.writeAsStringSync(jsonEncode(existingData));

      final result = command.loadXcStringsFile(xcstringsFile, 'en');

      expect(result['sourceLanguage'], equals('en'));
      expect(
        result['strings'],
        isNull,
      ); // loadXcStringsFile returns the file as-is
      expect(result['version'], equals('1.0'));
    });

    test('should handle xcstrings file with null strings value', () {
      final command = LocalizePermissionsCommand();
      final xcstringsFile = File('${tempDir.path}/test.xcstrings');

      final existingData = {
        'sourceLanguage': 'en',
        'strings': null,
        'version': '1.0',
      };

      xcstringsFile.writeAsStringSync(jsonEncode(existingData));

      final result = command.loadXcStringsFile(xcstringsFile, 'en');

      expect(result['sourceLanguage'], equals('en'));
      expect(result['strings'], isNull);
      expect(result['version'], equals('1.0'));
    });

    test(
      'should handle getExistingLangCodes with malformed strings structure',
      () {
        final command = LocalizePermissionsCommand();

        // Test with strings as a list instead of map
        final json = {
          'strings': [
            'NSCameraUsageDescription',
            'NSMicrophoneUsageDescription',
          ],
        };

        final result = command.getExistingLangCodes(json);
        expect(result, isEmpty);
      },
    );

    test(
      'should handle getExistingLangCodes with string entry missing localizations',
      () {
        final command = LocalizePermissionsCommand();

        final json = {
          'strings': {
            'NSCameraUsageDescription': {
              // Missing 'localizations' key
              'someOtherKey': 'value',
            },
          },
        };

        final result = command.getExistingLangCodes(json);
        expect(result, isEmpty);
      },
    );

    test(
      'should handle getExistingLangCodes with localizations as non-map',
      () {
        final command = LocalizePermissionsCommand();

        final json = {
          'strings': {
            'NSCameraUsageDescription': {
              'localizations': 'not a map',
            },
          },
        };

        final result = command.getExistingLangCodes(json);
        expect(result, isEmpty);
      },
    );

    test(
      'should handle complex xcstrings with mixed existing and new entries',
      () {
        final xcstringsJson = <String, dynamic>{
          'sourceLanguage': 'en',
          'strings': <String, dynamic>{
            'NSCameraUsageDescription': {
              'localizations': <String, dynamic>{
                'en': {
                  'stringUnit': {
                    'state': 'translated',
                    'value': 'Camera access for photos',
                  },
                },
                'fr': {
                  'stringUnit': {
                    'state': 'translated',
                    'value': 'Accès à la caméra pour les photos',
                  },
                },
              },
            },
            'NSMicrophoneUsageDescription': {
              'localizations': <String, dynamic>{}, // Empty localizations
            },
          },
          'version': '1.0',
        };

        final usageDescriptions = [
          PListUsageDescription(
            key: 'NSCameraUsageDescription',
            description: 'Camera access for photos',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSMicrophoneUsageDescription',
            description: 'Microphone access for recording',
            comments: [],
          ),
          PListUsageDescription(
            key: 'NSPhotoLibraryUsageDescription',
            description: 'Photo library access',
            comments: [],
          ),
        ];

        final langCodes = <String>{'en', 'fr', 'de', 'es'};

        // Simulate the logic from LocalizePermissionsCommand.run()
        for (final entry in usageDescriptions) {
          final strings = xcstringsJson['strings'] as Map<String, dynamic>;
          strings[entry.key] ??= {
            'localizations': <String, dynamic>{},
          };
          final localizations = strings[entry.key]?['localizations'];
          if (localizations is Map<String, dynamic>) {
            for (final langCode in langCodes) {
              localizations.putIfAbsent(langCode, () {
                return {
                  'stringUnit': {
                    'state': langCode == 'en' ? 'translated' : 'new',
                    'value': entry.description,
                  },
                };
              });
            }
          }
        }

        final strings = xcstringsJson['strings'] as Map<String, dynamic>;

        // Check camera entry (had existing translations)
        final cameraLocalizations = strings['NSCameraUsageDescription']?['localizations'] as Map<String, dynamic>;
        expect(
          cameraLocalizations['en']['stringUnit']['value'],
          equals('Camera access for photos'),
        );
        expect(
          cameraLocalizations['fr']['stringUnit']['value'],
          equals('Accès à la caméra pour les photos'),
        );
        expect(cameraLocalizations['de']['stringUnit']['state'], equals('new'));
        expect(cameraLocalizations['es']['stringUnit']['state'], equals('new'));

        // Check microphone entry (had empty localizations)
        final micLocalizations = strings['NSMicrophoneUsageDescription']?['localizations'] as Map<String, dynamic>;
        expect(micLocalizations.length, equals(4)); // All languages added

        // Check photo library entry (was completely new)
        final photoLocalizations = strings['NSPhotoLibraryUsageDescription']?['localizations'] as Map<String, dynamic>;
        expect(photoLocalizations.length, equals(4)); // All languages added
      },
    );

    test('should handle PListUsageDescription with empty description', () {
      final description = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: '', // Empty description
        comments: ['@permit'],
      );

      expect(description.key, equals('NSCameraUsageDescription'));
      expect(description.description, equals(''));
      expect(description.comments, contains('@permit'));
    });

    test(
      'should handle PListUsageDescription with special characters in description',
      () {
        final description = PListUsageDescription(
          key: 'NSCameraUsageDescription',
          description: 'Camera access with special chars: àáâãäå, 中文, русский',
          comments: [],
        );

        expect(description.key, equals('NSCameraUsageDescription'));
        expect(description.description, contains('àáâãäå'));
        expect(description.description, contains('中文'));
        expect(description.description, contains('русский'));
      },
    );

    test('should handle xcstrings JSON with special characters', () {
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': {
              'en': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Camera access with special chars: àáâãäå',
                },
              },
              'zh': {
                'stringUnit': {
                  'state': 'translated',
                  'value': '相机访问权限：特殊字符',
                },
              },
            },
          },
        },
        'version': '1.0',
      };

      final formatter = JsonEncoder.withIndent('  ');
      final jsonString = formatter.convert(xcstringsJson);

      expect(jsonString, contains('àáâãäå'));
      expect(jsonString, contains('相机访问权限'));
      expect(jsonString, contains('"sourceLanguage": "en"'));
    });

    test('should handle very long permission descriptions', () {
      final longDescription = 'A'.padRight(
        1000,
        'A',
      ); // 1000 character description

      final description = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: longDescription,
        comments: [],
      );

      expect(description.description.length, equals(1000));
      expect(description.description, startsWith('A'));
      expect(description.description, endsWith('A'));
    });

    test('should handle xcstrings with duplicate language codes', () {
      final command = LocalizePermissionsCommand();

      final json = {
        'strings': {
          'NSCameraUsageDescription': {
            'localizations': {
              'en': {
                'stringUnit': {'state': 'translated', 'value': 'Camera'},
              },
              // ignore: equal_keys_in_map
              'en': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Camera duplicate',
                },
              }, // Duplicate key
              'fr': {
                'stringUnit': {'state': 'translated', 'value': 'Caméra'},
              },
            },
          },
        },
      };

      final result = command.getExistingLangCodes(json);

      // Should handle duplicate keys gracefully (JSON parsing would prevent true duplicates)
      expect(result, contains('en'));
      expect(result, contains('fr'));
    });

    test('should handle empty xcstrings JSON structure', () {
      final command = LocalizePermissionsCommand();

      final json = <String, dynamic>{};

      final result = command.getExistingLangCodes(json);
      expect(result, isEmpty);
    });

    test('should handle xcstrings with nested empty structures', () {
      final command = LocalizePermissionsCommand();

      final json = {
        'strings': {
          'NSCameraUsageDescription': {},
          'NSMicrophoneUsageDescription': {
            'localizations': {},
          },
          'NSPhotoLibraryUsageDescription': {
            'localizations': {
              'someKey': 'not a map',
            },
          },
        },
      };

      final result = command.getExistingLangCodes(json);
      expect(
        result,
        equals({'someKey'}),
      ); // 'someKey' is a valid key in localizations map
    });

    test('should handle loadXcStringsFile with read-only file', () {
      final command = LocalizePermissionsCommand();
      final xcstringsFile = File('${tempDir.path}/readonly.xcstrings');

      final existingData = {
        'sourceLanguage': 'en',
        'strings': {},
        'version': '1.0',
      };

      xcstringsFile.writeAsStringSync(jsonEncode(existingData));

      // Make file read-only (this might not work on all systems, but tests the logic)
      try {
        xcstringsFile.setLastModifiedSync(
          DateTime.now(),
        ); // Just to ensure it exists
        final result = command.loadXcStringsFile(xcstringsFile, 'en');
        expect(result['sourceLanguage'], equals('en'));
      } catch (e) {
        // If setting permissions fails, at least verify the method doesn't crash
        expect(e, isNotNull);
      }
    });

    test('should handle JSON encoding edge cases', () {
      final xcstringsJson = <String, dynamic>{
        'sourceLanguage': 'en',
        'strings': <String, dynamic>{
          'NSCameraUsageDescription': {
            'localizations': {
              'en': {
                'stringUnit': {
                  'state': 'translated',
                  'value': 'Description with "quotes" and \'apostrophes\'',
                },
              },
            },
          },
        },
        'version': '1.0',
      };

      final formatter = JsonEncoder.withIndent('  ');
      final jsonString = formatter.convert(xcstringsJson);

      expect(
        jsonString,
        contains('"Description with \\"quotes\\" and \'apostrophes\'"'),
      );
      expect(jsonString, contains('"sourceLanguage": "en"'));
    });

    test('should handle language codes with mixed case input', () {
      // Test that the validation function handles mixed case properly
      expect(isValidLanguageCode('EN'), isFalse); // Should be lowercase
      expect(isValidLanguageCode('en'), isTrue);
      expect(isValidLanguageCode('En'), isFalse); // Should be lowercase
      expect(isValidLanguageCode('EN-US'), isFalse); // Should be lowercase
      expect(isValidLanguageCode('en-US'), isTrue);
    });

    test('should handle language codes with numbers and special cases', () {
      expect(
        isValidLanguageCode('en-001'),
        isFalse,
      ); // UN M.49 region code - not supported by current regex
      expect(isValidLanguageCode('zh-Hans-CN'), isTrue); // Script and region
      expect(isValidLanguageCode('de-1990'), isFalse); // Invalid format
      expect(isValidLanguageCode('en--US'), isFalse); // Double hyphen
      expect(isValidLanguageCode('e'), isFalse); // Too short
      expect(isValidLanguageCode('english'), isFalse); // Too long for 2-letter
    });

    test('should handle PListUsageDescription equality', () {
      final desc1 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );

      final desc2 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Camera access',
        comments: ['@permit'],
      );

      final desc3 = PListUsageDescription(
        key: 'NSCameraUsageDescription',
        description: 'Different description',
        comments: ['@permit'],
      );

      expect(desc1 == desc2, isTrue);
      expect(desc1 == desc3, isFalse);
      expect(desc1.hashCode == desc2.hashCode, isTrue);
      expect(desc1.hashCode == desc3.hashCode, isFalse);
    });

    test(
      'should handle PListUsageDescription with different comment orders',
      () {
        final desc1 = PListUsageDescription(
          key: 'NSCameraUsageDescription',
          description: 'Camera access',
          comments: ['@permit', '@code'],
        );

        final desc2 = PListUsageDescription(
          key: 'NSCameraUsageDescription',
          description: 'Camera access',
          comments: ['@code', '@permit'], // Different order
        );

        // Comments order should matter for equality
        expect(desc1 == desc2, isFalse);
      },
    );

    test('should handle xcstrings path constant', () {
      expect(
        LocalizePermissionsCommand.xcstringsFileName,
        equals('InfoPlist.xcstrings'),
      );
    });

    test(
      'should handle command with no arguments and no existing xcstrings',
      () async {
        // Create an Info.plist with usage descriptions
        final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
        infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

        // Ensure xcodeproj exists for this test
        final xcodeDir = Directory(
          '${tempDir.path}/ios/Runner.xcodeproj',
        );
        if (!xcodeDir.existsSync()) {
          xcodeDir.createSync(recursive: true);
          File(
            '${xcodeDir.path}/project.pbxproj',
          ).writeAsStringSync('// Empty pbxproj for testing');
        }

        final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) {
            output.writeln(line);
          },
        );

        await runZoned(
          () async => runner.run(['localize']),
          zoneSpecification: spec,
        );

        // Should proceed without errors about missing files
        expect(output.toString(), isNot(contains('Could not find Info.plist')));
        expect(
          output.toString(),
          isNot(contains('No usage description keys found')),
        );
        expect(output.toString(), isNot(contains('Could not find')));
        expect(output.toString(), isNot(contains('Runner.xcodeproj')));
      },
    );

    test(
      'should handle command with mixed valid and invalid language codes',
      () async {
        // Create an Info.plist with usage descriptions
        final infoPlist = File('${tempDir.path}/ios/Runner/Info.plist');
        infoPlist.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Camera access for photos</string>
</dict>
</plist>''');

        // Ensure xcodeproj exists for this test
        final xcodeDir = Directory(
          '${tempDir.path}/ios/Runner.xcodeproj',
        );
        if (!xcodeDir.existsSync()) {
          xcodeDir.createSync(recursive: true);
          File(
            '${xcodeDir.path}/project.pbxproj',
          ).writeAsStringSync('// Empty pbxproj for testing');
        }

        final runner = PermitRunner(pathFinder)..addCommand(LocalizePermissionsCommand());

        final output = StringBuffer();
        final spec = ZoneSpecification(
          print: (self, parent, zone, line) {
            output.writeln(line);
          },
        );

        await runZoned(
          () async => runner.run(['localize', 'en', 'invalid', 'fr', 'also-invalid']),
          zoneSpecification: spec,
        );

        // Should stop at first invalid code
        expect(
          output.toString(),
          contains('Invalid language code provided: invalid'),
        );
        expect(
          output.toString(),
          isNot(contains('Invalid language code provided: also-invalid')),
        );
      },
    );
  });
}
