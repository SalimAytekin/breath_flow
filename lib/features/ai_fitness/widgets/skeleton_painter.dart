import 'package:flutter/material.dart';
import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';

/// İskelet çizim sınıfı — Kamera önizlemesi üzerine overlay.
///
/// MediaPipe'tan gelen 33 landmark noktasını ve bağlantı çizgilerini
/// kamera preview üzerine çizer.
///
/// Renkler:
/// - Beyaz/Gri: Normal duruş
/// - Yeşil: Doğru form / hedef açıya ulaşıldı
/// - Kırmızı: Yanlış form (sadece ilgili eklem)
/// - Mavi: Birincil ölçüm noktaları
class SkeletonPainter extends CustomPainter {
  final List<LandmarkPoint> landmarks;
  final bool isFormCorrect;
  final ExercisePhase phase;
  final List<int>? highlightedLandmarks;
  final Size imageSize;
  final bool isFrontCamera;

  SkeletonPainter({
    required this.landmarks,
    required this.isFormCorrect,
    required this.phase,
    this.highlightedLandmarks,
    required this.imageSize,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    // MediaPipe landmark koordinatları zaten normalize (0.0 – 1.0)
    // Doğrudan canvas boyutuyla çarpılır, imageSize'a gerek yok.
    // scaleX / scaleY kaldırıldı — eskiden landmark → pixel dönüşümünü
    // iki kere yapıyordu ve hatalı konumlandırmaya yol açıyordu.

    // ─── Bağlantı Çizgileri ──────────────────────────
    _drawConnections(canvas, size);

    // ─── Landmark Noktaları ──────────────────────────
    _drawLandmarks(canvas, size);
  }

  void _drawConnections(Canvas canvas, Size size) {
    for (final connection in PoseLandmarkIndex.skeletonConnections) {
      final startIdx = connection[0];
      final endIdx = connection[1];

      if (startIdx >= landmarks.length || endIdx >= landmarks.length) continue;

      final start = landmarks[startIdx];
      final end = landmarks[endIdx];

      // Düşük güvenli noktalar atla
      if (!start.isVisible || !end.isVisible) continue;

      // Renk belirleme
      Color lineColor;
      double strokeWidth = 2.5;

      final isHighlighted = highlightedLandmarks != null &&
          (highlightedLandmarks!.contains(startIdx) ||
              highlightedLandmarks!.contains(endIdx));

      if (isHighlighted && !isFormCorrect) {
        lineColor = const Color(0xFFFF4444); // Kırmızı — form hatası
        strokeWidth = 4.0;
      } else if (isHighlighted && phase == ExercisePhase.concentric) {
        lineColor = const Color(0xFF44FF44); // Yeşil — tepe noktası
        strokeWidth = 3.5;
      } else if (isHighlighted) {
        lineColor = const Color(0xFF4488FF); // Mavi — birincil noktalar
        strokeWidth = 3.0;
      } else {
        lineColor = Colors.white.withOpacity(0.6);
      }

      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startOffset = _toCanvasOffset(start, size);
      final endOffset = _toCanvasOffset(end, size);

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawLandmarks(Canvas canvas, Size size) {
    for (int i = 0; i < landmarks.length; i++) {
      final landmark = landmarks[i];
      if (!landmark.isVisible) continue;

      final offset = _toCanvasOffset(landmark, size);

      // Nokta boyutu ve rengi
      double radius = 4;
      Color color = Colors.white;

      final isHighlighted = highlightedLandmarks?.contains(i) ?? false;

      if (isHighlighted) {
        radius = 7;
        color = isFormCorrect
            ? const Color(0xFF44FF44)
            : const Color(0xFFFF4444);
      }

      // Dış halka (glow efekti)
      if (isHighlighted) {
        canvas.drawCircle(
          offset,
          radius + 4,
          Paint()
            ..color = color.withOpacity(0.25)
            ..style = PaintingStyle.fill,
        );
      }

      // İç daire
      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  /// Normalize MediaPipe landmark (0.0–1.0) → canvas piksel koordinatı.
  ///
  /// Ön kamerada tek aynalama burada yapılıyor.
  /// Kotlin tarafı artık aynalama YAPMIYOR — bu tek nokta.
  Offset _toCanvasOffset(
    LandmarkPoint landmark,
    Size canvasSize,
  ) {
    // Ön kamerada x eksenini ters çevir (selfie mirror efekti)
    final double x = isFrontCamera
        ? (1.0 - landmark.x) * canvasSize.width
        : landmark.x * canvasSize.width;
    final double y = landmark.y * canvasSize.height;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.isFormCorrect != isFormCorrect ||
        oldDelegate.phase != phase;
  }
}
