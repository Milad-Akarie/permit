import 'dart:io';

import 'package:permit/path/path_finder.dart';

class MockPathFinder extends PathFinder {
  @override
  final Directory root;

  MockPathFinder(this.root);

  void createMockManifest({String? content}) {
    File('${root.path}/AndroidManifest.xml')
      ..createSync()
      ..writeAsStringSync(
        content ?? '<manifest><application></application></manifest>',
      );
  }

  void createMockInfoPlist({String? content}) {
    final iosRunner = Directory('${root.path}/ios/Runner')
      ..createSync(recursive: true);
    File('${iosRunner.path}/Info.plist')
      ..createSync()
      ..writeAsStringSync(
        content ??
            '<?xml version="1.0"?><plist><dict><key>CFBundle</key></dict></plist>',
      );
  }

  void createMockPubspec({String? content}) {
    File('${root.path}/pubspec.yaml')
      ..createSync()
      ..writeAsStringSync(
        content ??
            'name: mock_project\ndependencies:\n  flutter:\n    sdk: flutter',
      );
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
    final file = File('${root.path}/ios/Runner/Info.plist');
    return file.existsSync() ? file : null;
  }

  @override
  File? getPubspec() {
    final file = File('${root.path}/pubspec.yaml');
    return file.existsSync() ? file : null;
  }
}
