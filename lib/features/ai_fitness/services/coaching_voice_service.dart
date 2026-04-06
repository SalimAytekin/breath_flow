import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 🎙️ Sesli Koçluk Servisi — TTS ile Türkçe egzersiz yönlendirmesi.
///
/// Spam önleme (2sn cooldown), sessiz mod desteği, öncelik kuyruğu.
class CoachingVoiceService {
  final FlutterTts _tts = FlutterTts();

  /// Ses açık mı?
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  /// Son konuşma zamanı (spam önleme)
  int _lastSpeakTime = 0;

  /// Minimum konuşma aralığı (ms)
  static const int _speakCooldownMs = 2000;

  /// Mevcut konuşma devam ediyor mu?
  bool _isSpeaking = false;

  /// TTS başlatıldı mı?
  bool _isInitialized = false;

  /// TTS motoru başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.55); // Biraz yavaş — egzersiz sırasında anlaşılsın
      await _tts.setVolume(0.9);
      await _tts.setPitch(1.05); // Hafif dinamik ton

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setVoice({"name": "Yelda", "locale": "tr-TR"});
      }

      _isInitialized = true;
      if (kDebugMode) debugPrint('🎙️ TTS initialized (tr-TR)');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ TTS init failed: $e');
    }
  }

  /// Sessiz modu aç/kapat
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _tts.stop();
      _isSpeaking = false;
    }
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      _tts.stop();
      _isSpeaking = false;
    }
  }

  // ─────────────────────────────────────────
  // 🗣️ Coaching Mesajları
  // ─────────────────────────────────────────

  /// Egzersiz başlangıcı
  Future<void> speakExerciseStart(String exerciseName) async {
    await _speak('$exerciseName başlıyor. Hazır ol!', priority: true);
  }

  /// Faz değişiklikleri
  Future<void> speakPhaseDown() async {
    await _speak('İn!');
  }

  Future<void> speakPhaseUp() async {
    await _speak('Kalk!');
  }

  /// Rep tamamlandı
  Future<void> speakRepCount(int count, int target) async {
    if (count == target) {
      await _speak('Bravo! Seti tamamladın!', priority: true);
    } else if (count == (target / 2).round()) {
      await _speak('Yarıladın! Devam et!', priority: true);
    } else if (count % 5 == 0 && count > 0) {
      await _speak('$count tekrar! Harikasın!', priority: true);
    } else {
      await _speak('$count', priority: false);
    }
  }

  /// Form uyarısı
  Future<void> speakFormWarning(String warning) async {
    await _speak(warning);
  }

  /// Streak kutlama (3+ art arda mükemmel)
  Future<void> speakStreak(int streakCount) async {
    if (streakCount == 3) {
      await _speak('Üç mükemmel! Harika form!', priority: true);
    } else if (streakCount == 5) {
      await _speak('Beş art arda mükemmel! Muhteşemsin!', priority: true);
    } else if (streakCount >= 10) {
      await _speak('İnanılmaz! $streakCount mükemmel seri!', priority: true);
    }
  }

  /// Set tamamlama
  Future<void> speakSetComplete(int totalReps, double successRate) async {
    if (successRate >= 90) {
      await _speak('Muhteşem performans! $totalReps tekrar, yüzde ${successRate.toInt()} başarı!', priority: true);
    } else if (successRate >= 70) {
      await _speak('Güzel iş! $totalReps tekrar tamamlandı.', priority: true);
    } else {
      await _speak('$totalReps tekrar bitti. Bir sonraki sefer daha iyi olacak!', priority: true);
    }
  }

  // ─────────────────────────────────────────
  // 🔧 Internal
  // ─────────────────────────────────────────

  /// Konuşma tetikle (cooldown & mute kontrolü ile)
  Future<void> _speak(String text, {bool priority = false}) async {
    if (_isMuted || !_isInitialized) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Priority mesajlar cooldown'u geçebilir
    if (!priority) {
      if (_isSpeaking) return;
      if ((now - _lastSpeakTime) < _speakCooldownMs) return;
    }

    _lastSpeakTime = now;
    _isSpeaking = true;

    try {
      // Emojileri temizle (sadece harf, rakam, boşluk ve temel noktalama işaretlerini bırakır)
      final cleanText = text.replaceAll(RegExp(r'[^\w\s.,!?:şŞıİçÇöÖüÜğĞ\-]'), '');
      
      // Önceki konuşmayı durdur (priority ise)
      if (priority) await _tts.stop();
      await _tts.speak(cleanText);
    } catch (e) {
      _isSpeaking = false;
      if (kDebugMode) debugPrint('⚠️ TTS speak error: $e');
    }
  }

  /// Temizle
  Future<void> dispose() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}
