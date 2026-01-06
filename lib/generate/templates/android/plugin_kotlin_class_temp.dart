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
// ---- GENERATED CODE - DO NOT MODIFY BY HAND ----
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

        when (call.method) {
            "open_settings" -> openSettings(act, result)
            "check_permission_status" -> getHandler(call, result)?.handleCheck(act, result)
            "request_permission" -> getHandler(call, result)?.handleRequest(act, result)
            "should_show_rationale" -> getHandler(call, result)
                ?.handleShouldShowRationale(act, result)

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

data class Permission(val name: String, val sinceApi: Int? = null)

abstract class PermissionHandler(val requestCode: Int, permissions: Array<Permission>) {
     val prefs = "permit_plugin_prefs"
     var pendingResult: MethodChannel.Result? = null

    val applicablePermissions: Array<String> = permissions
        .filter { it.sinceApi?.let { api -> android.os.Build.VERSION.SDK_INT >= api } ?: true }
        .map { it.name }
        .toTypedArray()


    private fun wasAsked(context: Context): Boolean =
         context.getSharedPreferences(prefs, Context.MODE_PRIVATE)
            .getBoolean("perm_asked_\${applicablePermissions.joinToString("-")}", false)

    private fun markAsked(context: Context) {
        context.getSharedPreferences(prefs, Context.MODE_PRIVATE)
            .edit()
            .putBoolean("perm_asked_\${applicablePermissions.joinToString("-")}", true)
            .apply()
    }

   open fun getStatus(activity: Activity): Int {
        applicablePermissions.ifEmpty { return 1 } // granted if no permissions to check
        val allGranted = applicablePermissions.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return 1 // granted

       val shouldShow = shouldShowRationale(activity)
       val askedBefore = wasAsked(activity)


       return when {
           !askedBefore -> 0     // first request
           shouldShow -> 0       // denied, can ask again
           else -> 4             // permanently denied
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

${handlers.map((e) => e.generate()).join('\n')}
    
''';
  }
}
