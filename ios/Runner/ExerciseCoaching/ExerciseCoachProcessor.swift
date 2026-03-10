import Foundation
import MLKitPoseDetection
import Flutter

/// Egzersiz koçluk işlemcisi.
/// MLKit Pose Detection'dan alınan Pose nesnelerini kullanarak
/// egzersiz değerlendirmesi yapar ve sonuçları Flutter'a gönderir.
/// Android'deki ExerciseCoachProcessor.java karşılığı.
class ExerciseCoachProcessor: NSObject {
    private static let TAG = "ExerciseCoachProcessor"
    
    // Flutter ile iletişim
    var eventSink: FlutterEventSink?
    
    // Egzersiz durumu
    private var isCoachingEnabled = false
    private var isExerciseActive = false
    private var isPaused = false
    private var currentExercise: [String: Any]?
    private var repetitionCount = 0
    
    // Modüler egzersiz sistemi
    private var currentAnalyzer: ExerciseAnalyzer?
    
    // Stabilizasyon ve koçluk sistemi
    private let poseStabilizer = PoseStabilizer()
    private let feedbackManager = CoachingFeedbackManager()
    
    // FPS optimizasyonu
    private var lastProcessTime: Int64 = 0
    private static let processIntervalMs: Int64 = 150 // ~7 FPS
    
    // Stabilize metrik gönderim throttling
    private var lastMetricsTime: Int64 = 0
    private static let metricsIntervalMs: Int64 = 1000
    
    override init() {
        super.init()
        
        // Feedback değiştiğinde UI'ya gönder
        feedbackManager.onFeedbackChanged = { [weak self] message in
            self?.sendFeedbackEvent(message)
        }
        
        print("[\(ExerciseCoachProcessor.TAG)] ExerciseCoachProcessor created")
    }
    
    // MARK: - Exercise Control
    
    func startExercise(_ exerciseData: [String: Any]) {
        print("[\(ExerciseCoachProcessor.TAG)] Starting exercise: \(exerciseData)")
        currentExercise = exerciseData
        isExerciseActive = true
        isCoachingEnabled = true
        isPaused = false
        repetitionCount = 0
        
        let exerciseType = exerciseData["type"] as? String ?? "default"
        let analyzerType = exerciseData["analyzerType"] as? String ?? ""
        
        if analyzerType == "default" {
            var rules = exerciseData["rules"] as? [String: Any] ?? [:]
            let feedbackRules = exerciseData["feedback"] as? [[String: Any]]
            rules["exerciseName"] = exerciseData["title"] as? String
            rules["exerciseType"] = exerciseData["type"] as? String
            currentAnalyzer = ExerciseAnalyzerFactory.createAnalyzer(analyzerType: "default", rules: rules, feedbackRules: feedbackRules)
        } else {
            currentAnalyzer = ExerciseAnalyzerFactory.createAnalyzer(exerciseId: exerciseType)
        }
        
        guard currentAnalyzer != nil else {
            print("[\(ExerciseCoachProcessor.TAG)] ❌ Desteklenmeyen egzersiz: \(exerciseType)")
            sendFeedback("Bu egzersiz henüz desteklenmiyor: \(exerciseType)")
            return
        }
        
        sendEvent(type: "exercise_started", data: exerciseData)
        
        let startMessage = getStartMessage(exerciseType: exerciseType, exerciseData: exerciseData)
        sendFeedback(startMessage)
        
        print("[\(ExerciseCoachProcessor.TAG)] ✅ Analizör başlatıldı")
    }
    
    func pauseExercise() {
        guard isExerciseActive else { return }
        isPaused = true
        sendEvent(type: "exercise_paused", data: nil)
        sendFeedback("Egzersiz duraklatıldı.")
    }
    
    func resumeExercise() {
        guard isExerciseActive, isPaused else { return }
        isPaused = false
        sendEvent(type: "exercise_resumed", data: nil)
        sendFeedback("Egzersiz devam ediyor.")
    }
    
    func stopExercise() {
        guard isExerciseActive else { return }
        isExerciseActive = false
        isPaused = false
        sendEvent(type: "exercise_stopped", data: nil)
        print("[\(ExerciseCoachProcessor.TAG)] Exercise stopped")
    }
    
    // MARK: - Pose Processing
    
    func processPose(_ pose: Pose) {
        guard isCoachingEnabled, isExerciseActive, !isPaused else { return }
        
        let currentTime = currentTimeMillis()
        guard currentTime - lastProcessTime >= ExerciseCoachProcessor.processIntervalMs else { return }
        lastProcessTime = currentTime
        
        evaluateExercise(pose: pose)
    }
    
    private func evaluateExercise(pose: Pose) {
        guard let analyzer = currentAnalyzer else {
            defaultEvaluation(pose: pose)
            return
        }
        
        let result = analyzer.analyze(pose: pose)
        
        // PoseStabilizer ile metrikleri smooth et
        poseStabilizer.update(pose: pose, rawAccuracy: result.accuracy)
        
        // Smoothed accuracy gönder
        sendAccuracy(poseStabilizer.smoothedAccuracy)
        
        // Feedback gönder
        let priority = CoachingFeedbackManager.detectPriority(result.feedback)
        feedbackManager.proposeFeedback(result.feedback, priority: priority)
        
        // Stabilite metrikleri — 1 saniyede bir gönder
        let now = currentTimeMillis()
        if now - lastMetricsTime >= ExerciseCoachProcessor.metricsIntervalMs {
            lastMetricsTime = now
            sendStabilityMetrics()
        }
        
        // Tekrar tamamlandı?
        if result.isRepetitionComplete {
            repetitionCount += 1
            sendRepetitionCount(repetitionCount)
        }
    }
    
    private func defaultEvaluation(pose: Pose) {
        if Double.random(in: 0...1) < 0.03 {
            repetitionCount += 1
            sendRepetitionCount(repetitionCount)
            let accuracy = 0.5 + Double.random(in: 0...0.5)
            sendAccuracy(accuracy)
        }
    }
    
    // MARK: - Start Messages
    
    private func getStartMessage(exerciseType: String, exerciseData: [String: Any]) -> String {
        let exerciseName = exerciseData["name"] as? String ?? "Egzersiz"
        
        switch exerciseType.lowercased() {
        case "chin_tuck":
            return "🎯 \(exerciseName) başlıyor!\n💪 Çenenizi hafifçe geriye çekin\n⏱️ 5 saniye tutun, 10 tekrar yapın"
        case "upper_trap_stretch":
            return "🎯 \(exerciseName) başlıyor!\n🤲 Elinizle başınızı yana eğin\n⏱️ 20-30 saniye tutun"
        case "neck_rotation_mobilization":
            return "🎯 \(exerciseName) başlıyor!\n🔄 Başınızı yavaşça sağa-sola çevirin\n🔄 Sonra sağa-sola yana eğin"
        default:
            return "🎯 \(exerciseName) başlıyor!\n📱 Kameraya bakın, hazır olduğunuzda başlayacağız\n▶️ Koçunuz hazır!"
        }
    }
    
    // MARK: - Event Sending
    
    private func sendStabilityMetrics() {
        guard eventSink != nil else { return }
        
        let data: [String: Any] = [
            "poseQuality": poseStabilizer.poseQualityLabel,
            "stability": poseStabilizer.stabilityLabel,
            "fluidity": poseStabilizer.fluidityLabel,
            "stabilityScore": poseStabilizer.stabilityScore,
            "fluidityScore": poseStabilizer.fluidityScore,
            "movementSpeed": poseStabilizer.movementSpeed
        ]
        
        sendEvent(type: "stability_metrics", data: data)
    }
    
    private func sendAccuracy(_ accuracy: Double) {
        guard eventSink != nil else { return }
        sendEvent(type: "accuracy", data: ["value": accuracy])
    }
    
    private func sendRepetitionCount(_ count: Int) {
        guard eventSink != nil else { return }
        sendEvent(type: "repetition", data: ["count": count])
    }
    
    private func sendFeedbackEvent(_ message: String) {
        guard eventSink != nil else { return }
        let data: [String: Any] = [
            "message": message,
            "timestamp": currentTimeMillis()
        ]
        sendEvent(type: "feedback", data: data)
    }
    
    private func sendFeedback(_ message: String) {
        guard !message.isEmpty else { return }
        let priority = CoachingFeedbackManager.detectPriority(message)
        feedbackManager.proposeFeedback(message, priority: priority)
    }
    
    private func sendEvent(type: String, data: Any?) {
        guard let eventSink = eventSink else {
            print("[\(ExerciseCoachProcessor.TAG)] EventSink nil, event yok sayılıyor: \(type)")
            return
        }
        
        var event: [String: Any] = ["type": type]
        if let data = data {
            event["data"] = data
        }
        
        DispatchQueue.main.async {
            eventSink(event)
        }
    }
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

// MARK: - FlutterStreamHandler

extension ExerciseCoachProcessor: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("[\(ExerciseCoachProcessor.TAG)] EventSink attached")
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("[\(ExerciseCoachProcessor.TAG)] EventSink detached")
        self.eventSink = nil
        return nil
    }
}
