import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:permit/commands/localize/utils.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:permit/commands/localize/ruby_scripts.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:permit/utils/utils.dart';

class LocalizePermissionsCommand extends PermitCommand {
  @override
  String get name => 'localize';

  @override
  String get description => 'Generate InfoPlist.xcstrings for permission localizations (iOS)';

  static const xcstringsPath = 'InfoPlist.xcstrings';

  @override
  FutureOr<dynamic>? run() async {
    final infoPlist = pathFinder.getInfoPlist();
    if (infoPlist == null) {
      Logger.error('Could not find Info.plist file in the iOS project.');
      return;
    }

    final editor = PListEditor(infoPlist.readAsStringSync());
    final usageDescription = editor.getUsageDescriptions();
    if (usageDescription.isEmpty) {
      Logger.info('No usage description keys found in Info.plist. Nothing to localize.');
      return;
    }

    final xcstringsFile = File(p.join(p.dirname(infoPlist.path), xcstringsPath));
    final projectDir = p.join(p.dirname(p.dirname(infoPlist.path)), 'Runner.xcodeproj');

    if (!Directory(projectDir).existsSync()) {
      Logger.error('Could not find $projectDir file in the iOS project.');
      return;
    }

    final relativeProjectPath = p.relative(projectDir, from: Directory.current.path);
    final relativeXcstringsPath = p.relative(xcstringsFile.path, from: Directory.current.path);

    final (source, knownRegions) = await getKnownRegions(relativeProjectPath);

    final langCodesToUse = <String>{};
    for (final code in [...?argResults?.rest]) {
      if (isValidLanguageCode(code)) {
        langCodesToUse.add(code);
      } else {
        Logger.error('Invalid language code provided: $code');
        return;
      }
    }

    final xcStringsJson = _loadXcStringsFile(xcstringsFile, source);

    if (langCodesToUse.isEmpty) {
      langCodesToUse.addAll(knownRegions);
      langCodesToUse.addAll(_getExistingLangCodes(xcStringsJson));
    }

    // always ensure source language is included
    langCodesToUse.add(source);

    for (final entry in usageDescription) {
      xcStringsJson['strings'][entry.key] ??= {
        'localizations': <String, dynamic>{},
      };
      final localizations = xcStringsJson['strings'][entry.key]?['localizations'];
      if (localizations is Map<String, dynamic>) {
        for (final langCode in langCodesToUse) {
          localizations.putIfAbsent(langCode, () {
            return {
              'stringUnit': {
                'state': langCode == source ? 'translated' : 'new',
                'value': entry.description,
              },
            };
          });
        }
      }
    }

    if (await isXcodeprojInstalled() != true) {
      // prompt to try install
      final installIt = prompt(
        'xcodeproj gem is not installed. try to install it now? [y/N]: ',
        defaultValue: 'y',
      );
      if (installIt.toLowerCase() == 'y') {
        await installXcodeproj();
      } else {
        Logger.error('xcodeproj gem is required to add localization references. Please install it and try again.');
        return;
      }
      return;
    }

    try {
      final formatter = JsonEncoder.withIndent('  ');
      await xcstringsFile.writeAsString(formatter.convert(xcStringsJson));
      await addXcodeReference(
        projectPath: relativeProjectPath,
        xcstringsPath: relativeXcstringsPath,
      );
      Logger.success('Added localization keys for the following languages: (${langCodesToUse.join(', ')})');
      Logger.success('Make sure you add your translations in\n${xcstringsFile.path}');
    } catch (e) {
      Logger.error('Failed to write to ${xcstringsFile.path}: $e');
    }
  }

  Map<String, dynamic> _loadXcStringsFile(File xcstringsFile, String source) {
    return xcstringsFile.existsSync()
        ? jsonDecode(xcstringsFile.readAsStringSync())
        : {
            "sourceLanguage": source,
            'strings': {},
            "version": "1.0",
          };
  }

  Set<String> _getExistingLangCodes(Map<String, dynamic> json) {
    final existingLangCodes = <String>{};
    final strings = json['strings'];
    if (strings is Map<String, dynamic>) {
      for (final key in strings.keys) {
        final localizations = strings[key]?['localizations'];
        if (localizations is Map<String, dynamic>) {
          existingLangCodes.addAll(localizations.keys);
        }
      }
    }
    return existingLangCodes;
  }
}
