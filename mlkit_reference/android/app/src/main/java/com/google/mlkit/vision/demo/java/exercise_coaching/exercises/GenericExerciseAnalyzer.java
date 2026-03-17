package com.google.mlkit.vision.demo.java.exercise_coaching.exercises;

import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;
import com.google.mlkit.vision.pose.Pose;
import java.util.List;
import java.util.Map;

public class GenericExerciseAnalyzer extends BaseExerciseAnalyzer {
    private final Map<String, Object> rules;
    private final List<Map<String, Object>> feedbackRules;

    public GenericExerciseAnalyzer(String exerciseName, String exerciseType, Map<String, Object> rules, List<Map<String, Object>> feedbackRules) {
        super(exerciseName, exerciseType);
        this.rules = rules;
        this.feedbackRules = feedbackRules;
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Şimdilik örnek bir analiz sonucu döndür
        double accuracy = 0.9; // Dummy
        String feedback = "Harika! Generic analizör çalışıyor.";
        boolean isRepetitionComplete = false;
        String poseQuality = getPoseQualityFromAccuracy(accuracy);
        return new AnalysisResult(accuracy, feedback, isRepetitionComplete, poseQuality);
    }
} 