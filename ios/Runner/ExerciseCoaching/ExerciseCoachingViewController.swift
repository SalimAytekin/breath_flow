import UIKit
import MLKitPoseDetection

/// Egzersiz koçluk ekranı — CameraPreviewViewController'ı genişleterek
/// pose detection üzerine coaching overlay'i ekler.
/// Android'deki ExerciseCoachingActivity.java karşılığı.
class ExerciseCoachingViewController: CameraPreviewViewController {
    
    // MARK: - UI Elements
    
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
        
        stopButton.setTitle("DURDUR", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 0.8)
        stopButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        stopButton.layer.cornerRadius = 10
        stopButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
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
        ])
        
        // ═══════════════════════════════════════════
        // Bottom Feedback Panel (Glassmorphism)
        // ═══════════════════════════════════════════
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.layer.cornerRadius = 24
        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomPanel.clipsToBounds = true
        view.addSubview(bottomPanel)
        
        let bottomBarContentView = bottomPanel.contentView
        
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
            // Arka planda istatistikleri tutmaya devam et, UI'dan kaldırdığımız için sadece data tutuyoruz.
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
        // Form Analiz panelini UI'dan kaldırdık, metrikler hesaplanıyor ama gösterilmiyor. İleride kaydedilebilir.
    }
    
    // Mesaj değişimlerinde şık bir soluklaşma efekti (fade) için
    private func crossDissolveText(label: UILabel, newText: String) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
    
    private func updateFeedbackVisuals(_ message: String) {
        crossDissolveText(label: feedbackMessageLabel, newText: message)
        
        UIView.animate(withDuration: 0.3) {
            if message.contains("Mükemmel") || message.contains("Harika") || message.contains("TEBRİKLER") {
                self.feedbackEmojiLabel.text = "🎉"
                self.feedbackTitleLabel.text = "Mükemmel!"
                self.feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
            } else if message.contains("İyi") || message.contains("Güzel") || message.contains("Devam") {
                self.feedbackEmojiLabel.text = "👍"
                self.feedbackTitleLabel.text = "İyi Gidiyor"
                self.feedbackTitleLabel.textColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1)
            } else if message.contains("⚠️") || message.contains("Dikkat") {
                self.feedbackEmojiLabel.text = "⚠️"
                self.feedbackTitleLabel.text = "Dikkat!"
                self.feedbackTitleLabel.textColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
            } else if message.contains("eğilin") || message.contains("dönün") || message.contains("tutun") {
                self.feedbackEmojiLabel.text = "🏋️"
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
