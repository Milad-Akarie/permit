import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:permit/commands/localize/ruby_scripts.dart';
import 'package:permit/commands/localize/utils.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:permit/editor/xml_editor.dart';
import 'package:permit/utils/logger.dart';
import 'package:permit/utils/utils.dart';

/// Command to generate iOS localization strings file (InfoPlist.xcstrings).
///
/// Usage: `permit localize [language_codes...]`
///
/// it does not remove existing entries, only adds missing ones.
/// even if localizable keys are removed from Info.plist, they will remain
/// in InfoPlist.xcstrings until manually removed.
///
/// If no language codes are provided, all known regions from the Xcode project
/// and existing languages in the InfoPlist.xcstrings file will be used.
///
/// Example:
/// ```
/// permit localize en ar it
/// ```
class LocalizePermissionsCommand extends PermitCommand {
  /// Default constructor.
  LocalizePermissionsCommand();

  @override
  String get name => 'localize';

  @override
  String get description =>
      'Generate InfoPlist.xcstrings for permission localizations (iOS)';

  /// Default file name for the xcstrings file.
  static const xcstringsFileName = 'InfoPlist.xcstrings';

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
      Logger.info(
        'No usage description keys found in Info.plist. Nothing to localize.',
      );
      return;
    }

    final xcstringsFile = File(
      p.join(p.dirname(infoPlist.path), xcstringsFileName),
    );
    final projectDir = p.join(
      p.dirname(p.dirname(infoPlist.path)),
      'Runner.xcodeproj',
    );

    if (!Directory(projectDir).existsSync()) {
      Logger.error('Could not find $projectDir file in the iOS project.');
      return;
    }

    final relativeProjectPath = p.relative(
      projectDir,
      from: Directory.current.path,
    );
    final relativeXcstringsPath = p.relative(
      xcstringsFile.path,
      from: Directory.current.path,
    );

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

    final xcStringsJson = loadXcStringsFile(xcstringsFile, source);

    if (langCodesToUse.isEmpty) {
      langCodesToUse.addAll(knownRegions);
      langCodesToUse.addAll(getExistingLangCodes(xcStringsJson));
    }

    // always ensure source language is included
    langCodesToUse.add(source);

    for (final entry in usageDescription) {
      xcStringsJson['strings'][entry.key] ??= {
        'localizations': <String, dynamic>{},
      };
      final localizations =
          xcStringsJson['strings'][entry.key]?['localizations'];
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
        Logger.error(
          'xcodeproj gem is required to add localization references. Please install it and try again.',
        );
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
      Logger.success(
        'Added localization keys for the following languages: (${langCodesToUse.join(', ')})',
      );
      Logger.success(
        'Make sure you add your translations in\n${xcstringsFile.path}',
      );
    } catch (e) {
      Logger.error('Failed to write to ${xcstringsFile.path}: $e');
    }
  }

  /// Loads the existing xcstrings file or creates a new structure if it doesn't exist.
  Map<String, dynamic> loadXcStringsFile(File xcstringsFile, String source) {
    return xcstringsFile.existsSync()
        ? jsonDecode(xcstringsFile.readAsStringSync())
        : {
            "sourceLanguage": source,
            'strings': {},
            "version": "1.0",
          };
  }

  /// Extracts existing language codes from the xcstrings JSON structure.
  Set<String> getExistingLangCodes(Map<String, dynamic> json) {
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
