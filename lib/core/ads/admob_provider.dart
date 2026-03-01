import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_provider.dart';
import '../../services/ad_config.dart';

class AdMobProvider implements AdProvider {
  Map<String, BannerAd> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  String? _currentBannerPlacement;
  
  Completer<InterstitialAd?>? _interstitialCompleter;
  
  // Callback fonksiyonu için
  Function()? _onInterstitialDismissed;

  @override
  bool get isInterstitialLoaded => _interstitialAd != null;

  @override
  Future<void> initialize() async {
    // AdMob zaten main.dart'da initialize edildi
    if (kDebugMode) {
      print('AdMobProvider initialized');
    }
  }
  
  // Callback ayarlama metodu
  void setInterstitialDismissedCallback(Function()? callback) {
    _onInterstitialDismissed = callback;
  }

  // Banner yükleme durumunu takip et
  final Map<String, bool> _bannerLoadedStates = {};
  
  // Banner yüklendi mi kontrol et
  bool isBannerLoaded(String placement) => _bannerLoadedStates[placement] == true;

  @override
  Future<void> loadBanner({required String placement, AdSize? size}) async {
    try {
      _currentBannerPlacement = placement;
      
      // Önceki banner'ı dispose et
      try {
        _bannerAds[placement]?.dispose();
      } catch (e) {
        // Dispose hatası olsa bile devam et
      }
      _bannerAds.remove(placement);
      _bannerLoadedStates[placement] = false;
      
      // Farklı banner boyutlarını dene
      final bannerSize = size ?? _getOptimalBannerSize();
      
      if (kDebugMode) {
        print('🎯 Banner yükleniyor - Placement: $placement');
      }
      
      final adRequest = AdRequest(
        keywords: ['wellness', 'meditation', 'breathing', 'relaxation', 'health', 'mindfulness'],
        contentUrl: 'https://breatheflow.app',
        nonPersonalizedAds: false,
      );
      
      // Completer ile yükleme tamamlanmasını bekle
      final completer = Completer<bool>();
      
      final bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: bannerSize,
        request: adRequest,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('✅ Banner yüklendi - $placement');
            }
            _bannerLoadedStates[placement] = true;
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('❌ Banner hata - $placement: ${error.code}');
            }
            ad.dispose();
            _bannerAds.remove(placement);
            _bannerLoadedStates[placement] = false;
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
          onAdOpened: (ad) {},
          onAdClosed: (ad) {},
          onAdImpression: (ad) {
            // if (kDebugMode) {
            //   print('👁️ Banner impression - $placement');
            // }
          },
        ),
      );
      
      _bannerAds[placement] = bannerAd;
      bannerAd.load();
      
      // Yükleme tamamlanana kadar bekle (timeout ile)
      try {
        await completer.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode) {
              print('⏰ Banner yükleme timeout - $placement');
            }
            _bannerLoadedStates[placement] = false;
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            return false;
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('⏰ Banner beklerken hata - $placement: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Banner yükleme hatası - Placement: $placement - Exception: $e');
      }
    }
  }

  @override
  Future<void> showBanner() async {
    // Banner gösterimi AdWidget ile yapılır, burada sadece yükleme kontrolü
    if (_currentBannerPlacement != null && !_bannerAds.containsKey(_currentBannerPlacement!)) {
      await loadBanner(placement: _currentBannerPlacement!);
    }
  }

  @override
  Future<void> loadInterstitial({required String placement}) async {
    try {
      // Önceki reklamı temizle
      if (_interstitialAd != null) {
        try {
          _interstitialAd!.dispose();
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Önceki interstitial dispose hatası: $e');
          }
        }
        _interstitialAd = null;
      }
      
      if (kDebugMode) {
        print('🎯 Interstitial yükleniyor - Placement: $placement');
      }
      
      // Completer oluştur
      _interstitialCompleter = Completer<InterstitialAd?>();
      
      InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            if (kDebugMode) {
              print('✅ Interstitial başarıyla yüklendi - Placement: $placement');
            }
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                if (kDebugMode) {
                  print('✅ Interstitial kapatıldı - Placement: $placement');
                }
                try {
                  ad.dispose();
                } catch (e) {
                  if (kDebugMode) {
                    print('⚠️ Interstitial dispose hatası: $e');
                  }
                }
                _interstitialAd = null;
                
                // Callback'i çağır
                if (_onInterstitialDismissed != null) {
                  if (kDebugMode) {
                    print('🎊 Interstitial callback çağrılıyor...');
                  }
                  _onInterstitialDismissed!();
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                if (kDebugMode) {
                  print('❌ Interstitial gösterilemedi - Placement: $placement - Hata: $error');
                }
                try {
                  ad.dispose();
                } catch (e) {
                  if (kDebugMode) {
                    print('⚠️ Interstitial dispose hatası: $e');
                  }
                }
                _interstitialAd = null;
              },
            );
            
            // Completer'ı tamamla
            if (!_interstitialCompleter!.isCompleted) {
              _interstitialCompleter!.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print('❌ Interstitial yüklenemedi - Placement: $placement - Hata: $error');
              print('🔍 Hata detayı: ${error.code} - ${error.message}');
            }
            _interstitialAd = null;
            
            // Completer'ı hata ile tamamla
            if (!_interstitialCompleter!.isCompleted) {
              _interstitialCompleter!.complete(null);
            }
          },
        ),
      );
      
      // Reklam yüklenene kadar bekle (timeout ile)
      try {
        await _interstitialCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              print('⏰ Interstitial yükleme timeout - Placement: $placement');
            }
            if (!_interstitialCompleter!.isCompleted) {
              _interstitialCompleter!.complete(null);
            }
            return null;
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ Interstitial yükleme beklerken hata - Placement: $placement - Exception: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Interstitial yükleme hatası - Placement: $placement - Exception: $e');
      }
    }
  }

  @override
  Future<bool> showInterstitial({required String placement}) async {
    // if (kDebugMode) {
    //   print('🎯 Interstitial gösterilmeye çalışılıyor - Placement: $placement');
    // }
    
    try {
      // Reklam yüklü değilse yükle
      if (_interstitialAd == null) {
        if (kDebugMode) {
          print('⚠️ Interstitial yüklü değil, yükleniyor...');
        }
        await loadInterstitial(placement: placement);
        
        // Yükleme işlemi tamamlandıktan sonra tekrar kontrol et
        if (_interstitialAd == null) {
          if (kDebugMode) {
            print('❌ Interstitial yüklenemedi, gösterilemiyor');
          }
          return false;
        }
      }
      
      // if (kDebugMode) {
      //   print('✅ Interstitial gösteriliyor - Placement: $placement');
      // }
      
      // Reklamı göster
      await _interstitialAd!.show();
      
      // if (kDebugMode) {
      //   print('🎉 Interstitial başarıyla gösterildi - Placement: $placement');
      // }
      return true;
      
    } catch (e) {
      // if (kDebugMode) {
      //   print('❌ Interstitial gösterim hatası - Placement: $placement - Exception: $e');
      // }
      
      // Hata durumunda reklamı temizle ve null yap
      try {
        _interstitialAd?.dispose();
      } catch (disposeError) {
        if (kDebugMode) {
          print('⚠️ Interstitial dispose hatası: $disposeError');
        }
      }
      _interstitialAd = null;
      return false;
    }
  }

  @override
  Future<void> loadRewarded({required String placement}) async {
    try {
      _rewardedAd?.dispose();
      
      await RewardedAd.load(
        adUnitId: AdConfig.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            if (kDebugMode) {
              print('Rewarded loaded for placement: $placement');
            }
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print('Rewarded failed to load for placement: $placement - $error');
            }
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Rewarded load error for placement: $placement - $e');
      }
    }
  }

  @override
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  }) async {
    if (_rewardedAd == null) {
      await loadRewarded(placement: placement);
      return false; // Henüz yüklenmedi
    }
    
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
          if (kDebugMode) {
            print('Reward earned for placement: $placement');
          }
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Rewarded show error for placement: $placement - $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    // Tüm banner ad'ları dispose et
    for (var bannerAd in _bannerAds.values) {
      bannerAd.dispose();
    }
    _bannerAds.clear();
    
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }

  // Banner widget'ı için getter - placement'a göre banner döndür
  BannerAd? getBannerAd(String placement) => _bannerAds[placement];
  
  // Optimal banner boyutunu belirle
  AdSize _getOptimalBannerSize() {
    // Placement'a göre optimal boyutu seç
    switch (_currentBannerPlacement) {
      case 'main_navigation':
        // Ana navigasyon için daha küçük banner - daha iyi fill rate
        return AdSize.banner; // 320x50 - En yaygın ve güvenilir boyut
      case 'sounds_screen':
        return AdSize.largeBanner; // 320x100 - Ses ekranı için daha büyük
      case 'sleep_journal':
        return AdSize.banner; // 320x50 - Günlük ekranı için standart
      case 'sleep_analytics':
        return AdSize.banner; // 320x50 - Analiz ekranı için standart
      case 'exercise_list_screen':
        return AdSize.banner; // 320x50 - Egzersiz listesi için standart
      default:
        return AdSize.banner; // Varsayılan olarak standart banner
    }
  }
}
