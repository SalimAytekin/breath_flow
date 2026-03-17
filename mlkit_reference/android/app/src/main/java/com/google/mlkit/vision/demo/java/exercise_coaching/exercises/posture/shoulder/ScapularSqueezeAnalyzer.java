package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.shoulder;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Scapular Squeeze (Kürek kemiği sıkıştırma) egzersizi için analizör
 * Omuzları geriye çekip kürek kemiklerini sıkıştırma egzersizi
 */
public class ScapularSqueezeAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_ELBOW = PoseLandmark.LEFT_ELBOW;
    private static final int RIGHT_ELBOW = PoseLandmark.RIGHT_ELBOW;
    private static final int LEFT_WRIST = PoseLandmark.LEFT_WRIST;
    private static final int RIGHT_WRIST = PoseLandmark.RIGHT_WRIST;
    
    // Hedef değerler
    private static final double TARGET_SHOULDER_RETRACTION = 0.85; // Omuz geriye çekme oranı
    private static final double TARGET_ELBOW_POSITION = 0.8;       // Dirsek pozisyon doğruluğu
    private static final double POSITION_TOLERANCE = 0.15;
    
    // Başlangıç pozisyonu referansı
    private double initialShoulderDistance = 0.0;
    private boolean hasInitialPosition = false;
    
    public ScapularSqueezeAnalyzer() {
        super("Scapular Squeeze (Kürek kemiği sıkıştırma)", "scapular_squeeze");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW, LEFT_WRIST, RIGHT_WRIST)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        PoseLandmark leftElbow = pose.getPoseLandmark(LEFT_ELBOW);
        PoseLandmark rightElbow = pose.getPoseLandmark(RIGHT_ELBOW);
        PoseLandmark leftWrist = pose.getPoseLandmark(LEFT_WRIST);
        PoseLandmark rightWrist = pose.getPoseLandmark(RIGHT_WRIST);
        
        // İlk pozisyonu kaydet (referans için)
        if (!hasInitialPosition) {
            initialShoulderDistance = calculateShoulderDistance(leftShoulder, rightShoulder);
            hasInitialPosition = true;
        }
        
        // Omuz geriye çekme miktarını hesapla
        double currentShoulderDistance = calculateShoulderDistance(leftShoulder, rightShoulder);
        double shoulderRetraction = calculateShoulderRetraction(currentShoulderDistance);
        
        // Dirsek pozisyonu kontrolü (vücuda yakın olmalı)
        double elbowPosition = checkElbowPosition(leftShoulder, rightShoulder, leftElbow, rightElbow);
        
        // Kol pozisyonu kontrolü (kollar vücuda yakın)
        double armAlignment = checkArmAlignment(leftShoulder, leftElbow, leftWrist, rightShoulder, rightElbow, rightWrist);
        
        // Göğüs açıklığı kontrolü
        double chestOpenness = calculateChestOpenness(leftShoulder, rightShoulder, leftElbow, rightElbow);
        
        // Accuracy hesapla
        double retractionAccuracy = calculateRetractionAccuracy(shoulderRetraction);
        double elbowAccuracy = calculateElbowAccuracy(elbowPosition);
        double armAccuracy = calculateArmAccuracy(armAlignment);
        double chestAccuracy = calculateChestAccuracy(chestOpenness);
        
        double overallAccuracy = (retractionAccuracy * 0.4 + elbowAccuracy * 0.25 + 
                                armAccuracy * 0.2 + chestAccuracy * 0.15);
        
        // Feedback üret
        String feedback = generateFeedback(shoulderRetraction, elbowPosition, armAlignment, chestOpenness, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü (5 saniye tutma)
        boolean isRepetitionComplete = overallAccuracy > 0.8;
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Omuzlar arası mesafeyi hesaplar
     */
    private double calculateShoulderDistance(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double dx = leftShoulder.getPosition().x - rightShoulder.getPosition().x;
        double dy = leftShoulder.getPosition().y - rightShoulder.getPosition().y;
        return Math.sqrt(dx * dx + dy * dy);
    }
    
    /**
     * Omuz geriye çekme miktarını hesaplar
     */
    private double calculateShoulderRetraction(double currentDistance) {
        if (initialShoulderDistance == 0.0) {
            return 0.5; // Henüz referans yok
        }
        
        // Omuzlar geriye çekildiğinde mesafe azalır
        double retractionRatio = (initialShoulderDistance - currentDistance) / initialShoulderDistance;
        return Math.max(0.0, Math.min(1.0, retractionRatio + 0.5)); // 0.5 offset ekle
    }
    
    /**
     * Dirsek pozisyonunu kontrol eder (vücuda yakın olmalı)
     */
    private double checkElbowPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                    PoseLandmark leftElbow, PoseLandmark rightElbow) {
        // Omuz orta noktası
        double shoulderMidX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        
        // Dirseklerin omuz orta noktasına uzaklığı
        double leftElbowDistance = Math.abs(leftElbow.getPosition().x - shoulderMidX);
        double rightElbowDistance = Math.abs(rightElbow.getPosition().x - shoulderMidX);
        double averageElbowDistance = (leftElbowDistance + rightElbowDistance) / 2.0;
        
        // Omuz genişliği referansı
        double shoulderWidth = Math.abs(leftShoulder.getPosition().x - rightShoulder.getPosition().x);
        
        // Dirsekler omuz genişliği içinde olmalı
        double positionRatio = 1.0 - (averageElbowDistance / (shoulderWidth * 0.8));
        return Math.max(0.0, Math.min(1.0, positionRatio));
    }
    
    /**
     * Kol hizalamasını kontrol eder
     */
    private double checkArmAlignment(PoseLandmark leftShoulder, PoseLandmark leftElbow, PoseLandmark leftWrist,
                                   PoseLandmark rightShoulder, PoseLandmark rightElbow, PoseLandmark rightWrist) {
        // Sol kol açısı
        double leftArmAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
        // Sağ kol açısı
        double rightArmAngle = calculateAngle(rightShoulder, rightElbow, rightWrist);
        
        // İdeal açı yaklaşık 90-120 derece (rahat pozisyon)
        double targetAngle = 105.0;
        double leftDifference = Math.abs(leftArmAngle - targetAngle);
        double rightDifference = Math.abs(rightArmAngle - targetAngle);
        double averageDifference = (leftDifference + rightDifference) / 2.0;
        
        // Açı farkı ne kadar az o kadar iyi
        return Math.max(0.0, 1.0 - (averageDifference / 60.0)); // 60 derece tolerans
    }
    
    /**
     * Göğüs açıklığını hesaplar
     */
    private double calculateChestOpenness(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                        PoseLandmark leftElbow, PoseLandmark rightElbow) {
        // Omuzlar arası mesafe
        double shoulderDistance = calculateShoulderDistance(leftShoulder, rightShoulder);
        
        // Dirsekler arası mesafe
        double elbowDistance = Math.sqrt(
            Math.pow(leftElbow.getPosition().x - rightElbow.getPosition().x, 2) +
            Math.pow(leftElbow.getPosition().y - rightElbow.getPosition().y, 2)
        );
        
        // Göğüs açıklığı oranı (dirsekler omuzlardan daha geniş olmalı)
        double opennessRatio = elbowDistance / shoulderDistance;
        return Math.min(1.0, Math.max(0.0, (opennessRatio - 0.8) / 0.4)); // 0.8-1.2 arası ideal
    }
    
    /**
     * Omuz geriye çekme accuracy'si hesaplar
     */
    private double calculateRetractionAccuracy(double retraction) {
        double difference = Math.abs(retraction - TARGET_SHOULDER_RETRACTION);
        
        if (difference <= POSITION_TOLERANCE) {
            return 1.0; // Mükemmel
        } else if (difference <= POSITION_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= POSITION_TOLERANCE * 3) {
            return 0.6; // Orta
        } else {
            return 0.3; // Zayıf
        }
    }
    
    /**
     * Dirsek pozisyonu accuracy'si hesaplar
     */
    private double calculateElbowAccuracy(double elbowPosition) {
        if (elbowPosition > TARGET_ELBOW_POSITION) {
            return 1.0; // Mükemmel
        } else if (elbowPosition > 0.6) {
            return 0.8; // İyi
        } else if (elbowPosition > 0.4) {
            return 0.6; // Orta
        } else {
            return 0.3; // Zayıf
        }
    }
    
    /**
     * Kol hizalaması accuracy'si hesaplar
     */
    private double calculateArmAccuracy(double armAlignment) {
        return armAlignment; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Göğüs açıklığı accuracy'si hesaplar
     */
    private double calculateChestAccuracy(double chestOpenness) {
        return chestOpenness; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double shoulderRetraction, double elbowPosition, 
                                   double armAlignment, double chestOpenness, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Kürek kemiklerinizi sıkıştırıyorsunuz";
        }
        
        // Öncelikli feedback
        if (shoulderRetraction < TARGET_SHOULDER_RETRACTION - POSITION_TOLERANCE) {
            return "Omuzlarınızı daha fazla geriye çekin";
        } else if (elbowPosition < 0.6) {
            return "Dirseklerinizi vücudunuza daha yakın tutun";
        } else if (chestOpenness < 0.5) {
            return "Göğsünüzü açın ve omuzları geriye çekin";
        } else if (armAlignment < 0.6) {
            return "Kollarınızı daha rahat bırakın";
        } else {
            return "İyi! Pozisyonu koruyun ve kürek kemiklerini sıkıştırın";
        }
    }
} 