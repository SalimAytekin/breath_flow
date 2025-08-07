import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../services/asset_manager.dart';
import 'sound_category.dart';

class SoundItem {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final String imagePath;
  final String? videoPath; // Video animasyon dosyası (opsiyonel)
  final IconData icon;
  final Color color;
  final bool isPremium;

  SoundItem({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.imagePath,
    this.videoPath,
    required this.icon,
    required this.color,
    this.isPremium = false,
  });

  // --- KATEGORİZE EDİLMİŞ SES LİSTELERİ ---

  static final List<SoundCategory> allCategories = [
    // 1. Doğa Sesleri
    SoundCategory(
      id: 'nature',
      name: 'Doğa Sesleri',
      icon: FeatherIcons.wind,
      sounds: [
    SoundItem(
          id: 'rain_on_tent',
          name: 'Çadırda Yağmur',
          description: 'Huzurlu bir kamp anı',
      assetPath: AssetManager.natureRainOnTent,
      imagePath: AssetManager.coverRain,
          videoPath: AssetManager.videoRainDrop,
          icon: FeatherIcons.umbrella,
      color: AppColors.relaxation,
    ),
    SoundItem(
          id: 'light_rain',
          name: 'Hafif Yağmur',
          description: 'Yapraklara düşen damlalar',
          assetPath: AssetManager.natureLightRain,
          imagePath: AssetManager.coverLightRain,
          videoPath: AssetManager.videoLightRain,
          icon: FeatherIcons.cloudDrizzle,
          color: AppColors.info,
        ),
        SoundItem(
          id: 'heavy_rain',
          name: 'Sağanak Yağmur',
          description: 'Pencereye vuran yoğun yağmur',
          assetPath: AssetManager.natureHeavyRain,
          imagePath: AssetManager.coverHeavyRain,
          videoPath: AssetManager.videoHeavyRain,
          icon: FeatherIcons.cloudRain,
          color: AppColors.info,
          isPremium: true,
    ),
    SoundItem(
      id: 'ocean',
      name: 'Okyanus Dalgaları',
          description: 'Sahile vuran sakinleştirici dalgalar',
      assetPath: AssetManager.natureOceanWaves,
      imagePath: AssetManager.coverOcean,
          videoPath: AssetManager.videoOceanWaves,
          icon: FeatherIcons.voicemail, // wave icon
      color: AppColors.info,
    ),
    SoundItem(
      id: 'forest',
      name: 'Orman Sesleri',
          description: 'Kuş cıvıltıları ve hışırdayan yapraklar',
          assetPath: AssetManager.natureForest,
      imagePath: AssetManager.coverForest,
          videoPath: AssetManager.videoForest,
          icon: FeatherIcons.wind,
      color: AppColors.success,
    ),
    SoundItem(
      id: 'thunder',
      name: 'Gök Gürültüsü',
          description: 'Uzaktan gelen rahatlatıcı fırtına',
          assetPath: AssetManager.natureThunder,
      imagePath: AssetManager.coverThunder,
      videoPath: AssetManager.videoThunder,
      icon: FeatherIcons.cloudLightning,
      color: AppColors.primary,
      isPremium: true,
    ),
    SoundItem(
          id: 'campfire',
          name: 'Kamp Ateşi',
          description: 'Çıtırdayan odun ve sıcaklık hissi',
          assetPath: AssetManager.natureCampfire,
          imagePath: AssetManager.coverCampfire,
          videoPath: AssetManager.videoCampfire,
          icon: FeatherIcons.zap, // fire icon
          color: AppColors.warning,
        ),
        SoundItem(
          id: 'river',
          name: 'Nehir Akıntısı',
          description: 'Sakin ve sürekli su akışı',
          assetPath: AssetManager.natureRiver,
          imagePath: AssetManager.coverRiver,
          videoPath: AssetManager.videoRiver,
          icon: FeatherIcons.gitPullRequest, // represents flow
          color: AppColors.info,
        ),
      ],
    ),

    // 2. Ortam & Gürültü
    SoundCategory(
      id: 'ambient',
      name: 'Ortam & Gürültü',
      icon: FeatherIcons.radio,
      sounds: [
        SoundItem(
          id: 'white_noise',
          name: 'Beyaz Gürültü',
          description: 'Tüm frekansları maskeleyen rahatlatıcı ses',
          assetPath: AssetManager.ambientWhiteNoise,
          imagePath: AssetManager.coverWhiteNoise,
          videoPath: AssetManager.videoWhiteNoise,
          icon: FeatherIcons.activity,
      color: AppColors.textSecondary,
    ),
        SoundItem(
          id: 'rainy_car_ride',
          name: 'Yağmurlu Arabada Yolculuk',
          description: 'Yağmur damlaları, silecek ve motor sesiyle huzurlu bir yolculuk',
          assetPath: AssetManager.ambientRainyCarRide,
          imagePath: AssetManager.coverRainyCarRide,
          videoPath: AssetManager.videoRainyCarRide,
          icon: FeatherIcons.truck,
          color: AppColors.info,
        ),
        SoundItem(
          id: 'bus_ride',
          name: 'Otobüs Yolculuğu',
          description: 'Motor uğultusu, yol titreşimi ve hafif konuşmalar',
          assetPath: AssetManager.ambientBusRide,
          imagePath: AssetManager.coverBusRide,
          videoPath: AssetManager.videoBusRide,
          icon: FeatherIcons.navigation,
          color: AppColors.primary,
        ),
        SoundItem(
          id: 'library',
          name: 'Kütüphane',
          description: 'Fısıltılar, sayfa çevirme ve kalem sesleri',
          assetPath: AssetManager.ambientLibrary,
          imagePath: AssetManager.coverLibrary,
          videoPath: null,
          icon: FeatherIcons.book,
          color: AppColors.focus,
        ),
        SoundItem(
          id: 'cafe',
          name: 'Kafe Ambiyansı',
          description: 'Bardak tıkırtısı, kahve makinesi ve arka plan sohbetler',
          assetPath: AssetManager.ambientCafe,
          imagePath: AssetManager.coverCafe,
          videoPath: AssetManager.videoCafe,
          icon: FeatherIcons.coffee,
          color: Colors.brown,
        ),
        SoundItem(
          id: 'train',
          name: 'Tren Yolculuğu',
          description: 'Rayların ritmik sesi ve yolculuk ambiyansı',
          assetPath: AssetManager.ambientTrain,
          imagePath: AssetManager.coverTrain,
          videoPath: AssetManager.videoTrain,
          icon: FeatherIcons.truck,
          color: AppColors.textSecondary,
          isPremium: true,
        ),
      ],
    ),
    
    // 3. Meditasyon Odaklı
    SoundCategory(
      id: 'meditation',
      name: 'Meditasyon Odaklı',
      icon: FeatherIcons.award,
      sounds: [
    SoundItem(
      id: 'meditation_bell',
      name: 'Meditasyon Çanı',
          description: 'Seans başlangıcı için Tibet çanı',
          assetPath: AssetManager.meditationBell,
      imagePath: AssetManager.coverMeditationBell,
      videoPath: AssetManager.videoMeditationBell,
      icon: FeatherIcons.bell,
      color: AppColors.sleep,
    ),
        SoundItem(
          id: 'tibetan_bowls',
          name: 'Tibet Ses Çanakları',
          description: 'Derin rezonans ve titreşimler',
          assetPath: AssetManager.meditationTibetanBowls,
          imagePath: AssetManager.coverTibetanBowls,
          videoPath: AssetManager.videoTibetanBowls,
          icon: FeatherIcons.disc,
          color: AppColors.focus,
          isPremium: true,
        ),
        SoundItem(
          id: 'lofi',
          name: 'Lo-fi Müzik',
          description: 'Odaklanmak için rahatlatıcı ritimler',
          assetPath: AssetManager.musicLofiChill,
          imagePath: AssetManager.coverLofi,
          videoPath: AssetManager.videoLofi,
          icon: FeatherIcons.music,
          color: AppColors.focus,
          isPremium: true,
        ),
    SoundItem(
      id: 'piano',
          name: 'Sakin Piyano',
          description: 'Yumuşak ve dinlendirici melodiler',
      assetPath: AssetManager.musicPiano,
      imagePath: AssetManager.coverPiano,
      videoPath: AssetManager.videoPiano,
      icon: FeatherIcons.music,
          color: AppColors.primary,
          isPremium: true,
        ),
        SoundItem(
          id: 'binaural_focus',
          name: 'Binaural Beats (Odak)',
          description: 'Alfa dalgaları ile zihinsel netlik',
          assetPath: AssetManager.meditationBinauralFocus,
          imagePath: AssetManager.coverBinauralBeats,
          videoPath: AssetManager.videoBinauralFocus,
          icon: FeatherIcons.target,
      color: AppColors.focus,
      isPremium: true,
    ),
      ],
    ),

    // 4. Gece Sesleri (Yeni Kategori)
    SoundCategory(
      id: 'night',
      name: 'Gece Sesleri',
      icon: FeatherIcons.moon,
      sounds: [
        SoundItem(
          id: 'night_crickets',
          name: 'Gece Böcekleri',
          description: 'Sıcak bir yaz gecesi ve huzurlu böcek sesleri',
          assetPath: AssetManager.sleepNightCrickets,
          imagePath: AssetManager.coverNightCrickets,
          videoPath: AssetManager.videoNightCrickets,
          icon: FeatherIcons.moon,
          color: AppColors.info,
        ),
      ],
    ),
  ];

  /// Tüm sesleri tek bir liste olarak döndürür.
  static List<SoundItem> get allSounds =>
      allCategories.expand((category) => category.sounds).toList();

  static SoundItem? findById(String id) {
    try {
      return allSounds.firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<SoundItem> get freeSounds => 
      allSounds.where((sound) => !sound.isPremium).toList();

  static List<SoundItem> get premiumSounds => 
      allSounds.where((sound) => sound.isPremium).toList();
}