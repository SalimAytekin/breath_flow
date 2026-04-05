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
    // EMA Smoothing parametreleri
    // ═══════════════════════════════════════════
    private static let emaAlpha: CGFloat = 0.15 // Titremeyi (jitter) azaltmak için düşürüldü
    private static let deadZonePx: CGFloat = 4.0 // Küçük oynamaları yoksaymak için artırıldı
    
    // Smoothed pozisyonlar — frame'ler arasında tutuluyor
    private var smoothedPositions: [String: [CGFloat]] = [:]
    
    // Mevcut poz verisi
    private var currentPose: Pose?
    var currentExerciseId: String?
    
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
    
    // MARK: - Gamification (Accuracy Color)
    private var currentAccuracy: Double = 0.0
    
    func updateAccuracy(_ accuracy: Double) {
        self.currentAccuracy = accuracy
        setNeedsDisplay()
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
        
        // Dinamik Renk Hesaplama (Gamification)
        // 0.0 (Beyaz) -> 1.0 (Parlak/Neon Yeşil)
        let greenVal = CGFloat(max(0.0, min(1.0, currentAccuracy)))
        
        // Ara renk: Beyaz (1,1,1) -> Yeşil yaklaştıkça kırmızı ve mavi azalıyor
        let redVal = CGFloat(1.0 - greenVal)
        let blueVal = CGFloat(1.0 - greenVal)
        
        let dynamicColor = UIColor(red: redVal, green: 1.0, blue: blueVal, alpha: 0.8)
        let shadowColor = UIColor.green.withAlphaComponent(CGFloat(currentAccuracy * 0.8)).cgColor
        
        // Glow (Neon) Efekti Ekle
        context.setShadow(offset: .zero, blur: CGFloat(10.0 + (currentAccuracy * 15.0)), color: shadowColor)
        
        let exerciseId = currentExerciseId?.lowercased() ?? ""
        
        switch exerciseId {
        case "neck_side_bend", "neck_lateral_flexion", "neckmovement":
            let nose = pose.landmark(ofType: .nose)
            let leftShoulder = pose.landmark(ofType: .leftShoulder)
            let rightShoulder = pose.landmark(ofType: .rightShoulder)
            let leftEar = pose.landmark(ofType: .leftEar)
            let rightEar = pose.landmark(ofType: .rightEar)
            
            drawSmoothedPoint(context: context, landmark: nose, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: leftEar, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: rightEar, color: dynamicColor)
            drawSmoothedLine(context: context, from: leftShoulder, to: rightShoulder, color: dynamicColor.withAlphaComponent(0.5))
            
        case "squat":
            let leftHip = pose.landmark(ofType: .leftHip)
            let rightHip = pose.landmark(ofType: .rightHip)
            let leftKnee = pose.landmark(ofType: .leftKnee)
            let rightKnee = pose.landmark(ofType: .rightKnee)
            let leftAnkle = pose.landmark(ofType: .leftAnkle)
            let rightAnkle = pose.landmark(ofType: .rightAnkle)
            
            // Bel çizgisi
            drawSmoothedLine(context: context, from: leftHip, to: rightHip, color: dynamicColor.withAlphaComponent(0.5))
            // Sol Bacak
            drawSmoothedLine(context: context, from: leftHip, to: leftKnee, color: dynamicColor)
            drawSmoothedLine(context: context, from: leftKnee, to: leftAnkle, color: dynamicColor)
            // Sağ Bacak
            drawSmoothedLine(context: context, from: rightHip, to: rightKnee, color: dynamicColor)
            drawSmoothedLine(context: context, from: rightKnee, to: rightAnkle, color: dynamicColor)
            
            // Eklemler
            drawSmoothedPoint(context: context, landmark: leftHip, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: rightHip, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: leftKnee, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: rightKnee, color: dynamicColor)
            
        case "shoulder_stretch", "shoulderstretch":
            let leftShoulder = pose.landmark(ofType: .leftShoulder)
            let rightShoulder = pose.landmark(ofType: .rightShoulder)
            let leftElbow = pose.landmark(ofType: .leftElbow)
            let rightElbow = pose.landmark(ofType: .rightElbow)
            let leftWrist = pose.landmark(ofType: .leftWrist)
            let rightWrist = pose.landmark(ofType: .rightWrist)
            let leftHip = pose.landmark(ofType: .leftHip)
            let rightHip = pose.landmark(ofType: .rightHip)
            
            // Kollar
            drawSmoothedLine(context: context, from: leftShoulder, to: leftElbow, color: dynamicColor)
            drawSmoothedLine(context: context, from: leftElbow, to: leftWrist, color: dynamicColor)
            drawSmoothedLine(context: context, from: rightShoulder, to: rightElbow, color: dynamicColor)
            drawSmoothedLine(context: context, from: rightElbow, to: rightWrist, color: dynamicColor)
            
            // Gövde bağlantısı
            drawSmoothedLine(context: context, from: leftShoulder, to: rightShoulder, color: dynamicColor.withAlphaComponent(0.5))
            drawSmoothedLine(context: context, from: leftShoulder, to: leftHip, color: dynamicColor.withAlphaComponent(0.3))
            drawSmoothedLine(context: context, from: rightShoulder, to: rightHip, color: dynamicColor.withAlphaComponent(0.3))
            
            // Eklemler
            drawSmoothedPoint(context: context, landmark: leftWrist, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: rightWrist, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: leftElbow, color: dynamicColor)
            drawSmoothedPoint(context: context, landmark: rightElbow, color: dynamicColor)
            
        default:
            let nose = pose.landmark(ofType: .nose)
            let leftShoulder = pose.landmark(ofType: .leftShoulder)
            let rightShoulder = pose.landmark(ofType: .rightShoulder)
            drawSmoothedPoint(context: context, landmark: nose, color: dynamicColor)
            drawSmoothedLine(context: context, from: leftShoulder, to: rightShoulder, color: dynamicColor.withAlphaComponent(0.5))
        }
    }
    
    // MARK: - Drawing Helpers
    
    /// Minimum güvenilirlik eşiği — bu değerin altındaki landmark'lar çizilmez
    private static let minDrawConfidence: Float = 0.75
    
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
