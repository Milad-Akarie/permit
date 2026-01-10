import 'package:permit/registry/ios_permissions.dart';
import 'package:permit/registry/models.dart';

abstract class SwiftHandlerSnippet {
  final IosPermissionDef entry;
  final Set<String> imports;

  SwiftHandlerSnippet({
    required this.entry,
    this.imports = const {},
  });

  String get key => entry.group;

  String generate();
}

final swiftHandlers = <String, SwiftHandlerSnippet Function()>{
  IosPermissions.camera.group: () => CameraPermissionHandler(),
  IosPermissions.microphone.group: () => MicrophonePermissionHandler(),
};

class CameraPermissionHandler extends SwiftHandlerSnippet {
  CameraPermissionHandler()
    : super(
        entry: IosPermissions.camera,
        imports: {'AVFoundation'},
      );

  @override
  String generate() {
    return '''class CameraPermissionHandler: PermissionHandler {
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
        // If already granted, return immediately
        if checkStatus() == 1 {
            result(1)
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

class MicrophonePermissionHandler extends SwiftHandlerSnippet {
  MicrophonePermissionHandler()
    : super(
        entry: IosPermissions.microphone,
        imports: {'AVFoundation'},
      );

  @override
  String generate() {
    return '''class MicrophonePermissionHandler: PermissionHandler {
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
