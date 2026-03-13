import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import '../utils/angle_calculator.dart';
import 'i_exercise_validator.dart';

/// Boyun Hareketi Validator — Ön kamerada test için ideal.
///
/// Baş eğme (tilt) hareketini takip eder:
/// - Başı sağa/sola eğ → tekrar sayılır
/// - Burun, kulak ve omuz noktaları kullanılır
/// - Ön kamerada rahatça test edilebilir
class NeckMovementValidator implements IExerciseValidator {
  final ExerciseConfig config;

  /// Mevcut faz
  ExercisePhase _phase = ExercisePhase.waiting;

  /// Baş eğme açısı (burun-omuz ortası-omuz)
  double _tiltAngle = 0;

  /// En büyük eğme açısı (bu rep için)
  double _maxTilt = 0;

  /// Eğme yönü: true = sağa, false = sola
  bool _tiltRight = true;

  /// Eğme sayısı (sağ + sol = 1 rep)
  int _tiltCount = 0;

  NeckMovementValidator({required this.config});

  @override
  ValidationResult validate(List<LandmarkPoint> landmarks, ExercisePhase currentPhase) {
    // Gerekli landmarklar
    final nose = landmarks[PoseLandmarkIndex.nose];
    final leftShoulder = landmarks[PoseLandmarkIndex.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkIndex.rightShoulder];
    final leftEar = landmarks[PoseLandmarkIndex.leftEar];
    final rightEar = landmarks[PoseLandmarkIndex.rightEar];

    // Omuz ortası
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderMidY = (leftShoulder.y + rightShoulder.y) / 2;
    final shoulderMid = LandmarkPoint(
      x: shoulderMidX,
      y: shoulderMidY,
      z: 0,
      visibility: 1.0,
    );

    // Baş eğme açısı: burun → omuz ortası → sağ/sol omuz
    // Dikey eksenden sapma miktarını ölçüyoruz
    _tiltAngle = AngleCalculator.calculateAngle(nose, shoulderMid, rightShoulder);

    // Kulak-omuz mesafesi ile de kontrol
    // Sol kulak sol omuza yaklaşıyorsa sola eğilmiş
    final leftEarToShoulder = AngleCalculator.distance(leftEar, leftShoulder);
    final rightEarToShoulder = AngleCalculator.distance(rightEar, rightShoulder);

    // Göreceli eğme: fark büyükse eğme var
    final tiltDiff = (leftEarToShoulder - rightEarToShoulder).abs();
    final isSignificantTilt = tiltDiff > 0.03; // Normalize koordinatlarda ~3% fark

    // Eğme yönü
    final isTiltingRight = leftEarToShoulder > rightEarToShoulder;
    final isTiltingLeft = rightEarToShoulder > leftEarToShoulder;

    bool isFormCorrect = true;
    String? formError;

    switch (_phase) {
      case ExercisePhase.waiting:
        // Belirgin bir eğme algılanırsa harekete geçiş
        if (isSignificantTilt && tiltDiff > 0.05) {
          _phase = ExercisePhase.eccentric;
          _tiltRight = isTiltingRight;
          _maxTilt = tiltDiff;
        }
        break;

      case ExercisePhase.eccentric:
        // Eğme derinleşiyor
        if (tiltDiff > _maxTilt) {
          _maxTilt = tiltDiff;
        }

        // Eğme azalmaya başladı → dönüş fazı
        if (tiltDiff < _maxTilt * 0.6 && _maxTilt > 0.05) {
          _phase = ExercisePhase.concentric;
        }

        // Minimum hareket genişliği kontrolü
        if (_maxTilt < 0.04) {
          formError = 'Biraz daha eğ!';
          isFormCorrect = false;
        }
        break;

      case ExercisePhase.concentric:
        // Nötr pozisyona dönüldü
        if (tiltDiff < 0.03) {
          _tiltCount++;
          _phase = ExercisePhase.completed;
        }
        break;

      case ExercisePhase.completed:
        // Bir rep = bir yöne eğip geri dönme
        _phase = ExercisePhase.waiting;
        _maxTilt = 0;
        break;
    }

    return ValidationResult(
      phase: _phase,
      currentAngle: _tiltAngle,
      isFormCorrect: isFormCorrect,
      formError: formError,
    );
  }

  @override
  bool canValidate(List<LandmarkPoint> landmarks) {
    if (landmarks.length < PoseLandmarkIndex.totalLandmarks) return false;

    final nose = landmarks[PoseLandmarkIndex.nose];
    final leftShoulder = landmarks[PoseLandmarkIndex.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkIndex.rightShoulder];
    final leftEar = landmarks[PoseLandmarkIndex.leftEar];
    final rightEar = landmarks[PoseLandmarkIndex.rightEar];

    return AngleCalculator.areLandmarksReliable(
      landmarks,
      [PoseLandmarkIndex.nose, PoseLandmarkIndex.leftShoulder, PoseLandmarkIndex.rightShoulder, PoseLandmarkIndex.leftEar, PoseLandmarkIndex.rightEar],
      minConfidence: 0.5,
    );
  }

  @override
  void reset() {
    _phase = ExercisePhase.waiting;
    _tiltAngle = 0;
    _maxTilt = 0;
    _tiltCount = 0;
  }
}
