part of 'xml_editor.dart';

/// Android Manifest-specific editor.
class ManifestEditor extends XmlEditor {
  /// Default constructor.
  ManifestEditor(super.source);

  /// Adds a permission to the manifest.
  ///
  /// [name] The permission name (e.g., 'android.permission.CAMERA').
  /// [comments] Optional comments to add above the permission.
  /// [removeCommentsOnUpdate] Predicate to determine which existing comments to remove.
  /// [maxSdkVersion] Optional max SDK version for the permission.
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
            attributes: {
              'android:name': name,
              if (maxSdkVersion != null)
                'android:maxSdkVersion': '$maxSdkVersion',
            },
            isSelfClosing: true,
          ),
        ],
        insertAfter: (tag, _) => tag == 'uses-permission',
      ),
    );
  }

  /// Removes a permission from the manifest by [name].
  ///
  /// [removeComments] Optional predicate to remove associated comments.
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

  /// Parses and returns a list of all permissions currently in the manifest.
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
