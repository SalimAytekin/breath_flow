package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Bird Dog egzersizi için analizör
 * Denge, core ve sırt kaslarını güçlendiren, koordinasyon geliştiren egzersiz
 */
public class BirdDogAnalyzer extends BaseExerciseAnalyzer {

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
    
    // Hedef açılar (derece)
    private static final double TARGET_ARM_ANGLE = 180.0; // Düz kol
    private static final double TARGET_LEG_ANGLE = 180.0; // Düz bacak
    private static final double TARGET_HIP_ANGLE = 90.0;  // Kalça 90 derece
    private static final double ANGLE_TOLERANCE = 15.0;
    
    public BirdDogAnalyzer() {
        super("Bird Dog", "bird_dog");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW,
                LEFT_WRIST, RIGHT_WRIST, LEFT_HIP, RIGHT_HIP, LEFT_KNEE, RIGHT_KNEE, LEFT_ANKLE, RIGHT_ANKLE)) {
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
        
        // Kol açılarını hesapla
        double leftArmAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
        double rightArmAngle = calculateAngle(rightShoulder, rightElbow, rightWrist);
        
        // Bacak açılarını hesapla
        double leftLegAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
        double rightLegAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
        
        // Kalça açılarını hesapla (gövde-bacak açısı)
        double leftHipAngle = calculateAngle(leftShoulder, leftHip, leftKnee);
        double rightHipAngle = calculateAngle(rightShoulder, rightHip, rightKnee);
        
        // Her eklem için accuracy hesapla
        double leftArmAccuracy = calculateJointAccuracy(leftArmAngle, TARGET_ARM_ANGLE);
        double rightArmAccuracy = calculateJointAccuracy(rightArmAngle, TARGET_ARM_ANGLE);
        double leftLegAccuracy = calculateJointAccuracy(leftLegAngle, TARGET_LEG_ANGLE);
        double rightLegAccuracy = calculateJointAccuracy(rightLegAngle, TARGET_LEG_ANGLE);
        double leftHipAccuracy = calculateJointAccuracy(leftHipAngle, TARGET_HIP_ANGLE);
        double rightHipAccuracy = calculateJointAccuracy(rightHipAngle, TARGET_HIP_ANGLE);
        
        // Genel accuracy hesapla
        double overallAccuracy = (leftArmAccuracy + rightArmAccuracy + leftLegAccuracy + 
                                 rightLegAccuracy + leftHipAccuracy + rightHipAccuracy) / 6.0;
        
        // Feedback üret
        String feedback = generateFeedback(leftArmAngle, rightArmAngle, leftLegAngle, rightLegAngle, 
                                         leftHipAngle, rightHipAngle, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = overallAccuracy > 0.8;
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Eklem açısı için accuracy hesaplar
     */
    private double calculateJointAccuracy(double currentAngle, double targetAngle) {
        double difference = Math.abs(currentAngle - targetAngle);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel
        } else if (difference <= ANGLE_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= ANGLE_TOLERANCE * 3) {
            return 0.6; // Orta
        } else if (difference <= ANGLE_TOLERANCE * 4) {
            return 0.4; // Zayıf
        } else {
            return 0.2; // Kötü
        }
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double leftArmAngle, double rightArmAngle, 
                                   double leftLegAngle, double rightLegAngle,
                                   double leftHipAngle, double rightHipAngle, 
                                   double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Bird dog pozisyonunu koruyun";
        }
        
        // En problemli eklem için öncelikli feedback
        if (Math.abs(leftArmAngle - TARGET_ARM_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Sol kolunuzu daha düz tutun";
        } else if (Math.abs(rightArmAngle - TARGET_ARM_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Sağ kolunuzu daha düz tutun";
        } else if (Math.abs(leftLegAngle - TARGET_LEG_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Sol bacağınızı daha düz tutun";
        } else if (Math.abs(rightLegAngle - TARGET_LEG_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Sağ bacağınızı daha düz tutun";
        } else if (Math.abs(leftHipAngle - TARGET_HIP_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Kalçanızı daha stabil tutun";
        } else if (Math.abs(rightHipAngle - TARGET_HIP_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Gövdenizi daha düz tutun";
        } else {
            return "İyi! Pozisyonu korumaya çalışın";
        }
    }
} 