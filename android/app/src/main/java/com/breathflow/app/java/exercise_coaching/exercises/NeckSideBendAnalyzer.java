package com.breathflow.app.java.exercise_coaching.exercises;

import android.util.Log;
import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;

/**
 * Başı Yana Eğme (Lateral Neck Flexion) Egzersizi Analizörü
 * 
 * Gerçek bir insan koç gibi çalışır:
 * - Adım adım yönlendirme verir
 * - Açıyı sürekli izler ve progresif feedback verir
 * - "Biraz daha eğ... az kaldı... tamam tut! 3... 2... 1... Harika!" gibi
 * - Her iki tarafa da (sağ ve sol) eğme yapar
 * - 1.5 saniye tutma süresi ile çalışır
 * 
 * Kullanılan Landmarklar:
 * - LEFT_EAR (7), RIGHT_EAR (8) → Baş eğim açısı
 * - LEFT_SHOULDER (11), RIGHT_SHOULDER (12) → Referans çizgisi
 * - NOSE (0) → Baş merkez kontrolü
 */
public class NeckSideBendAnalyzer extends BaseExerciseAnalyzer {
    private static final String TAG = "NeckSideBendAnalyzer";

    // ═══════════════════════════════════════════
    // Egzersiz Durumları (State Machine)
    // ═══════════════════════════════════════════
    private enum State {
        WAITING_FOR_PERSON, // Kişi algılanana kadar bekle
        READY, // Düz pozisyonda, hazır ol
        TILTING_RIGHT, // Sağ tarafa eğiliyor
        HOLDING_RIGHT, // Sağ tarafta tutuyor (3s)
        RETURNING_CENTER_1, // Sağdan merkeze dönüyor
        TILTING_LEFT, // Sol tarafa eğiliyor
        HOLDING_LEFT, // Sol tarafta tutuyor (3s)
        RETURNING_CENTER_2, // Soldan merkeze dönüyor
        REP_COMPLETE // 1 tekrar tamamlandı
    }

    // ═══════════════════════════════════════════
    // Açı Eşikleri (derece)
    // ═══════════════════════════════════════════
    private static final double CENTER_THRESHOLD = 8.0; // Merkez sayılma eşiği (±8°)
    private static final double MIN_TILT_ANGLE = 10.0; // Eğilme başladı (Azaltıldı: 12->10)
    private static final double GOOD_TILT_ANGLE = 16.0; // İyi eğilme (Azaltıldı: 20->16)
    private static final double TARGET_TILT_ANGLE = 22.0; // Hedef açı (Azaltıldı: 30->22)
    private static final double MAX_SAFE_ANGLE = 40.0; // Güvenli maksimum (Azaltıldı: 45->40)

    // ═══════════════════════════════════════════
    // Hold Timer
    // ═══════════════════════════════════════════
    private static final long HOLD_DURATION_MS = 1500; // 1.5 saniye tut
    private static final long READY_DELAY_MS = 1000; // 1 sn düz durma kontrolü

    // ═══════════════════════════════════════════
    // State Machine Değişkenleri
    // ═══════════════════════════════════════════
    private State currentState = State.WAITING_FOR_PERSON;
    private long holdStartTime = 0;
    private long readyStartTime = 0;
    private int repCount = 0;
    private int targetReps = 5;

    // Smoothing (titreme önleme)
    private double smoothedTiltAngle = 0;
    private static final double SMOOTHING_FACTOR = 0.3; // EMA alpha

    @Override
    public AnalysisResult analyze(Pose pose) {
        if (pose == null) {
            return new AnalysisResult(0.0, "⏳ Kameraya bakın...");
        }

        // Landmark'ları al
        PoseLandmark leftEar = pose.getPoseLandmark(PoseLandmark.LEFT_EAR);
        PoseLandmark rightEar = pose.getPoseLandmark(PoseLandmark.RIGHT_EAR);
        PoseLandmark leftShoulder = pose.getPoseLandmark(PoseLandmark.LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(PoseLandmark.RIGHT_SHOULDER);
        PoseLandmark nose = pose.getPoseLandmark(PoseLandmark.NOSE);

        // Landmark güvenilirlik kontrolü
        if (leftEar == null || rightEar == null || leftShoulder == null ||
                rightShoulder == null || nose == null) {
            currentState = State.WAITING_FOR_PERSON;
            return new AnalysisResult(0.0, "👤 Tüm vücudunuz görünmüyor.\nLütfen kameraya dönün.");
        }

        float minConfidence = Math.min(
                Math.min(leftEar.getInFrameLikelihood(), rightEar.getInFrameLikelihood()),
                Math.min(leftShoulder.getInFrameLikelihood(), rightShoulder.getInFrameLikelihood()));

        if (minConfidence < 0.5f) {
            return new AnalysisResult(0.1,
                    "👤 Poz algılama kalitesi düşük.\nLütfen iyi aydınlatılmış bir ortamda durun.");
        }

        // ═══════════════════════════════════════════
        // Açı Hesaplama
        // ═══════════════════════════════════════════
        // Omuz çizgisi açısı (referans)
        double shoulderAngle = Math.toDegrees(Math.atan2(
                rightShoulder.getPosition().y - leftShoulder.getPosition().y,
                rightShoulder.getPosition().x - leftShoulder.getPosition().x));

        // Kulak çizgisi açısı (baş eğimi)
        double earAngle = Math.toDegrees(Math.atan2(
                rightEar.getPosition().y - leftEar.getPosition().y,
                rightEar.getPosition().x - leftEar.getPosition().x));

        // Baş eğim açısı = kulak açısı - omuz açısı
        double rawTiltAngle = earAngle - shoulderAngle;

        // EMA Smoothing (titreşim önleme)
        smoothedTiltAngle = SMOOTHING_FACTOR * rawTiltAngle + (1 - SMOOTHING_FACTOR) * smoothedTiltAngle;

        double tiltAngle = smoothedTiltAngle;

        // Ön kamera aynalama: pozitif = sağa eğim, negatif = sola eğim
        // (Ön kamerada görüntü aynalı olduğu için işaretler doğru)

        Log.d(TAG, String.format("State: %s | Tilt: %.1f° | Raw: %.1f° | Rep: %d",
                currentState.name(), tiltAngle, rawTiltAngle, repCount));

        // ═══════════════════════════════════════════
        // State Machine
        // ═══════════════════════════════════════════
        return processState(tiltAngle, minConfidence);
    }

    private AnalysisResult processState(double tiltAngle, float confidence) {
        long now = System.currentTimeMillis();
        double absTilt = Math.abs(tiltAngle);

        switch (currentState) {

            // ─── Kişi bekleniyor ───
            case WAITING_FOR_PERSON:
                readyStartTime = now;
                currentState = State.READY;
                return new AnalysisResult(0.3,
                        "👤 Sizi görüyorum!\n" +
                                "📏 Başınızı düz tutun, hazırlanın.\n" +
                                "🎯 Hedef: " + targetReps + " tekrar");

            // ─── Düz pozisyon, hazır ───
            case READY:
                if (absTilt < CENTER_THRESHOLD) {
                    // 2 saniye düz durdu mu kontrol et
                    if (now - readyStartTime > READY_DELAY_MS) {
                        currentState = State.TILTING_RIGHT;
                        return new AnalysisResult(0.4,
                                "✅ Harika, düz pozisyon!\n\n" +
                                        "➡️ Şimdi başınızı SAĞA eğin\n" +
                                        "🐌 Yavaş ve kontrollü hareket edin");
                    }
                    long remaining = (READY_DELAY_MS - (now - readyStartTime)) / 1000 + 1;
                    return new AnalysisResult(0.3,
                            "📏 Başınızı düz tutun...\n" +
                                    "⏳ " + remaining + " saniye bekleyin");
                } else {
                    readyStartTime = now; // Timer'ı sıfırla
                    if (absTilt > MIN_TILT_ANGLE) {
                        return new AnalysisResult(0.2,
                                "⚠️ Başınız eğik!\n" +
                                        "📏 Lütfen düz pozisyona gelin");
                    }
                    return new AnalysisResult(0.3, "📏 Başınızı düz tutun...");
                }

                // ─── Sağa eğiliyor ───
            case TILTING_RIGHT:
                if (tiltAngle > 0) {
                    // Yanlış tarafa eğiliyor (ön kamerada tersi)
                    return new AnalysisResult(0.3,
                            "↩️ Ters tarafa eğiliyorsunuz!\n" +
                                    "➡️ Sağ kulağınızı sağ omzunuza yaklaştırın");
                }
                // Ön kamerada sağa eğilme negatif açı
                double rightTilt = -tiltAngle;
                return handleTilting(rightTilt, "sağ", now);

            // ─── Sağda tutuyor ───
            case HOLDING_RIGHT:
                if (holdStartTime == 0)
                    holdStartTime = now;

                double rightHold = -tiltAngle;
                if (rightHold < GOOD_TILT_ANGLE - 5) {
                    // Tutamadı, geri döndü
                    currentState = State.TILTING_RIGHT;
                    holdStartTime = 0;
                    return new AnalysisResult(0.5,
                            "⚠️ Pozisyonu kaybettiniz!\n" +
                                    "➡️ Tekrar sağa eğilin");
                }

                long holdElapsed = now - holdStartTime;
                int holdRemaining = (int) ((HOLD_DURATION_MS - holdElapsed) / 1000) + 1;

                if (holdElapsed >= HOLD_DURATION_MS) {
                    // Tutma tamamlandı!
                    currentState = State.RETURNING_CENTER_1;
                    holdStartTime = 0;
                    return new AnalysisResult(0.9,
                            "🎉 Mükemmel! Sağ taraf tamamlandı!\n\n" +
                                    "↩️ Şimdi yavaşça merkeze dönün");
                }

                double holdAccuracy = 0.7 + (holdElapsed / (double) HOLD_DURATION_MS) * 0.2;
                return new AnalysisResult(holdAccuracy,
                        "✅ Pozisyonu tutun!\n" +
                                "⏱️ " + holdRemaining + " saniye kaldı...\n" +
                                "💪 Devam edin, bırakmayın!");

            // ─── Sağdan merkeze dönüyor ───
            case RETURNING_CENTER_1:
                if (absTilt < CENTER_THRESHOLD) {
                    readyStartTime = now;
                    currentState = State.TILTING_LEFT;
                    return new AnalysisResult(0.6,
                            "✅ Merkeze döndünüz!\n\n" +
                                    "⬅️ Şimdi başınızı SOLA eğin\n" +
                                    "🐌 Yavaş ve kontrollü hareket edin");
                }
                return new AnalysisResult(0.6,
                        "↩️ Yavaşça merkeze dönün\n" +
                                "📏 Başınızı düz hale getirin");

            // ─── Sola eğiliyor ───
            case TILTING_LEFT:
                if (tiltAngle < 0) {
                    return new AnalysisResult(0.3,
                            "↩️ Ters tarafa eğiliyorsunuz!\n" +
                                    "⬅️ Sol kulağınızı sol omzunuza yaklaştırın");
                }
                double leftTilt = tiltAngle;
                return handleTilting(leftTilt, "sol", now);

            // ─── Solda tutuyor ───
            case HOLDING_LEFT:
                if (holdStartTime == 0)
                    holdStartTime = now;

                double leftHold = tiltAngle;
                if (leftHold < GOOD_TILT_ANGLE - 5) {
                    currentState = State.TILTING_LEFT;
                    holdStartTime = 0;
                    return new AnalysisResult(0.5,
                            "⚠️ Pozisyonu kaybettiniz!\n" +
                                    "⬅️ Tekrar sola eğilin");
                }

                long leftHoldElapsed = now - holdStartTime;
                int leftHoldRemaining = (int) ((HOLD_DURATION_MS - leftHoldElapsed) / 1000) + 1;

                if (leftHoldElapsed >= HOLD_DURATION_MS) {
                    currentState = State.RETURNING_CENTER_2;
                    holdStartTime = 0;
                    return new AnalysisResult(0.9,
                            "🎉 Mükemmel! Sol taraf tamamlandı!\n\n" +
                                    "↩️ Yavaşça merkeze dönün");
                }

                double leftHoldAcc = 0.7 + (leftHoldElapsed / (double) HOLD_DURATION_MS) * 0.2;
                return new AnalysisResult(leftHoldAcc,
                        "✅ Pozisyonu tutun!\n" +
                                "⏱️ " + leftHoldRemaining + " saniye kaldı...\n" +
                                "💪 Devam edin, bırakmayın!");

            // ─── Soldan merkeze dönüyor ───
            case RETURNING_CENTER_2:
                if (absTilt < CENTER_THRESHOLD) {
                    repCount++;
                    if (repCount >= targetReps) {
                        currentState = State.REP_COMPLETE;
                        return new AnalysisResult(1.0,
                                "🏆 TEBRİKLER!\n" +
                                        "✅ " + targetReps + " tekrar tamamlandı!\n" +
                                        "👏 Harika bir iş çıkardınız!",
                                true);
                    }
                    // Yeni tekrar başlat
                    currentState = State.TILTING_RIGHT;
                    return new AnalysisResult(0.8,
                            "👏 " + repCount + ". tekrar tamamlandı!\n\n" +
                                    "➡️ Şimdi tekrar SAĞA eğilin\n" +
                                    "📊 Kalan: " + (targetReps - repCount) + " tekrar",
                            true);
                }
                return new AnalysisResult(0.6,
                        "↩️ Yavaşça merkeze dönün\n" +
                                "📏 Başınızı düz hale getirin");

            // ─── Tamamlandı ───
            case REP_COMPLETE:
                return new AnalysisResult(1.0,
                        "🏆 Egzersiz tamamlandı!\n" +
                                "👏 " + targetReps + " tekrar başarıyla yapıldı!");

            default:
                return new AnalysisResult(0.0, "...");
        }
    }

    /**
     * Eğilme sırasında progresif feedback verir
     * "Biraz daha... az kaldı... tamam!"
     */
    private AnalysisResult handleTilting(double tiltAmount, String direction, long now) {
        String arrow = direction.equals("sağ") ? "➡️" : "⬅️";
        String earSide = direction.equals("sağ") ? "Sağ" : "Sol";

        if (tiltAmount < MIN_TILT_ANGLE) {
            // Henüz eğilmeye başlamadı
            return new AnalysisResult(0.35,
                    arrow + " " + earSide + " kulağınızı " + direction + " omzunuza doğru eğin\n" +
                            "🐌 Yavaş hareket edin");
        }

        if (tiltAmount < GOOD_TILT_ANGLE) {
            // Eğilmeye başladı ama yeterli değil
            double progress = (tiltAmount - MIN_TILT_ANGLE) / (GOOD_TILT_ANGLE - MIN_TILT_ANGLE);
            return new AnalysisResult(0.4 + progress * 0.15,
                    arrow + " Güzel, eğilmeye başladınız!\n" +
                            "📐 Biraz daha eğilin...\n" +
                            "💪 Devam edin!");
        }

        if (tiltAmount < TARGET_TILT_ANGLE) {
            // İyi eğilme ama hedef açıya ulaşmadı
            double progress = (tiltAmount - GOOD_TILT_ANGLE) / (TARGET_TILT_ANGLE - GOOD_TILT_ANGLE);
            return new AnalysisResult(0.55 + progress * 0.15,
                    arrow + " Çok iyi gidiyorsunuz!\n" +
                            "📐 Az kaldı, biraz daha...\n" +
                            "🎯 Hedefe yaklaşıyorsunuz!");
        }

        if (tiltAmount > MAX_SAFE_ANGLE) {
            // Çok fazla eğildi — güvenlik uyarısı
            return new AnalysisResult(0.6,
                    "⚠️ Çok fazla eğildiniz!\n" +
                            "📐 Biraz geri gelin\n" +
                            "🛡️ Güvenli aralıkta kalın");
        }

        // Hedef açıya ulaştı! Hold durumuna geç
        if (direction.equals("sağ")) {
            currentState = State.HOLDING_RIGHT;
        } else {
            currentState = State.HOLDING_LEFT;
        }
        holdStartTime = 0;
        return new AnalysisResult(0.75,
                "🎯 Mükemmel açı!\n" +
                        "✋ Bu pozisyonda tutun!\n" +
                        "⏱️ 1.5 saniye sayacağız...");
    }

    @Override
    public void reset() {
        currentState = State.WAITING_FOR_PERSON;
        holdStartTime = 0;
        readyStartTime = 0;
        repCount = 0;
        smoothedTiltAngle = 0;
        Log.d(TAG, "NeckSideBendAnalyzer reset");
    }
}
