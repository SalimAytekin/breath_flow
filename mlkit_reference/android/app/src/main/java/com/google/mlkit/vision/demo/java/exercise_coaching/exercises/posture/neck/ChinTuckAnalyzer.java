package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.neck;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Chin Tuck (Çene germe) egzersizi için analizör
 * Boyun hizalamasını ve duruşunu iyileştiren egzersiz
 */
public class ChinTuckAnalyzer extends BaseExerciseAnalyzer {

    private static final int NOSE = PoseLandmark.NOSE;
    private static final int LEFT_EAR = PoseLandmark.LEFT_EAR;
    private static final int RIGHT_EAR = PoseLandmark.RIGHT_EAR;
    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    
    // Hedef değerler
    private static final double TARGET_HEAD_FORWARD_RATIO = 0.2;
    private static final double TOLERANCE = 0.05;
    
    public ChinTuckAnalyzer() {
        super("Chin Tuck (Çene germe)", "chin_tuck");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, NOSE, LEFT_EAR, RIGHT_EAR, LEFT_SHOULDER, RIGHT_SHOULDER)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark nose = pose.getPoseLandmark(NOSE);
        PoseLandmark leftEar = pose.getPoseLandmark(LEFT_EAR);
        PoseLandmark rightEar = pose.getPoseLandmark(RIGHT_EAR);
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        
        // Orta noktaları hesapla
        double earMidpointX = (leftEar.getPosition().x + rightEar.getPosition().x) / 2;
        double earMidpointY = (leftEar.getPosition().y + rightEar.getPosition().y) / 2;
        
        double shoulderMidpointX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2;
        double shoulderMidpointY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2;
        
        // Mesafeleri hesapla
        double horizontalDistance = Math.abs(earMidpointX - shoulderMidpointX);
        double verticalDistance = Math.abs(earMidpointY - shoulderMidpointY);
        
        // Sıfır bölme kontrolü
        if (verticalDistance < 0.1) {
            return new AnalysisResult(0.0, "Lütfen yan profilden pozisyon alın", false, "Hatalı Pozisyon");
        }
        
        // Head forward ratio hesapla
        double headForwardRatio = horizontalDistance / verticalDistance;
        
        // Accuracy hesapla
        double accuracy = calculateAccuracy(headForwardRatio);
        
        // Feedback üret
        String feedback = generateFeedback(headForwardRatio, accuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(accuracy);
        
        // Tekrar tamamlanma kontrolü (5 saniye boyunca doğru pozisyon)
        boolean isRepetitionComplete = accuracy > 0.8;
        
        return new AnalysisResult(accuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Head forward ratio'ya göre accuracy hesaplar
     */
    private double calculateAccuracy(double headForwardRatio) {
        double difference = Math.abs(headForwardRatio - TARGET_HEAD_FORWARD_RATIO);
        
        if (difference <= TOLERANCE) {
            return 1.0; // Mükemmel
        } else if (difference <= TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= TOLERANCE * 3) {
            return 0.6; // Orta
        } else if (difference <= TOLERANCE * 4) {
            return 0.4; // Zayıf
        } else {
            return 0.2; // Kötü
        }
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double headForwardRatio, double accuracy) {
        if (accuracy > 0.85) {
            return "Mükemmel! Chin tuck pozisyonunu koruyun";
        } else if (headForwardRatio > TARGET_HEAD_FORWARD_RATIO + TOLERANCE) {
            return "Çenenizi biraz daha geriye çekin";
        } else if (headForwardRatio < TARGET_HEAD_FORWARD_RATIO - TOLERANCE) {
            return "Çenenizi fazla geriye çekmeyin, daha doğal olsun";
        } else {
            return "İyi! Pozisyonu korumaya çalışın";
        }
    }
} 