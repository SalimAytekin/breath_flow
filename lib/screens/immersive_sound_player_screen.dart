import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math';
import '../models/sound_item.dart';
import '../providers/audio_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../utils/performance_utils.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  // Chewie Player - SEAMLESS LOOPS! 🔄
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasVideo = false;
  bool _lastVideoPlayingState = false;
  bool _videoNearEndLogged = false;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;
  
  // Timer
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  
  // State Management
  bool _isDisposed = false;
  AudioProvider? _audioProvider;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkVideoAvailability();
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeScreen();
      }
    });
  }

  void _checkVideoAvailability() {
    _hasVideo = widget.sound.videoPath != null;
    
    if (_hasVideo) {
      debugPrint('🎬 Video detected for ${widget.sound.name}: ${widget.sound.videoPath}');
    } else {
      debugPrint('📷 No video for ${widget.sound.name} - using animated background');
    }
  }

  void _setupAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (_chewieController != null) {
      if (state == AppLifecycleState.resumed) {
        // ✅ Resume video when app comes to foreground
        if (!_isDisposed && mounted) {
          _chewieController!.play();
          debugPrint('✅ Chewie video resumed on app foreground');
        }
      } else if (state == AppLifecycleState.paused) {
        // Pause video when app goes to background
        _chewieController!.pause();
        debugPrint('📱 Chewie video paused on app background');
      }
    }
  }

  Future<void> _initializeScreen() async {
    if (_isDisposed) return;
    
    // 🚀 Start performance monitoring
    PerformanceMonitor.instance.startMonitoring();
    
    // Set immersive mode
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Initialize video if available - CHEWIE SEAMLESS!
    if (_hasVideo) {
      PerformanceMonitor.instance.trackVideoStart(widget.sound.videoPath!);
      await _initializeChewieVideo();
    }
    
    // Start animations
    _fadeController.forward();
    _backgroundController.repeat(reverse: true);
    
    // Start audio and timer
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isDisposed) {
      PerformanceMonitor.instance.trackAudioStart(widget.sound.id);
      _startAudio();
      _startTimer();
    }
  }

  Future<void> _initializeChewieVideo() async {
    if (_isDisposed || !_hasVideo) return;
    
    try {
      debugPrint('🎬 Initializing CHEWIE video: ${widget.sound.videoPath}');
      
      // Create video player controller first with SEAMLESS loop optimization
      _videoPlayerController = VideoPlayerController.asset(
        widget.sound.videoPath!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow mixing with audio
          allowBackgroundPlayback: true,
        ),
      );
      
      // 🚀 AGGRESSIVE preloading for seamless loops
      _videoPlayerController!.setLooping(true);
      
      // Add video state listener for performance monitoring
      _videoPlayerController!.addListener(_videoStateListener);
      
      // Initialize video controller with BUFFER PRE-LOADING
      await _videoPlayerController!.initialize();
      
      // 🔄 AGGRESSIVE BUFFERING for seamless loops
      await _videoPlayerController!.seekTo(Duration.zero);
      await _videoPlayerController!.play();
      await Future.delayed(Duration(milliseconds: 100)); // Allow initial buffering
      await _videoPlayerController!.pause();
      await _videoPlayerController!.seekTo(Duration.zero);
      
      debugPrint('✅ VideoPlayerController initialized with BUFFER PRE-LOAD');
      debugPrint('   📏 Duration: ${_videoPlayerController!.value.duration}');
      debugPrint('   📐 Size: ${_videoPlayerController!.value.size}');
      debugPrint('   📱 Aspect: ${_videoPlayerController!.value.aspectRatio.toStringAsFixed(2)}');
      debugPrint('   🔄 Loop pre-buffered for SEAMLESS playback');
      
      // ✨ CHEWIE configuration for SEAMLESS looping
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        
        // 🔄 SEAMLESS LOOPING - Key feature!
        looping: true,
        
        // 🔇 MUTED for separate audio handling
        autoPlay: true,
        startAt: Duration.zero,
        
        // 🎛️ Hide all controls - we handle them
        showControls: false,
        showControlsOnInitialize: false,
        
        // 🎯 FULL SCREEN aspect ratio - use video's natural ratio
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        
        // 🚀 ANTI-BLACK SCREEN optimizations
        allowFullScreen: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        
                 // 🎵 Volume handled by VideoPlayerController separately
        
        // 📱 SEAMLESS LOOP optimizations
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.transparent,
          handleColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          bufferedColor: Colors.transparent,
        ),
        
        // 🔄 ENHANCED error recovery for smooth loops
        errorBuilder: (context, errorMessage) {
          debugPrint('🔴 Chewie Error: $errorMessage');
          // Don't show error - return transparent container to avoid black screen
          return Container(
            color: Colors.transparent,
            child: Center(
              child: Icon(
                Icons.refresh,
                color: Colors.white24,
                size: 48,
              ),
            ),
          );
        },
        
        // 🎯 BUFFER MANAGEMENT for seamless loops
        placeholder: Container(
          color: Colors.transparent, // NO BLACK PLACEHOLDER
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          ),
        ),
      );
      
      // 🎵 MUTE video completely for separate audio
      await _videoPlayerController!.setVolume(0.0);
      
      debugPrint('✅ Chewie initialized with SEAMLESS looping');
      debugPrint('🔄 Looping: ON, Volume: 0.0, Controls: HIDDEN');
      debugPrint('🎵 Audio handled separately - NO CONFLICTS!');
      debugPrint('🚀 SEAMLESS video loops - NO BLACK SCREENS!');
      
      if (!_isDisposed && mounted) {
        setState(() {}); // Trigger rebuild to show video
      }
      
    } catch (e) {
      debugPrint('❌ Chewie video setup error: $e');
      debugPrint('📁 Video path was: ${widget.sound.videoPath}');
      debugPrint('🎵 Sound name: ${widget.sound.name}');
      // Continue without video - graceful fallback
    }
  }

  void _videoStateListener() {
    if (_videoPlayerController != null && !_isDisposed) {
      final value = _videoPlayerController!.value;
      
      if (value.hasError) {
        debugPrint('🔴 Video Error: ${value.errorDescription}');
        PerformanceMonitor.instance.trackVideoStutter(widget.sound.videoPath!, 500); // Major error
      }
      
      if (value.isPlaying != _lastVideoPlayingState) {
        _lastVideoPlayingState = value.isPlaying;
        debugPrint('🎬 Chewie playing state changed: ${value.isPlaying}');
        
        if (!value.isPlaying && value.position >= value.duration && value.duration > Duration.zero) {
          debugPrint('🔄 Video finished, Chewie handles seamless restart...');
        }
      }
      
      // Position tracking for seamless loop monitoring
      final position = value.position;
      final duration = value.duration;
      if (duration > Duration.zero) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        
        // Near end detection (95% complete)
        if (progress > 0.95 && !_videoNearEndLogged) {
          debugPrint('⏰ Chewie near end: ${position.inSeconds}s / ${duration.inSeconds}s - PREPARING LOOP');
          _videoNearEndLogged = true;
        }
        
        // Loop restart detection (back to beginning)
        if (progress < 0.05 && _videoNearEndLogged) {
          debugPrint('🔄 Chewie SEAMLESS loop restart detected! NO BLACK SCREEN!');
          _videoNearEndLogged = false; // Reset for next loop
        }
      }
      
      // Monitor for buffering (indicates potential stutters)
      if (value.isBuffering) {
        debugPrint('⏳ Chewie buffering... (${(value.position.inMilliseconds / value.duration.inMilliseconds * 100).toStringAsFixed(1)}%)');
        PerformanceMonitor.instance.trackVideoStutter(widget.sound.videoPath!, 100);
      }
      
      // Monitor for initialization state
      if (value.isInitialized && !value.hasError) {
        // Video is ready and healthy
        if (value.isPlaying && !value.isBuffering) {
          // Perfect playback state
        }
      }
    }
  }

  void _startAudio() {
    if (_audioProvider != null && !_isDisposed) {
      debugPrint('🎵 === STARTING AUDIO DEBUG ===');
      debugPrint('🎵 Sound ID: ${widget.sound.id}');
      debugPrint('🎵 Sound Name: ${widget.sound.name}');
      debugPrint('🎵 Sound Asset Path: ${widget.sound.assetPath}');
      debugPrint('🎵 Audio Provider State: ${_audioProvider != null ? 'Available' : 'NULL'}');
      
      try {
        _audioProvider!.playExclusive(widget.sound);
        debugPrint('✅ Audio playExclusive called successfully');
        
        // Verify audio is actually playing after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (_audioProvider != null && !_isDisposed) {
            final isPlaying = _audioProvider!.isPlaying(widget.sound.id);
            final exclusiveSound = _audioProvider!.exclusiveSound;
            final playerState = _audioProvider!.exclusivePlayerState;
            
            debugPrint('🔍 === AUDIO VERIFICATION ===');
            debugPrint('🔍 Is Playing: $isPlaying');
            debugPrint('🔍 Exclusive Sound: ${exclusiveSound?.name ?? 'NULL'}');
            debugPrint('🔍 Player State: $playerState');
            debugPrint('🔍 Master Volume: ${_audioProvider!.masterVolume}');
            debugPrint('🔍 Sound Volume: ${_audioProvider!.getVolume(widget.sound.id)}');
            
            if (!isPlaying) {
              debugPrint('🚨 AUDIO NOT PLAYING! Attempting restart...');
              _restartAudio();
            }
          }
        });
      } catch (e) {
        debugPrint('❌ Error starting audio: $e');
      }
    } else {
      debugPrint('❌ Cannot start audio - provider disposed or null');
    }
  }
  
  void _restartAudio() {
    debugPrint('🔄 Restarting audio...');
    if (_audioProvider != null && !_isDisposed) {
      // Stop and restart
      _audioProvider!.stopAllSounds().then((_) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (_audioProvider != null && !_isDisposed) {
            _audioProvider!.playExclusive(widget.sound);
            debugPrint('🔄 Audio restart attempted');
          }
        });
      });
    }
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
    if (_isDisposed || _audioProvider == null) return;
    
    // Check both playing state and exclusive sound
    final isCurrentlyPlaying = _audioProvider!.isPlaying(widget.sound.id) && 
                              _audioProvider!.exclusiveSound?.id == widget.sound.id &&
                              _audioProvider!.exclusivePlayerState == PlayerState.playing;
    
    debugPrint('🎛️ Toggle playback - Currently playing: $isCurrentlyPlaying');
    debugPrint('🎛️ Audio state: ${_audioProvider!.exclusivePlayerState}');
    debugPrint('🎛️ Exclusive sound: ${_audioProvider!.exclusiveSound?.name}');
    
    // 🎯 IMMEDIATE haptic feedback for responsiveness
    HapticFeedback.mediumImpact();
    
    if (isCurrentlyPlaying) {
      // PAUSE: Audio + Video (NON-BLOCKING)
      debugPrint('⏸️ Pausing audio + chewie video');
      
      // Audio pause (sync)
      _audioProvider!.pauseExclusive();
      _stopTimer();
      _backgroundController.stop();
      
      // Video pause (async - don't block UI)
      if (_hasVideo && _chewieController != null) {
        _chewieController!.pause();
        debugPrint('⏸️ Chewie paused');
      }
    } else {
      // PLAY/RESTART: Audio + Video (OPTIMIZED)
      if (_audioProvider!.exclusiveSound?.id != widget.sound.id) {
        // Start fresh if not the current exclusive sound
        debugPrint('▶️ Starting fresh audio + chewie video');
        _audioProvider!.playExclusive(widget.sound);
      } else {
        // Resume if paused
        debugPrint('▶️ Resuming audio + chewie video');
      _audioProvider!.resumeExclusive();
      }
      
      _startTimer();
      _backgroundController.repeat(reverse: true);
      
      // Video resume (async - don't block UI)
      if (_hasVideo && _chewieController != null) {
        // 🚀 BUFFERED resume for smooth playback
        _chewieController!.play();
        debugPrint('▶️ Chewie resumed - seamless loop continues');
      }
    }
  }

  Future<void> _exitScreen() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    // 📊 Stop performance monitoring and report results
    PerformanceMonitor.instance.trackAudioEnd(widget.sound.id);
    if (_hasVideo) {
      PerformanceMonitor.instance.trackVideoEnd(widget.sound.videoPath!);
    }
    PerformanceMonitor.instance.stopMonitoring();
    
    // Stop everything
    _stopTimer();
    _audioProvider?.stopAllSounds();
    
    // Safely stop and dispose Chewie
    if (_chewieController != null) {
      try {
        await _chewieController!.pause();
        _chewieController!.dispose();
        debugPrint('✅ Chewie controller disposed safely');
      } catch (e) {
        debugPrint('❌ Chewie dispose error: $e');
      }
      _chewieController = null;
    }
    
    // Dispose video controller
    if (_videoPlayerController != null) {
      try {
        _videoPlayerController!.removeListener(_videoStateListener);
        await _videoPlayerController!.dispose();
        debugPrint('✅ VideoPlayerController disposed safely');
      } catch (e) {
        debugPrint('❌ VideoPlayerController dispose error: $e');
      }
      _videoPlayerController = null;
    }
    
    // Animate out
    await _fadeController.reverse();
    
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
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Stop timer first
    _stopTimer();
    
    // Safely dispose Chewie
    if (_chewieController != null) {
      try {
        _chewieController!.dispose();
        debugPrint('✅ Chewie controller disposed safely');
      } catch (e) {
        debugPrint('❌ Chewie dispose error: $e');
      }
      _chewieController = null;
    }
    
    // Dispose video controller
    if (_videoPlayerController != null) {
      try {
        _videoPlayerController!.removeListener(_videoStateListener);
        _videoPlayerController!.dispose();
        debugPrint('✅ VideoPlayerController disposed safely');
      } catch (e) {
        debugPrint('❌ VideoPlayerController dispose error: $e');
      }
      _videoPlayerController = null;
    }
    
    // Dispose animations
    _fadeController.dispose();
    _backgroundController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isPlaying = audioProvider.isPlaying(widget.sound.id) &&
                          audioProvider.exclusiveSound?.id == widget.sound.id;

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
                  // Background Layer
                  _buildBackgroundLayer(),
                  
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
      child: Stack(
        children: [
          // Chewie Video (if available) - SEAMLESS LOOPS! 🔄
          if (_hasVideo && _chewieController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover, // FULL SCREEN - crop to fill
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ),
              ),
            ),
          // Animated background (only when no video or as overlay)
          if (!(_hasVideo && _chewieController != null))
            _buildAnimatedBackground(),
          // Dark overlay for readability (sadece video yoksa uygula)
          if (!(_hasVideo && _chewieController != null))
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
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
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
      builder: (context, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: _hasVideo && 
                     _chewieController != null ? 0.1 : 0.8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(_backgroundAnimation.value * 2 * pi),
                  colors: [
                    widget.sound.color.withOpacity(0.3),
                    widget.sound.color.withOpacity(0.6),
                    widget.sound.color.withOpacity(0.4),
                    widget.sound.color.withOpacity(0.8),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentLayer(bool isPlaying) {
    return Positioned.fill(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_elapsed),
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                widget.sound.name,
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                widget.sound.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
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
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 80,
            height: 80,
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
              size: 32,
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