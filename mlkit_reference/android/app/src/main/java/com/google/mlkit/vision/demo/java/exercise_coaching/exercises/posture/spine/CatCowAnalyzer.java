package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.posture.spine;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Cat-Cow (Kedi-İnek) egzersizi için analizör
 * Omurga mobilitesini artıran egzersiz
 */
public class CatCowAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int LEFT_KNEE = PoseLandmark.LEFT_KNEE;
    private static final int RIGHT_KNEE = PoseLandmark.RIGHT_KNEE;
    private static final int LEFT_WRIST = PoseLandmark.LEFT_WRIST;
    private static final int RIGHT_WRIST = PoseLandmark.RIGHT_WRIST;
    private static final int NOSE = PoseLandmark.NOSE;
    
    // Hedef açılar (derece)
    private static final double TARGET_SPINE_ARCH_COW = 160.0;    // İnek pozisyonu (sırt aşağı)
    private static final double TARGET_SPINE_ARCH_CAT = 200.0;    // Kedi pozisyonu (sırt yukarı)
    private static final double NEUTRAL_SPINE_ANGLE = 180.0;     // Nötr pozisyon
    private static final double ANGLE_TOLERANCE = 12.0;
    
    // Hareket fazları
    private enum CatCowPhase {
        NEUTRAL,     // Başlangıç pozisyonu
        COW,         // İnek pozisyonu (sırt aşağı)
        CAT,         // Kedi pozisyonu (sırt yukarı)
        TRANSITION   // Geçiş fazı
    }
    
    private CatCowPhase currentPhase = CatCowPhase.NEUTRAL;
    private int cycleCount = 0;
    
    public CatCowAnalyzer() {
        super("Cat-Cow (Kedi-İnek)", "cat_cow");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_HIP, RIGHT_HIP,
                LEFT_KNEE, RIGHT_KNEE, LEFT_WRIST, RIGHT_WRIST, NOSE)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        PoseLandmark leftHip = pose.getPoseLandmark(LEFT_HIP);
        PoseLandmark rightHip = pose.getPoseLandmark(RIGHT_HIP);
        PoseLandmark leftKnee = pose.getPoseLandmark(LEFT_KNEE);
        PoseLandmark rightKnee = pose.getPoseLandmark(RIGHT_KNEE);
        PoseLandmark leftWrist = pose.getPoseLandmark(LEFT_WRIST);
        PoseLandmark rightWrist = pose.getPoseLandmark(RIGHT_WRIST);
        PoseLandmark nose = pose.getPoseLandmark(NOSE);
        
        // Dört ayak pozisyonu kontrolü
        boolean isInQuadrupedPosition = checkQuadrupedPosition(leftShoulder, rightShoulder, 
                                                             leftWrist, rightWrist, leftKnee, rightKnee);
        
        // Omurga eğrisi açısını hesapla
        double spineAngle = calculateSpineAngle(leftShoulder, rightShoulder, leftHip, rightHip);
        
        // Kafa pozisyonu kontrolü
        double headPosition = checkHeadPosition(nose, leftShoulder, rightShoulder);
        
        // Hareket fazını güncelle
        updateCatCowPhase(spineAngle);
        
        // El ve diz pozisyonu kontrolü
        double limbAlignment = checkLimbAlignment(leftShoulder, rightShoulder, leftWrist, rightWrist,
                                                leftHip, rightHip, leftKnee, rightKnee);
        
        // Accuracy hesapla
        double positionAccuracy = isInQuadrupedPosition ? 1.0 : 0.3;
        double spineAccuracy = calculateSpineAccuracy(spineAngle);
        double headAccuracy = calculateHeadAccuracy(headPosition);
        double limbAccuracy = calculateLimbAccuracy(limbAlignment);
        
        double overallAccuracy = (positionAccuracy * 0.3 + spineAccuracy * 0.4 + 
                                headAccuracy * 0.2 + limbAccuracy * 0.1);
        
        // Feedback üret
        String feedback = generateFeedback(spineAngle, isInQuadrupedPosition, headPosition, 
                                         limbAlignment, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = checkCycleComplete(overallAccuracy);
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Dört ayak pozisyonunda olup olmadığını kontrol eder
     */
    private boolean checkQuadrupedPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                         PoseLandmark leftWrist, PoseLandmark rightWrist,
                                         PoseLandmark leftKnee, PoseLandmark rightKnee) {
        // Eller omuzların altında olmalı
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double wristY = (leftWrist.getPosition().y + rightWrist.getPosition().y) / 2.0;
        
        // Dizler kalçaların altında olmalı (yaklaşık aynı X pozisyonunda)
        boolean handsUnderShoulders = wristY > shoulderY; // Y koordinatı ters
        
        return handsUnderShoulders; // Basit kontrol
    }
    
    /**
     * Omurga açısını hesaplar
     */
    private double calculateSpineAngle(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                     PoseLandmark leftHip, PoseLandmark rightHip) {
        // Omuz orta noktası
        double shoulderMidX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        double shoulderMidY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        
        // Kalça orta noktası
        double hipMidX = (leftHip.getPosition().x + rightHip.getPosition().x) / 2.0;
        double hipMidY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        
        // Omurga vektörü
        double spineVectorX = shoulderMidX - hipMidX;
        double spineVectorY = shoulderMidY - hipMidY;
        
        // Yatay referans vektörü
        double horizontalX = 1.0;
        double horizontalY = 0.0;
        
        // Açıyı hesapla
        double dotProduct = spineVectorX * horizontalX + spineVectorY * horizontalY;
        double spineVectorMagnitude = Math.sqrt(spineVectorX * spineVectorX + spineVectorY * spineVectorY);
        
        double cosTheta = dotProduct / spineVectorMagnitude;
        cosTheta = Math.max(-1.0, Math.min(1.0, cosTheta));
        
        double angleRadians = Math.acos(cosTheta);
        return Math.toDegrees(angleRadians);
    }
    
    /**
     * Kafa pozisyonunu kontrol eder
     */
    private double checkHeadPosition(PoseLandmark nose, PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double shoulderMidY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double noseY = nose.getPosition().y;
        
        // Kafa omuzlarla aynı hizada olmalı (nötr pozisyon)
        double headAlignment = Math.abs(noseY - shoulderMidY);
        
        // Ne kadar az fark o kadar iyi
        return Math.max(0.0, 1.0 - (headAlignment / 100.0)); // 100 piksel tolerans
    }
    
    /**
     * El ve diz hizalamasını kontrol eder
     */
    private double checkLimbAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                    PoseLandmark leftWrist, PoseLandmark rightWrist,
                                    PoseLandmark leftHip, PoseLandmark rightHip,
                                    PoseLandmark leftKnee, PoseLandmark rightKnee) {
        // El-omuz hizalaması
        double leftHandAlignment = Math.abs(leftShoulder.getPosition().x - leftWrist.getPosition().x);
        double rightHandAlignment = Math.abs(rightShoulder.getPosition().x - rightWrist.getPosition().x);
        double handAlignment = (leftHandAlignment + rightHandAlignment) / 2.0;
        
        // Diz-kalça hizalaması
        double leftKneeAlignment = Math.abs(leftHip.getPosition().x - leftKnee.getPosition().x);
        double rightKneeAlignment = Math.abs(rightHip.getPosition().x - rightKnee.getPosition().x);
        double kneeAlignment = (leftKneeAlignment + rightKneeAlignment) / 2.0;
        
        // Ortalama hizalama
        double averageAlignment = (handAlignment + kneeAlignment) / 2.0;
        
        return Math.max(0.0, 1.0 - (averageAlignment / 50.0)); // 50 piksel tolerans
    }
    
    /**
     * Cat-Cow hareketinin fazını günceller
     */
    private void updateCatCowPhase(double spineAngle) {
        switch (currentPhase) {
            case NEUTRAL:
                if (spineAngle < TARGET_SPINE_ARCH_COW + ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.COW;
                } else if (spineAngle > TARGET_SPINE_ARCH_CAT - ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.CAT;
                }
                break;
            case COW:
                if (spineAngle > TARGET_SPINE_ARCH_CAT - ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.CAT;
                } else if (Math.abs(spineAngle - NEUTRAL_SPINE_ANGLE) < ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.NEUTRAL;
                }
                break;
            case CAT:
                if (spineAngle < TARGET_SPINE_ARCH_COW + ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.COW;
                    cycleCount++; // Tam döngü tamamlandı
                } else if (Math.abs(spineAngle - NEUTRAL_SPINE_ANGLE) < ANGLE_TOLERANCE) {
                    currentPhase = CatCowPhase.NEUTRAL;
                }
                break;
            case TRANSITION:
                // Geçiş fazı mantığı
                break;
        }
    }
    
    /**
     * Omurga açısı için accuracy hesaplar
     */
    private double calculateSpineAccuracy(double spineAngle) {
        double targetAngle;
        
        switch (currentPhase) {
            case COW:
                targetAngle = TARGET_SPINE_ARCH_COW;
                break;
            case CAT:
                targetAngle = TARGET_SPINE_ARCH_CAT;
                break;
            case NEUTRAL:
                targetAngle = NEUTRAL_SPINE_ANGLE;
                break;
            default:
                return 0.7; // Geçiş fazında orta skor
        }
        
        double difference = Math.abs(spineAngle - targetAngle);
        
        if (difference <= ANGLE_TOLERANCE) {
            return 1.0; // Mükemmel açı
        } else if (difference <= ANGLE_TOLERANCE * 2) {
            return 0.8; // İyi
        } else if (difference <= ANGLE_TOLERANCE * 3) {
            return 0.6; // Orta
        } else {
            return 0.4; // Zayıf
        }
    }
    
    /**
     * Kafa pozisyonu accuracy'si hesaplar
     */
    private double calculateHeadAccuracy(double headPosition) {
        return headPosition; // Zaten 0-1 arasında normalize
    }
    
    /**
     * El-diz hizalaması accuracy'si hesaplar
     */
    private double calculateLimbAccuracy(double limbAlignment) {
        return limbAlignment; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Döngü tamamlanma kontrolü
     */
    private boolean checkCycleComplete(double overallAccuracy) {
        return overallAccuracy > 0.8 && currentPhase == CatCowPhase.COW && cycleCount > 0;
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double spineAngle, boolean isInQuadrupedPosition,
                                   double headPosition, double limbAlignment, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Cat-Cow hareketini doğru yapıyorsunuz";
        }
        
        if (!isInQuadrupedPosition) {
            return "Dört ayak pozisyonuna geçin - eller omuzların altında, dizler kalçaların altında";
        }
        
        // Faza göre feedback
        switch (currentPhase) {
            case NEUTRAL:
                return "Başlangıç pozisyonunda - sırtınızı yukarı kaldırın (kedi) veya aşağı indirin (inek)";
            case COW:
                return "İnek pozisyonu - şimdi sırtınızı yukarı kaldırın (kedi pozisyonu)";
            case CAT:
                return "Kedi pozisyonu - şimdi sırtınızı aşağı indirin (inek pozisyonu)";
            default:
                if (headPosition < 0.6) {
                    return "Kafanızı nötr pozisyonda tutun";
                } else if (limbAlignment < 0.6) {
                    return "Ellerinizi omuzların altında, dizleri kalçaların altında tutun";
                } else {
                    return "İyi! Hareket devam ediyor";
                }
        }
    }
} 