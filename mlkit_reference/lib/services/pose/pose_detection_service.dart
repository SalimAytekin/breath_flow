import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Poz algılama sistemi için Android MLKit ile iletişim kuran servis
class PoseDetectionService {
  static const MethodChannel _methodChannel =
      MethodChannel('com.google.mlkit.vision.demo/pose_detector');
  
  static const EventChannel _poseDataChannel = 
      EventChannel('com.google.mlkit.vision.demo/pose_data');
  
  // Poz verilerini dinlemek için stream controller
  final StreamController<Map<String, dynamic>> _poseDataController = 
      StreamController<Map<String, dynamic>>.broadcast();
      
  // Koçluk sonuçlarını dinlemek için stream controller
  final StreamController<Map<String, dynamic>> _coachingResultController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Stream'leri dışarıya açıyoruz
  Stream<Map<String, dynamic>> get poseDataStream => _poseDataController.stream;
  Stream<Map<String, dynamic>> get coachingResultStream => _coachingResultController.stream;
  
  // Event channel subscriptions
  StreamSubscription? _poseDataSubscription;
  
  PoseDetectionService() {
    _initPoseDataChannel();
  }
  
  void _initPoseDataChannel() {
    debugPrint("EventChannel dinlemesi başlatılıyor...");
    
    try {
      _poseDataSubscription = _poseDataChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final Map<String, dynamic> poseData = Map<String, dynamic>.from(event);
            _poseDataController.add(poseData);
          }
        },
        onError: (dynamic error) {
          debugPrint("Pose data channel error: $error");
          _poseDataController.addError(error);
        }
      );
      debugPrint("EventChannel dinlemesi başarılı");
    } catch (e) {
      debugPrint("EventChannel dinleme hatası: $e");
    }
  }
  
  /// Native kamerayı ve poz algılama sistemini başlatır
  Future<void> startPoseDetection() async {
    try {
      final result = await _methodChannel.invokeMethod('startPoseDetection');
      return result;
    } catch (e) {
      debugPrint("Poz algılama başlatma hatası: $e");
      rethrow;
    }
  }
  
  /// Poz algılama sistemini durdurur
  Future<void> stopPoseDetection() async {
    try {
      await _methodChannel.invokeMethod('stopPoseDetection');
    } catch (e) {
      debugPrint("Poz algılama durdurma hatası: $e");
      rethrow;
    }
  }
  
  /// Native exercise coaching ekranını başlatır (CameraX + Coaching Overlay)
  Future<void> startExerciseCoaching({
    String exerciseName = "Egzersiz",
    String exerciseType = "default",
    Map<String, dynamic>? exerciseData,
  }) async {
    try {
      final data = exerciseData ?? {
        'name': exerciseName,
        'type': exerciseType,
        'description': 'Egzersiz açıklaması',
        'analyzerType': 'default',
        'rules': {},
        'feedback': [],
      };
      
      await _methodChannel.invokeMethod('startExerciseCoaching', data);
      log('Native exercise coaching başlatıldı: $exerciseName');
    } catch (e) {
      log('Exercise coaching başlatma hatası: $e');
      rethrow;
    }
  }
  
  /// Kaynakları temizler
  void dispose() {
    _poseDataSubscription?.cancel();
    _poseDataController.close();
    _coachingResultController.close();
  }
}
