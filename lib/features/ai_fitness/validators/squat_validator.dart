import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import '../utils/angle_calculator.dart';
import 'i_exercise_validator.dart';

/// Squat egzersizi doğrulayıcısı.
///
/// Kalça → Diz → Ayak bileği arasındaki açıyı ölçerek
/// çömelme hareketini analiz eder.
///
/// State Machine Fazları:
/// - waiting: Bacaklar düz (açı > 160°)
/// - eccentric: Çömelmeye başladı (açı düşüyor)
/// - concentric: Dip noktaya ulaştı (açı < 90°) — kalkıyor
/// - completed: Bacaklar tekrar düz (açı > 160°) — 1 rep sayıldı
class SquatValidator implements IExerciseValidator {
  @override
  final ExerciseConfig config;

  double _minAngleInRep = 180;
  double _maxAngleInRep = 0;

  SquatValidator({ExerciseConfig? config})
      : config = config ?? ExerciseConfig.squat();

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
    final hip = landmarks[config.primaryLandmarks[0]];
    final knee = landmarks[config.primaryLandmarks[1]];
    final ankle = landmarks[config.primaryLandmarks[2]];

    // Kalça-Diz-Ayak bileği açısı
    final angle = AngleCalculator.calculateAngle(hip, knee, ankle);

    // Min/Max takibi
    if (angle < _minAngleInRep) _minAngleInRep = angle;
    if (angle > _maxAngleInRep) _maxAngleInRep = angle;

    // Form kontrolü: Diz, ayak ucunun önüne geçmemeli
    String? formError;
    bool isFormCorrect = true;

    // Diz X pozisyonu, ayak bileği X pozisyonundan çok ileriyse
    final kneeForwardDist = knee.x - ankle.x;
    // Sağ taraftan bakıyorsak pozitif, sol taraftan negatif olabilir
    // Mutlak değer olarak kontrol: omuz-kalça mesafesinin %40'ından fazlaysa hata
    final torsoHeight = AngleCalculator.distance(
      landmarks[PoseLandmarkIndex.rightShoulder],
      landmarks[PoseLandmarkIndex.rightHip],
    );

    if (kneeForwardDist.abs() > torsoHeight * 0.5 && angle < 120) {
      formError = 'Dizlerin çok ileri gidiyor!';
      isFormCorrect = false;
    }

    // Symmetry check: Sol ve sağ diz açısı çok farklıysa
    if (config.secondaryLandmarks != null &&
        config.secondaryLandmarks!.length >= 3) {
      final leftHip = landmarks[config.secondaryLandmarks![0]];
      final leftKnee = landmarks[config.secondaryLandmarks![1]];
      final leftAnkle = landmarks[config.secondaryLandmarks![2]];

      if (leftKnee.isVisible && leftHip.isVisible && leftAnkle.isVisible) {
        final leftAngle =
            AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
        final asymmetry = (angle - leftAngle).abs();

        if (asymmetry > 25 && formError == null) {
          formError = 'Dengeni koru, eşit çömel!';
          isFormCorrect = false;
        }
      }
    }

    // State Machine geçişleri
    ExercisePhase newPhase = currentPhase;

    switch (currentPhase) {
      case ExercisePhase.waiting:
        if (angle < config.eccentricThreshold) {
          newPhase = ExercisePhase.eccentric;
          _minAngleInRep = angle;
          _maxAngleInRep = angle;
        }
        break;

      case ExercisePhase.eccentric:
        if (angle <= config.concentricThreshold) {
          newPhase = ExercisePhase.concentric;
        }
        if (angle > config.eccentricThreshold + 10) {
          newPhase = ExercisePhase.waiting;
        }
        break;

      case ExercisePhase.concentric:
        if (angle >= config.completionThreshold) {
          final rom = _maxAngleInRep - _minAngleInRep;
          if (rom >= config.minRangeOfMotion) {
            newPhase = ExercisePhase.completed;
          } else {
            newPhase = ExercisePhase.waiting;
          }
        }
        break;

      case ExercisePhase.completed:
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
    if (rom >= config.minRangeOfMotion * 1.3) return RepQuality.perfect;
    return RepQuality.acceptable;
  }

  @override
  void reset() {
    _minAngleInRep = 180;
    _maxAngleInRep = 0;
  }
}
