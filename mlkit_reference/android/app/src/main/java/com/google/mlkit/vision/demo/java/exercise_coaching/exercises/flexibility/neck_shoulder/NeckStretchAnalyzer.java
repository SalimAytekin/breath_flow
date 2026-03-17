package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.flexibility.neck_shoulder;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Neck Stretch (Boyun esnetme) egzersizi için analizör
 * Boyun kaslarını esnetmek ve gerginliği azaltmak için kullanılır
 */
public class NeckStretchAnalyzer extends BaseExerciseAnalyzer {

    private static final int NOSE = PoseLandmark.NOSE;
    private static final int LEFT_EAR = PoseLandmark.LEFT_EAR;
    private static final int RIGHT_EAR = PoseLandmark.RIGHT_EAR;
    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    
    // Hedef açılar (derece)
    private static final double TARGET_NECK_LATERAL_FLEXION = 30.0; // Yana eğilme açısı
    private static final double ANGLE_TOLERANCE = 8.0;
    
    // Hangi tarafa eğildiğini takip etmek için
    private boolean isStretchingLeft = false;
    private boolean isStretchingRight = false;
    
    public NeckStretchAnalyzer() {
        super("Neck Stretch (Boyun esnetme)", "neck_stretch");
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
        
        // Omuz orta noktasını hesapla
        double shoulderMidpointX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2;
        double shoulderMidpointY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2;
        
        // Kulak orta noktasını hesapla
        double earMidpointX = (leftEar.getPosition().x + rightEar.getPosition().x) / 2;
        double earMidpointY = (leftEar.getPosition().y + rightEar.getPosition().y) / 2;
        
        // Boyun lateral fleksiyon açısını hesapla
        double neckLateralFlexion = calculateNeckLateralFlexion(nose, leftEar, rightEar, shoulderMidpointX, shoulderMidpointY);
        
        // Hangi tarafa eğildiğini belirle
        determineStretchDirection(nose, earMidpointX, shoulderMidpointX);
        
        // Omuz pozisyonu kontrolü (bir omuz aşağıda tutulmalı)
        double shoulderAlignment = checkShoulderAlignment(leftShoulder, rightShoulder);
        
        // Accuracy hesapla
        double flexionAccuracy = calculateFlexionAccuracy(Math.abs(neckLateralFlexion));
        double shoulderAccuracy = calculateShoulderAccuracy(shoulderAlignment);
        double overallAccuracy = (flexionAccuracy * 0.7 + shoulderAccuracy * 0.3);
        
        // Feedback üret
        String feedback = generateFeedback(neckLateralFlexion, shoulderAlignment, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü (10 saniye tutma)
        boolean isRepetitionComplete = overallAccuracy > 0.8;
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Boyun lateral fleksiyon açısını hesaplar
     */
    private double calculateNeckLateralFlexion(PoseLandmark nose, PoseLandmark leftEar, PoseLandmark rightEar,
                                             double shoulderMidpointX, double shoulderMidpointY) {
        // Burun ile omuz orta noktası arasındaki açıyı hesapla
        double earMidpointX = (leftEar.getPosition().x + rightEar.getPosition().x) / 2;
        double earMidpointY = (leftEar.getPosition().y + rightEar.getPosition().y) / 2;
        
        // Dikey referans vektörü (düz boyun)
        double verticalX = 0;
        double verticalY = 1;
        
        // Boyun vektörü (kulak orta noktası - omuz orta noktası)
        double neckVectorX = earMidpointX - shoulderMidpointX;
        double neckVectorY = earMidpointY - shoulderMidpointY;
        
        // İki vektör arasındaki açıyı hesapla
        double dotProduct = neckVectorX * verticalX + neckVectorY * verticalY;
        double neckVectorMagnitude = Math.sqrt(neckVectorX * neckVectorX + neckVectorY * neckVectorY);
        double verticalMagnitude = Math.sqrt(verticalX * verticalX + verticalY * verticalY);
        
        double cosTheta = dotProduct / (neckVectorMagnitude * verticalMagnitude);
        cosTheta = Math.max(-1.0, Math.min(1.0, cosTheta)); // Clamp to [-1, 1]
        
        double angleRadians = Math.acos(cosTheta);
        double angleDegrees = Math.toDegrees(angleRadians);
        
        // Sağa eğilme pozitif, sola eğilme negatif olacak şekilde işaretle
        if (neckVectorX > 0) {
            return angleDegrees; // Sağa eğilme
        } else {
            return -angleDegrees; // Sola eğilme
        }
    }
    
    /**
     * Hangi tarafa eğildiğini belirler
     */
    private void determineStretchDirection(PoseLandmark nose, double earMidpointX, double shoulderMidpointX) {
        double noseX = nose.getPosition().x;
        
        // Burun pozisyonuna göre eğilme yönünü belirle
        if (noseX < earMidpointX - 10) { // Sol tarafa eğilme
            isStretchingLeft = true;
            isStretchingRight = false;
        } else if (noseX > earMidpointX + 10) { // Sağ tarafa eğilme
            isStretchingRight = true;
            isStretchingLeft = false;
        } else {
            // Nötr pozisyon
            isStretchingLeft = false;
            isStretchingRight = false;
        }
    }
    
    /**
     * Omuz hizalamasını kontrol eder (bir omuz aşağıda tutulmalı)
     */
    private double checkShoulderAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double leftShoulderY = leftShoulder.getPosition().y;
        double rightShoulderY = rightShoulder.getPosition().y;
        
        double shoulderHeightDifference = Math.abs(leftShoulderY - rightShoulderY);
        
        // Omuzlar arasında yeterli yükseklik farkı olmalı (esnetme sırasında)
        if (isStretchingLeft || isStretchingRight) {
            return shoulderHeightDifference; // Fark ne kadar fazlaysa o kadar iyi
        } else {
            // Nötr pozisyonda omuzlar hizalı olmalı
            return Math.max(0, 50 - shoulderHeightDifference); // Fark az olmalı
        }
    }
    
    /**
     * Fleksiyon açısı için accuracy hesaplar
     */
    private double calculateFlexionAccuracy(double flexionAngle) {
        double targetAngle = TARGET_NECK_LATERAL_FLEXION;
        double difference = Math.abs(flexionAngle - targetAngle);
        
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
     * Omuz hizalaması için accuracy hesaplar
     */
    private double calculateShoulderAccuracy(double shoulderAlignment) {
        if (isStretchingLeft || isStretchingRight) {
            // Esnetme sırasında omuz farkı olmalı
            if (shoulderAlignment > 30) {
                return 1.0; // İyi omuz pozisyonu
            } else if (shoulderAlignment > 20) {
                return 0.8;
            } else {
                return 0.5; // Omuz pozisyonu yetersiz
            }
        } else {
            // Nötr pozisyonda omuzlar hizalı olmalı
            if (shoulderAlignment > 40) {
                return 1.0; // İyi hizalama
            } else if (shoulderAlignment > 30) {
                return 0.8;
            } else {
                return 0.6;
            }
        }
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double neckLateralFlexion, double shoulderAlignment, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Boyun esnetmesini doğru yapıyorsunuz";
        }
        
        double flexionAngle = Math.abs(neckLateralFlexion);
        
        if (flexionAngle < TARGET_NECK_LATERAL_FLEXION - ANGLE_TOLERANCE * 2) {
            return "Başınızı biraz daha yana eğin";
        } else if (flexionAngle > TARGET_NECK_LATERAL_FLEXION + ANGLE_TOLERANCE * 2) {
            return "Başınızı fazla eğmeyin, daha yumuşak olsun";
        } else if (shoulderAlignment < 20 && (isStretchingLeft || isStretchingRight)) {
            return "Karşı omzunuzu aşağıda tutun";
        } else if (!isStretchingLeft && !isStretchingRight) {
            return "Başınızı yana doğru eğmeye başlayın";
        } else {
            return "İyi! Pozisyonu koruyun ve yumuşak esnetin";
        }
    }
} 