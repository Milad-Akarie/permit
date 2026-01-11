import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/generate/templates/template.dart';

class PluginSwiftClassTemp extends Template {
  @override
  String get path => 'ios/Classes/PermitPlugin.swift';

  final List<SwiftHandlerSnippet> handlers;
  final String channelName;

  PluginSwiftClassTemp(this.handlers, {this.channelName = kDefaultChannelName});

  @override
  String generate() {
    final imports = handlers.expand((e) => e.imports).toSet();

    return '''
// GENERATED FILE - DO NOT MODIFY BY HAND
import Flutter
import UIKit
${imports.map((e) => 'import $e').join('\n')}

public class PermitPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "$channelName",
            binaryMessenger: registrar.messenger()
        )
        let instance = PermitPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle open_settings separately (no permission arg needed)
        if call.method == "open_settings" {
            openSettings(result: result)
            return
        }
        
        // For other methods, require permission argument
        guard let args = call.arguments as? [String: Any],
              let permission = args["permission"] as? String else {
            result(FlutterError(
                code: "NO_PERMISSION",
                message: "Permission argument missing",
                details: nil
            ))
            return
        }
        
        guard let handler = PermissionRegistry.shared.handler(for: permission) else {
            result(FlutterError(
                code: "UNKNOWN_PERMISSION",
                message: "No handler for \(permission)",
                details: nil
            ))
            return
        }
        
        switch call.method {
        case "check_permission_status":
            result(handler.checkStatus())
        case "request_permission":
            handler.request(result: result)
        case "check_service_status":
            result(handler.checkServiceStatus())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func openSettings(result: @escaping FlutterResult) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            result(FlutterError(
                code: "INVALID_URL",
                message: "Settings URL is invalid",
                details: nil
            ))
            return
        }
    
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    result(true)
                } else {
                    result(FlutterError(
                        code: "OPEN_FAILED",
                        message: "Failed to open settings",
                        details: nil
                    ))
                }
            }
        } else {
            // Fallback for iOS 9 and earlier (if you need to support it)
            UIApplication.shared.openURL(url)
            result(true)
        }
    }
}

// Base handler protocol
protocol PermissionHandler {
    func checkStatus() -> Int
    func request(result: @escaping FlutterResult)
    func checkServiceStatus() -> Int
}

// Default implementations
extension PermissionHandler {
    func checkServiceStatus() -> Int {
        return 2 // Not applicable
    }
}

// Lazy singleton registry
class PermissionRegistry {
    static let shared = PermissionRegistry()
    
    private var cache: [String: PermissionHandler] = [:]
    
    private init() {}
    
    func handler(for key: String) -> PermissionHandler? {
        // Return cached handler if exists
        if let cached = cache[key] {
            return cached
        }
        
        // Create handler lazily based on key
        let handler: PermissionHandler? = {
            switch key {
            ${handlers.map((e) => 'case "${e.key}":\n                return ${e.className}()').join('\n            ')}
            default:
                return nil
            }
        }()
        
        // Cache it if created
        if let handler = handler {
            cache[key] = handler
        }
        
        return handler
    }
}

// MARK: - Generated Handlers

${handlers.map((e) => e.generate()).join('\n')}
''';
  }
}
