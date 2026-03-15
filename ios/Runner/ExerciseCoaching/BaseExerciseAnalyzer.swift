import Foundation
import MLKitPoseDetection

/// Egzersiz analiz sonucunu temsil eden yapı.
struct AnalysisResult {
    let accuracy: Double      // 0.0 - 1.0
    let feedback: String      // Kullanıcıya gösterilecek mesaj
    let isRepetitionComplete: Bool // Tekrar tamamlandı mı?
    let debugInfo: [String: Any]?  // Debug overlay için ek bilgi
    
    init(accuracy: Double, feedback: String, isRepetitionComplete: Bool = false, debugInfo: [String: Any]? = nil) {
        self.accuracy = accuracy
        self.feedback = feedback
        self.isRepetitionComplete = isRepetitionComplete
        self.debugInfo = debugInfo
    }
}

/// Tüm egzersiz analizörlerinin protokolü.
/// Android'deki BaseExerciseAnalyzer.java karşılığı.
protocol ExerciseAnalyzer: AnyObject {
    /// Poz verisini analiz eder ve sonuç döndürür
    func analyze(pose: Pose) -> AnalysisResult
    
    /// Analizörü sıfırlar (yeni egzersiz başladığında)
    func reset()
}

/// Varsayılan reset implementasyonu
extension ExerciseAnalyzer {
    func reset() {
        // Override edilebilir
    }
}
