class HRVMeasurement {
  final String id;
  final DateTime timestamp;
  final int heartRate; // BPM
  final double stressLevel; // 0-100 arası
  final List<double> rrIntervals; // R-R aralıkları (milisaniye)
  final Map<String, double> hrvMetrics; // RMSSD, SDNN, etc.
  final String? sessionType; // 'before_breathing', 'after_breathing', 'standalone'
  final String? notes;

  HRVMeasurement({
    required this.id,
    required this.timestamp,
    required this.heartRate,
    required this.stressLevel,
    required this.rrIntervals,
    required this.hrvMetrics,
    this.sessionType,
    this.notes,
  });

  // Stres seviyesini hesapla (basit algoritma)
  static double calculateStressLevel(double rmssd, int heartRate) {
    // RMSSD değeri düşükse stres yüksek
    // Normal RMSSD: 20-50ms
    // Yüksek stres: <20ms
    // Düşük stres: >50ms
    
    double stressFromRMSSD = 0;
    if (rmssd < 20) {
      stressFromRMSSD = 80 + (20 - rmssd) * 2; // 80-100 arası
    } else if (rmssd > 50) {
      stressFromRMSSD = 20 - (rmssd - 50) * 0.5; // 0-20 arası
    } else {
      stressFromRMSSD = 80 - (rmssd - 20) * 2; // 20-80 arası
    }
    
    // Kalp atış hızı da etkili
    double stressFromHR = 0;
    if (heartRate > 100) {
      stressFromHR = 60 + (heartRate - 100) * 0.8;
    } else if (heartRate < 60) {
      stressFromHR = 20;
    } else {
      stressFromHR = 20 + (heartRate - 60) * 1.0;
    }
    
    // Ortalamasını al ve 0-100 arasında sınırla
    double finalStress = (stressFromRMSSD + stressFromHR) / 2;
    return finalStress.clamp(0, 100);
  }

  // Stres seviyesi açıklaması
  String get stressLevelDescription {
    if (stressLevel < 30) {
      return 'Düşük Stres';
    } else if (stressLevel < 60) {
      return 'Orta Stres';
    } else if (stressLevel < 80) {
      return 'Yüksek Stres';
    } else {
      return 'Çok Yüksek Stres';
    }
  }

  // Stres seviyesi rengi
  String get stressLevelColor {
    if (stressLevel < 30) {
      return '#4CAF50'; // Yeşil
    } else if (stressLevel < 60) {
      return '#FFC107'; // Sarı
    } else if (stressLevel < 80) {
      return '#FF9800'; // Turuncu
    } else {
      return '#F44336'; // Kırmızı
    }
  }

  // JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'stressLevel': stressLevel,
      'rrIntervals': rrIntervals,
      'hrvMetrics': hrvMetrics,
      'sessionType': sessionType,
      'notes': notes,
    };
  }

  // JSON'dan oluştur
  factory HRVMeasurement.fromJson(Map<String, dynamic> json) {
    return HRVMeasurement(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['heartRate'],
      stressLevel: json['stressLevel'],
      rrIntervals: List<double>.from(json['rrIntervals']),
      hrvMetrics: Map<String, double>.from(json['hrvMetrics']),
      sessionType: json['sessionType'],
      notes: json['notes'],
    );
  }

  // Kopyala
  HRVMeasurement copyWith({
    String? id,
    DateTime? timestamp,
    int? heartRate,
    double? stressLevel,
    List<double>? rrIntervals,
    Map<String, double>? hrvMetrics,
    String? sessionType,
    String? notes,
  }) {
    return HRVMeasurement(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      stressLevel: stressLevel ?? this.stressLevel,
      rrIntervals: rrIntervals ?? this.rrIntervals,
      hrvMetrics: hrvMetrics ?? this.hrvMetrics,
      sessionType: sessionType ?? this.sessionType,
      notes: notes ?? this.notes,
    );
  }
}

// HRV ölçüm durumu
enum HRVMeasurementState {
  idle,
  requesting_permission,
  preparing,
  measuring,
  processing,
  completed,
  error,
}

// HRV ölçüm hatası
class HRVMeasurementError {
  final String message;
  final String? details;
  final DateTime timestamp;

  HRVMeasurementError({
    required this.message,
    this.details,
    required this.timestamp,
  });
} 