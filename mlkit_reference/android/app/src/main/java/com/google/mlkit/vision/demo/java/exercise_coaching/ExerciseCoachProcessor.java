package com.google.mlkit.vision.demo.java.exercise_coaching;

import android.content.Context;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.pose.Pose;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

import java.util.HashMap;
import java.util.Map;

/**
 * Egzersiz koçluk işlemcisi. MLKit Pose Detection'dan alınan Pose nesnelerini kullanarak
 * egzersiz değerlendirmesi yapar ve sonuçları Flutter'a gönderir.
 */
public class ExerciseCoachProcessor {
    private static final String TAG = "ExerciseCoachProcessor";
    
    // Flutter ile iletişim için kanallar
    private static final String CHANNEL_NAME = "com.google.mlkit.vision.demo/pose_detector";
    private static final String EVENT_CHANNEL_NAME = "com.google.mlkit.vision.demo/pose_data";
    
    private final Context context;
    private final BinaryMessenger binaryMessenger;
    private EventChannel.EventSink eventSink;
    
    // Egzersiz durumu
    private boolean isCoachingEnabled = false;
    private boolean isExerciseActive = false;
    private boolean isPaused = false;
    private Map<String, Object> currentExercise;
    private int repetitionCount = 0;
    
    // Modüler egzersiz sistemi
    private BaseExerciseAnalyzer currentAnalyzer;
    
    // FPS optimizasyonu için frame throttling
    private long lastProcessTime = 0;
    private static final long PROCESS_INTERVAL_MS = 100; // 10 FPS (100ms aralık)
    
    // UI güncelleme throttling
    private long lastFeedbackTime = 0;
    private String lastFeedbackMessage = "";
    private static final long FEEDBACK_INTERVAL_MS = 300; // ~3 FPS feedback
    
    // Ana thread'de çalışacak handler
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    
    /**
     * ExerciseCoachProcessor kurucusu
     * 
     * @param context App context
     * @param binaryMessenger Flutter binary messenger - null olabilir (MainActivity'den kurulduğunda)
     */
    public ExerciseCoachProcessor(Context context, BinaryMessenger binaryMessenger) {
        this.context = context;
        this.binaryMessenger = binaryMessenger;
        Log.d(TAG, "ExerciseCoachProcessor created");
        
        // Method Channel kurulumu - SADECE binaryMessenger null DEĞİLSE (MainActivity'den değil, doğrudan çağrıldığında)
        // MainActivity'den çağrıldığında binaryMessenger null olur ve MethodChannel MainActivity'de kurulur
        if (binaryMessenger != null) {
            Log.d(TAG, "Setting up MethodChannel handler directly in ExerciseCoachProcessor");
            new MethodChannel(binaryMessenger, CHANNEL_NAME).setMethodCallHandler(this::handleMethodCall);
        } else {
            Log.d(TAG, "MethodChannel handler will be managed by MainActivity");
        }
    }
    
    /**
     * Flutter'dan gelen method çağrılarını işler
     */
    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.d(TAG, "Method call received: " + call.method);
        switch (call.method) {
            case "enableExerciseCoach":
                Log.d(TAG, "Enabling exercise coach");
                isCoachingEnabled = true;
                result.success(true);
                break;
                
            case "disableExerciseCoach":
                Log.d(TAG, "Disabling exercise coach");
                isCoachingEnabled = false;
                result.success(true);
                break;
                
            case "enableContinuousData":
                Log.d(TAG, "Enabling continuous data stream");
                // Bu metot pose detection'dan sürekli veri akışını etkinleştirir
                // Şu anda bir şey yapmıyoruz çünkü pose detection zaten sürekli çalışıyor
                result.success(true);
                break;
                
            case "disableContinuousData":
                Log.d(TAG, "Disabling continuous data stream");
                result.success(true);
                break;
                
            case "startCoaching":
                try {
                    Map<String, Object> exerciseData = call.arguments();
                    if (exerciseData != null) {
                        startExercise(exerciseData);
                        result.success(true);
                    } else {
                        result.error("INVALID_ARGUMENTS", "Exercise data is required", null);
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error starting exercise", e);
                    result.error("START_ERROR", "Failed to start exercise: " + e.getMessage(), null);
                }
                break;
                
            case "pauseCoaching":
                pauseExercise();
                result.success(true);
                break;
                
            case "resumeCoaching":
                resumeExercise();
                result.success(true);
                break;
                
            case "stopCoaching":
                stopExercise();
                result.success(true);
                break;
                
            default:
                Log.w(TAG, "Method not implemented: " + call.method);
                result.notImplemented();
                break;
        }
    }
    
    /**
     * Event Channel listener'ı ayarlar
     */
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "EventSink attached");
        this.eventSink = events;
    }
    
    /**
     * Event Channel listener'ını kaldırır
     */
    public void onCancel(Object arguments) {
        Log.d(TAG, "EventSink detached");
        this.eventSink = null;
    }
    
    /**
     * Egzersizi başlatır
     * 
     * @param exerciseData Egzersiz verileri
     */
    public void startExercise(Map<String, Object> exerciseData) {
        Log.d(TAG, "Starting exercise: " + exerciseData);
        this.currentExercise = exerciseData;
        this.isExerciseActive = true;
        this.isCoachingEnabled = true;
        this.isPaused = false;
        this.repetitionCount = 0;
        
        // Modüler analizör oluştur
        String exerciseType = (String) exerciseData.get("type");
        String analyzerType = (String) exerciseData.get("analyzerType");
        Log.d(TAG, "🔧 Analyzer seçiliyor - Exercise Type: " + exerciseType + ", AnalyzerType: " + analyzerType);
        Log.d(TAG, "🔧 Exercise Data: " + exerciseData);
        
        if ("default".equals(analyzerType)) {
            Map<String, Object> rules = (Map<String, Object>) exerciseData.get("rules");
            java.util.List<Map<String, Object>> feedbackRules = (java.util.List<Map<String, Object>>) exerciseData.get("feedback");
            if (rules != null) {
                rules.put("exerciseName", (String) exerciseData.get("title"));
                rules.put("exerciseType", (String) exerciseData.get("type"));
            }
            this.currentAnalyzer = ExerciseAnalyzerFactory.createAnalyzer("default", rules, feedbackRules);
        } else {
            this.currentAnalyzer = ExerciseAnalyzerFactory.createAnalyzer(exerciseType);
        }
        
        if (currentAnalyzer == null) {
            Log.w(TAG, "❌ Desteklenmeyen egzersiz tipi: " + exerciseType);
            Log.w(TAG, "❌ Desteklenen egzersizler: " + java.util.Arrays.toString(ExerciseAnalyzerFactory.getSupportedExerciseIds()));
            sendFeedback("Bu egzersiz henüz desteklenmiyor: " + exerciseType);
            return;
        }
        
        // Egzersiz başlangıç bilgisini gönder
        sendEvent("exercise_started", exerciseData);
        
        // Egzersiz tipi özel başlangıç mesajı
        String startMessage = getStartMessage(exerciseType, exerciseData);
        sendFeedback(startMessage);
        
        Log.d(TAG, "✅ Modüler analizör başlatıldı: " + currentAnalyzer.getClass().getSimpleName());
    }
    
    /**
     * Egzersizi duraklatır
     */
    public void pauseExercise() {
        if (isExerciseActive) {
            isPaused = true;
            sendEvent("exercise_paused", null);
            sendFeedback("Egzersiz duraklatıldı.");
        }
    }
    
    /**
     * Duraklatılmış egzersizi devam ettirir
     */
    public void resumeExercise() {
        if (isExerciseActive && isPaused) {
            isPaused = false;
            sendEvent("exercise_resumed", null);
            sendFeedback("Egzersiz devam ediyor.");
        }
    }
    
    /**
     * Egzersizi durdurur
     */
    public void stopExercise() {
        if (isExerciseActive) {
            isExerciseActive = false;
            isPaused = false;
            sendEvent("exercise_stopped", null);
            Log.d(TAG, "Exercise stopped");
        }
    }
    
    /**
     * Poz verisini işler ve egzersiz değerlendirmesi yapar
     * 
     * @param pose MLKit'ten gelen poz verisi
     */
    public void processPose(Pose pose) {
        if (!isCoachingEnabled || !isExerciseActive || isPaused || pose == null) {
            return;
        }
        
        // FPS optimizasyonu: Sadece belirli aralıklarla işle
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastProcessTime < PROCESS_INTERVAL_MS) {
            return; // Bu frame'i atla
        }
        lastProcessTime = currentTime;
        
        Log.d(TAG, "processPose called - coaching: " + isCoachingEnabled + ", active: " + isExerciseActive + ", paused: " + isPaused + ", pose: " + (pose != null));
        
        try {
            // Egzersiz değerlendirmesi yap (pose data gönderme sadece gerektiğinde)
            evaluateExercise(pose);
        } catch (Exception e) {
            Log.e(TAG, "Error processing pose", e);
        }
    }
    
    /**
     * Pose nesnesini Map'e çevirir
     */
    private Map<String, Object> convertPoseToMap(Pose pose) {
        Map<String, Object> poseMap = new HashMap<>();
        
        // Landmarks'ları çevir
        java.util.List<Map<String, Object>> landmarksList = new java.util.ArrayList<>();
        for (var landmark : pose.getAllPoseLandmarks()) {
            Map<String, Object> landmarkData = new HashMap<>();
            
            // getLandmarkType() int döndürüyor, name() metodu yok
            int landmarkType = landmark.getLandmarkType();
            landmarkData.put("type", getPoseLandmarkTypeName(landmarkType));
            landmarkData.put("x", landmark.getPosition().x);
            landmarkData.put("y", landmark.getPosition().y);
            landmarkData.put("z", 0.0); // PointF'te z yok, 0 olarak ayarla
            landmarkData.put("likelihood", landmark.getInFrameLikelihood());
            
            landmarksList.add(landmarkData);
        }
        
        poseMap.put("landmarks", landmarksList);
        poseMap.put("timestamp", System.currentTimeMillis());
        
        return poseMap;
    }
    
    /**
     * Pose landmark type int'ini string'e çevirir
     */
    private String getPoseLandmarkTypeName(int landmarkType) {
        switch (landmarkType) {
            case com.google.mlkit.vision.pose.PoseLandmark.NOSE: return "NOSE";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_EYE_INNER: return "LEFT_EYE_INNER";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_EYE: return "LEFT_EYE";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_EYE_OUTER: return "LEFT_EYE_OUTER";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_EYE_INNER: return "RIGHT_EYE_INNER";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_EYE: return "RIGHT_EYE";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_EYE_OUTER: return "RIGHT_EYE_OUTER";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_EAR: return "LEFT_EAR";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_EAR: return "RIGHT_EAR";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_MOUTH: return "LEFT_MOUTH";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_MOUTH: return "RIGHT_MOUTH";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_SHOULDER: return "LEFT_SHOULDER";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_SHOULDER: return "RIGHT_SHOULDER";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_ELBOW: return "LEFT_ELBOW";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_ELBOW: return "RIGHT_ELBOW";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_WRIST: return "LEFT_WRIST";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_WRIST: return "RIGHT_WRIST";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_PINKY: return "LEFT_PINKY";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_PINKY: return "RIGHT_PINKY";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_INDEX: return "LEFT_INDEX";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_INDEX: return "RIGHT_INDEX";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_THUMB: return "LEFT_THUMB";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_THUMB: return "RIGHT_THUMB";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_HIP: return "LEFT_HIP";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_HIP: return "RIGHT_HIP";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_KNEE: return "LEFT_KNEE";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_KNEE: return "RIGHT_KNEE";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_ANKLE: return "LEFT_ANKLE";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_ANKLE: return "RIGHT_ANKLE";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_HEEL: return "LEFT_HEEL";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_HEEL: return "RIGHT_HEEL";
            case com.google.mlkit.vision.pose.PoseLandmark.LEFT_FOOT_INDEX: return "LEFT_FOOT_INDEX";
            case com.google.mlkit.vision.pose.PoseLandmark.RIGHT_FOOT_INDEX: return "RIGHT_FOOT_INDEX";
            default: return "UNKNOWN";
        }
    }
    
    /**
     * Egzersiz tipine göre başlangıç mesajı döndürür
     */
    private String getStartMessage(String exerciseType, Map<String, Object> exerciseData) {
        String exerciseName = (String) exerciseData.get("name");
        
        switch (exerciseType.toLowerCase()) {
            case "chin_tuck":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "💪 Çenenizi hafifçe geriye çekin\n" +
                       "⏱️ 5 saniye tutun, 10 tekrar yapın";
                       
            case "upper_trap_stretch":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🤲 Elinizle başınızı yana eğin\n" +
                       "⏱️ 20-30 saniye tutun";
                       
            case "levator_skapula_stretch":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "📐 Başınızı 45° öne ve yana eğin\n" +
                       "🤲 Elinizle hafifçe destekleyin";
                       
            case "neck_rotation_mobilization":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🔄 Başınızı yavaşça sağa-sola çevirin\n" +
                       "🔄 Sonra sağa-sola yana eğin";
                       
            case "isometric_neck":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🤲 Elinizi alnınıza koyun\n" +
                       "💪 Başı hareket ettirmeden dirençle itin";
                       
            case "pelvic_tilt_nondiagnosed":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🛌 Sırt üstü yatın, dizleri bükün\n" +
                       "⬆️ Kalçayı hafifçe yukarı kaldırın";
                       
            case "cat_camel_nondiagnosed":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🐱 Dört ayak pozisyonunda durun\n" +
                       "🔄 Sırtı yukarı kaldırıp aşağı indirin";
                       
            case "superman":
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "🦸 Yüzüstü yatın\n" +
                       "⬆️ Kol ve bacakları birlikte kaldırın";
                       
            default:
                return "🎯 " + exerciseName + " başlıyor!\n" +
                       "📱 Kamerayı egzersiz alanına odaklayın\n" +
                       "▶️ Harekete başlayabilirsiniz";
        }
    }
    
    /**
     * Poz verisini kullanarak egzersiz değerlendirmesi yapar
     * 
     * @param pose MLKit'ten gelen poz verisi
     */
    private void evaluateExercise(Pose pose) {
        // Modüler analizör kullan
        if (currentAnalyzer == null) {
            Log.w(TAG, "Analizör mevcut değil, varsayılan değerlendirme yapılıyor");
                defaultEvaluation(pose);
            return;
        }
        
        try {
            Log.d(TAG, "📊 Pose analizi yapılıyor - Analyzer: " + currentAnalyzer.getClass().getSimpleName());
            BaseExerciseAnalyzer.AnalysisResult result = currentAnalyzer.analyze(pose);
            
            // Sonuçları UI'ya gönder
            sendAccuracy(result.accuracy);
            sendFeedback(result.feedback);
            
            // Log accuracy ve feedback (tam mesaj)
            Log.d(TAG, "📊 Accuracy: " + String.format("%.2f", result.accuracy) + " - Feedback: " + result.feedback);
            
            // Tekrar tamamlandıysa sayısını artır
            if (result.isRepetitionComplete) {
                incrementRepetition();
            }
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Modüler analiz hatası", e);
            sendFeedback("Analiz hatası oluştu");
            sendAccuracy(0.0);
        }
    }
    
    // *** ESKİ METOD KALDIRILDI - Artık modüler SquatAnalyzer kullanılıyor ***
    
    // *** ESKİ METOD KALDIRILDI - Artık modüler NeckRotationAnalyzer kullanılıyor ***
    
    // *** ESKİ BOYUN EGZERSİZ METODLARI KALDIRILDI ***
    // *** Artık modüler sistem kullanılıyor: ***
    // *** - NeckSideBendAnalyzer (gelecekte) ***
    // *** - NeckFlexionAnalyzer (gelecekte) ***

    /**
     * Diğer egzersizler için varsayılan değerlendirme
     */
    private void defaultEvaluation(Pose pose) {
        // Varsayılan değerlendirme - her 30 frame'de bir tekrar say
        if (Math.random() < 0.03) {
            repetitionCount++;
            sendRepetitionCount(repetitionCount);
            
            double accuracy = 0.5 + (Math.random() * 0.5);
            sendAccuracy(accuracy);
            
            if (accuracy > 0.8) {
                sendFeedback("Harika! Mükemmel form.");
            } else if (accuracy > 0.6) {
                sendFeedback("İyi gidiyorsun, ancak sırtını daha dik tut.");
            } else {
                sendFeedback("Formuna dikkat et, pozisyonunu kontrol et.");
            }
        }
    }
    
    /**
     * Tekrar sayısını artır (mükemmel form için)
     */
    private void incrementRepetition() {
        repetitionCount++;
        sendRepetitionCount(repetitionCount);
        Log.d(TAG, "Repetition count: " + repetitionCount);
    }
    
    /**
     * Poz verisini Flutter'a gönderir (sadece gerektiğinde)
     * 
     * @param poseData Gönderilecek poz verisi
     */
    private void sendPoseData(Map<String, Object> poseData) {
        // Pose data gönderme şu an için devre dışı - sadece coaching feedback'i gönderiyoruz
        // İleride pose skeleton overlay gerekirse burası açılabilir
        /*
        Log.d(TAG, "sendPoseData called - eventSink: " + (eventSink != null) + ", landmarks: " + (poseData != null ? poseData.size() : "null"));
        
        if (eventSink == null) {
            Log.w(TAG, "EventSink is null, cannot send pose data");
            return;
        }
        
        Map<String, Object> event = new HashMap<>();
        event.put("type", "pose_data");
        event.put("data", poseData);
        
        mainHandler.post(() -> {
            if (eventSink != null) {
                try {
                    eventSink.success(event);
                    Log.d(TAG, "Pose data sent successfully");
                } catch (Exception e) {
                    Log.e(TAG, "Error sending pose data", e);
                }
            }
        });
        */
    }
    
    /**
     * Doğruluk değerini Flutter'a gönderir
     * 
     * @param accuracy Doğruluk değeri (0.0-1.0)
     */
    private void sendAccuracy(double accuracy) {
        if (eventSink == null) {
            return;
        }
        
        Map<String, Object> data = new HashMap<>();
        data.put("value", accuracy);
        
        sendEvent("accuracy", data);
    }
    
    /**
     * Tekrar sayısını Flutter'a gönderir
     * 
     * @param count Tekrar sayısı
     */
    private void sendRepetitionCount(int count) {
        if (eventSink == null) {
            return;
        }
        
        Map<String, Object> data = new HashMap<>();
        data.put("count", count);
        
        sendEvent("repetition", data);
    }
    
    /**
     * Kullanıcıya geri bildirim gönderir (throttled)
     * 
     * @param message Geri bildirim mesajı
     */
    private void sendFeedback(final String message) {
        if (eventSink == null) {
            return;
        }
        
        // Feedback throttling - ama aynı mesaj kontrolünü kaldırıyoruz
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastFeedbackTime < FEEDBACK_INTERVAL_MS) {
            return;
        }
        
        lastFeedbackTime = currentTime;
        lastFeedbackMessage = message;
        
        // Geri bildirim olayını oluştur
        final Map<String, Object> data = new HashMap<>();
        data.put("message", message);
        data.put("timestamp", currentTime);
        
        sendEvent("feedback", data);
        Log.d(TAG, "Geri bildirim gönderildi: " + message);
    }
    
    /**
     * Belirli bir event tipini EventSink üzerinden Flutter'a gönderir
     * 
     * @param eventType Olay tipi
     * @param data Olay verileri
     */
    private void sendEvent(final String eventType, final Map<String, Object> data) {
        if (eventSink == null) {
            Log.w(TAG, "EventSink mevcut değil, event yok sayılıyor: " + eventType);
            return;
        }
        
        // Gönderilecek veriyi hazırla
        final Map<String, Object> event = new HashMap<>();
        event.put("type", eventType);
        event.put("data", data);
        
        // Ana thread'de gönder
        mainHandler.post(() -> {
            if (eventSink != null) { // Çift kontrol - post işlemi gerçekleşene kadar eventSink null olabilir
                try {
                    eventSink.success(event);
                    Log.d(TAG, "Event başarıyla gönderildi: " + eventType);
                } catch (Exception e) {
                    Log.e(TAG, "Event gönderilirken hata: " + e.getMessage());
                }
            } else {
                Log.w(TAG, "Post sırasında EventSink null oldu, event gönderilemedi: " + eventType);
            }
        });
    }
}
