import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

/// Handler for Contacts permission on iOS.
class ContactsPermissionHandler extends SwiftHandlerSnippet {
  /// Constructor for [ContactsPermissionHandler].
  ContactsPermissionHandler()
    : super(
        entry: IosPermissions.contacts,
        imports: {'Contacts'},
      );

  @override
  String generate() {
    return '''class $className: PermissionHandler {
    
      func checkStatus() -> Int {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            return 0 // denied (not requested yet)
        case .authorized:
            return 1 // granted
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // permanently denied
        case .limited:
            if #available(iOS 18.0, *) {
                return 3 // limited
            } else {
                return 1 // treat as granted on older iOS
            }
        @unknown default:
            return 0 // denied
        }
}

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }

        CNContactStore().requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
               result(granted ? 1 : self.checkStatus())
            }
        }
    }
}
''';
  }
}
