import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class MediaLibraryPermissionHandler extends SwiftHandlerSnippet {
  MediaLibraryPermissionHandler()
    : super(
        entry: IosPermissions.mediaLibrary,
        imports: {'MediaPlayer'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func checkStatus() -> Int {
        let status = MPMediaLibrary.authorizationStatus()
        return determinePermissionStatus(status)
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                result(self.determinePermissionStatus(status))
            }
        }
    }
    
    private func determinePermissionStatus(_ authorizationStatus: MPMediaLibraryAuthorizationStatus) -> Int {
        switch authorizationStatus {
        case .notDetermined:
            return 0 // denied (not requested yet)
        case .denied:
            return 4 // permanently denied
        case .restricted:
            return 2 // restricted
        case .authorized:
            return 1 // granted
        @unknown default:
            return 0 // denied
        }
    }
}
''';
  }
}
