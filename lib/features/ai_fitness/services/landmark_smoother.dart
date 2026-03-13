import 'dart:collection';
import '../models/landmark_point.dart';

/// Temporal Smoothing — Son N frame'in hareketli ortalaması (EMA).
///
/// Tek bir frame'in gürültüsünü (jitter) filtreler.
/// Her landmark için ayrı bir geçmiş kuyruğu tutar.
class LandmarkSmoother {
  /// Confidence eşiği — bu altındaki landmark null döner
  static const double _minConfidence = 0.65;

  /// Kaç frame'lik pencere kullanılsın
  final int windowSize;

  /// Her landmark index için geçmiş veriler
  final Map<int, Queue<LandmarkPoint>> _history = {};

  LandmarkSmoother({this.windowSize = 5});

  /// Ham landmark'ı yumuşatarak döndürür.
  ///
  /// - Confidence düşükse `null` döner (kullanma)
  /// - Son [windowSize] frame'in ortalamasını verir
  LandmarkPoint? smooth(int landmarkIndex, LandmarkPoint raw) {
    // Confidence filtresi
    if (raw.visibility < _minConfidence) return null;

    // Geçmiş kuyruğu oluştur veya al
    _history.putIfAbsent(landmarkIndex, () => Queue());
    final queue = _history[landmarkIndex]!;

    queue.add(raw);
    if (queue.length > windowSize) queue.removeFirst();

    // Hareketli ortalama
    double sumX = 0, sumY = 0, sumZ = 0, sumVis = 0;
    for (final p in queue) {
      sumX += p.x;
      sumY += p.y;
      sumZ += p.z;
      sumVis += p.visibility;
    }
    final count = queue.length;

    return LandmarkPoint(
      x: sumX / count,
      y: sumY / count,
      z: sumZ / count,
      visibility: sumVis / count,
    );
  }

  /// Tüm 33 landmark'ı toplu yumuşat
  List<LandmarkPoint> smoothAll(List<LandmarkPoint> rawLandmarks) {
    final result = <LandmarkPoint>[];

    for (int i = 0; i < rawLandmarks.length; i++) {
      final smoothed = smooth(i, rawLandmarks[i]);
      result.add(smoothed ?? rawLandmarks[i]);
    }

    return result;
  }

  /// Geçmişi temizle (yeni oturum başladığında)
  void reset() {
    _history.clear();
  }
}
