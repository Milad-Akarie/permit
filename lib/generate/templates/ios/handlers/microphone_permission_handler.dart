import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class MicrophonePermissionHandler extends SwiftHandlerSnippet {
  MicrophonePermissionHandler()
    : super(
        entry: IosPermissions.microphone,
        imports: {'AVFoundation'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func checkStatus() -> Int {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
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
    
    func request(result: @escaping FlutterResult) {
        let status = checkStatus()

         if status != 0 {
            result(status)
            return
        }
        
        AVCaptureDevice.requestAccess(for: .audio) { granted in
           DispatchQueue.main.async {
              result(granted ? 1 : self.checkStatus())
          }
       }
    }
}
''';
  }
}
