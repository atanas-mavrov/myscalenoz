package app.smallapps.myscalenoz

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingEnable: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestEnable" -> requestEnable(result)
                    else -> result.notImplemented()
                }
            }
    }

    /** Shows Android's "turn on Bluetooth?" dialog; replies whether the user agreed. */
    @SuppressLint("MissingPermission") // BLUETOOTH_CONNECT is requested before.
    private fun requestEnable(result: MethodChannel.Result) {
        if (pendingEnable != null) {
            result.error("busy", "A request is already showing", null)
            return
        }
        pendingEnable = result
        try {
            startActivityForResult(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE), REQUEST_ENABLE)
        } catch (e: Exception) {
            pendingEnable = null
            result.success(false)
        }
    }

    @Deprecated("Needed for the startActivityForResult reply")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ENABLE) {
            pendingEnable?.success(resultCode == RESULT_OK)
            pendingEnable = null
        }
    }

    companion object {
        private const val CHANNEL = "app.smallapps.myscalenoz/bluetooth"
        private const val REQUEST_ENABLE = 4711
    }
}
