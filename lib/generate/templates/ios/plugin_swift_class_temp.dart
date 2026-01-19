// ignore_for_file: unnecessary_string_escapes

import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/ios/handlers/swift_handler_snippet.dart';
import 'package:permit/generate/templates/template.dart';

/// Template for generating the Swift class for the iOS plugin.
///
/// it implements the FlutterPlugin protocol and handles method calls.
/// Uses the provided [handlers] to generate the necessary code for each permission handler.
class PluginSwiftClassTemp extends Template {
  @override
  String get path => 'ios/Classes/PermitPlugin.swift';

  /// The list of permission handler snippets to include.
  final List<SwiftHandlerSnippet> handlers;

  /// The method channel name to use.
  final String channelName;

  /// Default constructor for [PluginSwiftClassTemp].
  PluginSwiftClassTemp(this.handlers, {this.channelName = kDefaultChannelName});

  @override
  String generate() {
    final imports = handlers.expand((e) => e.imports).toSet();
    final uniqueHandlers = {
      for (var handler in handlers) handler.className: handler,
    }.values;

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
    
        if call.method == "open_settings" {
            openSettings(result: result)
            return
        }
        
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
            handler.checkServiceStatus(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func openSettings(result: @escaping FlutterResult) {
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(FlutterError(code: "INVALID_URL", message: "Settings URL is invalid", details: nil))
          return
      }
      UIApplication.shared.open(url, options: [:]) { success in
          result(success ? true : FlutterError(code: "OPEN_FAILED", message: "Failed to open settings", details: nil))
      }
}
}

// Base handler protocol
protocol PermissionHandler {
    func checkStatus() -> Int
    func request(result: @escaping FlutterResult)
    func checkServiceStatus(result: @escaping FlutterResult)
}

// Default implementations
extension PermissionHandler {
    func checkServiceStatus(result: @escaping FlutterResult){
        result(2) // Not applicable
    }
}

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
            ${handlers.map((e) => 'case "${e.key}":\n                return ${e.constructor}').join('\n            ')}
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

${uniqueHandlers.map((e) => e.generate()).join('\n')}
''';
  }
}
