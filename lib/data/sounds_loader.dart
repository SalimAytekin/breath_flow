import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/asset_manager.dart';
import '../models/sound_item.dart';
import '../models/sound_category.dart';

/// 🌍 Lokalize Ses Koleksiyonu Yükleyici
/// 
/// Bu sınıf, seçili dile göre ses verilerini yükler.
/// Tüm metinler AppStrings üzerinden easy_localization ile çevrilir.
class SoundsLoader {
  
  /// Tüm lokalize ses kategorilerini döndürür
  static List<SoundCategory> getAllCategories() => [
    // 1. Doğa Sesleri
    SoundCategory(
      id: 'nature',
      name: AppStrings.soundCategoryNature,
      icon: FeatherIcons.wind,
      sounds: [
        SoundItem(
          id: 'rain_on_tent',
          name: AppStrings.soundRainOnTentName,
          description: AppStrings.soundRainOnTentDesc,
          assetPath: AssetManager.natureRainOnTent,
          imagePath: AssetManager.coverRain,
          videoPath: AssetManager.videoRainDrop,
          icon: FeatherIcons.umbrella,
          color: AppColors.relaxation,
          tags: ['sleep', 'relaxation'],
        ),
        SoundItem(
          id: 'light_rain',
          name: AppStrings.soundLightRainName,
          description: AppStrings.soundLightRainDesc,
          assetPath: AssetManager.natureLightRain,
          imagePath: AssetManager.coverLightRain,
          videoPath: AssetManager.videoLightRain,
          icon: FeatherIcons.cloudDrizzle,
          color: AppColors.info,
          tags: ['sleep', 'relaxation', 'focus'],
        ),
        SoundItem(
          id: 'heavy_rain',
          name: AppStrings.soundHeavyRainName,
          description: AppStrings.soundHeavyRainDesc,
          assetPath: AssetManager.natureHeavyRain,
          imagePath: AssetManager.coverHeavyRain,
          videoPath: AssetManager.videoHeavyRain,
          icon: FeatherIcons.cloudRain,
          color: AppColors.info,
          isPremium: true,
          tags: ['sleep', 'focus'],
        ),
        SoundItem(
          id: 'ocean',
          name: AppStrings.soundOceanName,
          description: AppStrings.soundOceanDesc,
          assetPath: AssetManager.natureOceanWaves,
          imagePath: AssetManager.coverOcean,
          videoPath: AssetManager.videoOceanWaves,
          icon: FeatherIcons.voicemail,
          color: AppColors.info,
          isPremium: true,
          tags: ['sleep', 'meditation', 'relaxation'],
        ),
        SoundItem(
          id: 'forest',
          name: AppStrings.soundForestName,
          description: AppStrings.soundForestDesc,
          assetPath: AssetManager.natureForest,
          imagePath: AssetManager.coverForest,
          videoPath: AssetManager.videoForest,
          icon: FeatherIcons.wind,
          color: AppColors.success,
          tags: ['meditation', 'relaxation', 'focus'],
        ),
        SoundItem(
          id: 'thunder',
          name: AppStrings.soundThunderName,
          description: AppStrings.soundThunderDesc,
          assetPath: AssetManager.natureThunder,
          imagePath: AssetManager.coverThunder,
          videoPath: AssetManager.videoThunder,
          icon: FeatherIcons.cloudLightning,
          color: AppColors.primary,
          isPremium: true,
          tags: ['sleep', 'relaxation'],
        ),
        SoundItem(
          id: 'campfire',
          name: AppStrings.soundCampfireName,
          description: AppStrings.soundCampfireDesc,
          assetPath: AssetManager.natureCampfire,
          imagePath: AssetManager.coverCampfire,
          videoPath: AssetManager.videoCampfire,
          icon: FeatherIcons.zap,
          color: AppColors.warning,
          tags: ['sleep', 'relaxation'],
        ),
        SoundItem(
          id: 'river',
          name: AppStrings.soundRiverName,
          description: AppStrings.soundRiverDesc,
          assetPath: AssetManager.natureRiver,
          imagePath: AssetManager.coverRiver,
          videoPath: AssetManager.videoRiver,
          icon: FeatherIcons.gitPullRequest,
          color: AppColors.info,
          tags: ['meditation', 'relaxation', 'focus'],
        ),
      ],
    ),

    // 2. Ortam & Gürültü
    SoundCategory(
      id: 'ambient',
      name: AppStrings.soundCategoryAmbient,
      icon: FeatherIcons.radio,
      sounds: [
        SoundItem(
          id: 'white_noise',
          name: AppStrings.soundWhiteNoiseName,
          description: AppStrings.soundWhiteNoiseDesc,
          assetPath: AssetManager.ambientWhiteNoise,
          imagePath: AssetManager.coverWhiteNoise,
          videoPath: AssetManager.videoWhiteNoise,
          icon: FeatherIcons.activity,
          color: AppColors.textSecondary,
          tags: ['sleep', 'focus'],
        ),
        SoundItem(
          id: 'rainy_car_ride',
          name: AppStrings.soundRainyCarRideName,
          description: AppStrings.soundRainyCarRideDesc,
          assetPath: AssetManager.ambientRainyCarRide,
          imagePath: AssetManager.coverRainyCarRide,
          videoPath: AssetManager.videoRainyCarRide,
          icon: FeatherIcons.truck,
          color: AppColors.info,
          isPremium: true,
          tags: ['sleep', 'relaxation'],
        ),
        SoundItem(
          id: 'bus_ride',
          name: AppStrings.soundBusRideName,
          description: AppStrings.soundBusRideDesc,
          assetPath: AssetManager.ambientBusRide,
          imagePath: AssetManager.coverBusRide,
          videoPath: AssetManager.videoBusRide,
          icon: FeatherIcons.navigation,
          color: AppColors.primary,
          isPremium: true,
          tags: ['sleep', 'relaxation'],
        ),
        SoundItem(
          id: 'library',
          name: AppStrings.soundLibraryName,
          description: AppStrings.soundLibraryDesc,
          assetPath: AssetManager.ambientLibrary,
          imagePath: AssetManager.coverLibrary,
          videoPath: null,
          icon: FeatherIcons.book,
          color: AppColors.focus,
          tags: ['focus'],
        ),
        SoundItem(
          id: 'cafe',
          name: AppStrings.soundCafeName,
          description: AppStrings.soundCafeDesc,
          assetPath: AssetManager.ambientCafe,
          imagePath: AssetManager.coverCafe,
          videoPath: AssetManager.videoCafe,
          icon: FeatherIcons.coffee,
          color: Colors.brown,
          tags: ['focus'],
        ),
        SoundItem(
          id: 'train',
          name: AppStrings.soundTrainName,
          description: AppStrings.soundTrainDesc,
          assetPath: AssetManager.ambientTrain,
          imagePath: AssetManager.coverTrain,
          videoPath: AssetManager.videoTrain,
          icon: FeatherIcons.truck,
          color: AppColors.textSecondary,
          isPremium: true,
          tags: ['sleep', 'relaxation'],
        ),
      ],
    ),
    
    // 3. Müzik & Enstrümanlar
    SoundCategory(
      id: 'meditation',
      name: AppStrings.soundCategoryMeditation,
      icon: FeatherIcons.music,
      sounds: [
        SoundItem(
          id: 'meditation_bell',
          name: AppStrings.soundMeditationBellName,
          description: AppStrings.soundMeditationBellDesc,
          assetPath: AssetManager.meditationBell,
          imagePath: AssetManager.coverMeditationBell,
          videoPath: AssetManager.videoMeditationBell,
          icon: FeatherIcons.bell,
          color: AppColors.sleep,
          tags: ['meditation', 'relaxation'],
        ),
        SoundItem(
          id: 'tibetan_bowls',
          name: AppStrings.soundTibetanBowlsName,
          description: AppStrings.soundTibetanBowlsDesc,
          assetPath: AssetManager.meditationTibetanBowls,
          imagePath: AssetManager.coverTibetanBowls,
          videoPath: AssetManager.videoTibetanBowls,
          icon: FeatherIcons.disc,
          color: AppColors.focus,
          isPremium: true,
          tags: ['meditation', 'relaxation'],
        ),
        SoundItem(
          id: 'piano',
          name: AppStrings.soundPianoName,
          description: AppStrings.soundPianoDesc,
          assetPath: AssetManager.musicPiano,
          imagePath: AssetManager.coverPiano,
          videoPath: AssetManager.videoPiano,
          icon: FeatherIcons.music,
          color: AppColors.primary,
          isPremium: true,
          tags: ['meditation', 'relaxation'],
        ),
        SoundItem(
          id: 'binaural_focus',
          name: AppStrings.soundBinauralFocusName,
          description: AppStrings.soundBinauralFocusDesc,
          assetPath: AssetManager.meditationBinauralFocus,
          imagePath: AssetManager.coverBinauralFocus,
          videoPath: AssetManager.videoBinauralFocus,
          icon: FeatherIcons.target,
          color: AppColors.focus,
          isPremium: true,
          tags: ['focus', 'meditation'],
        ),
      ],
    ),

    // 4. Gece Sesleri
    SoundCategory(
      id: 'night',
      name: AppStrings.soundCategoryNight,
      icon: FeatherIcons.moon,
      sounds: [
        SoundItem(
          id: 'night_crickets',
          name: AppStrings.soundNightCricketsName,
          description: AppStrings.soundNightCricketsDesc,
          assetPath: AssetManager.sleepNightCrickets,
          imagePath: AssetManager.coverNightCrickets,
          videoPath: AssetManager.videoNightCrickets,
          icon: FeatherIcons.moon,
          color: AppColors.info,
          tags: ['sleep', 'relaxation'],
        ),
      ],
    ),
  ];

  /// Tüm sesleri tek bir liste olarak döndürür
  static List<SoundItem> getAllSounds() =>
      getAllCategories().expand((category) => category.sounds).toList();

  /// ID'ye göre ses bul
  static SoundItem? findById(String id) {
    try {
      return getAllSounds().firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ücretsiz sesleri döndürür
  static List<SoundItem> getFreeSounds() => 
      getAllSounds().where((sound) => !sound.isPremium).toList();

  /// Premium sesleri döndürür
  static List<SoundItem> getPremiumSounds() => 
      getAllSounds().where((sound) => sound.isPremium).toList();

  /// Tag'lere göre sesleri filtreler
  static List<SoundItem> getSoundsByTags(List<String> tags) {
    if (tags.isEmpty) return getAllSounds();
    return getAllSounds().where((sound) {
      return tags.any((tag) => sound.tags.contains(tag));
    }).toList();
  }
}
