import 'package:collection/collection.dart';

abstract class XmlEntry {
  final String key;
  final List<String> comments;

  XmlEntry({required this.key, required this.comments});

  bool get generatesCode => comments.any((comment) => comment.contains('@permit:code'));
}

class PListUsageDescription extends XmlEntry {
  PListUsageDescription({
    required super.key,
    required this.description,
    required super.comments,
  });

  final String description;

  // equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PListUsageDescription &&
        other.key == key &&
        other.description == description &&
        const ListEquality().equals(other.comments, comments);
  }

  @override
  int get hashCode => Object.hash(key, description, const ListEquality().hash(comments));

  @override
  String toString() {
    return '(key: $key, description: $description, comments: $comments)';
  }
}

class ManifestPermissionEntry extends XmlEntry {
  ManifestPermissionEntry({
    required super.key,
    required super.comments,
  });

  // equatable override
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManifestPermissionEntry &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          const ListEquality().equals(comments, other.comments);
  @override
  int get hashCode => key.hashCode ^ const ListEquality().hash(comments);
}
