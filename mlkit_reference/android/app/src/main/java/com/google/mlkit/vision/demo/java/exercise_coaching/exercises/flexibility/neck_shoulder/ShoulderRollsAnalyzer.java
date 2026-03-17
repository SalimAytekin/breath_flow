package com.google.mlkit.vision.demo.java.exercise_coaching.exercises.flexibility.neck_shoulder;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.demo.java.exercise_coaching.exercises.BaseExerciseAnalyzer;

/**
 * Shoulder Rolls (Omuz çevirme) egzersizi için analizör
 * Omuz kaslarını gevşetmek ve dolaşımı artırmak için yapılır
 */
public class ShoulderRollsAnalyzer extends BaseExerciseAnalyzer {

    private static final int LEFT_SHOULDER = PoseLandmark.LEFT_SHOULDER;
    private static final int RIGHT_SHOULDER = PoseLandmark.RIGHT_SHOULDER;
    private static final int LEFT_ELBOW = PoseLandmark.LEFT_ELBOW;
    private static final int RIGHT_ELBOW = PoseLandmark.RIGHT_ELBOW;
    private static final int LEFT_WRIST = PoseLandmark.LEFT_WRIST;
    private static final int RIGHT_WRIST = PoseLandmark.RIGHT_WRIST;
    private static final int LEFT_HIP = PoseLandmark.LEFT_HIP;
    private static final int RIGHT_HIP = PoseLandmark.RIGHT_HIP;
    private static final int NOSE = PoseLandmark.NOSE;
    
    // Hareket fazları
    private enum ShoulderRollPhase {
        NEUTRAL,    // Başlangıç pozisyonu
        UP,         // Omuzlar yukarıda
        BACK,       // Omuzlar geriye
        DOWN,       // Omuzlar aşağıda
        FORWARD     // Omuzlar öne
    }
    
    // Hedef değerler
    private static final double MIN_SHOULDER_MOVEMENT = 15.0; // Minimum omuz hareketi (piksel)
    private static final double TARGET_POSTURE_ALIGNMENT = 0.8; // Postür hizalaması
    
    private ShoulderRollPhase currentPhase = ShoulderRollPhase.NEUTRAL;
    private int rollCount = 0;
    private boolean isRollingForward = true; // İleri mi geri mi
    
    // Başlangıç pozisyonu referansı
    private double initialShoulderY = 0.0;
    private double initialShoulderX = 0.0;
    private boolean hasInitialPosition = false;
    
    public ShoulderRollsAnalyzer() {
        super("Shoulder Rolls (Omuz çevirme)", "shoulder_rolls");
    }

    @Override
    public AnalysisResult analyze(Pose pose) {
        // Gerekli landmark'ları kontrol et
        if (!areLandmarksAvailable(pose, LEFT_SHOULDER, RIGHT_SHOULDER, LEFT_ELBOW, RIGHT_ELBOW,
                LEFT_WRIST, RIGHT_WRIST, LEFT_HIP, RIGHT_HIP, NOSE)) {
            return new AnalysisResult(0.0, "Lütfen kameranın sizi tam görebildiğinden emin olun", false, "Görünmüyor");
        }
        
        // Landmark'ları al
        PoseLandmark leftShoulder = pose.getPoseLandmark(LEFT_SHOULDER);
        PoseLandmark rightShoulder = pose.getPoseLandmark(RIGHT_SHOULDER);
        PoseLandmark leftElbow = pose.getPoseLandmark(LEFT_ELBOW);
        PoseLandmark rightElbow = pose.getPoseLandmark(RIGHT_ELBOW);
        PoseLandmark leftWrist = pose.getPoseLandmark(LEFT_WRIST);
        PoseLandmark rightWrist = pose.getPoseLandmark(RIGHT_WRIST);
        PoseLandmark leftHip = pose.getPoseLandmark(LEFT_HIP);
        PoseLandmark rightHip = pose.getPoseLandmark(RIGHT_HIP);
        PoseLandmark nose = pose.getPoseLandmark(NOSE);
        
        // İlk pozisyonu kaydet
        if (!hasInitialPosition) {
            initialShoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
            initialShoulderX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
            hasInitialPosition = true;
        }
        
        // Dik duruş pozisyonu kontrolü
        boolean isInStandingPosition = checkStandingPosition(leftShoulder, rightShoulder, leftHip, rightHip);
        
        // Omuz hareketi analizi
        double shoulderMovement = calculateShoulderMovement(leftShoulder, rightShoulder);
        
        // Kol pozisyonu kontrolü (kollar rahat aşağıda olmalı)
        double armPosition = checkArmPosition(leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist);
        
        // Hareket fazını güncelle
        updateShoulderRollPhase(leftShoulder, rightShoulder);
        
        // Postür hizalaması
        double postureAlignment = checkPostureAlignment(leftShoulder, rightShoulder, leftHip, rightHip, nose);
        
        // Simetri kontrolü
        double shoulderSymmetry = checkShoulderSymmetry(leftShoulder, rightShoulder);
        
        // Accuracy hesapla
        double positionAccuracy = isInStandingPosition ? 1.0 : 0.4;
        double movementAccuracy = calculateMovementAccuracy(shoulderMovement);
        double armAccuracy = calculateArmAccuracy(armPosition);
        double postureAccuracy = calculatePostureAccuracy(postureAlignment);
        double symmetryAccuracy = calculateSymmetryAccuracy(shoulderSymmetry);
        
        double overallAccuracy = (positionAccuracy * 0.2 + movementAccuracy * 0.3 + 
                                armAccuracy * 0.2 + postureAccuracy * 0.2 + symmetryAccuracy * 0.1);
        
        // Feedback üret
        String feedback = generateFeedback(shoulderMovement, isInStandingPosition, armPosition, 
                                         postureAlignment, shoulderSymmetry, overallAccuracy);
        
        // Poz kalitesi
        String poseQuality = getPoseQualityFromAccuracy(overallAccuracy);
        
        // Tekrar tamamlanma kontrolü
        boolean isRepetitionComplete = checkRollComplete(overallAccuracy);
        
        return new AnalysisResult(overallAccuracy, feedback, isRepetitionComplete, poseQuality);
    }
    
    /**
     * Dik duruş pozisyonunu kontrol eder
     */
    private boolean checkStandingPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                        PoseLandmark leftHip, PoseLandmark rightHip) {
        // Omuzlar kalçaların üstünde olmalı
        double shoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double hipY = (leftHip.getPosition().y + rightHip.getPosition().y) / 2.0;
        
        return shoulderY < hipY; // Y koordinatı ters olduğu için
    }
    
    /**
     * Omuz hareketini hesaplar
     */
    private double calculateShoulderMovement(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        if (initialShoulderY == 0.0) {
            return 0.0;
        }
        
        double currentShoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double currentShoulderX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        
        // Başlangıç pozisyonundan ne kadar uzaklaştı
        double verticalMovement = Math.abs(currentShoulderY - initialShoulderY);
        double horizontalMovement = Math.abs(currentShoulderX - initialShoulderX);
        
        return Math.max(verticalMovement, horizontalMovement);
    }
    
    /**
     * Kol pozisyonunu kontrol eder
     */
    private double checkArmPosition(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                   PoseLandmark leftElbow, PoseLandmark rightElbow,
                                   PoseLandmark leftWrist, PoseLandmark rightWrist) {
        // Kollar rahat aşağıda olmalı
        double leftArmRelaxed = checkArmRelaxed(leftShoulder, leftElbow, leftWrist);
        double rightArmRelaxed = checkArmRelaxed(rightShoulder, rightElbow, rightWrist);
        
        return (leftArmRelaxed + rightArmRelaxed) / 2.0;
    }
    
    /**
     * Tek kol rahatlığını kontrol eder
     */
    private double checkArmRelaxed(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
        // Dirsek omuzun altında olmalı
        boolean elbowBelow = elbow.getPosition().y > shoulder.getPosition().y;
        
        // El dirseğin altında olmalı
        boolean wristBelow = wrist.getPosition().y > elbow.getPosition().y;
        
        // Kol çok gergin olmamalı (açı kontrol)
        double armAngle = calculateAngle(shoulder, elbow, wrist);
        boolean armNotTense = armAngle > 150.0 && armAngle < 200.0; // Rahat açı
        
        int score = 0;
        if (elbowBelow) score++;
        if (wristBelow) score++;
        if (armNotTense) score++;
        
        return score / 3.0;
    }
    
    /**
     * Omuz çevirme fazını günceller
     */
    private void updateShoulderRollPhase(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        if (initialShoulderY == 0.0) return;
        
        double currentShoulderY = (leftShoulder.getPosition().y + rightShoulder.getPosition().y) / 2.0;
        double currentShoulderX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        
        double verticalDiff = currentShoulderY - initialShoulderY;
        double horizontalDiff = currentShoulderX - initialShoulderX;
        
        // Faz geçişlerini kontrol et
        if (isRollingForward) {
            // İleri çevirme: UP -> FORWARD -> DOWN -> BACK -> UP
            switch (currentPhase) {
                case NEUTRAL:
                    if (verticalDiff < -MIN_SHOULDER_MOVEMENT) {
                        currentPhase = ShoulderRollPhase.UP;
                    }
                    break;
                case UP:
                    if (horizontalDiff > MIN_SHOULDER_MOVEMENT) {
                        currentPhase = ShoulderRollPhase.FORWARD;
                    }
                    break;
                case FORWARD:
                    if (verticalDiff > MIN_SHOULDER_MOVEMENT) {
                        currentPhase = ShoulderRollPhase.DOWN;
                    }
                    break;
                case DOWN:
                    if (horizontalDiff < -MIN_SHOULDER_MOVEMENT) {
                        currentPhase = ShoulderRollPhase.BACK;
                    }
                    break;
                case BACK:
                    if (Math.abs(verticalDiff) < MIN_SHOULDER_MOVEMENT/2 && 
                        Math.abs(horizontalDiff) < MIN_SHOULDER_MOVEMENT/2) {
                        currentPhase = ShoulderRollPhase.NEUTRAL;
                        rollCount++;
                    }
                    break;
            }
        }
    }
    
    /**
     * Postür hizalamasını kontrol eder
     */
    private double checkPostureAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
                                       PoseLandmark leftHip, PoseLandmark rightHip, PoseLandmark nose) {
        // Kafa omuzların ortasında olmalı
        double shoulderMidX = (leftShoulder.getPosition().x + rightShoulder.getPosition().x) / 2.0;
        double headAlignment = Math.abs(nose.getPosition().x - shoulderMidX);
        
        // Omuzlar kalçalarla hizalı olmalı
        double hipMidX = (leftHip.getPosition().x + rightHip.getPosition().x) / 2.0;
        double bodyAlignment = Math.abs(shoulderMidX - hipMidX);
        
        double headScore = Math.max(0.0, 1.0 - (headAlignment / 50.0));
        double bodyScore = Math.max(0.0, 1.0 - (bodyAlignment / 30.0));
        
        return (headScore + bodyScore) / 2.0;
    }
    
    /**
     * Omuz simetrisini kontrol eder
     */
    private double checkShoulderSymmetry(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
        double shoulderHeightDiff = Math.abs(leftShoulder.getPosition().y - rightShoulder.getPosition().y);
        
        return Math.max(0.0, 1.0 - (shoulderHeightDiff / 30.0)); // 30 piksel tolerans
    }
    
    /**
     * Hareket accuracy'si hesaplar
     */
    private double calculateMovementAccuracy(double shoulderMovement) {
        if (shoulderMovement >= MIN_SHOULDER_MOVEMENT) {
            return 1.0; // Yeterli hareket
        } else if (shoulderMovement >= MIN_SHOULDER_MOVEMENT * 0.7) {
            return 0.8; // İyi
        } else if (shoulderMovement >= MIN_SHOULDER_MOVEMENT * 0.5) {
            return 0.6; // Orta
        } else {
            return 0.4; // Zayıf
        }
    }
    
    /**
     * Kol pozisyonu accuracy'si hesaplar
     */
    private double calculateArmAccuracy(double armPosition) {
        return armPosition; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Postür accuracy'si hesaplar
     */
    private double calculatePostureAccuracy(double postureAlignment) {
        return postureAlignment; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Simetri accuracy'si hesaplar
     */
    private double calculateSymmetryAccuracy(double shoulderSymmetry) {
        return shoulderSymmetry; // Zaten 0-1 arasında normalize
    }
    
    /**
     * Çevirme tamamlanma kontrolü
     */
    private boolean checkRollComplete(double overallAccuracy) {
        return overallAccuracy > 0.7 && rollCount > 0 && currentPhase == ShoulderRollPhase.NEUTRAL;
    }
    
    /**
     * Kullanıcıya feedback üretir
     */
    private String generateFeedback(double shoulderMovement, boolean isInStandingPosition,
                                   double armPosition, double postureAlignment, 
                                   double shoulderSymmetry, double overallAccuracy) {
        if (overallAccuracy > 0.85) {
            return "Mükemmel! Omuz çevirme hareketini doğru yapıyorsunuz";
        }
        
        if (!isInStandingPosition) {
            return "Dik durun ve omuz çevirme hareketine başlayın";
        }
        
        // Faza göre feedback
        switch (currentPhase) {
            case NEUTRAL:
                return "Omuzlarınızı yukarı kaldırarak çevirmeye başlayın";
            case UP:
                return "Omuzlarınızı öne doğru çevirin";
            case FORWARD:
                return "Omuzlarınızı aşağı indirin";
            case DOWN:
                return "Omuzlarınızı geriye doğru çevirin";
            case BACK:
                return "Omuzlarınızı başlangıç pozisyonuna getirin";
            default:
                if (shoulderMovement < MIN_SHOULDER_MOVEMENT * 0.7) {
                    return "Omuzlarınızı daha geniş çevirmeye çalışın";
                } else if (armPosition < 0.6) {
                    return "Kollarınızı rahat bırakın ve sadece omuzları çevirin";
                } else if (postureAlignment < 0.6) {
                    return "Dik durun ve kafanızı ortalayın";
                } else if (shoulderSymmetry < 0.6) {
                    return "Her iki omzunuzu eşit şekilde çevirin";
                } else {
                    return "İyi! Omuz çevirme hareketini devam ettirin";
                }
        }
    }
} 