import 'dart:io';

import 'package:permit/generate/templates/template.dart';
import 'package:permit/utils/logger.dart';

class Generator {
  final List<Template> templates;
  final Directory rootDir;
  Generator({required this.rootDir, required this.templates});

  void generate() {
    for (var template in templates) {
      try {
        final file = File('${rootDir.path}/${template.path}');
        file.createSync(recursive: true);
        file.writeAsStringSync(template.generate());
      } catch (e) {
        Logger.error('Failed to generate ${template.path}: $e');
      }
    }
  }
}
