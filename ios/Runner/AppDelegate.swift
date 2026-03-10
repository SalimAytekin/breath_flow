import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let methodChannelName = "com.breathflow.app/pose_detector"
    private let eventChannelName = "com.breathflow.app/pose_data"
    
    private var exerciseCoachProcessor: ExerciseCoachProcessor?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        let binaryMessenger = controller.binaryMessenger
        
        // ExerciseCoachProcessor oluştur
        exerciseCoachProcessor = ExerciseCoachProcessor()
        
        // EventChannel — coaching feedback'lerini Flutter'a gönderir
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: binaryMessenger)
        eventChannel.setStreamHandler(exerciseCoachProcessor)
        
        // MethodChannel — Flutter'dan komutları alır
        let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            print("[AppDelegate] Method call: \(call.method)")
            
            switch call.method {
            case "startExerciseCoaching":
                self.handleStartExerciseCoaching(call: call, result: result, controller: controller)
                
            case "startPoseDetection":
                self.handleStartPoseDetection(controller: controller, result: result)
                
            case "stopPoseDetection":
                result(true)
                
            case "startCoaching":
                if let data = call.arguments as? [String: Any] {
                    self.exerciseCoachProcessor?.startExercise(data)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Exercise data required", details: nil))
                }
                
            case "stopCoaching":
                self.exerciseCoachProcessor?.stopExercise()
                result(true)
                
            case "pauseCoaching":
                self.exerciseCoachProcessor?.pauseExercise()
                result(true)
                
            case "resumeCoaching":
                self.exerciseCoachProcessor?.resumeExercise()
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Method Handlers
    
    private func handleStartExerciseCoaching(call: FlutterMethodCall, result: @escaping FlutterResult, controller: FlutterViewController) {
        guard let exerciseData = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Exercise data required", details: nil))
            return
        }
        
        guard let processor = exerciseCoachProcessor else {
            result(FlutterError(code: "INIT_ERROR", message: "Coach processor not initialized", details: nil))
            return
        }
        
        let coachingVC = ExerciseCoachingViewController()
        coachingVC.configure(exerciseData: exerciseData, coachProcessor: processor)
        coachingVC.modalPresentationStyle = .fullScreen
        
        controller.present(coachingVC, animated: true) {
            result(true)
        }
    }
    
    private func handleStartPoseDetection(controller: FlutterViewController, result: @escaping FlutterResult) {
        let cameraVC = CameraPreviewViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        
        controller.present(cameraVC, animated: true) {
            result(true)
        }
    }
}
