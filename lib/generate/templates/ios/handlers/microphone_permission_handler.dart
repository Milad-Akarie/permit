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
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return 1 // granted
        case .denied:
            return 4 // permanently denied
        case .undetermined:
            return 0 // not requested yet
        @unknown default:
            return 0
        }
    } 
    
    func request(result: @escaping FlutterResult) {
        // If already granted, return immediately
        if checkStatus() == 1 {
            result(1)
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                result(granted ? 1 : self.checkStatus())
            }
        }
    }
}
''';
  }
}
