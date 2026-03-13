import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import '../utils/angle_calculator.dart';
import 'i_exercise_validator.dart';

/// Biceps Curl egzersizi doğrulayıcısı.
///
/// Omuz → Dirsek → Bilek arasındaki açıyı ölçerek
/// kol bükme hareketini analiz eder.
///
/// State Machine Fazları:
/// - waiting: Kol düz (açı > 140°) — bekleme
/// - eccentric: Kol bükülmeye başladı (açı düşüyor)
/// - concentric: Kol tepe noktasına ulaştı (açı < 50°) — kalkıyor
/// - completed: Kol tekrar düz konuma döndü (açı > 140°) — 1 rep sayıldı
class BicepsCurlValidator implements IExerciseValidator {
  @override
  final ExerciseConfig config;

  /// Tekrar sırasında kaydedilen minimum açı
  double _minAngleInRep = 180;

  /// Tekrar sırasında kaydedilen maksimum açı
  double _maxAngleInRep = 0;

  BicepsCurlValidator({ExerciseConfig? config})
      : config = config ?? ExerciseConfig.bicepsCurlRight();

  @override
  bool canValidate(List<LandmarkPoint> landmarks) {
    return AngleCalculator.areLandmarksReliable(
      landmarks,
      config.primaryLandmarks,
    );
  }

  @override
  ValidationResult validate(
    List<LandmarkPoint> landmarks,
    ExercisePhase currentPhase,
  ) {
    final shoulder = landmarks[config.primaryLandmarks[0]];
    final elbow = landmarks[config.primaryLandmarks[1]];
    final wrist = landmarks[config.primaryLandmarks[2]];

    // Omuz-Dirsek-Bilek açısı
    final angle = AngleCalculator.calculateAngle(shoulder, elbow, wrist);

    // Min/Max takibi
    if (angle < _minAngleInRep) _minAngleInRep = angle;
    if (angle > _maxAngleInRep) _maxAngleInRep = angle;

    // Form kontrolü: Dirsek sabitliği
    String? formError;
    bool isFormCorrect = true;

    if (config.secondaryLandmarks != null &&
        config.secondaryLandmarks!.isNotEmpty) {
      final hip = landmarks[config.secondaryLandmarks![0]];
      final elbowDeviation =
          AngleCalculator.horizontalDeviation(elbow, shoulder, hip);

      // Omuz genişliğinin %30'undan fazla sapma = form hatası
      final shoulderWidth = AngleCalculator.distance(
        landmarks[PoseLandmarkIndex.leftShoulder],
        landmarks[PoseLandmarkIndex.rightShoulder],
      );

      if (elbowDeviation > shoulderWidth * 0.3) {
        formError = 'Dirseğini sabit tut!';
        isFormCorrect = false;
      }
    }

    // State Machine geçişleri
    ExercisePhase newPhase = currentPhase;

    switch (currentPhase) {
      case ExercisePhase.waiting:
        // Kol düz → bükülmeye başladığında eccentric faza geç
        if (angle < config.eccentricThreshold) {
          newPhase = ExercisePhase.eccentric;
          _minAngleInRep = angle;
          _maxAngleInRep = angle;
        }
        break;

      case ExercisePhase.eccentric:
        // Kol yeterince büküldüğünde concentric faza geç
        if (angle <= config.concentricThreshold) {
          newPhase = ExercisePhase.concentric;
        }
        // Yarıda bıraktı — kol tekrar açılıyorsa waiting'e dön
        if (angle > config.eccentricThreshold + 10) {
          newPhase = ExercisePhase.waiting;
        }
        break;

      case ExercisePhase.concentric:
        // Kol tekrar düz konuma döndüğünde rep tamamlandı
        if (angle >= config.completionThreshold) {
          // ROM kontrolü — çok kısa hareket saydırılmaz
          final rom = _maxAngleInRep - _minAngleInRep;
          if (rom >= config.minRangeOfMotion) {
            newPhase = ExercisePhase.completed;
          } else {
            // ROM yetersiz, sayma
            newPhase = ExercisePhase.waiting;
          }
        }
        break;

      case ExercisePhase.completed:
        // Completed durumu ExerciseController tarafından handle edilir
        // ve hemen waiting'e döner
        newPhase = ExercisePhase.waiting;
        break;
    }

    return ValidationResult(
      phase: newPhase,
      currentAngle: angle,
      isFormCorrect: isFormCorrect,
      formError: formError,
      quality: _determineQuality(isFormCorrect),
    );
  }

  RepQuality _determineQuality(bool isFormCorrect) {
    if (!isFormCorrect) return RepQuality.bad;
    final rom = _maxAngleInRep - _minAngleInRep;
    if (rom >= config.minRangeOfMotion * 1.2) return RepQuality.perfect;
    return RepQuality.acceptable;
  }

  @override
  void reset() {
    _minAngleInRep = 180;
    _maxAngleInRep = 0;
  }
}
