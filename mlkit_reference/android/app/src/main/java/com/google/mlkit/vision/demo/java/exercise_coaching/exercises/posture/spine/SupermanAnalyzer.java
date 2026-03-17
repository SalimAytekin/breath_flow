package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Superman egzersizi için analizör
 * Sırt ve core kaslarını güçlendirmek için yapılır
 */
public class SupermanAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_ELBOW = PoseLandmark.LEFT_ELBOW;
    private static final int RIGHT_ELBOW = PoseLandmark.RIGHT_ELBOW;
    private static final int LEFT_WRIST = PoseLandmark.LEFT_WRIST;
    private static final int RIGHT_WRIST = PoseLandmark.RIGHT_WRIST;
    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int LEFT_KNEE = PoseLandmark.LEFT_KNEE;
    private static final int RIGHT_KNEE = PoseLandmark.RIGHT_KNEE;
    private static final int LEFT_ANKLE = PoseLandmark.LEFT_ANKLE;
    private static final int RIGHT_ANKLE = PoseLandmark.RIGHT_ANKLE;
    private static final int NOSE = PoseLandmark.NOSE;
    
    // Hedef değerler
    private static final double MIN_ARM_LIFT_HEIGHT = 50.0;    // Minimum kol kaldırma yüksekliği (piksel)
    private static final double MIN_LEG_LIFT_HEIGHT = 30.0;    // Minimum bacak kaldırma yüksekliği (piksel)
    private static final double TARGET_BODY_ALIGNMENT = 0.85;  // Vücut hizalaması hedefi
    private static final double LIFT_TOLERANCE = 15.0;
    
    // Başlangıç pozisyonu referansı
    private double initialShoulderY = 0.0;
    private double initialHipY = 0.0;
    private boolean hasInitialPosition = false;
    
    public SupermanAnalyzer() {
        super("Superman", "superman");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW,
                LEFT_WRIST, RIGHT_WRIST, LEFT_HIP, RIGHT_HIP, LEFT_KNEE, RIGHT_KNEE, 
                LEFT_ANKLE, RIGHT_ANKLE, NOSE)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        PoseLandmark leftElbow = pose.getPoseLandmark(LEFT_ELBOW);
        PoseLandmark rightElbow = pose.getPoseLandmark(RIGHT_ELBOW);
        PoseLandmark leftWrist = pose.getPoseLandmark(LEFT_WRIST);
        PoseLandmark rightWrist = pose.getPoseLandmark(RIGHT_WRIST);
        PoseLandmark leftHip = pose.getPoseLandmark(LEFT_HIP);
        PoseLandmark rightHip = pose.getPoseLandmark(RIGHT_HIP);
        PoseLandmark leftKnee = pose.getPoseLandmark(LEFT_KNEE);
        PoseLandmark rightKnee = pose.getPoseLandmark(RIGHT_KNEE);
        PoseLandmark leftAnkle = pose.getPoseLandmark(LEFT_ANKLE);
        PoseLandmark rightAnkle = pose.getPoseLandmark(RIGHT_ANKLE);
        PoseLandmark nose = pose.getPoseLandmark(NOSE);
        
        // İlk pozisyonu kaydet (yüzüstü yatış pozisyonu)
        if (!hasInitialPosition) {
            initialShoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
            initialHipY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
            hasInitialPosition = true;
        }
        
        // Yüzüstü pozisyon kontrolü
        boolean isInPronePosition = checkPronePosition(leftShoulder, rightShoulder, leftHip, rightHip);
        
        // Kol kaldırma miktarını hesapla
        double armLift = calculateArmLift(leftShoulder, rightShoulder, leftWrist, rightWrist);
        
        // Bacak kaldırma miktarını hesapla
        double legLift = calculateLegLift(leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle);
        
        // Kafa pozisyonu kontrolü
        double headPosition = checkHeadPosition(nose, leftShoulder, rightShoulder);
        
        // Vücut hizalaması kontrolü
        double bodyAlignment = checkBodyAlignment(leftShoulder, rightShoulder, leftHip, rightHip, 
                                                leftKnee, rightKnee);
        
        // Accuracy hesapla
        double positionAccuracy = isInPronePosition ? 1.0 : 0.3;
        double armAccuracy = calculateArmAccuracy(armLift);
        double legAccuracy = calculateLegAccuracy(legLift);
        double headAccuracy = calculateHeadAccuracy(headPosition);
        double alignmentAccuracy = calculateAlignmentAccuracy(bodyAlignment);
        
        double overallAccuracy = (positionAccuracy * 0.2 + armAccuracy * 0.3 + 
                                legAccuracy * 0.3 + headAccuracy * 0.1 + alignmentAccuracy * 0.1);
        
        // Feedback üret
        String feedback = generateFeedback(armLift, legLift, isInPronePosition, headPosition, 
                                         bodyAlignment, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü (5 saniye tutma)
        boolean isRepetitionComplete = overallAccuracy > 0.8;
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Yüzüstü pozisyonda olup olmadığını kontrol eder
     */
    private boolean checkPronePosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                     PoseLandmark leftHip, PoseLandmark rightHip) {
        // Omuzlar ve kalçalar yaklaşık aynı seviyede olmalı (yüzüstü yatış)
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double hipY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        
        double heightDifference = Math.abs(shoulderY - hipY);
        
        // Yüzüstü pozisyonda omuz-kalça yükseklik farkı az olmalı
        return heightDifference < 80.0; // 80 piksel tolerans
    }
    
    /**
     * Kol kaldırma miktarını hesaplar
     */
    private double calculateArmLift(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                   PoseLandmark leftWrist, PoseLandmark rightWrist) {
        if (initialShoulderY == 0.0) {
            return 0.0; // Henüz referans yok
        }
        
        // Mevcut omuz yüksekliği
        double currentShoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        
        // El yüksekliği
        double wristY = (leftWrist.getPosition().y + rightWrist.getPosition().y) / 2.0;
        
        // Kol kaldırma miktarı (başlangıç pozisyonuna göre)
        double shoulderLift = initialShoulderY - currentShoulderY; // Y koordinatı ters
        double wristLift = initialShoulderY - wristY;
        
        // Ortalama kaldırma miktarı
        return (shoulderLift + wristLift) / 2.0;
    }
    
    /**
     * Bacak kaldırma miktarını hesaplar
     */
    private double calculateLegLift(PoseLandmark leftHip, PoseLandmark rightHip,
                                   PoseLandmark leftKnee, PoseLandmark rightKnee,
                                   PoseLandmark leftAnkle, PoseLandmark rightAnkle) {
        if (initialHipY == 0.0) {
            return 0.0; // Henüz referans yok
        }
        
        // Mevcut kalça yüksekliği
        double currentHipY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        
        // Diz yüksekliği
        double kneeY = (leftKnee.getPosition().y + rightKnee.getPosition().y) / 2.0;
        
        // Ayak bileği yüksekliği
        double ankleY = (leftAnkle.getPosition().y + rightAnkle.getPosition().y) / 2.0;
        
        // Bacak kaldırma miktarı
        double hipLift = initialHipY - currentHipY;
        double kneeLift = initialHipY - kneeY;
        double ankleLift = initialHipY - ankleY;
        
        // Ortalama kaldırma miktarı
        return (hipLift + kneeLift + ankleLift) / 3.0;
    }
    
    /**
     * Kafa pozisyonunu kontrol eder
     */
    private double checkHeadPosition(PoseLandmark nose, PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double noseY = nose.getPosition().y;
        
        // Kafa omuzlardan yukarıda olmalı (superman pozisyonunda)
        double headLift = shoulderY - noseY; // Y koordinatı ters
        
        return Math.max(0.0, headLift);
    }
    
    /**
     * Vücut hizalamasını kontrol eder
     */
    private double checkBodyAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                    PoseLandmark leftHip, PoseLandmark rightHip,
                                    PoseLandmark leftKnee, PoseLandmark rightKnee) {
        // Sol ve sağ taraf simetrisi
        double leftSideY = (leftShoulder.getPosition().y + leftHip.getPosition().y + leftKnee.getPosition().y) / 3.0;
        double rightSideY = (rightShoulder.getPosition().y + rightHip.getPosition().y + rightKnee.getPosition().y) / 3.0;
        
        double symmetry = Math.abs(leftSideY - rightSideY);
        
        // Simetri ne kadar iyi o kadar yüksek skor
        return Math.max(0.0, 1.0 - (symmetry / 50.0)); // 50 piksel tolerans
    }
    
    /**
     * Kol kaldırma accuracy'si hesaplar
     */
    private double calculateArmAccuracy(double armLift) {
        if (armLift >= MIN_ARM_LIFT_HEIGHT) {
            return 1.0; // Mükemmel kaldırma
        } else if (armLift >= MIN_ARM_LIFT_HEIGHT * 0.7) {
            return 0.8; // İyi
        } else if (armLift >= MIN_ARM_LIFT_HEIGHT * 0.5) {
            return 0.6; // Orta
        } else if (armLift >= MIN_ARM_LIFT_HEIGHT * 0.3) {
            return 0.4; // Zayıf
        } else {
            return 0.2; // Çok zayıf
        }
    }
    
    /**
     * Bacak kaldırma accuracy'si hesaplar
     */
    private double calculateLegAccuracy(double legLift) {
        if (legLift >= MIN_LEG_LIFT_HEIGHT) {
            return 1.0; // Mükemmel kaldırma
        } else if (legLift >= MIN_LEG_LIFT_HEIGHT * 0.7) {
            return 0.8; // İyi
        } else if (legLift >= MIN_LEG_LIFT_HEIGHT * 0.5) {
            return 0.6; // Orta
        } else if (legLift >= MIN_LEG_LIFT_HEIGHT * 0.3) {
            return 0.4; // Zayıf
        } else {
            return 0.2; // Çok zayıf
        }
    }
    
    /**
     * Kafa pozisyonu accuracy'si hesaplar
     */
    private double calculateHeadAccuracy(double headPosition) {
        if (headPosition >= 20.0) {
            return 1.0; // İyi kafa pozisyonu
        } else if (headPosition >= 10.0) {
            return 0.8;
        } else if (headPosition >= 5.0) {
            return 0.6;
        } else {
            return 0.4;
        }
    }
    
    /**
     * Vücut hizalaması accuracy'si hesaplar
     */
    private double calculateAlignmentAccuracy(double bodyAlignment) {
        return bodyAlignment; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double armLift, double legLift, boolean isInPronePosition,
                                   double headPosition, double bodyAlignment, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Superman pozisyonunu doğru yapıyorsunuz";
        }
        
        if (!isInPronePosition) {
            return "Yüzüstü yatın ve superman pozisyonuna geçin";
        }
        
        // Öncelikli feedback
        if (armLift < MIN_ARM_LIFT_HEIGHT * 0.5) {
            return "Kollarınızı daha yukarı kaldırın";
        } else if (legLift < MIN_LEG_LIFT_HEIGHT * 0.5) {
            return "Bacaklarınızı daha yukarı kaldırın";
        } else if (headPosition < 10.0) {
            return "Kafanızı yukarı kaldırın ve öne bakın";
        } else if (bodyAlignment < 0.6) {
            return "Vücudunuzu düz tutun ve simetrik kaldırın";
        } else if (armLift < MIN_ARM_LIFT_HEIGHT) {
            return "Kollarınızı biraz daha yükseğe kaldırın";
        } else if (legLift < MIN_LEG_LIFT_HEIGHT) {
            return "Bacaklarınızı biraz daha yükseğe kaldırın";
        } else {
            return "İyi! Pozisyonu koruyun ve tutmaya devam edin";
        }
    }
} 