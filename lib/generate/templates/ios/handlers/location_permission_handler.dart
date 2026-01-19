import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

/// Handler for Location permission on iOS.
class LocationPermissionHandler extends SwiftHandlerSnippet {
  /// Whether to request 'Always' permission.
  final bool forAlways;

  /// Constructor for [LocationPermissionHandler].
  LocationPermissionHandler({this.forAlways = false})
    : super(
        entry: forAlways ? IosPermissions.locationAlways : IosPermissions.locationWhenInUse,
        imports: {'CoreLocation'},
      );

  @override
  String get className => 'LocationHandler';

  @override
  String get constructor {
    final requestType = forAlways ? 'requestAlwaysAuthorization()' : 'requestWhenInUseAuthorization()';
    return '''LocationHandler(forAlways: $forAlways) { manager in
                    manager.$requestType
                }''';
  }

  @override
  String generate() {
    return '''class $className: NSObject, PermissionHandler, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var requestResult: FlutterResult?
    private let requestAuthorization: (CLLocationManager) -> Void
    private let forAlways: Bool
    private let storageKey: String

    init(forAlways: Bool, requestAuth: @escaping (CLLocationManager) -> Void) {
        self.forAlways = forAlways
        self.requestAuthorization = requestAuth
        self.storageKey = "permit_\\(forAlways ? "location_always" : "location")_requested"
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
        let currentStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            currentStatus = locationManager?.authorizationStatus ?? .notDetermined
        } else {
            currentStatus = CLLocationManager.authorizationStatus()
        }

        if forAlways {
            // Always permission logic
            if currentStatus == .authorizedAlways {
                result(1)
                return
            }

            if currentStatus == .notDetermined {
                result(FlutterError(
                    code: "MISSING_WHENINUSE_PERMISSION",
                    message: "Must have 'When in use' permission before requesting 'Always' permission",
                    details: nil
                ))
                return
            }

            if currentStatus == .denied || currentStatus == .restricted {
                result(determineStatus(currentStatus))
                return
            }

            // currentStatus == .authorizedWhenInUse
            let alreadyRequested = UserDefaults.standard.bool(forKey: storageKey)
            if alreadyRequested {
                result(0)
                return
            }

            UserDefaults.standard.set(true, forKey: storageKey)
            requestResult = result
            guard let manager = locationManager else { return }
            requestAuthorization(manager)
        } else {
            // When in use permission logic
            if currentStatus != .notDetermined {
                result(determineStatus(currentStatus))
                return
            }

            UserDefaults.standard.set(true, forKey: storageKey)
            requestResult = result
            guard let manager = locationManager else { return }
            requestAuthorization(manager)
        }
    }

    func checkServiceStatus(result: @escaping FlutterResult){
         result(CLLocationManager.locationServicesEnabled() ? 1 : 0)
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

        if status != .notDetermined {
            result(determineStatus(status))
            requestResult = nil
            return
        }

        let alreadyRequested = UserDefaults.standard.bool(forKey: storageKey)
        if alreadyRequested {
            result(0)
            requestResult = nil
        }
    }

    private func determineStatus(_ status: CLAuthorizationStatus) -> Int {
        switch status {
        case .notDetermined:
            return 0 // not requested / not granted yet
        case .restricted:
            return 2 // restricted
        case .denied:
            return 4 // denied (cannot prompt again)
        case .authorizedWhenInUse:
            return forAlways ? 0 : 1 // not granted always yet (can still ask) : granted
        case .authorizedAlways:
            return 1 // granted
        @unknown default:
            return 0
        }
    }
}
''';
  }
}
