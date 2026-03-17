import UIKit
import MLKitPoseDetection

/// Egzersiz koçluk ekranı — CameraPreviewViewController'ı genişleterek
/// pose detection üzerine coaching overlay'i ekler.
/// Android'deki ExerciseCoachingActivity.java karşılığı.
class ExerciseCoachingViewController: CameraPreviewViewController {
    
    // MARK: - UI Elem    // MARK: - UI Elements
    
    // Top bar
    private let topBar = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let exerciseNameLabel = UILabel()
    private let timerLabel = UILabel()
    private let repCountLabel = UILabel()
    private let stopButton = UIButton(type: .system)
    
    // Bottom feedback panel
    private let bottomPanel = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let feedbackEmojiLabel = UILabel()
    private let feedbackTitleLabel = UILabel()
    private let feedbackMessageLabel = UILabel()
    
    // Progress Arc (Açı Barı)
    private let progressLayer = CAShapeLayer()
    private let progressTrackLayer = CAShapeLayer()
    

    
    // MARK: - Coaching
    private var exerciseCoachProcessor: ExerciseCoachProcessor?
    private var exerciseData: [String: Any]?
    private var timer: Timer?
    private var elapsedSeconds: Int = 0
    private var bestAccuracy: Double = 0
    private var totalAccuracy: Double = 0
    private var accuracyCount: Int = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachingOverlay()
        setupProgressArc()
        initializeExerciseCoaching()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    // MARK: - Configuration
    
    func configure(exerciseData: [String: Any], coachProcessor: ExerciseCoachProcessor) {
        self.exerciseData = exerciseData
        self.exerciseCoachProcessor = coachProcessor
    }
    
    // MARK: - Coaching Setup
    
    private func setupProgressArc() {
        let arcCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let radius: CGFloat = 120
        let startAngle = CGFloat.pi * 3 / 4
        let endAngle = CGFloat.pi * 1 / 4
        
        let circularPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Arka plan çizgisi (Track)
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        progressTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
        progressTrackLayer.lineWidth = 15
        progressTrackLayer.lineCap = .round
        view.layer.addSublayer(progressTrackLayer)
        
        // İlerleme çizgisi (Progress)
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor // Nötr renk (değişecek)
        progressLayer.lineWidth = 15
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        
        // Neon / Glow effect
        progressLayer.shadowColor = UIColor.green.cgColor
        progressLayer.shadowOffset = .zero
        progressLayer.shadowOpacity = 0.0
        progressLayer.shadowRadius = 15.0
        
        view.layer.addSublayer(progressLayer)
    }
    
    private func setupCoachingOverlay() {
        let safeArea = view.safeAreaLayoutGuide
        
        // ═══════════════════════════════════════════
        // Top Status Bar (Glassmorphism)
        // ═══════════════════════════════════════════
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        let topBarContentView = topBar.contentView
        
        exerciseNameLabel.text = "Egzersiz"
        exerciseNameLabel.textColor = .white
        exerciseNameLabel.font = .boldSystemFont(ofSize: 20)
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarContentView.addSubview(exerciseNameLabel)
        
        timerLabel.text = "00:00"
        timerLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        timerLabel.font = .boldSystemFont(ofSize: 16)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarContentView.addSubview(timerLabel)
        
        let repStack = UIStackView()
        repStack.axis = .vertical
        repStack.alignment = .center
        repStack.translatesAutoresizingMaskIntoConstraints = false
        
        let repTitle = UILabel()
        repTitle.text = "TEKRAR"
        repTitle.textColor = UIColor(red: 1, green: 0.76, blue: 0.03, alpha: 1)
        repTitle.font = .boldSystemFont(ofSize: 12)
        repStack.addArrangedSubview(repTitle)
        
        repCountLabel.text = "0"
        repCountLabel.textColor = .white
        repCountLabel.font = .boldSystemFont(ofSize: 28)
        repStack.addArrangedSubview(repCountLabel)
        topBarContentView.addSubview(repStack)
        
        // Pause Button (SFSymbol)
        let pauseConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let pauseIcon = UIImage(systemName: "pause.circle.fill", withConfiguration: pauseConfig)
        stopButton.setImage(pauseIcon, for: .normal)
        stopButton.tintColor = UIColor(white: 0.9, alpha: 1)
        
        stopButton.addTarget(self, action: #selector(stopCoachingTapped), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        topBarContentView.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 110),
            
            exerciseNameLabel.leadingAnchor.constraint(equalTo: topBarContentView.leadingAnchor, constant: 20),
            exerciseNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            timerLabel.leadingAnchor.constraint(equalTo: topBarContentView.leadingAnchor, constant: 20),
            timerLabel.topAnchor.constraint(equalTo: exerciseNameLabel.bottomAnchor, constant: 6),
            
            repStack.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -20),
            repStack.centerYAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25),
            
            stopButton.trailingAnchor.constraint(equalTo: topBarContentView.trailingAnchor, constant: -20),
            stopButton.centerYAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25),
            stopButton.widthAnchor.constraint(equalToConstant: 44),
            stopButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        // ═══════════════════════════════════════════
        // Bottom Feedback Panel (Glassmorphism)
        // ═══════════════════════════════════════════
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.layer.cornerRadius = 32
        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomPanel.clipsToBounds = true
        view.addSubview(bottomPanel)
        
        let bottomBarContentView = bottomPanel.contentView
        
        feedbackEmojiLabel.text = "🔄"
        feedbackEmojiLabel.font = .systemFont(ofSize: 40)
        feedbackEmojiLabel.textAlignment = .center
        feedbackEmojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        feedbackEmojiLabel.layer.cornerRadius = 16
        feedbackEmojiLabel.clipsToBounds = true
        feedbackEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        feedbackTitleLabel.text = "Başlayın"
        feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        feedbackTitleLabel.font = .boldSystemFont(ofSize: 22)
        
        feedbackMessageLabel.text = "Koçluk başlatılıyor..."
        feedbackMessageLabel.textColor = .white
        feedbackMessageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        feedbackMessageLabel.numberOfLines = 4
        
        let feedbackTextStack = UIStackView(arrangedSubviews: [feedbackTitleLabel, feedbackMessageLabel])
        feedbackTextStack.axis = .vertical
        feedbackTextStack.spacing = 6
        feedbackTextStack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBarContentView.addSubview(feedbackEmojiLabel)
        bottomBarContentView.addSubview(feedbackTextStack)
        
        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 220), // Taller Panel
            
            feedbackEmojiLabel.leadingAnchor.constraint(equalTo: bottomBarContentView.leadingAnchor, constant: 20),
            feedbackEmojiLabel.topAnchor.constraint(equalTo: bottomBarContentView.topAnchor, constant: 32),
            feedbackEmojiLabel.widthAnchor.constraint(equalToConstant: 72),
            feedbackEmojiLabel.heightAnchor.constraint(equalToConstant: 72),
            
            feedbackTextStack.leadingAnchor.constraint(equalTo: feedbackEmojiLabel.trailingAnchor, constant: 20),
            feedbackTextStack.trailingAnchor.constraint(equalTo: bottomBarContentView.trailingAnchor, constant: -20),
            feedbackTextStack.topAnchor.constraint(equalTo: bottomBarContentView.topAnchor, constant: 32),
        ])
        
        // Overlay'ları pose overlay'ın üstüne getir
        view.bringSubviewToFront(topBar)
        view.bringSubviewToFront(bottomPanel)
    }
    
    // MARK: - Exercise Initialization
    
    private func initializeExerciseCoaching() {
        guard let data = exerciseData, let processor = exerciseCoachProcessor else { return }
        
        // UI güncelle
        exerciseNameLabel.text = data["name"] as? String ?? "Egzersiz"
        
        // Adapter'ı bağla
        PoseDetectorToExerciseAdapter.shared.setExerciseCoachProcessor(processor)
        PoseDetectorToExerciseAdapter.shared.setEnabled(true)
        
        // Egzersizi başlat
        processor.startExercise(data)
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            let minutes = self.elapsedSeconds / 60
            let seconds = self.elapsedSeconds % 60
            self.timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - UI Updates (Called from EventChannel events)
    
    func updateFeedback(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.feedbackMessageLabel.text = message
            self?.updateFeedbackVisuals(message)
        }
    }
    
    func updateAccuracy(_ accuracy: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if accuracy > self.bestAccuracy { self.bestAccuracy = accuracy }
            self.totalAccuracy += accuracy
            self.accuracyCount += 1
            
            // Progress Arc Animasyonu
            self.progressLayer.strokeEnd = CGFloat(accuracy)
            
            // Dinamik Renk ve Parlama
            let greenVal = CGFloat(max(0.0, min(1.0, accuracy)))
            let redVal = CGFloat(1.0 - greenVal)
            let blueVal = CGFloat(1.0 - greenVal)
            let dynamicColor = UIColor(red: redVal, green: 1.0, blue: blueVal, alpha: 1.0)
            
            self.progressLayer.strokeColor = dynamicColor.cgColor
            if accuracy >= 0.95 {
                self.progressLayer.shadowOpacity = 1.0 // Hedefteyken parlar
            } else {
                self.progressLayer.shadowOpacity = 0.0
            }
        }
    }
    
    func updateRepetitionCount(_ count: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Pop-up Scale Animasyonu
            if self.repCountLabel.text != "\(count)" {
                self.repCountLabel.text = "\(count)"
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.repCountLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    self.repCountLabel.textColor = .green
                }) { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.repCountLabel.transform = CGAffineTransform.identity
                        self.repCountLabel.textColor = .white
                    })
                }
            }
        }
    }
    
    func updateStabilityMetrics(_ metrics: [String: Any]) {
        // ...
    }
    
    // Mesaj değişimlerinde şık bir soluklaşma efekti (fade) için
    private func crossDissolveText(label: UILabel, newText: String) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
    
    private func updateFeedbackVisuals(_ message: String) {
        crossDissolveText(label: feedbackMessageLabel, newText: message)
        
        UIView.animate(withDuration: 0.4) {
            if message.contains("Mükemmel") || message.contains("Harika") || message.contains("TEBRİKLER") {
                self.feedbackEmojiLabel.text = "🎉"
                self.feedbackTitleLabel.text = "Mükemmel!"
                self.feedbackTitleLabel.textColor = UIColor.white
                self.bottomPanel.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.85) // Koyu Yeşil
            } else if message.contains("İyi") || message.contains("Güzel") || message.contains("Devam") {
                self.feedbackEmojiLabel.text = "👍"
                self.feedbackTitleLabel.text = "İyi Gidiyor"
                self.feedbackTitleLabel.textColor = UIColor.white
                self.bottomPanel.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 0.85) // Koyu Mavi
            } else if message.contains("⚠️") || message.contains("Dikkat") {
                self.feedbackEmojiLabel.text = "⚠️"
                self.feedbackTitleLabel.text = "Dikkat!"
                self.feedbackTitleLabel.textColor = UIColor.white
                self.bottomPanel.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 0.85) // Turuncu Hata
            } else if message.contains("eğilin") || message.contains("dönün") || message.contains("tutun") {
                self.feedbackEmojiLabel.text = "🏋️"
                self.feedbackTitleLabel.text = "Koç Diyor"
                self.feedbackTitleLabel.textColor = UIColor(red: 0.4, green: 0.8, blue: 0.95, alpha: 1)
                self.bottomPanel.backgroundColor = UIColor.clear // Nötr
            } else {
                self.feedbackEmojiLabel.text = "🔄"
                self.feedbackTitleLabel.text = "Devam"
                self.feedbackTitleLabel.textColor = .white
                self.bottomPanel.backgroundColor = UIColor.clear // Nötr
            }
        }
    }kEmojiLabel.text = "🏋️"
                self.feedbackTitleLabel.text = "Koç Diyor"
                self.feedbackTitleLabel.textColor = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1)
            } else {
                self.feedbackEmojiLabel.text = "🔄"
                self.feedbackTitleLabel.text = "Devam"
                self.feedbackTitleLabel.textColor = .white
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func stopCoachingTapped() {
        exerciseCoachProcessor?.stopExercise()
        PoseDetectorToExerciseAdapter.shared.setEnabled(false)
        stopCamera()
        stopTimer()
        dismiss(animated: true)
    }
    
    deinit {
        stopTimer()
        PoseDetectorToExerciseAdapter.shared.setEnabled(false)
    }
}
