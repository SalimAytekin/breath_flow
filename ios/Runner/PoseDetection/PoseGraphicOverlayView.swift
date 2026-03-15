import UIKit
import MLKitPoseDetection

/// İskelet çizim overlay'i (UIView).
/// Core Graphics ile EMA smoothing uygulanarak poz çizimi yapar.
/// Android'deki PoseGraphic.java karşılığı.
class PoseGraphicOverlayView: UIView {
    
    // ═══════════════════════════════════════════
    // Çizim parametreleri
    // ═══════════════════════════════════════════
    private static let dotRadius: CGFloat = 8.0
    private static let strokeWidth: CGFloat = 4.0
    
    // ═══════════════════════════════════════════
    // EMA Smoothing parametreleri (Android ile aynı)
    // ═══════════════════════════════════════════
    private static let emaAlpha: CGFloat = 0.35
    private static let deadZonePx: CGFloat = 2.0
    
    // Smoothed pozisyonlar — frame'ler arasında tutuluyor
    private var smoothedPositions: [String: [CGFloat]] = [:]
    
    // Mevcut poz verisi
    private var currentPose: Pose?
    
    // Görüntü boyutları (koordinat dönüşümü için)
    private var imageWidth: CGFloat = 1.0
    private var imageHeight: CGFloat = 1.0
    private var isFrontCamera: Bool = true
    
    // Renkler
    private let leftPaint = UIColor.green
    private let rightPaint = UIColor.yellow
    private let whitePaint = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    // MARK: - Public API
    
    /// Yeni poz verisini ayarla ve yeniden çiz
    func updatePose(_ pose: Pose?, imageWidth: CGFloat, imageHeight: CGFloat, isFrontCamera: Bool = true) {
        self.currentPose = pose
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.isFrontCamera = isFrontCamera
        setNeedsDisplay()
    }
    
    /// Smoothing arabelleğini temizle
    func resetSmoothing() {
        smoothedPositions.removeAll()
    }
    
    // MARK: - Coordinate Transform
    
    /// Image koordinatlarını view koordinatlarına dönüştür.
    /// NOT: Ön kamera için AVCaptureConnection.isVideoMirrored = true
    /// olduğundan video çıkışı zaten aynalanmış durumda.
    /// Bu yüzden overlay'da tekrar aynalama yapmıyoruz.
    private func translateX(_ x: CGFloat) -> CGFloat {
        let scaleX = bounds.width / imageWidth
        return x * scaleX
    }
    
    private func translateY(_ y: CGFloat) -> CGFloat {
        let scaleY = bounds.height / imageHeight
        return y * scaleY
    }
    
    // MARK: - EMA Smoothing
    
    /// Landmark pozisyonunu EMA ile smooth et (Android PoseGraphic ile aynı)
    private func getSmoothedPosition(for landmark: PoseLandmark) -> [CGFloat] {
        let type = String(describing: landmark.type.rawValue)
        let rawX = CGFloat(landmark.position.x)
        let rawY = CGFloat(landmark.position.y)
        let rawZ = CGFloat(truncating: landmark.position.z as NSNumber)
        
        guard let prev = smoothedPositions[type] else {
            // İlk frame — direkt raw değeri kullan
            let pos: [CGFloat] = [rawX, rawY, rawZ]
            smoothedPositions[type] = pos
            return pos
        }
        
        // Dead zone kontrolü
        let dx = rawX - prev[0]
        let dy = rawY - prev[1]
        let dist = sqrt(dx * dx + dy * dy)
        
        if dist < PoseGraphicOverlayView.deadZonePx {
            return prev // Hareket yok — eski pozisyonu koru
        }
        
        // EMA smoothing
        let alpha = PoseGraphicOverlayView.emaAlpha
        let smoothX = alpha * rawX + (1 - alpha) * prev[0]
        let smoothY = alpha * rawY + (1 - alpha) * prev[1]
        let smoothZ = alpha * rawZ + (1 - alpha) * prev[2]
        
        let smoothed: [CGFloat] = [smoothX, smoothY, smoothZ]
        let typeKey = String(describing: landmark.type.rawValue)
        smoothedPositions[typeKey] = smoothed
        return smoothed
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let pose = currentPose, let context = UIGraphicsGetCurrentContext() else { return }
        
        let landmarks = pose.landmarks
        guard !landmarks.isEmpty else { return }
        
        // Tüm landmark'ları smooth et
        for landmark in landmarks {
            _ = getSmoothedPosition(for: landmark)
        }
        
        // Tüm noktaları çiz
        for landmark in landmarks {
            drawSmoothedPoint(context: context, landmark: landmark, color: whitePaint)
        }
        
        // Landmark'ları getir
        let nose = pose.landmark(ofType: .nose)
        let leftEyeInner = pose.landmark(ofType: .leftEyeInner)
        let leftEye = pose.landmark(ofType: .leftEye)
        let leftEyeOuter = pose.landmark(ofType: .leftEyeOuter)
        let rightEyeInner = pose.landmark(ofType: .rightEyeInner)
        let rightEye = pose.landmark(ofType: .rightEye)
        let rightEyeOuter = pose.landmark(ofType: .rightEyeOuter)
        let leftEar = pose.landmark(ofType: .leftEar)
        let rightEar = pose.landmark(ofType: .rightEar)
        let leftMouth = pose.landmark(ofType: .mouthLeft)
        let rightMouth = pose.landmark(ofType: .mouthRight)
        
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let rightElbow = pose.landmark(ofType: .rightElbow)
        let leftWrist = pose.landmark(ofType: .leftWrist)
        let rightWrist = pose.landmark(ofType: .rightWrist)
        let leftHip = pose.landmark(ofType: .leftHip)
        let rightHip = pose.landmark(ofType: .rightHip)
        let leftKnee = pose.landmark(ofType: .leftKnee)
        let rightKnee = pose.landmark(ofType: .rightKnee)
        let leftAnkle = pose.landmark(ofType: .leftAnkle)
        let rightAnkle = pose.landmark(ofType: .rightAnkle)
        
        let leftPinky = pose.landmark(ofType: .leftPinkyFinger)
        let rightPinky = pose.landmark(ofType: .rightPinkyFinger)
        let leftIndex = pose.landmark(ofType: .leftIndexFinger)
        let rightIndex = pose.landmark(ofType: .rightIndexFinger)
        let leftThumb = pose.landmark(ofType: .leftThumb)
        let rightThumb = pose.landmark(ofType: .rightThumb)
        let leftHeel = pose.landmark(ofType: .leftHeel)
        let rightHeel = pose.landmark(ofType: .rightHeel)
        let leftFootIndex = pose.landmark(ofType: .leftToe)
        let rightFootIndex = pose.landmark(ofType: .rightToe)
        
        // Face
        drawSmoothedLine(context: context, from: nose, to: leftEyeInner, color: whitePaint)
        drawSmoothedLine(context: context, from: leftEyeInner, to: leftEye, color: whitePaint)
        drawSmoothedLine(context: context, from: leftEye, to: leftEyeOuter, color: whitePaint)
        drawSmoothedLine(context: context, from: leftEyeOuter, to: leftEar, color: whitePaint)
        drawSmoothedLine(context: context, from: nose, to: rightEyeInner, color: whitePaint)
        drawSmoothedLine(context: context, from: rightEyeInner, to: rightEye, color: whitePaint)
        drawSmoothedLine(context: context, from: rightEye, to: rightEyeOuter, color: whitePaint)
        drawSmoothedLine(context: context, from: rightEyeOuter, to: rightEar, color: whitePaint)
        drawSmoothedLine(context: context, from: leftMouth, to: rightMouth, color: whitePaint)
        
        // Center
        drawSmoothedLine(context: context, from: leftShoulder, to: rightShoulder, color: whitePaint)
        drawSmoothedLine(context: context, from: leftHip, to: rightHip, color: whitePaint)
        
        // Left body
        drawSmoothedLine(context: context, from: leftShoulder, to: leftElbow, color: leftPaint)
        drawSmoothedLine(context: context, from: leftElbow, to: leftWrist, color: leftPaint)
        drawSmoothedLine(context: context, from: leftShoulder, to: leftHip, color: leftPaint)
        drawSmoothedLine(context: context, from: leftHip, to: leftKnee, color: leftPaint)
        drawSmoothedLine(context: context, from: leftKnee, to: leftAnkle, color: leftPaint)
        drawSmoothedLine(context: context, from: leftWrist, to: leftThumb, color: leftPaint)
        drawSmoothedLine(context: context, from: leftWrist, to: leftPinky, color: leftPaint)
        drawSmoothedLine(context: context, from: leftWrist, to: leftIndex, color: leftPaint)
        drawSmoothedLine(context: context, from: leftIndex, to: leftPinky, color: leftPaint)
        drawSmoothedLine(context: context, from: leftAnkle, to: leftHeel, color: leftPaint)
        drawSmoothedLine(context: context, from: leftHeel, to: leftFootIndex, color: leftPaint)
        
        // Right body
        drawSmoothedLine(context: context, from: rightShoulder, to: rightElbow, color: rightPaint)
        drawSmoothedLine(context: context, from: rightElbow, to: rightWrist, color: rightPaint)
        drawSmoothedLine(context: context, from: rightShoulder, to: rightHip, color: rightPaint)
        drawSmoothedLine(context: context, from: rightHip, to: rightKnee, color: rightPaint)
        drawSmoothedLine(context: context, from: rightKnee, to: rightAnkle, color: rightPaint)
        drawSmoothedLine(context: context, from: rightWrist, to: rightThumb, color: rightPaint)
        drawSmoothedLine(context: context, from: rightWrist, to: rightPinky, color: rightPaint)
        drawSmoothedLine(context: context, from: rightWrist, to: rightIndex, color: rightPaint)
        drawSmoothedLine(context: context, from: rightIndex, to: rightPinky, color: rightPaint)
        drawSmoothedLine(context: context, from: rightAnkle, to: rightHeel, color: rightPaint)
        drawSmoothedLine(context: context, from: rightHeel, to: rightFootIndex, color: rightPaint)
    }
    
    // MARK: - Drawing Helpers
    
    /// Minimum güvenilirlik eşiği — bu değerin altındaki landmark'lar çizilmez
    private static let minDrawConfidence: Float = 0.5
    
    private func drawSmoothedPoint(context: CGContext, landmark: PoseLandmark, color: UIColor) {
        // Düşük güvenilirlikli landmark'ları çizme (hayalet uzuv önleme)
        guard landmark.inFrameLikelihood >= PoseGraphicOverlayView.minDrawConfidence else { return }
        
        let sp = getSmoothedPosition(for: landmark)
        let x = translateX(sp[0])
        let y = translateY(sp[1])
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(
            x: x - PoseGraphicOverlayView.dotRadius,
            y: y - PoseGraphicOverlayView.dotRadius,
            width: PoseGraphicOverlayView.dotRadius * 2,
            height: PoseGraphicOverlayView.dotRadius * 2
        ))
    }
    
    private func drawSmoothedLine(context: CGContext, from startLandmark: PoseLandmark, to endLandmark: PoseLandmark, color: UIColor) {
        // Her iki uç noktanın da yeterli güvenilirliğe sahip olması gerekir
        guard startLandmark.inFrameLikelihood >= PoseGraphicOverlayView.minDrawConfidence,
              endLandmark.inFrameLikelihood >= PoseGraphicOverlayView.minDrawConfidence else { return }
        
        let start = getSmoothedPosition(for: startLandmark)
        let end = getSmoothedPosition(for: endLandmark)
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(PoseGraphicOverlayView.strokeWidth)
        context.setLineCap(.round)
        
        context.move(to: CGPoint(x: translateX(start[0]), y: translateY(start[1])))
        context.addLine(to: CGPoint(x: translateX(end[0]), y: translateY(end[1])))
        context.strokePath()
    }
}
