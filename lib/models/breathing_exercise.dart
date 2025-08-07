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

  static List<BreathingExercise> get allExercises => [
        // =========== ODAKLANMA (FOCUS & PERFORMANCE) ===========
        const BreathingExercise(
          type: BreathingType.boxBreathing,
          name: 'Kutu Nefesi',
          description:
              'Zihinsel berraklık ve sakinlik için dört eşit aşamalı bir tekniktir. Stresli anlarda topraklanmanıza yardımcı olur.',
          purpose: 'Odaklanma ve Denge',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Nefes Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 4, instruction: 'Tut (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Nefes Ver (4 sn)'),
            BreathingStep(type: BreathingStepType.holdAfterExhale, duration: 4, instruction: 'Bekle (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.intermediate,
        ),
        const BreathingExercise(
          type: BreathingType.alternateNostril,
          name: 'Değişken Burun Nefesi',
          description:
              'Beynin sağ ve sol yarım kürelerini dengeleyerek zihinsel netliği ve odaklanmayı artırır. Sakinleştirici ve dengeleyici bir etkisi vardır.',
          purpose: 'Zihinsel Netlik',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Soldan Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 4, instruction: 'Tut (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 8, instruction: 'Sağdan Ver (8 sn)'),
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Sağdan Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 4, instruction: 'Tut (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 8, instruction: 'Soldan Ver (8 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.advanced,
          isPremium: true,
        ),
        const BreathingExercise(
          type: BreathingType.stimulatingBreath,
          name: 'Uyarıcı Nefes',
          description:
              'Hızlı ve ritmik nefeslerle zihinsel sisliliği dağıtarak güne enerjik bir başlangıç yapmanızı veya öğleden sonraki yorgunluğu atmanızı sağlar.',
          purpose: 'Zihinsel Uyanıklık',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 2, instruction: 'Hızlıca Al'),
            BreathingStep(type: BreathingStepType.exhale, duration: 2, instruction: 'Hızlıca Ver'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
        ),

        // =========== KAYGI VE STRES AZALTICI (ANXIETY & STRESS RELIEF) ===========
        const BreathingExercise(
          type: BreathingType.breathing478,
          name: '4-7-8 Tekniği',
          description:
              'Parasempatik sinir sistemini aktive ederek bedeni ve zihni hızla sakinleştiren, "rahatlatıcı nefes" olarak da bilinen güçlü bir tekniktir.',
          purpose: 'Hızlı Sakinleşme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Nefes Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 7, instruction: 'Tut (7 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 8, instruction: 'Yavaşça Ver (8 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.intermediate,
        ),
        const BreathingExercise(
          type: BreathingType.samaVritti,
          name: 'Eşit Nefes (Sama Vritti)',
          description:
              'Eşit süreli nefes alıp verme, sinir sistemini dengeleyerek anksiyeteyi azaltır ve zihinsel denge sağlar. Başlangıç için harikadır.',
          purpose: 'Sinir Sistemini Dengeleme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Nefes Al (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 4, instruction: 'Nefes Ver (4 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.coherentBreathing,
          name: 'Uyumlu Nefes',
          description:
              'Dakikada yaklaşık 5-6 nefes döngüsü ile kalp atış değişkenliğini (HRV) optimize ederek stres seviyelerini düşürür ve duygusal dayanıklılığı artırır.',
          purpose: 'Duygusal Dayanıklılık',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Nefes Al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 5, instruction: 'Nefes Ver (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.intermediate,
          isPremium: true,
        ),
        const BreathingExercise(
          type: BreathingType.triangleBreathing,
          name: 'Üçgen Nefesi (4-7-8)',
          description:
              '4-7-8 tekniğinin bir varyasyonu olan bu yöntem, görsel bir üçgen imgesiyle kaygıyı azaltmaya ve ana odaklanmaya yardımcı olur.',
          purpose: 'Anksiyete Giderme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Nefes Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 7, instruction: 'Tut (7 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 8, instruction: 'Yavaşça Ver (8 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.intermediate,
          isPremium: true,
        ),

        // =========== UYKU VE RAHATLAMA (SLEEP & RELAXATION) ===========
        const BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Diyafram Nefesi',
          description:
              'Karından derin nefes alarak sinir sistemini rahatlatır, "savaş ya da kaç" tepkisini azaltır ve derin bir gevşeme hissi yaratır.',
          purpose: 'Derin Gevşeme',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Derin Nefes Al (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Yavaşça Bırak (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
        ),
        const BreathingExercise(
          type: BreathingType.progressiveRelaxation,
          name: 'Aşamalı Gevşeme Nefesi',
          description:
              'Farklı kas gruplarını sıkıp bırakırken nefesinizi koordine ederek vücuttaki fiziksel gerilimi atmanıza ve uykuya hazırlanmanıza yardımcı olur.',
          purpose: 'Fiziksel Gerilimi Azaltma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 5, instruction: 'Gerilirken Nefes Al (5 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 7, instruction: 'Gevşerken Ver (7 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.intermediate,
          isPremium: true,
        ),
        const BreathingExercise(
          type: BreathingType.moonBreathing,
          name: 'Ay Nefesi (Chandra Bhedana)',
          description:
              'Sadece sol burun deliğinden nefes alarak yapılan bu teknik, vücut ısısını düşürür ve parasempatik sinir sistemini aktive ederek uykuya geçişi kolaylaştırır.',
          purpose: 'Zihni ve Vücudu Soğutma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 4, instruction: 'Soldan Al (4 sn)'),
            BreathingStep(type: BreathingStepType.hold, duration: 4, instruction: 'Tut (4 sn)'),
            BreathingStep(type: BreathingStepType.exhale, duration: 6, instruction: 'Sağdan Ver (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.advanced,
          isPremium: true,
        ),

        // =========== ENERJİ VE CANLILIK (ENERGY & VITALITY) ===========
        const BreathingExercise(
          type: BreathingType.wimHof,
          name: 'Wim Hof Metodu',
          description:
              'Güçlü, döngüsel nefesler ve ardından nefes tutma periyotları ile enerji seviyelerini yükseltir, odaklanmayı artırır ve bağışıklık sistemini güçlendirir.',
          purpose: 'Enerji Patlaması ve Odak',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 2, instruction: 'Güçlü Al'),
            BreathingStep(type: BreathingStepType.exhale, duration: 1, instruction: 'Bırak'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.advanced,
          isPremium: true,
        ),
        const BreathingExercise(
          type: BreathingType.kapalabhati,
          name: 'Kafatası Parlatan Nefes',
          description:
              'Karından yapılan güçlü ve pasif nefes verişlerle toksinlerin atılmasına, metabolizmanın hızlanmasına ve zihnin canlanmasına yardımcı olur.',
          purpose: 'Toksinlerden Arınma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 2, instruction: 'Normal Al'),
            BreathingStep(type: BreathingStepType.exhale, duration: 1, instruction: 'Güçlü Ver'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.advanced,
          isPremium: true,
        ),
        const BreathingExercise(
          type: BreathingType.bellowsBreath,
          name: 'Körük Nefesi (Bhastrika)',
          description:
              'Hızlı ve güçlü nefeslerle akciğer kapasitesini artırır, kan dolaşımını hızlandırır ve anında enerji patlaması sağlar.',
          purpose: 'Anında Canlanma',
          steps: [
            BreathingStep(type: BreathingStepType.inhale, duration: 1, instruction: 'Güçlü Al'),
            BreathingStep(type: BreathingStepType.exhale, duration: 1, instruction: 'Güçlü Ver'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.intermediate,
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