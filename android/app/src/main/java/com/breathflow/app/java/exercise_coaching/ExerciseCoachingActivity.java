package com.breathflow.app.java.exercise_coaching;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.FrameLayout;

import com.breathflow.app.BuildConfig;
import com.breathflow.app.R;
import com.breathflow.app.java.CameraXLivePreviewActivity;
import com.breathflow.app.java.exercise_coaching.ExerciseCoachProcessor;
import com.breathflow.app.java.exercise_coaching.PoseDetectorToExerciseAdapter;

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
    private ProgressBar progressArc;
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
                    FrameLayout.LayoutParams.MATCH_PARENT);
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
            progressArc = coachingOverlay.findViewById(R.id.progress_arc);
            btnStopCoaching = coachingOverlay.findViewById(R.id.btn_stop_coaching);

            // Performance tracking başlat
            startTime = System.currentTimeMillis();
            updateTimer();

            // Stop butonu click listener'ı
            btnStopCoaching.setOnClickListener(v -> stopCoachingAndFinish());

            Log.d(TAG, "✅ Coaching overlay başarıyla eklendi");

            // Debug modda değilse teknik bilgileri gizle
            if (!BuildConfig.DEBUG) {
                // FPS bilgisi gizle
                if (tvFpsInfo != null)
                    tvFpsInfo.setVisibility(View.GONE);

                // Sağ panel (form analizi, performans istatistikleri, talimatlar) gizle
                View rightPanel = coachingOverlay.findViewById(R.id.right_panel);
                if (rightPanel != null)
                    rightPanel.setVisibility(View.GONE);
            }

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
            exerciseData.put("name",
                    intent.getStringExtra("exercise_name") != null ? intent.getStringExtra("exercise_name")
                            : "Egzersiz");
            exerciseData.put("type",
                    intent.getStringExtra("exercise_type") != null ? intent.getStringExtra("exercise_type")
                            : "default");
            exerciseData.put("description",
                    intent.getStringExtra("exercise_description") != null
                            ? intent.getStringExtra("exercise_description")
                            : "");
            exerciseData.put("duration",
                    intent.getStringExtra("exercise_duration") != null ? intent.getStringExtra("exercise_duration")
                            : "5 dk");
            exerciseData.put("difficulty",
                    intent.getStringExtra("exercise_difficulty") != null ? intent.getStringExtra("exercise_difficulty")
                            : "Kolay");

            // Instructions
            String instructionsString = intent.getStringExtra("exercise_instructions");
            if (instructionsString != null && !instructionsString.isEmpty()) {
                String[] instructionsArray = instructionsString.split("\\|");
                java.util.List<String> instructionsList = java.util.Arrays.asList(instructionsArray);
                exerciseData.put("instructions", instructionsList);
            } else {
                exerciseData.put("instructions", new java.util.ArrayList<String>());
            }

            Log.d(TAG, "🎯 Intent'ten alınan egzersiz verisi: " + exerciseData.get("name") + " ("
                    + exerciseData.get("type") + ")");

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
        if (tvExerciseInstructions == null)
            return;

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
                        Integer count = (Integer) eventMap.get("count");
                        updateRepetitionCount(count);
                    }
                    break;

                case "stability_metrics":
                    if (data instanceof Map) {
                        Map<String, Object> metricsData = (Map<String, Object>) data;
                        updateStabilityMetrics(metricsData);
                    }
                    break;

                case "pose_data":
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
        if (!message.equals(currentFeedbackMessage)) {
            currentFeedbackMessage = message;
            
            // Fade geçiş
            tvFeedbackMessage.animate().alpha(0f).setDuration(150).withEndAction(() -> {
                tvFeedbackMessage.setText(message);
                updateFeedbackVisuals(message);
                tvFeedbackMessage.animate().alpha(1f).setDuration(150).start();
            }).start();
        }
    }

    private void updateAccuracyPercentage() {
        if (accuracyPoints.isEmpty()) {
            return;
        }

        double sum = 0;
        for (double d : accuracyPoints) {
            sum += d;
        }
        double latestAccuracy = accuracyPoints.get(accuracyPoints.size() - 1);
        double currentAccuracy = sum / accuracyPoints.size();

        if (currentAccuracy > maxAccuracy) {
            maxAccuracy = currentAccuracy;
            tvBestAccuracy.setText(String.format(Locale.getDefault(), "En İyi: %.1f%%", maxAccuracy * 100));
        }

        tvAccuracyPercentage.setText(String.format(Locale.getDefault(), "%.1f%%", currentAccuracy * 100));
        progressAccuracy.setProgress((int) (currentAccuracy * 100));

        // Ortalama hesaplama (tüm egzersiz süresince)
        double totalSum = 0;
        for (double d : allAccuracyPoints) {
            totalSum += d;
        }
        double averageAccuracy = totalSum / allAccuracyPoints.size();
        tvAvgAccuracy.setText(String.format(Locale.getDefault(), "Ortalama: %.1f%%", averageAccuracy * 100));

        // İlerleme çubuğu rengini güncelle
        if (currentAccuracy >= 0.8) {
            progressAccuracy.setProgressTintList(android.content.res.ColorStateList.valueOf(Color.GREEN));
            tvAccuracyPercentage.setTextColor(Color.GREEN);
        } else if (currentAccuracy >= 0.5) {
            progressAccuracy.setProgressTintList(android.content.res.ColorStateList.valueOf(Color.YELLOW));
            tvAccuracyPercentage.setTextColor(Color.YELLOW);
        } else {
            progressAccuracy.setProgressTintList(android.content.res.ColorStateList.valueOf(Color.RED));
            tvAccuracyPercentage.setTextColor(Color.RED);
        }
        
        // --- Progress Arc Gamification (Açı Barı) ---
        if (progressArc != null) {
            int progressValue = (int) (latestAccuracy * 100);
            
            // Smooth Animasyon
            ObjectAnimator animation = ObjectAnimator.ofInt(progressArc, "progress", progressArc.getProgress(), progressValue);
            animation.setDuration(200); // 200ms
            animation.setInterpolator(new android.view.animation.DecelerateInterpolator());
            animation.start();
            
            // Dinamik Renk
            float greenVal = Math.max(0.0f, Math.min(1.0f, (float) latestAccuracy));
            int redVal = (int) (255 * (1.0f - greenVal));
            int blueVal = (int) (255 * (1.0f - greenVal));
            int dynamicColor = Color.rgb(redVal, 255, blueVal);
            
            Drawable progressDrawable = progressArc.getProgressDrawable();
            if (progressDrawable instanceof android.graphics.drawable.LayerDrawable) {
                android.graphics.drawable.LayerDrawable layerDrawable = (android.graphics.drawable.LayerDrawable) progressDrawable;
                Drawable progressLayer = layerDrawable.findDrawableByLayerId(android.R.id.progress);
                if (progressLayer != null) {
                     progressLayer.setTint(dynamicColor);
                }
            }
            
            // Hedefe Yaklaşıldıkça Parla
            if (latestAccuracy >= 0.95) {
                progressArc.setAlpha(1.0f);
            } else {
                 progressArc.setAlpha(0.8f);
            }
        }
        
        com.breathflow.app.java.posedetector.PoseGraphic.updateAccuracy(latestAccuracy); // Çizim için Graphic'e ilet
    }

    private void updateRepetitionCount(int newCount) {
        if (repetitionCount != newCount) {
            repetitionCount = newCount;
            tvRepetitionCount.setText(String.valueOf(repetitionCount));
            
            // Pop-up Animasyonu (Scale)
            tvRepetitionCount.setTextColor(Color.GREEN);
            tvRepetitionCount.animate()
                    .scaleX(1.5f).scaleY(1.5f)
                    .setDuration(100)
                    .withEndAction(() -> {
                        tvRepetitionCount.animate()
                                .scaleX(1.0f).scaleY(1.0f)
                                .setDuration(200)
                                .withEndAction(() -> {
                                    tvRepetitionCount.setTextColor(Color.WHITE);
                                })
                                .start();
                    })
                    .start();
        }
    }
            
    private void updateFeedbackVisuals(String message) {
       // Premium & Simple vizyonu: Renk odaklı card değişimi
       String lowerMsg = message.toLowerCase(Locale.getDefault());
       
       if (lowerMsg.contains("mükemmel") || lowerMsg.contains("harika") || lowerMsg.contains("tebrikler")) {
           tvFeedbackEmoji.setText("🎉");
           tvFeedbackTitle.setText("Mükemmel!");
           tvFeedbackTitle.setTextColor(Color.WHITE);
           bottomFeedbackPanel.setBackgroundColor(Color.argb(215, 50, 150, 50)); // Koyu Yeşil (Alfa: ~85%)
       } else if (lowerMsg.contains("iyi") || lowerMsg.contains("güzel") || lowerMsg.contains("devam")) {
           tvFeedbackEmoji.setText("👍");
           tvFeedbackTitle.setText("İyi Gidiyor");
           tvFeedbackTitle.setTextColor(Color.WHITE);
           bottomFeedbackPanel.setBackgroundColor(Color.argb(215, 25, 100, 180)); // Koyu Mavi
       } else if (lowerMsg.contains("⚠️") || lowerMsg.contains("dikkat")) {
           tvFeedbackEmoji.setText("⚠️");
           tvFeedbackTitle.setText("Dikkat!");
           tvFeedbackTitle.setTextColor(Color.WHITE);
           bottomFeedbackPanel.setBackgroundColor(Color.argb(215, 200, 100, 25)); // Turuncu
       } else if (lowerMsg.contains("eğilin") || lowerMsg.contains("dönün") || lowerMsg.contains("tutun")) {
           tvFeedbackEmoji.setText("🏋️");
           tvFeedbackTitle.setText("Koç Diyor");
           tvFeedbackTitle.setTextColor(Color.parseColor("#2196F3")); // Açık Mavi
           bottomFeedbackPanel.setBackgroundColor(Color.argb(144, 0, 0, 0)); // Nötr Siyah (%56 alfa)
       } else {
           tvFeedbackEmoji.setText("🔄");
           tvFeedbackTitle.setText("Devam");
           tvFeedbackTitle.setTextColor(Color.WHITE);
           bottomFeedbackPanel.setBackgroundColor(Color.argb(144, 0, 0, 0)); // Nötr Siyah (%56 alfa)
       }
    }

    /**
     * Timer'ı günceller
     */
    private void updateTimer() {
        if (tvTimer == null)
            return;

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
        if (tvFpsInfo == null || !BuildConfig.DEBUG)
            return;

        long currentTime = System.currentTimeMillis();
        if (currentTime - lastFpsUpdate > 1000) { // Her saniye güncelle
            double fps = frameCount / ((currentTime - lastFpsUpdate) / 1000.0);
            tvFpsInfo.setText(String.format("FPS: %.0f", fps));
            frameCount = 0;
            lastFpsUpdate = currentTime;
        }
    }

    /**
     * Poz kalitesini günceller (sadece accuracy gösterimi için)
     */
    private void updatePoseQuality(double accuracy) {
        // Poz kalitesi artık stability_metrics event'inden geliyor
        // Bu metod sadece accuracy değerini görüntülemek için kullanılır
        // Gerçek kalite/stabilite/akıcılık metrikleri updateStabilityMetrics'te
        // güncellenir
    }

    /**
     * PoseStabilizer'dan gelen gerçek stabilite metriklerini günceller.
     */
    private void updateStabilityMetrics(Map<String, Object> metrics) {
        String poseQuality = (String) metrics.get("poseQuality");
        String stability = (String) metrics.get("stability");
        String fluidity = (String) metrics.get("fluidity");

        if (tvPoseQuality != null && poseQuality != null) {
            tvPoseQuality.setText(poseQuality);
        }
        if (tvStability != null && stability != null) {
            tvStability.setText(stability);
        }
        if (tvMovementFlow != null && fluidity != null) {
            tvMovementFlow.setText(fluidity);
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