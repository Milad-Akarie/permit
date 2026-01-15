import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class SensorsPermissionHandler extends SwiftHandlerSnippet {
  SensorsPermissionHandler()
    : super(
        entry: IosPermissions.sensors,
        imports: {'CoreMotion'},
      );

  @override
  String get className => 'SensorsPermissionHandler';

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func checkStatus() -> Int {
        let status = CMMotionActivityManager.authorizationStatus()
        return determinePermissionStatus(status)
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        let motionManager = CMMotionActivityManager()
        let today = Date()
        motionManager.queryActivityStarting(from: today, to: today, to: OperationQueue.main) { activities, error in
            result(self.determinePermissionStatus(CMMotionActivityManager.authorizationStatus()))
        }
    }

    private func determinePermissionStatus(_ authorizationStatus: CMAuthorizationStatus) -> Int {
        switch authorizationStatus {
        case .notDetermined:
            return 0 // denied (not requested yet)
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .authorized:
            return 1 // granted
        @unknown default:
            return 1 // granted
        }
    }
}
''';
  }
}
