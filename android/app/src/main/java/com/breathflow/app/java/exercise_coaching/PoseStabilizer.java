package com.breathflow.app.java.exercise_coaching;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;

import java.util.HashMap;
import java.util.Map;

/**
 * Poz metriklerini stabilize eden merkezi sınıf.
 *
 * Her frame'de raw poz verisi beslenir ve şu stabilize edilmiş değerler
 * üretilir:
 * - Smoothed accuracy (EMA)
 * - Movement speed (son N frame'deki toplam yer değiştirme)
 * - Stability score (0.0 = çok hareketli, 1.0 = tamamen sabit)
 * - Fluidity score (0.0 = sarsıntılı, 1.0 = akıcı)
 */
public class PoseStabilizer {
    private static final String TAG = "PoseStabilizer";

    // EMA parametreleri
    private static final double ACCURACY_ALPHA = 0.2; // Accuracy smoothing (düşük = daha stabil)
    private static final double SPEED_ALPHA = 0.3; // Hareket hızı smoothing

    // Stabilite hesapları
    private static final int SPEED_HISTORY_SIZE = 10; // Son 10 frame'lik hız penceresi
    private static final double STABILITY_HIGH_THRESHOLD = 3.0; // px/frame — altında = stabil
    private static final double STABILITY_LOW_THRESHOLD = 15.0; // px/frame — üstünde = dengesiz

    // Smoothed değerler
    private double smoothedAccuracy = 0.5;
    private double smoothedSpeed = 0.0;
    private double stabilityScore = 0.5;
    private double fluidityScore = 0.5;

    // Hareket hızı geçmişi
    private final double[] speedHistory = new double[SPEED_HISTORY_SIZE];
    private int speedHistoryIndex = 0;
    private boolean speedHistoryFilled = false;

    // Önceki frame landmark pozisyonları
    private final Map<Integer, float[]> previousPositions = new HashMap<>();

    // Son işlenen accuracy için ivme hesabı
    private double lastAccuracyDelta = 0;

    /**
     * Yeni bir poz frame'i ile metrikleri güncelle.
     *
     * @param pose        MLKit Pose nesnesi
     * @param rawAccuracy Analizör tarafından hesaplanan ham accuracy (0.0-1.0)
     */
    public void update(Pose pose, double rawAccuracy) {
        if (pose == null)
            return;

        // 1. Accuracy EMA smoothing
        double prevAccuracy = smoothedAccuracy;
        smoothedAccuracy = ACCURACY_ALPHA * rawAccuracy + (1 - ACCURACY_ALPHA) * smoothedAccuracy;

        // Accuracy değişim ivmesi (fluidity hesabında kullanılır)
        double currentDelta = Math.abs(smoothedAccuracy - prevAccuracy);
        lastAccuracyDelta = 0.3 * currentDelta + 0.7 * lastAccuracyDelta;

        // 2. Hareket hızı hesapla
        double frameSpeed = calculateFrameSpeed(pose);
        smoothedSpeed = SPEED_ALPHA * frameSpeed + (1 - SPEED_ALPHA) * smoothedSpeed;

        // Speed history güncelle
        speedHistory[speedHistoryIndex] = smoothedSpeed;
        speedHistoryIndex = (speedHistoryIndex + 1) % SPEED_HISTORY_SIZE;
        if (speedHistoryIndex == 0)
            speedHistoryFilled = true;

        // 3. Stability score hesapla
        updateStabilityScore();

        // 4. Fluidity score hesapla
        updateFluidityScore();
    }

    /**
     * İki frame arasındaki toplam landmark yer değiştirmesini hesapla.
     * Sadece güvenilir landmark'ları (confidence > 0.5) kullan.
     */
    private double calculateFrameSpeed(Pose pose) {
        double totalDisplacement = 0;
        int count = 0;

        // Ana gövde landmark'ları — ekstremiteler hariç
        int[] keyLandmarks = {
                PoseLandmark.NOSE,
                PoseLandmark.LEFT_SHOULDER,
                PoseLandmark.RIGHT_SHOULDER,
                PoseLandmark.LEFT_HIP,
                PoseLandmark.RIGHT_HIP,
                PoseLandmark.LEFT_ELBOW,
                PoseLandmark.RIGHT_ELBOW,
                PoseLandmark.LEFT_KNEE,
                PoseLandmark.RIGHT_KNEE
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

    /**
     * Stabilite skoru: vücut ne kadar sabit duruyorsa o kadar yüksek.
     * Hareket hızındaki varyansı da hesaba katar.
     */
    private void updateStabilityScore() {
        double avgSpeed = getAverageSpeed();

        if (avgSpeed < STABILITY_HIGH_THRESHOLD) {
            // Çok düşük hareket → yüksek stabilite
            stabilityScore = 0.3 * 1.0 + 0.7 * stabilityScore;
        } else if (avgSpeed > STABILITY_LOW_THRESHOLD) {
            // Çok hızlı hareket → düşük stabilite
            stabilityScore = 0.3 * 0.2 + 0.7 * stabilityScore;
        } else {
            // Arada — lineer interpolasyon
            double t = (avgSpeed - STABILITY_HIGH_THRESHOLD)
                    / (STABILITY_LOW_THRESHOLD - STABILITY_HIGH_THRESHOLD);
            double raw = 1.0 - t * 0.8; // 1.0 → 0.2 arasında
            stabilityScore = 0.3 * raw + 0.7 * stabilityScore;
        }
    }

    /**
     * Akıcılık skoru: hareket ne kadar pürüzsüzse o kadar yüksek.
     * Accuracy değişim hızının düzgünlüğünü ölçer.
     */
    private void updateFluidityScore() {
        // Speed varyansını hesapla
        double speedVariance = getSpeedVariance();

        // Accuracy değişim hızı çok yüksekse → akıcılık düşük
        double accSmoothnessScore = Math.max(0, 1.0 - lastAccuracyDelta * 20);

        // Speed varyansı düşükse → akıcılık yüksek
        double speedSmoothnessScore = Math.max(0, 1.0 - speedVariance / 50.0);

        double rawFluidity = 0.5 * accSmoothnessScore + 0.5 * speedSmoothnessScore;
        fluidityScore = 0.2 * rawFluidity + 0.8 * fluidityScore;
    }

    private double getAverageSpeed() {
        int count = speedHistoryFilled ? SPEED_HISTORY_SIZE : speedHistoryIndex;
        if (count == 0)
            return 0;

        double sum = 0;
        for (int i = 0; i < count; i++) {
            sum += speedHistory[i];
        }
        return sum / count;
    }

    private double getSpeedVariance() {
        int count = speedHistoryFilled ? SPEED_HISTORY_SIZE : speedHistoryIndex;
        if (count < 2)
            return 0;

        double avg = getAverageSpeed();
        double sumSq = 0;
        for (int i = 0; i < count; i++) {
            double diff = speedHistory[i] - avg;
            sumSq += diff * diff;
        }
        return sumSq / count;
    }

    // ═══════════════════════════════════════════
    // Getters — Stabilize edilmiş metrikler
    // ═══════════════════════════════════════════

    /** Smoothed accuracy (0.0-1.0). Frame-bazlı dalgalanma çok azaltılmış. */
    public double getSmoothedAccuracy() {
        return smoothedAccuracy;
    }

    /** Anlık hareket hızı (px/frame, smoothed). */
    public double getMovementSpeed() {
        return smoothedSpeed;
    }

    /** Stabilite skoru (0.0 = çok hareketli, 1.0 = tamamen sabit). */
    public double getStabilityScore() {
        return stabilityScore;
    }

    /** Akıcılık skoru (0.0 = sarsıntılı, 1.0 = pürüzsüz). */
    public double getFluidityScore() {
        return fluidityScore;
    }

    /** Poz kalitesi etiketi. */
    public String getPoseQualityLabel() {
        double acc = smoothedAccuracy;
        if (acc > 0.75)
            return "Mükemmel";
        if (acc > 0.55)
            return "İyi";
        if (acc > 0.35)
            return "Orta";
        return "Düşük";
    }

    /** Stabilite etiketi. */
    public String getStabilityLabel() {
        if (stabilityScore > 0.7)
            return "Stabil";
        if (stabilityScore > 0.4)
            return "Normal";
        return "Dengesiz";
    }

    /** Akıcılık etiketi. */
    public String getFluidityLabel() {
        if (fluidityScore > 0.7)
            return "Akıcı";
        if (fluidityScore > 0.4)
            return "Normal";
        return "Kesikli";
    }

    /** Tüm state'i sıfırla. */
    public void reset() {
        smoothedAccuracy = 0.5;
        smoothedSpeed = 0.0;
        stabilityScore = 0.5;
        fluidityScore = 0.5;
        speedHistoryIndex = 0;
        speedHistoryFilled = false;
        lastAccuracyDelta = 0;
        previousPositions.clear();
        for (int i = 0; i < SPEED_HISTORY_SIZE; i++) {
            speedHistory[i] = 0;
        }
    }
}
