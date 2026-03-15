import UIKit
import MLKitPoseDetection

/// Egzersiz koçluk ekranı — CameraPreviewViewController'ı genişleterek
/// pose detection üzerine coaching overlay'i ekler.
/// Android'deki ExerciseCoachingActivity.java karşılığı.
class ExerciseCoachingViewController: CameraPreviewViewController {
    
    // MARK: - UI Elements
    
    // Top bar
    private let topBar = UIView()
    private let exerciseNameLabel = UILabel()
    private let timerLabel = UILabel()
    private let repCountLabel = UILabel()
    private let stopButton = UIButton(type: .system)
    
    // Right panel
    private let rightPanel = UIView()
    private let accuracyLabel = UILabel()
    private let accuracyProgressView = UIProgressView(progressViewStyle: .default)
    private let poseQualityLabel = UILabel()
    private let fluidityLabel = UILabel()
    private let stabilityLabel = UILabel()
    
    // Bottom feedback panel
    private let bottomPanel = UIView()
    private let feedbackEmojiLabel = UILabel()
    private let feedbackTitleLabel = UILabel()
    private let feedbackMessageLabel = UILabel()
    
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
    
    private func setupCoachingOverlay() {
        let safeArea = view.safeAreaLayoutGuide
        
        // ═══════════════════════════════════════════
        // Top Status Bar
        // ═══════════════════════════════════════════
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.56)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        exerciseNameLabel.text = "Egzersiz"
        exerciseNameLabel.textColor = .white
        exerciseNameLabel.font = .boldSystemFont(ofSize: 18)
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(exerciseNameLabel)
        
        timerLabel.text = "00:00"
        timerLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        timerLabel.font = .boldSystemFont(ofSize: 14)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(timerLabel)
        
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
        repCountLabel.font = .boldSystemFont(ofSize: 24)
        repStack.addArrangedSubview(repCountLabel)
        topBar.addSubview(repStack)
        
        stopButton.setTitle("DURDUR", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1)
        stopButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        stopButton.layer.cornerRadius = 8
        stopButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        stopButton.addTarget(self, action: #selector(stopCoachingTapped), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 100),
            
            exerciseNameLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            exerciseNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            timerLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            timerLabel.topAnchor.constraint(equalTo: exerciseNameLabel.bottomAnchor, constant: 4),
            
            repStack.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -16),
            repStack.centerYAnchor.constraint(equalTo: topBar.centerYAnchor, constant: 10),
            
            stopButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            stopButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor, constant: 10),
        ])
        
        // ═══════════════════════════════════════════
        // Bottom Feedback Panel (rightPanel'den ÖNCE eklenmeli,
        // çünkü rightPanel.bottomAnchor → bottomPanel.topAnchor referansı var)
        // ═══════════════════════════════════════════
        bottomPanel.backgroundColor = UIColor.black.withAlphaComponent(0.56)
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomPanel)
        
        feedbackEmojiLabel.text = "🔄"
        feedbackEmojiLabel.font = .systemFont(ofSize: 32)
        feedbackEmojiLabel.textAlignment = .center
        feedbackEmojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.27)
        feedbackEmojiLabel.layer.cornerRadius = 8
        feedbackEmojiLabel.clipsToBounds = true
        feedbackEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        feedbackTitleLabel.text = "Başlayın"
        feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        feedbackTitleLabel.font = .boldSystemFont(ofSize: 18)
        
        feedbackMessageLabel.text = "Koçluk başlatılıyor..."
        feedbackMessageLabel.textColor = .white
        feedbackMessageLabel.font = .systemFont(ofSize: 15)
        feedbackMessageLabel.numberOfLines = 4
        
        let feedbackTextStack = UIStackView(arrangedSubviews: [feedbackTitleLabel, feedbackMessageLabel])
        feedbackTextStack.axis = .vertical
        feedbackTextStack.spacing = 4
        feedbackTextStack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomPanel.addSubview(feedbackEmojiLabel)
        bottomPanel.addSubview(feedbackTextStack)
        
        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 150),
            
            feedbackEmojiLabel.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 16),
            feedbackEmojiLabel.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
            feedbackEmojiLabel.widthAnchor.constraint(equalToConstant: 60),
            feedbackEmojiLabel.heightAnchor.constraint(equalToConstant: 60),
            
            feedbackTextStack.leadingAnchor.constraint(equalTo: feedbackEmojiLabel.trailingAnchor, constant: 16),
            feedbackTextStack.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
            feedbackTextStack.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
        ])
        
        // ═══════════════════════════════════════════
        // Right Panel
        // ═══════════════════════════════════════════
        rightPanel.backgroundColor = UIColor.black.withAlphaComponent(0.52)
        rightPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightPanel)
        
        let formTitle = UILabel()
        formTitle.text = "📊 FORM ANALİZİ"
        formTitle.textColor = .white
        formTitle.font = .boldSystemFont(ofSize: 16)
        formTitle.textAlignment = .center
        
        let accTitle = UILabel()
        accTitle.text = "Genel Doğruluk"
        accTitle.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        accTitle.font = .boldSystemFont(ofSize: 14)
        
        accuracyProgressView.progressTintColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        accuracyProgressView.progress = 0
        
        accuracyLabel.text = "0%"
        accuracyLabel.textColor = .white
        accuracyLabel.font = .boldSystemFont(ofSize: 18)
        accuracyLabel.textAlignment = .center
        
        // Detay satırları
        func makeDetailRow(title: String, valueLabel: UILabel, color: UIColor) -> UIStackView {
            let titleL = UILabel()
            titleL.text = title
            titleL.textColor = .white
            titleL.font = .systemFont(ofSize: 12)
            
            valueLabel.textColor = color
            valueLabel.font = .boldSystemFont(ofSize: 12)
            
            let stack = UIStackView(arrangedSubviews: [titleL, valueLabel])
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            return stack
        }
        
        poseQualityLabel.text = "İyi"
        fluidityLabel.text = "Normal"
        stabilityLabel.text = "Stabil"
        
        let pqRow = makeDetailRow(title: "Poz Kalitesi:", valueLabel: poseQualityLabel, color: UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1))
        let flRow = makeDetailRow(title: "Akıcılık:", valueLabel: fluidityLabel, color: UIColor(red: 1, green: 0.6, blue: 0, alpha: 1))
        let stRow = makeDetailRow(title: "Stabilite:", valueLabel: stabilityLabel, color: UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1))
        
        let rightStack = UIStackView(arrangedSubviews: [formTitle, accTitle, accuracyProgressView, accuracyLabel, pqRow, flRow, stRow])
        rightStack.axis = .vertical
        rightStack.spacing = 10
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightPanel.addSubview(rightStack)
        
        NSLayoutConstraint.activate([
            rightPanel.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            rightPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightPanel.widthAnchor.constraint(equalToConstant: 200),
            rightPanel.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),
            
            rightStack.topAnchor.constraint(equalTo: rightPanel.topAnchor, constant: 16),
            rightStack.leadingAnchor.constraint(equalTo: rightPanel.leadingAnchor, constant: 12),
            rightStack.trailingAnchor.constraint(equalTo: rightPanel.trailingAnchor, constant: -12),
        ])
        
        // ═══════════════════════════════════════════
        // Debug Panel (Sol Orta)
        // ═══════════════════════════════════════════
        let debugPanel = UIView()
        debugPanel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        debugPanel.layer.cornerRadius = 8
        debugPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugPanel)
        
        let debugTitle = UILabel()
        debugTitle.text = "🔧 DEBUG"
        debugTitle.textColor = .yellow
        debugTitle.font = .boldSystemFont(ofSize: 12)
        
        let dStateL = UILabel(); dStateL.textColor = .white; dStateL.font = .systemFont(ofSize: 10)
        let dTiltL = UILabel(); dTiltL.textColor = .white; dTiltL.font = .systemFont(ofSize: 10)
        let dRawL = UILabel(); dRawL.textColor = .white; dRawL.font = .systemFont(ofSize: 10)
        let dConfL = UILabel(); dConfL.textColor = .white; dConfL.font = .systemFont(ofSize: 10)
        let dLmL = UILabel(); dLmL.textColor = .white; dLmL.font = .systemFont(ofSize: 10)
        
        let debugStack = UIStackView(arrangedSubviews: [debugTitle, dStateL, dTiltL, dRawL, dConfL, dLmL])
        debugStack.axis = .vertical
        debugStack.spacing = 4
        debugStack.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(debugStack)
        
        NSLayoutConstraint.activate([
            debugPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            debugPanel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            debugPanel.widthAnchor.constraint(equalToConstant: 160),
            
            debugStack.topAnchor.constraint(equalTo: debugPanel.topAnchor, constant: 8),
            debugStack.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 8),
            debugStack.trailingAnchor.constraint(equalTo: debugPanel.trailingAnchor, constant: -8),
            debugStack.bottomAnchor.constraint(equalTo: debugPanel.bottomAnchor, constant: -8)
        ])
        
        // Debug callback bağlama
        exerciseCoachProcessor?.onDebugInfoUpdated = { [weak self] info in
            DispatchQueue.main.async {
                dStateL.text = "State: \(info["state"] as? String ?? "-")"
                dTiltL.text = "Tilt (EMA): \(info["tiltAngle"] as? String ?? "-")"
                dRawL.text = "Raw Angle: \(info["rawAngle"] as? String ?? "-")"
                dConfL.text = "Confidence: \(info["confidence"] as? String ?? "-")"
                dLmL.text = "Visible LMs: \(info["landmarks"] as? String ?? "-")"
            }
        }
        
        // Overlay'ları pose overlay'ın üstüne getir
        view.bringSubviewToFront(topBar)
        view.bringSubviewToFront(bottomPanel)
        view.bringSubviewToFront(rightPanel)
        view.bringSubviewToFront(debugPanel)
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
            let percentage = Int(accuracy * 100)
            self.accuracyLabel.text = "\(percentage)%"
            self.accuracyProgressView.setProgress(Float(accuracy), animated: true)
            
            // Renk güncelle
            if accuracy > 0.7 {
                self.accuracyProgressView.progressTintColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
            } else if accuracy > 0.4 {
                self.accuracyProgressView.progressTintColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
            } else {
                self.accuracyProgressView.progressTintColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1)
            }
            
            // İstatistikler
            if accuracy > self.bestAccuracy { self.bestAccuracy = accuracy }
            self.totalAccuracy += accuracy
            self.accuracyCount += 1
        }
    }
    
    func updateRepetitionCount(_ count: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.repCountLabel.text = "\(count)"
        }
    }
    
    func updateStabilityMetrics(_ metrics: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.poseQualityLabel.text = metrics["poseQuality"] as? String ?? "—"
            self.fluidityLabel.text = metrics["fluidity"] as? String ?? "—"
            self.stabilityLabel.text = metrics["stability"] as? String ?? "—"
        }
    }
    
    private func updateFeedbackVisuals(_ message: String) {
        if message.contains("Mükemmel") || message.contains("Harika") || message.contains("TEBRİKLER") {
            feedbackEmojiLabel.text = "🎉"
            feedbackTitleLabel.text = "Mükemmel!"
            feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        } else if message.contains("İyi") || message.contains("Güzel") || message.contains("Devam") {
            feedbackEmojiLabel.text = "👍"
            feedbackTitleLabel.text = "İyi Gidiyor"
            feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
        } else if message.contains("⚠️") || message.contains("Dikkat") {
            feedbackEmojiLabel.text = "⚠️"
            feedbackTitleLabel.text = "Dikkat!"
            feedbackTitleLabel.textColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        } else if message.contains("eğilin") || message.contains("dönün") || message.contains("tutun") {
            feedbackEmojiLabel.text = "🏋️"
            feedbackTitleLabel.text = "Koç Diyor"
            feedbackTitleLabel.textColor = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1)
        } else {
            feedbackEmojiLabel.text = "🔄"
            feedbackTitleLabel.text = "Devam"
            feedbackTitleLabel.textColor = .white
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
