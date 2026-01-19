import 'package:test/test.dart';
import 'package:permit/generate/templates/android/plugin_kotlin_class_temp.dart';
import 'package:permit/generate/templates/android/handlers/kotlin_handler_snippet.dart';
import 'package:permit/registry/android_permissions.dart';

void main() {
  group('PluginKotlinClassTemp', () {
    test('generate with no handlers produces basic class and path', () {
      final plugin = PluginKotlinClassTemp(handlers: []);
      final output = plugin.generate();

      expect(output, contains('package ${plugin.packageName}'));
      expect(output, contains('class PermitPlugin : FlutterPlugin'));
      // path should have package slashes
      expect(plugin.path, contains(plugin.packageName.replaceAll('.', '/')));
    });

    test(
      'generate includes handler, service imports, and ServiceChecker for location',
      () {
        final handler = KotlinHandlerSnippet(
          key: 'location',
          permissions: [AndroidPermissions.accessFineLocation],
          imports: {'android.location.LocationManager'},
        );

        final plugin = PluginKotlinClassTemp(
          packageName: 'com.example.app',
          channelName: 'com.example.channel',
          handlers: [handler],
        );

        final output = plugin.generate();

        // Handler class generated
        expect(output, contains('class LocationHandler'));

        // Service import included
        expect(output, contains('import android.location.LocationManager'));

        // ServiceChecker function for Location should be present
        expect(output, contains('fun checkLocationStatus('));
        expect(output, contains('ServiceChecker.checkLocationStatus'));

        // PermissionRegistry mapping should include the handler key mapping
        expect(output, contains('"location" -> LocationHandler()'));

        // Path uses provided packageName
        expect(plugin.path, contains('com/example/app/PermitPlugin.kt'));
      },
    );

    test(
      'generate includes bluetooth and phone service snippets when provided',
      () {
        final h1 = KotlinHandlerSnippet(
          key: 'bluetooth',
          permissions: [AndroidPermissions.bluetoothConnect],
          imports: {'android.bluetooth.BluetoothAdapter'},
        );

        // Use accessFineLocation for phone? actually use readPhoneState for phone service
        final h2 = KotlinHandlerSnippet(
          key: 'phone',
          permissions: [AndroidPermissions.readPhoneState],
          imports: {'android.telephony.TelephonyManager'},
        );

        final plugin = PluginKotlinClassTemp(handlers: [h1, h2]);
        final output = plugin.generate();

        // Should contain ServiceChecker check functions for Bluetooth and Phone
        expect(output, contains('fun checkBluetoothStatus('));
        expect(output, contains('fun checkPhoneStatus('));

        // imports for bluetooth/phone should be present
        expect(
          output.contains('import android.bluetooth.BluetoothAdapter') ||
              output.contains('import android.bluetooth.BluetoothManager'),
          isTrue,
        );
        expect(
          output.contains('import android.telephony.TelephonyManager'),
          isTrue,
        );
      },
    );
  });
}
