import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:async';
import '../models/sound_item.dart';
import '../providers/seamless_audio_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
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
    with SingleTickerProviderStateMixin {
  
  // Animation Controller - Sadece fade için
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Timer
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  
  // State Management
  bool _isDisposed = false;
  SeamlessAudioProvider? _seamlessProvider;

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
    // Sadece fade animation - geçiş için
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300), // Hızlı çıkış
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _seamlessProvider = Provider.of<SeamlessAudioProvider>(context, listen: false);
  }

  Future<void> _initializeScreen() async {
    if (_isDisposed) return;
    
    // 🚀 Start performance monitoring
    PerformanceMonitor.instance.startMonitoring();
    
    // Set immersive mode
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Start fade animation
    _fadeController.forward();
    
    // Start audio and timer
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isDisposed) {
      PerformanceMonitor.instance.trackAudioStart(widget.sound.id);
      _startAudio();
      _startTimer();
    }
  }

  void _startAudio() {
    if (_isDisposed) return;
    
    _seamlessProvider!.playSeamlessLoop(widget.sound);
    
    // Verify seamless audio is working
    Future.delayed(Duration(milliseconds: 500), () {
      if (_seamlessProvider != null && !_isDisposed) {
        final isPlaying = _seamlessProvider!.isPlaying(widget.sound.id);
        
        if (!isPlaying) {
          _restartAudio();
        }
      }
    });
  }
  
  void _restartAudio() {
    _seamlessProvider!.stopAllSounds().then((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_seamlessProvider != null && !_isDisposed) {
          _seamlessProvider!.playSeamlessLoop(widget.sound);
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
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _togglePlayback() async {
    if (_isDisposed) return;
    
    bool isCurrentlyPlaying = _seamlessProvider!.isPlaying(widget.sound.id);
    
    // 🎯 IMMEDIATE haptic feedback for responsiveness
    HapticFeedback.mediumImpact();
    
    if (isCurrentlyPlaying) {
      _seamlessProvider!.pause(widget.sound.id, withFade: true);
      _stopTimer();
    } else {
      _seamlessProvider!.resume(widget.sound.id, withFade: true);
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
        
        // 🎯 Ses oturumu sonrası interstitial reklam göster
        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
        if (!premiumProvider.canAccessFeature('ad_free')) {
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
      _seamlessProvider!.stopAllSounds(withFade: true),
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
    
    // Dispose animations
    _fadeController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SeamlessAudioProvider>(
      builder: (context, seamlessProvider, child) {
        bool isPlaying = seamlessProvider.isPlaying(widget.sound.id);

        return WillPopScope(
          onWillPop: () async {
            await _exitScreen();
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Background Layer - Sadece statik resim
                  _buildBackgroundLayer(),
                  
                  // Dark overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Content Layer
                  _buildContentLayer(isPlaying),
                  
                  // Controls Layer
                  _buildControlsLayer(isPlaying),
                  
                  // Exit Button
                  _buildExitButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundLayer() {
    return Positioned.fill(
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
    );
  }

  Widget _buildContentLayer(bool isPlaying) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Positioned.fill(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_elapsed),
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: isSmallScreen ? 48 : 64,
                ),
              ),
              SizedBox(height: isSmallScreen ? AppSpacing.small : AppSpacing.medium),
              Text(
                widget.sound.name,
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 20 : 24,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 8 : AppSpacing.small),
              Text(
                widget.sound.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isSmallScreen ? 13 : 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsLayer(bool isPlaying) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Positioned(
      bottom: isSmallScreen ? 100 : 120,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: isSmallScreen ? 70 : 80,
            height: isSmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? FeatherIcons.pause : FeatherIcons.play,
              color: Colors.white,
              size: isSmallScreen ? 28 : 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: GestureDetector(
        onTap: _exitScreen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            FeatherIcons.x,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
