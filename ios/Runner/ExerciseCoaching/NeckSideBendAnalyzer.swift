import Foundation
import MLKitPoseDetection

/// Başı Yana Eğme (Lateral Neck Flexion) Egzersizi Analizörü.
/// Android'deki NeckSideBendAnalyzer.java karşılığı — aynı açı eşikleri ve state machine.
///
/// Kullanılan Landmarklar:
/// - LEFT_EAR (7), RIGHT_EAR (8) → Baş eğim açısı
/// - LEFT_SHOULDER (11), RIGHT_SHOULDER (12) → Referans çizgisi
/// - NOSE (0) → Baş merkez kontrolü
class NeckSideBendAnalyzer: ExerciseAnalyzer {
    
    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private enum State {
        case waitingForPerson
        case ready
        case tiltingRight
        case holdingRight
        case returningCenter1
        case tiltingLeft
        case holdingLeft
        case returningCenter2
        case repComplete
    }
    
    // ═══════════════════════════════════════════
    // Açı Eşikleri (derece)
    // ═══════════════════════════════════════════
    private static let centerThreshold: Double = 8.0
    private static let minTiltAngle: Double = 12.0
    private static let goodTiltAngle: Double = 20.0
    private static let targetTiltAngle: Double = 30.0
    private static let maxSafeAngle: Double = 45.0
    
    // ═══════════════════════════════════════════
    // Hold Timer
    // ═══════════════════════════════════════════
    private static let holdDurationMs: Int64 = 3000
    private static let readyDelayMs: Int64 = 2000
    
    // ═══════════════════════════════════════════
    // State Değişkenleri
    // ═══════════════════════════════════════════
    private var currentState: State = .waitingForPerson
    private var holdStartTime: Int64 = 0
    private var readyStartTime: Int64 = 0
    private var repCount = 0
    private let targetReps = 5
    
    // Smoothing
    private var smoothedTiltAngle: Double = 0
    private static let smoothingFactor: Double = 0.3
    
    func analyze(pose: Pose) -> AnalysisResult {
        // Landmark'ları al
        let leftEar = pose.landmark(ofType: .leftEar)
        let rightEar = pose.landmark(ofType: .rightEar)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let nose = pose.landmark(ofType: .nose)
        
        // Güvenilirlik kontrolü
        let minConfidence = min(
            min(leftEar.inFrameLikelihood, rightEar.inFrameLikelihood),
            min(leftShoulder.inFrameLikelihood, rightShoulder.inFrameLikelihood)
        )
        
        if minConfidence < 0.3 {
            currentState = .waitingForPerson
            return AnalysisResult(accuracy: 0.0, feedback: "👤 Tüm vücudunuz görünmüyor.\nLütfen kameraya dönün.")
        }
        
        if minConfidence < 0.5 {
            return AnalysisResult(accuracy: 0.1, feedback: "👤 Poz algılama kalitesi düşük.\nLütfen iyi aydınlatılmış bir ortamda durun.")
        }
        
        // ═══════════════════════════════════════════
        // Açı Hesaplama
        // ═══════════════════════════════════════════
        let shoulderAngle = atan2(
            Double(rightShoulder.position.y - leftShoulder.position.y),
            Double(rightShoulder.position.x - leftShoulder.position.x)
        ) * 180.0 / .pi
        
        let earAngle = atan2(
            Double(rightEar.position.y - leftEar.position.y),
            Double(rightEar.position.x - leftEar.position.x)
        ) * 180.0 / .pi
        
        let rawTiltAngle = earAngle - shoulderAngle
        
        // EMA Smoothing
        smoothedTiltAngle = NeckSideBendAnalyzer.smoothingFactor * rawTiltAngle + (1 - NeckSideBendAnalyzer.smoothingFactor) * smoothedTiltAngle
        
        let tiltAngle = smoothedTiltAngle
        
        return processState(tiltAngle: tiltAngle, confidence: minConfidence)
    }
    
    private func processState(tiltAngle: Double, confidence: Float) -> AnalysisResult {
        let now = currentTimeMillis()
        let absTilt = abs(tiltAngle)
        
        switch currentState {
            
        case .waitingForPerson:
            readyStartTime = now
            currentState = .ready
            return AnalysisResult(accuracy: 0.3, feedback:
                "👤 Sizi görüyorum!\n📏 Başınızı düz tutun, hazırlanın.\n🎯 Hedef: \(targetReps) tekrar")
            
        case .ready:
            if absTilt < NeckSideBendAnalyzer.centerThreshold {
                if now - readyStartTime > NeckSideBendAnalyzer.readyDelayMs {
                    currentState = .tiltingRight
                    return AnalysisResult(accuracy: 0.4, feedback:
                        "✅ Harika, düz pozisyon!\n\n➡️ Şimdi başınızı SAĞA eğin\n🐌 Yavaş ve kontrollü hareket edin")
                }
                let remaining = (NeckSideBendAnalyzer.readyDelayMs - (now - readyStartTime)) / 1000 + 1
                return AnalysisResult(accuracy: 0.3, feedback:
                    "📏 Başınızı düz tutun...\n⏳ \(remaining) saniye bekleyin")
            } else {
                readyStartTime = now
                if absTilt > NeckSideBendAnalyzer.minTiltAngle {
                    return AnalysisResult(accuracy: 0.2, feedback:
                        "⚠️ Başınız eğik!\n📏 Lütfen düz pozisyona gelin")
                }
                return AnalysisResult(accuracy: 0.3, feedback: "📏 Başınızı düz tutun...")
            }
            
        case .tiltingRight:
            if tiltAngle > 0 {
                return AnalysisResult(accuracy: 0.3, feedback:
                    "↩️ Ters tarafa eğiliyorsunuz!\n➡️ Sağ kulağınızı sağ omzunuza yaklaştırın")
            }
            let rightTilt = -tiltAngle
            return handleTilting(tiltAmount: rightTilt, direction: "sağ", now: now)
            
        case .holdingRight:
            if holdStartTime == 0 { holdStartTime = now }
            
            let rightHold = -tiltAngle
            if rightHold < NeckSideBendAnalyzer.goodTiltAngle - 5 {
                currentState = .tiltingRight
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.5, feedback:
                    "⚠️ Pozisyonu kaybettiniz!\n➡️ Tekrar sağa eğilin")
            }
            
            let holdElapsed = now - holdStartTime
            let holdRemaining = Int((NeckSideBendAnalyzer.holdDurationMs - holdElapsed) / 1000) + 1
            
            if holdElapsed >= NeckSideBendAnalyzer.holdDurationMs {
                currentState = .returningCenter1
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.9, feedback:
                    "🎉 Mükemmel! Sağ taraf tamamlandı!\n\n↩️ Şimdi yavaşça merkeze dönün")
            }
            
            let holdAccuracy = 0.7 + (Double(holdElapsed) / Double(NeckSideBendAnalyzer.holdDurationMs)) * 0.2
            return AnalysisResult(accuracy: holdAccuracy, feedback:
                "✅ Pozisyonu tutun!\n⏱️ \(holdRemaining) saniye kaldı...\n💪 Devam edin, bırakmayın!")
            
        case .returningCenter1:
            if absTilt < NeckSideBendAnalyzer.centerThreshold {
                readyStartTime = now
                currentState = .tiltingLeft
                return AnalysisResult(accuracy: 0.6, feedback:
                    "✅ Merkeze döndünüz!\n\n⬅️ Şimdi başınızı SOLA eğin\n🐌 Yavaş ve kontrollü hareket edin")
            }
            return AnalysisResult(accuracy: 0.6, feedback:
                "↩️ Yavaşça merkeze dönün\n📏 Başınızı düz hale getirin")
            
        case .tiltingLeft:
            if tiltAngle < 0 {
                return AnalysisResult(accuracy: 0.3, feedback:
                    "↩️ Ters tarafa eğiliyorsunuz!\n⬅️ Sol kulağınızı sol omzunuza yaklaştırın")
            }
            let leftTilt = tiltAngle
            return handleTilting(tiltAmount: leftTilt, direction: "sol", now: now)
            
        case .holdingLeft:
            if holdStartTime == 0 { holdStartTime = now }
            
            let leftHold = tiltAngle
            if leftHold < NeckSideBendAnalyzer.goodTiltAngle - 5 {
                currentState = .tiltingLeft
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.5, feedback:
                    "⚠️ Pozisyonu kaybettiniz!\n⬅️ Tekrar sola eğilin")
            }
            
            let leftHoldElapsed = now - holdStartTime
            let leftHoldRemaining = Int((NeckSideBendAnalyzer.holdDurationMs - leftHoldElapsed) / 1000) + 1
            
            if leftHoldElapsed >= NeckSideBendAnalyzer.holdDurationMs {
                currentState = .returningCenter2
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.9, feedback:
                    "🎉 Mükemmel! Sol taraf tamamlandı!\n\n↩️ Yavaşça merkeze dönün")
            }
            
            let leftHoldAcc = 0.7 + (Double(leftHoldElapsed) / Double(NeckSideBendAnalyzer.holdDurationMs)) * 0.2
            return AnalysisResult(accuracy: leftHoldAcc, feedback:
                "✅ Pozisyonu tutun!\n⏱️ \(leftHoldRemaining) saniye kaldı...\n💪 Devam edin, bırakmayın!")
            
        case .returningCenter2:
            if absTilt < NeckSideBendAnalyzer.centerThreshold {
                repCount += 1
                if repCount >= targetReps {
                    currentState = .repComplete
                    return AnalysisResult(accuracy: 1.0, feedback:
                        "🏆 TEBRİKLER!\n✅ \(targetReps) tekrar tamamlandı!\n👏 Harika bir iş çıkardınız!", isRepetitionComplete: true)
                }
                currentState = .tiltingRight
                return AnalysisResult(accuracy: 0.8, feedback:
                    "👏 \(repCount). tekrar tamamlandı!\n\n➡️ Şimdi tekrar SAĞA eğilin\n📊 Kalan: \(targetReps - repCount) tekrar", isRepetitionComplete: true)
            }
            return AnalysisResult(accuracy: 0.6, feedback:
                "↩️ Yavaşça merkeze dönün\n📏 Başınızı düz hale getirin")
            
        case .repComplete:
            return AnalysisResult(accuracy: 1.0, feedback:
                "🏆 Egzersiz tamamlandı!\n👏 \(targetReps) tekrar başarıyla yapıldı!")
        }
    }
    
    /// Eğilme sırasında progresif feedback
    private func handleTilting(tiltAmount: Double, direction: String, now: Int64) -> AnalysisResult {
        let arrow = direction == "sağ" ? "➡️" : "⬅️"
        let earSide = direction == "sağ" ? "Sağ" : "Sol"
        
        if tiltAmount < NeckSideBendAnalyzer.minTiltAngle {
            return AnalysisResult(accuracy: 0.35, feedback:
                "\(arrow) \(earSide) kulağınızı \(direction) omzunuza doğru eğin\n🐌 Yavaş hareket edin")
        }
        
        if tiltAmount < NeckSideBendAnalyzer.goodTiltAngle {
            let progress = (tiltAmount - NeckSideBendAnalyzer.minTiltAngle) / (NeckSideBendAnalyzer.goodTiltAngle - NeckSideBendAnalyzer.minTiltAngle)
            return AnalysisResult(accuracy: 0.4 + progress * 0.15, feedback:
                "\(arrow) Güzel, eğilmeye başladınız!\n📐 Biraz daha eğilin...\n💪 Devam edin!")
        }
        
        if tiltAmount < NeckSideBendAnalyzer.targetTiltAngle {
            let progress = (tiltAmount - NeckSideBendAnalyzer.goodTiltAngle) / (NeckSideBendAnalyzer.targetTiltAngle - NeckSideBendAnalyzer.goodTiltAngle)
            return AnalysisResult(accuracy: 0.55 + progress * 0.15, feedback:
                "\(arrow) Çok iyi gidiyorsunuz!\n📐 Az kaldı, biraz daha...\n🎯 Hedefe yaklaşıyorsunuz!")
        }
        
        if tiltAmount > NeckSideBendAnalyzer.maxSafeAngle {
            return AnalysisResult(accuracy: 0.6, feedback:
                "⚠️ Çok fazla eğildiniz!\n📐 Biraz geri gelin\n🛡️ Güvenli aralıkta kalın")
        }
        
        // Hedef açıya ulaştı — hold durumuna geç
        if direction == "sağ" {
            currentState = .holdingRight
        } else {
            currentState = .holdingLeft
        }
        holdStartTime = 0
        return AnalysisResult(accuracy: 0.75, feedback:
            "🎯 Mükemmel açı!\n✋ Bu pozisyonda tutun!\n⏱️ 3 saniye sayacağız...")
    }
    
    func reset() {
        currentState = .waitingForPerson
        holdStartTime = 0
        readyStartTime = 0
        repCount = 0
        smoothedTiltAngle = 0
        print("[NeckSideBend] Reset")
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
