import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:breathe_flow/core/ads/ad_manager.dart';
import 'package:breathe_flow/core/ads/admob_provider.dart';
import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:provider/provider.dart';
import 'package:breathe_flow/constants/app_strings.dart';

class AdContainer extends StatefulWidget {
  final String placement;
  final double height;
  final Duration? refreshInterval;
  final EdgeInsets? margin;

  const AdContainer({
    super.key,
    required this.placement,
    this.height = 60,
    this.refreshInterval,
    this.margin,
  });

  @override
  State<AdContainer> createState() => _AdContainerState();
}

class _AdContainerState extends State<AdContainer> {
  Timer? _timer;
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  double _currentAdHeight = 60; // Dinamik yükseklik
  DateTime? _lastLoadTime; // Son yükleme zamanı
  bool _disposed = false; // ⚡ Leak prevention

  @override
  void initState() {
    super.initState();
    // ⚡ OPTIMIZE: Banner'ları sırayla yükle - aynı anda 3 banner yükleme
    // Her banner için farklı gecikme
    final delay = _getLoadDelay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _load();
      });
    });
    _setupRefresh();
  }
  
  // Banner placement'a göre yükleme gecikmesi
  int _getLoadDelay() {
    if (widget.placement.contains('home')) return 0;      // Hemen
    if (widget.placement.contains('explore')) return 500; // 0.5s sonra
    if (widget.placement.contains('profile')) return 1000; // 1s sonra
    return 0;
  }

  void _setupRefresh() {
    // ⚡ OPTIMIZE: Çok daha uzun refresh interval - UI blokajını engelle
    final seconds = AdManager.instance.getBannerRefreshSeconds();
    final interval = widget.refreshInterval ?? Duration(seconds: seconds * 3); // 3x daha uzun (90 saniye)
    _timer = Timer.periodic(interval, (_) {
      if (!_disposed && mounted) { // ⚡ Safe timer callback
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (_disposed || !mounted || _isLoading) return; // ⚡ Disposed check first
    
    // ⚡ OPTIMIZE: Daha agresif cache kontrolü - gereksiz yüklemeleri engelle
    if (_lastLoadTime != null) {
      final timeSinceLastLoad = DateTime.now().difference(_lastLoadTime!);
      // Başarılı yükleme sonrası 30 saniye bekle
      if (_isLoaded && timeSinceLastLoad.inSeconds < 30) {
        return;
      }
      // Başarısız yükleme sonrası 10 saniye bekle
      if (!_isLoaded && timeSinceLastLoad.inSeconds < 10) {
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    _lastLoadTime = DateTime.now();
    
    try {
      // AdMobProvider'dan banner al
      final provider = AdManager.instance.provider as AdMobProvider?;
      if (provider != null) {
        // Google AdMob standartlarına uygun adaptive banner boyutu hesapla
        final screenWidth = MediaQuery.of(context).size.width;
        final adWidth = screenWidth.truncate();
        
        AdSize? adaptiveSize;
        try {
          // Google standartlarına uygun adaptive banner
          adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);
          
          // Google standartlarına uygunluk kontrolü
          if (adaptiveSize != null) {
            // Minimum yükseklik kontrolü (Google standartları)
            if (adaptiveSize.height < 50) {
              adaptiveSize = AdSize.largeBanner; // 320x100 - daha iyi okunabilirlik
            }
          }
        } catch (e) {
          adaptiveSize = null;
        }

        // Fallback: Google standart boyutları
        AdSize finalSize;
        if (adaptiveSize != null) {
          finalSize = adaptiveSize;
        } else {
          // Ekran genişliğine göre en uygun standart boyutu seç
          if (screenWidth >= 728) {
            finalSize = AdSize.leaderboard; // 728x90 - tablet için
          } else if (screenWidth >= 400) {
            finalSize = AdSize.largeBanner; // 320x100 - daha iyi okunabilirlik
          } else {
            finalSize = AdSize.banner; // 320x50 - standart mobil
          }
        }
        
        await provider.loadBanner(
          placement: widget.placement,
          size: finalSize,
        );
        
        // ⚡ FIX: Sadece gerçekten yüklenmiş banner'ı al
        final isLoaded = provider.isBannerLoaded(widget.placement);
        _bannerAd = isLoaded ? provider.getBannerAd(widget.placement) : null;
        
        if (_bannerAd != null && isLoaded && mounted) {
          setState(() {
            _isLoaded = true;
            _isLoading = false;
            _hasError = false;
            _retryCount = 0; // Başarılı yükleme sonrası retry sayacını sıfırla
            _currentAdHeight = finalSize.height.toDouble(); // Reklam boyutuna göre yükseklik ayarla
          });
        } else {
          _handleLoadError();
        }
      } else {
        _handleLoadError();
      }
    } catch (e) {
      _handleLoadError();
    }
  }

  void _handleLoadError() {
    if (mounted) {
      setState(() {
        _isLoaded = false;
        _isLoading = false;
        _hasError = true;
        _retryCount++;
      });
      
      // Daha agresif retry mekanizması - hızlı retry
      if (_retryCount < _maxRetries) {
        // Çok daha hızlı retry - kullanıcı deneyimi için
        final delaySeconds = _retryCount == 1 ? 1 : (_retryCount * 2);
        Future.delayed(Duration(seconds: delaySeconds), () {
          if (mounted) {
            _load();
          }
        });
      } else {
        // Son retry'dan sonra fallback banner göster
        setState(() {
          _hasError = false; // Fallback banner göstermek için
        });
      }
    }
  }

  @override
  void dispose() {
    _disposed = true; // ⚡ Mark as disposed first
    _timer?.cancel();
    _timer = null;
    try {
      _bannerAd?.dispose();
    } catch (e) {
      // Dispose hatası olsa bile devam et
    }
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ OPTIMIZE: Selector kullan - sadece ad_free değiştiğinde rebuild
    return Selector<PremiumProvider, bool>(
      selector: (_, premium) => premium.canAccessFeature('ad_free'),
      builder: (context, isAdFree, child) {
        // Premium kullanıcılar için reklamları gizle
        if (isAdFree) {
          return const SizedBox.shrink();
        }

        // child parametresini kullan - gereksiz rebuild'leri engelle
        return child!;
      },
      child: Container(
        margin: widget.margin ?? const EdgeInsets.fromLTRB(12, 6, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: _currentAdHeight,
            child: _buildAdContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildAdContent() {
    // Reklam başarıyla yüklendiyse göster
    // ⚡ FIX: isBannerLoaded kontrolü ile "Ad.load to be called before" crash'ini önle
    if (_isLoaded && _bannerAd != null) {
      try {
        final provider = AdManager.instance.provider as AdMobProvider?;
        final isActuallyLoaded = provider?.isBannerLoaded(widget.placement) ?? false;
        
        if (!isActuallyLoaded) {
          // Banner henüz yüklenmedi, loading göster
          return _buildLoadingIndicator();
        }
        
        // ⚡ OPTIMIZE: RepaintBoundary ile AdWidget'ı izole et
        return RepaintBoundary(
          child: AdWidget(ad: _bannerAd!),
        );
      } catch (e) {
        // Ad dispose edilmişse veya hata varsa fallback göster
        return _buildFallbackBanner();
      }
    }
    
    // Yükleniyor durumunda profesyonel loading göster
    if (_isLoading) {
      return Container(
        height: _currentAdHeight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }
    
    // Hata durumunda sessizce loading göster (retry mesajını gizle)
    if (_hasError && _retryCount < _maxRetries) {
      return Container(
        height: _currentAdHeight,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      );
    }
    
    // Maksimum retry aşıldıysa veya başka bir hata varsa fallback banner göster
    return _buildFallbackBanner();
  }


  Widget _buildLoadingIndicator() {
    return Container(
      height: _currentAdHeight,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: _currentAdHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.08),
            Colors.blue.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.adPlaceholder,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


