import '../constants/app_strings.dart';
import 'package:flutter/material.dart';

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

  const BreathingExercise({
    required this.type,
    required this.name,
    required this.description,
    required this.purpose,
    required this.steps,
    required this.category,
    required this.difficulty,
    this.defaultDuration = 5,
    this.isPremium = false,
  });

  String get timingsFormatted {
    final relevantSteps = steps
        .where((s) =>
            s.type == BreathingStepType.inhale ||
            s.type == BreathingStepType.hold ||
            s.type == BreathingStepType.exhale ||
            s.type == BreathingStepType.holdAfterExhale)
        .toList();
    return relevantSteps
        .map((step) => '${step.duration}sn ${_getStepName(step.type)}')
        .join(' · ');
  }

  String _getStepName(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return 'al';
      case BreathingStepType.hold:
        return 'tut';
      case BreathingStepType.exhale:
        return 'ver';
      case BreathingStepType.holdAfterExhale:
        return 'bekle';
      default:
        return '';
    }
  }

  /// Bir döngünün toplam süresini saniye cinsinden döndürür
  int get totalDuration {
    return steps.fold<int>(0, (total, step) => total + step.duration);
  }

  static List<BreathingExercise> get allExercises => [
        // =========== ODAKLANMA VE DİKKAT ===========
        const BreathingExercise(
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
        ),
        const BreathingExercise(
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
        ),
        const BreathingExercise(
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
        ),

        // =========== SAKİNLEŞME VE STRES AZALTMA ===========
        const BreathingExercise(
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
        ),
        const BreathingExercise(
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
        ),
        const BreathingExercise(
          type: BreathingType.samaVritti,
          name: 'Eşit Nefes',
          description:
              'Nefesi aynı sürede alıp ver. Zihinsel denge ve iç huzur sağlar.',
          purpose: 'Zihinsel Denge',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: '4 saniyede nefes al'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Aynı sürede bırak'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
        ),

        // =========== UYKU VE RAHATLAMA ===========
        const BreathingExercise(
          type: BreathingType.custom,
          name: 'Yavaşlatıcı Nefes',
          description:
              'Her nefeste ritmi biraz daha yavaşlat. Bedenini uykuya hazırlar.',
          purpose: 'Uyku Hazırlığı',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Nefesini yavaşça al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 7, instruction: 'Şimdi daha yavaş şekilde bırak (7 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.bodyScan,
          name: 'Beden Farkındalığı Nefesi',
          description:
              'Nefes alırken bedenine odaklan. Gerginlikleri fark et ve bırak.',
          purpose: 'Vücut Farkındalığı',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Nefesine odaklan, bedenini hisset (5 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 2, instruction: 'Kısa bir an nefesini tut ve hisset (2 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Şimdi bırak gitsin, rahatla (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Gevşeme Nefesi (3-6)',
          description:
              'Kısa nefes al, uzun nefes ver. Vücudun derin rahatlama yaşar.',
          purpose: 'Derin Gevşeme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 3, instruction: 'Kısa bir nefes al (3 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Uzunca bırak, gevşemene izin ver (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
        ),

        // =========== ENERJİ VE CANLANMA ===========
        const BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Canlandırıcı Diyafram',
          description:
              'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.',
          purpose: 'Doğal Canlanma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Karnından derin bir nefes al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Aynı derinlikte bırak (5 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.deepBreathing,
          name: 'Sabah Nefesi',
          description:
              'Güne derin ve canlı nefeslerle başla. Sabah enerjini yükseltir.',
          purpose: 'Güne Başlama',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 6, instruction: 'Derin bir nefesle sabahı içine çek (6 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 2, instruction: 'Biraz bekle, enerjiyi hisset (2 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Şimdi nefesini canlı bir şekilde bırak (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.resonanceBreathing,
          name: 'Güne Başlama Nefesi (6-4)',
          description:
              'Pozitif enerjiyle nefes al, hafif şekilde ver. Güne hazırlar.',
          purpose: 'Pozitif Enerji',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 6, instruction: 'Pozitif enerjiyle derin bir nefes al (6 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Canlılıkla bırak gitsin (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
        ),
      ];

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