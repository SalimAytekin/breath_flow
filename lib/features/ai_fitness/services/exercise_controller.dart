import 'package:flutter/foundation.dart';
import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import '../models/rep_result.dart';
import '../validators/i_exercise_validator.dart';
import '../validators/biceps_curl_validator.dart';
import '../validators/squat_validator.dart';
import '../validators/neck_movement_validator.dart';
import 'landmark_smoother.dart';
import 'feedback_engine.dart';

/// Egzersiz kontrolcüsü — State Machine + Rep Sayacı + Motivasyon.
///
/// Bu sınıf merkezi orkestratördür:
/// - Kameradan gelen landmark'ları alır
/// - LandmarkSmoother ile filtreler
/// - Doğru Validator'a yönlendirir
/// - Tekrar sayar + kalite belirler
/// - FeedbackEngine'e geri bildirim tetikler (haptic + TTS)
/// - Streak & milestone takibi yapar
class ExerciseController extends ChangeNotifier {
  /// Mevcut egzersiz konfigürasyonu
  ExerciseConfig _config;

  /// Aktif validator (Strategy Pattern)
  late IExerciseValidator _validator;

  /// Temporal smoothing
  final LandmarkSmoother _smoother = LandmarkSmoother(windowSize: 5);

  /// Geri bildirim motoru (haptic + TTS)
  final FeedbackEngine _feedbackEngine = FeedbackEngine();
  FeedbackEngine get feedbackEngine => _feedbackEngine;

  /// Mevcut faz
  ExercisePhase _currentPhase = ExercisePhase.waiting;
  ExercisePhase get currentPhase => _currentPhase;

  /// Mevcut açı (UI gösterimi için)
  double _currentAngle = 0;
  double get currentAngle => _currentAngle;

  /// Tamamlanan rep sayısı
  int _repCount = 0;
  int get repCount => _repCount;

  /// Hedef rep sayısı
  int get targetReps => _config.targetReps;

  /// Form doğru mu?
  bool _isFormCorrect = true;
  bool get isFormCorrect => _isFormCorrect;

  /// Form hatası mesajı
  String? _formError;
  String? get formError => _formError;

  /// Oturum aktif mi?
  bool _isActive = false;
  bool get isActive => _isActive;

  /// Son yumuşatılmış landmark verileri (UI'da çizim için)
  List<LandmarkPoint> _smoothedLandmarks = [];
  List<LandmarkPoint> get smoothedLandmarks => _smoothedLandmarks;

  /// Rep geçmişi
  final List<RepResult> _repHistory = [];
  List<RepResult> get repHistory => List.unmodifiable(_repHistory);

  /// Tekrar başlama zamanı
  DateTime? _repStartTime;

  /// Oturum başlama zamanı
  DateTime? _sessionStartTime;

  // ─────────────────────────────────────────
  // 🔥 Streak & Motivasyon
  // ─────────────────────────────────────────

  /// Rep sırasında kaydedilen min/max açılar
  double _repMinAngle = 360;
  double _repMaxAngle = 0;

  /// Art arda mükemmel rep sayısı
  int _consecutivePerfect = 0;
  int get consecutivePerfect => _consecutivePerfect;

  /// En uzun streak
  int _bestStreak = 0;
  int get bestStreak => _bestStreak;

  /// Son rep kalitesi
  RepQuality? _lastRepQuality;
  RepQuality? get lastRepQuality => _lastRepQuality;

  ExerciseController({ExerciseConfig? config})
      : _config = config ?? ExerciseConfig.bicepsCurlRight() {
    _validator = _createValidator(_config.type);
  }

  /// Factory: Egzersiz tipine uygun validator oluştur
  IExerciseValidator _createValidator(ExerciseType type) {
    switch (type) {
      case ExerciseType.bicepsCurl:
        return BicepsCurlValidator(config: _config);
      case ExerciseType.squat:
        return SquatValidator(config: _config);
      case ExerciseType.neckMovement:
        return NeckMovementValidator(config: _config);
      default:
        return BicepsCurlValidator(config: _config);
    }
  }

  /// Egzersiz türünü değiştir
  void setExercise(ExerciseConfig config) {
    _config = config;
    _validator = _createValidator(config.type);
    reset();
  }

  /// Oturumu başlat
  Future<void> start() async {
    await _feedbackEngine.initialize();
    _isActive = true;
    _sessionStartTime = DateTime.now();

    // TTS ile egzersiz başlangıcı
    await _feedbackEngine.onExerciseStart(_config.displayName);

    notifyListeners();
  }

  /// Oturumu durdur
  void stop() {
    _isActive = false;
    notifyListeners();
  }

  /// Ana işlem: Kameradan gelen landmark'ları işle
  ///
  /// Bu metot her frame'de (~15 FPS) çağrılır.
  void processLandmarks(List<LandmarkPoint> rawLandmarks) {
    if (!_isActive) return;
    if (rawLandmarks.length < PoseLandmarkIndex.totalLandmarks) return;

    // 1️⃣ Temporal Smoothing
    _smoothedLandmarks = _smoother.smoothAll(rawLandmarks);

    // 2️⃣ Gerekli landmarklar görünür mü?
    if (!_validator.canValidate(_smoothedLandmarks)) {
      _formError = 'Vücut tam görünmüyor';
      notifyListeners();
      return;
    }

    // 3️⃣ Validator çalıştır
    final result = _validator.validate(_smoothedLandmarks, _currentPhase);

    // 4️⃣ State güncellemeleri
    _currentAngle = result.currentAngle;
    _isFormCorrect = result.isFormCorrect;
    _formError = result.formError;

    // 5️⃣ Rep min/max açı takibi
    if (_currentPhase != ExercisePhase.waiting) {
      if (result.currentAngle < _repMinAngle) {
        _repMinAngle = result.currentAngle;
      }
      if (result.currentAngle > _repMaxAngle) {
        _repMaxAngle = result.currentAngle;
      }
    }

    // 6️⃣ Faz geçişi
    if (result.phase != _currentPhase) {
      _onPhaseChanged(_currentPhase, result.phase, result);
      _currentPhase = result.phase;
    }

    // 7️⃣ Form hatası geri bildirimi
    if (!result.isFormCorrect && result.formError != null) {
      _feedbackEngine.onBadForm(warningMessage: result.formError);
    }

    notifyListeners();
  }

  /// Faz değiştiğinde çağrılır
  void _onPhaseChanged(
      ExercisePhase oldPhase, ExercisePhase newPhase, ValidationResult result) {
    // Faz geçişi haptic
    _feedbackEngine.onPhaseChanged(newPhase.name);

    // Yeni tekrara başlandı
    if (newPhase == ExercisePhase.eccentric &&
        oldPhase == ExercisePhase.waiting) {
      _repStartTime = DateTime.now();
      _repMinAngle = 360;
      _repMaxAngle = 0;
    }

    // Tekrar tamamlandı!
    if (newPhase == ExercisePhase.completed) {
      _repCount++;

      final now = DateTime.now();
      final durationMs = _repStartTime != null
          ? now.difference(_repStartTime!).inMilliseconds
          : 0;

      // Kalite belirleme — validator'ın quality'sini kullan
      final quality = result.quality;
      _lastRepQuality = quality;

      _repHistory.add(RepResult(
        repNumber: _repCount,
        quality: quality,
        minAngle: _repMinAngle < 360 ? _repMinAngle : 0,
        maxAngle: _repMaxAngle > 0 ? _repMaxAngle : 180,
        durationMs: durationMs,
        timestamp: now,
      ));

      _validator.reset();

      // 🔥 Streak takibi
      if (quality == RepQuality.perfect) {
        _consecutivePerfect++;
        if (_consecutivePerfect > _bestStreak) {
          _bestStreak = _consecutivePerfect;
        }
        // Streak milestone
        if (_consecutivePerfect == 3 ||
            _consecutivePerfect == 5 ||
            _consecutivePerfect >= 10) {
          _feedbackEngine.onStreak(_consecutivePerfect);
        }
      } else {
        _consecutivePerfect = 0;
      }

      // Rep tamamlandı geri bildirimi (haptic + TTS)
      _feedbackEngine.onRepCompleted(
        repCount: _repCount,
        targetReps: _config.targetReps,
      );

      // 🎯 Milestone kontrolü (5., 10. rep'ler)
      if (_repCount % 5 == 0 && _repCount > 0) {
        _feedbackEngine.onMilestone(_repCount);
      }

      // Set tamamlandı mı?
      if (_repCount >= _config.targetReps) {
        final successRate = _repHistory.isEmpty
            ? 0.0
            : (_repHistory.where((r) => r.isSuccessful).length /
                    _repHistory.length) *
                100;
        _feedbackEngine.onSetCompleted(
          totalReps: _repCount,
          successRate: successRate,
        );
      }

      if (kDebugMode) {
        debugPrint(
            '🏋️ Rep #$_repCount: ${quality.name} (${_repMinAngle.toStringAsFixed(0)}°-${_repMaxAngle.toStringAsFixed(0)}°) streak=$_consecutivePerfect');
      }
    }
  }

  /// Oturum sonuç özetini döndür
  SessionResult getSessionResult() {
    final now = DateTime.now();
    return SessionResult(
      exerciseType: _config.type,
      totalReps: _repCount,
      perfectReps:
          _repHistory.where((r) => r.quality == RepQuality.perfect).length,
      acceptableReps:
          _repHistory.where((r) => r.quality == RepQuality.acceptable).length,
      badReps: _repHistory.where((r) => r.quality == RepQuality.bad).length,
      totalDuration: _sessionStartTime != null
          ? now.difference(_sessionStartTime!)
          : Duration.zero,
      repHistory: _repHistory,
      startTime: _sessionStartTime ?? now,
      endTime: now,
    );
  }

  /// Her şeyi sıfırla
  void reset() {
    _currentPhase = ExercisePhase.waiting;
    _currentAngle = 0;
    _repCount = 0;
    _isFormCorrect = true;
    _formError = null;
    _repHistory.clear();
    _smoother.reset();
    _validator.reset();
    _repStartTime = null;
    _sessionStartTime = null;
    _consecutivePerfect = 0;
    _bestStreak = 0;
    _repMinAngle = 360;
    _repMaxAngle = 0;
    _lastRepQuality = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isActive = false;
    _feedbackEngine.dispose();
    super.dispose();
  }
}
