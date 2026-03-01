import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

/// 📊 Performans İzleme Aracı
/// 
/// Uygulama performansını gerçek zamanlı olarak izler:
/// - FPS (Frame Per Second) - Kare hızı
/// - Frame build time - Kare oluşturma süresi
/// - Memory usage - Bellek kullanımı
/// - Jank detection - Takılma tespiti
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // FPS Tracking
  final List<Duration> _frameDurations = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _currentFPS = 60.0;
  
  // Jank Detection (16.67ms = 60 FPS)
  static const Duration _targetFrameTime = Duration(milliseconds: 16);
  int _jankCount = 0;
  int _totalFrames = 0;
  
  // Performance Stats
  Duration _averageFrameTime = Duration.zero;
  Duration _maxFrameTime = Duration.zero;
  
  bool _isMonitoring = false;
  Timer? _statsTimer;

  /// Monitoring başlat
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    
    // Her 1 saniyede bir istatistikleri güncelle
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateStats();
    });
    
    if (kDebugMode) {
      print('🎯 PerformanceMonitor başlatıldı');
    }
  }

  /// Monitoring durdur
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _statsTimer?.cancel();
    _statsTimer = null;
    
    if (kDebugMode) {
      print('🛑 PerformanceMonitor durduruldu');
    }
  }

  /// Frame timing callback
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalDuration = buildDuration + rasterDuration;
      
      _frameDurations.add(totalDuration);
      _totalFrames++;
      
      // Jank detection (>16.67ms = jank)
      if (totalDuration > _targetFrameTime) {
        _jankCount++;
      }
      
      // Max frame time güncelle
      if (totalDuration > _maxFrameTime) {
        _maxFrameTime = totalDuration;
      }
      
      // Son 60 frame'i tut
      if (_frameDurations.length > 60) {
        _frameDurations.removeAt(0);
      }
    }
  }

  /// İstatistikleri hesapla
  void _calculateStats() {
    if (_frameDurations.isEmpty) return;
    
    // Ortalama frame time
    final totalMs = _frameDurations.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMicroseconds,
    );
    _averageFrameTime = Duration(microseconds: totalMs ~/ _frameDurations.length);
    
    // FPS hesapla (1000ms / average frame time)
    if (_averageFrameTime.inMicroseconds > 0) {
      _currentFPS = 1000000 / _averageFrameTime.inMicroseconds;
      _currentFPS = _currentFPS.clamp(0, 60); // Max 60 FPS
    }
  }

  /// Mevcut FPS değeri
  double get currentFPS => _currentFPS;
  
  /// Ortalama frame süresi (ms)
  double get averageFrameTimeMs => _averageFrameTime.inMicroseconds / 1000;
  
  /// Maksimum frame süresi (ms)
  double get maxFrameTimeMs => _maxFrameTime.inMicroseconds / 1000;
  
  /// Jank yüzdesi
  double get jankPercentage => _totalFrames > 0 
      ? (_jankCount / _totalFrames) * 100 
      : 0;
  
  /// Toplam frame sayısı
  int get totalFrames => _totalFrames;
  
  /// Toplam jank sayısı
  int get jankCount => _jankCount;

  /// İstatistikleri sıfırla
  void reset() {
    _frameDurations.clear();
    _frameCount = 0;
    _lastFrameTime = null;
    _currentFPS = 60.0;
    _jankCount = 0;
    _totalFrames = 0;
    _averageFrameTime = Duration.zero;
    _maxFrameTime = Duration.zero;
  }

  /// Performans raporu al
  PerformanceReport getReport() {
    return PerformanceReport(
      fps: _currentFPS,
      averageFrameTimeMs: averageFrameTimeMs,
      maxFrameTimeMs: maxFrameTimeMs,
      jankPercentage: jankPercentage,
      totalFrames: _totalFrames,
      jankCount: _jankCount,
    );
  }
}

/// Performans Raporu
class PerformanceReport {
  final double fps;
  final double averageFrameTimeMs;
  final double maxFrameTimeMs;
  final double jankPercentage;
  final int totalFrames;
  final int jankCount;

  PerformanceReport({
    required this.fps,
    required this.averageFrameTimeMs,
    required this.maxFrameTimeMs,
    required this.jankPercentage,
    required this.totalFrames,
    required this.jankCount,
  });

  /// Performans seviyesi
  PerformanceLevel get level {
    if (fps >= 55) return PerformanceLevel.excellent;
    if (fps >= 45) return PerformanceLevel.good;
    if (fps >= 30) return PerformanceLevel.fair;
    return PerformanceLevel.poor;
  }

  /// Performans emoji
  String get emoji {
    switch (level) {
      case PerformanceLevel.excellent:
        return '🟢';
      case PerformanceLevel.good:
        return '🟡';
      case PerformanceLevel.fair:
        return '🟠';
      case PerformanceLevel.poor:
        return '🔴';
    }
  }

  @override
  String toString() {
    return '''
📊 Performans Raporu $emoji
━━━━━━━━━━━━━━━━━━━━━━
FPS: ${fps.toStringAsFixed(1)} (${level.name})
Ortalama Frame: ${averageFrameTimeMs.toStringAsFixed(2)}ms
Max Frame: ${maxFrameTimeMs.toStringAsFixed(2)}ms
Jank: ${jankPercentage.toStringAsFixed(1)}% ($jankCount/$totalFrames)
━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}

/// Performans Seviyeleri
enum PerformanceLevel {
  excellent, // 55+ FPS
  good,      // 45-55 FPS
  fair,      // 30-45 FPS
  poor,      // <30 FPS
}
