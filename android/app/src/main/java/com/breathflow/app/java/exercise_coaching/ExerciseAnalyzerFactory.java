package com.breathflow.app.java.exercise_coaching;

import com.breathflow.app.java.exercise_coaching.exercises.BaseExerciseAnalyzer;
import com.breathflow.app.java.exercise_coaching.exercises.GenericExerciseAnalyzer;
import com.breathflow.app.java.exercise_coaching.exercises.NeckSideBendAnalyzer;

import java.util.List;
import java.util.Map;

/**
 * Egzersiz analizörleri için Factory sınıfı.
 * Yeni egzersiz analizörleri buraya eklenerek genişletilebilir.
 */
public class ExerciseAnalyzerFactory {

    /**
     * Egzersiz ID'sine göre uygun analizörü döndürür.
     */
    public static BaseExerciseAnalyzer createAnalyzer(String exerciseId) {
        if (exerciseId == null)
            return null;

        switch (exerciseId.toLowerCase()) {

            // ✅ Implement edilmiş egzersizler
            case "neck_side_bend":
            case "neck_lateral_flexion":
            case "neckmovement": // Flutter ExerciseConfig.neckMovement()
                return new NeckSideBendAnalyzer();

            // Diğer egzersizler için generic analyzer
            default:
                return new GenericExerciseAnalyzer(exerciseId, exerciseId, null, null);
        }
    }

    /**
     * Kural tabanlı generic analizör
     */
    public static BaseExerciseAnalyzer createAnalyzer(String analyzerType, Map<String, Object> rules,
            List<Map<String, Object>> feedbackRules) {
        String exerciseName = rules != null && rules.containsKey("exerciseName") ? (String) rules.get("exerciseName")
                : "Generic";
        String exerciseType = rules != null && rules.containsKey("exerciseType") ? (String) rules.get("exerciseType")
                : "generic";
        return new GenericExerciseAnalyzer(exerciseName, exerciseType, rules, feedbackRules);
    }

    /**
     * Desteklenen egzersiz ID'lerini döndürür
     */
    public static String[] getSupportedExerciseIds() {
        return new String[] {
                "neck_side_bend",
                "neck_lateral_flexion",
                "neckmovement"
        };
    }
}