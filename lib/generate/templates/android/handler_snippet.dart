import 'package:permit/generate/utils.dart';
import 'package:permit/registry/models.dart';

const indent = '    ';

class HandlerSnippet {
  final String key;
  final String requestCode;
  final List<AndroidPermissionDef> permissions;
  final Set<String> imports;
  HandlerSnippet({
    required this.key,
    required this.requestCode,
    required this.permissions,
    this.imports = const {},
  });

  String get className => '${key.toCamelCase().capitalize()}Handler';

  late final permissionsArray = permissions.map((perm) {
    final sinceApiParam = perm.sinceApi != null ? ', sinceApi = ${perm.sinceApi}' : '';
    return 'Permission(${perm.key.replaceFirst('android.permission', 'android.Manifest.permission')}$sinceApiParam)';
  });

  String generate() {
    final buffer = StringBuffer();
    buffer.writeln('class $className : PermissionHandler(');
    buffer.writeln('$indent$requestCode, arrayOf(');

    final permissionsArray = permissions.map((perm) {
      final sinceApiParam = perm.sinceApi != null ? ', sinceApi = ${perm.sinceApi}' : '';
      return 'Permission(${perm.key.replaceFirst('android.permission', 'android.Manifest.permission')}$sinceApiParam)';
    });

    for (final perm in permissionsArray) {
      buffer.writeln('$indent$indent$perm,');
    }
    buffer.writeln('$indent)');
    buffer.writeln(')');
    return buffer.toString();
  }
}

final customHandlers = <String, HandlerSnippet Function(int requestCode)>{
  'system_alert_window': (requestCode) => SystemAlertWindowHandler(requestCode),
};

class SystemAlertWindowHandler extends HandlerSnippet {
  SystemAlertWindowHandler(int requestCode)
    : super(
        key: 'system_alert_window',
        requestCode: '$requestCode',
        permissions: [
          const AndroidPermissionDef(
            'android.permission.SYSTEM_ALERT_WINDOW',
            group: 'system',
            runtime: true,
          ),
        ],
      );

  @override
  String generate() {
    return '''
class $className : PermissionHandler(
    $requestCode,
    arrayOf(${permissionsArray.join(',\n$indent$indent')})
) {
    override fun getStatus(context: Context): Int {
        return if (Settings.canDrawOverlays(context)) 1 else 0
    }

    override fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (Settings.canDrawOverlays(activity)) {
            result.success(1)
            return
        }

        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
            data = Uri.parse("package:\${activity.packageName}")
        }
        activity.startActivityForResult(intent, requestCode)
        pendingResult = result
    }
}
''';
  }
}
