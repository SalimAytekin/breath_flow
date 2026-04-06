import Foundation
import MLKitPoseDetection
import MLKitVision

/// Squat (Diz Bükme) Egzersizi Analizörü.
/// Kalça-Diz-Ayak bileği açısını kullanarak tam biyomekanik analiz yapar.
class SquatAnalyzer: ExerciseAnalyzer {
    
    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private enum State {
        case waitingForPerson
        case ready
        case descending
        case holdingBottom
        case ascending
        case restingStanding
        case repComplete
    }
    
    // ═══════════════════════════════════════════
    // Açı Eşikleri (Derece)
    // ═══════════════════════════════════════════
    private static let standingAngle: Double = 160.0        // Düz duruş
    private static let descentStartAngle: Double = 145.0    // İniş algılama
    private static let goodDepthAngle: Double = 125.0       // İyi derinlik (eski 110'du, daha yapılabilir yapıldı)
    private static let targetDepthAngle: Double = 110.0     // Hedef (daha esnek, yarım squat için)
    private static let tooDeepAngle: Double = 70.0          // Çok derin (güvenlik)
    private static let ascentCompleteAngle: Double = 155.0  // Çıkış tamamlandı
    
    // Hız Kontrolü
    private static let maxAllowedSpeed: Double = 60.0       // Derece/saniye
    private static let speedWarningCooldownMs: Int64 = 2500
    
    // Form Kontrol Eşikleri
    private static let kneeValgusThreshold: Double = 0.15   // Diz içe çökme oranı
    private static let backLeanThreshold: Double = 35.0     // Sırt eğim limiti (derece)
    
    // Zamanlayıcılar
    private static let holdDurationMs: Int64 = 500          // Alt noktada tutma
    private static let readyDelayMs: Int64 = 1000           // Hazırlanma süresi
    private static let restingDurationMs: Int64 = 1500      // Tekrarlar arası dinlenme
    
    // ═══════════════════════════════════════════
    // State Değişkenleri
    // ═══════════════════════════════════════════
    private var currentState: State = .waitingForPerson
    private var holdStartTime: Int64 = 0
    private var readyStartTime: Int64 = 0
    private var repCount = 0
    private let targetReps = 8
    
    // Smoothing & Hız
    private var smoothedKneeAngle: Double = 170.0
    private static let smoothingFactor: Double = 0.3
    private var lastTimestamp: Int64 = 0
    private var lastKneeAngle: Double = 170.0
    private var lastSpeedWarningTime: Int64 = 0
    
    // Derinlik takibi
    private var deepestAngleInRep: Double = 180.0
    
    func analyze(pose: Pose) -> AnalysisResult {
        // ═══════════════════════════════════════════
        // Landmark Güvenilirlik Kontrolü
        // ═══════════════════════════════════════════
        let rightHip = pose.landmark(ofType: .rightHip)
        let rightKnee = pose.landmark(ofType: .rightKnee)
        let rightAnkle = pose.landmark(ofType: .rightAnkle)
        let leftHip = pose.landmark(ofType: .leftHip)
        let leftKnee = pose.landmark(ofType: .leftKnee)
        let leftAnkle = pose.landmark(ofType: .leftAnkle)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        
        let lowerBodyConfidence = min(
            max(rightHip.inFrameLikelihood, leftHip.inFrameLikelihood),
            min(max(rightKnee.inFrameLikelihood, leftKnee.inFrameLikelihood),
                max(rightAnkle.inFrameLikelihood, leftAnkle.inFrameLikelihood))
        )
        
        let extraConfidence = max(rightShoulder.inFrameLikelihood, leftShoulder.inFrameLikelihood)
        
        let minConfidence = min(lowerBodyConfidence, extraConfidence)
        
        if minConfidence < 0.3 {
            currentState = .waitingForPerson
            return AnalysisResult(accuracy: 0.0, feedback: "👤 Tüm vücudunuz görünmüyor.\nLütfen kameradan uzaklaşın,\ntam vücut görünsün.")
        }
        
        if minConfidence < 0.5 {
            return AnalysisResult(accuracy: 0.1, feedback: "👤 Poz algılama kalitesi düşük.\nTelefonu yere koyun ve\nbirkaç adım geri gidin.")
        }
        
        // ═══════════════════════════════════════════
        // Açı Hesaplama — İki bacağın ortalaması
        // ═══════════════════════════════════════════
        let rightLegConfidence = rightHip.inFrameLikelihood + rightKnee.inFrameLikelihood + rightAnkle.inFrameLikelihood
        let leftLegConfidence = leftHip.inFrameLikelihood + leftKnee.inFrameLikelihood + leftAnkle.inFrameLikelihood
        
        let rawKneeAngle: Double
        if rightLegConfidence > leftLegConfidence {
            rawKneeAngle = calculateAngle(
                a: rightHip.position, b: rightKnee.position, c: rightAnkle.position
            )
        } else {
            rawKneeAngle = calculateAngle(
                a: leftHip.position, b: leftKnee.position, c: leftAnkle.position
            )
        }
        
        // EMA Smoothing
        smoothedKneeAngle = SquatAnalyzer.smoothingFactor * rawKneeAngle + (1 - SquatAnalyzer.smoothingFactor) * smoothedKneeAngle
        let kneeAngle = smoothedKneeAngle
        
        // Hız Hesaplama
        let now = currentTimeMillis()
        var currentSpeed: Double = 0.0
        
        if lastTimestamp != 0 && now > lastTimestamp {
            let timeDiff = Double(now - lastTimestamp) / 1000.0
            if timeDiff > 0 {
                currentSpeed = abs(kneeAngle - lastKneeAngle) / timeDiff
            }
        }
        
        lastKneeAngle = kneeAngle
        lastTimestamp = now
        
        // ═══════════════════════════════════════════
        // Form Kontrolleri
        // ═══════════════════════════════════════════
        let kneeValgus = checkKneeValgus(
            leftKnee: leftKnee.position, rightKnee: rightKnee.position,
            leftAnkle: leftAnkle.position, rightAnkle: rightAnkle.position
        )
        
        let backLean = calculateBackLean(
            shoulder: midpoint(rightShoulder.position, leftShoulder.position),
            hip: midpoint(rightHip.position, leftHip.position)
        )
        
        let debugInfo: [String: Any] = [
            "kneeAngle": String(format: "%.1f°", kneeAngle),
            "speed": String(format: "%.1f°/sn", currentSpeed),
            "state": String(describing: currentState),
            "repCount": "\(repCount)/\(targetReps)",
            "backLean": String(format: "%.1f°", backLean)
        ]
        
        return processState(kneeAngle: kneeAngle, currentSpeed: currentSpeed, 
                          kneeValgus: kneeValgus, backLean: backLean, 
                          now: now, debugInfo: debugInfo)
    }
    
    // ═══════════════════════════════════════════
    // State Machine
    // ═══════════════════════════════════════════
    private func processState(kneeAngle: Double, currentSpeed: Double, 
                            kneeValgus: Bool, backLean: Double, 
                            now: Int64, debugInfo: [String: Any]?) -> AnalysisResult {
        
        // Global Hız Kontrolü (sadece aşağı iniş fazında kontrollü olmayı zorla, çıkışta daha serbest)
        if currentState == .descending {
            if currentSpeed > SquatAnalyzer.maxAllowedSpeed {
                if (now - lastSpeedWarningTime) > SquatAnalyzer.speedWarningCooldownMs {
                    lastSpeedWarningTime = now
                    return AnalysisResult(accuracy: 0.3, feedback: "⚠️ Çok hızlı!\n🐌 Yavaş ve kontrollü hareket edin.\nKaslarınızı hissedin.", debugInfo: debugInfo)
                }
            }
        }
        
        // Diz valgus uyarısı (sadece iniş/hold'da)
        if kneeValgus && (currentState == .descending || currentState == .holdingBottom) {
            return AnalysisResult(accuracy: 0.35, feedback: "⚠️ Dizleriniz içe çöküyor!\n🦵 Dizleri ayak uçlarına\nhizalayın.", debugInfo: debugInfo)
        }
        
        // Sırt uyarısı
        if backLean > SquatAnalyzer.backLeanThreshold && (currentState == .descending || currentState == .holdingBottom) {
            return AnalysisResult(accuracy: 0.35, feedback: "⚠️ Sırtınız çok eğik!\n📐 Göğsünüzü dik tutun.\nSırtınızı düzleştirin.", debugInfo: debugInfo)
        }
        
        switch currentState {
            
        case .waitingForPerson:
            readyStartTime = 0
            currentState = .ready
            return AnalysisResult(accuracy: 0.3, feedback: "👤 Sizi görüyorum!\n🦵 Ayakta düz durun ve\nKAMERAYA YAN DÖNÜN.\n🎯 Hedef: \(targetReps) squat", debugInfo: debugInfo)
            
        case .ready:
            if kneeAngle >= SquatAnalyzer.standingAngle - 10 {
                if readyStartTime == 0 { readyStartTime = now }
                
                let elapsed = now - readyStartTime
                if elapsed > SquatAnalyzer.readyDelayMs {
                    currentState = .descending
                    readyStartTime = 0
                    deepestAngleInRep = 180.0
                    return AnalysisResult(accuracy: 0.4, feedback: "✅ Harika pozisyon!\n\n⬇️ Şimdi yavaşça ÇÖMELIN\n🐌 Kontrollü inin", debugInfo: debugInfo)
                }
                
                let remaining = (SquatAnalyzer.readyDelayMs - elapsed) / 1000 + 1
                return AnalysisResult(accuracy: 0.3, feedback: "📏 Düz durun...\n⏳ \(remaining) saniye bekleyin\n🦵 Ayaklar omuz genişliğinde", debugInfo: debugInfo)
                
            } else {
                readyStartTime = 0
                return AnalysisResult(accuracy: 0.2, feedback: "📏 Lütfen tam düz durun.\n🦵 Bacaklarınızı düzleştirin.", debugInfo: debugInfo)
            }
            
        case .descending:
            // Derinlik takibi
            if kneeAngle < deepestAngleInRep {
                deepestAngleInRep = kneeAngle
            }
            
            // Çok derin - güvenlik
            if kneeAngle < SquatAnalyzer.tooDeepAngle {
                return AnalysisResult(accuracy: 0.4, feedback: "⚠️ Çok derin indiniz!\n📐 Biraz yukarı gelin.\n🛡️ Dizlerinizi koruyun.", debugInfo: debugInfo)
            }
            
            // Hedef derinliğe ulaştı
            if kneeAngle <= SquatAnalyzer.targetDepthAngle {
                currentState = .holdingBottom
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.75, feedback: "🎯 Mükemmel derinlik!\n✋ Bu pozisyonda TUTUN!\n⏱️ 1 saniye sayacağız...", debugInfo: debugInfo)
            }
            
            // İyi derinlik - devam et
            if kneeAngle <= SquatAnalyzer.goodDepthAngle {
                let progress = (SquatAnalyzer.goodDepthAngle - kneeAngle) / (SquatAnalyzer.goodDepthAngle - SquatAnalyzer.targetDepthAngle)
                return AnalysisResult(accuracy: 0.55 + progress * 0.15, feedback: "⬇️ Çok iyi!\n🎯 Biraz daha çömelin...\n📐 Hedefe yaklaşıyorsunuz!", debugInfo: debugInfo)
            }
            
            // İniş başlangıcı
            if kneeAngle < SquatAnalyzer.descentStartAngle {
                let progress = (SquatAnalyzer.descentStartAngle - kneeAngle) / (SquatAnalyzer.descentStartAngle - SquatAnalyzer.goodDepthAngle)
                return AnalysisResult(accuracy: 0.4 + progress * 0.1, feedback: "⬇️ Güzel, inmeye başladınız!\n📐 Daha derine inin...\n🐌 Yavaş ve kontrollü", debugInfo: debugInfo)
            }
            
            return AnalysisResult(accuracy: 0.35, feedback: "⬇️ Kalçanızı geriye iterek\nçömelmeye başlayın.\n🐌 Yavaşça inin.", debugInfo: debugInfo)
            
        case .holdingBottom:
            if holdStartTime == 0 { holdStartTime = now }
            
            // Pozisyon kaybı kontrolü — hedeften çok yükseldiyse
            if kneeAngle > SquatAnalyzer.goodDepthAngle + 10 {
                currentState = .descending
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.5, feedback: "⚠️ Pozisyonu kaybettiniz!\n⬇️ Tekrar aşağı inin.", debugInfo: debugInfo)
            }
            
            let holdElapsed = now - holdStartTime
            
            if holdElapsed >= SquatAnalyzer.holdDurationMs {
                currentState = .ascending
                holdStartTime = 0
                return AnalysisResult(accuracy: 0.9, feedback: "🎉 Mükemmel! Tutma tamamlandı!\n\n⬆️ Şimdi yavaşça KALKIN\n💪 Topuklardan itin!", debugInfo: debugInfo)
            }
            
            let holdAccuracy = 0.75 + (Double(holdElapsed) / Double(SquatAnalyzer.holdDurationMs)) * 0.15
            let holdRemaining = Int((SquatAnalyzer.holdDurationMs - holdElapsed) / 1000) + 1
            return AnalysisResult(accuracy: holdAccuracy, feedback: "✅ Pozisyonu tutun!\n⏱️ \(holdRemaining) saniye kaldı...\n💪 Bırakmayın!", debugInfo: debugInfo)
            
        case .ascending:
            if kneeAngle >= SquatAnalyzer.ascentCompleteAngle {
                repCount += 1
                
                if repCount >= targetReps {
                    currentState = .repComplete
                    return AnalysisResult(accuracy: 1.0, feedback: "🏆 TEBRİKLER!\n✅ \(targetReps) squat tamamlandı!\n👏 Harika bir iş çıkardınız!", isRepetitionComplete: true, debugInfo: debugInfo)
                }
                
                currentState = .restingStanding
                readyStartTime = now
                deepestAngleInRep = 180.0
                return AnalysisResult(accuracy: 0.8, feedback: "👏 \(repCount). tekrar tamamlandı!\n\n🧍 Düz durun, dinlenin...", isRepetitionComplete: true, debugInfo: debugInfo)
            }
            
            // Tekrar iniş yaptıysa (doğrulamadan kalkmadan tekrar inmek)
            if kneeAngle < SquatAnalyzer.goodDepthAngle {
                currentState = .descending
                return AnalysisResult(accuracy: 0.5, feedback: "🔄 Önce tam kalkın,\nsonra tekrar inin.\n⬆️ Bacakları düzleştirin.", debugInfo: debugInfo)
            }
            
            let progress = (kneeAngle - SquatAnalyzer.targetDepthAngle) / (SquatAnalyzer.ascentCompleteAngle - SquatAnalyzer.targetDepthAngle)
            return AnalysisResult(accuracy: 0.6 + progress * 0.15, feedback: "⬆️ Güzel kalkıyorsunuz!\n💪 Topuklardan itin!\n📐 Tam düz olana kadar kalkın.", debugInfo: debugInfo)
            
        case .restingStanding:
            let elapsed = now - readyStartTime
            if elapsed > SquatAnalyzer.restingDurationMs {
                currentState = .descending
                return AnalysisResult(accuracy: 0.6, feedback: "⬇️ Tekrar ÇÖMELIN\n📊 Kalan: \(targetReps - repCount) tekrar", debugInfo: debugInfo)
            }
            let remaining = (SquatAnalyzer.restingDurationMs - elapsed) / 1000 + 1
            return AnalysisResult(accuracy: 0.7, feedback: "🧍 Harika! \(remaining) saniye dinlenin...\n📏 Pozisyonu koruyun.", debugInfo: debugInfo)
            
        case .repComplete:
            return AnalysisResult(accuracy: 1.0, feedback: "🏆 Egzersiz tamamlandı!\n👏 \(targetReps) squat başarıyla yapıldı!\n💪 Harika performans!", isRepetitionComplete: false, debugInfo: debugInfo)
        }
    }
    
    // ═══════════════════════════════════════════
    // Yardımcı Hesaplama Fonksiyonları
    // ═══════════════════════════════════════════
    
    /// Üç nokta arasındaki açıyı hesapla (derece).
    /// a-b-c açısı, b merkez noktadır.
    private func calculateAngle(a: VisionPoint, b: VisionPoint, c: VisionPoint) -> Double {
        let ba = CGPoint(x: CGFloat(a.x - b.x), y: CGFloat(a.y - b.y))
        let bc = CGPoint(x: CGFloat(c.x - b.x), y: CGFloat(c.y - b.y))
        
        let dotProduct = Double(ba.x * bc.x + ba.y * bc.y)
        let magBA = sqrt(Double(ba.x * ba.x + ba.y * ba.y))
        let magBC = sqrt(Double(bc.x * bc.x + bc.y * bc.y))
        
        guard magBA > 0 && magBC > 0 else { return 180.0 }
        
        let cosAngle = max(-1.0, min(1.0, dotProduct / (magBA * magBC)))
        return acos(cosAngle) * 180.0 / .pi
    }
    
    /// Diz valgus (içe çökme) kontrolü
    private func checkKneeValgus(leftKnee: VisionPoint, rightKnee: VisionPoint,
                                  leftAnkle: VisionPoint, rightAnkle: VisionPoint) -> Bool {
        let kneeWidth = abs(Double(rightKnee.x - leftKnee.x))
        let ankleWidth = abs(Double(rightAnkle.x - leftAnkle.x))
        
        guard ankleWidth > 0 else { return false }
        
        let ratio = kneeWidth / ankleWidth
        return ratio < (1.0 - SquatAnalyzer.kneeValgusThreshold)
    }
    
    /// Sırt eğim açısı hesapla
    private func calculateBackLean(shoulder: CGPoint, hip: CGPoint) -> Double {
        let dx = Double(shoulder.x - hip.x)
        let dy = Double(shoulder.y - hip.y)
        
        guard abs(dy) > 0 else { return 0 }
        
        // Dikey eksenden sapma açısı
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
        smoothedKneeAngle = 170.0
        deepestAngleInRep = 180.0
        print("[SquatAnalyzer] Reset")
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
