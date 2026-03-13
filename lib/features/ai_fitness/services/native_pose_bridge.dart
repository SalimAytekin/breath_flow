import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/landmark_point.dart';

/// MLKit Pose Detection bridge.
///
/// Android: MethodChannel ile native ExerciseCoachingActivity başlatılır.
/// Kamera, pose detection ve iskelet çizimi tamamen native tarafta çalışır.
/// Feedback, accuracy ve rep sayısı EventChannel ile Flutter'a geri döner.
class NativePoseBridge {
  static const _methodChannel = MethodChannel('com.breathflow.app/pose_detector');
  static const _eventChannelName = 'com.breathflow.app/pose_data';

  EventChannel? _eventChannel;
  StreamSubscription? _subscription;

  bool _isActive = false;
  bool get isActive => _isActive;

  // Debug bilgileri
  double _currentFps = 0;
  String _statusMessage = 'Başlatılıyor...';
  String _accelerationMode = 'mlkit';
  int _frameCount = 0;
  int _detectedCount = 0;
  int _lastInferenceMs = 0;
  int _repCount = 0;
  double _accuracy = 0;
  String _feedback = '';

  double get currentFps => _currentFps;
  String get statusMessage => _statusMessage;
  String get accelerationMode => _accelerationMode;
  int get frameCount => _frameCount;
  int get detectedCount => _detectedCount;
  int get lastInferenceMs => _lastInferenceMs;
  int get repCount => _repCount;
  double get accuracy => _accuracy;
  String get feedback => _feedback;

  final void Function(List<LandmarkPoint> landmarks)? onPoseDetected;
  final void Function(String error)? onError;

  // Yeni callback'ler (Flutter UI & FeedbackEngine entegrasyonu için)
  final void Function(int count)? onRepetition;
  final void Function(String message)? onFeedback;
  final void Function(double value)? onAccuracy;
  final void Function()? onExerciseStarted;

  NativePoseBridge({
    this.onPoseDetected,
    this.onError,
    this.onRepetition,
    this.onFeedback,
    this.onAccuracy,
    this.onExerciseStarted,
  });

  /// Native ExerciseCoachingActivity'yi başlat
  Future<bool> startExerciseCoaching({
    required String exerciseName,
    required String exerciseType,
    String description = '',
    String duration = '5 dk',
  }) async {
    try {
      final result = await _methodChannel.invokeMethod('startExerciseCoaching', {
        'name': exerciseName,
        'type': exerciseType,
        'description': description,
        'duration': duration,
      });
      _isActive = true;
      _statusMessage = 'Koçluk başlatıldı';
      return result == true;
    } catch (e) {
      debugPrint('❌ startExerciseCoaching error: $e');
      onError?.call('Coaching başlatma hatası: $e');
      return false;
    }
  }

  /// Native poz algılama Activity'sini başlat (coaching olmadan)
  Future<bool> startPoseDetection() async {
    try {
      final result = await _methodChannel.invokeMethod('startPoseDetection');
      _isActive = true;
      _statusMessage = 'Poz algılama başlatıldı';
      return result == true;
    } catch (e) {
      debugPrint('❌ startPoseDetection error: $e');
      onError?.call('Poz algılama hatası: $e');
      return false;
    }
  }

  /// EventChannel'ı dinlemeye başla (coaching feedback'leri)
  void startListening() {
    _eventChannel = const EventChannel(_eventChannelName);
    _subscription = _eventChannel!.receiveBroadcastStream().listen(
      _onEvent,
      onError: _onStreamError,
    );
    _isActive = true;
    debugPrint('🎯 NativePoseBridge: EventChannel dinlemeye başladı');
  }

  void _onEvent(dynamic event) {
    if (event is! Map) return;

    final type = event['type'] as String?;
    final data = event['data'];

    switch (type) {
      case 'feedback':
        if (data is Map) {
          _feedback = data['message'] as String? ?? '';
          if (_feedback.isNotEmpty) onFeedback?.call(_feedback);
        }
        break;

      case 'accuracy':
        if (data is Map) {
          _accuracy = (data['value'] as num?)?.toDouble() ?? 0;
          onAccuracy?.call(_accuracy);
        }
        break;

      case 'repetition':
        if (data is Map) {
          _repCount = (data['count'] as num?)?.toInt() ?? 0;
          onRepetition?.call(_repCount);
        }
        break;

      case 'exercise_started':
        _statusMessage = 'Egzersiz başladı';
        _accelerationMode = 'mlkit';
        onExerciseStarted?.call();
        break;

      case 'exercise_stopped':
        _statusMessage = 'Egzersiz durduruldu';
        break;

      case 'error':
        final message = event['message'] as String? ?? 'Unknown error';
        _statusMessage = 'Hata: $message';
        onError?.call(message);
        break;
    }
  }

  void _onStreamError(dynamic error) {
    debugPrint('❌ NativePoseBridge stream error: $error');
    onError?.call('Stream error: $error');
  }

  /// Dinlemeyi durdur
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isActive = false;
  }

  void dispose() {
    stopListening();
  }
}
