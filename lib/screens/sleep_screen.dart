import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../models/sound_item.dart';
import '../models/breathing_exercise.dart';
import '../providers/audio_provider.dart';
import '../providers/breathing_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sleep_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/sound_player_card.dart';
import '../widgets/sleep_stats_widget.dart';
import '../widgets/story_series_card.dart';
import '../screens/sleep_input_screen.dart';
import '../screens/story_series_detail_screen.dart';
import 'package:breathe_flow/widgets/professional_button.dart';
import 'package:breathe_flow/widgets/professional_card.dart';
import 'package:breathe_flow/constants/app_spacing.dart';
import 'package:breathe_flow/constants/app_typography.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uyku Sesleri', style: AppTypography.displaySmall),
            const SizedBox(height: AppSpacing.small),
                  Text(
              'Rahatlatıcı seslerle daha hızlı uykuya dalın.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.large),
            _buildSoundGrid(context),
            const SizedBox(height: AppSpacing.xlarge),
            _buildTimerSection(context),
            const SizedBox(height: AppSpacing.large),
            _buildMasterVolumeSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return ProfessionalCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zamanlayıcı',
                style: AppTypography.headlineSmall,
              ),
              if (audioProvider.isTimerActive)
              Text(
                  'Kalan: ${audioProvider.remainingTime} dk',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryAccent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Slider(
                    value: audioProvider.timerDuration.toDouble(),
            min: 0,
                    max: 120,
            divisions: 8,
            label: '${audioProvider.timerDuration} dakika',
                    onChanged: (value) {
                      audioProvider.setTimerDuration(value.toInt());
                    },
                  ),
          const SizedBox(height: AppSpacing.medium),
          ProfessionalButton(
            text: audioProvider.isTimerActive ? 'Zamanlayıcıyı Durdur' : 'Zamanlayıcıyı Başlat',
                        onPressed: () {
                          if (audioProvider.isTimerActive) {
                            audioProvider.stopTimer();
                          } else {
                            audioProvider.startTimer();
                          }
            },
            icon: audioProvider.isTimerActive ? FeatherIcons.stopCircle : FeatherIcons.play,
            buttonType: ButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterVolumeSection(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return ProfessionalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ana Ses Seviyesi',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Slider(
            value: audioProvider.masterVolume,
            onChanged: (value) {
              audioProvider.setMasterVolume(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundGrid(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    // Uykuya uygun sesleri night, nature ve ambient kategorilerinden birleştir
    final sleepCategories = SoundItem.allCategories.where((cat) =>
      cat.id == 'night' || cat.id == 'nature' || cat.id == 'ambient').toList();
    final sleepSounds = sleepCategories.expand((cat) => cat.sounds).toList();
    final playingSoundIds = audioProvider.mixerSounds.map((s) => s.id).toSet();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.medium,
        mainAxisSpacing: AppSpacing.medium,
        childAspectRatio: 0.85,
      ),
      itemCount: sleepSounds.length,
      itemBuilder: (context, index) {
        final sound = sleepSounds[index];
        final isPlaying = playingSoundIds.contains(sound.id);

        return SoundPlayerCard(
          sound: sound,
          isPlaying: isPlaying,
          onTap: () {
            audioProvider.toggleMixerSound(sound);
          },
        );
      },
    );
  }
} 