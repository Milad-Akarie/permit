import 'dart:io';
import 'package:permit/xml_editor/xml_editor.dart';

void main(List<String> ags) {
  final xmlFile = File('bin/AndroidManifest.xml');
  final editor = ManifestEditor(xmlFile.readAsStringSync());
  // editor.addManifestTag(
  //   path: 'manifest',
  //   tag: '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />',
  //   comments: ['@permit.gen'],
  // );

  // editor.removePlistEntry(key: 'NSLocationWhenInUseUsageDescription', commentMarkers: ['@permit.gen']);

  // editor.addPlistEntry(
  //   key: 'NSLocationWhenInUseUsageDescription',
  //   value: '<String>Needed for tracking bus location</String>',
  //   keyComments: ['@permit.gen'],
  // );

  // final existingKeys = editor.findTags(path: 'plist.dict', name: 'key');
  // for (final keyTag in existingKeys) {
  //   print(editor.getCommentsOf(keyTag));
  //   if (keyTag.innerText == 'NSLocationWhenInUseUsageDescription') {
  //     print('Found existing key NSLocationWhenInUseUsageDescription, skipping addition.');
  //     return;
  //   }
  // }

  xmlFile.writeAsString(editor.toXmlString());
}
