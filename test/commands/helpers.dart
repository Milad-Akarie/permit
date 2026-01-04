import 'dart:io';

import 'package:permit/path/path_finder.dart';

class MockPathFinder extends PathFinder {
  @override
  final Directory root;

  MockPathFinder(this.root);

  void createMockManifest({String? content}) {
    File('${root.path}/AndroidManifest.xml')
      ..createSync()
      ..writeAsStringSync(content ?? '<manifest><application></application></manifest>');
  }

  void createMockInfoPlist({String? content}) {
    File('${root.path}/Info.plist')
      ..createSync()
      ..writeAsStringSync(content ?? '<?xml version="1.0"?><plist><dict><key>CFBundle</key></dict></plist>');
  }

  @override
  File? getManifest() {
    // Mock implementation for testing purposes
    final file = File('${root.path}/AndroidManifest.xml');
    return file.existsSync() ? file : null;
  }

  @override
  File? getInfoPlist() {
    // Mock implementation for testing purposes
    final file = File('${root.path}/Info.plist');
    return file.existsSync() ? file : null;
  }
}
