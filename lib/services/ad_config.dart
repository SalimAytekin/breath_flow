import 'dart:io';
import 'package:flutter/foundation.dart';

/// Temiz ve basit reklam konfigürasyonu
/// Önceki karmaşık sistemlerden ders alınarak sadeleştirildi
class AdConfig {
  // Test reklam ID'leri - Güvenli başlangıç
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313'; // ← Eksik olan eklendi

  // ✅ Gerçek reklam ID'leri - AdMob Console'dan alındı
  static const String _realBannerAndroid = 'ca-app-pub-5877027096706438/4334146343';
  static const String _realBannerIOS = 'ca-app-pub-5877027096706438/4334146343';
  static const String _realInterstitialAndroid = 'ca-app-pub-5877027096706438/8652950914';
  static const String _realInterstitialIOS = 'ca-app-pub-5877027096706438/8652950914';
  // ⚠️ Rewarded reklam ID'leri AdMob Console'da oluşturulmalı
  static const String _realRewardedAndroid = 'ca-app-pub-5877027096706438/REWARDED_ID_GEREKLI';
  static const String _realRewardedIOS = 'ca-app-pub-5877027096706438/REWARDED_IOS_ID_GEREKLI';

  // 🎯 TEST MODU - Test reklamları aktif
  // Dahili test için güvenli test reklamları kullanılıyor
  static const bool _useTestAds = true; // Test reklamları
  
  // ℹ️ TEST ETMEK İÇİN:
  // 1. Debug modda çalıştırın: flutter run
  // 2. Test device ID'nizi alın (loglardan)
  // 3. ad_manager.dart'daki testDeviceIds listesine ekleyin
  // 4. Debug modda güvenle test edin - BAN RİSKİ YOK!

  /// Banner reklam ID'sini al
  static String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return Platform.isAndroid ? _realBannerAndroid : _realBannerIOS;
  }

  /// Interstitial reklam ID'sini al
  static String get interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS;
    }
    return Platform.isAndroid ? _realInterstitialAndroid : _realInterstitialIOS;
  }

  /// Rewarded reklam ID'sini al
  static String get rewardedAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testRewardedAndroid : _testRewardedIOS;
    }
    return Platform.isAndroid ? _realRewardedAndroid : _realRewardedIOS;
  }

  /// Debug bilgileri
  static void printConfig() {
    if (kDebugMode) {
      print('🎯 AdConfig - Test Mode: $_useTestAds');
      print('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('🎬 Banner ID: $bannerAdUnitId');
      print('📺 Interstitial ID: $interstitialAdUnitId');
      print('🎁 Rewarded ID: $rewardedAdUnitId');
    }
  }
  
  /// Test modu aktif mi?
  static bool get isTestMode => _useTestAds;
}
