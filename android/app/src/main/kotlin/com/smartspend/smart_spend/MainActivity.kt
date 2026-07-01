package com.smartspend.smart_spend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.smartspend.smart_spend/secrets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGeminiApiKey") {
                val apiKey = BuildConfig.GEMINI_API_KEY
                result.success(apiKey)
            } else {
                result.notImplemented()
            }
        }
    }
}
