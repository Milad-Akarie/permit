part of 'xml_editor.dart';

/// Android Manifest-specific editor
class ManifestEditor extends XmlEditor {
  ManifestEditor(super.source);

  /// Add a permission to the manifest
  void addPermission({
    required String name,
    List<String>? comments,
    RemoveComment? removeCommentsOnUpdate,
  }) {
    // Remove existing permission if present
    removePermission(
      name: name,
      removeComments: removeCommentsOnUpdate,
    );

    insert(
      XmlInsertElementEdit(
        path: 'manifest',
        tags: [
          XmlElementInfo(
            name: 'uses-permission',
            content: '',
            comments: comments,
            attributes: {'android:name': name},
            isSelfClosing: true,
          ),
        ],
        insertAfter: (tag, _) => tag == 'uses-permission',
      ),
    );
  }

  /// Remove a permission from the manifest by name
  ///
  /// Example:
  /// ```dart
  /// editor.removePermission(
  ///   name: 'android.permission.CAMERA',
  ///   removeComments: (comment) => comment.contains('@marker'),
  /// );
  /// ```
  void removePermission({
    required String name,
    RemoveComment? removeComments,
  }) {
    remove(
      XmlRemoveElementEdit(
        path: 'manifest',
        tag: 'uses-permission',
        attributes: {'android:name': name},
        commentRemover: removeComments,
      ),
    );
  }

  List<ManifestPermissionEntry> getPermissions() {
    final permissions = <ManifestPermissionEntry>[];
    final range = _getElementScope('manifest');
    if (range == null) return permissions;

    final comments = <String>[];
    for (var i = range.start; i <= range.end; i++) {
      final event = _events[i];
      if (event is XmlCommentEvent) {
        comments.add(event.value);
        continue;
      } else if (event is XmlStartElementEvent && event.name == 'uses-permission') {
        final nameAttr = event.attributes.where((attr) => attr.name == 'android:name').firstOrNull;
        if (nameAttr != null) {
          permissions.add(
            ManifestPermissionEntry(
              key: nameAttr.value,
              comments: List.from(comments),
            ),
          );
        }
        comments.clear();
      }
    }

    return permissions;
  }
}
