import 'package:collection/collection.dart';

/// Base class for XML entries (permissions or usage descriptions).
abstract class XmlEntry {
  /// The key/name of the entry.
  final String key;

  /// Comments associated with the entry.
  final List<String> comments;

  /// Default constructor.
  XmlEntry({required this.key, required this.comments});

  /// Whether this entry is associated with generated code.
  bool get generatesCode =>
      comments.any((comment) => comment.contains('@permit:code'));

  /// Whether this entry is marked as legacy.
  bool get isLegacy =>
      comments.any((comment) => comment.contains('@permit:legacy'));
}

/// Represents a usage description in Info.plist.
class PListUsageDescription extends XmlEntry {
  /// Default constructor.
  PListUsageDescription({
    required super.key,
    required this.description,
    required super.comments,
  });

  /// The usage description text.
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
  int get hashCode =>
      Object.hash(key, description, const ListEquality().hash(comments));

  @override
  String toString() {
    return '(key: $key, description: $description, comments: $comments)';
  }
}

/// Represents a permission entry in AndroidManifest.xml.
class ManifestPermissionEntry extends XmlEntry {
  /// Default constructor.
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
