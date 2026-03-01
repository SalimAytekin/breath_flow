import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/professional_app_bar.dart';
import '../constants/app_strings.dart';
import '../models/sound_item.dart';
import '../models/sound_category.dart';
import '../providers/audio_provider.dart';
import 'dart:ui';
import '../widgets/mixer_panel.dart';
import '../widgets/sound_card.dart';
import '../constants/app_spacing.dart';
import '../widgets/global_background.dart';
import '../constants/app_typography.dart';
import '../screens/immersive_sound_player_screen.dart';
import '../ui/components/ad_container.dart';

class SoundsScreen extends StatefulWidget {
  final String? customTitle;
  final List<String>? filterTags;

  const SoundsScreen({
    Key? key,
    this.customTitle,
    this.filterTags,
  }) : super(key: key);

  @override
  _SoundsScreenState createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  late final ScrollController _scrollController;
  late final List<SoundCategory> categories;
  AudioProvider? _audioProvider; // Provider referansını sakla

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Filtreleme varsa uygula
    if (widget.filterTags != null && widget.filterTags!.isNotEmpty) {
      final filteredSounds = SoundItem.getSoundsByTags(widget.filterTags!);
      // Filtrelenmiş sesleri kategorilere göre grupla
      categories = _groupSoundsByCategory(filteredSounds);
    } else {
      categories = SoundItem.allCategories;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider referansını güvenli şekilde al
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }
  
  /// Sesleri kategorilere göre gruplar
  List<SoundCategory> _groupSoundsByCategory(List<SoundItem> sounds) {
    final Map<String, List<SoundItem>> categoryMap = {};
    
    for (var sound in sounds) {
      // Her sesin hangi kategoriye ait olduğunu bul
      for (var category in SoundItem.allCategories) {
        if (category.sounds.any((s) => s.id == sound.id)) {
          if (!categoryMap.containsKey(category.id)) {
            categoryMap[category.id] = [];
          }
          categoryMap[category.id]!.add(sound);
          break;
        }
      }
    }
    
    // Kategorileri oluştur
    return SoundItem.allCategories
        .where((cat) => categoryMap.containsKey(cat.id))
        .map((cat) => SoundCategory(
              id: cat.id,
              name: cat.name,
              icon: cat.icon,
              sounds: categoryMap[cat.id]!,
            ))
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    
    // 🎵 Mixer ekranından çıkışta sesleri otomatik durdur
    // NOT: Context kullanmıyoruz, sadece önceden alınmış provider referansını kullanıyoruz
    try {
      if (_audioProvider != null && _audioProvider!.isMixerActive) {
        _audioProvider!.stopAllSounds();
      }
    } catch (e) {
      // Hata sessizce yoksayılır
    }
    
    super.dispose();
  }

  void _onSoundTapped(SoundItem sound) {
    // Premium kontrolü (şu an askıda)
    // final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    // Kart tıklaması player ekranını açar
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ImmersiveSoundPlayerScreen(sound: sound),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: ProfessionalAppBar(
          scrollController: _scrollController,
          title: widget.customTitle ?? AppStrings.soundCollectionTitle,
        ),
        body: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(), // ⚡ Daha performanslı
              cacheExtent: 500, // ⚡ Ön belleğe al
              padding: EdgeInsets.only(
                top: topPadding + kToolbarHeight + AppSpacing.medium,
                bottom: 120,
                left: 0,
                right: 0,
              ),
              itemCount: categories.length + 1, // +1 for banner ad
              itemBuilder: (context, index) {
                // İlk item banner reklam
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.small),
                    child: const AdContainer(
                      placement: 'sounds_screen',
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    ),
                  );
                }
                
                // Diğer itemlar kategori bölümleri
                final categoryIndex = index - 1;
                final category = categories[categoryIndex];
                if (category.sounds.isEmpty) return const SizedBox.shrink();
                return _CategorySection(
                  category: category,
                  onSoundTap: _onSoundTapped,
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MixerPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final SoundCategory category;
  final Function(SoundItem) onSoundTap;

  const _CategorySection({
    required this.category,
    required this.onSoundTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tüm kartlar daha büyük boyutta olacak
    const double cardWidth = 240;  // 200'den 240'a çıkardık
    const double cardHeight = 300; // 250'den 300'e çıkardık

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(title: category.name),
          const SizedBox(height: AppSpacing.small),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              cacheExtent: 1000, // ⚡ Horizontal scroll için cache
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              itemCount: category.sounds.length,
              itemBuilder: (context, index) {
                final sound = category.sounds[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.medium),
                  child: SizedBox(
                    width: cardWidth,
                    // ⚡ PERFORMANS: Consumer kaldırıldı - SoundCard kendi içinde dinliyor
                    child: SoundCard(
                      sound: sound,
                      onTap: onSoundTap,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;

  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Text(
        title,
        style: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 