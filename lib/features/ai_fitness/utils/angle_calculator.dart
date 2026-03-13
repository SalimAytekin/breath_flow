import 'dart:math' as math;
import '../models/landmark_point.dart';

/// Açı ve vektör hesaplama yardımcı sınıfı.
///
/// Egzersiz formunu analiz etmek için 2D (X, Y) düzleminde
/// üç noktalı açı hesaplaması yapar. Z ekseni güvenilir olmadığı
/// için V1'de kullanılmaz.
class AngleCalculator {
  /// Üç nokta arasındaki açıyı derece cinsinden hesaplar.
  ///
  /// [a] = Üst nokta (örn: omuz)
  /// [b] = Orta nokta / vertex (örn: dirsek)
  /// [c] = Alt nokta (örn: bilek)
  ///
  /// Dönen değer: 0°-180° arası açı (derece)
  static double calculateAngle(
    LandmarkPoint a,
    LandmarkPoint b,
    LandmarkPoint c,
  ) {
    // Vektör BA ve BC
    final baX = a.x - b.x;
    final baY = a.y - b.y;
    final bcX = c.x - b.x;
    final bcY = c.y - b.y;

    // Dot product
    final dot = baX * bcX + baY * bcY;

    // Magnitudes
    final magBA = math.sqrt(baX * baX + baY * baY);
    final magBC = math.sqrt(bcX * bcX + bcY * bcY);

    // Sıfıra bölme koruması
    if (magBA == 0 || magBC == 0) return 0;

    // Acos — clamp ile NaN koruması
    final cosAngle = (dot / (magBA * magBC)).clamp(-1.0, 1.0);
    final angleRad = math.acos(cosAngle);

    // Radyan → Derece
    return angleRad * (180.0 / math.pi);
  }

  /// İki nokta arasındaki mesafeyi hesaplar (2D Euclidean)
  static double distance(LandmarkPoint a, LandmarkPoint b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Bir noktanın, iki nokta tarafından oluşturulan dikey çizgiye
  /// olan yatay sapmasını hesaplar.
  ///
  /// Dirsek sabitliği kontrolü gibi durumlarda kullanılır:
  /// Dirsek, omuz-kalça hizasından ne kadar sapıyor?
  static double horizontalDeviation(
    LandmarkPoint point,
    LandmarkPoint lineTop,
    LandmarkPoint lineBottom,
  ) {
    // Dikey çizginin ortalaması x koordinatı
    final lineX = (lineTop.x + lineBottom.x) / 2;
    return (point.x - lineX).abs();
  }

  /// Tüm gerekli landmarkların güvenilir olup olmadığını kontrol eder
  static bool areLandmarksReliable(
    List<LandmarkPoint> landmarks,
    List<int> requiredIndices, {
    double minConfidence = 0.65,
  }) {
    for (final index in requiredIndices) {
      if (index >= landmarks.length) return false;
      if (landmarks[index].visibility < minConfidence) return false;
    }
    return true;
  }
}
