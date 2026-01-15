import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class SpeechPermissionHandler extends SwiftHandlerSnippet {
  SpeechPermissionHandler()
    : super(
        entry: IosPermissions.speech,
        imports: {'Speech'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func determinePermissionStatus(_ authorizationStatus: SFSpeechRecognizerAuthorizationStatus) -> Int {
        switch authorizationStatus {
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
        return determinePermissionStatus(SFSpeechRecognizer.authorizationStatus())
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                result(self.determinePermissionStatus(authStatus))
            }
        }
    }
}
''';
  }
}
