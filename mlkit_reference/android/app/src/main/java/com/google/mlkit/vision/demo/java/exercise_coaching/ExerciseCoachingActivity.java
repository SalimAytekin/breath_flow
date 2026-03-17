package com.google.mlkit.vision.demo.java.exercise_coaching;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.FrameLayout;

import com.google.mlkit.vision.demo.R;
import com.google.mlkit.vision.demo.java.CameraXLivePreviewActivity;
import com.google.mlkit.vision.demo.java.exercise_coaching.ExerciseCoachProcessor;
import com.google.mlkit.vision.demo.java.exercise_coaching.PoseDetectorToExerciseAdapter;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

/**
 * Egzersiz koçluk ekranı - CameraXLivePreviewActivity'yi genişleterek
 * pose detection üzerine coaching overlay'i ekler
 */
public class ExerciseCoachingActivity extends CameraXLivePreviewActivity {
    private static final String TAG = "ExerciseCoaching";
    
    // Coaching UI elementi
    private View coachingOverlay;
    private TextView tvExerciseName;
    private TextView tvRepetitionCount;
    private TextView tvFeedbackMessage;
    private TextView tvFeedbackTitle;
    private TextView tvFeedbackEmoji;
    private TextView tvAccuracyPercentage;
    private TextView tvTimer;
    private TextView tvFpsInfo;
    private TextView tvPoseQuality;
    private TextView tvMovementFlow;
    private TextView tvStability;
    private TextView tvBestAccuracy;
    private TextView tvAvgAccuracy;
    private TextView tvExerciseInstructions;
    private ProgressBar progressAccuracy;
    private Button btnStopCoaching;
    
    // Performance tracking
    private long startTime;
    private int frameCount = 0;
    private double totalAccuracy = 0;
    private double bestAccuracy = 0;
    private long lastFpsUpdate = 0;
    
    // Coaching processor
    private ExerciseCoachProcessor exerciseCoachProcessor;
    private String currentExerciseName = "Boyun Döndürme Egzersizi";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Log.d(TAG, "🎯 Egzersiz koçluk ekranı başlatılıyor");
        
        // Coaching overlay'ini ekle
        setupCoachingOverlay();
        
        // Coaching processor'ı başlat
        initializeExerciseCoaching();
        
        // Intent'ten egzersiz verilerini al
        handleIntent();
    }
    
    /**
     * Coaching overlay'ini ana kamera layout'una ekler
     */
    private void setupCoachingOverlay() {
        try {
            // Ana layout'u bul (CameraXLivePreviewActivity'deki root layout)
            FrameLayout rootLayout = findViewById(android.R.id.content);
            
            // Coaching overlay'ini inflate et
            LayoutInflater inflater = LayoutInflater.from(this);
            coachingOverlay = inflater.inflate(R.layout.coaching_overlay, null);
            
            // Overlay'i ana layout'a ekle
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            );
            rootLayout.addView(coachingOverlay, params);
            
            // UI elementlerini bağla
            tvExerciseName = coachingOverlay.findViewById(R.id.tv_exercise_name);
            tvRepetitionCount = coachingOverlay.findViewById(R.id.tv_repetition_count);
            tvFeedbackMessage = coachingOverlay.findViewById(R.id.tv_feedback_message);
            tvFeedbackTitle = coachingOverlay.findViewById(R.id.tv_feedback_title);
            tvFeedbackEmoji = coachingOverlay.findViewById(R.id.tv_feedback_emoji);
            tvAccuracyPercentage = coachingOverlay.findViewById(R.id.tv_accuracy_percentage);
            tvTimer = coachingOverlay.findViewById(R.id.tv_timer);
            tvFpsInfo = coachingOverlay.findViewById(R.id.tv_fps_info);
            tvPoseQuality = coachingOverlay.findViewById(R.id.tv_pose_quality);
            tvMovementFlow = coachingOverlay.findViewById(R.id.tv_movement_flow);
            tvStability = coachingOverlay.findViewById(R.id.tv_stability);
            tvBestAccuracy = coachingOverlay.findViewById(R.id.tv_best_accuracy);
            tvAvgAccuracy = coachingOverlay.findViewById(R.id.tv_avg_accuracy);
            tvExerciseInstructions = coachingOverlay.findViewById(R.id.tv_exercise_instructions);
            progressAccuracy = coachingOverlay.findViewById(R.id.progress_accuracy);
            btnStopCoaching = coachingOverlay.findViewById(R.id.btn_stop_coaching);
            
            // Performance tracking başlat
            startTime = System.currentTimeMillis();
            updateTimer();
            
            // Stop butonu click listener'ı
            btnStopCoaching.setOnClickListener(v -> stopCoachingAndFinish());
            
            Log.d(TAG, "✅ Coaching overlay başarıyla eklendi");
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Coaching overlay kurulumunda hata", e);
        }
    }
    
    /**
     * Exercise coaching sistemini başlatır
     */
    private void initializeExerciseCoaching() {
        try {
            // Exercise coach processor'ı oluştur
            exerciseCoachProcessor = new ExerciseCoachProcessor(this, null);
            
            // Adapter'a processor'ı bağla
            PoseDetectorToExerciseAdapter.setExerciseCoachProcessor(exerciseCoachProcessor);
            
            // Event listener'ı ayarla
            exerciseCoachProcessor.onListen(null, new EventChannel.EventSink() {
                @Override
                public void success(Object event) {
                    runOnUiThread(() -> handleCoachingEvent(event));
                }
                
                @Override
                public void error(String errorCode, String errorMessage, Object errorDetails) {
                    Log.e(TAG, "Coaching event error: " + errorMessage);
                }
                
                @Override
                public void endOfStream() {
                    Log.d(TAG, "Coaching event stream ended");
                }
            });
            
            // Intent'ten gelen egzersiz verilerini al ve başlat
            Map<String, Object> exerciseData = getExerciseDataFromIntent();
            exerciseCoachProcessor.startExercise(exerciseData);
            
            // Adapter'ı etkinleştir
            PoseDetectorToExerciseAdapter.setEnabled(true);
            
            Log.d(TAG, "✅ Exercise coaching başarıyla başlatıldı");
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Exercise coaching başlatma hatası", e);
        }
    }
    
    /**
     * Intent'ten gelen egzersiz verilerini işler
     */
    private void handleIntent() {
        Intent intent = getIntent();
        if (intent != null) {
            String exerciseName = intent.getStringExtra("exercise_name");
            if (exerciseName != null) {
                currentExerciseName = exerciseName;
                if (tvExerciseName != null) {
                    tvExerciseName.setText(exerciseName);
                }
            }
        }
    }
    
    /**
     * Intent'ten egzersiz verilerini alır ve Map olarak döndürür
     */
    private Map<String, Object> getExerciseDataFromIntent() {
        Intent intent = getIntent();
        Map<String, Object> exerciseData = new HashMap<>();
        
        if (intent != null) {
            // Temel bilgiler
            exerciseData.put("name", intent.getStringExtra("exercise_name") != null ? 
                intent.getStringExtra("exercise_name") : "Egzersiz");
            exerciseData.put("type", intent.getStringExtra("exercise_type") != null ? 
                intent.getStringExtra("exercise_type") : "default");
            exerciseData.put("description", intent.getStringExtra("exercise_description") != null ? 
                intent.getStringExtra("exercise_description") : "");
            exerciseData.put("duration", intent.getStringExtra("exercise_duration") != null ? 
                intent.getStringExtra("exercise_duration") : "5 dk");
            exerciseData.put("difficulty", intent.getStringExtra("exercise_difficulty") != null ? 
                intent.getStringExtra("exercise_difficulty") : "Kolay");
            
            // Instructions
            String instructionsString = intent.getStringExtra("exercise_instructions");
            if (instructionsString != null && !instructionsString.isEmpty()) {
                String[] instructionsArray = instructionsString.split("\\|");
                java.util.List<String> instructionsList = java.util.Arrays.asList(instructionsArray);
                exerciseData.put("instructions", instructionsList);
            } else {
                exerciseData.put("instructions", new java.util.ArrayList<String>());
            }
            
            Log.d(TAG, "🎯 Intent'ten alınan egzersiz verisi: " + exerciseData.get("name") + " (" + exerciseData.get("type") + ")");
            
            // UI'ya talimatları gönder
            updateExerciseInstructions(exerciseData);
            
        } else {
            // Fallback - varsayılan veri
            exerciseData.put("name", "Boyun Döndürme Egzersizi");
            exerciseData.put("type", "neck_rotation_mobilization");
            exerciseData.put("description", "Boyunuzu yavaşça sağa ve sola çevirin");
            exerciseData.put("duration", "5 dk");
            exerciseData.put("difficulty", "Kolay");
            exerciseData.put("instructions", new java.util.ArrayList<String>());
            
            Log.w(TAG, "⚠️ Intent null, varsayılan egzersiz verisi kullanılıyor");
        }
        
        return exerciseData;
    }
    
    /**
     * Egzersiz talimatlarını UI'da gösterir
     */
    private void updateExerciseInstructions(Map<String, Object> exerciseData) {
        if (tvExerciseInstructions == null) return;
        
        StringBuilder instructionsText = new StringBuilder();
        
        // Egzersiz açıklaması
        String description = (String) exerciseData.get("description");
        if (description != null && !description.isEmpty()) {
            instructionsText.append("📝 ").append(description).append("\n\n");
        }
        
        // Adım adım talimatlar
        Object instructionsObj = exerciseData.get("instructions");
        if (instructionsObj instanceof java.util.List) {
            java.util.List<String> instructionsList = (java.util.List<String>) instructionsObj;
            if (!instructionsList.isEmpty()) {
                instructionsText.append("📋 ADIMLAR:\n");
                for (int i = 0; i < instructionsList.size(); i++) {
                    instructionsText.append(String.format("%d. %s\n", i + 1, instructionsList.get(i)));
                }
                instructionsText.append("\n");
            }
        }
        
        // Egzersiz detayları
        String duration = (String) exerciseData.get("duration");
        String difficulty = (String) exerciseData.get("difficulty");
        if (duration != null || difficulty != null) {
            instructionsText.append("ℹ️ BİLGİLER:\n");
            if (duration != null) {
                instructionsText.append("⏱️ Süre: ").append(duration).append("\n");
            }
            if (difficulty != null) {
                instructionsText.append("📊 Zorluk: ").append(difficulty).append("\n");
            }
        }
        
        // Güvenlik önerileri
        instructionsText.append("\n⚠️ GÜVENLİK:\n");
        instructionsText.append("• Ağrı hissederseniz durun\n");
        instructionsText.append("• Yavaş ve kontrollü hareket edin\n");
        instructionsText.append("• Düzenli nefes alın");
        
        runOnUiThread(() -> {
            tvExerciseInstructions.setText(instructionsText.toString());
            Log.d(TAG, "📋 Egzersiz talimatları güncellendi");
        });
    }
    
    /**
     * ExerciseCoachProcessor'dan gelen event'leri işler
     */
    private void handleCoachingEvent(Object event) {
        if (event instanceof Map) {
            Map<String, Object> eventMap = (Map<String, Object>) event;
            String eventType = (String) eventMap.get("type");
            Object data = eventMap.get("data");
            
            Log.d(TAG, "📨 Event alındı - Type: " + eventType + ", Data: " + data);
            
            switch (eventType) {
                case "feedback":
                    if (data instanceof Map) {
                        Map<String, Object> feedbackData = (Map<String, Object>) data;
                        String message = (String) feedbackData.get("message");
                        if (message != null) {
                            updateFeedbackMessage(message);
                            Log.d(TAG, "💬 Feedback UI'da güncellendi: " + message);
                        }
                    }
                    break;
                    
                case "accuracy":
                    if (data instanceof Map) {
                        Map<String, Object> accuracyData = (Map<String, Object>) data;
                        Double accuracy = (Double) accuracyData.get("value");
                        if (accuracy != null) {
                            updateAccuracy(accuracy);
                        }
                    } else if (eventMap.get("value") instanceof Double) {
                        // Fallback - direkt value
                        Double accuracy = (Double) eventMap.get("value");
                        updateAccuracy(accuracy);
                    }
                    break;
                    
                case "repetition":
                    if (data instanceof Map) {
                        Map<String, Object> repData = (Map<String, Object>) data;
                        Integer count = (Integer) repData.get("count");
                        if (count != null) {
                            updateRepetitionCount(count);
                        }
                    } else if (eventMap.get("count") instanceof Integer) {
                        // Fallback - direkt count
                        Integer count = (Integer) eventMap.get("count");
                        updateRepetitionCount(count);
                    }
                    break;
                    
                case "pose_data":
                    // Pose datası alındı - şu an için ekstra bir şey yapmıyoruz
                    // İleride pose skeleton overlay eklemek için kullanılabilir
                    break;
                    
                default:
                    Log.w(TAG, "⚠️ Bilinmeyen event tipi: " + eventType);
                    break;
            }
        }
    }
    
    /**
     * Feedback mesajını günceller
     */
    private void updateFeedbackMessage(String message) {
        if (tvFeedbackMessage != null && message != null) {
            tvFeedbackMessage.setText(message);
            
            // Feedback'e göre title ve emoji güncelle
            updateFeedbackVisuals(message);
            
            Log.d(TAG, "💬 Feedback güncellendi: " + message);
        }
    }
    
    /**
     * Doğruluk skorunu günceller
     */
    private void updateAccuracy(double accuracy) {
        if (progressAccuracy != null && tvAccuracyPercentage != null) {
            int percentage = (int) (accuracy * 100);
            progressAccuracy.setProgress(percentage);
            tvAccuracyPercentage.setText(percentage + "%");
            
            // Performance tracking
            frameCount++;
            totalAccuracy += accuracy;
            if (accuracy > bestAccuracy) {
                bestAccuracy = accuracy;
                updateBestAccuracy();
            }
            updateAverageAccuracy();
            updatePoseQuality(accuracy);
            
            // FPS güncelleme
            updateFPS();
            
            Log.d(TAG, "📊 Accuracy güncellendi: " + percentage + "%");
        }
    }
    
    /**
     * Tekrar sayısını günceller
     */
    private void updateRepetitionCount(int count) {
        if (tvRepetitionCount != null) {
            tvRepetitionCount.setText(String.valueOf(count));
            Log.d(TAG, "🔢 Tekrar sayısı güncellendi: " + count);
        }
    }
    
    /**
     * Feedback görsellerini günceller (emoji ve title)
     */
    private void updateFeedbackVisuals(String message) {
        if (tvFeedbackTitle == null || tvFeedbackEmoji == null) return;
        
        String title = "Devam Edin";
        String emoji = "🔄";
        
        if (message.contains("Mükemmel") || message.contains("Harika")) {
            title = "Mükemmel!";
            emoji = "🎯";
        } else if (message.contains("İyi")) {
            title = "İyi Gidiyor";
            emoji = "👍";
        } else if (message.contains("DİKKAT") || message.contains("Dikkat")) {
            title = "Dikkat!";
            emoji = "⚠️";
        } else if (message.contains("yavaşça")) {
            title = "Yavaş Hareket";
            emoji = "🐌";
        }
        
        tvFeedbackTitle.setText(title);
        tvFeedbackEmoji.setText(emoji);
    }
    
    /**
     * Timer'ı günceller
     */
    private void updateTimer() {
        if (tvTimer == null) return;
        
        Runnable timerRunnable = new Runnable() {
            @Override
            public void run() {
                long elapsedTime = System.currentTimeMillis() - startTime;
                int seconds = (int) (elapsedTime / 1000) % 60;
                int minutes = (int) (elapsedTime / (1000 * 60));
                
                String timeString = String.format("%02d:%02d", minutes, seconds);
                tvTimer.setText(timeString);
                
                // Her saniye tekrar çağır
                if (tvTimer != null) {
                    tvTimer.postDelayed(this, 1000);
                }
            }
        };
        tvTimer.post(timerRunnable);
    }
    
    /**
     * FPS bilgisini günceller
     */
    private void updateFPS() {
        if (tvFpsInfo == null) return;
        
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastFpsUpdate > 1000) { // Her saniye güncelle
            double fps = frameCount / ((currentTime - lastFpsUpdate) / 1000.0);
            tvFpsInfo.setText(String.format("FPS: %.0f", fps));
            frameCount = 0;
            lastFpsUpdate = currentTime;
        }
    }
    
    /**
     * Poz kalitesini günceller
     */
    private void updatePoseQuality(double accuracy) {
        if (tvPoseQuality == null) return;
        
        String quality;
        if (accuracy > 0.8) {
            quality = "Mükemmel";
        } else if (accuracy > 0.6) {
            quality = "İyi";
        } else if (accuracy > 0.4) {
            quality = "Orta";
        } else {
            quality = "Kötü";
        }
        
        tvPoseQuality.setText(quality);
        
        // Movement flow ve stability'yi de güncelle
        if (tvMovementFlow != null) {
            tvMovementFlow.setText(accuracy > 0.7 ? "Akıcı" : "Kesikli");
        }
        if (tvStability != null) {
            tvStability.setText(accuracy > 0.75 ? "Stabil" : "Dengesiz");
        }
    }
    
    /**
     * En iyi accuracy'yi günceller
     */
    private void updateBestAccuracy() {
        if (tvBestAccuracy != null) {
            tvBestAccuracy.setText(String.format("En İyi: %.0f%%", bestAccuracy * 100));
        }
    }
    
    /**
     * Ortalama accuracy'yi günceller
     */
    private void updateAverageAccuracy() {
        if (tvAvgAccuracy != null && frameCount > 0) {
            double avgAccuracy = totalAccuracy / frameCount;
            tvAvgAccuracy.setText(String.format("Ortalama: %.0f%%", avgAccuracy * 100));
        }
    }
    
    /**
     * Coaching'i durdur ve ekranı kapat
     */
    private void stopCoachingAndFinish() {
        Log.d(TAG, "🛑 Coaching durduruluyor");
        
        if (exerciseCoachProcessor != null) {
            exerciseCoachProcessor.stopExercise();
        }
        
        PoseDetectorToExerciseAdapter.setEnabled(false);
        
        finish();
    }
    
    @Override
    protected void onDestroy() {
        // Coaching sistemini temizle
        if (exerciseCoachProcessor != null) {
            exerciseCoachProcessor.stopExercise();
        }
        PoseDetectorToExerciseAdapter.setEnabled(false);
        
        Log.d(TAG, "🧹 ExerciseCoachingActivity destroyed");
        
        // Parent'ın onDestroy'ını çağır
        super.onDestroy();
    }
} 