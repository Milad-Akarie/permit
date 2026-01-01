import 'dart:io';
import 'package:xml/xml.dart';

void main(List<String> ags) {
  final xmlFile = File('bin/AndroidManifest.xml');
  final xmlContent = xmlFile.readAsStringSync();
  final xmlDoc = XmlDocument.parse(xmlContent);
  print(xmlDoc.toXmlString(pretty: true, indent: '\t'));
}
