import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'coaching_voice_service.dart';

/// 🎯 Gelişmiş Geri Bildirim Motoru — Haptik + TTS + Motivasyon.
///
/// 3 katmanlı geri bildirim:
/// 1. Haptic — anlık dokunsal hissetme
/// 2. TTS — sesli koçluk yönlendirmesi
/// 3. Visual — renk/ikon değişiklikleri (UI tarafında)
class FeedbackEngine {
  /// Cihaz titreşim destekliyor mu?
  bool _hasVibrator = false;

  /// Son haptik geri bildirimin zamanı (spam önleme için)
  int _lastHapticTime = 0;

  /// Haptik geri bildirimler arası minimum süre (ms)
  static const int _hapticCooldownMs = 500;

  /// TTS Ses koçu
  final CoachingVoiceService _voice = CoachingVoiceService();
  CoachingVoiceService get voice => _voice;

  /// Son form uyarısı zamanı (spam önleme)
  int _lastFormWarningTime = 0;
  static const int _formWarningCooldownMs = 3000;

  /// Başlatma
  Future<void> initialize() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      _hasVibrator = false;
      if (kDebugMode) debugPrint('⚠️ Vibration check failed: $e');
    }

    await _voice.initialize();
  }

  /// 🎬 Egzersiz başladı
  Future<void> onExerciseStart(String exerciseName) async {
    await _voice.speakExerciseStart(exerciseName);
  }

  /// 🔄 Faz değişimi — hafif tik
  Future<void> onPhaseChanged(String phaseName) async {
    if (!_canVibrate()) return;
    _lastHapticTime = DateTime.now().millisecondsSinceEpoch;

    try {
      await Vibration.vibrate(duration: 30, amplitude: 80);
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
    }
  }

  /// ✅ Başarılı tekrar geri bildirimi — kısa, tatmin edici titreşim + ses
  Future<void> onRepCompleted({
    required int repCount,
    required int targetReps,
  }) async {
    // Haptic
    if (_canVibrate()) {
      _lastHapticTime = DateTime.now().millisecondsSinceEpoch;
      try {
        await Vibration.vibrate(duration: 80, amplitude: 128);
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
      }
    }

    // TTS — rep sayısı
    await _voice.speakRepCount(repCount, targetReps);
  }

  /// ❌ Yanlış form geri bildirimi — çift kısa titreşim + sesli uyarı
  Future<void> onBadForm({String? warningMessage}) async {
    // Haptic
    if (_canVibrate()) {
      _lastHapticTime = DateTime.now().millisecondsSinceEpoch;
      try {
        await Vibration.vibrate(
            pattern: [0, 60, 40, 60], intensities: [0, 180, 0, 180]);
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
      }
    }

    // TTS — form uyarısı (cooldown ile)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (warningMessage != null &&
        (now - _lastFormWarningTime) >= _formWarningCooldownMs) {
      _lastFormWarningTime = now;
      await _voice.speakFormWarning(warningMessage);
    }
  }

  /// 🔥 Streak kutlama — art arda perfect rep
  Future<void> onStreak(int consecutivePerfect) async {
    // Özel titreşim deseni
    if (_canVibrate()) {
      _lastHapticTime = DateTime.now().millisecondsSinceEpoch;
      try {
        await Vibration.vibrate(
          pattern: [0, 50, 30, 50, 30, 80],
          intensities: [0, 150, 0, 150, 0, 200],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
      }
    }

    // TTS — streak kutlama
    await _voice.speakStreak(consecutivePerfect);
  }

  /// 🏆 Set tamamlandı — uzun, doyurucu titreşim + kutlama sesi
  Future<void> onSetCompleted({
    required int totalReps,
    required double successRate,
  }) async {
    // Haptic — uzun ve doyurucu
    if (_canVibrate()) {
      _lastHapticTime = DateTime.now().millisecondsSinceEpoch;
      try {
        await Vibration.vibrate(duration: 300, amplitude: 200);
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
      }
    }

    // TTS — set tamamlama kutlama
    await _voice.speakSetComplete(totalReps, successRate);
  }

  /// 🎯 Milestone — 5., 10. rep özel geri bildirim
  Future<void> onMilestone(int repCount) async {
    if (_canVibrate()) {
      _lastHapticTime = DateTime.now().millisecondsSinceEpoch;
      try {
        await Vibration.vibrate(
          pattern: [0, 80, 50, 80, 50, 120],
          intensities: [0, 160, 0, 160, 0, 220],
        );
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Vibration error: $e');
      }
    }
  }

  /// Spam'ı önlemek için cooldown kontrolü
  bool _canVibrate() {
    if (!_hasVibrator) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - _lastHapticTime) >= _hapticCooldownMs;
  }

  /// Temizle
  Future<void> dispose() async {
    await _voice.dispose();
  }
}
