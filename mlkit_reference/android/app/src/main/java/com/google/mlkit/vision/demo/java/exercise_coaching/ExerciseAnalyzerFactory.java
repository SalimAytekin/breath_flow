package com.google.mlkit.vision.demo.java.exercise_coaching;

import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.GenericExerciseAnalyzer;

// ===== YENİ KATEGORİ SİSTEMİ =====
// Postür & Duruş
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.neck.ChinTuckAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.shoulder.ScapularSqueezeAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.shoulder.WallAngelsAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine.BirdDogAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine.CatCowAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine.SupermanAnalyzer;

// Esneklik & Mobilite
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.flexibility.neck_shoulder.NeckStretchAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.flexibility.neck_shoulder.ShoulderRollsAnalyzer;

// Güç & Kuvvet
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.lower_body.SquatAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.core.PlankAnalyzer;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.strength.upper_body.PushUpAnalyzer;

import java.util.List;
import java.util.Map;

/**
 * Egzersiz analizörleri için Factory sınıfı
 * Yeni kategori sistemine göre düzenlenmiştir:
 * - posture/ (Postür & Duruş)
 * - flexibility/ (Esneklik & Mobilite)  
 * - strength/ (Güç & Kuvvet)
 * - balance/ (Denge & Koordinasyon)
 * - breathing/ (Nefes & Rahatlama)
 */
public class ExerciseAnalyzerFactory {
    
    /**
     * Egzersiz ID'sine göre uygun analizörü döndürür
     * exercises.json'daki "id" alanı kullanılır
     */
    public static BaseExerciseAnalyzer createAnalyzer(String exerciseId) {
        if (exerciseId == null) {
            return null;
        }
        
        switch (exerciseId.toLowerCase()) {
            
            // ===== POSTÜR & DURUŞ =====
            // Boyun Postürü
            case "chin_tuck":
                return new ChinTuckAnalyzer();
                
            // Omuz Postürü
            case "scapular_squeeze":
                return new ScapularSqueezeAnalyzer();
                
            // Omurga Desteği
            case "cat_cow":
                return new CatCowAnalyzer();
                
            case "superman":
                return new SupermanAnalyzer();
                
            case "bird_dog":
                return new BirdDogAnalyzer();
                
            // Ayakta Duruş
            case "wall_angels":
                return new WallAngelsAnalyzer();
                
            // ===== ESNEKLİK & MOBİLİTE =====
            // Boyun & Omuz
            case "neck_stretch":
                return new NeckStretchAnalyzer();
                
            case "shoulder_rolls":
                return new ShoulderRollsAnalyzer();
                
            // ===== GÜÇ & KUVVET =====
            // Core
            case "dead_bug":
                // TODO: Implement DeadBugAnalyzer
                return null;
                
            case "plank":
                return new PlankAnalyzer();
                
            case "glute_bridge":
                // TODO: Implement GluteBridgeAnalyzer
                return null;
                
            // Üst Vücut
            case "push_up":
                return new PushUpAnalyzer();
                
            // Alt Vücut
            case "squat":
                return new SquatAnalyzer();
                
            case "lunge":
                // TODO: Implement LungeAnalyzer
                return null;
                
            // ===== DENGE & KOORDİNASYON =====
            // TODO: Balance egzersizleri eklenecek
            
            // ===== NEFES & RAHATLAMA =====
            // TODO: Breathing egzersizleri eklenecek
            
            default:
                return null; // Desteklenmeyen egzersiz
        }
    }
    
    /**
     * Kural tabanlı generic analizör için overload
     */
    public static BaseExerciseAnalyzer createAnalyzer(String analyzerType, Map<String, Object> rules, List<Map<String, Object>> feedbackRules) {
        if ("default".equals(analyzerType)) {
            String exerciseName = rules != null && rules.containsKey("exerciseName") ? (String) rules.get("exerciseName") : "Generic";
            String exerciseType = rules != null && rules.containsKey("exerciseType") ? (String) rules.get("exerciseType") : "generic";
            return new GenericExerciseAnalyzer(exerciseName, exerciseType, rules, feedbackRules);
        }
        return null;
    }
    
    /**
     * Desteklenen egzersiz ID'lerini döndürür
     * exercises.json'daki "compatibleWithMLKit": true olan egzersizler
     */
    public static String[] getSupportedExerciseIds() {
        return new String[]{
            // Postür & Duruş
            "chin_tuck",        // ✅ Implemented
            "scapular_squeeze", // ✅ Implemented
            "cat_cow",          // ✅ Implemented
            "superman",         // ✅ Implemented
            "bird_dog",         // ✅ Implemented
            "wall_angels",      // ✅ Implemented
            
            // Esneklik & Mobilite
            "neck_stretch",     // ✅ Implemented
            "shoulder_rolls",   // ✅ Implemented
            
            // Güç & Kuvvet
            "dead_bug",         // TODO
            "plank",            // ✅ Implemented
            "glute_bridge",     // TODO
            "push_up",          // ✅ Implemented
            "squat",            // ✅ Implemented
            "lunge"             // TODO
        };
    }
    
    /**
     * Egzersiz ID'sinin desteklenip desteklenmediğini kontrol eder
     */
    public static boolean isExerciseSupported(String exerciseId) {
        return createAnalyzer(exerciseId) != null;
    }
    
    /**
     * Implementasyonu tamamlanan egzersizleri döndürür
     */
    public static String[] getImplementedExercises() {
        return new String[]{
            "chin_tuck",
            "scapular_squeeze",
            "cat_cow",
            "superman",
            "bird_dog",
            "wall_angels",
            "neck_stretch",
            "shoulder_rolls",
            "plank",
            "push_up",
            "squat"
        };
    }
    
    /**
     * TODO listesindeki egzersizleri döndürür
     */
    public static String[] getTodoExercises() {
        return new String[]{
            "dead_bug",
            "glute_bridge",
            "lunge"
        };
    }
} 