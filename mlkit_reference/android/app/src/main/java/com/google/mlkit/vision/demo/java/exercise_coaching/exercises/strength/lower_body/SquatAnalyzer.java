package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.lower_body;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Squat egzersizi için analizör
 * Bacak ve kalça kaslarını güçlendiren egzersiz
 */
public class SquatAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int LEFT_KNEE = PoseLandmark.LEFT_KNEE;
    private static final int RIGHT_KNEE = PoseLandmark.RIGHT_KNEE;
    private static final int LEFT_ANKLE = PoseLandmark.LEFT_ANKLE;
    private static final int RIGHT_ANKLE = PoseLandmark.RIGHT_ANKLE;
    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    
    // Hedef açılar (derece)
    private static final double TARGET_KNEE_ANGLE_MIN = 70.0;  // Minimum diz açısı (derin squat)
    private static final double TARGET_KNEE_ANGLE_MAX = 110.0; // Maksimum diz açısı (yüzeysel squat)
    private static final double STANDING_KNEE_ANGLE = 170.0;   // Ayakta durma açısı
    private static final double ANGLE_TOLERANCE = 15.0;
    
    // Hareket durumu
    private boolean isMovingDown = false;
    private boolean isMovingUp = false;
    private double previousKneeAngle = 0.0;
    
    public SquatAnalyzer() {
        super("Squat", "squat");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_HIP, RIGHT_HIP, LEFT_KNEE, RIGHT_KNEE, 
                LEFT_ANKLE, RIGHT_ANKLE, LEFT_SHOULDER, RIGHT_SHOULDER)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftHip = pose.getPoseLandmark(LEFT_HIP);
        PoseLandmark rightHip = pose.getPoseLandmark(RIGHT_HIP);
        PoseLandmark leftKnee = pose.getPoseLandmark(LEFT_KNEE);
        PoseLandmark rightKnee = pose.getPoseLandmark(RIGHT_KNEE);
        PoseLandmark leftAnkle = pose.getPoseLandmark(LEFT_ANKLE);
        PoseLandmark rightAnkle = pose.getPoseLandmark(RIGHT_ANKLE);
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        
        // Diz açılarını hesapla
        double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
        double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
        double averageKneeAngle = (leftKneeAngle + rightKneeAngle) / 2.0;
        
        // Gövde açısını hesapla (dik durma kontrolü)
        double leftTorsoAngle = calculateTorsoAngle(leftShoulder, leftHip, leftKnee);
        double rightTorsoAngle = calculateTorsoAngle(rightShoulder, rightHip, rightKnee);
        double averageTorsoAngle = (leftTorsoAngle + rightTorsoAngle) / 2.0;
        
        // Hareket yönünü belirle
        determineMovementDirection(averageKneeAngle);
        
        // Accuracy hesapla
        double kneeAccuracy = calculateKneeAccuracy(averageKneeAngle);
        double torsoAccuracy = calculateTorsoAccuracy(averageTorsoAngle);
        double overallAccuracy = (kneeAccuracy + torsoAccuracy) / 2.0;
        
        // Feedback üret
        String feedback = generateFeedback(averageKneeAngle, averageTorsoAngle, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = checkRepetitionComplete(averageKneeAngle);
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Hareket yönünü belirler
     */
    private void determineMovementDirection(double currentKneeAngle) {
        if (previousKneeAngle > 0) {
            if (currentKneeAngle < previousKneeAngle - 5) {
                isMovingDown = true;
                isMovingUp = false;
            } else if (currentKneeAngle > previousKneeAngle + 5) {
                isMovingUp = true;
                isMovingDown = false;
            }
        }
        previousKneeAngle = currentKneeAngle;
    }
    
    /**
     * Diz açısı için accuracy hesaplar
     */
    private double calculateKneeAccuracy(double kneeAngle) {
        // Squat pozisyonunda mı kontrol et
        if (kneeAngle >= TARGET_KNEE_ANGLE_MIN && kneeAngle <= TARGET_KNEE_ANGLE_MAX) {
            return 1.0; // Mükemmel squat derinliği
        } else if (kneeAngle > TARGET_KNEE_ANGLE_MAX && kneeAngle <= TARGET_KNEE_ANGLE_MAX + ANGLE_TOLERANCE) {
            return 0.8; // Yüzeysel ama kabul edilebilir
        } else if (kneeAngle < TARGET_KNEE_ANGLE_MIN && kneeAngle >= TARGET_KNEE_ANGLE_MIN - ANGLE_TOLERANCE) {
            return 0.9; // Derin squat, iyi
        } else if (kneeAngle > STANDING_KNEE_ANGLE - ANGLE_TOLERANCE) {
            return 0.6; // Ayakta durma pozisyonu
        } else {
            return 0.3; // Hatalı pozisyon
        }
    }
    
    /**
     * Gövde açısı için accuracy hesaplar
     */
    private double calculateTorsoAccuracy(double torsoAngle) {
        // Gövde dik tutulmalı (90 derece civarı)
        double targetTorsoAngle = 90.0;
        double difference = Math.abs(torsoAngle - targetTorsoAngle);
        
        if (difference <= 15.0) {
            return 1.0; // Mükemmel gövde pozisyonu
        } else if (difference <= 25.0) {
            return 0.8; // İyi
        } else if (difference <= 35.0) {
            return 0.6; // Orta
        } else {
            return 0.3; // Kötü
        }
    }
    
    /**
     * Gövde açısını hesaplar
     */
    private double calculateTorsoAngle(PoseLandmark shoulder, PoseLandmark hip, PoseLandmark knee) {
        // Gövde ile bacak arasındaki açı
        return calculateAngle(shoulder, hip, knee);
    }
    
    /**
     * Tekrar tamamlanma kontrolü
     */
    private boolean checkRepetitionComplete(double kneeAngle) {
        // Tam bir squat hareketi: aşağı inip tekrar yukarı çıkma
        return isMovingUp && kneeAngle > STANDING_KNEE_ANGLE - ANGLE_TOLERANCE;
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double kneeAngle, double torsoAngle, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Squat formunuz harika";
        }
        
        // Öncelikli feedback
        if (kneeAngle > TARGET_KNEE_ANGLE_MAX + ANGLE_TOLERANCE) {
            return "Daha derin inin, dizlerinizi daha çok büküün";
        } else if (kneeAngle < TARGET_KNEE_ANGLE_MIN - ANGLE_TOLERANCE) {
            return "Çok derin iniyorsunuz, biraz daha yüzeysel olabilir";
        } else if (Math.abs(torsoAngle - 90.0) > 25.0) {
            return "Gövdenizi daha dik tutun";
        } else if (isMovingDown) {
            return "İyi! Kontrollü bir şekilde inin";
        } else if (isMovingUp) {
            return "Harika! Şimdi yukarı çıkın";
        } else {
            return "Squat pozisyonunu koruyun";
        }
    }
} 