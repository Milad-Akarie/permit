import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// A simple editor for pubspec.yaml files to manage dependencies.
class PubspecEditor {
  /// The original content of the pubspec.yaml file.
  final String pubspecContent;

  /// The YAML editor instance.
  final YamlEditor _editor;

  /// Creates a [PubspecEditor] with the given [pubspecContent].
  PubspecEditor(this.pubspecContent) : _editor = YamlEditor(pubspecContent);

  /// Checks if the pubspec has a dependency on [packageName].
  bool hasDependency(String packageName) {
    try {
      final dependenciesNode = _editor.parseAt(['dependencies']);
      if (dependenciesNode is YamlMap) {
        return dependenciesNode.containsKey(packageName);
      }
    } catch (e) {
      // Invalid YAML or parsing error
      return false;
    }
    return false;
  }

  /// Adds a path dependency for [packageName] at the given [path].
  ///
  /// Returns `true` if the dependency was added, `false` if it already existed.
  bool addPathDependency(String packageName, String path) {
    try {
      final dependenciesNode = _editor.parseAt(['dependencies']);
      if (dependenciesNode is YamlMap) {
        if (dependenciesNode.containsKey(packageName)) {
          return false;
        }
        _editor.update(['dependencies', packageName], {'path': path});
      }
    } catch (e) {
      // If dependencies section does not exist, create it
      _editor.update(
        ['dependencies'],
        {
          packageName: {'path': path},
        },
      );
    }
    return true;
  }

  /// Removes the dependency on [packageName].
  ///
  /// Returns `true` if the dependency was removed, `false` if it did not exist.
  bool removeDependency(String packageName) {
    try {
      final dependenciesNode = _editor.parseAt(['dependencies']);
      if (dependenciesNode is YamlMap && dependenciesNode.containsKey(packageName)) {
        _editor.remove(['dependencies', packageName]);
        return true;
      }
    } catch (e) {
      // Invalid YAML or parsing error
      return false;
    }
    return false;
  }

  /// Returns the current YAML content as a string.
  String toYamlString() => _editor.toString();

  /// Saves the current YAML content to the given [file].
  /// Returns `true` if the save was successful, `false` otherwise.
  bool save(File file) {
    try {
      file.writeAsStringSync(_editor.toString());
      return true;
    } catch (e) {
      return false;
    }
  }
}
