import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';
import '../models/landmark_point.dart';

/// MediaPipe Pose Detection servisi — Manual Mode.
///
/// Flutter CameraController'dan gelen frame'leri
/// `processFrame()` API'si ile native MediaPipe'a gönderir.
///
/// NOT: `startCameraDetection()` kullanılMIYOR çünkü
/// o API kendi native kamerasını açar ve Flutter
/// CameraController ile çakışır.
class PoseDetectorService {
  static const int _frameIntervalMs = 100; // ~10 FPS hedef

  int _lastProcessedTime = 0;
  NpuPoseDetector? _detector;
  bool _isActive = false;
  bool get isActive => _isActive;
  bool _isProcessing = false;

  bool _mediaPipeReady = false;
  bool get mediaPipeReady => _mediaPipeReady;

  // Debug
  int _frameCount = 0;
  int _detectedCount = 0;
  int _errorCount = 0;
  int _lastInferenceMs = 0;
  double _currentFps = 0;
  String _accelerationMode = 'unknown';
  String _statusMessage = 'Başlatılmadı';

  // FPS hesaplama
  final List<int> _fpsTimestamps = [];

  int get frameCount => _frameCount;
  int get detectedCount => _detectedCount;
  int get errorCount => _errorCount;
  int get lastInferenceMs => _lastInferenceMs;
  double get currentFps => _currentFps;
  String get accelerationMode => _accelerationMode;
  String get statusMessage => _statusMessage;

  final void Function(List<LandmarkPoint> landmarks)? onPoseDetected;
  final void Function(String error)? onError;

  PoseDetectorService({this.onPoseDetected, this.onError});

  Future<void> initialize() async {
    debugPrint('🎯 PoseDetector başlatılıyor...');
    try {
      _detector = NpuPoseDetector(
        config: const PoseDetectorConfig(
          mode: DetectionMode.fast,
          maxPoses: 1,
          minConfidence: 0.3,
          enableZEstimation: false,
          // GPU, MediaTek chipsetlerde aşırı yavaş (1200ms+).
          // CPU + XNNPack çok daha hızlı olabilir (~17ms).
          preferredAcceleration: AccelerationMode.cpu,
        ),
      );

      final mode = await _detector!.initialize();
      _accelerationMode = mode.toString();
      _mediaPipeReady = true;
      _isActive = true;
      _statusMessage = 'Hazır (${ _accelerationMode})';
      debugPrint('✅ MediaPipe hazır: $_accelerationMode');
    } catch (e) {
      debugPrint('⚠️ MediaPipe yüklenemedi: $e');
      _mediaPipeReady = false;
      _isActive = true;
      _accelerationMode = 'MOCK';
      _statusMessage = 'MOCK MOD';
    }
  }

  /// CameraController'ın startImageStream callback'inden çağrılır
  Future<void> processFrame(CameraImage image) async {
    if (!_isActive || _isProcessing) return;

    // Throttle
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedTime < _frameIntervalMs) return;
    _lastProcessedTime = now;
    _isProcessing = true;
    _frameCount++;

    // FPS hesapla
    _fpsTimestamps.add(now);
    _fpsTimestamps.removeWhere((t) => now - t > 1000);
    _currentFps = _fpsTimestamps.length.toDouble();

    try {
      if (_mediaPipeReady && _detector != null) {
        final planes = image.planes.map((p) => <String, dynamic>{
          'bytes': p.bytes,
          'bytesPerRow': p.bytesPerRow,
          'bytesPerPixel': p.bytesPerPixel,
        }).toList();

        final String format;
        switch (image.format.group) {
          case ImageFormatGroup.nv21:
            format = 'nv21';
            break;
          case ImageFormatGroup.yuv420:
            format = 'yuv420';
            break;
          case ImageFormatGroup.bgra8888:
            format = 'bgra8888';
            break;
          default:
            format = 'yuv420';
        }

        final result = await _detector!.processFrame(
          planes: planes,
          width: image.width,
          height: image.height,
          format: format,
          rotation: 270,
        );

        _lastInferenceMs = result.processingTimeMs;

        if (result.hasPoses) {
          _detectedCount++;
          final pose = result.firstPose!;
          final landmarks = _parseLandmarks(pose);
          onPoseDetected?.call(landmarks);
        }
      } else {
        // Mock — emülatör
        _lastInferenceMs = 5;
        _detectedCount++;
        onPoseDetected?.call(_generateMockLandmarks());
      }
    } catch (e) {
      _errorCount++;
      // Sadece ilk 3 hatayı logla (log spam önleme)
      if (_errorCount <= 3) {
        debugPrint('❌ Frame hatası #$_errorCount: $e');
      }
    } finally {
      _isProcessing = false;
    }
  }

  List<LandmarkPoint> _parseLandmarks(Pose pose) {
    return List.generate(pose.landmarks.length, (i) {
      final l = pose.landmarks[i];
      return LandmarkPoint(x: l.x, y: l.y, z: l.z, visibility: l.visibility);
    });
  }

  List<LandmarkPoint> _generateMockLandmarks() {
    final t = DateTime.now().millisecondsSinceEpoch;
    final Map<int, List<double>> pos = {
      PoseLandmarkIndex.nose: [0.50, 0.15],
      PoseLandmarkIndex.leftEye: [0.47, 0.13],
      PoseLandmarkIndex.rightEye: [0.53, 0.13],
      PoseLandmarkIndex.leftEar: [0.44, 0.14],
      PoseLandmarkIndex.rightEar: [0.56, 0.14],
      PoseLandmarkIndex.leftShoulder: [0.40, 0.25],
      PoseLandmarkIndex.rightShoulder: [0.60, 0.25],
      PoseLandmarkIndex.leftElbow: [0.35, 0.40],
      PoseLandmarkIndex.rightElbow: [0.65, 0.40],
      PoseLandmarkIndex.leftWrist: [0.33, 0.52],
      PoseLandmarkIndex.rightWrist: [0.67, 0.52],
      PoseLandmarkIndex.leftHip: [0.43, 0.55],
      PoseLandmarkIndex.rightHip: [0.57, 0.55],
      PoseLandmarkIndex.leftKnee: [0.42, 0.72],
      PoseLandmarkIndex.rightKnee: [0.58, 0.72],
      PoseLandmarkIndex.leftAnkle: [0.41, 0.88],
      PoseLandmarkIndex.rightAnkle: [0.59, 0.88],
    };
    return List.generate(PoseLandmarkIndex.totalLandmarks, (i) {
      final p = pos[i] ?? [0.5, 0.5];
      final j = 0.002 * (((t + i * 100) % 1000) / 500.0 - 1.0);
      return LandmarkPoint(x: p[0] + j, y: p[1] + j, z: 0, visibility: 0.95);
    });
  }

  Future<void> dispose() async {
    _isActive = false;
    _detector?.dispose();
    _detector = null;
  }
}
