import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../models/sound_item.dart';
import '../providers/audio_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'dart:async';

class TestVideoScreen extends StatefulWidget {
  final SoundItem sound;

  const TestVideoScreen({
    super.key,
    required this.sound,
  });

  @override
  State<TestVideoScreen> createState() => _TestVideoScreenState();
}

class _TestVideoScreenState extends State<TestVideoScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String _status = "Loading...";
  
  // Timer
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isDisposed = false;
  AudioProvider? _audioProvider;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Tam ekran mod
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Audio provider'ı hazırla ve PARALEL başlatma yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioProvider = Provider.of<AudioProvider>(context, listen: false);
      _startBothSimultaneously(); // İkisini birden başlat
    });
  }

  Future<void> _startBothSimultaneously() async {
    debugPrint('🎯 Starting BOTH audio and muted video simultaneously...');
    
    // Aynı anda ikisini de başlat (paralel execution)
    await Future.wait([
      _startSeparateAudio(),
      _startSeamlessChewieVideo(),
    ]);
    
    debugPrint('✅ BOTH started successfully - SEPARATE TRACKS!');
  }

  Future<void> _startSeparateAudio() async {
    try {
      debugPrint('🎵 Starting SEPARATE audio...');
      setState(() => _status = "Starting exclusive audio...");
      
      // Audio'yu başlat (video'dan TAMAMEN BAĞIMSIZ)
      _audioProvider!.playExclusive(widget.sound);
      debugPrint('🎵 Separate audio started successfully');
      debugPrint('🎧 Audio provider handles looping independently');
      
    } catch (e) {
      debugPrint('❌ Separate audio error: $e');
      throw e;
    }
  }

  Future<void> _startSeamlessChewieVideo() async {
    try {
      debugPrint('🎬 Starting SEAMLESS Chewie video...');
      setState(() => _status = "Creating Chewie controller...");
      
      // Video yolu kontrol et
      final videoPath = widget.sound.videoPath ?? 'assets/videos/rain_drop.mp4';
      debugPrint('📁 Video path: $videoPath');
      
      setState(() => _status = "Initializing VideoPlayerController...");
      
      // Create video player controller first
      _videoController = VideoPlayerController.asset(
        videoPath,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow mixing with separate audio
          allowBackgroundPlayback: true,
        ),
      );
      
      // Initialize video controller
      await _videoController!.initialize();
      debugPrint('✅ VideoPlayerController initialized');
      
      setState(() => _status = "Creating Chewie for seamless loops...");
      
      // ✨ CHEWIE configuration - SEAMLESS LOOPS!
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        
        // 🔄 SEAMLESS LOOPING - No black screens!
        looping: true,
        
        // 🔇 COMPLETELY MUTED for separate audio
        autoPlay: true,
        startAt: Duration.zero,
        // Volume handled by VideoPlayerController separately
        
        // 🎛️ Hide all controls - we handle them
        showControls: false,
        showControlsOnInitialize: false,
        
        // 🎯 Aspect ratio and display
        aspectRatio: _videoController!.value.aspectRatio,
        
        // 🚀 Performance optimizations for smooth playback
        allowFullScreen: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        
        // 📱 Platform optimizations
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.transparent,
          handleColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          bufferedColor: Colors.transparent,
        ),
        
        // 🔄 Error recovery for smooth loops
        errorBuilder: (context, errorMessage) {
          debugPrint('🔴 Chewie Error: $errorMessage');
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  SizedBox(height: 16),
                  Text('Video Error: $errorMessage', 
                       style: TextStyle(color: Colors.white70), 
                       textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      );
      
      // 🎵 MUTE video completely for separate audio
      await _videoController!.setVolume(0.0);
      
      setState(() => _status = "Chewie ready - seamless loops active!"); 
      debugPrint('✅ Chewie initialized with SEAMLESS looping');
      debugPrint('🔄 Looping: ON, Volume: 0.0, Controls: HIDDEN');
      debugPrint('🎵 Audio handled SEPARATELY - NO CONFLICTS!');
      debugPrint('🚀 SEAMLESS video loops - NO BLACK SCREENS!');
      
      setState(() => _isInitialized = true);
      
    } catch (e) {
      debugPrint('❌ Seamless Chewie error: $e');
      setState(() => _status = "Chewie Error: $e");
      throw e;
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

  void _togglePlayback() {
    if (_isDisposed || _audioProvider == null) return;
    
    debugPrint('🎛️ Toggle playback - Current state: ${_audioProvider!.isPlaying(widget.sound.id)}');
    
    if (_audioProvider!.isPlaying(widget.sound.id)) {
      debugPrint('⏸️ Pausing exclusive audio (Chewie continues)');
      _audioProvider!.pauseExclusive();
      _stopTimer();
    } else {
      // Eğer hiç başlatılmamışsa başlat, pause edilmişse resume et
      if (_audioProvider!.exclusiveSound?.id == widget.sound.id && 
          _audioProvider!.isPaused(widget.sound.id)) {
        debugPrint('▶️ Resuming exclusive audio (Chewie continues)');
        _audioProvider!.resumeExclusive();
      } else {
        debugPrint('🎵 Starting exclusive audio for first time (Chewie continues)');
        _audioProvider!.playExclusive(widget.sound);
      }
      _startTimer();
    }
    
    HapticFeedback.mediumImpact();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _exit() async {
    _isDisposed = true;
    _stopTimer();
    _audioProvider?.stopAllSounds();
    
    // Dispose Chewie first
    if (_chewieController != null) {
      await _chewieController!.pause();
      _chewieController!.dispose();
      _chewieController = null;
    }
    
    // Then dispose video controller
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimer();
    
    // Dispose controllers in correct order
    _chewieController?.dispose();
    _videoController?.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isPlaying = audioProvider.isPlaying(widget.sound.id) &&
                          audioProvider.exclusiveSound?.id == widget.sound.id;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Chewie Video tam ekran - SEAMLESS LOOPS! 🔄
              if (_isInitialized && _chewieController != null)
                Positioned.fill(
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ),

              // Content overlay - Merkez
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer
                      Text(
                        _formatDuration(_elapsed),
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 64,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sound name
                      Text(
                        widget.sound.name,
                        style: AppTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        widget.sound.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Play/Pause Button - Alt merkez
              Positioned(
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
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
              ),

              // Status overlay (sol üst)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Exit button (sağ üst)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: _exit,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: const Icon(
                      FeatherIcons.x,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 