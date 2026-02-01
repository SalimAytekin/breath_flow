import 'package:flutter/material.dart';
import '../data/sounds_loader.dart';
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
  final List<String> tags; // Kullanım senaryosu etiketleri

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
    this.tags = const [], // Varsayılan boş liste
  });

  // --- LOKALİZE SES VERİLERİ (SoundsLoader'dan) ---

  /// Tüm kategorileri lokalize olarak döndürür
  static List<SoundCategory> get allCategories => SoundsLoader.getAllCategories();

  /// Tüm sesleri tek bir liste olarak döndürür
  static List<SoundItem> get allSounds => SoundsLoader.getAllSounds();

  /// ID'ye göre ses bul
  static SoundItem? findById(String id) => SoundsLoader.findById(id);

  /// Ücretsiz sesleri döndürür
  static List<SoundItem> get freeSounds => SoundsLoader.getFreeSounds();

  /// Premium sesleri döndürür
  static List<SoundItem> get premiumSounds => SoundsLoader.getPremiumSounds();

  /// Tag'lere göre sesleri filtreler
  static List<SoundItem> getSoundsByTags(List<String> tags) => 
      SoundsLoader.getSoundsByTags(tags);
}