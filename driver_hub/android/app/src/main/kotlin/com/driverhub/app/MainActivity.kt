package com.driverhub.app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.driverhub.app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            if (call.method == "getMapsApiKey") {
                try {
                    val applicationInfo = packageManager.getApplicationInfo(
                        packageName,
                        PackageManager.GET_META_DATA
                    )

                    val apiKey = applicationInfo.metaData
                        ?.getString("com.google.android.geo.API_KEY")

                    if (!apiKey.isNullOrBlank()) {
                        result.success(apiKey)
                    } else {
                        result.error(
                            "API_KEY_NOT_FOUND",
                            "Google Maps API key not found in AndroidManifest.xml",
                            null
                        )
                    }
                } catch (exception: Exception) {
                    result.error(
                        "API_KEY_ERROR",
                        exception.message,
                        null
                    )
                }
            } else {
                result.notImplemented()
            }
        }
    }
}