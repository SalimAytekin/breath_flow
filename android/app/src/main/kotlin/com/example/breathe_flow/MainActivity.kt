package com.breathflow.app

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

import com.breathflow.app.java.exercise_coaching.ExerciseCoachProcessor
import com.breathflow.app.java.exercise_coaching.ExerciseCoachingActivity

class MainActivity : FlutterActivity() {

    private val TAG = "MainActivity"
    private val METHOD_CHANNEL = "com.breathflow.app/pose_detector"
    private val EVENT_CHANNEL = "com.breathflow.app/pose_data"

    private var exerciseCoachProcessor: ExerciseCoachProcessor? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ExerciseCoachProcessor oluştur
        exerciseCoachProcessor = ExerciseCoachProcessor(this, null)

        // EventChannel — coaching feedback'leri Flutter'a gnderir
        val eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        )
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                exerciseCoachProcessor?.onListen(arguments, events!!)
            }

            override fun onCancel(arguments: Any?) {
                exerciseCoachProcessor?.onCancel(arguments)
            }
        })

        // MethodChannel — Flutter'dan komutları alır
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call: ${call.method}")
            when (call.method) {
                "startExerciseCoaching" -> {
                    try {
                        val exerciseData = call.arguments as? Map<String, Any>
                        val intent = Intent(this, ExerciseCoachingActivity::class.java)
                        intent.putExtra("exercise_name", exerciseData?.get("name") as? String ?: "Egzersiz")
                        intent.putExtra("exercise_type", exerciseData?.get("type") as? String ?: "default")
                        intent.putExtra("exercise_description", exerciseData?.get("description") as? String ?: "")
                        intent.putExtra("exercise_duration", exerciseData?.get("duration") as? String ?: "5 dk")
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "startExerciseCoaching error", e)
                        result.error("LAUNCH_ERROR", e.message, null)
                    }
                }

                "startPoseDetection" -> {
                    try {
                        // CameraXLivePreviewActivity (sadece pose overlay, coaching olmadan)
                        val intent = Intent(this, com.breathflow.app.java.CameraXLivePreviewActivity::class.java)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LAUNCH_ERROR", e.message, null)
                    }
                }

                "stopPoseDetection" -> {
                    result.success(true)
                }

                "startCoaching" -> {
                    val data = call.arguments as? Map<String, Any>
                    if (data != null) {
                        val dataMap = HashMap<String, Any>(data)
                        exerciseCoachProcessor?.startExercise(dataMap)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Exercise data required", null)
                    }
                }

                "stopCoaching" -> {
                    exerciseCoachProcessor?.stopExercise()
                    result.success(true)
                }

                "pauseCoaching" -> {
                    exerciseCoachProcessor?.pauseExercise()
                    result.success(true)
                }

                "resumeCoaching" -> {
                    exerciseCoachProcessor?.resumeExercise()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
