import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../services/ad_config.dart';

/// Basit banner reklam widget'ı - Tek sorumluluk prensibi
/// Önceki karmaşık state yönetimi problemlerinden ders alınarak sadeleştirildi
class SimpleBannerAd extends StatefulWidget {
  final String placement; // Hangi ekranda olduğunu belirtmek için
  final EdgeInsets? margin;
  final bool showPlaceholder;

  const SimpleBannerAd({
    super.key,
    required this.placement,
    this.margin,
    this.showPlaceholder = true,
  });

  @override
  State<SimpleBannerAd> createState() => _SimpleBannerAdState();
}

class _SimpleBannerAdState extends State<SimpleBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  /// Banner reklamı yükle
  void _loadBannerAd() {
    if (_isDisposed) return;

    try {
      _bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoaded = true;
              });
              print('✅ Banner reklam yüklendi: ${widget.placement}');
            }
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner reklam yükleme hatası: $error');
            ad.dispose();
            if (!_isDisposed && mounted) {
              setState(() {
                _bannerAd = null;
                _isLoaded = false;
                _retryCount++;
                print('🔄 Banner reklam retry: $_retryCount/$_maxRetries');
              });
              
              // İlk 3 deneme hızlı, sonra yavaş yavaş
              int delaySeconds;
              if (_retryCount <= _maxRetries) {
                delaySeconds = 3 * _retryCount; // 3, 6, 9 saniye
              } else {
                delaySeconds = 60; // 1 dakika sonra tekrar dene
              }
              
              print('⏰ Banner reklam $delaySeconds saniye sonra tekrar denenecek');
              _retryTimer = Timer(Duration(seconds: delaySeconds), () {
                if (!_isDisposed && mounted) {
                  _loadBannerAd();
                }
              });
            }
          },
          onAdOpened: (ad) {
            print('📱 Banner reklam açıldı: ${widget.placement}');
          },
          onAdClosed: (ad) {
            print('📱 Banner reklam kapatıldı: ${widget.placement}');
          },
        ),
      );

      _bannerAd!.load();
    } catch (e) {
      print('❌ Banner reklam oluşturma hatası (${widget.placement}): $e');
    }
  }

  /// Placeholder widget'ı
  Widget _buildPlaceholder() {
    if (!widget.showPlaceholder) return const SizedBox.shrink();

    String message = 'Reklam yükleniyor...';
    if (_retryCount > 0) {
      message = 'Reklam yeniden deneniyor... (${_retryCount}/$_maxRetries)';
    }

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _retryCount > _maxRetries 
              ? [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)]
              : [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _retryCount > _maxRetries 
              ? Colors.orange.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _retryCount <= _maxRetries 
              ? 'Reklam Yükleniyor... ($_retryCount/$_maxRetries)'
              : 'Reklam Yeniden Denenecek...',
          style: TextStyle(
            color: _retryCount > _maxRetries 
                ? Colors.orange.withOpacity(0.7)
                : Colors.blue.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Reklam container'ı
  Widget _buildAdContainer() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Premium kullanıcılar için reklamları gizle
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (premiumProvider.isPremiumUser) {
          return const SizedBox.shrink();
        }

        // Tam genişlik için SizedBox kullan
        return Container(
          width: double.infinity,
          margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
          child: _isLoaded && _bannerAd != null
              ? SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AdWidget(ad: _bannerAd!),
                )
              : Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _retryCount > _maxRetries 
                          ? [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)]
                          : [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _retryCount > _maxRetries 
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _retryCount <= _maxRetries 
                          ? 'Reklam Yükleniyor... ($_retryCount/$_maxRetries)'
                          : 'Reklam Yeniden Denenecek...',
                      style: TextStyle(
                        color: _retryCount > _maxRetries 
                            ? Colors.orange.withOpacity(0.7)
                            : Colors.blue.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    print('🗑️ SimpleBannerAd dispose ediliyor');
    _isDisposed = true;
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }
}
