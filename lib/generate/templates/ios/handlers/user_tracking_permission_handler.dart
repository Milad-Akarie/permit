import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class UserTrackingPermissionHandler extends SwiftHandlerSnippet {
  UserTrackingPermissionHandler()
    : super(
        entry: IosPermissions.userTracking,
        imports: {'AppTrackingTransparency'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func determinePermissionStatus(_ status: ATTrackingManager.AuthorizationStatus) -> Int {
        switch status {
        case .notDetermined:
            return 0 // not requested yet
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .authorized:
            return 1 // granted
        @unknown default:
            return 0
        }
    }

    func checkStatus() -> Int {
        if #available(iOS 14, *) {
            return determinePermissionStatus(ATTrackingManager.trackingAuthorizationStatus)
        } else {
            // Prior to iOS 14 tracking permission not required; treat as granted
            return 1
        }
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { authStatus in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(authStatus))
                }
            }
        } else {
            result(1)
        }
    }
}
''';
  }
}
