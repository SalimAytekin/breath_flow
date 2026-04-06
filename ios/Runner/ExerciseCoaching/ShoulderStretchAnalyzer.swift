import Foundation
import MLKitPoseDetection
import MLKitVision

/// Omuz Germe (Shoulder Stretch) Egzersizi Analizörü.
/// Kol-gövde açısını (wrist-shoulder-hip) kullanarak omuz mobilizasyonu analizi yapar.
/// Sağ kol kaldırma → hold → indirme → Sol kol kaldırma → hold → indirme = 1 tekrar
class ShoulderStretchAnalyzer: ExerciseAnalyzer {
    
    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private enum State {
        case waitingForPerson
        case ready
        case raisingRight
        case holdingRight
        case loweringRight
        case raisingLeft
        case holdingLeft
        case loweringLeft
        case restingSide
        case restingBetweenReps
        case repComplete
    }
    
    // ═══════════════════════════════════════════
    // Açı Eşikleri (Derece)
    // ═══════════════════════════════════════════
    private static let armDownAngle: Double = 30.0          // Kol aşağıda
    private static let raiseStartAngle: Double = 45.0       // Kaldırma algılama
    private static let goodPositionAngle: Double = 90.0     // İyi pozisyon (yatay)
    private static let targetAngle: Double = 130.0          // Hedef (daha esnek)
    private static let maxSafeAngle: Double = 170.0         // Güvenlik sınırı
    
    // Hız Kontrolü
    private static let maxAllowedSpeed: Double = 60.0       // Derece/saniye
    private static let speedWarningCooldownMs: Int64 = 2500
    private static let backLeanThreshold: Double = 20.0     // Sırt / postür eğilme limiti
    
    
    // Zamanlayıcılar
    private static let holdDurationMs: Int64 = 1500         // 1.5 saniye tutma
    private static let readyDelayMs: Int64 = 1000           // Hazırlanma süresi
    private static let restingDurationMs: Int64 = 1500      // Taraflar arası mola
    
    // ═══════════════════════════════════════════
    // State Değişkenleri
    // ═══════════════════════════════════════════
    private var currentState: State = .waitingForPerson
    private var holdStartTime: Int64 = 0
    private var readyStartTime: Int64 = 0
    private var repCount = 0
    private let targetReps = 5
    
    // Smoothing & Hız
    private var smoothedArmAngle: Double = 0.0
    private static let smoothingFactor: Double = 0.3
    private var lastTimestamp: Int64 = 0
    private var lastArmAngle: Double = 0.0
    private var lastSpeedWarningTime: Int64 = 0
    
    func analyze(pose: Pose) -> AnalysisResult {
        // ═══════════════════════════════════════════
        // Landmark Güvenilirlik Kontrolü
        // ═══════════════════════════════════════════
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightElbow = pose.landmark(ofType: .rightElbow)
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let rightWrist = pose.landmark(ofType: .rightWrist)
        let leftWrist = pose.landmark(ofType: .leftWrist)
        let rightHip = pose.landmark(ofType: .rightHip)
        let leftHip = pose.landmark(ofType: .leftHip)
        
        let minConfidence = min(
            min(min(rightShoulder.inFrameLikelihood, leftShoulder.inFrameLikelihood),
                min(rightElbow.inFrameLikelihood, leftElbow.inFrameLikelihood)),
            min(min(rightWrist.inFrameLikelihood, leftWrist.inFrameLikelihood),
                min(rightHip.inFrameLikelihood, leftHip.inFrameLikelihood))
        )
        
        if minConfidence < 0.3 {
            currentState = .waitingForPerson
            return AnalysisResult(accuracy: 0.0, feedback: "👤 Tüm vücudunuz görünmüyor.\nLütfen kameraya dönün.")
        }
        
        if minConfidence < 0.5 {
            return AnalysisResult(accuracy: 0.1, feedback: "👤 Poz algılama kalitesi düşük.\nLütfen iyi aydınlatılmış\nbir ortamda durun.")
        }
        
        // ═══════════════════════════════════════════
        // Kol-Gövde Açısı Hesaplama
        // ═══════════════════════════════════════════
        let isRightSide = (currentState == .raisingRight || currentState == .holdingRight || currentState == .loweringRight)
        let isLeftSide = (currentState == .raisingLeft || currentState == .holdingLeft || currentState == .loweringLeft)
        
        let armAngle: Double
        if isLeftSide {
            armAngle = calculateArmAngle(
                wrist: leftWrist.position,
                elbow: leftElbow.position,
                shoulder: leftShoulder.position,
                hip: leftHip.position
            )
        } else {
            // Default ve sağ taraf için sağ kolu ölç
            armAngle = calculateArmAngle(
                wrist: rightWrist.position,
                elbow: rightElbow.position,
                shoulder: rightShoulder.position,
                hip: rightHip.position
            )
        }
        
        // EMA Smoothing
        smoothedArmAngle = ShoulderStretchAnalyzer.smoothingFactor * armAngle + (1 - ShoulderStretchAnalyzer.smoothingFactor) * smoothedArmAngle
        let currentAngle = smoothedArmAngle
        
        // Hız Hesaplama
        let now = currentTimeMillis()
        var currentSpeed: Double = 0.0
        
        if lastTimestamp != 0 && now > lastTimestamp {
            let timeDiff = Double(now - lastTimestamp) / 1000.0
            if timeDiff > 0 {
                currentSpeed = abs(currentAngle - lastArmAngle) / timeDiff
            }
        }
        
        lastArmAngle = currentAngle
        lastTimestamp = now
        
        let backLean = calculateBackLean(
            shoulder: midpoint(rightShoulder.position, leftShoulder.position),
            hip: midpoint(rightHip.position, leftHip.position)
        )
        
        let debugInfo: [String: Any]? = [
            "rightArmAngle": String(format: "%.1f°", calculateArmAngle(wrist: rightWrist.position, elbow: rightElbow.position, shoulder: rightShoulder.position, hip: rightHip.position)),
            "leftArmAngle": String(format: "%.1f°", calculateArmAngle(wrist: leftWrist.position, elbow: leftElbow.position, shoulder: leftShoulder.position, hip: leftHip.position)),
            "speed": String(format: "%.1f°/sn", currentSpeed),
            "state": String(describing: currentState),
            "backLean": String(format: "%.1f°", backLean)
        ]
        
        return processState(armAngle: currentAngle, currentSpeed: currentSpeed, backLean: backLean, now: now, debugInfo: debugInfo)
    }
    
    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private func processState(armAngle: Double, currentSpeed: Double, backLean: Double,
                            now: Int64, debugInfo: [String: Any]?) -> AnalysisResult {
        
        // Postür (Diklik) Kontrolü
        let isHoldingOrRaising = (currentState == .raisingRight || currentState == .holdingRight ||
                                  currentState == .raisingLeft || currentState == .holdingLeft)
        if isHoldingOrRaising && backLean > ShoulderStretchAnalyzer.backLeanThreshold {
            return AnalysisResult(accuracy: 0.35, feedback: "⚠️ Gövdeniz eğriliyor!\n📏 Sırtınızı tamamen dik tutun\nOmuzdan güç alın.", debugInfo: debugInfo)
        }
        
        // Global Hız Kontrolü (sadece omuzu germe/kaldırma fazını kontrol eder, indirme aşamasında serbest)
        let isMoving = (currentState == .raisingRight || currentState == .raisingLeft)
        if isMoving && currentSpeed > ShoulderStretchAnalyzer.maxAllowedSpeed {
            if (now - lastSpeedWarningTime) > ShoulderStretchAnalyzer.speedWarningCooldownMs {
                lastSpeedWarningTime = now
                return AnalysisResult(accuracy: 0.3, feedback: "⚠️ Çok hızlı!\n🐌 Yavaş hareket edin.\n💆 Kaslarınızı hissedin.", debugInfo: debugInfo)
            }
        }
        
        switch currentState {
            
        case .waitingForPerson:
            readyStartTime = 0
            currentState = .ready
            return AnalysisResult(accuracy: 0.3, feedback: "👤 Sizi görüyorum!\n📏 Kollarınızı yanlara bırakın...\n🎯 Hedef: \(targetReps) tekrar", debugInfo: debugInfo)
            
        case .ready:
            if armAngle <= ShoulderStretchAnalyzer.armDownAngle {
                if readyStartTime == 0 { readyStartTime = now }
                
                let elapsed = now - readyStartTime
                if elapsed > ShoulderStretchAnalyzer.readyDelayMs {
                    currentState = .raisingRight
                    readyStartTime = 0
                    smoothedArmAngle = 0 // Reset smoothing for new side
                    return AnalysisResult(accuracy: 0.4, feedback: "✅ Harika pozisyon!\n\n🤚 SAĞ kolunuzu yavaşça\nyukarı kaldırın", debugInfo: debugInfo)
                }
                
                let remaining = (ShoulderStretchAnalyzer.readyDelayMs - elapsed) / 1000 + 1
                return AnalysisResult(accuracy: 0.3, feedback: "📏 Kollarınızı yanınızda tutun...\n⏳ \(remaining) saniye bekleyin", debugInfo: debugInfo)
                
            } else {
                readyStartTime = 0
                return AnalysisResult(accuracy: 0.2, feedback: "📏 Kollarınızı aşağıya indirin.\n🧘 Rahat bir pozisyona gelin.", debugInfo: debugInfo)
            }
            
        case .raisingRight:
            return handleRaising(angle: armAngle, direction: "sağ", now: now, debugInfo: debugInfo)
            
        case .holdingRight:
            return handleHolding(angle: armAngle, direction: "sağ", now: now, debugInfo: debugInfo)
            
        case .loweringRight:
            if armAngle <= ShoulderStretchAnalyzer.armDownAngle {
                currentState = .restingSide
                readyStartTime = now // Mola süresi için kullan
                smoothedArmAngle = 0 // Reset smoothing for new side
                lastArmAngle = 0
                return AnalysisResult(accuracy: 0.6, feedback: "✅ Sağ taraf tamamlandı!\n\n😌 Kollarınızı 1 saniye\nrahatlatın.", debugInfo: debugInfo)
            }
            return AnalysisResult(accuracy: 0.6, feedback: "⬇️ Yavaşça kolunuzu indirin.\n📏 Kontrollü hareket edin.", debugInfo: debugInfo)
            
        case .restingSide:
            let elapsed = now - readyStartTime
            if elapsed > ShoulderStretchAnalyzer.restingDurationMs {
                // Hangi koldaydık? repCount mantığından ve o anki duruma göre sırası gelen kolu buluruz
                // loweredRight'ten buraya gelindiyse -> raisingLeft'e gitmeli
                // loweredLeft'ten buraya gelindiyse -> rep tamam, raisingRight'e gitmeli
                // Bunun için basit bir toggle kontrolü yapacak özel bir değişkene gerek kalmaması adına,
                // left lowering sonrası .repComplete'e atıyoruz, right lowering sonrası .restingSide'a atıp oradan .raisingLeft'e atlayacağız.
                // Ve sol bitince yeni tekrara geçmeden de 1 sn mola verdirelim:
                
                // Mola bitti
                currentState = .raisingLeft
                return AnalysisResult(accuracy: 0.8, feedback: "✅ Mola tamam!\n\n🤚 Şimdi SOL kolunuzu\nyavaşça kaldırın", debugInfo: debugInfo)
            }
            // Molaya devam
            return AnalysisResult(accuracy: 0.5, feedback: "😌 Kollarınızı rahat bırakın...\nMola veriyorsunuz.", debugInfo: debugInfo)
            
        case .raisingLeft:
            return handleRaising(angle: armAngle, direction: "sol", now: now, debugInfo: debugInfo)
            
        case .holdingLeft:
            return handleHolding(angle: armAngle, direction: "sol", now: now, debugInfo: debugInfo)
            
        case .loweringLeft:
            if armAngle <= ShoulderStretchAnalyzer.armDownAngle {
                repCount += 1
                
                if repCount >= targetReps {
                    currentState = .repComplete
                    return AnalysisResult(accuracy: 1.0, feedback: "🏆 TEBRİKLER!\n✅ \(targetReps) tekrar tamamlandı!\n👏 Harika bir iş çıkardınız!", isRepetitionComplete: true, debugInfo: debugInfo)
                }
                
                currentState = .restingBetweenReps
                readyStartTime = now
                smoothedArmAngle = 0
                lastArmAngle = 0
                return AnalysisResult(accuracy: 0.8, feedback: "👏 \(repCount). tekrar tamamlandı!\n\n😌 1 saniye dinlenin...", isRepetitionComplete: true, debugInfo: debugInfo)
            }
            return AnalysisResult(accuracy: 0.6, feedback: "⬇️ Yavaşça kolunuzu indirin.\n📏 Kontrollü hareket edin.", debugInfo: debugInfo)
            
        case .restingBetweenReps:
            let elapsed = now - readyStartTime
            if elapsed > ShoulderStretchAnalyzer.restingDurationMs {
                currentState = .raisingRight
                return AnalysisResult(accuracy: 0.7, feedback: "✅ Mola tamam!\n\n🤚 Tekrar SAĞ kolunuzu kaldırın\n📊 Kalan: \(targetReps - repCount) tekrar", debugInfo: debugInfo)
            }
            return AnalysisResult(accuracy: 0.5, feedback: "😌 Kollarınızı rahat bırakın...\nMola veriyorsunuz.", debugInfo: debugInfo)
            
        case .repComplete:
            return AnalysisResult(accuracy: 1.0, feedback: "🏆 Egzersiz tamamlandı!\n👏 \(targetReps) tekrar başarıyla yapıldı!\n💪 Omuzlarınız teşekkür ediyor!", isRepetitionComplete: false, debugInfo: debugInfo)
        }
    }
    
    // ═══════════════════════════════════════════
    // Ortak Fazlar
    // ═══════════════════════════════════════════
    
    private func handleRaising(angle: Double, direction: String, now: Int64, debugInfo: [String: Any]?) -> AnalysisResult {
        let arrow = direction == "sağ" ? "🤚" : "🤚"
        let sideName = direction == "sağ" ? "Sağ" : "Sol"
        
        // Güvenlik sınırı
        if angle > ShoulderStretchAnalyzer.maxSafeAngle {
            return AnalysisResult(accuracy: 0.5, feedback: "⚠️ Çok yüksek!\n📐 Biraz aşağı indirin.\n🛡️ Omzunuzu zorlamayın.", debugInfo: debugInfo)
        }
        
        // Hedef açıya ulaştı
        if angle >= ShoulderStretchAnalyzer.targetAngle {
            if direction == "sağ" {
                currentState = .holdingRight
            } else {
                currentState = .holdingLeft
            }
            holdStartTime = 0
            return AnalysisResult(accuracy: 0.75, feedback: "🎯 Mükemmel açı!\n✋ Bu pozisyonda TUTUN!\n⏱️ 3 saniye sayacağız...", debugInfo: debugInfo)
        }
        
        // İyi pozisyon
        if angle >= ShoulderStretchAnalyzer.goodPositionAngle {
            let progress = (angle - ShoulderStretchAnalyzer.goodPositionAngle) / (ShoulderStretchAnalyzer.targetAngle - ShoulderStretchAnalyzer.goodPositionAngle)
            return AnalysisResult(accuracy: 0.55 + progress * 0.15, feedback: "\(arrow) Çok iyi gidiyorsunuz!\n🎯 Biraz daha kaldırın!\n💆 \(sideName) omzunuzu hissedin", debugInfo: debugInfo)
        }
        
        // Kaldırma başlangıcı
        if angle >= ShoulderStretchAnalyzer.raiseStartAngle {
            let progress = (angle - ShoulderStretchAnalyzer.raiseStartAngle) / (ShoulderStretchAnalyzer.goodPositionAngle - ShoulderStretchAnalyzer.raiseStartAngle)
            return AnalysisResult(accuracy: 0.4 + progress * 0.1, feedback: "\(arrow) Güzel, yükseltmeye başladınız!\n📐 Daha yukarı kaldırın...", debugInfo: debugInfo)
        }
        
        return AnalysisResult(accuracy: 0.35, feedback: "\(arrow) \(sideName) kolunuzu yavaşça\nyukarı kaldırmaya başlayın.", debugInfo: debugInfo)
    }
    
    private func handleHolding(angle: Double, direction: String, now: Int64, debugInfo: [String: Any]?) -> AnalysisResult {
        if holdStartTime == 0 { holdStartTime = now }
        
        // Pozisyon kaybı
        if angle < ShoulderStretchAnalyzer.goodPositionAngle - 10 {
            if direction == "sağ" {
                currentState = .raisingRight
            } else {
                currentState = .raisingLeft
            }
            holdStartTime = 0
            return AnalysisResult(accuracy: 0.5, feedback: "⚠️ Pozisyonu kaybettiniz!\n🤚 Tekrar kolunuzu kaldırın.", debugInfo: debugInfo)
        }
        
        let holdElapsed = now - holdStartTime
        let holdRemaining = Int((ShoulderStretchAnalyzer.holdDurationMs - holdElapsed) / 1000) + 1
        
        if holdElapsed >= ShoulderStretchAnalyzer.holdDurationMs {
            if direction == "sağ" {
                currentState = .loweringRight
            } else {
                currentState = .loweringLeft
            }
            holdStartTime = 0
            let sideName = direction == "sağ" ? "Sağ" : "Sol"
            return AnalysisResult(accuracy: 0.9, feedback: "🎉 \(sideName) taraf tamamlandı!\n\n⬇️ Yavaşça kolunuzu indirin", debugInfo: debugInfo)
        }
        
        let holdAccuracy = 0.75 + (Double(holdElapsed) / Double(ShoulderStretchAnalyzer.holdDurationMs)) * 0.15
        return AnalysisResult(accuracy: holdAccuracy, feedback: "✅ Pozisyonu tutun!\n⏱️ \(holdRemaining) saniye kaldı...\n💪 Bırakmayın, nefes alın!", debugInfo: debugInfo)
    }
    
    // ═══════════════════════════════════════════
    // Açı Hesaplama
    // ═══════════════════════════════════════════
    
    /// Kol-gövde açısı: Wrist/Elbow → Shoulder → Hip
    private func calculateArmAngle(wrist: VisionPoint, elbow: VisionPoint, 
                                    shoulder: VisionPoint, hip: VisionPoint) -> Double {
        // Shoulder-Hip vektörü (gövde)
        let bodyVec = CGPoint(x: CGFloat(hip.x - shoulder.x), y: CGFloat(hip.y - shoulder.y))
        // Shoulder-Wrist vektörü (kol)
        let armVec = CGPoint(x: CGFloat(wrist.x - shoulder.x), y: CGFloat(wrist.y - shoulder.y))
        
        let dotProduct = Double(bodyVec.x * armVec.x + bodyVec.y * armVec.y)
        let magBody = sqrt(Double(bodyVec.x * bodyVec.x + bodyVec.y * bodyVec.y))
        let magArm = sqrt(Double(armVec.x * armVec.x + armVec.y * armVec.y))
        
        guard magBody > 0 && magArm > 0 else { return 0 }
        
        let cosAngle = max(-1.0, min(1.0, dotProduct / (magBody * magArm)))
        return acos(cosAngle) * 180.0 / .pi
    }
    
    /// Sırt eğim açısı hesapla
    private func calculateBackLean(shoulder: CGPoint, hip: CGPoint) -> Double {
        let dx = Double(shoulder.x - hip.x)
        let dy = Double(shoulder.y - hip.y)
        guard abs(dy) > 0 else { return 0 }
        return abs(atan2(dx, -dy)) * 180.0 / .pi
    }
    
    /// İki noktanın ortası
    private func midpoint(_ a: VisionPoint, _ b: VisionPoint) -> CGPoint {
        return CGPoint(x: CGFloat(a.x + b.x) / 2.0, y: CGFloat(a.y + b.y) / 2.0)
    }
    
    func reset() {
        currentState = .waitingForPerson
        holdStartTime = 0
        readyStartTime = 0
        lastTimestamp = 0
        repCount = 0
        smoothedArmAngle = 0.0
        print("[ShoulderStretchAnalyzer] Reset")
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
