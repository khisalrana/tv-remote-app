package com.clicktv.universalremote

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Must match the MethodChannel name used in lib/services/ir_service.dart exactly.
    private val CHANNEL = "com.clicktv.universalremote/ir"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasIrBlaster" -> {
                        val ir = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
                        result.success(ir?.hasIrEmitter() ?: false)
                    }
                    "transmit" -> {
                        try {
                            val frequency = call.argument<Int>("frequency") ?: 38000
                            val pattern = call.argument<List<Int>>("pattern") ?: emptyList()
                            val ir = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
                            if (ir != null && ir.hasIrEmitter()) {
                                ir.transmit(frequency, pattern.toIntArray())
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
