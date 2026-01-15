import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class AssistantPermissionHandler extends SwiftHandlerSnippet {
  AssistantPermissionHandler()
    : super(
        entry: IosPermissions.assistant,
        imports: {'Intents'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    private func determinePermissionStatus(_ status: INSiriAuthorizationStatus) -> Int {
        switch status {
        case .authorized:
            return 1 // granted
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .notDetermined:
            return 0 // not requested yet
        @unknown default:
            return 0
        }
    }

    func checkStatus() -> Int {
        if #available(iOS 10, *) {
            return determinePermissionStatus(INPreferences.siriAuthorizationStatus())
        } else {
            // Prior to iOS 10 Siri authorization not applicable; treat as granted
            return 1
        }
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        if #available(iOS 10, *) {
            INPreferences.requestSiriAuthorization { authStatus in
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
