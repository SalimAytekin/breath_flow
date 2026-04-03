import 'package:flutter/material.dart';
import 'exercise_phase.dart';
import 'landmark_point.dart';

/// Egzersiz zorluk seviyesi
enum DifficultyLevel {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Kolay';
      case DifficultyLevel.medium:
        return 'Orta';
      case DifficultyLevel.hard:
        return 'Zor';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.easy:
        return const Color(0xFF7DB87D);
      case DifficultyLevel.medium:
        return const Color(0xFFD4A574);
      case DifficultyLevel.hard:
        return const Color(0xFFD98B8B);
    }
  }
}

/// Telefon konumlandırma pozisyonu
enum PhonePosition {
  floor,
  table,
  wall,
  hand;

  String get displayName {
    switch (this) {
      case PhonePosition.floor:
        return 'Yere koy';
      case PhonePosition.table:
        return 'Masaya koy';
      case PhonePosition.wall:
        return 'Duvara daya';
      case PhonePosition.hand:
        return 'Elde tut';
    }
  }

  String get instruction {
    switch (this) {
      case PhonePosition.floor:
        return 'Telefonu yere, yaklaşık 2 metre uzağına koy ve arkana yasla.';
      case PhonePosition.table:
        return 'Telefonu masa veya tezgah üzerine, seni görecek şekilde yerleştir.';
      case PhonePosition.wall:
        return 'Telefonu duvara veya sağlam bir yüzeye daya.';
      case PhonePosition.hand:
        return 'Telefonu ön kameranı kullanarak yüzüne doğru tut.';
    }
  }

  IconData get icon {
    switch (this) {
      case PhonePosition.floor:
        return Icons.phone_android;
      case PhonePosition.table:
        return Icons.table_restaurant;
      case PhonePosition.wall:
        return Icons.vertical_align_center;
      case PhonePosition.hand:
        return Icons.front_hand;
    }
  }
}

/// Egzersiz yapılandırma sınıfı.
///
/// Her egzersiz tipi için açı eşikleri, hedef tekrar sayısı,
/// kullanılacak landmark indeksleri ve UX bilgilerini tanımlar.
class ExerciseConfig {
  /// Egzersiz türü
  final ExerciseType type;

  /// Egzersiz adı (gösterim için)
  final String displayName;

  /// Egzersiz açıklaması
  final String description;

  /// Eksantrik faza geçiş açısı (derece) — örn: kol aşağıya inmeye başladı
  final double eccentricThreshold;

  /// Konsantrik faza geçiş açısı (derece) — örn: kol tepe noktasına geldi
  final double concentricThreshold;

  /// Tekrar tamamlanma açısı (derece) — kol başlangıça döndü
  final double completionThreshold;

  /// Minimum kabul edilebilir ROM (Range of Motion) — çok kısa hareketleri filtreler
  final double minRangeOfMotion;

  /// Form hatası toleransı (±derece)
  final double formTolerance;

  /// Hedef tekrar sayısı
  final int targetReps;

  /// Bu egzersizde açı hesabına dahil landmark indeksleri [üst, orta, alt]
  /// Örneğin Biceps Curl: [omuz, dirsek, bilek]
  final List<int> primaryLandmarks;

  /// İkincil kontrol landmarkları (opsiyonel form kontrolleri)
  final List<int>? secondaryLandmarks;

  // ─────────────────────────────────────────
  // 🆕 UX Alanları
  // ─────────────────────────────────────────

  /// Zorluk seviyesi
  final DifficultyLevel difficulty;

  /// Tahmini egzersiz süresi
  final Duration estimatedDuration;

  /// Tahmini kalori yakımı
  final int estimatedCalories;

  /// Egzersiz ikonu
  final IconData iconData;

  /// Gradient renkleri
  final List<Color> gradientColors;

  /// Kısa form talimatları (3-4 madde)
  final List<String> instructions;

  /// Telefon konumlandırma pozisyonu
  final PhonePosition phonePosition;

  /// Hedef kas grubu
  final String targetMuscle;

  /// Egzersiz kilitli mi? (yakında)
  final bool isLocked;

  const ExerciseConfig({
    required this.type,
    required this.displayName,
    required this.description,
    required this.eccentricThreshold,
    required this.concentricThreshold,
    required this.completionThreshold,
    required this.minRangeOfMotion,
    this.formTolerance = 15.0,
    this.targetReps = 12,
    required this.primaryLandmarks,
    this.secondaryLandmarks,
    this.difficulty = DifficultyLevel.easy,
    this.estimatedDuration = const Duration(minutes: 5),
    this.estimatedCalories = 30,
    this.iconData = Icons.fitness_center,
    this.gradientColors = const [Color(0xFF0D47A1), Color(0xFF42A5F5)],
    this.instructions = const [],
    this.phonePosition = PhonePosition.hand,
    this.targetMuscle = '',
    this.isLocked = false,
  });

  // ─────────────────────────────────────────
  // 🏋️ Hazır Egzersiz Konfigürasyonları
  // ─────────────────────────────────────────

  /// Omuz Germe (Shoulder Stretch)
  static ExerciseConfig shoulderStretch() => ExerciseConfig(
        type: ExerciseType.shoulderStretch,
        displayName: 'Omuz Germe',
        description: 'Kollarınızı sırayla yukarı kaldırarak omuz kaslarını gerin ve mobilize edin. Her pozisyonda 3 saniye tutun.',
        eccentricThreshold: 0,
        concentricThreshold: 0,
        completionThreshold: 0,
        minRangeOfMotion: 0,
        primaryLandmarks: [
          PoseLandmarkIndex.rightShoulder,
          PoseLandmarkIndex.rightElbow,
          PoseLandmarkIndex.rightWrist,
        ],
        secondaryLandmarks: [
          PoseLandmarkIndex.leftShoulder,
          PoseLandmarkIndex.leftElbow,
          PoseLandmarkIndex.leftWrist,
          PoseLandmarkIndex.rightHip,
          PoseLandmarkIndex.leftHip,
        ],
        targetReps: 5,
        difficulty: DifficultyLevel.easy,
        estimatedDuration: const Duration(minutes: 4),
        estimatedCalories: 20,
        iconData: Icons.accessibility_new,
        gradientColors: const [Color(0xFFC4956A), Color(0xFFD4A574)],
        targetMuscle: 'Omuz & Sırt',
        phonePosition: PhonePosition.table,
        instructions: [
          'Ayakta dur, kollarını yanına indir',
          'Sağ kolunu yavaşça yukarı kaldır',
          'Kolun hedef açıya gelince 3 saniye tut',
          'Yavaşça indir, sonra sol kolla tekrarla',
        ],
      );

  /// Squat
  static ExerciseConfig squat() => ExerciseConfig(
        type: ExerciseType.squat,
        displayName: 'Squat',
        description: 'Kalça-diz-ayak bileği açısını analiz ederek doğru squat formu sağlar. Diz hizası ve sırt düzlüğü kontrol edilir.',
        eccentricThreshold: 140.0,
        concentricThreshold: 90.0,
        completionThreshold: 160.0,
        minRangeOfMotion: 45.0,
        primaryLandmarks: [
          PoseLandmarkIndex.rightHip,
          PoseLandmarkIndex.rightKnee,
          PoseLandmarkIndex.rightAnkle,
        ],
        secondaryLandmarks: [
          PoseLandmarkIndex.leftHip,
          PoseLandmarkIndex.leftKnee,
          PoseLandmarkIndex.leftAnkle,
        ],
        targetReps: 8,
        difficulty: DifficultyLevel.medium,
        estimatedDuration: const Duration(minutes: 5),
        estimatedCalories: 45,
        iconData: Icons.fitness_center,
        gradientColors: const [Color(0xFF8BA5C4), Color(0xFF7B95B4)],
        targetMuscle: 'Bacak & Kalça',
        phonePosition: PhonePosition.floor,
        instructions: [
          'Telefonu yere koy, tam vücudun görünsün',
          'Ayaklar omuz genişliğinde, sırt düz',
          'Kalçanı geriye iterek yavaşça çömel',
          'Alt noktada 1 saniye tut, sonra kalk',
        ],
      );

  /// Boyun Hareketi (Ön Kamera)
  static ExerciseConfig neckMovement() => ExerciseConfig(
        type: ExerciseType.neckMovement,
        displayName: 'Boyun Eğme',
        description: 'Başı sağa ve sola eğerek boyun kaslarını esnet.',
        eccentricThreshold: 0,
        concentricThreshold: 0,
        completionThreshold: 0,
        minRangeOfMotion: 0,
        primaryLandmarks: [
          PoseLandmarkIndex.nose,
          PoseLandmarkIndex.leftEar,
          PoseLandmarkIndex.rightEar,
        ],
        secondaryLandmarks: [
          PoseLandmarkIndex.leftShoulder,
          PoseLandmarkIndex.rightShoulder,
        ],
        difficulty: DifficultyLevel.easy,
        estimatedDuration: const Duration(minutes: 3),
        estimatedCalories: 10,
        iconData: Icons.self_improvement,
        gradientColors: const [Color(0xFFA8B5A0), Color(0xFF98A590)],
        targetMuscle: 'Boyun & Omuz',
        phonePosition: PhonePosition.hand,
        instructions: [
          'Telefonu yüzüne doğru tut',
          'Başını yavaşça sağ omzuna doğru eğ',
          '2 saniye bekle, sonra sola eğ',
          'Omuzlarını sabit tut, sadece başını hareket ettir',
        ],
      );

  // ─────────────────────────────────────────
  // 🔒 Kilitli / Yakında Egzersizler
  // ─────────────────────────────────────────

  static ExerciseConfig pushUpLocked() => ExerciseConfig(
        type: ExerciseType.pushUp,
        displayName: 'Şınav',
        description: 'Klasik şınav hareketi. Yakında!',
        eccentricThreshold: 0,
        concentricThreshold: 0,
        completionThreshold: 0,
        minRangeOfMotion: 0,
        primaryLandmarks: [],
        difficulty: DifficultyLevel.hard,
        estimatedDuration: const Duration(minutes: 5),
        estimatedCalories: 50,
        iconData: Icons.sports_gymnastics,
        gradientColors: const [Color(0xFFB8A0D4), Color(0xFFA08BC4)],
        targetMuscle: 'Göğüs & Kol',
        phonePosition: PhonePosition.floor,
        isLocked: true,
        instructions: [],
      );

  static ExerciseConfig lungeLocked() => ExerciseConfig(
        type: ExerciseType.lunge,
        displayName: 'Lunge',
        description: 'Adım atarak çömelme. Yakında!',
        eccentricThreshold: 0,
        concentricThreshold: 0,
        completionThreshold: 0,
        minRangeOfMotion: 0,
        primaryLandmarks: [],
        difficulty: DifficultyLevel.medium,
        estimatedDuration: const Duration(minutes: 5),
        estimatedCalories: 40,
        iconData: Icons.directions_walk,
        gradientColors: const [Color(0xFFD4A574), Color(0xFFB8845E)],
        targetMuscle: 'Bacak',
        phonePosition: PhonePosition.floor,
        isLocked: true,
        instructions: [],
      );

  static ExerciseConfig shoulderPressLocked() => ExerciseConfig(
        type: ExerciseType.shoulderPress,
        displayName: 'Omuz Press',
        description: 'Omuz presi hareketi. Yakında!',
        eccentricThreshold: 0,
        concentricThreshold: 0,
        completionThreshold: 0,
        minRangeOfMotion: 0,
        primaryLandmarks: [],
        difficulty: DifficultyLevel.medium,
        estimatedDuration: const Duration(minutes: 4),
        estimatedCalories: 35,
        iconData: Icons.arrow_upward,
        gradientColors: const [Color(0xFF8BA5C4), Color(0xFF6B8FB4)],
        targetMuscle: 'Omuz',
        phonePosition: PhonePosition.table,
        isLocked: true,
        instructions: [],
      );

  /// Tüm egzersizlerin listesi (aktif + kilitli)
  static List<ExerciseConfig> allExercises() => [
        neckMovement(),
        squat(),
        shoulderStretch(),
        pushUpLocked(),
        lungeLocked(),
        shoulderPressLocked(),
      ];

  /// Sadece aktif (açık) egzersizler
  static List<ExerciseConfig> activeExercises() =>
      allExercises().where((e) => !e.isLocked).toList();
}
