package it.rateel.tajweed_lab

import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.FloatBuffer
import java.nio.IntBuffer
import java.util.concurrent.Executors

/**
 * Runs the int8 Muaalem model with the official ONNX Runtime package on a background thread
 * (the Flutter plugin used before ran it on the main thread: Android closed the app during analysis).
 * Also reports the device memory and why Android last closed the app.
 */
class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val env: OrtEnvironment by lazy { OrtEnvironment.getEnvironment() }
    private var session: OrtSession? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rateel.lab/ort").setMethodCallHandler { call, result ->
            fun ok(v: Any?) = main.post { result.success(v) }
            fun fail(t: Throwable) = main.post { result.error(t.javaClass.simpleName, t.message ?: t.toString(), t.stackTraceToString()) }
            when (call.method) {
                "deviceInfo" -> result.success(deviceInfo())
                "load" -> worker.execute {
                    try {
                        session?.close()
                        session = null
                        val opts = OrtSession.SessionOptions()
                        opts.setIntraOpNumThreads(call.argument<Int>("threads") ?: 2)
                        val lowMem = call.argument<Boolean>("lowMemory") ?: false
                        if (lowMem) {
                            opts.setCPUArenaAllocator(false)
                            opts.setMemoryPatternOptimization(false)
                        }
                        val t0 = SystemClock.elapsedRealtime()
                        session = env.createSession(call.argument<String>("path")!!, opts)
                        ok(mapOf("ms" to (SystemClock.elapsedRealtime() - t0).toInt()))
                    } catch (t: Throwable) {
                        fail(t)
                    }
                }
                "run" -> worker.execute {
                    try {
                        val s = session ?: throw IllegalStateException("model not loaded")
                        val features = call.argument<FloatArray>("features")!!
                        val mask = call.argument<IntArray>("mask")!!
                        val frames = mask.size.toLong()
                        val t0 = SystemClock.elapsedRealtime()
                        OnnxTensor.createTensor(env, FloatBuffer.wrap(features), longArrayOf(1, frames, 160)).use { x ->
                            OnnxTensor.createTensor(env, IntBuffer.wrap(mask), longArrayOf(1, frames)).use { m ->
                                s.run(mapOf("input_features" to x, "attention_mask" to m), setOf("phonemes")).use { r ->
                                    val out = r.get("phonemes").get() as OnnxTensor
                                    val shape = out.info.shape
                                    val buf = out.floatBuffer
                                    val arr = FloatArray(buf.remaining())
                                    buf.get(arr)
                                    ok(mapOf(
                                        "logits" to arr,
                                        "frames" to shape[1].toInt(),
                                        "classes" to shape[2].toInt(),
                                        "ms" to (SystemClock.elapsedRealtime() - t0).toInt(),
                                    ))
                                }
                            }
                        }
                    } catch (t: Throwable) {
                        fail(t)
                    }
                }
                "close" -> worker.execute {
                    session?.close()
                    session = null
                    ok(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun deviceInfo(): Map<String, Any?> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mi = ActivityManager.MemoryInfo()
        am.getMemoryInfo(mi)
        val info = mutableMapOf<String, Any?>(
            "device" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "android" to Build.VERSION.RELEASE,
            "totalMb" to (mi.totalMem / 1048576).toInt(),
            "availMb" to (mi.availMem / 1048576).toInt(),
            "lowMemory" to mi.lowMemory,
            "appLimitMb" to am.largeMemoryClass,
        )
        if (Build.VERSION.SDK_INT >= 30) {
            val exits = am.getHistoricalProcessExitReasons(packageName, 0, 1)
            if (exits.isNotEmpty()) {
                val e = exits[0]
                info["lastExit"] = mapOf(
                    "reason" to reasonName(e.reason),
                    "description" to e.description,
                    "time" to e.timestamp,
                    "pssMb" to (e.pss / 1024).toInt(),
                    "rssMb" to (e.rss / 1024).toInt(),
                )
            }
        }
        return info
    }

    private fun reasonName(r: Int) = when (r) {
        1 -> "EXIT_SELF"
        2 -> "SIGNALED"
        3 -> "LOW_MEMORY"
        4 -> "CRASH (Java)"
        5 -> "CRASH_NATIVE"
        6 -> "ANR (app non risponde)"
        7 -> "INITIALIZATION_FAILURE"
        8 -> "PERMISSION_CHANGE"
        9 -> "EXCESSIVE_RESOURCE_USAGE"
        10 -> "USER_REQUESTED"
        11 -> "USER_STOPPED"
        12 -> "DEPENDENCY_DIED"
        13 -> "OTHER"
        14 -> "FREEZER"
        15 -> "PACKAGE_STATE_CHANGE"
        16 -> "PACKAGE_UPDATED"
        else -> "UNKNOWN ($r)"
    }
}
