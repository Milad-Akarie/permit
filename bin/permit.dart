import 'dart:io';
import 'package:permit/xml_editor/xml_editor.dart';
import 'package:xml/xml.dart';

void main(List<String> ags) {
  final xmlFile = File('bin/Info.plist');
  final xmlContent = xmlFile.readAsStringSync();
  final editor = XmlEditor(xmlContent);
  // editor.addManifestTag(
  //   path: 'manifest',
  //   tag: '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />',
  //   comments: ['@permit: Needed for tracking bus location'],
  // );

  editor.addPlistEntry(
    key: 'NSLocationWhenInUseUsageDescription',
    value: 'Needed for tracking bus location',
    keyComments: ['@permit.gen'],
  );

  xmlFile.writeAsString(editor.toXmlString());
}
