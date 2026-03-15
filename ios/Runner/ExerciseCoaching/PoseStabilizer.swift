import Foundation
import MLKitPoseDetection

/// Poz metriklerini stabilize eden merkezi sınıf.
/// Android'deki PoseStabilizer.java karşılığı — aynı parametreler.
///
/// Her frame'de raw poz verisi beslenir ve şu stabilize edilmiş değerler üretilir:
/// - Smoothed accuracy (EMA)
/// - Movement speed (son N frame'deki toplam yer değiştirme)
/// - Stability score (0.0 = çok hareketli, 1.0 = tamamen sabit)
/// - Fluidity score (0.0 = sarsıntılı, 1.0 = akıcı)
class PoseStabilizer {
    
    // EMA parametreleri
    private static let accuracyAlpha: Double = 0.2
    private static let speedAlpha: Double = 0.3
    
    // Stabilite hesapları
    private static let speedHistorySize = 10
    private static let stabilityHighThreshold: Double = 3.0
    private static let stabilityLowThreshold: Double = 15.0
    
    // Smoothed değerler
    private(set) var smoothedAccuracy: Double = 0.5
    private(set) var smoothedSpeed: Double = 0.0
    private(set) var stabilityScore: Double = 0.5
    private(set) var fluidityScore: Double = 0.5
    
    // Hareket hızı geçmişi
    private var speedHistory: [Double]
    private var speedHistoryIndex = 0
    private var speedHistoryFilled = false
    
    // Önceki frame landmark pozisyonları
    private var previousPositions: [String: [CGFloat]] = [:]
    
    // Accuracy ivme hesabı
    private var lastAccuracyDelta: Double = 0
    
    // Key landmarks — ana gövde (Android ile aynı)
    private let keyLandmarkTypes: [PoseLandmarkType] = [
        .nose, .leftShoulder, .rightShoulder,
        .leftHip, .rightHip, .leftElbow,
        .rightElbow, .leftKnee, .rightKnee
    ]
    
    init() {
        speedHistory = Array(repeating: 0, count: PoseStabilizer.speedHistorySize)
    }
    
    /// Yeni bir poz frame'i ile metrikleri güncelle.
    func update(pose: Pose, rawAccuracy: Double) {
        // 1. Accuracy EMA smoothing
        let prevAccuracy = smoothedAccuracy
        smoothedAccuracy = PoseStabilizer.accuracyAlpha * rawAccuracy + (1 - PoseStabilizer.accuracyAlpha) * smoothedAccuracy
        
        // Accuracy değişim ivmesi
        let currentDelta = abs(smoothedAccuracy - prevAccuracy)
        lastAccuracyDelta = 0.3 * currentDelta + 0.7 * lastAccuracyDelta
        
        // 2. Hareket hızı hesapla
        let frameSpeed = calculateFrameSpeed(pose: pose)
        smoothedSpeed = PoseStabilizer.speedAlpha * frameSpeed + (1 - PoseStabilizer.speedAlpha) * smoothedSpeed
        
        // Speed history güncelle
        speedHistory[speedHistoryIndex] = smoothedSpeed
        speedHistoryIndex = (speedHistoryIndex + 1) % PoseStabilizer.speedHistorySize
        if speedHistoryIndex == 0 { speedHistoryFilled = true }
        
        // 3. Stability score hesapla
        updateStabilityScore()
        
        // 4. Fluidity score hesapla
        updateFluidityScore()
    }
    
    /// İki frame arasındaki toplam landmark yer değiştirmesini hesapla.
    private func calculateFrameSpeed(pose: Pose) -> Double {
        var totalDisplacement: Double = 0
        var count = 0
        
        for landmarkType in keyLandmarkTypes {
            let lm = pose.landmark(ofType: landmarkType)
            guard lm.inFrameLikelihood >= 0.5 else { continue }
            
            let x = CGFloat(lm.position.x)
            let y = CGFloat(lm.position.y)
            let typeKey = String(describing: landmarkType.rawValue)
            
            if let prev = previousPositions[typeKey] {
                let dx = Double(x - prev[0])
                let dy = Double(y - prev[1])
                totalDisplacement += sqrt(dx * dx + dy * dy)
                count += 1
            }
            
            previousPositions[typeKey] = [x, y]
        }
        
        return count > 0 ? totalDisplacement / Double(count) : 0
    }
    
    private func updateStabilityScore() {
        let avgSpeed = averageSpeed
        
        if avgSpeed < PoseStabilizer.stabilityHighThreshold {
            stabilityScore = 0.3 * 1.0 + 0.7 * stabilityScore
        } else if avgSpeed > PoseStabilizer.stabilityLowThreshold {
            stabilityScore = 0.3 * 0.2 + 0.7 * stabilityScore
        } else {
            let t = (avgSpeed - PoseStabilizer.stabilityHighThreshold) /
                    (PoseStabilizer.stabilityLowThreshold - PoseStabilizer.stabilityHighThreshold)
            let raw = 1.0 - t * 0.8
            stabilityScore = 0.3 * raw + 0.7 * stabilityScore
        }
    }
    
    private func updateFluidityScore() {
        let speedVar = speedVariance
        let accSmoothnessScore = max(0, 1.0 - lastAccuracyDelta * 20)
        let speedSmoothnessScore = max(0, 1.0 - speedVar / 50.0)
        let rawFluidity = 0.5 * accSmoothnessScore + 0.5 * speedSmoothnessScore
        fluidityScore = 0.2 * rawFluidity + 0.8 * fluidityScore
    }
    
    private var averageSpeed: Double {
        let count = speedHistoryFilled ? PoseStabilizer.speedHistorySize : speedHistoryIndex
        guard count > 0 else { return 0 }
        return speedHistory.prefix(count).reduce(0, +) / Double(count)
    }
    
    private var speedVariance: Double {
        let count = speedHistoryFilled ? PoseStabilizer.speedHistorySize : speedHistoryIndex
        guard count >= 2 else { return 0 }
        let avg = averageSpeed
        let sumSq = speedHistory.prefix(count).reduce(0.0) { sum, speed in
            let diff = speed - avg
            return sum + diff * diff
        }
        return sumSq / Double(count)
    }
    
    // ═══════════════════════════════════════════
    // Getters — Etiketler
    // ═══════════════════════════════════════════
    
    var movementSpeed: Double { smoothedSpeed }
    
    var poseQualityLabel: String {
        if smoothedAccuracy > 0.75 { return "Mükemmel" }
        if smoothedAccuracy > 0.55 { return "İyi" }
        if smoothedAccuracy > 0.35 { return "Orta" }
        return "Düşük"
    }
    
    var stabilityLabel: String {
        if stabilityScore > 0.7 { return "Stabil" }
        if stabilityScore > 0.4 { return "Normal" }
        return "Dengesiz"
    }
    
    var fluidityLabel: String {
        if fluidityScore > 0.7 { return "Akıcı" }
        if fluidityScore > 0.4 { return "Normal" }
        return "Kesikli"
    }
    
    /// Tüm state'i sıfırla.
    func reset() {
        smoothedAccuracy = 0.5
        smoothedSpeed = 0.0
        stabilityScore = 0.5
        fluidityScore = 0.5
        speedHistoryIndex = 0
        speedHistoryFilled = false
        lastAccuracyDelta = 0
        previousPositions.removeAll()
        speedHistory = Array(repeating: 0, count: PoseStabilizer.speedHistorySize)
    }
}
