import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// A/B Test sistemi - Premium fiyatlandırma optimizasyonu
class ABTestService {
  static ABTestService? _instance;
  static ABTestService get instance => _instance ??= ABTestService._();
  ABTestService._();

  /// A/B Test servisini başlat
  Future<void> initialize() async {
    try {
      if (kDebugMode) print('🧪 A/B Test Service başlatıldı');
    } catch (e) {
      if (kDebugMode) print('❌ A/B Test Service başlatma hatası: $e');
    }
  }

  // Test konfigürasyonları
  static const String _pricingTestKey = 'pricing_ab_test';
  static const String _triggerTestKey = 'trigger_ab_test';
  static const String _adFrequencyTestKey = 'ad_frequency_ab_test';

  // Test varyantları
  static const List<String> _pricingVariants = ['A', 'B', 'C'];
  static const List<String> _triggerVariants = ['early', 'medium', 'late'];
  static const List<String> _adFrequencyVariants = ['low', 'medium', 'high'];

  /// Kullanıcı için test varyantını belirle
  Future<String> getVariant(String testKey, List<String> variants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? existingVariant = prefs.getString(testKey);
      
      if (existingVariant != null && variants.contains(existingVariant)) {
        return existingVariant;
      }
      
      // Yeni varyant seç
      final random = Random();
      final selectedVariant = variants[random.nextInt(variants.length)];
      
      await prefs.setString(testKey, selectedVariant);
      if (kDebugMode) print('🧪 A/B Test: $testKey = $selectedVariant');
      
      return selectedVariant;
    } catch (e) {
      if (kDebugMode) print('❌ A/B Test hatası: $e');
      return variants.first; // Fallback
    }
  }

  /// Fiyatlandırma testi varyantını al
  Future<String> getPricingVariant() async {
    return await getVariant(_pricingTestKey, _pricingVariants);
  }

  /// Premium tetikleyici testi varyantını al
  Future<String> getTriggerVariant() async {
    return await getVariant(_triggerTestKey, _triggerVariants);
  }

  /// Reklam sıklığı testi varyantını al
  Future<String> getAdFrequencyVariant() async {
    return await getVariant(_adFrequencyTestKey, _adFrequencyVariants);
  }

  /// Fiyatlandırma varyantına göre fiyat al
  Future<Map<String, String>> getPricingForVariant() async {
    final variant = await getPricingVariant();
    
    switch (variant) {
      case 'A':
        return {
          'monthly': '₺19,99/ay',
          'yearly': '₺199,99/yıl',
          'trial': '7 gün ücretsiz',
          'discount': '₺9,99/ay',
          'original': '₺19,99',
        };
      case 'B':
        return {
          'monthly': '₺14,99/ay',
          'yearly': '₺149,99/yıl',
          'trial': '7 gün ücretsiz',
          'discount': '₺7,99/ay',
          'original': '₺14,99',
        };
      case 'C':
        return {
          'monthly': '₺29,99/ay',
          'yearly': '₺299,99/yıl',
          'trial': '7 gün ücretsiz',
          'discount': '₺14,99/ay',
          'original': '₺29,99',
        };
      default:
        return {
          'monthly': '₺19,99/ay',
          'yearly': '₺199,99/yıl',
          'trial': '7 gün ücretsiz',
          'discount': '₺9,99/ay',
          'original': '₺19,99',
        };
    }
  }

  /// Tetikleyici varyantına göre koşulları al
  Future<Map<String, dynamic>> getTriggerConditions() async {
    final variant = await getTriggerVariant();
    
    switch (variant) {
      case 'early':
        return {
          'sessionThreshold': 2,
          'cooldownDays': 3,
          'priority': 3,
        };
      case 'medium':
        return {
          'sessionThreshold': 5,
          'cooldownDays': 5,
          'priority': 2,
        };
      case 'late':
        return {
          'sessionThreshold': 8,
          'cooldownDays': 7,
          'priority': 1,
        };
      default:
        return {
          'sessionThreshold': 5,
          'cooldownDays': 5,
          'priority': 2,
        };
    }
  }

  /// Reklam sıklığı varyantına göre ayarları al
  Future<Map<String, dynamic>> getAdFrequencySettings() async {
    final variant = await getAdFrequencyVariant();
    
    switch (variant) {
      case 'low':
        return {
          'interstitialInterval': 8, // Her 8 seans sonrası
          'maxInterstitialsPerDay': 3,
          'bannerRefreshMinutes': 10,
        };
      case 'medium':
        return {
          'interstitialInterval': 5, // Her 5 seans sonrası
          'maxInterstitialsPerDay': 5,
          'bannerRefreshMinutes': 5,
        };
      case 'high':
        return {
          'interstitialInterval': 3, // Her 3 seans sonrası
          'maxInterstitialsPerDay': 8,
          'bannerRefreshMinutes': 3,
        };
      default:
        return {
          'interstitialInterval': 5,
          'maxInterstitialsPerDay': 5,
          'bannerRefreshMinutes': 5,
        };
    }
  }

  /// Test sonuçlarını kaydet
  Future<void> recordTestResult({
    required String testName,
    required String variant,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'ab_test_result_${testName}_${variant}_${action}';
      final count = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, count + 1);
      
      if (kDebugMode) print('📊 A/B Test sonucu kaydedildi: $testName - $variant - $action');
    } catch (e) {
      if (kDebugMode) print('❌ A/B Test sonuç kaydetme hatası: $e');
    }
  }

  /// Test istatistiklerini al
  Future<Map<String, Map<String, int>>> getTestStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('ab_test_result_'));
      
      final statistics = <String, Map<String, int>>{};
      
      for (final key in keys) {
        final parts = key.split('_');
        if (parts.length >= 6) {
          final testName = parts[3];
          final variant = parts[4];
          final action = parts[5];
          
          if (!statistics.containsKey(testName)) {
            statistics[testName] = {};
          }
          
          final count = prefs.getInt(key) ?? 0;
          statistics[testName]!['${variant}_$action'] = count;
        }
      }
      
      return statistics;
    } catch (e) {
      if (kDebugMode) print('❌ A/B Test istatistik alma hatası: $e');
      return {};
    }
  }

  /// Test varyantını sıfırla (test için)
  Future<void> resetTestVariant(String testKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(testKey);
      if (kDebugMode) print('🧪 A/B Test sıfırlandı: $testKey');
    } catch (e) {
      if (kDebugMode) print('❌ A/B Test sıfırlama hatası: $e');
    }
  }

  /// Tüm testleri sıfırla (test için)
  Future<void> resetAllTests() async {
    await resetTestVariant(_pricingTestKey);
    await resetTestVariant(_triggerTestKey);
    await resetTestVariant(_adFrequencyTestKey);
    if (kDebugMode) print('🧪 Tüm A/B Testler sıfırlandı');
  }
}

/// A/B Test Provider'ı
class ABTestProvider extends ChangeNotifier {
  final ABTestService _abTestService = ABTestService.instance;
  
  Map<String, String> _pricing = {};
  Map<String, dynamic> _triggerConditions = {};
  Map<String, dynamic> _adFrequencySettings = {};

  Map<String, String> get pricing => _pricing;
  Map<String, dynamic> get triggerConditions => _triggerConditions;
  Map<String, dynamic> get adFrequencySettings => _adFrequencySettings;

  Future<void> initialize() async {
    _pricing = await _abTestService.getPricingForVariant();
    _triggerConditions = await _abTestService.getTriggerConditions();
    _adFrequencySettings = await _abTestService.getAdFrequencySettings();
    notifyListeners();
  }

  Future<void> recordTestResult({
    required String testName,
    required String variant,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await _abTestService.recordTestResult(
      testName: testName,
      variant: variant,
      action: action,
      metadata: metadata,
    );
  }

  Future<Map<String, Map<String, int>>> getTestStatistics() async {
    return await _abTestService.getTestStatistics();
  }

  Future<void> resetAllTests() async {
    await _abTestService.resetAllTests();
    await initialize();
  }
}
