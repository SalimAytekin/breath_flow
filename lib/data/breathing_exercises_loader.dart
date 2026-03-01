import '../models/breathing_exercise.dart';
import '../services/asset_manager.dart';
import '../constants/app_strings.dart';

/// 🌍 Lokalize Nefes Egzersizleri Yükleyici
/// 
/// Bu sınıf, seçili dile göre egzersiz verilerini yükler.
/// Tüm metinler AppStrings üzerinden easy_localization ile çevrilir.
class BreathingExercisesLoader {
  
  /// Step type text'lerini lokalize olarak döndürür
  /// JSON'daki 'inhale', 'hold', 'exhale', 'holdAfterExhale' key'lerini kullanır
  static String getStepTypeText(BreathingStepType stepType) {
    switch (stepType) {
      case BreathingStepType.inhale:
        return AppStrings.inhale;
      case BreathingStepType.hold:
        return AppStrings.hold;
      case BreathingStepType.exhale:
        return AppStrings.exhale;
      case BreathingStepType.holdAfterExhale:
        return AppStrings.holdAfterExhale;
    }
  }

  /// Tüm lokalize nefes egzersizlerini döndürür
  static List<BreathingExercise> getAllExercises() => [
    // =========== ODAKLANMA VE DİKKAT ===========
    BreathingExercise(
      type: BreathingType.boxBreathing,
      name: AppStrings.exerciseBoxBreathingName,
      description: AppStrings.exerciseBoxBreathingDesc,
      purpose: AppStrings.exerciseBoxBreathingPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseBoxBreathingStep1,
        ),
        BreathingStep(
          type: BreathingStepType.hold,
          duration: 4,
          instruction: AppStrings.exerciseBoxBreathingStep2,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 4,
          instruction: AppStrings.exerciseBoxBreathingStep3,
        ),
        BreathingStep(
          type: BreathingStepType.holdAfterExhale,
          duration: 4,
          instruction: AppStrings.exerciseBoxBreathingStep4,
        ),
      ],
      category: BreathingCategory.odaklanma,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.kutuNefesi,
    ),
    
    BreathingExercise(
      type: BreathingType.custom,
      name: AppStrings.exerciseSimpleCountingName,
      description: AppStrings.exerciseSimpleCountingDesc,
      purpose: AppStrings.exerciseSimpleCountingPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseSimpleCountingStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 4,
          instruction: AppStrings.exerciseSimpleCountingStep2,
        ),
      ],
      category: BreathingCategory.odaklanma,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.basitSaymaNefesi,
      isPremium: true,
    ),
    
    BreathingExercise(
      type: BreathingType.deepBreathing,
      name: AppStrings.exerciseAwarenessName,
      description: AppStrings.exerciseAwarenessDesc,
      purpose: AppStrings.exerciseAwarenessPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseAwarenessStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 4,
          instruction: AppStrings.exerciseAwarenessStep2,
        ),
      ],
      category: BreathingCategory.odaklanma,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.farkindalikNefesi,
      isPremium: true,
    ),

    // =========== SAKİNLEŞME VE STRES AZALTMA ===========
    BreathingExercise(
      type: BreathingType.extendedExhale,
      name: AppStrings.exerciseExtendedExhaleName,
      description: AppStrings.exerciseExtendedExhaleDesc,
      purpose: AppStrings.exerciseExtendedExhalePurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseExtendedExhaleStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 6,
          instruction: AppStrings.exerciseExtendedExhaleStep2,
        ),
      ],
      category: BreathingCategory.kaygiVeStres,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.uzuncaNefesVer,
    ),
    
    BreathingExercise(
      type: BreathingType.diaphragmaticBreathing,
      name: AppStrings.exerciseDiaphragmName,
      description: AppStrings.exerciseDiaphragmDesc,
      purpose: AppStrings.exerciseDiaphragmPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 5,
          instruction: AppStrings.exerciseDiaphragmStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 5,
          instruction: AppStrings.exerciseDiaphragmStep2,
        ),
      ],
      category: BreathingCategory.kaygiVeStres,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.diyaframNefesi,
    ),
    
    BreathingExercise(
      type: BreathingType.samaVritti,
      name: AppStrings.exerciseEqualBreathName,
      description: AppStrings.exerciseEqualBreathDesc,
      purpose: AppStrings.exerciseEqualBreathPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 5,
          instruction: AppStrings.exerciseEqualBreathStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 5,
          instruction: AppStrings.exerciseEqualBreathStep2,
        ),
      ],
      category: BreathingCategory.kaygiVeStres,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.esitNefes,
    ),

    // =========== UYKU VE RAHATLAMA ===========
    BreathingExercise(
      type: BreathingType.moonBreathing,
      name: AppStrings.exerciseSlowingName,
      description: AppStrings.exerciseSlowingDesc,
      purpose: AppStrings.exerciseSlowingPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseSlowingStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 8,
          instruction: AppStrings.exerciseSlowingStep2,
        ),
      ],
      category: BreathingCategory.uykuVeRahatlama,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.yavaslaticiNefes,
    ),
    
    BreathingExercise(
      type: BreathingType.bodyScan,
      name: AppStrings.exerciseBodyAwarenessName,
      description: AppStrings.exerciseBodyAwarenessDesc,
      purpose: AppStrings.exerciseBodyAwarenessPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 5,
          instruction: AppStrings.exerciseBodyAwarenessStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 5,
          instruction: AppStrings.exerciseBodyAwarenessStep2,
        ),
      ],
      category: BreathingCategory.uykuVeRahatlama,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.bedenFarkindaligi,
    ),
    
    BreathingExercise(
      type: BreathingType.progressiveRelaxation,
      name: AppStrings.exerciseRelaxationName,
      description: AppStrings.exerciseRelaxationDesc,
      purpose: AppStrings.exerciseRelaxationPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 6,
          instruction: AppStrings.exerciseRelaxationStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 6,
          instruction: AppStrings.exerciseRelaxationStep2,
        ),
      ],
      category: BreathingCategory.uykuVeRahatlama,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.gevsemeNefesi,
    ),

    // =========== ENERJİ VE CANLILIK ===========
    BreathingExercise(
      type: BreathingType.diaphragmaticBreathing,
      name: AppStrings.exerciseEnergizingDiaphragmName,
      description: AppStrings.exerciseEnergizingDiaphragmDesc,
      purpose: AppStrings.exerciseEnergizingDiaphragmPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 5,
          instruction: AppStrings.exerciseEnergizingDiaphragmStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 5,
          instruction: AppStrings.exerciseEnergizingDiaphragmStep2,
        ),
      ],
      category: BreathingCategory.enerjiVeCanlilik,
      difficulty: ExerciseDifficulty.intermediate,
      imagePath: AssetManager.canlandiriciDiyafram,
      isPremium: true,
    ),
    
    BreathingExercise(
      type: BreathingType.energizing,
      name: AppStrings.exerciseMorningBreathName,
      description: AppStrings.exerciseMorningBreathDesc,
      purpose: AppStrings.exerciseMorningBreathPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 4,
          instruction: AppStrings.exerciseMorningBreathStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 4,
          instruction: AppStrings.exerciseMorningBreathStep2,
        ),
      ],
      category: BreathingCategory.enerjiVeCanlilik,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.sabahNefesi,
    ),
    
    BreathingExercise(
      type: BreathingType.vitalizing,
      name: AppStrings.exerciseDayStartName,
      description: AppStrings.exerciseDayStartDesc,
      purpose: AppStrings.exerciseDayStartPurpose,
      steps: [
        BreathingStep(
          type: BreathingStepType.inhale,
          duration: 5,
          instruction: AppStrings.exerciseDayStartStep1,
        ),
        BreathingStep(
          type: BreathingStepType.exhale,
          duration: 3,
          instruction: AppStrings.exerciseDayStartStep2,
        ),
      ],
      category: BreathingCategory.enerjiVeCanlilik,
      difficulty: ExerciseDifficulty.beginner,
      imagePath: AssetManager.guneBaslangic,
      isPremium: true,
    ),
  ];
  
  /// Kategori isimlerini lokalize olarak döndürür
  static String getCategoryName(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppStrings.categoryFocus;
      case BreathingCategory.kaygiVeStres:
        return AppStrings.categoryStress;
      case BreathingCategory.uykuVeRahatlama:
        return AppStrings.categorySleep;
      case BreathingCategory.enerjiVeCanlilik:
        return AppStrings.categoryEnergy;
    }
  }
}
