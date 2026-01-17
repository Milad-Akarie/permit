import 'package:collection/collection.dart';
import 'package:permit/generate/templates/android/handlers/kotlin_handler_snippet.dart';
import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';
import 'package:permit/registry/models.dart';

final _serviceImports = <AssociatedService, Set<String>>{
  AssociatedService.location: {'android.location.LocationManager'},
  AssociatedService.bluetooth: {
    'android.bluetooth.BluetoothAdapter',
    'android.bluetooth.BluetoothManager',
  },
  AssociatedService.phone: {
    'android.content.Context.BLUETOOTH_SERVICE',
    'android.telephony.TelephonyManager',
  },
};

class PluginKotlinClassTemp extends Template {
  final String packageName;
  final String channelName;
  final List<KotlinHandlerSnippet> handlers;

  PluginKotlinClassTemp({
    this.packageName = kAndroidPackageName,
    this.channelName = kDefaultChannelName,
    required this.handlers,
  });

  @override
  String get path => 'android/src/main/kotlin/${packageName.replaceAll('.', '/')}/PermitPlugin.kt';

  late final services = handlers.map((e) => e.service).nonNulls.where((e) => e.isAndroidSupported).toSet();

  @override
  String generate() {
    final serviceImports = services.expand((e) => _serviceImports[e] ?? []);
    final handlersImports = handlers.expand((e) => e.imports ?? {}).where((e) => e.isNotEmpty);
    final allImports = {...serviceImports, ...handlersImports};

    return '''
// ---- GENERATED CODE - DO NOT MODIFY BY HAND ----
package $packageName

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.edit${allImports.map((e) => '\nimport $e').join()}
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class PermitPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "$channelName")
        channel.setMethodCallHandler(this)
    }


    private fun getHandler(call: MethodCall, result: MethodChannel.Result): PermissionHandler? {
        val permission = call.argument<String>("permission")
        return if (permission == null) {
            result.error("NO_PERMISSION", "Permission argument is missing", null)
            null
        } else {
            PermissionRegistry.getHandler(permission)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val act = activity ?: run { result.error("NO_ACTIVITY", "Activity is null", null); return }
        if(call.method == "open_settings") {
            openSettings(act, result)
            return
        }
        val handler = getHandler(call, result) ?: return
        
        when (call.method) {
            "check_permission_status" -> handler.handleCheck(act, result)
            "request_permission" -> handler.handleRequest(act, result)
            "check_service_status" -> handler.handleServiceStatus(act, result)
            "should_show_rationale" -> handler.handleShouldShowRationale(act, result)
            else -> result.notImplemented()
        }
    }

    private fun openSettings(
        act: Activity,
        result: MethodChannel.Result
    ) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", act.packageName, null)
        }
        if (intent.resolveActivity(act.packageManager) != null) {
            try {
                act.startActivity(intent)
                result.success(null)
            } catch (e: Exception) {
                result.error("ACTIVITY_START_FAILED", "Failed to open settings: \${e.message}", null)
            }
        } else {
            result.error("NO_ACTIVITY_FOUND", "No activity found to handle the intent", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ): Boolean {
        return PermissionRegistry.handlerByCode(requestCode)?.let {
            activity?.let { act -> it.handleResult(act, grantResults) }
            true
        } ?: false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return PermissionRegistry.handlerByCode(requestCode)?.let {
            activity?.let { act -> it.handleOnActivityResult(act) }
            true
        } ?: false
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


}

// Permission data class
data class Permission(val name: String, val sinceSDK: Int? = null, val untilSDK: Int? = null)

// Base PermissionHandler class
abstract class PermissionHandler(val requestCode: Int, permissions: Array<Permission>) {
     val prefs = "permit_plugin_prefs"
     var pendingResult: MethodChannel.Result? = null

    val applicablePermissions: Array<String> = permissions
        .filter { permission ->
            val meetsMinVersion = permission.sinceSDK?.let { api -> Build.VERSION.SDK_INT >= api } ?: true
            val meetsMaxVersion = permission.untilSDK?.let { api -> Build.VERSION.SDK_INT <= api } ?: true
            meetsMinVersion && meetsMaxVersion
        }
        .map { it.name }
        .toTypedArray()


    private fun wasAsked(context: Context): Boolean =
         context.getSharedPreferences(prefs, Context.MODE_PRIVATE)
            .getBoolean("perm_asked_\${applicablePermissions.joinToString("-")}", false)

    private fun markAsked(context: Context) {
        context.getSharedPreferences(prefs, Context.MODE_PRIVATE)
            .edit {
                putBoolean("perm_asked_\${applicablePermissions.joinToString("-")}", true)
            }
    }


   open fun getStatus(activity: Activity): Int {
        applicablePermissions.ifEmpty { return 1 } // granted if no permissions to check
        val allGranted = applicablePermissions.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return 1 // granted

       return when {
           !wasAsked(activity) -> 0             // first request
           shouldShowRationale(activity) -> 0   // denied, can ask again
           else -> 4                            // permanently denied
       }
    }

    fun shouldShowRationale(activity: Activity): Boolean {
        if ( applicablePermissions.isEmpty()) return false
        return applicablePermissions.any {
            ActivityCompat.shouldShowRequestPermissionRationale(activity, it)
        }
    }

    fun handleShouldShowRationale(activity: Activity, result: MethodChannel.Result) {
        result.success(shouldShowRationale(activity))
    }

    fun handleCheck(activity: Activity, result: MethodChannel.Result) {
        result.success(getStatus(activity))
    }

    open fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        markAsked(activity)
        if (getStatus(activity) == 1) {
            result.success(1)
            return
        }
        pendingResult = result
        ActivityCompat.requestPermissions(activity, applicablePermissions, requestCode)
    }

   open fun handleServiceStatus(activity: Activity, result: MethodChannel.Result) {
        result.success(2) // not applicable by default
    }

    fun handleResult(activity: Activity, grantResults: IntArray) {
        val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingResult?.success(if (granted) 1 else getStatus(activity))
        pendingResult = null
    }

    fun handleOnActivityResult(activity: Activity) {
        pendingResult?.success(getStatus(activity))
        pendingResult = null
    }
}

object PermissionRegistry {
    private val cache = mutableMapOf<String, PermissionHandler>()

    fun getHandler(key: String): PermissionHandler? {
        return cache[key] ?: run {
            val handler = when (key) {
                ${handlers.map((e) => '"${e.key}" -> ${e.className}()').join('\n                ')}
                else -> null
            }
            if (handler != null) cache[key] = handler
            handler
        }
    }

    fun handlerByCode(requestCode: Int): PermissionHandler? =
        cache.values.find { it.requestCode == requestCode }
}

${handlers.mapIndexed((index, e) => e.generate(1010 + index)).join('\n')}

${_generateServiceSnippet()}
    
''';
  }

  String _generateServiceSnippet() {
    if (services.isEmpty) return '';
    final buffer = StringBuffer();
    final w = buffer.writeln;
    w('@Suppress("deprecation")');
    w('object ServiceChecker {');
    for (final service in services) {
      final functionName = 'check${service}Status';
      if (service == AssociatedService.location) {
        w('''
        fun $functionName(context: Context): Int {
          val enabled = when {
              Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> {
                  val locationManager = context.getSystemService(LocationManager::class.java)
                  locationManager?.isLocationEnabled ?: false
              }
              Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT -> {
                  try {
                      val locationMode = Settings.Secure.getInt(
                          context.contentResolver,
                          Settings.Secure.LOCATION_MODE
                      )
                      locationMode != Settings.Secure.LOCATION_MODE_OFF
                  } catch (e: Settings.SettingNotFoundException) {
                      print("Error checking location mode: \${e.message}")
                      false
                  }
              }
              else -> {
                  val locationProviders = Settings.Secure.getString(
                      context.contentResolver,
                      Settings.Secure.LOCATION_PROVIDERS_ALLOWED
                  )
                  !locationProviders.isNullOrEmpty()
              }
          }
          return if (enabled) 1 else 0
        }
    
         ''');
      } else if (service == AssociatedService.bluetooth) {
        w('''
        fun $functionName(context: Context): Int {
          val enabled = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
            BluetoothAdapter.getDefaultAdapter()?.isEnabled == true
          } else {
            val manager = context.getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
            manager.adapter?.isEnabled == true
          }
          return if (enabled) 1 else 0
        }
         ''');
      } else if (service == AssociatedService.phone) {
        w('''
        fun $functionName(context: Context): Int {
          val pm = context.packageManager
          if (!pm.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)) {
            return 2 // SERVICE_STATUS_NOT_APPLICABLE
          }
          val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
          if (telephonyManager == null || telephonyManager.phoneType == TelephonyManager.PHONE_TYPE_NONE) {
            return 2 // SERVICE_STATUS_NOT_APPLICABLE
          }
          val callIntent = Intent(Intent.ACTION_CALL).apply { data = Uri.parse("tel:777777") }
          val callAppsList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(callIntent, PackageManager.ResolveInfoFlags.of(0))
          } else {
            pm.queryIntentActivities(callIntent, 0)
          }
          if (callAppsList.isEmpty()) {
            return 2 // SERVICE_STATUS_NOT_APPLICABLE
          }
          return if (telephonyManager.simState == TelephonyManager.SIM_STATE_READY) {
            1 // SERVICE_STATUS_ENABLED
          } else {
            0 // SERVICE_STATUS_DISABLED
          }
        }
         ''');
      } else {
        throw UnimplementedError('Service check $service not implemented');
      }
    }
    w('}');
    return buffer.toString();
  }
}
