part of 'xml_editor.dart';

/// Android Manifest-specific editor
class ManifestEditor extends XmlEditor {
  ManifestEditor(super.source);

  /// Add a permission to the manifest
  void addPermission({
    required String name,
    List<String>? comments,
    RemoveComment? removeCommentsOnUpdate,
    List<XmlElementInfo> extraTags = const [],
    int? maxSdkVersion,
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
            comments: comments,
            attributes: {'android:name': name, if (maxSdkVersion != null) 'android:maxSdkVersion': '$maxSdkVersion'},
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
    var depth = 0;
    for (var i = range.start; i <= range.end; i++) {
      final event = _events[i];
      if (event is XmlCommentEvent) {
        comments.add(event.value);
        continue;
      } else if (event is XmlStartElementEvent) {
        if (event.name == 'uses-permission') {
          // Only include permissions that are direct children of manifest (depth 0)
          if (depth == 0) {
            String? nameAttrValue;
            for (final attr in event.attributes) {
              if (attr.name == 'android:name') {
                nameAttrValue = attr.value;
              } else if (attr.name == 'tools:node' && attr.value == 'remove') {
                nameAttrValue = null;
                break;
              }
            }
            if (nameAttrValue != null) {
              permissions.add(
                ManifestPermissionEntry(
                  key: nameAttrValue,
                  comments: List.from(comments),
                ),
              );
            }
            comments.clear();
          }
        }
        if (!event.isSelfClosing) {
          depth++;
        }
      } else if (event is XmlEndElementEvent) {
        depth--;
      }
    }

    return permissions;
  }
}
