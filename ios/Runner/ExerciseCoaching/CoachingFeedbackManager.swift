import Foundation

/// Koçluk geri bildirimlerini yöneten ve stabilize eden sınıf.
/// Android'deki CoachingFeedbackManager.java karşılığı.
///
/// 1. Minimum görüntülenme süresi: Mesaj en az 2 saniye ekranda kalır
/// 2. Öncelik sistemi: Güvenlik > Tekrar > Koçluk > Bilgi
/// 3. Geçiş debounce: Yeni mesajın en az 500ms boyunca tutarlı olması gerekir
class CoachingFeedbackManager {
    
    // ═══════════════════════════════════════════
    // Feedback Parametreleri
    // ═══════════════════════════════════════════
    
    private static let minDisplayDurationMs: Int64 = 2000
    private static let debounceDurationMs: Int64 = 500
    
    static let priorityCritical = 100
    static let priorityRepCount = 80
    static let priorityStateChange = 60
    static let priorityCoaching = 40
    static let priorityInfo = 20
    
    // ═══════════════════════════════════════════
    // State
    // ═══════════════════════════════════════════
    
    private var currentMessage = ""
    private var currentPriority = 0
    private var currentMessageStartTime: Int64 = 0
    
    private var pendingMessage = ""
    private var pendingPriority = 0
    private var pendingStartTime: Int64 = 0
    
    /// Feedback değişikliği callback
    var onFeedbackChanged: ((String) -> Void)?
    
    // MARK: - Public API
    
    /// Yeni bir feedback mesajı öner.
    func proposeFeedback(_ message: String, priority: Int) {
        guard !message.isEmpty else { return }
        
        let now = currentTimeMillis()
        
        // Aynı mesaj tekrarı → yok say
        if message == currentMessage { return }
        
        // Yüksek öncelikli mesaj → anında göster
        if priority >= CoachingFeedbackManager.priorityRepCount {
            showMessage(message, priority: priority, time: now)
            return
        }
        
        // Mevcut mesaj minimum süresini doldurmadıysa
        let elapsed = now - currentMessageStartTime
        if elapsed < CoachingFeedbackManager.minDisplayDurationMs && priority <= currentPriority {
            return
        }
        
        // Debounce
        if message != pendingMessage {
            pendingMessage = message
            pendingPriority = priority
            pendingStartTime = now
            return
        }
        
        // Aynı aday mesaj — debounce süresi doldu mu?
        if now - pendingStartTime >= CoachingFeedbackManager.debounceDurationMs {
            showMessage(message, priority: priority, time: now)
            pendingMessage = ""
        }
    }
    
    private func showMessage(_ message: String, priority: Int, time: Int64) {
        currentMessage = message
        currentPriority = priority
        currentMessageStartTime = time
        pendingMessage = ""
        
        print("[CoachFeedback] 📢 Feedback (P=\(priority)): \(message)")
        onFeedbackChanged?(message)
    }
    
    // ═══════════════════════════════════════════
    // Convenience metodlar
    // ═══════════════════════════════════════════
    
    func safetyWarning(_ message: String) {
        proposeFeedback(message, priority: CoachingFeedbackManager.priorityCritical)
    }
    
    func repCompleted(_ message: String) {
        proposeFeedback(message, priority: CoachingFeedbackManager.priorityRepCount)
    }
    
    func stateChange(_ message: String) {
        proposeFeedback(message, priority: CoachingFeedbackManager.priorityStateChange)
    }
    
    func coaching(_ message: String) {
        proposeFeedback(message, priority: CoachingFeedbackManager.priorityCoaching)
    }
    
    func info(_ message: String) {
        proposeFeedback(message, priority: CoachingFeedbackManager.priorityInfo)
    }
    
    var getCurrentMessage: String { currentMessage }
    
    func reset() {
        currentMessage = ""
        currentPriority = 0
        currentMessageStartTime = 0
        pendingMessage = ""
        pendingPriority = 0
        pendingStartTime = 0
    }
    
    // ═══════════════════════════════════════════
    // Static helper: Mesaj içeriğinden öncelik çıkar
    // ═══════════════════════════════════════════
    
    static func detectPriority(_ message: String?) -> Int {
        guard let message = message else { return priorityInfo }
        
        if message.contains("⚠️") || message.contains("DİKKAT") ||
            message.contains("Dikkat") || message.contains("fazla") {
            return priorityCritical
        }
        
        if message.contains("tamamlandı") || message.contains("TEBRİKLER") ||
            message.contains("🏆") || message.contains("👏") {
            return priorityRepCount
        }
        
        if message.contains("Şimdi") || message.contains("tutun") ||
            message.contains("eğilin") || message.contains("dönün") ||
            message.contains("Mükemmel açı") {
            return priorityStateChange
        }
        
        if message.contains("Devam") || message.contains("Güzel") ||
            message.contains("iyi") || message.contains("daha") {
            return priorityCoaching
        }
        
        return priorityInfo
    }
    
    // MARK: - Helper
    
    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
