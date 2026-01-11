import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/registry/ios_permissions.dart';

class BluetoothPermissionHandler extends SwiftHandlerSnippet {
  BluetoothPermissionHandler()
    : super(
        entry: IosPermissions.bluetooth,
        imports: {'CoreBluetooth'},
      );

  @override
  String generate() {
    return '''class $className: NSObject, PermissionHandler, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var requestResult: FlutterResult?
    
    func checkStatus() -> Int {
        if #available(iOS 13.1, *) {
            switch CBCentralManager.authorization {
            case .notDetermined:
                return 0 // not requested yet
            case .restricted:
                return 3 // restricted
            case .denied:
                return 4 // permanently denied
            case .allowedAlways:
                return 1 // granted
            @unknown default:
                return 0
            }
        } else if #available(iOS 13.0, *) {
            // iOS 13.0: Can't check without triggering permission
            return 0
        } else {
            // Pre-iOS 13: No Bluetooth permission required
            return 1
        }
    }
    
    func request(result: @escaping FlutterResult) {
        // If already granted or permanently denied, return immediately
        let status = checkStatus()
        if status != 0 {
            result(status)
            return
        }
        
        // Initialize manager to trigger permission request
        requestResult = result
        let options = [CBCentralManagerOptionShowPowerAlertKey: false]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    func checkServiceStatus() -> Int {
        // Create manager if needed, but only if permission already determined
        if centralManager == nil {
            if #available(iOS 13.1, *) {
                // Only create manager if permission not undetermined
                if CBCentralManager.authorization == .notDetermined {
                    // Can't check service without triggering permission
                    return 0
                }
            }
            
            // Permission determined or pre-iOS 13 - safe to create manager
            let options = [CBCentralManagerOptionShowPowerAlertKey: false]
            centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        }
        
        guard let manager = centralManager else {
            return 0
        }
        
        // Return enabled only if powered on, disabled for all other states
        switch manager.state {
        case .poweredOn:
            return 1 // enabled
        case .poweredOff:
            return 0 // disabled
        case .unsupported:
            return 2 // not applicable
        case .unauthorized, .resetting, .unknown:
            return 0 // disabled (can't determine actual state)
        @unknown default:
            return 0
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let result = requestResult else { return }
        result(checkStatus())
        requestResult = nil
    }
}
''';
  }
}
