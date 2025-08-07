import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/sound_item.dart';
import '../models/sound_category.dart';
import '../providers/audio_provider.dart';
import '../widgets/sound_player_card.dart';
import 'dart:ui';
import '../widgets/mixer_panel.dart';
import '../widgets/sound_card.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({Key? key}) : super(key: key);

  @override
  _SoundsScreenState createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final List<SoundCategory> categories = SoundItem.allCategories;

  void _onSoundTapped(SoundItem sound) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.toggleMixerSound(sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Keşfet'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(FeatherIcons.search),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: AppSpacing.medium, 
              bottom: 120,
              left: 0,
              right: 0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              if (category.sounds.isEmpty) return const SizedBox.shrink();
              return _CategorySection(
                category: category,
                onSoundTap: _onSoundTapped,
              );
            },
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MixerPanel(),
          ),
        ],
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
          _CategoryHeader(title: category.name, onSeeAllTap: () {}),
          const SizedBox(height: AppSpacing.small),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              itemCount: category.sounds.length,
              itemBuilder: (context, index) {
                final sound = category.sounds[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.medium),
                  child: SizedBox(
                    width: cardWidth,
                    child: Consumer<AudioProvider>(
                      builder: (context, audioProvider, child) {
                        return SoundCard(
                          sound: sound,
                        );
                      },
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
  final VoidCallback onSeeAllTap;

  const _CategoryHeader({required this.title, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAllTap,
            child: Text(
              'Tümünü gör',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 