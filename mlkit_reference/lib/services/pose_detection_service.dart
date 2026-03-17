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
  
  /// Egzersiz koçluk modunu etkinleştirir
  Future<void> startCoaching(Map<String, dynamic> exerciseData) async {
    try {
      await _methodChannel.invokeMethod('startCoaching', exerciseData);
    } catch (e) {
      debugPrint("Koçluk başlatma hatası: $e");
      rethrow;
    }
  }
  
  /// Koçluk modunu durdurur
  Future<void> stopCoaching() async {
    try {
      await _methodChannel.invokeMethod('stopCoaching');
    } catch (e) {
      debugPrint("Koçluk durdurma hatası: $e");
      rethrow;
    }
  }
  
  /// Koçluk modunu duraklatır
  Future<void> pauseCoaching() async {
    try {
      await _methodChannel.invokeMethod('pauseCoaching');
    } catch (e) {
      debugPrint("Koçluk duraklatma hatası: $e");
      rethrow;
    }
  }
  
  /// Duraklatılmış koçluk modunu devam ettirir
  Future<void> resumeCoaching() async {
    try {
      await _methodChannel.invokeMethod('resumeCoaching');
    } catch (e) {
      debugPrint("Koçluk devam ettirme hatası: $e");
      rethrow;
    }
  }
  
  /// Native exercise coaching ekranını başlatır (CameraX + Coaching Overlay)
  Future<void> startExerciseCoaching({
    String exerciseName = "Squat Egzersizi",
    String exerciseType = "squat",
    Map<String, dynamic>? exerciseData,
  }) async {
    try {
      final data = exerciseData ?? {
        'name': exerciseName,
        'type': exerciseType,
        'description': 'Egzersiz açıklaması',
      };
      
      await _methodChannel.invokeMethod('startExerciseCoaching', data);
      log('Native exercise coaching başlatıldı: $exerciseName');
    } catch (e) {
      log('Exercise coaching başlatma hatası: $e');
      rethrow;
    }
  }

  /// Boyun Döndürme Egzersizi
  Future<void> startNeckRotationExercise() async {
    await startExerciseCoaching(
      exerciseName: "Boyun Döndürme Egzersizi",
      exerciseType: "neck_rotation",
      exerciseData: {
        'name': 'Boyun Döndürme',
        'type': 'neck_rotation',
        'description': 'Boyunuzu yavaşça sağa ve sola döndürün',
        'instructions': 'Başınızı dik tutarak boyunuzu yavaşça sağa döndürün, 2 saniye bekleyin, sonra sola döndürün.',
      }
    );
  }

  /// Boyun Yan Eğme Egzersizi  
  Future<void> startNeckSideBendExercise() async {
    await startExerciseCoaching(
      exerciseName: "Boyun Yan Eğme Egzersizi",
      exerciseType: "neck_side_bend",
      exerciseData: {
        'name': 'Boyun Yan Eğme',
        'type': 'neck_side_bend', 
        'description': 'Kulağınızı omzunuza yaklaştırın',
        'instructions': 'Sırtınızı dik tutarak, kulağınızı omzunuza doğru yavaşça eğin.',
      }
    );
  }

  /// Boyun Öne/Arkaya Eğme Egzersizi
  Future<void> startNeckFlexionExercise() async {
    await startExerciseCoaching(
      exerciseName: "Boyun Flexion Egzersizi", 
      exerciseType: "neck_flexion",
      exerciseData: {
        'name': 'Boyun Öne/Arkaya Eğme',
        'type': 'neck_flexion',
        'description': 'Başınızı öne ve arkaya yavaşça eğin',
        'instructions': 'Çenenizi göğsünüze doğru indirin, sonra başınızı arkaya eğin.',
      }
    );
  }

  /// Squat Egzersizi
  Future<void> startSquatExercise() async {
    await startExerciseCoaching(
      exerciseName: "Squat Egzersizi",
      exerciseType: "squat",
      exerciseData: {
        'name': 'Squat Egzersizi',
        'type': 'squat',
        'description': 'Doğru form ile squat hareketi yapın',
        'instructions': 'Ayaklarınızı omuz genişliğinde açın, kalçanızı geriye iterek diz üzerine çökün.',
      }
    );
  }
  
  /// Kaynakları temizler
  void dispose() {
    _poseDataSubscription?.cancel();
    _poseDataController.close();
    _coachingResultController.close();
  }
}
