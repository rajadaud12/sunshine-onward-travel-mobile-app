import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    @override
    fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                object : MethodCallHandler() {
                    @Override
                    fun onMethodCall(call: MethodCall, result: Result) {
                        if (call.method.equals("getGoogleMapsApiKey")) {
                            val apiKey: String? = this.apiKey
                            result.success(apiKey)
                        } else {
                            result.notImplemented()
                        }
                    }
                }
            )
    }

    private val apiKey: String?
        get() {
            try {
                val metaData: Bundle? = getPackageManager().getApplicationInfo(
                    getPackageName(),
                    PackageManager.GET_META_DATA
                ).metaData
                if (metaData != null) {
                    return metaData.getString("com.google.android.geo.API_KEY")
                }
            } catch (e: PackageManager.NameNotFoundException) {
                // Handle exception
            }
            return null
        }

    companion object {
        private val CHANNEL: String = "com.sot/app"
    }
}