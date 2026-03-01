import '../data/breathing_exercises_loader.dart';

enum BreathingType {
  boxBreathing,
  breathing478,
  deepBreathing,
  coherentBreathing,
  diaphragmaticBreathing,
  alternateNostril,
  wimHof,
  triangleBreathing,
  resonanceBreathing,
  samaVritti,
  kapalabhati,
  extendedExhale,
  progressiveRelaxation,
  bellowsBreath,
  stimulatingBreath,
  moonBreathing,
  bodyScan,
  threePartBreath,
  energizing,
  vitalizing,
  custom,
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

enum BreathingCategory {
  odaklanma,
  kaygiVeStres,
  uykuVeRahatlama,
  enerjiVeCanlilik,
}

class BreathingExercise {
  final BreathingType type;
  final String name;
  final String description;
  final String purpose;
  final List<BreathingStep> steps;
  final BreathingCategory category;
  final ExerciseDifficulty difficulty;
  final int defaultDuration; // dakika cinsinden
  final bool isPremium;
  final String imagePath;

  BreathingExercise({
    required this.type,
    required this.name,
    required this.description,
    required this.purpose,
    required this.steps,
    required this.category,
    required this.difficulty,
    required this.imagePath,
    this.defaultDuration = 5,
    this.isPremium = false,
  });

  String get timingsFormatted {
    final relevantSteps = steps
        .where((s) =>
            s.type == BreathingStepType.inhale ||
            s.type == BreathingStepType.exhale)
        .toList();
    
    if (relevantSteps.isEmpty) return '';
    
    final inhaleStep = relevantSteps.firstWhere(
      (s) => s.type == BreathingStepType.inhale,
      orElse: () => relevantSteps.first,
    );
    final exhaleStep = relevantSteps.firstWhere(
      (s) => s.type == BreathingStepType.exhale,
      orElse: () => relevantSteps.last,
    );
    
    return '${inhaleStep.duration}sn ${_getStepTypeText(inhaleStep.type)} - ${exhaleStep.duration}sn ${_getStepTypeText(exhaleStep.type)}';
  }

  String _getStepTypeText(BreathingStepType stepType) {
    // Çoklu dil desteği için lokalize loader'dan al
    return BreathingExercisesLoader.getStepTypeText(stepType);
  }

  /// Bir tekrarnün toplam süresini saniye cinsinden döndürür
  int get totalDuration {
    return steps.fold<int>(0, (total, step) => total + step.duration);
  }

  /// Tüm nefes egzersizlerini döndürür (çoklu dil desteği - otomatik lokalize)
  static List<BreathingExercise> get allExercises {
    // Lokalize loader kullanarak seçili dile göre egzersizleri döndür
    return BreathingExercisesLoader.getAllExercises();
  }

  // Eski hardcoded data kaldırıldı - artık lib/data/breathing_exercises_tr.dart dosyasında
  /* static List<BreathingExercise> get allExercises => [
        BreathingExercise(
          type: BreathingType.boxBreathing,
          name: 'Kutu Nefesi (4-4-4-4)',
          description:
              'Nefesini dört aşamada düzenle: al, tut, ver ve bekle. Zihinsel dengeyi artırır.',
          purpose: 'Odaklanma ve Denge',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Şimdi derin bir nefes al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 4, instruction: 'Nefesini içinde tut (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Yavaşça bırak (4 sn)'),
            BreathingStep(type: BreathingStepType.holdAfterExhale, duration: 4, instruction: 'Kısa bir an bekle (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.kutuNefesi,
        ),
        BreathingExercise(
          type: BreathingType.custom,
          name: 'Basit Sayma Nefesi',
          description:
              'Nefes alırken ve verirken sayılara odaklan. Zihni toparlamaya yardımcı olur.',
          purpose: 'Zihinsel Odaklanma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: ' 1\'den 4\'e kadar sayarak nefes al, (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Şimdi 1\'den 4\'e kadar sayarak bırak, (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.basitSaymaNefesi,
          isPremium: true, // Premium egzersiz
        ),
        BreathingExercise(
          type: BreathingType.deepBreathing,
          name: 'Farkındalık Nefesi',
          description:
              'Nefesini doğal akışında gözlemle. Değiştirmeden sadece fark et.',
          purpose: 'Nefes Farkındalığı',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Nefesin doğal akışını hisset (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Hiç değiştirmeden bırak gitsin (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.farkindalikNefesi,
          isPremium: true, // Premium egzersiz
        ),

        // =========== SAKİNLEŞME VE STRES AZALTMA ===========
        BreathingExercise(
          type: BreathingType.extendedExhale,
          name: 'Uzunca Nefes Ver (4-6)',
          description:
              'Kısa al, uzun ver. Bu ritim sinir sistemini sakinleştirir.',
          purpose: 'Doğal Sakinleşme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Rahatça nefes al (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Şimdi daha uzun ve sakin şekilde ver (6 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.uzuncaNefesVer,
        ),
        BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Diyafram Nefesi',
          description:
              'Nefesi karnına doğru al. Göğüsten değil karından nefes almak stresi azaltır.',
          purpose: 'Derin Rahatlama',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Nefesi karnına doğru çek (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Karından yavaşça bırak (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.diyaframNefesi,
          isPremium: true, // Premium egzersiz
        ),
        BreathingExercise(
          type: BreathingType.samaVritti,
          name: 'Eşit Nefes',
          description:
              'Nefes alma ve verme sürelerini eşitleyerek sinir sistemini dengeleyin.',
          purpose: 'Sistem Dengesi',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Eşit bir nefes al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Eşit bir nefes ver (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.esitNefes,
          isPremium: true, // Premium egzersiz
        ),

        // =========== UYKU VE RAHATLAMA ===========
        BreathingExercise(
          type: BreathingType.moonBreathing,
          name: 'Yavaşlatıcı Nefes',
          description:
              'Nefes ritmini yavaşlatarak kalp atış hızını düşürür ve uykuya hazırlar.',
          purpose: 'Uykuya Hazırlık',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Yavaşça nefes al (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 8, instruction: 'Çok yavaşça ve uzun bırak (8 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.yavaslaticiNefes,
        ),
        BreathingExercise(
          type: BreathingType.bodyScan,
          name: 'Beden Farkındalığı Nefesi',
          description:
              'Nefes alırken bedenin farklı bölgelerine odaklanarak gerginliği serbest bırakır.',
          purpose: 'Beden Gevşetme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Nefes alırken bedenini tarayın (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Gerginliği bırakarak verin (5 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.bedenFarkindaligiNefesi,
          isPremium: true, // Premium egzersiz
        ),
        BreathingExercise(
          type: BreathingType.progressiveRelaxation,
          name: 'Gevşeme Nefesi',
          description:
              'Derin bir rahatlama hissi yaratır ve uykuya geçişi kolaylaştırır.',
          purpose: 'Derin Gevşeme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 6, instruction: 'Derin bir nefes al (6 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Tüm gerginliği bırak (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.gevseemeNefesi,
          isPremium: true, // Premium egzersiz
        ),

        // =========== ENERJİ VE CANLILIK ===========
        BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Canlandırıcı Diyafram',
          description:
              'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.',
          purpose: 'Enerji Artırma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Diyaframdan derin nefes al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Enerjiyle bırak gitsin (5 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.canlandiriciDiyafram,
        ),
        BreathingExercise(
          type: BreathingType.stimulatingBreath,
          name: 'Sabah Nefesi',
          description:
              'Güne derin ve canlı nefeslerle başla. Sabah enerjini yükseltir.',
          purpose: 'Sabah Enerjisi',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 6, instruction: 'Sabah enerjisiyle nefes al (6 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 2, instruction: 'Enerjiyi içinde tut (2 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Canlılıkla bırak (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.sabahNefesi,
          isPremium: true, // Premium egzersiz
        ),
        BreathingExercise(
          type: BreathingType.resonanceBreathing,
          name: 'Güne Başlama Nefesi',
          description:
              'Pozitif enerjiyle nefes al, hafif şekilde ver. Güne hazırlar.',
          purpose: 'Pozitif Enerji',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 6, instruction: 'Pozitif enerjiyle derin bir nefes al (6 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Canlılıkla bırak gitsin (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.guneBaslamaNefesi,
          isPremium: true, // Premium egzersiz
        ),
      ]; */

  int get totalCycleTime => steps.fold(0, (sum, step) => sum + step.duration);
}

enum BreathingStepType {
  inhale,
  hold,
  exhale,
  holdAfterExhale, // Nefes verdikten sonra tutma
}

class BreathingStep {
  final BreathingStepType type;
  final int duration; // saniye
  final String instruction;

  const BreathingStep({
    required this.type,
    required this.duration,
    required this.instruction,
  });
}

enum BreathingState {
  idle,
  running,
  paused,
  completed,
}