import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class RemindersPermissionHandler extends SwiftHandlerSnippet {
  RemindersPermissionHandler()
    : super(
        entry: IosPermissions.reminders,
        imports: {'EventKit'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    func checkStatus() -> Int {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        return determinePermissionStatus(status)
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        let eventStore = EKEventStore()
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(EKEventStore.authorizationStatus(for: .reminder)))
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(EKEventStore.authorizationStatus(for: .reminder)))
                }
            }
        }
    }

    private func determinePermissionStatus(_ authorizationStatus: EKAuthorizationStatus) -> Int {
        switch authorizationStatus {
        case .notDetermined:
            return 0 // denied (not requested yet)
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .authorized:
            return 1 // granted
        case .fullAccess:
            return 1 // granted
        case .writeOnly:
            return 0 // reminders do not support write-only; treat as denied
        @unknown default:
            return 0 // denied
        }
    }
}
''';
  }
}
