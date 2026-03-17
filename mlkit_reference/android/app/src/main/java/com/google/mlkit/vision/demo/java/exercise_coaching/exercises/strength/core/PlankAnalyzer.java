package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.core;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Plank egzersizi için analizör
 * Core kaslarını güçlendirmek ve gövde stabilitesini artırmak için yapılır
 */
public class PlankAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_ELBOW = PoseLandmark.LEFT_ELBOW;
    private static final int RIGHT_ELBOW = PoseLandmark.RIGHT_ELBOW;
    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int LEFT_KNEE = PoseLandmark.LEFT_KNEE;
    private static final int RIGHT_KNEE = PoseLandmark.RIGHT_KNEE;
    private static final int LEFT_ANKLE = PoseLandmark.LEFT_ANKLE;
    private static final int RIGHT_ANKLE = PoseLandmark.RIGHT_ANKLE;
    
    // Hedef açılar (derece)
    private static final double TARGET_BODY_LINE_ANGLE = 180.0; // Düz vücut hattı
    private static final double TARGET_ELBOW_ANGLE = 90.0;      // Dirsek 90 derece (forearm plank)
    private static final double ANGLE_TOLERANCE = 10.0;
    
    // Pozisyon kontrolü için eşik değerler
    private static final double MIN_PLANK_HEIGHT = 0.3; // Minimum yükseklik oranı
    
    public PlankAnalyzer() {
        super("Plank", "plank");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW,
                LEFT_HIP, RIGHT_HIP, LEFT_KNEE, RIGHT_KNEE, LEFT_ANKLE, RIGHT_ANKLE)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        PoseLandmark leftElbow = pose.getPoseLandmark(LEFT_ELBOW);
        PoseLandmark rightElbow = pose.getPoseLandmark(RIGHT_ELBOW);
        PoseLandmark leftHip = pose.getPoseLandmark(LEFT_HIP);
        PoseLandmark rightHip = pose.getPoseLandmark(RIGHT_HIP);
        PoseLandmark leftKnee = pose.getPoseLandmark(LEFT_KNEE);
        PoseLandmark rightKnee = pose.getPoseLandmark(RIGHT_KNEE);
        PoseLandmark leftAnkle = pose.getPoseLandmark(LEFT_ANKLE);
        PoseLandmark rightAnkle = pose.getPoseLandmark(RIGHT_ANKLE);
        
        // Vücut hattı açısını hesapla (omuz-kalça-ayak bileği)
        double leftBodyLineAngle = calculateAngle(leftShoulder, leftHip, leftAnkle);
        double rightBodyLineAngle = calculateAngle(rightShoulder, rightHip, rightAnkle);
        double averageBodyLineAngle = (leftBodyLineAngle + rightBodyLineAngle) / 2.0;
        
        // Dirsek açılarını hesapla (forearm plank kontrolü)
        double leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftAnkle);
        double rightElbowAngle = calculateAngle(rightShoulder, rightElbow, rightAnkle);
        double averageElbowAngle = (leftElbowAngle + rightElbowAngle) / 2.0;
        
        // Plank pozisyonu kontrolü (yerde mi değil mi)
        boolean isInPlankPosition = checkPlankPosition(leftShoulder, rightShoulder, leftHip, rightHip);
        
        // Kalça yüksekliği kontrolü (çok yüksek veya çok alçak olmamalı)
        double hipAlignment = checkHipAlignment(leftShoulder, rightShoulder, leftHip, rightHip, leftAnkle, rightAnkle);
        
        // Accuracy hesapla
        double bodyLineAccuracy = calculateBodyLineAccuracy(averageBodyLineAngle);
        double positionAccuracy = isInPlankPosition ? 1.0 : 0.3;
        double hipAccuracy = calculateHipAccuracy(hipAlignment);
        
        double overallAccuracy = (bodyLineAccuracy * 0.5 + positionAccuracy * 0.3 + hipAccuracy * 0.2);
        
        // Feedback üret
        String feedback = generateFeedback(averageBodyLineAngle, hipAlignment, isInPlankPosition, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Plank tutma süresi kontrolü (20 saniye)
        boolean isRepetitionComplete = overallAccuracy > 0.8; // Süre kontrolü ayrıca yapılacak
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Plank pozisyonunda olup olmadığını kontrol eder
     */
    private boolean checkPlankPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                     PoseLandmark leftHip, PoseLandmark rightHip) {
        // Omuzların kalçalardan yüksek olması gerekir (plank pozisyonu)
        double shoulderHeight = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double hipHeight = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        
        return shoulderHeight < hipHeight; // Y koordinatı ters (0 üstte)
    }
    
    /**
     * Kalça hizalamasını kontrol eder
     */
    private double checkHipAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                   PoseLandmark leftHip, PoseLandmark rightHip,
                                   PoseLandmark leftAnkle, PoseLandmark rightAnkle) {
        // Omuz, kalça ve ayak bileği arasındaki yükseklik farkını hesapla
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double hipY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        double ankleY = (leftAnkle.getPosition().y + rightAnkle.getPosition().y) / 2.0;
        
        // İdeal plank'te kalça, omuz ve ayak bileği arasında olmalı
        double shoulderHipDistance = Math.abs(shoulderY - hipY);
        double hipAnkleDistance = Math.abs(hipY - ankleY);
        
        // Kalça çok yüksek veya çok alçak olmamalı
        return Math.min(shoulderHipDistance, hipAnkleDistance) / Math.max(shoulderHipDistance, hipAnkleDistance);
    }
    
    /**
     * Vücut hattı açısı için accuracy hesaplar
     */
    private double calculateBodyLineAccuracy(double bodyLineAngle) {
        double difference = Math.abs(bodyLineAngle - TARGET_BODY_LINE_ANGLE);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel düz hat
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
     * Kalça hizalaması için accuracy hesaplar
     */
    private double calculateHipAccuracy(double hipAlignment) {
        if (hipAlignment > 0.8) {
            return 1.0; // Mükemmel hizalama
        } else if (hipAlignment > 0.6) {
            return 0.8; // İyi
        } else if (hipAlignment > 0.4) {
            return 0.6; // Orta
        } else {
            return 0.3; // Kötü
        }
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double bodyLineAngle, double hipAlignment, 
                                   boolean isInPlankPosition, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Plank pozisyonunu koruyun";
        }
        
        if (!isInPlankPosition) {
            return "Plank pozisyonuna geçin - dirsekler ve ayak parmakları üzerinde durun";
        }
        
        // Öncelikli feedback
        if (Math.abs(bodyLineAngle - TARGET_BODY_LINE_ANGLE) > ANGLE_TOLERANCE * 2) {
            if (bodyLineAngle < TARGET_BODY_LINE_ANGLE - ANGLE_TOLERANCE) {
                return "Kalçanızı biraz daha yukarı kaldırın";
            } else {
                return "Kalçanızı biraz daha aşağı indirin";
            }
        } else if (hipAlignment < 0.6) {
            return "Vücudunuzu düz bir hat halinde tutun";
        } else {
            return "İyi! Pozisyonu korumaya çalışın";
        }
    }
} 