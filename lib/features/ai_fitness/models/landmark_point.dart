/// MediaPipe landmark noktalarının sarmalayıcı (wrapper) sınıfı.
///
/// MediaPipe 33 landmark döndürür. Bu sınıf, ham veriyi normalize eder
/// ve güven skoru (visibility) kontrolü sağlar.
class LandmarkPoint {
  final double x;
  final double y;
  final double z;
  final double visibility;

  const LandmarkPoint({
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
  });

  /// Landmark güvenilir mi? (visibility eşiği: 0.65)
  bool get isVisible => visibility >= 0.65;

  /// Landmark yüksek güvenle algılandı mı? (eşik: 0.85)
  bool get isHighConfidence => visibility >= 0.85;

  /// Boş/geçersiz landmark
  static const LandmarkPoint empty = LandmarkPoint(
    x: 0,
    y: 0,
    z: 0,
    visibility: 0,
  );

  /// JSON'dan oluşturma
  factory LandmarkPoint.fromMap(Map<String, dynamic> map) {
    return LandmarkPoint(
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      z: (map['z'] as num?)?.toDouble() ?? 0.0,
      visibility: (map['visibility'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'visibility': visibility,
    };
  }

  @override
  String toString() =>
      'LandmarkPoint(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, '
      'z: ${z.toStringAsFixed(3)}, vis: ${visibility.toStringAsFixed(2)})';
}

/// MediaPipe 33 Landmark İndeksleri
/// https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker
class PoseLandmarkIndex {
  static const int nose = 0;
  static const int leftEyeInner = 1;
  static const int leftEye = 2;
  static const int leftEyeOuter = 3;
  static const int rightEyeInner = 4;
  static const int rightEye = 5;
  static const int rightEyeOuter = 6;
  static const int leftEar = 7;
  static const int rightEar = 8;
  static const int mouthLeft = 9;
  static const int mouthRight = 10;
  static const int leftShoulder = 11;
  static const int rightShoulder = 12;
  static const int leftElbow = 13;
  static const int rightElbow = 14;
  static const int leftWrist = 15;
  static const int rightWrist = 16;
  static const int leftPinky = 17;
  static const int rightPinky = 18;
  static const int leftIndex = 19;
  static const int rightIndex = 20;
  static const int leftThumb = 21;
  static const int rightThumb = 22;
  static const int leftHip = 23;
  static const int rightHip = 24;
  static const int leftKnee = 25;
  static const int rightKnee = 26;
  static const int leftAnkle = 27;
  static const int rightAnkle = 28;
  static const int leftHeel = 29;
  static const int rightHeel = 30;
  static const int leftFootIndex = 31;
  static const int rightFootIndex = 32;

  /// Toplam landmark sayısı
  static const int totalLandmarks = 33;

  /// Üst vücut landmarkları (Arms + Shoulders)
  static const List<int> upperBody = [
    leftShoulder, rightShoulder,
    leftElbow, rightElbow,
    leftWrist, rightWrist,
  ];

  /// Alt vücut landmarkları (Legs + Hips)
  static const List<int> lowerBody = [
    leftHip, rightHip,
    leftKnee, rightKnee,
    leftAnkle, rightAnkle,
  ];

  /// İskelet çizimi için bağlantı çiftleri
  static const List<List<int>> skeletonConnections = [
    // Yüz
    [nose, leftEyeInner], [leftEyeInner, leftEye], [leftEye, leftEyeOuter],
    [nose, rightEyeInner], [rightEyeInner, rightEye], [rightEye, rightEyeOuter],
    [leftEar, leftEyeOuter], [rightEar, rightEyeOuter],
    [mouthLeft, mouthRight],
    // Gövde
    [leftShoulder, rightShoulder],
    [leftShoulder, leftHip], [rightShoulder, rightHip],
    [leftHip, rightHip],
    // Sol kol
    [leftShoulder, leftElbow], [leftElbow, leftWrist],
    [leftWrist, leftPinky], [leftWrist, leftIndex], [leftWrist, leftThumb],
    // Sağ kol
    [rightShoulder, rightElbow], [rightElbow, rightWrist],
    [rightWrist, rightPinky], [rightWrist, rightIndex], [rightWrist, rightThumb],
    // Sol bacak
    [leftHip, leftKnee], [leftKnee, leftAnkle],
    [leftAnkle, leftHeel], [leftAnkle, leftFootIndex], [leftHeel, leftFootIndex],
    // Sağ bacak
    [rightHip, rightKnee], [rightKnee, rightAnkle],
    [rightAnkle, rightHeel], [rightAnkle, rightFootIndex], [rightHeel, rightFootIndex],
  ];
}
