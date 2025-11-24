import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 🚨 Crashlytics Service - Kritik hataları yakalar ve raporlar
/// 
/// Bu service, uygulamanın kritik hatalarını Firebase Crashlytics'e gönderir.
/// AdManager, MediaPlayer ve Network call'ları için özel error handling sağlar.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  static CrashlyticsService get instance => _instance;

  FirebaseCrashlytics? _crashlytics;
  bool _isInitialized = false;
  
  // Test için public getter'lar
  FirebaseCrashlytics? get crashlytics => _crashlytics;
  set crashlytics(FirebaseCrashlytics? value) => _crashlytics = value;
  set isInitialized(bool value) => _isInitialized = value;

  /// Crashlytics servisini başlatır
  Future<void> initialize() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Debug modda test crash gönder
      if (kDebugMode) {
        await _crashlytics!.setCrashlyticsCollectionEnabled(true);
        debugPrint('🚨 Crashlytics Service initialized successfully');
        
        // Test crash gönder (sadece debug modda)
        // await _crashlytics!.crash();
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('🚨 Crashlytics initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Error kaydetme - Ana metod
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || _crashlytics == null) {
      debugPrint('🚨 Crashlytics not initialized, skipping error: $exception');
      return;
    }

    try {
      // Additional data'yı string'e çevir
      Map<String, String>? stringData;
      if (additionalData != null) {
        stringData = additionalData.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }

      await _crashlytics!.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
        information: stringData?.entries
            .map((e) => DiagnosticsProperty(e.key, e.value))
            .toList() ?? [],
      );

      if (kDebugMode) {
        debugPrint('🚨 Crashlytics Error Recorded: $exception');
        if (reason != null) debugPrint('   Reason: $reason');
        if (additionalData != null) debugPrint('   Data: $additionalData');
      }
    } catch (e) {
      debugPrint('🚨 Crashlytics recordError failed: $e');
    }
  }

  // ========================================
  // 🎯 REKLAM ERROR HANDLING
  // ========================================

  /// AdManager hatalarını kaydet
  Future<void> recordAdError({
    required String errorType, // load_failed, show_failed, etc.
    required String placement,
    required String errorMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) async {
    await recordError(
      originalError ?? Exception('Ad Error: $errorMessage'),
      stackTrace,
      reason: 'AdManager Error',
      additionalData: {
        'error_type': errorType,
        'placement': placement,
        'error_message': errorMessage,
        'component': 'AdManager',
      },
    );
  }

  // ========================================
  // 🎵 MEDIA ERROR HANDLING
  // ========================================

  /// MediaPlayer hatalarını kaydet
  Future<void> recordMediaError({
    required String errorType, // audio_load_failed, video_load_failed, etc.
    required String mediaId,
    required String errorMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) async {
    await recordError(
      originalError ?? Exception('Media Error: $errorMessage'),
      stackTrace,
      reason: 'MediaPlayer Error',
      additionalData: {
        'error_type': errorType,
        'media_id': mediaId,
        'error_message': errorMessage,
        'component': 'MediaPlayer',
      },
    );
  }

  // ========================================
  // 🌐 NETWORK ERROR HANDLING
  // ========================================

  /// Network hatalarını kaydet
  Future<void> recordNetworkError({
    required String errorType, // timeout, connection_failed, etc.
    required String endpoint,
    required String errorMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) async {
    await recordError(
      originalError ?? Exception('Network Error: $errorMessage'),
      stackTrace,
      reason: 'Network Error',
      additionalData: {
        'error_type': errorType,
        'endpoint': endpoint,
        'error_message': errorMessage,
        'component': 'Network',
      },
    );
  }

  // ========================================
  // 🧘 EGZERSİZ ERROR HANDLING
  // ========================================

  /// Egzersiz hatalarını kaydet
  Future<void> recordExerciseError({
    required String errorType,
    required String exerciseId,
    required String errorMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) async {
    await recordError(
      originalError ?? Exception('Exercise Error: $errorMessage'),
      stackTrace,
      reason: 'Exercise Error',
      additionalData: {
        'error_type': errorType,
        'exercise_id': exerciseId,
        'error_message': errorMessage,
        'component': 'Exercise',
      },
    );
  }

  // ========================================
  // 🔧 UTILITY METODLAR
  // ========================================

  /// User ID set etme
  Future<void> setUserId(String userId) async {
    if (!_isInitialized || _crashlytics == null) return;
    
    try {
      await _crashlytics!.setUserIdentifier(userId);
      debugPrint('🚨 Crashlytics User ID set: $userId');
    } catch (e) {
      debugPrint('🚨 Crashlytics setUserId failed: $e');
    }
  }

  /// Custom key-value pair set etme
  Future<void> setCustomKey(String key, String value) async {
    if (!_isInitialized || _crashlytics == null) return;
    
    try {
      await _crashlytics!.setCustomKey(key, value);
      debugPrint('🚨 Crashlytics Custom Key set: $key = $value');
    } catch (e) {
      debugPrint('🚨 Crashlytics setCustomKey failed: $e');
    }
  }

  /// Log mesajı gönderme
  Future<void> log(String message) async {
    if (!_isInitialized || _crashlytics == null) return;
    
    try {
      await _crashlytics!.log(message);
      if (kDebugMode) {
        debugPrint('🚨 Crashlytics Log: $message');
      }
    } catch (e) {
      debugPrint('🚨 Crashlytics log failed: $e');
    }
  }

  /// Test crash gönderme (sadece debug modda)
  Future<void> testCrash() async {
    if (!_isInitialized || _crashlytics == null) return;
    
    if (kDebugMode) {
      _crashlytics!.crash();
    }
  }

  /// Crashlytics collection durumunu kontrol et
  bool get isInitialized => _isInitialized;

  /// Debug için tüm error tiplerini listele
  void printAvailableErrorTypes() {
    if (kDebugMode) {
      debugPrint('''
🚨 Available Crashlytics Error Types:
  📊 Reklam Errors:
    - load_failed, show_failed, click_failed
  
  🎵 Media Errors:
    - audio_load_failed, video_load_failed, playback_failed
  
  🌐 Network Errors:
    - timeout, connection_failed, server_error
  
  🧘 Exercise Errors:
    - initialization_failed, timer_error, state_error
  
  🔧 General Errors:
    - recordError(exception, stackTrace, reason, additionalData)
      ''');
    }
  }
}
