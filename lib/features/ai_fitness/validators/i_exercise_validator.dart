import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';

/// Validasyon sonucu
class ValidationResult {
  /// Mevcut egzersiz fazı
  final ExercisePhase phase;

  /// Mevcut birincil açı (derece)
  final double currentAngle;

  /// Form doğru mu?
  final bool isFormCorrect;

  /// Form hatası mesajı (varsa)
  final String? formError;

  /// Tekrar kalitesi
  final RepQuality quality;

  const ValidationResult({
    required this.phase,
    required this.currentAngle,
    required this.isFormCorrect,
    this.formError,
    this.quality = RepQuality.acceptable,
  });
}

/// Egzersiz doğrulayıcı arayüzü (Strategy Pattern)
///
/// Her egzersiz tipi bu arayüzü uygulayarak kendi geometrik
/// kurallarını tanımlar.
abstract class IExerciseValidator {
  /// Egzersiz konfigürasyonu
  ExerciseConfig get config;

  /// Mevcut fazı ve doğruluğu değerlendir
  ///
  /// [landmarks] = MediaPipe'tan gelen 33 nokta
  /// [currentPhase] = Şu anki state machine durumu
  ValidationResult validate(
    List<LandmarkPoint> landmarks,
    ExercisePhase currentPhase,
  );

  /// Gerekli landmarkların görünür olup olmadığını kontrol et
  bool canValidate(List<LandmarkPoint> landmarks);

  /// Validator'ı sıfırla (yeni set başlangıcında)
  void reset();
}
