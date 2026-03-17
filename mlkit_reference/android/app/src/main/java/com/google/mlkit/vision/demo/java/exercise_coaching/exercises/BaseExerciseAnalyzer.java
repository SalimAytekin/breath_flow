package com.google.mlkit.vision.demo.java.exercise_coaching.exercises;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;

/**
 * Tüm egzersiz analizörleri için temel sınıf
 */
public abstract class BaseExerciseAnalyzer {
    
    protected String exerciseName;
    protected String exerciseType;
    
    // Analiz sonucu sınıfı
    public static class AnalysisResult {
        public double accuracy;
        public String feedback;
        public boolean isRepetitionComplete;
        public String poseQuality;
        
        public AnalysisResult(double accuracy, String feedback, boolean isRepetitionComplete, String poseQuality) {
            this.accuracy = accuracy;
            this.feedback = feedback;
            this.isRepetitionComplete = isRepetitionComplete;
            this.poseQuality = poseQuality;
        }
    }
    
    public BaseExerciseAnalyzer(String exerciseName, String exerciseType) {
        this.exerciseName = exerciseName;
        this.exerciseType = exerciseType;
    }
    
    /**
     * Ana analiz metodu - her egzersiz kendi implementasyonunu yapar
     */
    public abstract AnalysisResult analyze(Pose pose);
    
    /**
     * İki nokta arasındaki mesafeyi hesaplar
     */
    protected double calculateDistance(PoseLandmark p1, PoseLandmark p2) {
        if (p1 == null || p2 == null) return 0;
        
        double dx = p1.getPosition().x - p2.getPosition().x;
        double dy = p1.getPosition().y - p2.getPosition().y;
        return Math.sqrt(dx * dx + dy * dy);
    }
    
    /**
     * Üç nokta arasındaki açıyı hesaplar
     */
    protected double calculateAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
        if (p1 == null || p2 == null || p3 == null) return 0;
        
        double dx1 = p1.getPosition().x - p2.getPosition().x;
        double dy1 = p1.getPosition().y - p2.getPosition().y;
        double dx2 = p3.getPosition().x - p2.getPosition().x;
        double dy2 = p3.getPosition().y - p2.getPosition().y;
        
        double angle1 = Math.atan2(dy1, dx1);
        double angle2 = Math.atan2(dy2, dx2);
        
        double angleDiff = Math.abs(angle1 - angle2);
        return Math.toDegrees(angleDiff);
    }
    
    /**
     * Gerekli landmark'ların mevcut olup olmadığını kontrol eder
     */
    protected boolean areLandmarksAvailable(Pose pose, int... landmarkTypes) {
        for (int type : landmarkTypes) {
            if (pose.getPoseLandmark(type) == null) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Accuracy değerine göre poz kalitesi döndürür
     */
    protected String getPoseQualityFromAccuracy(double accuracy) {
        if (accuracy > 0.85) return "Mükemmel";
        if (accuracy > 0.7) return "İyi";
        if (accuracy > 0.5) return "Orta";
        return "Kötü";
    }
    
    public String getExerciseName() {
        return exerciseName;
    }
    
    public String getExerciseType() {
        return exerciseType;
    }
} 