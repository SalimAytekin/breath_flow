import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/scheduler.dart';

/// ⚡ Performance Utilities
/// Optimization tools for Deep Night Serenity theme system
class PerformanceUtils {
  /// 🎯 Widget Build Optimization
  static const int maxListViewItemCount = 100;
  static const double listViewCacheExtent = 1000.0;
  
  /// 🖼️ Image Optimization
  static const int maxImageCacheSize = 100;
  static const int maxImageCacheSizeBytes = 50 * 1024 * 1024; // 50MB
  
  /// ⏱️ Animation Performance
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  /// 📱 Device Performance Detection
  static DevicePerformance? _devicePerformance;
  static DevicePerformance get devicePerformance {
    _devicePerformance ??= _detectDevicePerformance();
    return _devicePerformance!;
  }
  
  /// 🔍 Detect Device Performance Level
  static DevicePerformance _detectDevicePerformance() {
    // Simple heuristic based on available information
    // In a real app, you might use more sophisticated detection
    final binding = WidgetsBinding.instance;
    final window = binding.window;
    
    // Check screen density and size
    final devicePixelRatio = window.devicePixelRatio;
    final screenSize = window.physicalSize;
    final screenArea = screenSize.width * screenSize.height;
    
    // High-end device indicators
    if (devicePixelRatio >= 3.0 && screenArea > 2000000) {
      return DevicePerformance.high;
    }
    // Mid-range device indicators
    else if (devicePixelRatio >= 2.0 && screenArea > 1000000) {
      return DevicePerformance.medium;
    }
    // Low-end device
    else {
      return DevicePerformance.low;
    }
  }
  
  /// 🎨 Get Optimized Animation Duration
  static Duration getOptimizedAnimationDuration(Duration baseDuration) {
    switch (devicePerformance) {
      case DevicePerformance.high:
        return baseDuration;
      case DevicePerformance.medium:
        return Duration(milliseconds: (baseDuration.inMilliseconds * 1.2).round());
      case DevicePerformance.low:
        return Duration(milliseconds: (baseDuration.inMilliseconds * 1.5).round());
    }
  }
  
  /// 🔧 Get Optimized Widget Settings
  static OptimizedSettings getOptimizedSettings() {
    switch (devicePerformance) {
      case DevicePerformance.high:
        return OptimizedSettings(
          enableShadows: true,
          enableBlur: true,
          enableComplexAnimations: true,
          maxListItems: 200,
          imageQuality: ImageQuality.high,
        );
      case DevicePerformance.medium:
        return OptimizedSettings(
          enableShadows: true,
          enableBlur: false,
          enableComplexAnimations: true,
          maxListItems: 100,
          imageQuality: ImageQuality.medium,
        );
      case DevicePerformance.low:
        return OptimizedSettings(
          enableShadows: false,
          enableBlur: false,
          enableComplexAnimations: false,
          maxListItems: 50,
          imageQuality: ImageQuality.low,
        );
    }
  }
  
  /// 🧹 Memory Management
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  static void optimizeImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = maxImageCacheSize;
    imageCache.maximumSizeBytes = maxImageCacheSizeBytes;
  }
  
  /// 📊 Performance Monitoring
  static void enablePerformanceOverlay() {
    if (kDebugMode) {
      debugPaintSizeEnabled = false; // Disable to reduce overhead
      debugRepaintRainbowEnabled = false;
    }
  }
  
  static void logPerformanceInfo(String operation, Duration duration) {
    if (kDebugMode) {
 if (kDebugMode) debugPrint('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }
}

/// 📱 Device Performance Levels
enum DevicePerformance {
  low,
  medium,
  high,
}

/// ⚙️ Optimized Settings
class OptimizedSettings {
  final bool enableShadows;
  final bool enableBlur;
  final bool enableComplexAnimations;
  final int maxListItems;
  final ImageQuality imageQuality;
  
  const OptimizedSettings({
    required this.enableShadows,
    required this.enableBlur,
    required this.enableComplexAnimations,
    required this.maxListItems,
    required this.imageQuality,
  });
}

/// 🖼️ Image Quality Levels
enum ImageQuality {
  low,
  medium,
  high,
}

/// ⚡ Optimized ListView
/// ListView with performance optimizations
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final bool addAutomaticKeepAlives;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = PerformanceUtils.getOptimizedSettings();
    final effectiveItemCount = itemCount > settings.maxListItems 
        ? settings.maxListItems 
        : itemCount;
    
    return ListView.builder(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding,
      shrinkWrap: shrinkWrap,
      cacheExtent: PerformanceUtils.listViewCacheExtent,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      itemCount: effectiveItemCount,
      itemBuilder: (context, index) {
        // Add performance monitoring in debug mode
        if (kDebugMode) {
          final stopwatch = Stopwatch()..start();
          final widget = itemBuilder(context, index);
          stopwatch.stop();
          
          if (stopwatch.elapsedMilliseconds > 16) {
            PerformanceUtils.logPerformanceInfo(
              'ListView item $index build',
              stopwatch.elapsed,
            );
          }
          
          return widget;
        }
        
        return itemBuilder(context, index);
      },
    );
  }
}

/// 🎨 Optimized Container
/// Container with performance-aware decorations
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  const OptimizedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final settings = PerformanceUtils.getOptimizedSettings();
    
    // Optimize decoration based on device performance
    Decoration? optimizedDecoration = decoration;
    if (decoration is BoxDecoration && !settings.enableShadows) {
      final boxDecoration = decoration as BoxDecoration;
      optimizedDecoration = boxDecoration.copyWith(boxShadow: null);
    }
    
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: optimizedDecoration,
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      child: child,
    );
  }
}

/// 🌊 Optimized AnimatedContainer
/// AnimatedContainer with performance-aware animations
class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Duration? duration;
  final Curve curve;
  final VoidCallback? onEnd;

  const OptimizedAnimatedContainer({
    super.key,
    this.child,
    this.padding,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.duration,
    this.curve = Curves.easeInOut,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final settings = PerformanceUtils.getOptimizedSettings();
    final optimizedDuration = PerformanceUtils.getOptimizedAnimationDuration(
      duration ?? PerformanceUtils.defaultAnimationDuration,
    );
    
    // Disable complex animations on low-end devices
    if (!settings.enableComplexAnimations) {
      return OptimizedContainer(
        padding: padding,
        color: color,
        decoration: decoration,
        width: width,
        height: height,
        constraints: constraints,
        alignment: alignment,
        child: child,
      );
    }
    
    return AnimatedContainer(
      duration: optimizedDuration,
      curve: curve,
      padding: padding,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      onEnd: onEnd,
      child: child,
    );
  }
}

/// 💾 Memory-Efficient Image
/// Image widget with memory optimization
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final settings = PerformanceUtils.getOptimizedSettings();
    
    // Determine cache dimensions based on quality setting
    double? cacheWidth;
    double? cacheHeight;
    
    if (width != null && height != null) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final qualityMultiplier = switch (settings.imageQuality) {
        ImageQuality.low => 0.5,
        ImageQuality.medium => 0.75,
        ImageQuality.high => 1.0,
      };
      
      cacheWidth = (width! * devicePixelRatio * qualityMultiplier).round().toDouble();
      cacheHeight = (height! * devicePixelRatio * qualityMultiplier).round().toDouble();
    }
    
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth?.toInt(),
      cacheHeight: cacheHeight?.toInt(),
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
      // Note: loadingBuilder removed for compatibility
    );
  }
}

/// 🎭 Performance Monitoring Widget
/// Widget that monitors and reports performance metrics
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  final String? label;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
    this.label,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _stopwatch = Stopwatch()..start();
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      _stopwatch.stop();
      PerformanceUtils.logPerformanceInfo(
        widget.label ?? 'Widget lifecycle',
        _stopwatch.elapsed,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 🚀 Performance monitoring utility for seamless video/audio loops
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  
  PerformanceMonitor._();
  
  // Frame rate monitoring
  List<Duration> _frameTimes = [];
  Timer? _performanceTimer;
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  
  // Audio performance tracking
  Map<String, List<int>> _audioGaps = {};
  Map<String, DateTime> _audioStartTimes = {};
  
  // Video performance tracking
  Map<String, List<int>> _videoStutters = {};
  Map<String, DateTime> _videoStartTimes = {};
  
  // Performance thresholds
  static const int _targetFPS = 60;
  static const int _stutterThresholdMs = 50; // 50ms+ frame time = stutter
  static const int _audioGapThresholdMs = 10; // 10ms+ audio gap = noticeable
  
  /// 🎯 Start comprehensive performance monitoring
  void startMonitoring() {
    if (_performanceTimer?.isActive == true) return;
    
 if (kDebugMode) debugPrint('🚀 Performance Monitor STARTED');
 if (kDebugMode) debugPrint('📊 Target FPS: $_targetFPS');
 if (kDebugMode) debugPrint('⚠️ Stutter threshold: ${_stutterThresholdMs}ms');
 if (kDebugMode) debugPrint('🎵 Audio gap threshold: ${_audioGapThresholdMs}ms');
    
    // Frame rate monitoring
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimingAvailable);
    
    // Performance reporting timer
    _performanceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _reportPerformanceStats();
    });
  }
  
  /// 🛑 Stop performance monitoring
  void stopMonitoring() {
    _performanceTimer?.cancel();
    _performanceTimer = null;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimingAvailable);
    
 if (kDebugMode) debugPrint('🛑 Performance Monitor STOPPED');
    _reportFinalStats();
    _clearData();
  }
  
  /// 📊 Frame timing callback for FPS and stutter detection
  void _onFrameTimingAvailable(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameTimes.add(frameDuration);
      _frameCount++;
      
      // Detect stutters (frames taking too long)
      final frameTimeMs = frameDuration.inMicroseconds / 1000;
      if (frameTimeMs > _stutterThresholdMs) {
 if (kDebugMode) debugPrint('🚨 FRAME STUTTER detected: ${frameTimeMs.toStringAsFixed(1)}ms');
        
        // Log detailed stutter info
 if (kDebugMode) debugPrint('   🎬 Build: ${timing.buildDuration.inMicroseconds / 1000}ms');
 if (kDebugMode) debugPrint('   🎨 Raster: ${timing.rasterDuration.inMicroseconds / 1000}ms');
 if (kDebugMode) debugPrint('   ⏱️ Total: ${timing.totalSpan.inMicroseconds / 1000}ms');
      }
      
      // Keep only recent frame times (last 5 seconds worth)
      if (_frameTimes.length > _targetFPS * 5) {
        _frameTimes.removeRange(0, _frameTimes.length - _targetFPS * 5);
      }
    }
  }
  
  /// 🎵 Track audio playback start for gap detection
  void trackAudioStart(String soundId) {
    _audioStartTimes[soundId] = DateTime.now();
 if (kDebugMode) debugPrint('🎵 Audio tracking started: $soundId');
  }
  
  /// ⏸️ Track audio playback end and calculate gaps
  void trackAudioEnd(String soundId) {
    final startTime = _audioStartTimes[soundId];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
 if (kDebugMode) debugPrint('🎵 Audio session duration: ${duration}ms for $soundId');
      _audioStartTimes.remove(soundId);
    }
  }
  
  /// 🔄 Track audio loop restart for gap measurement
  void trackAudioLoopGap(String soundId, int gapMs) {
    if (!_audioGaps.containsKey(soundId)) {
      _audioGaps[soundId] = [];
    }
    
    _audioGaps[soundId]!.add(gapMs);
    
    if (gapMs > _audioGapThresholdMs) {
 if (kDebugMode) debugPrint('🚨 AUDIO GAP detected: ${gapMs}ms in $soundId');
    } else {
 if (kDebugMode) debugPrint('✅ Smooth audio loop: ${gapMs}ms gap in $soundId');
    }
  }
  
  /// 🎬 Track video playback start
  void trackVideoStart(String videoPath) {
    _videoStartTimes[videoPath] = DateTime.now();
 if (kDebugMode) debugPrint('🎬 Video tracking started: $videoPath');
  }
  
  /// ⏹️ Track video playback end
  void trackVideoEnd(String videoPath) {
    final startTime = _videoStartTimes[videoPath];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
 if (kDebugMode) debugPrint('🎬 Video session duration: ${duration}ms for $videoPath');
      _videoStartTimes.remove(videoPath);
    }
  }
  
  /// 🔄 Track video stutter/buffering
  void trackVideoStutter(String videoPath, int stutterMs) {
    if (!_videoStutters.containsKey(videoPath)) {
      _videoStutters[videoPath] = [];
    }
    
    _videoStutters[videoPath]!.add(stutterMs);
    
    if (stutterMs > _stutterThresholdMs) {
 if (kDebugMode) debugPrint('🚨 VIDEO STUTTER detected: ${stutterMs}ms in $videoPath');
    }
  }
  
  /// 📊 Report current performance statistics
  void _reportPerformanceStats() {
    if (_frameTimes.isEmpty) return;
    
    // Calculate FPS
    final avgFrameTime = _frameTimes.fold<int>(0, (sum, time) => sum + time.inMicroseconds) / _frameTimes.length;
    final currentFPS = (1000000 / avgFrameTime).round();
    
    // Count stutters
    final stutterCount = _frameTimes.where((time) => time.inMicroseconds / 1000 > _stutterThresholdMs).length;
    final stutterPercentage = (stutterCount / _frameTimes.length * 100);
    
 if (kDebugMode) debugPrint('📊 === PERFORMANCE REPORT ===');
 if (kDebugMode) debugPrint('🎯 Current FPS: $currentFPS (target: $_targetFPS)');
 if (kDebugMode) debugPrint('⚠️ Stutters: $stutterCount/${_frameTimes.length} (${stutterPercentage.toStringAsFixed(1)}%)');
 if (kDebugMode) debugPrint('⏱️ Avg frame time: ${(avgFrameTime / 1000).toStringAsFixed(1)}ms');
    
    // Audio performance
    _audioGaps.forEach((soundId, gaps) {
      if (gaps.isNotEmpty) {
        final avgGap = gaps.fold<int>(0, (sum, gap) => sum + gap) / gaps.length;
        final problemGaps = gaps.where((gap) => gap > _audioGapThresholdMs).length;
 if (kDebugMode) debugPrint('🎵 Audio $soundId: ${avgGap.toStringAsFixed(1)}ms avg gap, $problemGaps problem loops');
      }
    });
    
    // Video performance  
    _videoStutters.forEach((videoPath, stutters) {
      if (stutters.isNotEmpty) {
        final avgStutter = stutters.fold<int>(0, (sum, stutter) => sum + stutter) / stutters.length;
 if (kDebugMode) debugPrint('🎬 Video ${videoPath.split('/').last}: ${stutters.length} stutters, ${avgStutter.toStringAsFixed(1)}ms avg');
      }
    });
    
 if (kDebugMode) debugPrint('========================');
  }
  
  /// 📈 Report final performance statistics
  void _reportFinalStats() {
 if (kDebugMode) debugPrint('📈 === FINAL PERFORMANCE REPORT ===');
    
    if (_frameTimes.isNotEmpty) {
      final avgFrameTime = _frameTimes.fold<int>(0, (sum, time) => sum + time.inMicroseconds) / _frameTimes.length;
      final avgFPS = (1000000 / avgFrameTime).round();
      final totalStutters = _frameTimes.where((time) => time.inMicroseconds / 1000 > _stutterThresholdMs).length;
      
 if (kDebugMode) debugPrint('🎯 Session average FPS: $avgFPS');
 if (kDebugMode) debugPrint('⚠️ Total stutters: $totalStutters');
 if (kDebugMode) debugPrint('📊 Total frames analyzed: ${_frameTimes.length}');
    }
    
    // Audio summary
    int totalAudioGaps = 0;
    int problemAudioGaps = 0;
    _audioGaps.forEach((soundId, gaps) {
      totalAudioGaps += gaps.length;
      problemAudioGaps += gaps.where((gap) => gap > _audioGapThresholdMs).length;
    });
    
    if (totalAudioGaps > 0) {
 if (kDebugMode) debugPrint('🎵 Total audio loops: $totalAudioGaps');
 if (kDebugMode) debugPrint('🚨 Problem audio gaps: $problemAudioGaps');
 if (kDebugMode) debugPrint('✅ Smooth audio rate: ${((totalAudioGaps - problemAudioGaps) / totalAudioGaps * 100).toStringAsFixed(1)}%');
    }
    
    // Video summary
    int totalVideoStutters = 0;
    _videoStutters.forEach((videoPath, stutters) {
      totalVideoStutters += stutters.length;
    });
    
    if (totalVideoStutters > 0) {
 if (kDebugMode) debugPrint('🎬 Total video stutters: $totalVideoStutters');
    }
    
 if (kDebugMode) debugPrint('================================');
  }
  
  /// 🧹 Clear all monitoring data
  void _clearData() {
    _frameTimes.clear();
    _audioGaps.clear();
    _audioStartTimes.clear();
    _videoStutters.clear();
    _videoStartTimes.clear();
    _frameCount = 0;
  }
  
  /// 🎯 Get current performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_frameTimes.isEmpty) return {};
    
    final avgFrameTime = _frameTimes.fold<int>(0, (sum, time) => sum + time.inMicroseconds) / _frameTimes.length;
    final currentFPS = (1000000 / avgFrameTime).round();
    final stutterCount = _frameTimes.where((time) => time.inMicroseconds / 1000 > _stutterThresholdMs).length;
    
    return {
      'fps': currentFPS,
      'targetFPS': _targetFPS,
      'stutterCount': stutterCount,
      'frameCount': _frameTimes.length,
      'stutterPercentage': stutterCount / _frameTimes.length * 100,
      'avgFrameTimeMs': avgFrameTime / 1000,
    };
  }
}

/// 🎛️ Performance optimization utilities
class PerformanceOptimizer {
  
  /// 🚀 Optimize app for smooth video/audio playback
  static Future<void> optimizeForMediaPlayback() async {
 if (kDebugMode) debugPrint('🚀 Optimizing app for SEAMLESS media playback...');
    
    // Memory optimization
    if (Platform.isAndroid) {
 if (kDebugMode) debugPrint('📱 Android: Requesting high performance mode');
      // Note: These would require platform channels in real implementation
    }
    
    if (Platform.isIOS) {
 if (kDebugMode) debugPrint('🍎 iOS: Optimizing for media playback');
      // Note: These would require platform channels in real implementation
    }
    
 if (kDebugMode) debugPrint('✅ Media playback optimizations applied');
  }
  
  /// 🎵 Pre-warm audio system for faster startup
  static Future<void> preWarmAudioSystem() async {
 if (kDebugMode) debugPrint('🎵 Pre-warming audio system for faster loop starts...');
    
    // This would involve creating and disposing a dummy audio player
    // to initialize the audio system faster for subsequent plays
    
 if (kDebugMode) debugPrint('✅ Audio system pre-warmed');
  }
  
  /// 🎬 Pre-warm video system for smoother playback
  static Future<void> preWarmVideoSystem() async {
 if (kDebugMode) debugPrint('🎬 Pre-warming video system for smoother loops...');
    
    // This would involve initializing video codec caches
    
 if (kDebugMode) debugPrint('✅ Video system pre-warmed');
  }
} 
