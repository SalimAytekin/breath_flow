import Foundation

/// Egzersiz analizörleri için Factory sınıfı.
/// Android'deki ExerciseAnalyzerFactory.java karşılığı.
class ExerciseAnalyzerFactory {
    
    /// Egzersiz ID'sine göre uygun analizörü döndürür.
    static func createAnalyzer(exerciseId: String) -> ExerciseAnalyzer? {
        guard !exerciseId.isEmpty else { return nil }
        
        switch exerciseId.lowercased() {
        case "neck_side_bend", "neck_lateral_flexion", "neckmovement":
            return NeckSideBendAnalyzer()
        case "squat":
            return SquatAnalyzer()
        case "shoulder_stretch", "shoulderstretch":
            return ShoulderStretchAnalyzer()
        default:
            return GenericExerciseAnalyzer(exerciseName: exerciseId, exerciseType: exerciseId, rules: nil, feedbackRules: nil)
        }
    }
    
    /// Kural tabanlı generic analizör
    static func createAnalyzer(analyzerType: String, rules: [String: Any]?, feedbackRules: [[String: Any]]?) -> ExerciseAnalyzer {
        let exerciseName = rules?["exerciseName"] as? String ?? "Generic"
        let exerciseType = rules?["exerciseType"] as? String ?? "generic"
        return GenericExerciseAnalyzer(exerciseName: exerciseName, exerciseType: exerciseType, rules: rules, feedbackRules: feedbackRules)
    }
    
    /// Desteklenen egzersiz ID'leri
    static let supportedExerciseIds = [
        "neck_side_bend", "neck_lateral_flexion", "neckmovement",
        "squat",
        "shoulder_stretch", "shoulderstretch"
    ]
}
