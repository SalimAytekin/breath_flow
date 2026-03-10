import UIKit
import AVFoundation
import MLKitPoseDetection

/// AVFoundation kamera önizlemesi ile poz overlay'i.
/// Android'deki CameraXLivePreviewActivity karşılığı.
class CameraPreviewViewController: UIViewController {
    
    // MARK: - Camera
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.breathflow.camera.session")
    
    // MARK: - Pose Detection
    let poseProcessor = PoseDetectorProcessor(useAccurateModel: true)
    let poseOverlay = PoseGraphicOverlayView()
    
    // MARK: - State
    private var isUsingFrontCamera = true
    private var currentImageWidth: CGFloat = 480
    private var currentImageHeight: CGFloat = 640
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupCamera()
        setupPoseOverlay()
        setupPoseCallbacks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        poseOverlay.frame = view.bounds
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        // Ön kamera
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: isUsingFrontCamera ? .front : .back
        ) else {
            print("[CameraPreview] Camera not available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("[CameraPreview] Camera input error: \(error)")
            return
        }
        
        // Video output
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        // Video yönünü ayarla
        if let connection = videoDataOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if isUsingFrontCamera && connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        // Preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer
        self.captureSession = session
    }
    
    private func setupPoseOverlay() {
        poseOverlay.frame = view.bounds
        poseOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(poseOverlay)
    }
    
    private func setupPoseCallbacks() {
        poseProcessor.onPoseDetected = { [weak self] pose in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.poseOverlay.updatePose(
                    pose,
                    imageWidth: self.currentImageWidth,
                    imageHeight: self.currentImageHeight,
                    isFrontCamera: self.isUsingFrontCamera
                )
            }
            // Adapter üzerinden exercise coaching'e ilet
            PoseDetectorToExerciseAdapter.shared.processPose(pose)
        }
        
        poseProcessor.onError = { error in
            print("[CameraPreview] Pose detection error: \(error)")
        }
    }
    
    // MARK: - Camera Control
    
    func startCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    /// Kamera değiştir (ön/arka)
    func toggleCamera() {
        isUsingFrontCamera.toggle()
        poseOverlay.resetSmoothing()
        
        guard let session = captureSession else { return }
        
        sessionQueue.async {
            // Mevcut input'ları kaldır
            session.beginConfiguration()
            for input in session.inputs {
                session.removeInput(input)
            }
            
            // Yeni kamera
            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: self.isUsingFrontCamera ? .front : .back
            ) else { return }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            } catch {
                print("[CameraPreview] Camera switch error: \(error)")
            }
            
            // Video yönü güncelle
            if let connection = self.videoDataOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if self.isUsingFrontCamera && connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }
            
            session.commitConfiguration()
        }
    }
    
    /// Image orientation — cihaz yönüne göre
    private func imageOrientation() -> UIImage.Orientation {
        if isUsingFrontCamera {
            return .leftMirrored
        }
        return .right
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraPreviewViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Frame boyutlarını güncelle
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let width = CGFloat(CVPixelBufferGetWidth(imageBuffer))
            let height = CGFloat(CVPixelBufferGetHeight(imageBuffer))
            // Portrait modda width/height ters olabilir
            currentImageWidth = min(width, height)
            currentImageHeight = max(width, height)
        }
        
        // Poz algılama
        poseProcessor.detectPose(in: sampleBuffer, orientation: imageOrientation())
    }
}
