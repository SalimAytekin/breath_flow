package com.breathflow.app.java.exercise_coaching.exercises;

import com.google.mlkit.vision.pose.Pose;

/**
 * Tüm egzersiz analizörlerinin temel sınıfı.
 * Kullanıcı kendi egzersiz dosyalarını yazarak bu sınıfı extend edecek.
 */
public abstract class BaseExerciseAnalyzer {

    /**
     * Analiz sonucunu temsil eden sınıf
     */
    public static class AnalysisResult {
        public final double accuracy; // 0.0 - 1.0
        public final String feedback; // Kullanıcıya gösterilecek mesaj
        public final boolean isRepetitionComplete; // Tekrar tamamlandı mı?

        public AnalysisResult(double accuracy, String feedback, boolean isRepetitionComplete) {
            this.accuracy = accuracy;
            this.feedback = feedback;
            this.isRepetitionComplete = isRepetitionComplete;
        }

        public AnalysisResult(double accuracy, String feedback) {
            this(accuracy, feedback, false);
        }
    }

    /**
     * Poz verisini analiz eder ve sonuç döndürür
     *
     * @param pose MLKit Pose nesnesi
     * @return Analiz sonucu (accuracy, feedback, repetition)
     */
    public abstract AnalysisResult analyze(Pose pose);

    /**
     * Analizörü sıfırlar (yeni egzersiz başladığında)
     */
    public void reset() {
        // Override edilebilir
    }
}
