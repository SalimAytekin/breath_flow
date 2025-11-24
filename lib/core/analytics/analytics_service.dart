import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// 🎯 Analytics Service - Tüm event'leri tutarlı şekilde Firebase Analytics'e gönderir
/// 
/// Bu service, uygulamanın tüm önemli event'lerini standartlaştırılmış format ile
/// Firebase Analytics'e gönderir. Event parametreleri tutarlı ve test edilebilir.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;
  
  // Test için public getter'lar
  FirebaseAnalytics? get analytics => _analytics;
  set analytics(FirebaseAnalytics? value) => _analytics = value;
  set isInitialized(bool value) => _isInitialized = value;

  /// Analytics servisini başlatır
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      
      // Debug modda log'ları göster
      if (kDebugMode) {
        await _analytics!.setAnalyticsCollectionEnabled(true);
        debugPrint('🎯 Analytics Service initialized successfully');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('🚨 Analytics initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Event gönderme - Ana metod
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    if (!_isInitialized || _analytics == null) {
      debugPrint('🚨 Analytics not initialized, skipping event: $eventName');
      return;
    }

    try {
      // Parametreleri string'e çevir (Firebase Analytics requirement)
      final Map<String, String> stringParams = parameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      await _analytics!.logEvent(
        name: eventName,
        parameters: stringParams,
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics Event: $eventName -> $stringParams');
      }
    } catch (e) {
      debugPrint('🚨 Analytics event failed: $eventName - $e');
    }
  }

  // ========================================
  // 🎯 REKLAM EVENT'LERİ
  // ========================================

  /// Reklam gösterimi event'i
  Future<void> logAdImpression({
    required String type, // banner, interstitial, rewarded
    required String placement,
  }) async {
    await logEvent('ad_impression', {
      'type': type,
      'placement': placement,
    });
  }

  /// Reklam hatası event'i
  Future<void> logAdError({
    required String errorCode,
    required String placement,
  }) async {
    await logEvent('ad_error', {
      'error_code': errorCode,
      'placement': placement,
    });
  }

  // ========================================
  // 🧘 EGZERSİZ EVENT'LERİ
  // ========================================

  /// Egzersiz başlatma event'i
  Future<void> logExerciseStarted({
    required String exerciseId,
    required String from, // home, explore, profile, favorite
  }) async {
    await logEvent('exercise_started', {
      'id': exerciseId,
      'from': from,
    });
  }

  /// Egzersiz tamamlama event'i
  Future<void> logExerciseCompleted({
    required String exerciseId,
    required int durationSeconds,
  }) async {
    await logEvent('exercise_completed', {
      'id': exerciseId,
      'duration': durationSeconds.toString(),
    });
  }

  // ========================================
  // 🎵 SES EVENT'LERİ
  // ========================================

  /// Ses çalma event'i
  Future<void> logSoundPlayed({
    required String soundId,
    required int durationSeconds,
  }) async {
    await logEvent('sound_played', {
      'id': soundId,
      'duration': durationSeconds.toString(),
    });
  }

  // ========================================
  // 😴 UYKU EVENT'LERİ
  // ========================================

  /// Uyku girişi ekleme event'i
  Future<void> logSleepEntryAdded() async {
    await logEvent('sleep_entry_added', {});
  }

  // ========================================
  // ❤️ FAVORİ EVENT'LERİ
  // ========================================

  /// Favori toggle event'i
  Future<void> logFavoriteToggled({
    required String itemId,
    required String type, // exercise, sound
  }) async {
    await logEvent('favorite_toggled', {
      'id': itemId,
      'type': type,
    });
  }

  // ========================================
  // 💎 PREMIUM EVENT'LERİ
  // ========================================

  /// Premium satın alma event'i
  Future<void> logPremiumPurchase({
    required String plan,
  }) async {
    await logEvent('premium_purchase', {
      'plan': plan,
    });
  }

  // ========================================
  // 📱 EKRAN EVENT'LERİ
  // ========================================

  /// Ekran görüntüleme event'i
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {
      'screen_name': screenName,
    });
  }

  // ========================================
  // 🔧 UTILITY METODLAR
  // ========================================

  /// User ID set etme
  Future<void> setUserId(String userId) async {
    if (!_isInitialized || _analytics == null) return;
    
    try {
      await _analytics!.setUserId(id: userId);
      debugPrint('📊 Analytics User ID set: $userId');
    } catch (e) {
      debugPrint('🚨 Analytics setUserId failed: $e');
    }
  }

  /// User property set etme
  Future<void> setUserProperty(String name, String value) async {
    if (!_isInitialized || _analytics == null) return;
    
    try {
      await _analytics!.setUserProperty(name: name, value: value);
      debugPrint('📊 Analytics User Property set: $name = $value');
    } catch (e) {
      debugPrint('🚨 Analytics setUserProperty failed: $e');
    }
  }

  /// Analytics collection durumunu kontrol et
  bool get isInitialized => _isInitialized;

  /// Debug için tüm event'leri listele
  void printAvailableEvents() {
    if (kDebugMode) {
      debugPrint('''
🎯 Available Analytics Events:
  📊 Reklam Events:
    - ad_impression(type, placement)
    - ad_error(error_code, placement)
  
  🧘 Egzersiz Events:
    - exercise_started(id, from)
    - exercise_completed(id, duration)
  
  🎵 Ses Events:
    - sound_played(id, duration)
  
  😴 Uyku Events:
    - sleep_entry_added()
  
  ❤️ Favori Events:
    - favorite_toggled(id, type)
  
  💎 Premium Events:
    - premium_purchase(plan)
  
  📱 Ekran Events:
    - screen_view(screen_name)
      ''');
    }
  }
}
