import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_config.dart';

/// Basit ve temiz reklam servisi
/// Önceki karmaşık provider sistemlerinden ders alınarak sadeleştirildi
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialTime;
  int _interstitialCountToday = 0;
  String? _todayKey;

  /// AdMob'u başlat
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      AdConfig.printConfig();
      print('✅ AdMob başarıyla başlatıldı');
      
      // İlk interstitial reklamı yükle
      instance.loadInterstitialAd();
    } catch (e) {
      print('❌ AdMob başlatma hatası: $e');
    }
  }

  /// Interstitial reklamı yükle
  Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            print('✅ Interstitial reklam yüklendi');
            
            // Reklam kapatıldığında temizle
            _interstitialAd!.setImmersiveMode(true);
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                print('📱 Interstitial reklam kapatıldı');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                print('❌ Interstitial reklam gösterim hatası: $error');
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial reklam yükleme hatası: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      print('❌ Interstitial reklam yükleme exception: $e');
    }
  }

  /// Interstitial reklamı göster (kurallarla birlikte)
  Future<bool> showInterstitialAd() async {
    // Günlük limit kontrolü
    await _checkDailyLimit();
    
    if (_interstitialCountToday >= AdConfig.maxInterstitialsPerDay) {
      print('⏰ Günlük interstitial limit aşıldı');
      return false;
    }

    // Zaman kontrolü
    if (_lastInterstitialTime != null) {
      final timeDiff = DateTime.now().difference(_lastInterstitialTime!);
      if (timeDiff < AdConfig.minTimeBetweenInterstitials) {
        print('⏰ Interstitial için henüz erken');
        return false;
      }
    }

    // Reklam hazır mı?
    if (_interstitialAd == null) {
      print('📺 Interstitial reklam henüz yüklenmedi');
      await loadInterstitialAd(); // Yeniden yüklemeyi dene
      return false;
    }

    try {
      await _interstitialAd!.show();
      _lastInterstitialTime = DateTime.now();
      _interstitialCountToday++;
      await _saveDailyCount();
      
      // Yeni reklam yükle
      Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
      
      print('✅ Interstitial reklam gösterildi');
      return true;
    } catch (e) {
      print('❌ Interstitial reklam gösterim exception: $e');
      return false;
    }
  }

  /// Günlük limit kontrolü
  Future<void> _checkDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (_todayKey != today) {
      _todayKey = today;
      _interstitialCountToday = prefs.getInt('interstitial_count_$today') ?? 0;
    }
  }

  /// Günlük sayacı kaydet
  Future<void> _saveDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setInt('interstitial_count_$today', _interstitialCountToday);
  }

  /// Servisi temizle
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
