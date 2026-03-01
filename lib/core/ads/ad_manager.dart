import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'ad_provider.dart';
import 'admob_provider.dart';
import '../analytics/analytics_service.dart';
import '../crashlytics/crashlytics_service.dart';

class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

  // Global state
  bool isPremium = false;
  DateTime? _lastInterstitialTime;
  int interstitialIntervalMinutes = 4; // Kullanıcı deneyimi için optimize

  // Config
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Provider
  AdProvider? _provider;
  void setProvider(AdProvider provider) => _provider = provider;
  
  // Public getter for provider access
  AdProvider? get provider => _provider;

  /// Interstitial reklam yüklü mü?
  bool get isInterstitialLoaded => _provider?.isInterstitialLoaded ?? false;

  bool get _adsEnabled => _remoteConfig.getBool('ads_enabled');
  int getBannerRefreshSeconds() {
    final value = _remoteConfig.getInt('banner_refresh_seconds');
    return value.clamp(30, 45);
  }

  Future<void> initialize({AdProvider? provider}) async {
    try {
      // Default provider olarak AdMobProvider kullan
      _provider = provider ?? AdMobProvider();
      
      // Test device konfigürasyonu
      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: [
              // 🎯 Test device ID'lerinizi buraya ekleyin
              // Nasıl bulunur: flutter run ile uygulamayı çalıştırın, logları kontrol edin
              // Örnek: '2077ef9a63d2b398840261c8221a0c9b'
              
              // TODO: Kendi test device ID'lerinizi buraya ekleyin:
              // 'SIZIN_TEST_DEVICE_ID_1',
              // 'SIZIN_TEST_DEVICE_ID_2',
              '0B68B2F5993374366D973F283AAB7E74', // Loglardan alınan device ID
            ],
            tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
            tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
            maxAdContentRating: MaxAdContentRating.g,
          ),
        );
        print('🎯 Test device konfigürasyonu ayarlandı');
        print('🔧 Test reklamları aktif - BAN RİSKİ YOK');
        print('📱 Test Device ID\'leri: YOK (Güvenli)');
        print('⚠️ Production\'a geçerken test device ID\'lerini kaldırın!');
      }
      
      await MobileAds.instance.initialize();

      // Remote Config fetch
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));
      await _remoteConfig.setDefaults(const {
        'ads_enabled': true,
        'interstitial_interval_min': 4, // Kullanıcı deneyimi için optimize
        'banner_refresh_seconds': 30,
      });
      await _remoteConfig.fetchAndActivate();
      interstitialIntervalMinutes = _remoteConfig.getInt('interstitial_interval_min').clamp(1, 10);

      await _provider!.initialize();
      
      if (kDebugMode) {
        debugPrint('✅ AdManager initialized');
        debugPrint('⏱️ Interval: ${interstitialIntervalMinutes}m | Ads: $_adsEnabled');
      }
    } catch (e, st) {
      await CrashlyticsService.instance.recordAdError(
        errorType: 'initialization_failed',
        placement: 'ad_manager_init',
        errorMessage: e.toString(),
        originalError: e,
        stackTrace: st,
      );
      if (kDebugMode) debugPrint('❌ AdManager initialization failed: $e');
    }
  }

  // Banner
  Future<void> showBanner({required String placement}) async {
    // Premium sistemi kaldırıldı - herkes reklam görür
    if (!_adsEnabled) return;
    try {
      await _provider?.loadBanner(placement: placement);
      await _provider?.showBanner();
      
      // Analytics event
      await AnalyticsService.instance.logAdImpression(
        type: 'banner',
        placement: placement,
      );
    } catch (e, st) {
      await CrashlyticsService.instance.recordAdError(
        errorType: 'show_failed',
        placement: placement,
        errorMessage: e.toString(),
        originalError: e,
        stackTrace: st,
      );
      await AnalyticsService.instance.logAdError(
        errorCode: e.toString(),
        placement: placement,
      );
    }
  }

  // Preload Interstitial
  Future<void> preloadInterstitial({required String placement}) async {
    if (!_adsEnabled) return;
    try {
      if (_provider == null) return;
      if (_provider!.isInterstitialLoaded) return; // Zaten yüklü

      if (kDebugMode) debugPrint('📥 Interstitial preloading: $placement');
      await _provider!.loadInterstitial(placement: placement);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Preload error: $e');
    }
  }

  // Interstitial
  Future<bool> showInterstitial({required String placement}) async {
    // Premium sistemi kaldırıldı - herkes reklam görür
    if (!_adsEnabled) return false;

    final now = DateTime.now();
    if (_lastInterstitialTime != null) {
      final diff = now.difference(_lastInterstitialTime!);
      final minDiff = Duration(minutes: interstitialIntervalMinutes);
      
      // Çıkış ve tamamlanma reklamları için rate limit'i esnet (20 saniyeye düşür)
      // Kullanıcı gerçekten 3 kere girip çıkmışsa veya uzun süre durmuşsa göstermeli
      bool isPriorityPlacement = placement.contains('exit') || placement.contains('complete') || placement.contains('save');
      final effectiveMinDiff = isPriorityPlacement ? const Duration(seconds: 20) : minDiff;

      if (diff < effectiveMinDiff) {
        // if (kDebugMode) debugPrint('⏳ Rate limit active. Next ad in: ${(effectiveMinDiff - diff).inSeconds}s');
        return false; 
      }
    }

    try {
      if (_provider == null) return false;

      // Eğer önceden yüklenmemişse yükle
      if (!_provider!.isInterstitialLoaded) {
        await _provider!.loadInterstitial(placement: placement);
      }
      
      final shown = await _provider!.showInterstitial(placement: placement);
      
      if (shown) {
        _lastInterstitialTime = now;
        await AnalyticsService.instance.logAdImpression(
          type: 'interstitial',
          placement: placement,
        );
        
        if (kDebugMode) debugPrint('🎬 Interstitial shown: $placement');
      }
      
      return shown;
    } catch (e, st) {
      await CrashlyticsService.instance.recordAdError(
        errorType: 'show_failed',
        placement: placement,
        errorMessage: e.toString(),
        originalError: e,
        stackTrace: st,
      );
      await AnalyticsService.instance.logAdError(
        errorCode: e.toString(),
        placement: placement,
      );
      return false;
    }
  }

  // Rewarded
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  }) async {
    // Premium sistemi kaldırıldı - herkes rewarded reklam izleyebilir
    if (!_adsEnabled) return false;
    try {
      await _provider?.loadRewarded(placement: placement);
      final shown = await _provider?.showRewarded(
            placement: placement,
            onRewardEarned: onRewardEarned,
          ) ??
          false;
      
      if (shown) {
        // Analytics event
        await AnalyticsService.instance.logAdImpression(
          type: 'rewarded',
          placement: placement,
        );
      }
      
      return shown;
    } catch (e, st) {
      await CrashlyticsService.instance.recordAdError(
        errorType: 'show_failed',
        placement: placement,
        errorMessage: e.toString(),
        originalError: e,
        stackTrace: st,
      );
      await AnalyticsService.instance.logAdError(
        errorCode: e.toString(),
        placement: placement,
      );
      return false;
    }
  }

  void updatePremium(bool premium) {
    isPremium = premium;
  }

  void dispose() {
    // Provider varsa dispose et
    _provider?.dispose();
  }
}


