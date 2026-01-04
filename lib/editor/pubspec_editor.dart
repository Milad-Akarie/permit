import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecEditor {
  final String pubspecContent;
  final YamlEditor _editor;

  PubspecEditor(this.pubspecContent) : _editor = YamlEditor(pubspecContent);

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

  String toYamlString() => _editor.toString();

  bool save(File file) {
    try {
      file.writeAsStringSync(_editor.toString());
      return true;
    } catch (e) {
      return false;
    }
  }
}
