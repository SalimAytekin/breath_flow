import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../providers/audio_provider.dart';
import '../providers/premium_provider.dart';
import '../models/sound_item.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'professional_button.dart';

class MixerPanel extends StatefulWidget {
  const MixerPanel({super.key});

  @override
  State<MixerPanel> createState() => _MixerPanelState();
}

class _MixerPanelState extends State<MixerPanel> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final mixerSounds = audioProvider.mixerSounds;

    if (mixerSounds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCollapsedTab(mixerSounds.length),
          _buildExpandedPanel(mixerSounds, audioProvider),
        ],
      ),
    );
  }

  Widget _buildCollapsedTab(int mixCount) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withOpacity(0.8),
              border: const Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(FeatherIcons.sliders, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.medium),
                    Text(
                      'Mikser ($mixCount)',
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? FeatherIcons.chevronDown : FeatherIcons.chevronUp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildExpandedPanel(List<SoundItem> sounds, AudioProvider audioProvider) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.large),
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
        ),
        child: Column(
          children: [
            ...sounds.map((sound) => _buildVolumeSlider(sound, audioProvider)).toList(),
            const SizedBox(height: AppSpacing.large),
            ProfessionalButton(
              text: 'Tümünü Durdur',
              onPressed: () {
                audioProvider.stopAllSounds();
                _toggleExpanded();
              },
              icon: FeatherIcons.stopCircle,
              buttonType: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(SoundItem sound, AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          Icon(sound.icon, color: sound.color, size: 24),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              sound.name,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            flex: 2,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: sound.color,
                inactiveTrackColor: sound.color.withOpacity(0.3),
                thumbColor: sound.color,
                overlayColor: sound.color.withOpacity(0.2),
              ),
              child: Slider(
                value: audioProvider.getVolume(sound.id),
                onChanged: (value) {
                  audioProvider.setVolume(sound.id, value);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(FeatherIcons.x, color: AppColors.textTertiary, size: 20),
            onPressed: () => audioProvider.toggleMixerSound(sound),
          ),
        ],
      ),
    );
  }
} 