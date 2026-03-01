import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:async';
import '../models/sound_item.dart';
import '../providers/audio_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../core/ads/ad_manager.dart';
import '../utils/performance_utils.dart';
import '../providers/premium_provider.dart';

class ImmersiveSoundPlayerScreen extends StatefulWidget {
  final SoundItem sound;

  const ImmersiveSoundPlayerScreen({
    super.key,
    required this.sound,
  });

  @override
  State<ImmersiveSoundPlayerScreen> createState() => _ImmersiveSoundPlayerScreenState();
}

class _ImmersiveSoundPlayerScreenState extends State<ImmersiveSoundPlayerScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Yavaş zoom animasyonu (nefes gibi)
  late AnimationController _breathController;
  late Animation<double> _zoomAnimation;
  late Animation<double> _overlayAnimation;
  
  // Timer
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  
  // Timer limit (0 = sonsuz)
  int _timerMinutes = 0;
  static const List<int> _timerOptions = [0, 5, 15, 30, 60];
  
  // Auto-hide kontroller
  bool _controlsVisible = true;
  Timer? _hideTimer;
  
  // State Management
  bool _isDisposed = false;
  AudioProvider? _audioProvider;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeScreen();
      }
    });
  }

  void _setupAnimations() {
    // Fade animation - giriş/çıkış
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Yavaş nefes animasyonu — 12 saniyelik döngü
    _breathController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    // Hafif zoom: 1.0 → 1.08 (neredeyse fark edilmez ama canlılık katar)
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    // Gradient overlay opacity geçişi
    _overlayAnimation = Tween<double>(begin: 0.3, end: 0.55).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }

  Future<void> _initializeScreen() async {
    if (_isDisposed) return;
    
    // 🚀 Start performance monitoring
    PerformanceMonitor.instance.startMonitoring();
    
    // Set immersive mode
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Start animations
    _fadeController.forward();
    _breathController.repeat(reverse: true);
    
    // 🎯 Preload Ad
    if (mounted) {
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      if (!premiumProvider.canAccessFeature('ad_free')) {
        AdManager.instance.preloadInterstitial(placement: 'sound_session_complete');
      }
    }
    
    // Start audio and timer
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isDisposed) {
      PerformanceMonitor.instance.trackAudioStart(widget.sound.id);
      _startAudio();
      _startTimer();
      _scheduleHideControls();
    }
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isDisposed) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleHideControls();
  }

  void _startAudio() {
    if (_isDisposed) return;
    
    _audioProvider!.playExclusive(widget.sound);
    
    // Verify audio is working
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_audioProvider != null && !_isDisposed) {
        final isPlaying = _audioProvider!.isPlaying(widget.sound.id);
        
        if (!isPlaying) {
          _restartAudio();
        }
      }
    });
  }
  
  void _restartAudio() {
    _audioProvider!.stopAllSounds().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_audioProvider != null && !_isDisposed) {
          _audioProvider!.playExclusive(widget.sound);
        }
      });
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposed) {
        setState(() {
          _elapsed = Duration(seconds: timer.tick);
        });
        // Timer limiti kontrolü
        if (_timerMinutes > 0 && _elapsed.inSeconds >= _timerMinutes * 60) {
          _exitScreen();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _stopHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _togglePlayback() async {
    if (_isDisposed) return;
    
    bool isCurrentlyPlaying = _audioProvider!.isPlaying(widget.sound.id);
    
    HapticFeedback.mediumImpact();
    
    if (isCurrentlyPlaying) {
      await _audioProvider!.pauseExclusive();
      _breathController.stop();
      _stopTimer();
    } else {
      await _audioProvider!.resumeExclusive();
      _breathController.repeat(reverse: true);
      _startTimer();
    }
  }

  Future<void> _exitScreen() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    // 📊 Record sound session to statistics
    if (_elapsed.inMinutes > 0 && mounted) {
      try {
        final userPrefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);
        userPrefsProvider.recordSoundSession(_elapsed.inMinutes);
      } catch (e) {
        // Hata sessizce yoksayılır
      }
    }
    
    // 🎯 Çıkışta interstitial reklam göster (2dk+ dinleme VEYA 3. oturum)
    if (mounted) {
      try {
        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
        
        // 1. Süre kontrolü
        final durationThresholdMet = _elapsed >= AudioProvider.soundInterstitialThreshold;
        
        // 2. Oturum sayısı kontrolü (Şimdiki oturumu da saymak için +1)
        final sessionCount = audioProvider.sessionCount + 1;
        final sessionThresholdMet = sessionCount > 0 && (sessionCount % AudioProvider.sessionCountThreshold == 0);
        
        if (kDebugMode){
          print('Ad Logic Check:');
          print('- Duration: ${_elapsed.inSeconds}s >= ${AudioProvider.soundInterstitialThreshold.inSeconds}s -> $durationThresholdMet');
          print('- Session (current included): $sessionCount % ${AudioProvider.sessionCountThreshold} == 0 -> $sessionThresholdMet');
        }

        if (!premiumProvider.canAccessFeature('ad_free') && 
            (audioProvider.shouldShowExitInterstitial || durationThresholdMet || sessionThresholdMet)) {
          audioProvider.consumeExitInterstitial();
          await AdManager.instance.showInterstitial(placement: 'sound_session_complete');
        }
      } catch (e) {
        // Hata sessizce yoksayılır
      }
    }
    
    // 📊 Stop performance monitoring
    PerformanceMonitor.instance.trackAudioEnd(widget.sound.id);
    PerformanceMonitor.instance.stopMonitoring();
    
    // Stop everything - hızlı kapatma
    _stopTimer();
    
    // Paralel: Ses + ekran animasyonu aynı anda
    await Future.wait([
      _audioProvider!.stopAllSounds(),
      _fadeController.reverse(),
    ]);
    
    // Restore system UI
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    _stopTimer();
    _stopHideTimer();
    
    // Dispose animations
    _breathController.dispose();
    _fadeController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        bool isPlaying = audioProvider.isPlaying(widget.sound.id);

        return WillPopScope(
          onWillPop: () async {
            await _exitScreen();
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: _showControls,
              behavior: HitTestBehavior.opaque,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    // Background Layer - Sadece statik resim
                    _buildBackgroundLayer(),
                    
                    // Dark overlay with breathing animation
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _overlayAnimation,
                        builder: (context, _) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(_overlayAnimation.value),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(_overlayAnimation.value + 0.25),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Content Layer (top bar + timer + controls hepsi içinde)
                    _buildContentLayer(isPlaying),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundLayer() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _zoomAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _zoomAnimation.value,
            child: child,
          );
        },
        child: Image.asset(
          widget.sound.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.sound.color.withOpacity(0.6),
                    widget.sound.color.withOpacity(0.9),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentLayer(bool isPlaying) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Positioned.fill(
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: Column(
              children: [
                // Üst bar: Geri + Başlık + Favori
                _buildTopBar(),
                
                const Spacer(flex: 3),
                
                // Ses adı + açıklama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        widget.sound.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          shadows: [
                            const Shadow(blurRadius: 8, color: Colors.black54),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.sound.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Timer
                _buildCenterContent(isPlaying),
                
                const Spacer(flex: 2),
                
                // Alt kontroller: Timer + Play/Pause
                _buildBottomControls(isPlaying),
                
                SizedBox(height: bottomPad + 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: _exitScreen,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: const Icon(FeatherIcons.chevronDown, color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          // Timer badge
          if (_timerMinutes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FeatherIcons.clock, color: AppColors.primaryAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_timerMinutes dk',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          // Favori butonu
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, _) {
              final isFav = userPrefs.isFavoriteSound(widget.sound.id);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  userPrefs.toggleFavoriteSound(widget.sound.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent(bool isPlaying) {
    // Timer kalan süre
    String timerLabel = '';
    if (_timerMinutes > 0) {
      final remaining = Duration(seconds: (_timerMinutes * 60) - _elapsed.inSeconds);
      if (remaining.inSeconds > 0) {
        timerLabel = _formatDuration(remaining);
      }
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Büyük timer
          Text(
            _formatDuration(_elapsed),
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w200,
              fontSize: 56,
              letterSpacing: 4,
            ),
          ),
          // Kalan süre (timer aktifse)
          if (timerLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '-$timerLabel kaldı',
              style: TextStyle(
                color: AppColors.primaryAccent.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls(bool isPlaying) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Timer butonu (sol alt köşe)
          GestureDetector(
            onTap: () {
              _showTimerPicker();
              _scheduleHideControls();
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(_timerMinutes > 0 ? 0.2 : 0.1),
              ),
              child: Icon(
                FeatherIcons.clock,
                color: _timerMinutes > 0 ? AppColors.primaryAccent : Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Play/Pause butonu (orta)
          GestureDetector(
            onTap: () {
              _togglePlayback();
              _scheduleHideControls();
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Icon(
                isPlaying ? FeatherIcons.pause : FeatherIcons.play,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Simetri için görünmez alan
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  void _showTimerPicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Zamanlayıcı',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timerOptions.map((minutes) {
                  final isSelected = _timerMinutes == minutes;
                  final label = minutes == 0 ? '∞' : '$minutes dk';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _timerMinutes = minutes);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 72,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.primaryAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : Colors.white.withOpacity(0.15),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryAccent : Colors.white.withOpacity(0.8),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
