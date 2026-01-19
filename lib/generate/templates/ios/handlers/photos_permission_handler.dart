import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

/// Handler for Photos permission on iOS.
class PhotosPermissionHandler extends SwiftHandlerSnippet {
  /// Whether the permission is for adding only.
  final bool addOnly;

  /// Constructor for [PhotosPermissionHandler].
  PhotosPermissionHandler({this.addOnly = false})
    : super(
        entry: addOnly ? IosPermissions.photoLibraryAdd : IosPermissions.photoLibrary,
        imports: {'Photos'},
      );

  @override
  String get className => 'PhotosPermissionHandler';

  @override
  String get constructor {
    return '$className(addOnly: $addOnly)';
  }

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    private let addOnly: Bool

    init(addOnly: Bool) {
        self.addOnly = addOnly
    }

    func checkStatus() -> Int {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            let accessLevel: PHAccessLevel = addOnly ? .addOnly : .readWrite
            status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }

        return determinePermissionStatus(status)
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        if #available(iOS 14, *) {
            let accessLevel: PHAccessLevel = addOnly ? .addOnly : .readWrite
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { authorizationStatus in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(authorizationStatus))
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { authorizationStatus in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(authorizationStatus))
                }
            }
        }
    }
    
    private func determinePermissionStatus(_ authorizationStatus: PHAuthorizationStatus) -> Int {
        switch authorizationStatus {
        case .notDetermined:
            return 0 // denied (not requested yet)
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .authorized:
            return 1 // granted
        case .limited:
            return 3 // limited
        @unknown default:
            return 0 // denied
        }
    }
}
''';
  }
}
