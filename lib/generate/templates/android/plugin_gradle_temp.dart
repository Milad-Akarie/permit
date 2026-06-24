import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the `build.gradle.kts` for a plugin package.
///
/// Targets the **Android Gradle Plugin 9.x** DSL:
///  * Kotlin is built-in (`android.builtInKotlin = true` by default in AGP 9),
///    so the `org.jetbrains.kotlin.android` plugin is no longer applied.
///  * `kotlinOptions {}` is removed in favour of the `kotlin.compilerOptions`
///    block.
///  * AGP 9 requires JDK 17 to *run* Gradle; bytecode is still emitted for
///    Java 17 here to keep `compileOptions`, `kotlin.compilerOptions` and the
///    consuming app's toolchain aligned.
class PluginGradleTemp extends Template {
  /// The Android package name for the plugin.
  final String androidPackageName;

  /// The compile SDK version.
  final int compileSdk;

  /// The minimum SDK version.
  final int minSdk;

  /// Constructor for [PluginGradleTemp].
  PluginGradleTemp({
    this.androidPackageName = kAndroidPackageName,
    this.compileSdk = 36,
    this.minSdk = 21,
  });

  @override
  String get path => 'android/build.gradle.kts';

  @override
  String generate() {
    return '''
// ---- GENERATED CODE - DO NOT MODIFY BY HAND ----
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    // Kotlin is built-in with AGP 9 — no `org.jetbrains.kotlin.android` here.
}

android {
    namespace = "$androidPackageName"
    compileSdk = $compileSdk

    defaultConfig {
        minSdk = $minSdk
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
''';
  }
}
