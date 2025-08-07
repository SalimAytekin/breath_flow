import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'dart:convert';
import 'dart:math';
import '../models/hrv_measurement.dart';
import '../providers/user_preferences_provider.dart';

class HRVProvider extends ChangeNotifier {
  // State
  HRVMeasurementState _state = HRVMeasurementState.idle;
  HRVMeasurementError? _error;
  List<HRVMeasurement> _measurements = [];
  
  // Current measurement data
  List<SensorValue> _currentRawData = [];
  List<double> _rrIntervals = [];
  int _currentHeartRate = 0;
  double _measurementProgress = 0.0;
  
  // Measurement settings
  static const int _measurementDurationSeconds = 60; // 1 dakika
  static const int _minSamplesForHRV = 30; // Minimum R-R aralığı sayısı
  
  // Getters
  HRVMeasurementState get state => _state;
  HRVMeasurementError? get error => _error;
  List<HRVMeasurement> get measurements => List.unmodifiable(_measurements);
  List<SensorValue> get currentRawData => List.unmodifiable(_currentRawData);
  int get currentHeartRate => _currentHeartRate;
  double get measurementProgress => _measurementProgress;
  
  // Statistics
  HRVMeasurement? get latestMeasurement => 
      _measurements.isNotEmpty ? _measurements.first : null;
  
  double get averageStressLevel {
    if (_measurements.isEmpty) return 0;
    return _measurements.map((m) => m.stressLevel).reduce((a, b) => a + b) / _measurements.length;
  }
  
  List<HRVMeasurement> get todayMeasurements {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return _measurements.where((m) => m.timestamp.isAfter(todayStart)).toList();
  }

  final UserPreferencesProvider _userPreferencesProvider;

  HRVProvider(this._userPreferencesProvider) {
    _loadMeasurements();
  }

  // Verileri yükle
  Future<void> _loadMeasurements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final measurementsJson = prefs.getStringList('hrv_measurements') ?? [];
      
      _measurements = measurementsJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return HRVMeasurement.fromJson(json);
      }).toList();
      
      // Tarihe göre sırala (en yeni önce)
      _measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      notifyListeners();
    } catch (e) {
      debugPrint('HRV measurements loading error: $e');
    }
  }

  // Verileri kaydet
  Future<void> _saveMeasurements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final measurementsJson = _measurements.map((measurement) {
        return jsonEncode(measurement.toJson());
      }).toList();
      
      await prefs.setStringList('hrv_measurements', measurementsJson);
    } catch (e) {
      debugPrint('HRV measurements saving error: $e');
    }
  }

  // Kamera iznini kontrol et
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    return false;
  }

  // HRV ölçümü başlat
  Future<void> startMeasurement({String? sessionType}) async {
    try {
      _setState(HRVMeasurementState.requesting_permission);
      
      // Kamera iznini kontrol et
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        _setError('Kamera izni gerekli');
        return;
      }
      
      _setState(HRVMeasurementState.preparing);
      _clearCurrentData();
      
      // Ölçüm başlatma hazırlığı
      await Future.delayed(const Duration(milliseconds: 500));
      
      _setState(HRVMeasurementState.measuring);
      
      // Bu noktada UI HeartBPMDialog'u gösterecek
      // Callback'ler UI tarafından ayarlanacak
      
    } catch (e) {
      _setError('Ölçüm başlatılamadı: $e');
    }
  }

  // Raw data callback (HeartBPMDialog'dan gelir)
  void onRawData(SensorValue value) {
    if (_state != HRVMeasurementState.measuring) return;
    
    _currentRawData.add(value);
    
    // Progress hesapla (basit yaklaşım)
    _measurementProgress = (_currentRawData.length / (_measurementDurationSeconds * 30)).clamp(0.0, 1.0);
    
    // R-R aralıklarını hesapla (basit peak detection)
    _calculateRRIntervals();
    
    notifyListeners();
  }

  // Heart rate callback (HeartBPMDialog'dan gelir)
  void onHeartRate(int bpm) {
    if (_state != HRVMeasurementState.measuring) return;
    
    _currentHeartRate = bpm;
    notifyListeners();
  }

  // Ölçümü tamamla
  Future<void> completeMeasurement({String? sessionType, String? notes}) async {
    if (_state != HRVMeasurementState.measuring) return;
    
    try {
      _setState(HRVMeasurementState.processing);
      
      // HRV metrikleri hesapla
      final hrvMetrics = _calculateHRVMetrics();
      
      // Stres seviyesini hesapla
      final stressLevel = HRVMeasurement.calculateStressLevel(
        hrvMetrics['RMSSD'] ?? 0,
        _currentHeartRate,
      );
      
      // Ölçümü kaydet
      final measurement = HRVMeasurement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        heartRate: _currentHeartRate,
        stressLevel: stressLevel,
        rrIntervals: List.from(_rrIntervals),
        hrvMetrics: hrvMetrics,
        sessionType: sessionType,
        notes: notes,
      );
      
      _measurements.insert(0, measurement);
      await _saveMeasurements();
      
      // FAZ 1: Akıllı öneri sistemi için HRV seansını kaydet
      _userPreferencesProvider.recordHrvSession(measurement.stressLevel.round());
      
      _setState(HRVMeasurementState.completed);
      
      // 2 saniye sonra idle'a geç
      Future.delayed(const Duration(seconds: 2), () {
        _setState(HRVMeasurementState.idle);
      });
      
    } catch (e) {
      _setError('Ölçüm tamamlanamadı: $e');
    }
  }

  // Ölçümü iptal et
  void cancelMeasurement() {
    _clearCurrentData();
    _setState(HRVMeasurementState.idle);
  }

  // R-R aralıklarını hesapla (basit peak detection)
  void _calculateRRIntervals() {
    if (_currentRawData.length < 10) return;
    
    // Son 10 veri noktasını al
    final recentData = _currentRawData.length > 10 
        ? _currentRawData.sublist(_currentRawData.length - 10)
        : _currentRawData;
    
    // Basit peak detection
    for (int i = 1; i < recentData.length - 1; i++) {
      final prev = recentData[i - 1];
      final current = recentData[i];
      final next = recentData[i + 1];
      
      // Peak bulma (basit algoritma)
      if (current.value > prev.value && current.value > next.value) {
        if (_rrIntervals.isNotEmpty) {
          final timeDiff = current.time.millisecondsSinceEpoch - recentData[0].time.millisecondsSinceEpoch;
          if (timeDiff > 300 && timeDiff < 2000) { // 300ms - 2000ms arası
            _rrIntervals.add(timeDiff.toDouble());
          }
        } else {
          // İlk peak için dummy değer
          _rrIntervals.add(800.0); // Ortalama bir R-R aralığı
        }
      }
    }
    
    // Çok fazla veri birikmesin
    if (_rrIntervals.length > 200) {
      _rrIntervals.removeRange(0, _rrIntervals.length - 200);
    }
  }

  // HRV metrikleri hesapla
  Map<String, double> _calculateHRVMetrics() {
    if (_rrIntervals.length < _minSamplesForHRV) {
      return {'RMSSD': 0, 'SDNN': 0, 'pNN50': 0, 'meanNN': 0};
    }
    
    // Mean NN
    final meanNN = _rrIntervals.reduce((a, b) => a + b) / _rrIntervals.length;
    
    // SDNN (Standard Deviation of NN intervals)
    final variance = _rrIntervals.map((rr) => pow(rr - meanNN, 2)).reduce((a, b) => a + b) / _rrIntervals.length;
    final sdnn = sqrt(variance);
    
    // RMSSD (Root Mean Square of Successive Differences)
    final successiveDiffs = <double>[];
    for (int i = 1; i < _rrIntervals.length; i++) {
      successiveDiffs.add(_rrIntervals[i] - _rrIntervals[i - 1]);
    }
    
    final rmssd = successiveDiffs.isNotEmpty 
        ? sqrt(successiveDiffs.map((d) => pow(d, 2)).reduce((a, b) => a + b) / successiveDiffs.length)
        : 0.0;
    
    // pNN50 (Percentage of NN intervals > 50ms)
    final nn50Count = successiveDiffs.where((d) => d.abs() > 50).length;
    final pnn50 = successiveDiffs.isNotEmpty ? (nn50Count / successiveDiffs.length) * 100 : 0.0;
    
    return {
      'RMSSD': rmssd,
      'SDNN': sdnn,
      'pNN50': pnn50,
      'meanNN': meanNN,
    };
  }

  // Durum değiştir
  void _setState(HRVMeasurementState newState) {
    _state = newState;
    _error = null;
    notifyListeners();
  }

  // Hata ayarla
  void _setError(String message) {
    _error = HRVMeasurementError(
      message: message,
      timestamp: DateTime.now(),
    );
    _state = HRVMeasurementState.error;
    notifyListeners();
  }

  // Mevcut veriyi temizle
  void _clearCurrentData() {
    _currentRawData.clear();
    _rrIntervals.clear();
    _currentHeartRate = 0;
    _measurementProgress = 0.0;
    _error = null;
  }

  // Ölçüm sil
  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((m) => m.id == id);
    await _saveMeasurements();
    notifyListeners();
  }

  // Tüm ölçümleri sil
  Future<void> clearAllMeasurements() async {
    _measurements.clear();
    await _saveMeasurements();
    notifyListeners();
  }

  // Belirli tarih aralığındaki ölçümleri al
  List<HRVMeasurement> getMeasurementsByDateRange(DateTime start, DateTime end) {
    return _measurements.where((m) => 
      m.timestamp.isAfter(start) && m.timestamp.isBefore(end)
    ).toList();
  }

  // Haftalık ortalama stres seviyesi
  double getWeeklyAverageStress() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyMeasurements = _measurements.where((m) => m.timestamp.isAfter(weekAgo)).toList();
    
    if (weeklyMeasurements.isEmpty) return 0;
    
    return weeklyMeasurements.map((m) => m.stressLevel).reduce((a, b) => a + b) / weeklyMeasurements.length;
  }
} 