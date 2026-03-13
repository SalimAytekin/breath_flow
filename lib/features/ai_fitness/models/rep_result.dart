import 'exercise_phase.dart';

/// Tek bir tekrarın (rep) sonuç verisi
class RepResult {
  /// Tekrar sıra numarası (1, 2, 3...)
  final int repNumber;

  /// Tekrar kalitesi
  final RepQuality quality;

  /// Tekrar sırasındaki minimum açı (derece)
  final double minAngle;

  /// Tekrar sırasındaki maksimum açı (derece)
  final double maxAngle;

  /// Tekrarın tamamlanma süresi (milisaniye)
  final int durationMs;

  /// Hata mesajı (varsa)
  final String? errorMessage;

  /// Tekrarın zaman damgası
  final DateTime timestamp;

  const RepResult({
    required this.repNumber,
    required this.quality,
    required this.minAngle,
    required this.maxAngle,
    required this.durationMs,
    this.errorMessage,
    required this.timestamp,
  });

  /// Tekrar başarılı mı?
  bool get isSuccessful => quality != RepQuality.bad;

  /// Hareket açıklığı (Range of Motion)
  double get rangeOfMotion => (maxAngle - minAngle).abs();

  @override
  String toString() =>
      'Rep #$repNumber: ${quality.name} (${minAngle.toStringAsFixed(0)}°-${maxAngle.toStringAsFixed(0)}°, ${durationMs}ms)';
}

/// Egzersiz oturumunun özet sonuçları
class SessionResult {
  final ExerciseType exerciseType;
  final int totalReps;
  final int perfectReps;
  final int acceptableReps;
  final int badReps;
  final Duration totalDuration;
  final List<RepResult> repHistory;
  final DateTime startTime;
  final DateTime endTime;

  const SessionResult({
    required this.exerciseType,
    required this.totalReps,
    required this.perfectReps,
    required this.acceptableReps,
    required this.badReps,
    required this.totalDuration,
    required this.repHistory,
    required this.startTime,
    required this.endTime,
  });

  /// Genel başarı yüzdesi
  double get successRate {
    if (totalReps == 0) return 0;
    return ((perfectReps + acceptableReps) / totalReps) * 100;
  }

  /// Ortalama tekrar süresi
  double get avgRepDurationMs {
    if (repHistory.isEmpty) return 0;
    final totalMs = repHistory.fold<int>(0, (sum, r) => sum + r.durationMs);
    return totalMs / repHistory.length;
  }
}
