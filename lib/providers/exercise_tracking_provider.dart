import 'package:flutter/foundation.dart';

/// 🎯 Egzersiz Takip Provider
/// Kullanıcının egzersiz davranışlarını takip eder ve interstitial reklam kontrolü yapar
class ExerciseTrackingProvider extends ChangeNotifier {
  static final ExerciseTrackingProvider _instance = ExerciseTrackingProvider._internal();
  factory ExerciseTrackingProvider() => _instance;
  ExerciseTrackingProvider._internal();

  // Egzersiz başlatma sayacı
  int _exerciseStartCount = 0;
  
  // Son interstitial reklam zamanı
  DateTime? _lastInterstitialTime;
  
  // Minimum interval (2 dakika) - Test için daha kısa
  static const Duration _minInterval = Duration(minutes: 2);
  
  // Maksimum egzersiz başlatma sayısı (3)
  static const int _maxExerciseStarts = 3;

  /// Egzersiz başlatıldığında çağrılır
  void onExerciseStarted() {
    _exerciseStartCount++;
    debugPrint('🎯 Egzersiz başlatıldı. Toplam: $_exerciseStartCount');
    notifyListeners();
  }

  /// Egzersiz tamamlandığında çağrılır
  void onExerciseCompleted() {
    _exerciseStartCount = 0; // Sayaç sıfırla
    debugPrint('✅ Egzersiz tamamlandı. Sayaç sıfırlandı.');
    notifyListeners();
  }

  /// Egzersizden çıkış kontrolü
  /// 3 egzersiz başlatıp çıkarsa interstitial reklam göster
  bool shouldShowExitInterstitial() {
    final now = DateTime.now();
    
    // Rate limiting kontrolü
    if (_lastInterstitialTime != null) {
      final timeSinceLastAd = now.difference(_lastInterstitialTime!);
      if (timeSinceLastAd < _minInterval) {
        debugPrint('⏰ Rate limiting: ${_minInterval.inMinutes - timeSinceLastAd.inMinutes} dakika kaldı');
        return false;
      }
    }
    
    // Egzersiz başlatma sayısı kontrolü
    if (_exerciseStartCount >= _maxExerciseStarts) {
      debugPrint('🎯 3 egzersiz başlatıldı, interstitial reklam gösterilecek');
      _lastInterstitialTime = now;
      _exerciseStartCount = 0; // Sayaç sıfırla
      notifyListeners();
      return true;
    }
    
    return false;
  }

  /// Egzersiz tamamlanma kontrolü
  /// Egzersiz tamamlandığında interstitial reklam göster
  bool shouldShowCompletionInterstitial() {
    final now = DateTime.now();
    
    // Rate limiting kontrolü
    if (_lastInterstitialTime != null) {
      final timeSinceLastAd = now.difference(_lastInterstitialTime!);
      if (timeSinceLastAd < _minInterval) {
        debugPrint('⏰ Rate limiting: ${_minInterval.inMinutes - timeSinceLastAd.inMinutes} dakika kaldı');
        return false;
      }
    }
    
    debugPrint('✅ Egzersiz tamamlandı, interstitial reklam gösterilecek');
    _lastInterstitialTime = now;
    _exerciseStartCount = 0; // Sayaç sıfırla
    notifyListeners();
    return true;
  }

  /// Mevcut egzersiz başlatma sayısı
  int get exerciseStartCount => _exerciseStartCount;
  
  /// Son interstitial reklam zamanı
  DateTime? get lastInterstitialTime => _lastInterstitialTime;
  
  /// Rate limiting durumu
  bool get isRateLimited {
    if (_lastInterstitialTime == null) return false;
    final now = DateTime.now();
    final timeSinceLastAd = now.difference(_lastInterstitialTime!);
    return timeSinceLastAd < _minInterval;
  }
  
  /// Rate limiting kalan süre
  Duration? get remainingRateLimitTime {
    if (_lastInterstitialTime == null) return null;
    final now = DateTime.now();
    final timeSinceLastAd = now.difference(_lastInterstitialTime!);
    final remaining = _minInterval - timeSinceLastAd;
    return remaining.isNegative ? null : remaining;
  }
}
