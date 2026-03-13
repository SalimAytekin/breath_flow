package com.breathflow.app.java.exercise_coaching.exercises;

import android.util.Log;
import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * JSON rule tabanlı generic egzersiz analizörü.
 *
 * State Machine:
 * - IDLE: Kişi algılanmıyor veya güvenilirlik düşük → sabit mesaj
 * - POSITIONING: Kişi görünüyor ama tam pozisyonda değil → pozisyon yönergesi
 * - EXERCISING: Tam pozisyonda, egzersize başlayabilir → koçluk mesajları
 *
 * Feedback Stabilizasyonu:
 * - Her state için sabit feedback mesajları (sürekli değişmez)
 * - State değişmeden feedback değişmez
 * - Hareket algılama ile exercise state'e otomatik geçiş
 */
public class GenericExerciseAnalyzer extends BaseExerciseAnalyzer {
    private static final String TAG = "GenericExerciseAnalyzer";

    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private enum State {
        IDLE, // Kişi algılanmıyor
        POSITIONING, // Kişi görünüyor ama tam pozisyonda değil
        EXERCISING // Egzersiz yapılıyor
    }

    private final String exerciseName;
    private final String exerciseType;
    private final Map<String, Object> rules;
    private final List<Map<String, Object>> feedbackRules;

    // State tracking
    private State currentState = State.IDLE;
    private long stateEntryTime = 0;
    private long exerciseStartTime = 0;

    // Hareket algılama
    private final Map<Integer, float[]> previousPositions = new HashMap<>();
    private double smoothedMovementSpeed = 0;
    private static final double MOVEMENT_ALPHA = 0.3; // EMA alpha
    private static final double ACTIVE_MOVEMENT_THRESHOLD = 5.0; // px/frame — üstü = hareket var
    private static final double MIN_CONFIDENCE_FOR_POSITIONING = 0.4;
    private static final double MIN_CONFIDENCE_FOR_EXERCISING = 0.6;

    // Positioning süre kontrolü (sabit durma)
    private static final long POSITIONING_STABLE_MS = 1500; // 1.5 saniye sabit dur
    private long positioningStableStart = 0;

    public GenericExerciseAnalyzer(String exerciseName, String exerciseType,
            Map<String, Object> rules,
            List<Map<String, Object>> feedbackRules) {
        this.exerciseName = exerciseName != null ? exerciseName : "Egzersiz";
        this.exerciseType = exerciseType != null ? exerciseType : "generic";
        this.rules = rules;
        this.feedbackRules = feedbackRules;
        Log.d(TAG, "GenericExerciseAnalyzer created for: " + this.exerciseName);
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        if (pose == null || pose.getAllPoseLandmarks().isEmpty()) {
            transitionTo(State.IDLE);
            return new AnalysisResult(0.0, "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.");
        }

        // Ortalama güvenilirlik
        double avgConfidence = calculateAverageConfidence(pose);

        // Hareket hızı hesapla
        double movementSpeed = calculateMovementSpeed(pose);
        smoothedMovementSpeed = MOVEMENT_ALPHA * movementSpeed + (1 - MOVEMENT_ALPHA) * smoothedMovementSpeed;

        // State machine
        return processState(pose, avgConfidence, smoothedMovementSpeed);
    }

    private AnalysisResult processState(Pose pose, double avgConfidence, double movementSpeed) {
        long now = System.currentTimeMillis();

        switch (currentState) {

            case IDLE:
                if (avgConfidence >= MIN_CONFIDENCE_FOR_POSITIONING) {
                    transitionTo(State.POSITIONING);
                    positioningStableStart = now;
                    return new AnalysisResult(0.25,
                            "👤 Sizi görüyorum!\n" +
                                    "📏 Lütfen düz durun ve hazırlanın.\n" +
                                    "🎯 " + exerciseName + " için hazırlanıyoruz.");
                }
                return new AnalysisResult(0.0,
                        "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.");

            case POSITIONING:
                if (avgConfidence < MIN_CONFIDENCE_FOR_POSITIONING) {
                    transitionTo(State.IDLE);
                    return new AnalysisResult(0.0,
                            "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.");
                }

                if (avgConfidence >= MIN_CONFIDENCE_FOR_EXERCISING) {
                    // Hareketsiz mi kontrol et
                    if (movementSpeed < ACTIVE_MOVEMENT_THRESHOLD) {
                        if (positioningStableStart == 0) {
                            positioningStableStart = now;
                        }
                        long stableTime = now - positioningStableStart;
                        if (stableTime >= POSITIONING_STABLE_MS) {
                            transitionTo(State.EXERCISING);
                            exerciseStartTime = now;
                            return new AnalysisResult(0.5,
                                    "✅ Harika pozisyon!\n\n" +
                                            "▶️ " + exerciseName + " başlıyor!\n" +
                                            "💪 Koçunuz hazır, başlayabilirsiniz.");
                        }
                        long remaining = (POSITIONING_STABLE_MS - stableTime) / 1000 + 1;
                        return new AnalysisResult(0.35,
                                "📏 Güzel, pozisyonunuz iyi.\n" +
                                        "⏳ " + remaining + " saniye sabit durun...");
                    } else {
                        positioningStableStart = 0; // Timer sıfırla
                        return new AnalysisResult(0.3,
                                "📏 Lütfen düz ve sabit durun.\n" +
                                        "🧘 Hareket etmeyin, pozisyonunuzu koruyun.");
                    }
                }

                return new AnalysisResult(0.25,
                        "📏 Lütfen tüm vücudunuzun kamerada görünmesini sağlayın.\n" +
                                "💡 Daha iyi sonuç için aydınlık bir ortamda durun.");

            case EXERCISING:
                if (avgConfidence < MIN_CONFIDENCE_FOR_POSITIONING) {
                    transitionTo(State.POSITIONING);
                    positioningStableStart = 0;
                    return new AnalysisResult(0.3,
                            "⚠️ Sizi kaybettik!\n" +
                                    "📏 Lütfen tekrar pozisyona gelin.");
                }

                // Egzersiz modunda — koçluk mesajları
                long exerciseElapsed = now - exerciseStartTime;
                return generateExerciseFeedback(avgConfidence, movementSpeed, exerciseElapsed);

            default:
                return new AnalysisResult(0.0, "...");
        }
    }

    /**
     * Egzersiz sırasında koçluk mesajı üret.
     * Mesajlar sabit — sadece belirli koşullarda değişir.
     */
    private AnalysisResult generateExerciseFeedback(double avgConfidence, double movementSpeed, long elapsedMs) {
        // Hareket var mı?
        boolean isMoving = movementSpeed >= ACTIVE_MOVEMENT_THRESHOLD;

        // Confidence çok yüksek ve hareket var → mükemmel
        if (avgConfidence > 0.8 && isMoving) {
            return new AnalysisResult(0.85,
                    "🎯 Mükemmel! Formunuz harika.\n" +
                            "💪 Böyle devam edin!\n" +
                            "🕐 " + formatElapsed(elapsedMs));
        }

        // Confidence iyi ve hareket var → iyi
        if (avgConfidence > 0.6 && isMoving) {
            return new AnalysisResult(0.7,
                    "👍 İyi gidiyorsunuz!\n" +
                            "📋 " + exerciseName + " yapıyorsunuz.\n" +
                            "🕐 " + formatElapsed(elapsedMs));
        }

        // Hareket yok → sabit duruyor
        if (!isMoving) {
            return new AnalysisResult(0.55,
                    "🧘 Sabit duruyorsunuz.\n" +
                            "▶️ Harekete geçebilirsiniz!\n" +
                            "🕐 " + formatElapsed(elapsedMs));
        }

        // Confidence düşük ama hareket var
        return new AnalysisResult(0.5,
                "📋 " + exerciseName + " devam ediyor.\n" +
                        "💡 Tüm vücudunuzun görünmesine dikkat edin.\n" +
                        "🕐 " + formatElapsed(elapsedMs));
    }

    private void transitionTo(State newState) {
        if (currentState != newState) {
            Log.d(TAG, "State geçişi: " + currentState + " → " + newState);
            currentState = newState;
            stateEntryTime = System.currentTimeMillis();
        }
    }

    private double calculateAverageConfidence(Pose pose) {
        double total = 0;
        int count = 0;
        for (PoseLandmark landmark : pose.getAllPoseLandmarks()) {
            total += landmark.getInFrameLikelihood();
            count++;
        }
        return count > 0 ? total / count : 0;
    }

    /**
     * İki frame arasındaki ortalama landmark yer değiştirmesi.
     */
    private double calculateMovementSpeed(Pose pose) {
        double totalDisplacement = 0;
        int count = 0;

        // Ana gövde landmark'ları
        int[] keyLandmarks = {
                PoseLandmark.NOSE,
                PoseLandmark.LEFT_SHOULDER,
                PoseLandmark.RIGHT_SHOULDER,
                PoseLandmark.LEFT_HIP,
                PoseLandmark.RIGHT_HIP,
                PoseLandmark.LEFT_ELBOW,
                PoseLandmark.RIGHT_ELBOW
        };

        for (int landmarkType : keyLandmarks) {
            PoseLandmark lm = pose.getPoseLandmark(landmarkType);
            if (lm == null || lm.getInFrameLikelihood() < 0.5f)
                continue;

            float x = lm.getPosition().x;
            float y = lm.getPosition().y;

            float[] prev = previousPositions.get(landmarkType);
            if (prev != null) {
                double dx = x - prev[0];
                double dy = y - prev[1];
                totalDisplacement += Math.sqrt(dx * dx + dy * dy);
                count++;
            }

            previousPositions.put(landmarkType, new float[] { x, y });
        }

        return count > 0 ? totalDisplacement / count : 0;
    }

    private String formatElapsed(long ms) {
        int seconds = (int) (ms / 1000) % 60;
        int minutes = (int) (ms / (1000 * 60));
        return String.format("%d:%02d", minutes, seconds);
    }

    @Override
    public void reset() {
        currentState = State.IDLE;
        stateEntryTime = 0;
        exerciseStartTime = 0;
        positioningStableStart = 0;
        smoothedMovementSpeed = 0;
        previousPositions.clear();
        Log.d(TAG, "GenericExerciseAnalyzer reset");
    }
}
