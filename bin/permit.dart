import 'dart:io';
import 'editor.dart';

void main(List<String> ags) {
  final xmlFile = File('bin/AndroidManifest.xml');
  final xmlContent = xmlFile.readAsStringSync();
  final editor = SurgicalXmlEditor(xmlContent);
  editor.removeManifestTag(
    path: 'manifest.uses-permission',
    comments: ['@permit'],
  );

  xmlFile.writeAsString(editor.toXmlString());
}
