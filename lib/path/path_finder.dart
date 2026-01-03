import 'dart:io';

class PathFinder {
  /// Attempts to locate the AndroidManifest.xml actually used by the app.
  /// Returns null if it cannot be determined reliably.
  static File? getManifest(Directory projectRoot) {
    final androidDir = Directory('${projectRoot.path}/android/app');
    if (!androidDir.existsSync()) return null;

    // 1. Check conventional location first (most common case)
    final conventional = File('${androidDir.path}/src/main/AndroidManifest.xml');
    if (conventional.existsSync() && _isMainManifest(conventional)) {
      return conventional;
    }

    // 2. Honor custom sourceSets in build.gradle(.kts)
    final gradleFiles = [
      File('${androidDir.path}/build.gradle'),
      File('${androidDir.path}/build.gradle.kts'),
    ].where((f) => f.existsSync());

    for (final gradle in gradleFiles) {
      final content = gradle.readAsStringSync();

      final match = RegExp(
        r'manifest\.srcFile\s*[=(]\s*["'
        "'"
        r'](.+AndroidManifest\.xml)["'
        "'"
        r']',
      ).firstMatch(content);
      if (match != null) {
        final customPath = match.group(1)!;

        // Try relative to android/app first
        var file = File('${androidDir.path}/$customPath');
        if (file.existsSync() && _isMainManifest(file)) return file;

        // Try relative to android root
        file = File('${projectRoot.path}/android/$customPath');
        if (file.existsSync() && _isMainManifest(file)) return file;

        // Try as absolute path
        file = File(customPath);
        if (file.existsSync() && _isMainManifest(file)) return file;
      }
    }

    // Anything beyond this requires Gradle execution
    return null;
  }

  /// Validates that the manifest file is a main manifest (not a variant-specific one).
  static bool _isMainManifest(File manifest) {
    try {
      final content = manifest.readAsStringSync();
      // Main manifest must have <application> tag
      return content.contains('<application');
    } catch (_) {
      return false;
    }
  }

  /// Attempts to locate the Info.plist used by iOS builds.
  /// Returns null if it cannot be determined reliably.
  static File? getInfoPlist(Directory projectRoot) {
    final iosDir = Directory('${projectRoot.path}/ios');
    if (!iosDir.existsSync()) return null;

    // 1. Check conventional location first (most common case)
    final conventional = File('${iosDir.path}/Runner/Info.plist');
    if (conventional.existsSync() && _isValidPlist(conventional)) {
      return conventional;
    }

    // 2. Parse project.pbxproj for custom INFOPLIST_FILE locations
    final pbxproj = File(
      '${iosDir.path}/Runner.xcodeproj/project.pbxproj',
    );
    if (!pbxproj.existsSync()) return null;

    final content = pbxproj.readAsStringSync();

    // Extract INFOPLIST_FILE entries
    final matches = RegExp(
      r'INFOPLIST_FILE\s*=\s*([^;]+);',
    ).allMatches(content);

    for (final match in matches) {
      var value = match.group(1)!.trim();

      // Skip variable-based paths (cannot be resolved statically)
      if (value.contains(r'$')) continue;

      value = value.replaceAll('"', '');
      final file = File('${iosDir.path}/$value');
      if (file.existsSync() && _isValidPlist(file)) return file;
    }

    return null;
  }

  /// Validates that the file is a valid Info.plist.
  static bool _isValidPlist(File plist) {
    try {
      final content = plist.readAsStringSync();
      // Valid plist must have proper XML structure and CFBundleIdentifier
      return content.contains('<?xml') && content.contains('<plist') && content.contains('CFBundle');
    } catch (_) {
      return false;
    }
  }
}
