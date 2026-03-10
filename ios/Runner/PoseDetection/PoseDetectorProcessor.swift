import Foundation
import MLKitVision
import MLKitPoseDetectionAccurate
import MLKitPoseDetection
import AVFoundation

/// ML Kit Pose Detection wrapper.
/// CMSampleBuffer'dan VisionImage oluşturur ve Pose döndürür.
/// Android'deki PoseDetectorProcessor.java karşılığı.
class PoseDetectorProcessor {
    private static let TAG = "PoseDetectorProcessor"
    
    private let poseDetector: PoseDetector
    private var isProcessing = false
    
    /// Pose algılandığında çağrılan callback
    var onPoseDetected: ((Pose) -> Void)?
    
    /// Hata oluştuğunda çağrılan callback
    var onError: ((Error) -> Void)?
    
    init(useAccurateModel: Bool = true) {
        let options: PoseDetectorOptions
        if useAccurateModel {
            let accurateOptions = AccuratePoseDetectorOptions()
            accurateOptions.detectorMode = .stream
            options = accurateOptions
        } else {
            options = PoseDetectorOptions()
            options.detectorMode = .stream
        }
        
        poseDetector = PoseDetector.poseDetector(options: options)
        print("[\(PoseDetectorProcessor.TAG)] PoseDetectorProcessor initialized (accurate: \(useAccurateModel))")
    }
    
    /// CMSampleBuffer'dan poz algıla
    /// - Parameters:
    ///   - sampleBuffer: Kameradan gelen frame
    ///   - orientation: Görüntü yönü
    func detectPose(in sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
        guard !isProcessing else { return } // Bir önceki frame işlenirken yeniyi atla
        isProcessing = true
        
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = orientation
        
        poseDetector.process(image) { [weak self] poses, error in
            guard let self = self else { return }
            self.isProcessing = false
            
            if let error = error {
                print("[\(PoseDetectorProcessor.TAG)] Pose detection error: \(error.localizedDescription)")
                self.onError?(error)
                return
            }
            
            guard let poses = poses, !poses.isEmpty, let pose = poses.first else {
                return
            }
            
            self.onPoseDetected?(pose)
        }
    }
    
    /// Detector'ı kapat
    func close() {
        // ML Kit iOS'ta explicit close yok, ARC yönetir
        print("[\(PoseDetectorProcessor.TAG)] PoseDetectorProcessor closed")
    }
}
