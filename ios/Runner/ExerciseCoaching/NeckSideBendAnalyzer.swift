import Foundation
import MLKitPoseDetection

/// Başı Yana Eğme (Lateral Neck Flexion) Egzersizi Analizörü.
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
    // Açı ve Hız Eşikleri
    // ═══════════════════════════════════════════
    private static let centerThreshold: Double = 8.0
    private static let minTiltAngle: Double = 10.0 // Önceki 12.0 idi. Azaltıldı, daha erken tepki verecek.
    private static let goodTiltAngle: Double = 16.0 // Önceki 20.0 idi. "İyi gidiyorsun" mesajı daha rahat çıkacak.
    private static let targetTiltAngle: Double = 22.0 // Önceki 30.0 idi. "Tamam tut!" açısı insani seviyeye indirildi.
    private static let maxSafeAngle: Double = 40.0 // Önceki 45.0 idi. Güvenli bölge daraltıldı.
    
    // Hız Kontrolü (Derece / Saniye)
    private static let maxAllowedSpeed: Double = 15.0 
    private static let speedWarningCooldownMs: Int64 = 2000
    
    // ═══════════════════════════════════════════
    // Zamanlayıcılar (Timers)
    // ═══════════════════════════════════════════
    private static let holdDurationMs: Int64 = 3000
    private static let readyDelayMs: Int64 = 2000
    
    // State Değişkenleri
    private var currentState: State = .waitingForPerson
    private var holdStartTime: Int64 = 0
    private var readyStartTime: Int64 = 0
    private var repCount = 0
    private let targetReps = 5
    
    // Hız ve Smoothing Değişkenleri
    private var smoothedTiltAngle: Double = 0
    private static let smoothingFactor: Double = 0.3
    private var lastTimestamp: Int64 = 0
    private var lastTiltAngle: Double = 0
    private var lastSpeedWarningTime: Int64 = 0
    
    func analyze(pose: Pose) -> AnalysisResult {
        let leftEar = pose.landmark(ofType: .leftEar)
        let rightEar = pose.landmark(ofType: .rightEar)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        
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
        // Açı Hesaplama - (Mirroring Bypass Edilmiş Hali)
        // ═══════════════════════════════════════════
        // X eksenini abs() ile alarak iOS aynalama (mirroring) farkını yok ediyoruz!
        let shoulderDx = abs(Double(rightShoulder.position.x - leftShoulder.position.x))
        let shoulderDy = Double(rightShoulder.position.y - leftShoulder.position.y)
        let shoulderAngle = atan2(shoulderDy, shoulderDx) * 180.0 / .pi
        
        let earDx = abs(Double(rightEar.position.x - leftEar.position.x))
        let earDy = Double(rightEar.position.y - leftEar.position.y)
        let earAngle = atan2(earDy, earDx) * 180.0 / .pi
        
        let rawTiltAngle = earAngle - shoulderAngle
        // Sağa eğilimde 'earDy' > 0 çıkar (Sağ kulak pos.y büyür). Code State'leri sağa eğilimi negatif bekliyor, bu yüzden eksi atıyoruz.
        let correctedTiltAngle = -rawTiltAngle 
        
        // EMA Smoothing
        smoothedTiltAngle = NeckSideBendAnalyzer.smoothingFactor * correctedTiltAngle + (1 - NeckSideBendAnalyzer.smoothingFactor) * smoothedTiltAngle
        let tiltAngle = smoothedTiltAngle
        
        // Hız (Velocity) Hesaplama
        let now = currentTimeMillis()
        var currentSpeed: Double = 0.0
        
        if lastTimestamp != 0 && now > lastTimestamp {
            let timeDiff = Double(now - lastTimestamp) / 1000.0 // saniye cinsinden
            currentSpeed = abs(tiltAngle - lastTiltAngle) / timeDiff
        }
        
        lastTiltAngle = tiltAngle
        lastTimestamp = now
        
        let visibleLandmarkCount = pose.landmarks.filter { $0.inFrameLikelihood >= 0.5 }.count
        let debugInfo: [String: Any] = [
            "tiltAngle": String(format: "%.1f°", tiltAngle),
            "speed": String(format: "%.1f°/sn", currentSpeed),
            "state": String(describing: currentState),
            "repCount": "\(repCount)/\(targetReps)"
        ]
        
        return processState(tiltAngle: tiltAngle, currentSpeed: currentSpeed, confidence: minConfidence, now: now, debugInfo: debugInfo)
    }
    
    private func processState(tiltAngle: Double, currentSpeed: Double, confidence: Float, now: Int64, debugInfo: [String: Any]? = nil) -> AnalysisResult {
        let absTilt = abs(tiltAngle)
        
        // Global Hız Kontrolü (Sadece hareket fazlarında çalışır)
        if (currentState == .tiltingRight || currentState == .tiltingLeft || currentState == .returningCenter1 || currentState == .returningCenter2) {
            if currentSpeed > NeckSideBendAnalyzer.maxAllowedSpeed {
                if (now - lastSpeedWarningTime) > NeckSideBendAnalyzer.speedWarningCooldownMs {
                    lastSpeedWarningTime = now
                    return AnalysisResult(accuracy: 0.3, feedback: "⚠️ Çok hızlı hareket ediyorsunuz!\n🐌 Lütfen kaslarınızı hissederek yavaşlayın.", debugInfo: debugInfo)
                }
            }
        }
        
        switch currentState {
            
        case .waitingForPerson:
            readyStartTime = 0
            currentState = .ready
            return AnalysisResult(accuracy: 0.3, feedback: "👤 Sizi görüyorum!\n📏 Başınızı düz tutun, hazırlanın.\n🎯 Hedef: \(targetReps) tekrar", debugInfo: debugInfo)
            
        case .ready:
            // HYSTERESIS EKLENDİ: Sadece 12 dereceden fazla saparsa sayacı sıfırla.
            if absTilt <= NeckSideBendAnalyzer.centerThreshold {
                if readyStartTime == 0 { readyStartTime = now }
                
                let elapsed = now - readyStartTime
                if elapsed > NeckSideBendAnalyzer.readyDelayMs {
                    currentState = .tiltingRight
                    readyStartTime = 0
                    return AnalysisResult(accuracy: 0.4, feedback: "✅ Harika, düz pozisyon!\n\n➡️ Şimdi başınızı SAĞA eğin\n🐌 Yavaş ve kontrollü hareket edin", debugInfo: debugInfo)
                }
                
                let remaining = (NeckSideBendAnalyzer.readyDelayMs - elapsed) / 1000 + 1
                return AnalysisResult(accuracy: 0.3, feedback: "📏 Başınızı düz tutun...\n⏳ \(remaining) saniye bekleyin", debugInfo: debugInfo)
                
            } else if absTilt > NeckSideBendAnalyzer.minTiltAngle {
                // Sadece ölü bölgeden çıkarsa acımasızca sıfırla
                readyStartTime = 0
                return AnalysisResult(accuracy: 0.2, feedback: "⚠️ Başınız eğik!\n📏 Lütfen tam düz pozisyona gelin", debugInfo: debugInfo)
            } else {
                // 8 ile 12 derece arası ölü bölge (deadband). Sayacı sıfırlama ama ilerletme de.
                return AnalysisResult(accuracy: 0.3, feedback: "📏 Başınızı biraz daha dikleştirin...", debugInfo: debugInfo)
            }
            
        case .tiltingRight:
            if tiltAngle > 5.0 { // Yanlış yön toleransı eklendi
                return AnalysisResult(accuracy: 0.3, feedback: "↩️ Ters tarafa eğiliyorsunuz!\n➡️ Sağ kulağınızı sağ omzunuza yaklaştırın", debugInfo: debugInfo)
            }
            return handleTilting(tiltAmount: -tiltAngle, direction: "sağ", now: now, debugInfo: debugInfo)
            
        case .holdingRight:
            if holdStartTime == 0 { holdStartTime = now }
            
            let rightHold = -tiltAngle
            if rightHold < NeckSideBendAnalyzer.goodTiltAngle - 5 {
                currentState = .tiltingRight
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.5, feedback: "⚠️ Pozisyonu kaybettiniz!\n➡️ Tekrar sağa eğilin", debugInfo: debugInfo)
            }
            
            let holdElapsed = now - holdStartTime
            let holdRemaining = Int((NeckSideBendAnalyzer.holdDurationMs - holdElapsed) / 1000) + 1
            
            if holdElapsed >= NeckSideBendAnalyzer.holdDurationMs {
                currentState = .returningCenter1
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.9, feedback: "🎉 Mükemmel! Sağ taraf tamamlandı!\n\n↩️ Şimdi yavaşça merkeze dönün", debugInfo: debugInfo)
            }
            
            let holdAccuracy = 0.7 + (Double(holdElapsed) / Double(NeckSideBendAnalyzer.holdDurationMs)) * 0.2
            return AnalysisResult(accuracy: holdAccuracy, feedback: "✅ Pozisyonu tutun!\n⏱️ \(holdRemaining) saniye kaldı...\n💪 Devam edin, bırakmayın!", debugInfo: debugInfo)
            
        case .returningCenter1:
            if absTilt < NeckSideBendAnalyzer.centerThreshold {
                readyStartTime = now
                currentState = .tiltingLeft
                return AnalysisResult(accuracy: 0.6, feedback: "✅ Merkeze döndünüz!\n\n⬅️ Şimdi başınızı SOLA eğin\n🐌 Yavaş ve kontrollü hareket edin", debugInfo: debugInfo)
            }
            return AnalysisResult(accuracy: 0.6, feedback: "↩️ Yavaşça merkeze dönün\n📏 Başınızı düz hale getirin", debugInfo: debugInfo)
            
        case .tiltingLeft:
            if tiltAngle < -5.0 {
                return AnalysisResult(accuracy: 0.3, feedback: "↩️ Ters tarafa eğiliyorsunuz!\n⬅️ Sol kulağınızı sol omzunuza yaklaştırın", debugInfo: debugInfo)
            }
            return handleTilting(tiltAmount: tiltAngle, direction: "sol", now: now, debugInfo: debugInfo)
            
        case .holdingLeft:
            if holdStartTime == 0 { holdStartTime = now }
            
            let leftHold = tiltAngle
            if leftHold < NeckSideBendAnalyzer.goodTiltAngle - 5 {
                currentState = .tiltingLeft
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.5, feedback: "⚠️ Pozisyonu kaybettiniz!\n⬅️ Tekrar sola eğilin", debugInfo: debugInfo)
            }
            
            let leftHoldElapsed = now - holdStartTime
            let leftHoldRemaining = Int((NeckSideBendAnalyzer.holdDurationMs - leftHoldElapsed) / 1000) + 1
            
            if leftHoldElapsed >= NeckSideBendAnalyzer.holdDurationMs {
                currentState = .returningCenter2
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.9, feedback: "🎉 Mükemmel! Sol taraf tamamlandı!\n\n↩️ Yavaşça merkeze dönün", debugInfo: debugInfo)
            }
            
            let leftHoldAcc = 0.7 + (Double(leftHoldElapsed) / Double(NeckSideBendAnalyzer.holdDurationMs)) * 0.2
            return AnalysisResult(accuracy: leftHoldAcc, feedback: "✅ Pozisyonu tutun!\n⏱️ \(leftHoldRemaining) saniye kaldı...\n💪 Devam edin, bırakmayın!", debugInfo: debugInfo)
            
        case .returningCenter2:
            if absTilt < NeckSideBendAnalyzer.centerThreshold {
                repCount += 1
                if repCount >= targetReps {
                    currentState = .repComplete
                    return AnalysisResult(accuracy: 1.0, feedback: "🏆 TEBRİKLER!\n✅ \(targetReps) tekrar tamamlandı!\n👏 Harika bir iş çıkardınız!", isRepetitionComplete: true, debugInfo: debugInfo)
                }
                currentState = .tiltingRight
                return AnalysisResult(accuracy: 0.8, feedback: "👏 \(repCount). tekrar tamamlandı!\n\n➡️ Şimdi tekrar SAĞA eğilin\n📊 Kalan: \(targetReps - repCount) tekrar", isRepetitionComplete: true, debugInfo: debugInfo)
            }
            return AnalysisResult(accuracy: 0.6, feedback: "↩️ Yavaşça merkeze dönün\n📏 Başınızı düz hale getirin", debugInfo: debugInfo)
            
        case .repComplete:
            return AnalysisResult(accuracy: 1.0, feedback: "🏆 Egzersiz tamamlandı!\n👏 \(targetReps) tekrar başarıyla yapıldı!", isRepetitionComplete: true, debugInfo: debugInfo)
        }
    }
    
    private func handleTilting(tiltAmount: Double, direction: String, now: Int64, debugInfo: [String: Any]? = nil) -> AnalysisResult {
        let arrow = direction == "sağ" ? "➡️" : "⬅️"
        let earSide = direction == "sağ" ? "Sağ" : "Sol"
        
        if tiltAmount < NeckSideBendAnalyzer.minTiltAngle {
            return AnalysisResult(accuracy: 0.35, feedback: "\(arrow) \(earSide) kulağınızı \(direction) omzunuza doğru eğin", debugInfo: debugInfo)
        }
        
        if tiltAmount < NeckSideBendAnalyzer.goodTiltAngle {
            let progress = (tiltAmount - NeckSideBendAnalyzer.minTiltAngle) / (NeckSideBendAnalyzer.goodTiltAngle - NeckSideBendAnalyzer.minTiltAngle)
            return AnalysisResult(accuracy: 0.4 + progress * 0.15, feedback: "\(arrow) Güzel, eğilmeye başladınız!\n📐 Biraz daha eğilin...", debugInfo: debugInfo)
        }
        
        if tiltAmount < NeckSideBendAnalyzer.targetTiltAngle {
            let progress = (tiltAmount - NeckSideBendAnalyzer.goodTiltAngle) / (NeckSideBendAnalyzer.targetTiltAngle - NeckSideBendAnalyzer.goodTiltAngle)
            return AnalysisResult(accuracy: 0.55 + progress * 0.15, feedback: "\(arrow) Çok iyi gidiyorsunuz!\n🎯 Hedefe yaklaşıyorsunuz!", debugInfo: debugInfo)
        }
        
        if tiltAmount > NeckSideBendAnalyzer.maxSafeAngle {
            return AnalysisResult(accuracy: 0.6, feedback: "⚠️ Çok fazla eğildiniz!\n📐 Biraz geri gelin\n🛡️ Güvenli aralıkta kalın", debugInfo: debugInfo)
        }
        
        if direction == "sağ" {
            currentState = .holdingRight
        } else {
            currentState = .holdingLeft
        }
        holdStartTime = 0
        return AnalysisResult(accuracy: 0.75, feedback: "🎯 Mükemmel açı!\n✋ Bu pozisyonda tutun!\n⏱️ 3 saniye sayacağız...", debugInfo: debugInfo)
    }
    
    func reset() {
        currentState = .waitingForPerson
        holdStartTime = 0
        readyStartTime = 0
        lastTimestamp = 0
        repCount = 0
        smoothedTiltAngle = 0
        print("[NeckSideBend] Reset")
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}