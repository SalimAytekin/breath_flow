import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';

/// 🎯 Mood bazlı egzersiz + ses kombinasyonları
/// Her mood için default ve alternatif egzersizler tanımlanır
class MoodPreset {
  final String moodKey;
  final BreathingType defaultExercise;
  final List<BreathingType> alternativeExercises;
  final String defaultSoundId;
  final Map<BreathingType, String> exerciseSoundMap;

  // MoodDetailScreen için ek bilgiler
  final List<String> soundTags;
  final List<String> recommendedSoundIds;
  final List<Color> gradientColors;
  final String imageAsset;
  final IconData icon;

  const MoodPreset({
    required this.moodKey,
    required this.defaultExercise,
    required this.alternativeExercises,
    required this.defaultSoundId,
    required this.exerciseSoundMap,
    this.soundTags = const [],
    this.recommendedSoundIds = const [],
    this.gradientColors = const [],
    this.imageAsset = '',
    this.icon = Icons.spa,
  });

  /// Egzersiz tipine göre uygun sesi döndürür
  String getSoundForExercise(BreathingType type) {
    return exerciseSoundMap[type] ?? defaultSoundId;
  }

  /// Tüm egzersizleri döndürür (default + alternatifler)
  List<BreathingType> get allExercises => [defaultExercise, ...alternativeExercises];
}

/// 🎯 Mood Presets - Tüm mood kombinasyonları
class MoodPresets {
  MoodPresets._();

  /// Gerginim: Sakinleştirici egzersizler
  static const MoodPreset gerginim = MoodPreset(
    moodKey: 'gerginim',
    defaultExercise: BreathingType.extendedExhale,
    alternativeExercises: [
      BreathingType.diaphragmaticBreathing,
      BreathingType.samaVritti,
    ],
    defaultSoundId: 'light_rain',
    exerciseSoundMap: {
      BreathingType.extendedExhale: 'light_rain',
      BreathingType.diaphragmaticBreathing: 'ocean',
      BreathingType.samaVritti: 'forest',
    },
    soundTags: ['relaxation', 'meditation'],
    recommendedSoundIds: ['light_rain', 'ocean', 'forest'],
    gradientColors: [Color(0xFF3D2415), Color(0xFF5A3520), Color(0xFF8B5E3C)],
    icon: Icons.favorite_outline,
  );

  /// Düşüncelerim durmuyor: Odaklanma egzersizleri
  static const MoodPreset overthinking = MoodPreset(
    moodKey: 'overthinking',
    defaultExercise: BreathingType.boxBreathing,
    alternativeExercises: [
      BreathingType.custom,
      BreathingType.deepBreathing,
    ],
    defaultSoundId: 'campfire',
    exerciseSoundMap: {
      BreathingType.boxBreathing: 'campfire',
      BreathingType.custom: 'white_noise',
      BreathingType.deepBreathing: 'binaural_focus',
    },
    soundTags: ['focus', 'meditation'],
    recommendedSoundIds: ['campfire', 'white_noise', 'binaural_focus'],
    gradientColors: [Color(0xFF2A1540), Color(0xFF3D2060), Color(0xFF6B3FA0)],
    icon: Icons.psychology_outlined,
  );

  /// Uyuyamıyorum: Uyku hazırlık egzersizleri
  static const MoodPreset uyuyamiyorum = MoodPreset(
    moodKey: 'uyuyamiyorum',
    defaultExercise: BreathingType.moonBreathing,
    alternativeExercises: [
      BreathingType.bodyScan,
      BreathingType.progressiveRelaxation,
    ],
    defaultSoundId: 'night_crickets',
    exerciseSoundMap: {
      BreathingType.moonBreathing: 'night_crickets',
      BreathingType.bodyScan: 'rain_on_tent',
      BreathingType.progressiveRelaxation: 'piano',
    },
    soundTags: ['sleep', 'relaxation'],
    recommendedSoundIds: ['night_crickets', 'rain_on_tent', 'piano'],
    gradientColors: [Color(0xFF1A1040), Color(0xFF2D1B69), Color(0xFF4A2C8A)],
    icon: Icons.nightlight_round,
  );

  /// Tükendim: Enerji ve toparlanma egzersizleri
  static const MoodPreset tukendim = MoodPreset(
    moodKey: 'tukendim',
    defaultExercise: BreathingType.energizing,
    alternativeExercises: [
      BreathingType.vitalizing,
      BreathingType.boxBreathing,
    ],
    defaultSoundId: 'river',
    exerciseSoundMap: {
      BreathingType.energizing: 'river',
      BreathingType.vitalizing: 'meditation_bell',
      BreathingType.boxBreathing: 'thunder',
    },
    soundTags: ['relaxation', 'focus'],
    recommendedSoundIds: ['river', 'meditation_bell', 'thunder'],
    gradientColors: [Color(0xFF2D1F0E), Color(0xFF4A3520), Color(0xFF6B5030)],
    icon: Icons.battery_charging_full,
  );

  /// Mood key'e göre preset döndürür
  static MoodPreset getPreset(String moodKey) {
    switch (moodKey) {
      case 'gerginim':
        return gerginim;
      case 'overthinking':
        return overthinking;
      case 'uyuyamiyorum':
        return uyuyamiyorum;
      case 'tukendim':
        return tukendim;
      default:
        return gerginim;
    }
  }
}
