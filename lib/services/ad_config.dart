import 'dart:io';

/// Temiz ve basit reklam konfigürasyonu
/// Önceki karmaşık sistemlerden ders alınarak sadeleştirildi
class AdConfig {
  // Test reklam ID'leri - Güvenli başlangıç
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';

  // Gerçek reklam ID'leri - Daha sonra güncellenecek
  static const String _realBannerAndroid = 'ca-app-pub-3940256099942544/6300978111'; // Şimdilik test
  static const String _realBannerIOS = 'ca-app-pub-3940256099942544/2934735716'; // Şimdilik test
  static const String _realInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712'; // Şimdilik test
  static const String _realInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910'; // Şimdilik test

  // Test modu kontrolü - Kolayca değiştirilebilir
  static const bool _useTestAds = true;

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

  /// Reklam gösterim kuralları
  static const Duration minTimeBetweenInterstitials = Duration(minutes: 3);
  static const int maxInterstitialsPerDay = 10;
  static const Duration bannerRefreshInterval = Duration(minutes: 5);

  /// Debug bilgileri
  static void printConfig() {
    print('🎯 AdConfig - Test Mode: $_useTestAds');
    print('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
    print('🎬 Banner ID: $bannerAdUnitId');
    print('📺 Interstitial ID: $interstitialAdUnitId');
  }
}
