import 'package:permit/generate/templates/android/handler_snippet.dart';
import 'package:permit/generate/templates/constants.dart';
import 'package:permit/generate/templates/template.dart';

class PluginKotlinClassTemp extends Template {
  final String packageName;
  final String channelName;
  final List<HandlerSnippet> handlers;

  PluginKotlinClassTemp({
    this.packageName = kAndroidPackageName,
    this.channelName = kChannelName,
    required this.handlers,
  });

  @override
  String get path => 'android/src/main/kotlin/${packageName.replaceAll('.', '/')}/PermitPlugin.kt';

  @override
  String generate() {
    return '''
package $packageName

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
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
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "$channelName")
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
            "open_settings" -> openSettings(act, result)
            "check_permission_status" -> getHandler(call, result)?.handleCheck(ctx, result)
            "request_permission" -> getHandler(call, result)?.handleRequest(act, result)
            "should_show_rationale" -> getHandler(call, result)
                ?.handleShouldShowRationale(ctx, result)

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
            context?.let { ctx -> it.handleResult(ctx, grantResults) }
            true
        } ?: false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return PermissionRegistry.handlerByCode(requestCode)?.let {
            context?.let { ctx -> it.handleOnActivityResult(ctx) }
            true
        } ?: false
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

data class Permission(val name: String, val sinceApi: Int? = null)

abstract class PermissionHandler(val requestCode: Int, permissions: Array<Permission>) {
     var pendingResult: MethodChannel.Result? = null

    val applicablePermissions: Array<String> = permissions
        .filter { it.sinceApi?.let { api -> android.os.Build.VERSION.SDK_INT >= api } ?: true }
        .map { it.name }
        .toTypedArray()

   open fun getStatus(context: Context): Int {
        applicablePermissions.ifEmpty { return 1 } // granted if no permissions to check
        val allGranted = applicablePermissions.all {
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return 1 // granted

        if (shouldShowRationale(context)) return 0 // denied, can ask again

        return 4 // permanently denied
    }

    fun shouldShowRationale(context: Context): Boolean {
        if (context !is Activity || applicablePermissions.isEmpty()) return false
        return applicablePermissions.any {
            ActivityCompat.shouldShowRequestPermissionRationale(context, it)
        }
    }

    fun handleShouldShowRationale(context: Context, result: MethodChannel.Result) {
        result.success(shouldShowRationale(context))
    }

    fun handleCheck(context: Context, result: MethodChannel.Result) {
        result.success(getStatus(context))
    }

    open fun handleRequest(activity: Activity, result: MethodChannel.Result) {
        if (getStatus(activity) == 1) {
            result.success(1)
            return
        }
        pendingResult = result
        ActivityCompat.requestPermissions(activity, applicablePermissions, requestCode)
    }

    fun handleResult(context: Context, grantResults: IntArray) {
        val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingResult?.success(if (granted) 1 else getStatus(context))
        pendingResult = null
    }

    fun handleOnActivityResult(context: Context) {
        pendingResult?.success(getStatus(context))
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

${handlers.map((e) => e.generate()).join('\n')}
    
''';
  }
}
