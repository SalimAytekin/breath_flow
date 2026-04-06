import '../models/fitness_exercise.dart';

/// BreathFlow AI Fitness — Statik İçerik Katmanı
/// 12 Çekirdek Egzersiz + 11 Program (4 kategori)
/// Her program: whyItWorks, weekCount, isFeatured alanlarıyla tam dolu.
class FitnessContent {
  FitnessContent._();

  // ─────────────────────────────────────────────
  // 12 ÇEKİRDEK EGZERSİZ
  // ─────────────────────────────────────────────

  // Posture
  static const FitnessExercise chinTuck = FitnessExercise(
    id: 'chin_tuck',
    name: 'Chin Tuck',
    description: 'Baş ileri duruşunu (forward head posture) düzelten en etkili terapi hareketi.',
    category: FitnessCategory.posture,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '10 tekrar',
    icon: '🧘',
    muscleGroup: 'Neck & Upper Back',
    isAiEnabled: true,
    nativeExerciseKey: 'neck_rotation',
  );

  static const FitnessExercise wallAngels = FitnessExercise(
    id: 'wall_angels',
    name: 'Wall Angels',
    description: 'Yuvarlak omuzları düzelten, kürek kemiklerini aktive eden postür egzersizi.',
    category: FitnessCategory.posture,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '8 tekrar',
    icon: '🕊️',
    muscleGroup: 'Shoulders & Upper Back',
    isAiEnabled: true,
    nativeExerciseKey: 'shoulder_stretch',
  );

  static const FitnessExercise catCow = FitnessExercise(
    id: 'cat_cow',
    name: 'Cat Cow',
    description: 'Omurganın tüm uzunluğunu mobilize eden ritmik yoga hareketi.',
    category: FitnessCategory.posture,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '60 sn',
    icon: '🐱',
    muscleGroup: 'Spine & Core',
  );

  static const FitnessExercise thoracicExtension = FitnessExercise(
    id: 'thoracic_extension',
    name: 'Thoracic Extension',
    description: 'Göğüs omurlarını açıp kamburluğu gideren derin sırt mobilizasyon hareketi.',
    category: FitnessCategory.posture,
    difficulty: DifficultyLevel.intermediate,
    durationLabel: '45 sn',
    icon: '🌊',
    muscleGroup: 'Thoracic Spine',
  );

  // Strength
  static const FitnessExercise squat = FitnessExercise(
    id: 'squat',
    name: 'Squat',
    description: 'Bacak ve kalça kaslarını güçlendiren temel hareket. AI form analizi ile.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '12 tekrar',
    icon: '🏋️',
    muscleGroup: 'Legs & Glutes',
    isAiEnabled: true,
    nativeExerciseKey: 'squat',
  );

  static const FitnessExercise pushUp = FitnessExercise(
    id: 'push_up',
    name: 'Push Up',
    description: 'Göğüs, omuz ve triceps kaslarını aynı anda çalıştıran temel kuvvet egzersizi.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '10 tekrar',
    icon: '💪',
    muscleGroup: 'Chest, Shoulders & Triceps',
    isAiEnabled: true,
    nativeExerciseKey: 'pushup',
  );

  static const FitnessExercise lunge = FitnessExercise(
    id: 'lunge',
    name: 'Lunge',
    description: 'Alt vücudu güçlendiren, denge ve koordinasyonu geliştiren tek bacak hareketi.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '10 tekrar',
    icon: '🦵',
    muscleGroup: 'Legs & Balance',
  );

  static const FitnessExercise gluteBridge = FitnessExercise(
    id: 'glute_bridge',
    name: 'Glute Bridge',
    description: 'Kalça kasları ve alt sırtı güçlendiren, pelvik deviasyonu gideren hareket.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '15 tekrar',
    icon: '🌉',
    muscleGroup: 'Glutes & Lower Back',
  );

  // Core
  static const FitnessExercise plank = FitnessExercise(
    id: 'plank',
    name: 'Plank',
    description: 'Karın, sırt ve tüm gövde stabilitesini hedef alan core egzersizinin temeli.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '30 sn',
    icon: '🔲',
    muscleGroup: 'Core & Stability',
    isAiEnabled: true,
    nativeExerciseKey: 'ab_crunch',
  );

  static const FitnessExercise birdDog = FitnessExercise(
    id: 'bird_dog',
    name: 'Bird Dog',
    description: 'Core stabilitesini ve koordinasyonu geliştiren denge egzersizi.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '10 tekrar',
    icon: '🐦',
    muscleGroup: 'Core & Balance',
  );

  static const FitnessExercise superman = FitnessExercise(
    id: 'superman',
    name: 'Superman',
    description: 'Sırt ekstansör kasları ve kalça arkasını güçlendiren zemin egzersizi.',
    category: FitnessCategory.strength,
    difficulty: DifficultyLevel.beginner,
    durationLabel: '12 tekrar',
    icon: '🦸',
    muscleGroup: 'Lower Back & Glutes',
  );

  // Conditioning
  static const FitnessExercise mountainClimbers = FitnessExercise(
    id: 'mountain_climbers',
    name: 'Mountain Climbers',
    description: 'Kalp atışını hızlandıran, core ve kardiyoyu aynı anda zorlayan HIIT hareketi.',
    category: FitnessCategory.quick,
    difficulty: DifficultyLevel.intermediate,
    durationLabel: '30 sn',
    icon: '⛰️',
    muscleGroup: 'Full Body Cardio',
  );

  // ─────────────────────────────────────────────
  // 11 PROGRAM PAKETİ
  // ─────────────────────────────────────────────

  // 🧘 POSTURE & THERAPY (4 program, isFeatured: posture21DayReset)

  static const FitnessProgram posture21DayReset = FitnessProgram(
    id: 'posture_21_day_reset',
    name: '21 Day Posture Reset',
    subtitle: '4 hareket • 3 hafta',
    description: '21 günde baş ileri duruşu ve yuvarlak omuzları tamamen sıfırlayan AI destekli terapi programı. Masa başı çalışanlar için tasarlandı.',
    whyItWorks:
        'Chin Tuck ve Wall Angels kombinasyonu, derin boyun fleksörlerini ve kürek kemiği stabilizatörlerini progresif biçimde aktive eder. Günlük tekrar, kas belleğini yeniden programlar.',
    category: FitnessCategory.posture,
    exercises: [chinTuck, wallAngels, thoracicExtension, catCow],
    totalDuration: '10 dk',
    weekCount: 3,
    difficulty: DifficultyLevel.beginner,
    icon: '🧘',
    isNew: true,
    isPremium: true,
    isFeatured: true,
  );

  static const FitnessProgram neckPainRelief = FitnessProgram(
    id: 'neck_pain_relief',
    name: 'Neck Pain Relief',
    subtitle: '2 hareket • Tek seferlik',
    description: 'Boyun ağrısını ve sertliğini hızla gideren, masa başında her gün uygulanabilen terapi serisi.',
    whyItWorks:
        'Chin Tuck boyun kaslarındaki refleks gerilimini azaltırken Wall Angels skapular retraksiyon oluşturarak ağrının kaynağını hedefler.',
    category: FitnessCategory.posture,
    exercises: [chinTuck, wallAngels],
    totalDuration: '5 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '🌿',
  );

  static const FitnessProgram officeBackRescue = FitnessProgram(
    id: 'office_back_rescue',
    name: 'Office Back Rescue',
    subtitle: '3 hareket • Tek seferlik',
    description: 'Günün omurga yorgunluğunu ve bel ağrısını gideren, ofis çalışanı için tasarlanmış kurtarma serisi.',
    whyItWorks:
        'Cat Cow omurga nötralizasyonunu sağlar, Thoracic Extension torasik hareketliliği geri kazandırır, Glute Bridge alt sırttaki baskıyı kalçaya aktararak rahatlatır.',
    category: FitnessCategory.posture,
    exercises: [catCow, thoracicExtension, gluteBridge],
    totalDuration: '8 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '💼',
    isNew: true,
  );

  static const FitnessProgram shoulderOpener = FitnessProgram(
    id: 'shoulder_opener',
    name: 'Shoulder Opener',
    subtitle: '2 hareket • Tek seferlik',
    description: 'Sıkışmış ve yuvarlak omuzu açan, kürek kemiklerini doğru pozisyona getiren seri.',
    whyItWorks:
        'Thoracic Extension göğüs kafesini açarak omuzların geriye gitmesine yer açar, Wall Angels ise bu açıklığı kas kuvvetiyle kilitlemeye yardım eder.',
    category: FitnessCategory.posture,
    exercises: [wallAngels, thoracicExtension],
    totalDuration: '6 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '🕊️',
  );

  // 💪 STRENGTH (4 program, isFeatured: strengthStarter30Day)

  static const FitnessProgram strengthStarter30Day = FitnessProgram(
    id: 'strength_starter_30_day',
    name: '30 Day Strength Starter',
    subtitle: '6 hareket • 4 hafta • Split sistem',
    description: '30 günde sıfırdan güçlü bir vücut inşa eden başlangıç programı. Pzt Alt Vücut, Çrş Üst Vücut, Cum Core split sistemi.',
    whyItWorks:
        'Split sistem kas gruplarına ayrı toparlanma süresi tanır, progresif yükleme ile her hafta adaptasyon sağlanır. 4 haftada ölçülebilir güç artışı elde edilir.',
    category: FitnessCategory.strength,
    exercises: [squat, lunge, gluteBridge, pushUp, plank, birdDog],
    totalDuration: '12 dk',
    weekCount: 4,
    difficulty: DifficultyLevel.beginner,
    icon: '🔥',
    isPremium: true,
    isFeatured: true,
  );

  static const FitnessProgram lowerBodyBuilder = FitnessProgram(
    id: 'lower_body_builder',
    name: 'Lower Body Builder',
    subtitle: '3 hareket • Tek seferlik',
    description: 'Squat, Lunge ve Glute Bridge üçlemesiyle bacak ve kalça kaslarını yoğun çalıştıran seri.',
    whyItWorks:
        'Bu üç hareket büyük kas gruplarını (quadriceps, hamstrings, gluteus maximus) sırayla zorlayarak maksimum metabolik tepki oluşturur.',
    category: FitnessCategory.strength,
    exercises: [squat, lunge, gluteBridge],
    totalDuration: '10 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.intermediate,
    icon: '🦵',
  );

  static const FitnessProgram coreStability = FitnessProgram(
    id: 'core_stability',
    name: 'Core Stability',
    subtitle: '3 hareket • Tek seferlik',
    description: 'Merkezi güç sistemini güçlendiren, sırtı koruyan ve vücut dengesini artıran bilimsel egzersiz serisi.',
    whyItWorks:
        'Plank, Bird Dog ve Superman; transversus abdominis, multifidus ve erector spinae kaslarını birlikte aktive ederek omurgayı 360° korur.',
    category: FitnessCategory.strength,
    exercises: [plank, birdDog, superman],
    totalDuration: '8 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '⚡',
  );

  static const FitnessProgram sevenMinFullBody = FitnessProgram(
    id: 'seven_min_full_body',
    name: '7 Minute Full Body',
    subtitle: '4 hareket • Devre sistemi',
    description: 'Squat, Push Up, Plank ve Mountain Climbers ile tüm vücudu 7 dakikada çalıştıran bilim destekli yoğun seri.',
    whyItWorks:
        'HIIT formatında uygulanan bu devre, VO2 max değerini yükseltir ve egzersiz sonrası 24 saate kadar artan kalori yakmayı (EPOC etkisi) tetikler.',
    category: FitnessCategory.strength,
    exercises: [squat, pushUp, plank, mountainClimbers],
    totalDuration: '7 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.intermediate,
    icon: '⏱️',
    isNew: true,
  );

  // 🌿 MOBILITY & YOGA (3 program, isFeatured: morningMobilityFlow)

  static const FitnessProgram morningMobilityFlow = FitnessProgram(
    id: 'morning_mobility_flow',
    name: 'Morning Mobility Flow',
    subtitle: '3 hareket • Sabah rutini',
    description: 'Güne tüm vücudu uyandırarak başlatan, eklem hareket açıklığını artıran sabah ritüeli.',
    whyItWorks:
        'Uyku sonrası kaslar kısalmış ve sinovyal sıvı kısmen azalmış olur. Bu akış eklem sıvısını yeniden dağıtarak sabah sertliğini giderir.',
    category: FitnessCategory.mobility,
    exercises: [catCow, thoracicExtension, gluteBridge],
    totalDuration: '8 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '🌅',
    isFeatured: true,
  );

  static const FitnessProgram preWorkoutMobility = FitnessProgram(
    id: 'pre_workout_mobility',
    name: 'Pre Workout Mobility',
    subtitle: '3 hareket • Isınma rutini',
    description: 'Antrenman öncesi kasları ve eklemleri hazırlayan, sakatlık riskini azaltan ısınma serisi.',
    whyItWorks:
        'Dinamik mobilizasyon, statik esneme fazından daha etkili: kan akışını artırır, nöromusküler uyarılmayı hazırlar ve güç çıktısını optimize eder.',
    category: FitnessCategory.mobility,
    exercises: [catCow, thoracicExtension, lunge],
    totalDuration: '5 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '🌿',
  );

  static const FitnessProgram eveningUnwind = FitnessProgram(
    id: 'evening_unwind',
    name: 'Evening Unwind',
    subtitle: '3 hareket • Gece rutini',
    description: 'Günün gerginliğini gidermek ve uykuya hazırlanmak için sakinleştirici akış.',
    whyItWorks:
        'Yavaş tempolu mobilizasyon parasempatik sinir sistemini aktive ederek kortizol düzeyini düşürür ve uyku kalitesini artırır.',
    category: FitnessCategory.mobility,
    exercises: [catCow, chinTuck, gluteBridge],
    totalDuration: '6 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '🌙',
    isNew: true,
  );

  // ⚡ QUICK WORKOUTS (2 program, isFeatured: fiveMinBodyReset)

  static const FitnessProgram fiveMinBodyReset = FitnessProgram(
    id: 'five_min_body_reset',
    name: '5 Minute Body Reset',
    subtitle: '3 hareket • 5 dakika',
    description: 'Gün içinde herhangi bir anda enerjiyi ve odağı geri getiren 5 dakikalık express rutin.',
    whyItWorks:
        'Kısa süreli yüksek kaliteli hareket, düşük yoğunluklu uzun antrenmanlardan daha yüksek enerji algısı yaratır. Dopamin ve norepinefrin salgılanmasını hızlıca tetikler.',
    category: FitnessCategory.quick,
    exercises: [chinTuck, catCow, mountainClimbers],
    totalDuration: '5 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.beginner,
    icon: '⚡',
    isFeatured: true,
  );

  static const FitnessProgram tenMinCore = FitnessProgram(
    id: 'ten_min_core',
    name: '10 Minute Core Blast',
    subtitle: '4 hareket • 10 dakika',
    description: '10 dakikada core bölgesini derinlemesine hedef alan yüksek yoğunluklu seri.',
    whyItWorks:
        'Dört farklı core hareketi sıralanarak her açıdan gövde kasları çalıştırılır. Toparlanma arası olmadan yapılması metabolik yükü maksimize eder.',
    category: FitnessCategory.quick,
    exercises: [plank, mountainClimbers, birdDog, superman],
    totalDuration: '10 dk',
    weekCount: 0,
    difficulty: DifficultyLevel.intermediate,
    icon: '🎯',
    isNew: true,
  );

  // ─────────────────────────────────────────────
  // RECOMMENDATION LOGIC
  // ─────────────────────────────────────────────

  /// Kullanıcının hedefine ve saate göre "Today's Workout" programını döndür.
  static FitnessProgram getRecommendedProgram(UserGoal goal, int hour) {
    switch (goal) {
      case UserGoal.posture:
        return hour < 12 ? officeBackRescue : neckPainRelief;
      case UserGoal.strength:
        return hour < 15 ? lowerBodyBuilder : sevenMinFullBody;
      case UserGoal.mobility:
        return hour < 10 ? morningMobilityFlow : preWorkoutMobility;
      case UserGoal.quick:
        return fiveMinBodyReset;
    }
  }

  /// "SANA ÖZEL" alanı için — max 2 program döndür.
  static List<FitnessProgram> getRecommendedList(UserGoal goal, {int limit = 2}) {
    final preferred = getProgramsByCategory(_goalToCategory(goal));
    final today = getRecommendedProgram(goal, DateTime.now().hour);
    // Today's workout'u tekrar gösterme
    final filtered = preferred.where((p) => p.id != today.id).toList();
    if (filtered.length >= limit) return filtered.take(limit).toList();
    // Eksikse diğer kategorilerden tamamla
    final others = allPrograms
        .where((p) => p.category != _goalToCategory(goal) && p.id != today.id)
        .take(limit - filtered.length)
        .toList();
    return [...filtered, ...others].take(limit).toList();
  }

  /// Kategoriye göre programları döndür (max 4 — 1 featured + 3 diğer).
  static List<FitnessProgram> getProgramsByCategory(FitnessCategory cat) {
    final all = allPrograms.where((p) => p.category == cat).toList();
    // Featured öne al, max 4 döndür
    final featured = all.where((p) => p.isFeatured).toList();
    final rest = all.where((p) => !p.isFeatured).take(3).toList();
    return [...featured, ...rest];
  }

  static FitnessCategory _goalToCategory(UserGoal goal) {
    return switch (goal) {
      UserGoal.posture   => FitnessCategory.posture,
      UserGoal.strength  => FitnessCategory.strength,
      UserGoal.mobility  => FitnessCategory.mobility,
      UserGoal.quick     => FitnessCategory.quick,
    };
  }

  // ─────────────────────────────────────────────
  // TOPLU LİSTELER
  // ─────────────────────────────────────────────

  static const List<FitnessExercise> allExercises = [
    chinTuck, wallAngels, catCow, thoracicExtension,
    squat, pushUp, lunge, gluteBridge,
    plank, birdDog, superman,
    mountainClimbers,
  ];

  static const List<FitnessProgram> allPrograms = [
    posture21DayReset, neckPainRelief, officeBackRescue, shoulderOpener,
    strengthStarter30Day, lowerBodyBuilder, coreStability, sevenMinFullBody,
    morningMobilityFlow, preWorkoutMobility, eveningUnwind,
    fiveMinBodyReset, tenMinCore,
  ];
}
