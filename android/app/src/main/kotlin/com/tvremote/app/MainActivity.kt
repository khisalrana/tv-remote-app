package com.tvremote.app

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tvremote.app/ir"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasIrBlaster" -> {
                    val irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
                    result.success(irManager?.hasIrEmitter() ?: false)
                }
                "transmit" -> {
                    val frequency = call.argument<Int>("frequency") ?: 38000
                    val pattern = call.argument<List<Int>>("pattern") ?: emptyList()
                    try {
                        val irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
                        if (irManager != null && irManager.hasIrEmitter()) {
                            irManager.transmit(frequency, pattern.toIntArray())
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.error("IR_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
