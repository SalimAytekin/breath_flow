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
                instruction: 'Kutu Nefesi: Yavaş ve yumuşak bir nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.hold,
                duration: 4,
                instruction: 'Kutu Nefesi: Nefesini zorlamadan içinde tut (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Kutu Nefesi: Nefesini ağzından yavaşça bırak (4 sn)'),
            BreathingStep(
                type: BreathingStepType.holdAfterExhale,
                duration: 4,
                instruction: 'Kutu Nefesi: Döngüye başlamadan önce bekle (4 sn)'),
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
                instruction: 'Basit Sayma: 4\'e kadar sayarak yavaşça nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Basit Sayma: İçinden sayarak nefesini sakince bırak (4 sn)'),
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
                instruction: 'Farkındalık Nefesi: Güç harcamadan, yumuşakça nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Farkındalık Nefesi: Nefesin kendiliğinden yavaşça akıp gitsin (4 sn)'),
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
                instruction: 'Uzunca Nefes Ver: Sakin ve yumuşak bir nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 6,
                instruction: 'Uzunca Nefes Ver: Nefesini daha uzun sürede, yavaşça bırak (6 sn)'),
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
                instruction: 'Diyafram Nefesi: Göğsü şişirmeden, karnına doğru yavaşça al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Diyafram Nefesi: Karından sakince nefesini ver (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.diyaframNefesi,
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
                instruction: 'Eşit Nefes: Kasmadan, yavaş ve dengeli bir nefes al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Eşit Nefes: Aynı sürede, yumuşakça nefesini bırak (5 sn)'),
          ],
          category: BreathingCategory.kaygiVeStres,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.esitNefes,
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
                instruction: 'Yavaşlatıcı Nefes: Kendini kasmadan, sakince nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 8,
                instruction: 'Yavaşlatıcı Nefes: Nefesini çok yavaş ve uzunca bırak (8 sn)'),
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
                instruction: 'Beden Farkındalığı: Yavaşça nefes alırken bedenini hisset (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Beden Farkındalığı: Nefesle birlikte tüm gerginliğini bırak (5 sn)'),
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
                instruction: 'Gevşeme Nefesi: Kasmadan, yumuşak ve yavaş bir nefes al (6 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 6,
                instruction: 'Gevşeme Nefesi: Nefes verirken omuzlarını gevşet (6 sn)'),
          ],
          category: BreathingCategory.uykuVeRahatlama,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.gevsemeNefesi,
        ),

        // =========== ENERJİ VE CANLILIK ===========
        BreathingExercise(
          type: BreathingType.stimulatingBreath,
          name: 'Canlandırıcı Diyafram',
          description:
              'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.',
          purpose: 'Enerji Artırma',
          steps: [
            BreathingStep(
                type: BreathingStepType.inhale,
                duration: 5,
                instruction: 'Canlandırıcı Diyafram: Karnını şişirerek canlı ama yavaş nefes al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 5,
                instruction: 'Canlandırıcı Diyafram: Nefesini enerjik bir şekilde ver (5 sn)'),
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
                instruction: 'Sabah Nefesi: Tazeleyici, yumuşak ve sakin bir nefes al (4 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 4,
                instruction: 'Sabah Nefesi: Uykulu halini nefesinle dışarı üfle (4 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.sabahNefesi,
          isPremium: true,
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
                instruction: 'Gün Başlangıcı: Zorlamadan, yavaş ve pozitif bir nefes al (5 sn)'),
            BreathingStep(
                type: BreathingStepType.exhale,
                duration: 3,
                instruction: 'Gün Başlangıcı: Nefesini hafifçe ve sakince bırak (3 sn)'),
          ],
          category: BreathingCategory.enerjiVeCanlilik,
          difficulty: ExerciseDifficulty.beginner,
          imagePath: AssetManager.guneBaslangic,
          isPremium: true,
        ),
      ];
}
