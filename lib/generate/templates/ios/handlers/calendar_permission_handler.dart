import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class CalendarPermissionHandler extends SwiftHandlerSnippet {
  final bool writeOnly;

  CalendarPermissionHandler({this.writeOnly = false})
    : super(
        entry: writeOnly ? IosPermissions.calendarsWriteOnly : IosPermissions.calendars,
        imports: {'EventKit'},
      );

  @override
  String get className => 'CalendarPermissionHandler';

  @override
  String get constructor {
    return '$className(writeOnly: $writeOnly)';
  }

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    private let writeOnly: Bool

    init(writeOnly: Bool) {
        self.writeOnly = writeOnly
    }

    func checkStatus() -> Int {
        let status = EKEventStore.authorizationStatus(for: .event)
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
            if writeOnly {
                eventStore.requestWriteOnlyAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        result(self.determinePermissionStatus(EKEventStore.authorizationStatus(for: .event)))
                    }
                }
            } else {
                eventStore.requestFullAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        result(self.determinePermissionStatus(EKEventStore.authorizationStatus(for: .event)))
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    result(self.determinePermissionStatus(EKEventStore.authorizationStatus(for: .event)))
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
        case .writeOnly:
            return writeOnly ? 1 : 0 // granted if writeOnly, else denied
        case .fullAccess:
            return 1 // granted
        @unknown default:
            return 0 // denied
        }
    }
}
''';
  }
}
