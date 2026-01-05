import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginClassTemp extends Template {
  final String packageName;

  PluginClassTemp({this.packageName = kAndroidPackageName});

  @override
  String get path => 'android/src/main/kotlin/${packageName.replaceAll('.', '/')}/PermitPlugin.kt';

  @override
  String generate() {
    return '''
package $packageName

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class PermitPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    ActivityAware, PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "permit.plugin/permissions")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
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
        val ctx = context ?: run { result.error("NO_CONTEXT", "Context is null", null); return }
        val act = activity ?: run { result.error("NO_ACTIVITY", "Activity is null", null); return }

        when (call.method) {
            "open_settings" -> {
                // Not implemented in this example
                result.notImplemented()
            }
            "request_permission" -> getHandler(call,result)?.handleCheck(ctx, result)
            "check_permission_status" -> getHandler(call,result)?.handleRequest(act, result)
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ): Boolean {
        PermissionRegistry.handlerByCode(requestCode)?.handleResult(grantResults)
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }
}


abstract class PermissionHandler(val requestCode: Int, val androidPermission: Array<String>) {
    private var pendingResult: MethodChannel.Result? = null

    fun getStatus(context: Context): Int {
        val allGranted = androidPermission.all {
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return 1 // granted

        if (context is Activity && androidPermission.isNotEmpty()) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(context, androidPermission[0])) {
                return 0 // denied, can ask again
            }
        }
        return 4 // permanently denied
    }

    fun handleCheck(context: Context, result: MethodChannel.Result) {
        result.success(getStatus(context))
    }

    fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        val status = getStatus(activity)
        if (status == 1) {
            result.success(1)
            return
        }
        pendingResult = result
        ActivityCompat.requestPermissions(activity, androidPermission, requestCode)
    }

    fun handleResult(grantResults: IntArray) {
        val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingResult?.success(if (granted) 1 else 0)
        pendingResult = null
    }
}


object PermissionRegistry {
    private val cache = mutableMapOf<String, PermissionHandler>()

    fun getHandler(key: String): PermissionHandler? {
        return cache[key] ?: run {
            val handler = when (key) {
                "camera" -> CameraHandler()
                "microphone" -> MicrophoneHandler()
                else -> null
            }
            if (handler != null) cache[key] = handler
            handler
        }
    }

    fun handlerByCode(requestCode: Int): PermissionHandler? =
        cache.values.find { it.requestCode == requestCode }
}


class CameraHandler() : PermissionHandler(1001, arrayOf(android.Manifest.permission.CAMERA))

class MicrophoneHandler() :
    PermissionHandler(1002, arrayOf(android.Manifest.permission.RECORD_AUDIO))
    
''';
  }
}
