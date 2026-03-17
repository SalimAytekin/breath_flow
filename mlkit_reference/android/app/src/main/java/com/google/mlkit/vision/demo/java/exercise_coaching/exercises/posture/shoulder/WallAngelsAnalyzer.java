package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.shoulder;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Wall Angels egzersizi için analizör
 * Omuz mobilitesi ve postür düzeltme egzersizi
 */
public class WallAngelsAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_ELBOW = PoseLandmark.LEFT_ELBOW;
    private static final int RIGHT_ELBOW = PoseLandmark.RIGHT_ELBOW;
    private static final int LEFT_WRIST = PoseLandmark.LEFT_WRIST;
    private static final int RIGHT_WRIST = PoseLandmark.RIGHT_WRIST;
    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int NOSE = PoseLandmark.NOSE;
    
    // Hedef açılar (derece)
    private static final double TARGET_ARM_ANGLE_DOWN = 90.0;     // Kollar aşağıda (başlangıç)
    private static final double TARGET_ARM_ANGLE_UP = 150.0;      // Kollar yukarıda
    private static final double TARGET_ELBOW_ANGLE = 90.0;        // Dirsek açısı
    private static final double ANGLE_TOLERANCE = 15.0;
    
    // Hareket fazları
    private enum WallAngelsPhase {
        DOWN,        // Kollar aşağıda
        UP,          // Kollar yukarıda
        TRANSITION   // Geçiş fazı
    }
    
    private WallAngelsPhase currentPhase = WallAngelsPhase.DOWN;
    private int repetitionCount = 0;
    
    public WallAngelsAnalyzer() {
        super("Wall Angels", "wall_angels");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW,
                LEFT_WRIST, RIGHT_WRIST, LEFT_HIP, RIGHT_HIP, NOSE)) {
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
        PoseLandmark nose = pose.getPoseLandmark(NOSE);
        
        // Duvara yaslanma pozisyonu kontrolü
        boolean isAgainstWall = checkWallPosition(leftShoulder, rightShoulder, leftHip, rightHip);
        
        // Kol açılarını hesapla
        double leftArmAngle = calculateArmAngle(leftShoulder, leftElbow, leftWrist);
        double rightArmAngle = calculateArmAngle(rightShoulder, rightElbow, rightWrist);
        double averageArmAngle = (leftArmAngle + rightArmAngle) / 2.0;
        
        // Dirsek açılarını hesapla
        double leftElbowAngle = calculateElbowAngle(leftShoulder, leftElbow, leftWrist);
        double rightElbowAngle = calculateElbowAngle(rightShoulder, rightElbow, rightWrist);
        double averageElbowAngle = (leftElbowAngle + rightElbowAngle) / 2.0;
        
        // Hareket fazını güncelle
        updateWallAngelsPhase(averageArmAngle);
        
        // Simetri kontrolü
        double armSymmetry = checkArmSymmetry(leftArmAngle, rightArmAngle);
        
        // Kafa pozisyonu kontrolü
        double headPosition = checkHeadPosition(nose, leftShoulder, rightShoulder);
        
        // Accuracy hesapla
        double positionAccuracy = isAgainstWall ? 1.0 : 0.4;
        double armAccuracy = calculateArmAccuracy(averageArmAngle);
        double elbowAccuracy = calculateElbowAccuracy(averageElbowAngle);
        double symmetryAccuracy = calculateSymmetryAccuracy(armSymmetry);
        double headAccuracy = calculateHeadAccuracy(headPosition);
        
        double overallAccuracy = (positionAccuracy * 0.3 + armAccuracy * 0.3 + 
                                elbowAccuracy * 0.2 + symmetryAccuracy * 0.1 + headAccuracy * 0.1);
        
        // Feedback üret
        String feedback = generateFeedback(averageArmAngle, averageElbowAngle, isAgainstWall, 
                                         armSymmetry, headPosition, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = checkRepetitionComplete(overallAccuracy);
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Duvara yaslanma pozisyonunu kontrol eder
     */
    private boolean checkWallPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                    PoseLandmark leftHip, PoseLandmark rightHip) {
        // Omuzlar ve kalçalar yaklaşık aynı X koordinatında olmalı (duvara yaslanmış)
        double shoulderX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        double hipX = (leftHip.getPosition().x + rightHip.getPosition().x) / 2.0;
        
        double postureDifference = Math.abs(shoulderX - hipX);
        
        // Dik duruş kontrolü
        return postureDifference < 30.0; // 30 piksel tolerans
    }
    
    /**
     * Kol açısını hesaplar (omuz-dirsek-yatay referans)
     */
    private double calculateArmAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
        // Omuz-dirsek vektörü
        double shoulderElbowX = elbow.getPosition().x - shoulder.getPosition().x;
        double shoulderElbowY = elbow.getPosition().y - shoulder.getPosition().y;
        
        // Yatay referans vektörü
        double horizontalX = 1.0;
        double horizontalY = 0.0;
        
        // Açıyı hesapla
        double dotProduct = shoulderElbowX * horizontalX + shoulderElbowY * horizontalY;
        double shoulderElbowMagnitude = Math.sqrt(shoulderElbowX * shoulderElbowX + shoulderElbowY * shoulderElbowY);
        
        double cosTheta = dotProduct / shoulderElbowMagnitude;
        cosTheta = Math.max(-1.0, Math.min(1.0, cosTheta));
        
        double angleRadians = Math.acos(cosTheta);
        double angleDegrees = Math.toDegrees(angleRadians);
        
        // Y koordinatı ters olduğu için açıyı düzelt
        if (shoulderElbowY > 0) {
            angleDegrees = 360.0 - angleDegrees;
        }
        
        return angleDegrees;
    }
    
    /**
     * Dirsek açısını hesapla (omuz-dirsek-el)
     */
    private double calculateElbowAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
        return calculateAngle(shoulder, elbow, wrist);
    }
    
    /**
     * Wall Angels hareketinin fazını günceller
     */
    private void updateWallAngelsPhase(double armAngle) {
        switch (currentPhase) {
            case DOWN:
                if (armAngle > TARGET_ARM_ANGLE_UP - ANGLE_TOLERANCE) {
                    currentPhase = WallAngelsPhase.UP;
                }
                break;
            case UP:
                if (armAngle < TARGET_ARM_ANGLE_DOWN + ANGLE_TOLERANCE) {
                    currentPhase = WallAngelsPhase.DOWN;
                    repetitionCount++; // Tam döngü tamamlandı
                }
                break;
            case TRANSITION:
                // Geçiş fazı mantığı
                break;
        }
    }
    
    /**
     * Kol simetrisini kontrol eder
     */
    private double checkArmSymmetry(double leftArmAngle, double rightArmAngle) {
        double angleDifference = Math.abs(leftArmAngle - rightArmAngle);
        
        // Açı farkı ne kadar az o kadar iyi
        return Math.max(0.0, 1.0 - (angleDifference / 30.0)); // 30 derece tolerans
    }
    
    /**
     * Kafa pozisyonunu kontrol eder
     */
    private double checkHeadPosition(PoseLandmark nose, PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double shoulderMidX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        double noseX = nose.getPosition().x;
        
        // Kafa omuzların ortasında olmalı
        double headAlignment = Math.abs(noseX - shoulderMidX);
        
        return Math.max(0.0, 1.0 - (headAlignment / 50.0)); // 50 piksel tolerans
    }
    
    /**
     * Kol açısı accuracy'si hesaplar
     */
    private double calculateArmAccuracy(double armAngle) {
        double targetAngle;
        
        switch (currentPhase) {
            case DOWN:
                targetAngle = TARGET_ARM_ANGLE_DOWN;
                break;
            case UP:
                targetAngle = TARGET_ARM_ANGLE_UP;
                break;
            default:
                return 0.7; // Geçiş fazında orta skor
        }
        
        double difference = Math.abs(armAngle - targetAngle);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel açı
        } else if (difference <= ANGLE_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= ANGLE_TOLERANCE * 3) {
            return 0.6; // Orta
        } else {
            return 0.4; // Zayıf
        }
    }
    
    /**
     * Dirsek açısı accuracy'si hesaplar
     */
    private double calculateElbowAccuracy(double elbowAngle) {
        double difference = Math.abs(elbowAngle - TARGET_ELBOW_ANGLE);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel açı
        } else if (difference <= ANGLE_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= ANGLE_TOLERANCE * 3) {
            return 0.6; // Orta
        } else {
            return 0.4; // Zayıf
        }
    }
    
    /**
     * Simetri accuracy'si hesaplar
     */
    private double calculateSymmetryAccuracy(double symmetry) {
        return symmetry; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Kafa pozisyonu accuracy'si hesaplar
     */
    private double calculateHeadAccuracy(double headPosition) {
        return headPosition; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Tekrar tamamlanma kontrolü
     */
    private boolean checkRepetitionComplete(double overallAccuracy) {
        return overallAccuracy > 0.8 && currentPhase == WallAngelsPhase.DOWN && repetitionCount > 0;
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double armAngle, double elbowAngle, boolean isAgainstWall,
                                   double armSymmetry, double headPosition, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Wall Angels hareketini doğru yapıyorsunuz";
        }
        
        if (!isAgainstWall) {
            return "Sırtınızı duvara yaslayın ve dik durun";
        }
        
        // Faza göre feedback
        switch (currentPhase) {
            case DOWN:
                return "Kollarınızı yukarı kaldırın (melek kanatları gibi)";
            case UP:
                return "Kollarınızı aşağı indirin (başlangıç pozisyonuna)";
            default:
                if (Math.abs(elbowAngle - TARGET_ELBOW_ANGLE) > ANGLE_TOLERANCE * 2) {
                    return "Dirseklerinizi 90 derece açıda tutun";
                } else if (armSymmetry < 0.6) {
                    return "Her iki kolunuzu eşit şekilde hareket ettirin";
                } else if (headPosition < 0.6) {
                    return "Kafanızı duvara yaslayın ve düz tutun";
                } else {
                    return "İyi! Hareket devam ediyor";
                }
        }
    }
} 