package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.upper_body;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Push-up egzersizi için analizör
 * Göğüs, omuz ve kol kaslarını güçlendirmek için yapılır
 */
public class PushUpAnalyzer extends BaseExerciseAnalyzer {

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
    private static final double TARGET_ELBOW_ANGLE_DOWN = 90.0;   // Aşağı pozisyonda dirsek açısı
    private static final double TARGET_ELBOW_ANGLE_UP = 170.0;   // Yukarı pozisyonda dirsek açısı
    private static final double TARGET_BODY_LINE_ANGLE = 180.0;  // Düz vücut hattı
    private static final double ANGLE_TOLERANCE = 15.0;
    
    // Hareket fazları
    private enum PushUpPhase {
        UP_POSITION,    // Yukarı pozisyon (başlangıç)
        DOWN_POSITION,  // Aşağı pozisyon (göğüs yere yakın)
        TRANSITION      // Geçiş fazı
    }
    
    private PushUpPhase currentPhase = PushUpPhase.UP_POSITION;
    private int repetitionCount = 0;
    
    public PushUpAnalyzer() {
        super("Push-up", "push_up");
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
        
        // Dirsek açılarını hesapla
        double leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
        double rightElbowAngle = calculateAngle(rightShoulder, rightElbow, rightWrist);
        double averageElbowAngle = (leftElbowAngle + rightElbowAngle) / 2.0;
        
        // Vücut hattını hesapla (omuz-kalça-ayak bileği)
        double leftBodyLineAngle = calculateAngle(leftShoulder, leftHip, leftAnkle);
        double rightBodyLineAngle = calculateAngle(rightShoulder, rightHip, rightAnkle);
        double averageBodyLineAngle = (leftBodyLineAngle + rightBodyLineAngle) / 2.0;
        
        // El pozisyonu kontrolü (omuz genişliğinde)
        double handSpacing = checkHandSpacing(leftWrist, rightWrist, leftShoulder, rightShoulder);
        
        // Push-up pozisyonu kontrolü
        boolean isInPushUpPosition = checkPushUpPosition(leftShoulder, rightShoulder, leftWrist, rightWrist);
        
        // Hareket fazını belirle
        updatePushUpPhase(averageElbowAngle);
        
        // Accuracy hesapla
        double elbowAccuracy = calculateElbowAccuracy(averageElbowAngle);
        double bodyLineAccuracy = calculateBodyLineAccuracy(averageBodyLineAngle);
        double handSpacingAccuracy = calculateHandSpacingAccuracy(handSpacing);
        double positionAccuracy = isInPushUpPosition ? 1.0 : 0.3;
        
        double overallAccuracy = (elbowAccuracy * 0.4 + bodyLineAccuracy * 0.3 + 
                                handSpacingAccuracy * 0.2 + positionAccuracy * 0.1);
        
        // Feedback üret
        String feedback = generateFeedback(averageElbowAngle, averageBodyLineAngle, handSpacing, 
                                         isInPushUpPosition, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = checkRepetitionComplete(overallAccuracy);
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Push-up pozisyonunda olup olmadığını kontrol eder
     */
    private boolean checkPushUpPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                       PoseLandmark leftWrist, PoseLandmark rightWrist) {
        // Eller omuzlardan aşağıda olmalı (push-up pozisyonu)
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double wristY = (leftWrist.getPosition().y + rightWrist.getPosition().y) / 2.0;
        
        return wristY > shoulderY; // Y koordinatı ters (0 üstte)
    }
    
    /**
     * El aralığını kontrol eder (omuz genişliğinde olmalı)
     */
    private double checkHandSpacing(PoseLandmark leftWrist, PoseLandmark rightWrist,
                                   PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double handDistance = Math.abs(leftWrist.getPosition().x - rightWrist.getPosition().x);
        double shoulderDistance = Math.abs(leftShoulder.getPosition().x - rightShoulder.getPosition().x);
        
        // El aralığının omuz genişliğine oranı
        return handDistance / shoulderDistance;
    }
    
    /**
     * Push-up hareketinin fazını günceller
     */
    private void updatePushUpPhase(double elbowAngle) {
        switch (currentPhase) {
            case UP_POSITION:
                if (elbowAngle < TARGET_ELBOW_ANGLE_DOWN + ANGLE_TOLERANCE) {
                    currentPhase = PushUpPhase.DOWN_POSITION;
                }
                break;
            case DOWN_POSITION:
                if (elbowAngle > TARGET_ELBOW_ANGLE_UP - ANGLE_TOLERANCE) {
                    currentPhase = PushUpPhase.UP_POSITION;
                    repetitionCount++;
                }
                break;
            case TRANSITION:
                if (elbowAngle > TARGET_ELBOW_ANGLE_UP - ANGLE_TOLERANCE) {
                    currentPhase = PushUpPhase.UP_POSITION;
                } else if (elbowAngle < TARGET_ELBOW_ANGLE_DOWN + ANGLE_TOLERANCE) {
                    currentPhase = PushUpPhase.DOWN_POSITION;
                }
                break;
        }
    }
    
    /**
     * Dirsek açısı için accuracy hesaplar
     */
    private double calculateElbowAccuracy(double elbowAngle) {
        double targetAngle;
        
        switch (currentPhase) {
            case UP_POSITION:
                targetAngle = TARGET_ELBOW_ANGLE_UP;
                break;
            case DOWN_POSITION:
                targetAngle = TARGET_ELBOW_ANGLE_DOWN;
                break;
            default:
                return 0.7; // Geçiş fazında orta skor
        }
        
        double difference = Math.abs(elbowAngle - targetAngle);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel açı
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
     * Vücut hattı için accuracy hesaplar
     */
    private double calculateBodyLineAccuracy(double bodyLineAngle) {
        double difference = Math.abs(bodyLineAngle - TARGET_BODY_LINE_ANGLE);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel düz hat
        } else if (difference <= ANGLE_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= ANGLE_TOLERANCE * 3) {
            return 0.6; // Orta
        } else {
            return 0.4; // Zayıf
        }
    }
    
    /**
     * El aralığı için accuracy hesaplar
     */
    private double calculateHandSpacingAccuracy(double handSpacing) {
        // İdeal oran 1.0 - 1.2 arası (omuz genişliğinde veya biraz daha geniş)
        if (handSpacing >= 0.9 && handSpacing <= 1.3) {
            return 1.0; // Mükemmel aralık
        } else if (handSpacing >= 0.8 && handSpacing <= 1.5) {
            return 0.8; // İyi
        } else if (handSpacing >= 0.7 && handSpacing <= 1.7) {
            return 0.6; // Orta
        } else {
            return 0.4; // Kötü
        }
    }
    
    /**
     * Tekrar tamamlanma kontrolü
     */
    private boolean checkRepetitionComplete(double overallAccuracy) {
        return overallAccuracy > 0.8 && currentPhase == PushUpPhase.UP_POSITION;
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double elbowAngle, double bodyLineAngle, double handSpacing,
                                   boolean isInPushUpPosition, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Push-up'ı doğru yapıyorsunuz";
        }
        
        if (!isInPushUpPosition) {
            return "Push-up pozisyonuna geçin - eller yerde, vücut düz";
        }
        
        // Öncelikli feedback
        if (Math.abs(bodyLineAngle - TARGET_BODY_LINE_ANGLE) > ANGLE_TOLERANCE * 2) {
            return "Vücudunuzu düz tutun - kalça çok yüksek veya alçak";
        } else if (handSpacing < 0.8) {
            return "Ellerinizi biraz daha açın";
        } else if (handSpacing > 1.5) {
            return "Ellerinizi biraz daha yaklaştırın";
        } else {
            switch (currentPhase) {
                case UP_POSITION:
                    return "Aşağı inin - dirsekleri bükün";
                case DOWN_POSITION:
                    return "Yukarı itin - göğsünüzü yere yaklaştırın";
                default:
                    return "İyi! Hareket devam ediyor";
            }
        }
    }
} 