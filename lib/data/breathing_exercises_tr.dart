import '../models/breathing_exercise.dart';
import '../services/asset_manager.dart';

/// Türkçe nefes egzersizleri verisi
/// Bu dosya çoklu dil desteği için oluşturulmuştur.
/// İngilizce versiyonu için breathing_exercises_en.dart dosyasını oluşturun.
class BreathingExercisesTR {
  
  /// Step type text'lerini döndürür
  static String getStepTypeText(BreathingStepType stepType) {
    switch (stepType) {
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

  /// Tüm Türkçe nefes egzersizlerini döndürür
  static List<BreathingExercise> getAllExercises() => [
        // =========== ODAKLANMA VE DİKKAT ===========
        BreathingExercise(
          type: BreathingType.boxBreathing,
          name: 'Kutu Nefesi (4-4-4-4)',
          description:
              'Nefesini dört aşamada düzenle: al, tut, ver ve bekle. Zihinsel dengeyi artırır.',
          purpose: 'Odaklanma ve Denge',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: 'Şimdi derin bir nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.hold,
                duration: 4,
                instruction: 'Nefesini içinde tut (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Yavaşça bırak (4 sn)'),
            BreathingStep(
                type: BreathingStepType.holdAfterExhale,
                duration: 4,
                instruction: 'Kısa bir an bekle (4 sn)'),
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
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: ' 1\'den 4\'e kadar sayarak nefes al, (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Şimdi 1\'den 4\'e kadar sayarak bırak, (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.basitSaymaNefesi,
          isPremium: true,
        ),
        BreathingExercise(
          type: BreathingType.deepBreathing,
          name: 'Farkındalık Nefesi',
          description:
              'Nefesini doğal akışında gözlemle. Değiştirmeden sadece fark et.',
          purpose: 'Nefes Farkındalığı',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: 'Nefesin doğal akışını hisset (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Hiç değiştirmeden bırak gitsin (4 sn)'),
          ],
          category: BreathingCategory.odaklanma,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.farkindalikNefesi,
          isPremium: true,
        ),

        // =========== SAKİNLEŞME VE STRES AZALTMA ===========
        BreathingExercise(
          type: BreathingType.extendedExhale,
          name: 'Uzunca Nefes Ver (4-6)',
          description:
              'Kısa al, uzun ver. Bu ritim sinir sistemini sakinleştirir.',
          purpose: 'Doğal Sakinleşme',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: 'Rahatça nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 6,
                instruction: 'Şimdi daha uzun ve sakin şekilde ver (6 sn)'),
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
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Nefesi karnına doğru çek (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Karından yavaşça bırak (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.diyaframNefesi,
          isPremium: true,
        ),
        BreathingExercise(
          type: BreathingType.samaVritti,
          name: 'Eşit Nefes',
          description:
              'Nefes alma ve verme sürelerini eşitleyerek sinir sistemini dengeleyin.',
          purpose: 'Sistem Dengesi',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Eşit bir nefes al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Eşit bir nefes ver (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.esitNefes,
          isPremium: true,
        ),

        // =========== UYKU VE RAHATLAMA ===========
        BreathingExercise(
          type: BreathingType.moonBreathing,
          name: 'Yavaşlatıcı Nefes',
          description:
              'Nefes ritmini yavaşlatarak kalp atış hızını düşürür ve uykuya hazırlar.',
          purpose: 'Uykuya Hazırlık',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: 'Yavaşça nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 8,
                instruction: 'Çok yavaşça ve uzun bırak (8 sn)'),
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
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Nefes alırken bedenini tarayın (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Gerginliği bırakarak verin (5 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.bedenFarkindaligi,
          isPremium: true,
        ),
        BreathingExercise(
          type: BreathingType.progressiveRelaxation,
          name: 'Gevşeme Nefesi',
          description:
              'Derin bir rahatlama hissi yaratır ve uykuya geçişi kolaylaştırır.',
          purpose: 'Derin Gevşeme',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 6,
                instruction: 'Derin bir nefes al (6 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 6,
                instruction: 'Tüm gerginliği bırak (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.gevsemeNefesi,
          isPremium: true,
        ),

        // =========== ENERJİ VE CANLILIK ===========
        BreathingExercise(
          type: BreathingType.diaphragmaticBreathing,
          name: 'Canlandırıcı Diyafram',
          description:
              'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.',
          purpose: 'Enerji Artırma',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Diyaframdan güçlü bir nefes al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Enerjik bir şekilde ver (5 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.intermediate,
          imagePath: AssetManager.canlandiriciDiyafram,
          isPremium: true,
        ),
        BreathingExercise(
          type: BreathingType.energizing,
          name: 'Sabah Nefesi',
          description:
              'Güne derin ve canlı nefeslerle başla. Sabah enerjini yükseltir.',
          purpose: 'Sabah Aktivasyonu',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 4,
                instruction: 'Sabahın taze havasını al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Uykuyu üfle (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.sabahNefesi,
        ),
        BreathingExercise(
          type: BreathingType.vitalizing,
          name: 'Güne Başlangıç Nefesi',
          description:
              'Pozitif enerjiyle nefes al, hafif şekilde ver. Güne hazırlar.',
          purpose: 'Gün Başlangıcı',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Pozitif enerji al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 3,
                instruction: 'Hafifçe bırak (3 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.guneBaslangic,
          isPremium: true,
        ),
      ];
}
