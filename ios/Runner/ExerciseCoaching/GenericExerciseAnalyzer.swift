import Foundation
import MLKitPoseDetection

/// JSON rule tabanlı generic egzersiz analizörü.
/// Android'deki GenericExerciseAnalyzer.java karşılığı.
///
/// State Machine:
/// - IDLE: Kişi algılanmıyor veya güvenilirlik düşük
/// - POSITIONING: Kişi görünüyor ama tam pozisyonda değil
/// - EXERCISING: Tam pozisyonda, egzersiz yapılıyor
class GenericExerciseAnalyzer: ExerciseAnalyzer {
    
    private enum State {
        case idle
        case positioning
        case exercising
    }
    
    private let exerciseName: String
    private let exerciseType: String
    private let rules: [String: Any]?
    private let feedbackRules: [[String: Any]]?
    
    // State tracking
    private var currentState: State = .idle
    private var stateEntryTime: Int64 = 0
    private var exerciseStartTime: Int64 = 0
    
    // Hareket algılama
    private var previousPositions: [String: [CGFloat]] = [:]
    private var smoothedMovementSpeed: Double = 0
    
    private static let movementAlpha: Double = 0.3
    private static let activeMovementThreshold: Double = 5.0
    private static let minConfidenceForPositioning: Double = 0.4
    private static let minConfidenceForExercising: Double = 0.6
    
    // Positioning süre kontrolü
    private static let positioningStableMs: Int64 = 1500
    private var positioningStableStart: Int64 = 0
    
    init(exerciseName: String, exerciseType: String, rules: [String: Any]?, feedbackRules: [[String: Any]]?) {
        self.exerciseName = exerciseName.isEmpty ? "Egzersiz" : exerciseName
        self.exerciseType = exerciseType.isEmpty ? "generic" : exerciseType
        self.rules = rules
        self.feedbackRules = feedbackRules
        print("[GenericAnalyzer] Created for: \(self.exerciseName)")
    }
    
    func analyze(pose: Pose) -> AnalysisResult {
        if pose.landmarks.isEmpty {
            transitionTo(.idle)
            return AnalysisResult(accuracy: 0.0, feedback: "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.")
        }
        
        let avgConfidence = calculateAverageConfidence(pose: pose)
        let movementSpeed = calculateMovementSpeed(pose: pose)
        smoothedMovementSpeed = GenericExerciseAnalyzer.movementAlpha * movementSpeed + (1 - GenericExerciseAnalyzer.movementAlpha) * smoothedMovementSpeed
        
        return processState(pose: pose, avgConfidence: avgConfidence, movementSpeed: smoothedMovementSpeed)
    }
    
    private func processState(pose: Pose, avgConfidence: Double, movementSpeed: Double) -> AnalysisResult {
        let now = currentTimeMillis()
        
        switch currentState {
            
        case .idle:
            if avgConfidence >= GenericExerciseAnalyzer.minConfidenceForPositioning {
                transitionTo(.positioning)
                positioningStableStart = now
                return AnalysisResult(accuracy: 0.25, feedback:
                    "👤 Sizi görüyorum!\n📏 Lütfen düz durun ve hazırlanın.\n🎯 \(exerciseName) için hazırlanıyoruz.")
            }
            return AnalysisResult(accuracy: 0.0, feedback: "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.")
            
        case .positioning:
            if avgConfidence < GenericExerciseAnalyzer.minConfidenceForPositioning {
                transitionTo(.idle)
                return AnalysisResult(accuracy: 0.0, feedback: "👤 Kameraya bakın ve tüm vücudunuzun göründüğünden emin olun.")
            }
            
            if avgConfidence >= GenericExerciseAnalyzer.minConfidenceForExercising {
                if movementSpeed < GenericExerciseAnalyzer.activeMovementThreshold {
                    if positioningStableStart == 0 { positioningStableStart = now }
                    let stableTime = now - positioningStableStart
                    
                    if stableTime >= GenericExerciseAnalyzer.positioningStableMs {
                        transitionTo(.exercising)
                        exerciseStartTime = now
                        return AnalysisResult(accuracy: 0.5, feedback:
                            "✅ Harika pozisyon!\n\n▶️ \(exerciseName) başlıyor!\n💪 Koçunuz hazır, başlayabilirsiniz.")
                    }
                    
                    let remaining = (GenericExerciseAnalyzer.positioningStableMs - stableTime) / 1000 + 1
                    return AnalysisResult(accuracy: 0.35, feedback:
                        "📏 Güzel, pozisyonunuz iyi.\n⏳ \(remaining) saniye sabit durun...")
                } else {
                    positioningStableStart = 0
                    return AnalysisResult(accuracy: 0.3, feedback:
                        "📏 Lütfen düz ve sabit durun.\n🧘 Hareket etmeyin, pozisyonunuzu koruyun.")
                }
            }
            
            return AnalysisResult(accuracy: 0.25, feedback:
                "📏 Lütfen tüm vücudunuzun kamerada görünmesini sağlayın.\n💡 Daha iyi sonuç için aydınlık bir ortamda durun.")
            
        case .exercising:
            if avgConfidence < GenericExerciseAnalyzer.minConfidenceForPositioning {
                transitionTo(.positioning)
                positioningStableStart = 0
                return AnalysisResult(accuracy: 0.3, feedback:
                    "⚠️ Sizi kaybettik!\n📏 Lütfen tekrar pozisyona gelin.")
            }
            
            let exerciseElapsed = now - exerciseStartTime
            return generateExerciseFeedback(avgConfidence: avgConfidence, movementSpeed: movementSpeed, elapsedMs: exerciseElapsed)
        }
    }
    
    private func generateExerciseFeedback(avgConfidence: Double, movementSpeed: Double, elapsedMs: Int64) -> AnalysisResult {
        let isMoving = movementSpeed >= GenericExerciseAnalyzer.activeMovementThreshold
        
        if avgConfidence > 0.8 && isMoving {
            return AnalysisResult(accuracy: 0.85, feedback:
                "🎯 Mükemmel! Formunuz harika.\n💪 Böyle devam edin!\n🕐 \(formatElapsed(elapsedMs))")
        }
        
        if avgConfidence > 0.6 && isMoving {
            return AnalysisResult(accuracy: 0.7, feedback:
                "👍 İyi gidiyorsunuz!\n📋 \(exerciseName) yapıyorsunuz.\n🕐 \(formatElapsed(elapsedMs))")
        }
        
        if !isMoving {
            return AnalysisResult(accuracy: 0.55, feedback:
                "🧘 Sabit duruyorsunuz.\n▶️ Harekete geçebilirsiniz!\n🕐 \(formatElapsed(elapsedMs))")
        }
        
        return AnalysisResult(accuracy: 0.5, feedback:
            "📋 \(exerciseName) devam ediyor.\n💡 Tüm vücudunuzun görünmesine dikkat edin.\n🕐 \(formatElapsed(elapsedMs))")
    }
    
    private func transitionTo(_ newState: State) {
        if currentState != newState {
            print("[GenericAnalyzer] State geçişi: \(currentState) → \(newState)")
            currentState = newState
            stateEntryTime = currentTimeMillis()
        }
    }
    
    private func calculateAverageConfidence(pose: Pose) -> Double {
        let landmarks = pose.landmarks
        guard !landmarks.isEmpty else { return 0 }
        let total = landmarks.reduce(0.0) { $0 + Double($1.inFrameLikelihood) }
        return total / Double(landmarks.count)
    }
    
    private func calculateMovementSpeed(pose: Pose) -> Double {
        var totalDisplacement: Double = 0
        var count = 0
        
        let keyTypes: [PoseLandmarkType] = [.nose, .leftShoulder, .rightShoulder, .leftHip, .rightHip, .leftElbow, .rightElbow]
        
        for landmarkType in keyTypes {
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
    
    private func formatElapsed(_ ms: Int64) -> String {
        let seconds = Int(ms / 1000) % 60
        let minutes = Int(ms / (1000 * 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func reset() {
        currentState = .idle
        stateEntryTime = 0
        exerciseStartTime = 0
        positioningStableStart = 0
        smoothedMovementSpeed = 0
        previousPositions.removeAll()
        print("[GenericAnalyzer] Reset")
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
