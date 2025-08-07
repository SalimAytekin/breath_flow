import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🎯 Smart Asset Manager
/// Şimdi: Yerel assets'lerden çalışır
/// Gelecekte: Otomatik olarak bulut/yerel karar verir - KOD DEĞİŞMEZ!
class AssetManager {
  // Singleton pattern
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  // Asset base paths
  static const String _audioBasePath = 'assets/audio';
  static const String _imageBasePath = 'assets/images';
  static const String _lottieBasePath = 'assets/lottie';
  static const String _videoBasePath = 'assets/videos';

  // ================================
  // AUDIO ASSETS - Kategorize Edilmiş
  // ================================

  /// 🎵 Audio asset al - şimdi yerel, gelecekte akıllı
  static String audio(String fileName) {
    return '$_audioBasePath/$fileName';
  }

  // --- Doğa Sesleri ---
  static String get natureRainOnTent => audio('rain_on_tent.mp3');
  static String get natureCampfire => audio('campfire.mp3');
  static String get natureOceanWaves => audio('ocean_waves.mp3');
  static String get natureForest => audio('forest_sounds.mp3');
  static String get natureThunder => audio('distant_thunder.mp3');
  static String get natureLightRain => audio('light_rain.mp3');
  static String get natureHeavyRain => audio('heavy_rain.mp3');
  static String get natureRainOnLeaves => audio('rain_on_leaves.mp3');
  static String get natureRiver => audio('river.mp3');
  static String get natureWaterfall => audio('waterfall.mp3');
  static String get natureWindInTrees => audio('wind_in_trees.mp3');
  
  // --- Ortam & Gürültü Sesleri ---
  static String get ambientWhiteNoise => audio('white_noise.mp3');
  static String get ambientPinkNoise => audio('pink_noise.mp3');
  static String get ambientBrownNoise => audio('brown_noise.mp3');
  static String get ambientRainyCarRide => audio('rainy_car_ride.mp3');
  static String get ambientBusRide => audio('bus_ride.mp3');
  static String get ambientCafe => audio('cafe.mp3');
  static String get ambientLibrary => audio('library.mp3');
  static String get ambientAirplane => audio('airplane.mp3');
  static String get ambientTrain => audio('train.mp3');
  static String get ambientCityRain => audio('city_rain.mp3');
  static String get ambientFan => audio('fan.mp3');
  static String get ambientAcHum => audio('ac_hum.mp3');

  // --- Meditasyon & Müzik ---
  static String get musicLofiChill => audio('lofi_chill.mp3');
  static String get musicPiano => audio('piano_relax.mp3');
  static String get meditationBell => audio('meditation_bell.mp3');
  static String get meditationTibetanBowls => audio('tibetan_bowls.mp3');
  static String get meditationChimes => audio('chimes.mp3');
  static String get meditationBinauralFocus => audio('binaural_focus.mp3');
  static String get meditationBinauralSleep => audio('binaural_sleep.mp3');
  static String get meditationZenGarden => audio('zen_garden.mp3');
  
  // --- Uyku Odaklı Sesler ---
  static String get sleepNightCrickets => audio('night_crickets.mp3');
  static String get sleepLullaby => audio('lullaby.mp3');
  static String get sleepDeepSpace => audio('deep_space.mp3');
  static String get sleepHeartbeat => audio('heartbeat.mp3');
  static String get sleepWomb => audio('womb.mp3');

  /// 📚 Hikaye ses dosyaları (Ayrı Kategori)
  static String get storyTurkishEpisode01 => audio('stories/turkish_mythology/episode_01.mp3');
  static String get storyTurkishEpisode02 => audio('stories/turkish_mythology/episode_02.mp3');

  // ================================
  // IMAGE ASSETS - Kategorize Edilmiş
  // ================================

  /// 🖼️ Image asset al - şimdi yerel, gelecekte akıllı
  static String image(String fileName) {
    return '$_imageBasePath/$fileName';
  }

  /// 🌅 Background görselleri
  static String get backgroundBlurryGradient => image('backgrounds/blurry-gradient-background.png');
  static String get backgroundBlurryGradient2 => image('backgrounds/blurry-gradient-background(1).png');
  static String get backgroundDark => image('backgrounds/dark_background.jpg');

  /// 🔊 Sound preview görselleri
  static String get coverRain => image('sounds/rain.jpg');
  static String get coverCampfire => image('sounds/campfire.jpg');
  static String get coverOcean => image('sounds/ocean.jpg');
  static String get coverForest => image('sounds/forest.jpg');
  static String get coverThunder => image('sounds/thunder.jpg');
  static String get coverLightRain => image('sounds/light_rain.jpg');
  static String get coverHeavyRain => image('sounds/heavy_rain.jpg');
  static String get coverRainOnLeaves => image('sounds/rain_on_leaves.jpg');
  static String get coverRiver => image('sounds/river.jpg');
  static String get coverWaterfall => image('sounds/waterfall.jpg');
  static String get coverWindInTrees => image('sounds/wind_in_trees.jpg');
  
  static String get coverWhiteNoise => image('sounds/white_noise.jpg');
  static String get coverPinkNoise => image('sounds/pink_noise.jpg');
  static String get coverBrownNoise => image('sounds/brown_noise.jpg');
  static String get coverRainyCarRide => image('sounds/rainy_car_ride.jpg');
  static String get coverBusRide => image('sounds/bus_ride.jpg');
  static String get coverCafe => image('sounds/cafe.jpg');
  static String get coverLibrary => image('sounds/library.jpg');
  static String get coverAirplane => image('sounds/airplane.jpg');
  static String get coverTrain => image('sounds/train.jpg');
  static String get coverCityRain => image('sounds/city_rain.jpg');
  static String get coverFan => image('sounds/fan.jpg');
  static String get coverAcHum => image('sounds/ac_hum.jpg');

  static String get coverLofi => image('sounds/lofi.jpg');
  static String get coverPiano => image('sounds/piano.jpg');
  static String get coverMeditationBell => image('sounds/meditation_bell.jpg');
  static String get coverTibetanBowls => image('sounds/tibetan_bowls.jpg');
  static String get coverChimes => image('sounds/chimes.jpg');
  static String get coverBinauralBeats => image('sounds/binaural_beats.jpg');
  static String get coverZenGarden => image('sounds/zen_garden.jpg');

  static String get coverNightCrickets => image('sounds/night_crickets.jpg');
  static String get coverLullaby => image('sounds/lullaby.jpg');
  static String get coverDeepSpace => image('sounds/deep_space.jpg');
  static String get coverHeartbeat => image('sounds/heartbeat.jpg');
  static String get coverWomb => image('sounds/womb.jpg');

  // ================================
  // LOTTIE ANIMATIONS
  // ================================

  /// ✨ Lottie animation al - şimdi yerel, gelecekte akıllı
  static String lottie(String fileName) {
    return '$_lottieBasePath/$fileName';
  }

  /// 🌀 Animation dosyaları
  static String get animationBreathingCircle => lottie('breathing_circle.json');
  static String get animationCalmCircle => lottie('calm_circle.json');
  static String get animationNightBackground => lottie('night_background.json');

  // ================================
  // VIDEO ASSETS - Background Animations
  // ================================

  /// 🎬 Video asset al - şimdi yerel, gelecekte akıllı
  static String video(String fileName) {
    return '$_videoBasePath/$fileName';
  }

  /// 🌊 Video animasyonları (loop'a giren kısa videolar)
  static String get videoOceanWaves => video('ocean_waves.mp4');
  static String get videoRainDrop => video('rain_drop.mp4');
  static String get videoCampfire => video('campfire.mp4');
  static String get videoForest => video('forest.mp4');
  static String get videoThunder => video('thunder.mp4');
  static String get videoWhiteNoise => video('white_noise.mp4');
  static String get videoCafe => video('cafe.mp4');
  static String get videoTrain => video('train.mp4');
  static String get videoZenGarden => video('zen_garden.mp4');
  static String get videoStarryNight => video('starry_night.mp4');
  static String get videoFloatingParticles => video('floating_particles.mp4');
  static String get videoSoftWaves => video('soft_waves.mp4');
  
  // ✅ YENİ EKLENENLERş
  static String get videoLightRain => video('light_rain.mp4');
  static String get videoHeavyRain => video('heavy_rain.mp4');
  static String get videoRiver => video('river.mp4');
  static String get videoRainyCarRide => video('rainy_car_ride.mp4');
  static String get videoBusRide => video('bus_ride.mp4');
  static String get videoMeditationBell => video('meditation_bell.mp4');
  static String get videoTibetanBowls => video('tibetan_bowls.mp4');
  static String get videoLofi => video('lofi.mp4');
  static String get videoPiano => video('piano.mp4');
  static String get videoBinauralFocus => video('binaural_focus.mp4');
  static String get videoNightCrickets => video('night_crickets.mp4');
  static String get videoLullaby => video('lullaby.mp4');
  static String get videoBinauralSleep => video('binaural_sleep.mp4');
  static String get videoHeartbeat => video('heartbeat.mp4');
  static String get videoWomb => video('womb.mp4');

  // ================================
  // SMART FEATURES (GELECEKTEKİ BULUT DESTEĞİ)
  // ================================

  /// 📱 Asset'in mevcut olup olmadığını kontrol et
  static Future<bool> isAssetAvailable(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      if (kDebugMode) print('Asset not found: $assetPath');
      return false;
    }
  }

  /// 📦 Asset boyutunu al (MB)
  static Future<double> getAssetSizeMB(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.lengthInBytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// 📊 Tüm assets'lerin toplam boyutunu hesapla
  static Future<AssetInfo> getTotalAssetInfo() async {
    int totalFiles = 0;
    double totalSizeMB = 0.0;

    // Audio dosyaları
    final audioAssets = [
      // Doğa
      natureRainOnTent,
      natureCampfire,
      natureOceanWaves,
      natureForest,
      natureThunder,
      natureLightRain,
      natureHeavyRain,
      natureRainOnLeaves,
      natureRiver,
      natureWaterfall,
      natureWindInTrees,
      // Ortam & Gürültü
      ambientWhiteNoise,
      ambientPinkNoise,
      ambientBrownNoise,
      ambientCafe,
      ambientLibrary,
      ambientAirplane,
      ambientTrain,
      ambientCityRain,
      ambientFan,
      ambientAcHum,
      // Meditasyon & Müzik
      musicLofiChill,
      musicPiano,
      meditationBell,
      meditationTibetanBowls,
      meditationChimes,
      meditationBinauralFocus,
      meditationBinauralSleep,
      meditationZenGarden,
      // Uyku
      sleepNightCrickets,
      sleepLullaby,
      sleepDeepSpace,
      sleepHeartbeat,
      sleepWomb,
      // Hikayeler
      storyTurkishEpisode01,
      storyTurkishEpisode02,
    ];

    // Image dosyaları
    final imageAssets = [
      backgroundBlurryGradient,
      backgroundBlurryGradient2,
      backgroundDark,
      // Ses kapakları
      coverRain,
      coverCampfire,
      coverOcean,
      coverForest,
      coverThunder,
      coverLightRain,
      coverHeavyRain,
      coverRainOnLeaves,
      coverRiver,
      coverWaterfall,
      coverWindInTrees,
      coverWhiteNoise,
      coverPinkNoise,
      coverBrownNoise,
      coverCafe,
      coverLibrary,
      coverAirplane,
      coverTrain,
      coverCityRain,
      coverFan,
      coverAcHum,
      coverLofi,
      coverPiano,
      coverMeditationBell,
      coverTibetanBowls,
      coverChimes,
      coverBinauralBeats,
      coverZenGarden,
      coverNightCrickets,
      coverLullaby,
      coverDeepSpace,
      coverHeartbeat,
      coverWomb,
    ];

    // Animation dosyaları
    final animationAssets = [
      animationBreathingCircle,
      animationCalmCircle,
      animationNightBackground,
    ];

    // Tüm dosyaları kontrol et
    final allAssets = [...audioAssets, ...imageAssets, ...animationAssets];
    
    for (final asset in allAssets) {
      if (await isAssetAvailable(asset)) {
        totalFiles++;
        totalSizeMB += await getAssetSizeMB(asset);
      }
    }

    return AssetInfo(
      totalFiles: totalFiles,
      totalSizeMB: totalSizeMB,
      audioFiles: audioAssets.length,
      imageFiles: imageAssets.length,
      animationFiles: animationAssets.length,
    );
  }

  // ================================
  // GELECEKTEKİ CLOUD INTEGRATION (ŞİMDİLİK PLACEHOLDER)
  // ================================

  /// 🔮 Gelecekte: Asset'i buluttan mı yoksa yerel'den mi alacağına karar ver
  static Future<String> _getOptimalAssetPath(String fileName, AssetType type) async {
    // ŞİMDİ: Her zaman yerel döndür
    switch (type) {
      case AssetType.audio:
        return audio(fileName);
      case AssetType.image:
        return image(fileName);
      case AssetType.lottie:
        return lottie(fileName);
    }
  }

  /// 🔮 Gelecekte: Cloud URL'den local cache'e indir
  static Future<String?> _downloadAndCache(String cloudUrl, String fileName) async {
    // ŞİMDİ: Placeholder - gelecekte implement edilecek
    if (kDebugMode) print('🔮 Future: Download $fileName from $cloudUrl');
    return null;
  }

  /// 🔮 Gelecekte: Cache'den dosya al
  static Future<String?> _getCachedAsset(String fileName) async {
    // ŞİMDİ: Placeholder - gelecekte implement edilecek
    return null;
  }

  // ================================
  // UTILITY METHODS
  // ================================

  /// 🧹 Cache'i temizle (gelecekteki cloud için)
  static Future<void> clearCache() async {
    if (kDebugMode) print('🧹 Cache cleared (future feature)');
  }

  /// 📊 Asset kullanım istatistiklerini logla
  static void logAssetUsage(String assetPath) {
    // Gelecekte analytics için asset kullanımını track edebiliriz
    if (kDebugMode) print('📊 Asset used: $assetPath');
  }
}

// ================================
// DATA MODELS
// ================================

enum AssetType {
  audio,
  image,
  lottie,
}

class AssetInfo {
  final int totalFiles;
  final double totalSizeMB;
  final int audioFiles;
  final int imageFiles;
  final int animationFiles;

  AssetInfo({
    required this.totalFiles,
    required this.totalSizeMB,
    required this.audioFiles,
    required this.imageFiles,
    required this.animationFiles,
  });

  @override
  String toString() {
    return 'AssetInfo(files: $totalFiles, size: ${totalSizeMB.toStringAsFixed(1)}MB, audio: $audioFiles, images: $imageFiles, animations: $animationFiles)';
  }
}

// ================================
// KULLANIM ÖRNEKLERİ
// ================================

/// 🎯 BÖYLE KULLANACAKSINIZ:
/// 
/// ```dart
/// // Audio oynat
/// AudioPlayer.play(AssetManager.natureOceanWaves);
/// 
/// // Background image
/// Image.asset(AssetManager.backgroundDark);
/// 
/// // Lottie animation
/// Lottie.asset(AssetManager.animationBreathingCircle);
/// 
/// // Sound cover
/// Image.asset(AssetManager.coverOcean);
/// 
/// // Dinamik kullanım
/// String soundPath = AssetManager.audio('custom_sound.mp3');
/// ```
/// 
/// 🔮 GELECEKTE BULUT GEÇİŞİNDE:
/// - Kod hiç değişmez!
/// - AssetManager otomatik olarak yerel/bulut karar verir
/// - Cache sistemi devreye girer
/// - Analytics ile hangi assets popüler görebiliriz 
// ------------------------------------------------
// 🗑️ DEPRECATED - YENİ SİSTEME TAŞINDI
// ------------------------------------------------
// Eski değişkenler burada bırakıldı, referans veren kodlar kırılmasın diye.
// Yeni eklemeleri yukarıdaki kategorize edilmiş alanlara yapın.
// static String get natureLofiChill => audio('lofi_chill.mp3');
// static String get natureOceanWaves => audio('ocean_waves.mp3');
// static String get natureRainOnTent => audio('rain_on_tent.mp3');
// static String get coverLofi => image('sounds/lofi.jpg');
// static String get coverMeditationBell => image('sounds/meditation_bell.jpg');
// static String get coverOcean => image('sounds/ocean.jpg');
// static String get coverPiano => image('sounds/piano.jpg');
// static String get coverRain => image('sounds/rain.jpg');
// static String get coverThunder => image('sounds/thunder.jpg');
// static String get coverWhiteNoise => image('sounds/white_noise.jpg'); 