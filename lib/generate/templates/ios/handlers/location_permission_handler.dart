import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class LocationPermissionHandler extends SwiftHandlerSnippet {
  LocationPermissionHandler({required super.entry}) : super(imports: {'CoreLocation'});

  @override
  String generate() {
    final forAlways = entry.group == IosPermissions.locationAlways.group;
    final requestMethod = forAlways ? 'requestAlwaysAuthorization()' : 'requestWhenInUseAuthorization()';

    final statusMapping = forAlways
        ? '''switch status {
        case .notDetermined:
            return 0 // not requested yet
        case .restricted:
            return 3 // restricted (system-level)
        case .denied:
            return 4 // denied
        case .authorizedWhenInUse:
            return 4 // denied (Always not granted)
        case .authorizedAlways:
            return 1 // granted always
        @unknown default:
            return 0
    }'''
        : '''switch status {
        case .notDetermined:
            return 0 // not requested yet
        case .restricted:
            return 3 // restricted
        case .denied:
            return 4 // denied
        case .authorizedWhenInUse, .authorizedAlways:
            return 1 // granted
        @unknown default:
            return 0
    }''';

    final prerequisiteCheck = forAlways
        ? '''
        // Must have whenInUse permission before requesting always
        let currentStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            currentStatus = locationManager?.authorizationStatus ?? .notDetermined
        } else {
            currentStatus = CLLocationManager.authorizationStatus()
        }

        if currentStatus == .notDetermined {
            result(FlutterError(
                code: "MISSING_WHENINUSE_PERMISSION",
                message: "Must have 'When in use' permission before requesting 'Always' permission",
                details: nil
            ))
            return
        }

        if currentStatus == .authorizedWhenInUse {
            // Already have whenInUse, request always
            requestResult = result
            locationManager?.$requestMethod
        } else {
            // Already determined (restricted, denied, or already always)
            result(checkStatus())
        }'''
        : '''requestResult = result
        locationManager?.$requestMethod''';

    return '''class $className: NSObject, PermissionHandler, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var requestResult: FlutterResult?
    private var previousStatusWasNotDetermined = false

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }

    func checkStatus() -> Int {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager?.authorizationStatus ?? .notDetermined
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        return determineStatus(status)
    }

    func request(result: @escaping FlutterResult) {
        let status = checkStatus()

        if ${forAlways ? 'status == 0' : 'status == 0 || status == 4'} {
            result(status)
            return
        }

        $prerequisiteCheck
    }

    func checkServiceStatus() -> Int {
        return CLLocationManager.locationServicesEnabled() ? 1 : 0
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        handleAuthorizationChange(status)
    }

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(manager.authorizationStatus)
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        guard let result = requestResult else { return }

        // Handle notDetermined showing up during dialog
        if status == .notDetermined {
            if previousStatusWasNotDetermined {
                // Second notDetermined means dialog was dismissed
                result(0)
                requestResult = nil
            }
            previousStatusWasNotDetermined = true
            return
        }
        previousStatusWasNotDetermined = false

        result(determineStatus(status))
        requestResult = nil
    }

    private func determineStatus(_ status: CLAuthorizationStatus) -> Int {
        $statusMapping
    }
}
''';
  }
}
