import Foundation
import MLKitPoseDetection

/// PoseDetectorProcessor ile ExerciseCoachProcessor arasındaki adapter.
/// Android'deki PoseDetectorToExerciseAdapter.java karşılığı (singleton pattern).
class PoseDetectorToExerciseAdapter {
    
    static let shared = PoseDetectorToExerciseAdapter()
    
    private var exerciseCoachProcessor: ExerciseCoachProcessor?
    private var enabled = false
    
    private init() {}
    
    /// ExerciseCoachProcessor'ı ayarla
    func setExerciseCoachProcessor(_ processor: ExerciseCoachProcessor?) {
        exerciseCoachProcessor = processor
        print("[PoseAdapter] ExerciseCoachProcessor set")
    }
    
    /// Adapter'ın etkin olup olmadığını ayarla
    func setEnabled(_ isEnabled: Bool) {
        enabled = isEnabled
        print("[PoseAdapter] Adapter enabled: \(enabled)")
    }
    
    /// Poz verisini exercise coach'a ilet
    func processPose(_ pose: Pose) {
        guard enabled, let processor = exerciseCoachProcessor else { return }
        
        do {
            processor.processPose(pose)
        } catch {
            print("[PoseAdapter] Error processing pose: \(error)")
        }
    }
}
