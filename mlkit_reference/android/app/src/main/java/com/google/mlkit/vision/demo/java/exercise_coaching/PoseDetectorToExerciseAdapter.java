package com.google.mlkit.vision.demo.java.exercise_coaching;

import android.util.Log;
import com.google.mlkit.vision.pose.Pose;

/**
 * PoseDetectorProcessor ile ExerciseCoachProcessor arasındaki adapter sınıfı.
 * Bu sınıf, algılanan pozları egzersiz koçluk sisteminize aktarmak için kullanılır.
 */
public class PoseDetectorToExerciseAdapter {
    private static final String TAG = "PoseAdapter";
    
    private static ExerciseCoachProcessor exerciseCoachProcessor;
    private static boolean enabled = false;
    
    /**
     * ExerciseCoachProcessor'ı ayarlar
     * 
     * @param processor ExerciseCoachProcessor
     */
    public static void setExerciseCoachProcessor(ExerciseCoachProcessor processor) {
        exerciseCoachProcessor = processor;
        Log.d(TAG, "ExerciseCoachProcessor set");
    }
    
    /**
     * Adapter'ın etkin olup olmadığını ayarlar
     * 
     * @param isEnabled Etkin durumu
     */
    public static void setEnabled(boolean isEnabled) {
        enabled = isEnabled;
        Log.d(TAG, "Adapter enabled: " + enabled);
    }
    
    /**
     * Poses are sent from the PoseDetectorProcessor to the ExerciseCoachProcessor
     * 
     * @param pose MLKit Pose nesnesi
     */
    public static void processPose(Pose pose) {
        if (!enabled || exerciseCoachProcessor == null || pose == null) {
            return;
        }
        
        try {
            exerciseCoachProcessor.processPose(pose);
        } catch (Exception e) {
            Log.e(TAG, "Error processing pose", e);
        }
    }
}
