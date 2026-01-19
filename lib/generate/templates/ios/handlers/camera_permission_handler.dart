import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

/// Handler for Camera permission on iOS.
class CameraPermissionHandler extends SwiftHandlerSnippet {
  /// Constructor for [CameraPermissionHandler].
  CameraPermissionHandler()
    : super(
        entry: IosPermissions.camera,
        imports: {'AVFoundation'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func checkStatus() -> Int {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return 1 // granted
        case .denied, .restricted:
            return 4 // permanently denied
        case .notDetermined:
            return 0 // not requested yet
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
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                result(granted ? 1 : self.checkStatus())
            }
        }
    }
}
''';
  }
}
