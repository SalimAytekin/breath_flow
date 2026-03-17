package com.google.mlkit.vision.demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.plugins.FlutterPlugin
import android.content.Intent
import android.util.Log
import com.google.mlkit.vision.demo.java.LivePreviewActivity
import com.google.mlkit.vision.demo.java.exercise_coaching.ExerciseCoachProcessor
import com.google.mlkit.vision.demo.java.exercise_coaching.PoseDetectorToExerciseAdapter
// Gereksiz import kaldırıldı

class MainActivity : FlutterActivity(), FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    
    private val METHOD_CHANNEL_NAME = "com.google.mlkit.vision.demo/pose_detector"
    private val EVENT_CHANNEL_NAME = "com.google.mlkit.vision.demo/pose_data"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var exerciseCoachProcessor: ExerciseCoachProcessor? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Plugin'i Flutter engine'e kaydet
        flutterEngine.plugins.add(this)
    }
    
    // FlutterPlugin implementation
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("MainActivity", "Plugin attached to engine")
        
        val messenger = binding.binaryMessenger
        
        // MethodChannel kurulumu
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        
        // EventChannel kurulumu
        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
        eventChannel?.setStreamHandler(this)
        
        // ExerciseCoachProcessor'ı başlat (null BinaryMessenger ile - MethodChannel MainActivity'de yönetiliyor)
        exerciseCoachProcessor = ExerciseCoachProcessor(binding.applicationContext, null)
        
        // ExerciseCoachProcessor'ı PoseDetectorToExerciseAdapter'a bağla
        PoseDetectorToExerciseAdapter.setExerciseCoachProcessor(exerciseCoachProcessor)
        
        Log.d("MainActivity", "Channels and ExerciseCoachProcessor initialized")
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("MainActivity", "Plugin detached from engine")
        
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        
        exerciseCoachProcessor = null
    }
    
    // MethodCallHandler implementation
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("MainActivity", "Method call received: ${call.method}")
        
        when (call.method) {
            "startPoseDetection" -> {
                try {
                    Log.d("PoseDetection", "Starting pose detection activity")
                    val intent = Intent(this, LivePreviewActivity::class.java)
                    startActivity(intent)
                    result.success("Pose detection started")
                } catch (e: Exception) {
                    Log.e("PoseDetection", "Error starting pose detection", e)
                    result.error("ERROR", "Failed to start pose detection: ${e.message}", null)
                }
            }
            "stopPoseDetection" -> {
                result.success("Pose detection stopped")
            }
            "startCoaching" -> {
                try {
                    val exerciseData = call.arguments as? Map<String, Any>
                    if (exerciseData != null && exerciseCoachProcessor != null) {
                        exerciseCoachProcessor!!.startExercise(exerciseData)
                        // Pose detection'dan gelen verileri ExerciseCoachProcessor'a yönlendir
                        PoseDetectorToExerciseAdapter.setEnabled(true)
                        result.success("Coaching started")
                    } else {
                        result.error("INVALID_ARGUMENTS", "Exercise data is required", null)
                    }
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error starting coaching", e)
                    result.error("START_ERROR", "Failed to start coaching: ${e.message}", null)
                }
            }
            "stopCoaching" -> {
                try {
                    exerciseCoachProcessor?.stopExercise()
                    // Pose detection'dan gelen verilerin yönlendirilmesini durdur
                    PoseDetectorToExerciseAdapter.setEnabled(false)
                    result.success("Coaching stopped")
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error stopping coaching", e)
                    result.error("STOP_ERROR", "Failed to stop coaching: ${e.message}", null)
                }
            }
            "pauseCoaching" -> {
                try {
                    exerciseCoachProcessor?.pauseExercise()
                    result.success("Coaching paused")
                } catch (e: Exception) {
                    result.error("PAUSE_ERROR", "Failed to pause coaching: ${e.message}", null)
                }
            }
            "resumeCoaching" -> {
                try {
                    exerciseCoachProcessor?.resumeExercise()
                    result.success("Coaching resumed")
                } catch (e: Exception) {
                    result.error("RESUME_ERROR", "Failed to resume coaching: ${e.message}", null)
                }
            }
            "startExerciseCoaching" -> {
                try {
                    // YENİ: Exercise coaching activity'yi başlat
                    val intent = Intent(this, com.google.mlkit.vision.demo.java.exercise_coaching.ExerciseCoachingActivity::class.java)
                    // Egzersiz bilgilerini intent ile gönder
                    val exerciseData = call.arguments as? Map<String, Any>
                    if (exerciseData != null) {
                        intent.putExtra("exercise_name", exerciseData["name"] as? String ?: "Egzersiz")
                        intent.putExtra("exercise_type", exerciseData["type"] as? String ?: "default")
                        intent.putExtra("exercise_description", exerciseData["description"] as? String ?: "")
                        intent.putExtra("exercise_duration", exerciseData["duration"] as? String ?: "5 dk")
                        intent.putExtra("exercise_difficulty", exerciseData["difficulty"] as? String ?: "Kolay")
                        
                        // Instructions array'ini JSON string olarak gönder
                        val instructions = exerciseData["instructions"] as? List<String>
                        if (instructions != null) {
                            intent.putExtra("exercise_instructions", instructions.joinToString("|"))
                        }
                        
                        Log.d("MainActivity", "Exercise data sent to coaching activity: ${exerciseData["name"]} (${exerciseData["type"]})")
                    }
                    startActivity(intent)
                    result.success("Exercise coaching started")
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error starting exercise coaching", e)
                    result.error("START_ERROR", "Failed to start exercise coaching: ${e.message}", null)
                }
            }
            else -> {
                Log.w("MainActivity", "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }
    
    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d("MainActivity", "EventChannel listener attached")
        exerciseCoachProcessor?.onListen(arguments, events)
    }
    
    override fun onCancel(arguments: Any?) {
        Log.d("MainActivity", "EventChannel listener cancelled")
        exerciseCoachProcessor?.onCancel(arguments)
    }
}
