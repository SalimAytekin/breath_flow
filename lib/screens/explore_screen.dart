import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/global_background.dart';
import '../services/asset_manager.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../data/mood_presets.dart';
import '../providers/audio_provider.dart';
import '../models/sound_item.dart';
import '../providers/exercise_tracking_provider.dart';
import 'breathing_screen.dart';
import 'mood_detail_screen.dart';
import 'sounds_screen.dart';
import 'sleep_hub_screen.dart';

/// 🧭 Keşfet Ekranı — Premium, yetişkin, sıcak tasarım
/// ChatGPT mockup'ına birebir: 4 büyük mood kartı + 3 küçük kare kart
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ✨ Başlık Banner
                _buildHeaderBanner(),

                const SizedBox(height: 16),

                // 🌙 Uyuyamıyorum
                _buildMoodBannerCard(
                  context,
                  title: AppStrings.exploreDeepSleep,
                  subtitle: AppStrings.exploreDeepSleepDesc,
                  imageAsset: AssetManager.exploreSleepBanner,
                  gradientColors: [
                    const Color(0xFF1A1040),
                    const Color(0xFF2D1B69),
                    const Color(0xFF4A2C8A),
                  ],
                  moodKey: 'uyuyamiyorum',
                ),

                const SizedBox(height: 12),

                // 😰 Gerginim
                _buildMoodBannerCard(
                  context,
                  title: AppStrings.exploreAnxietyRelief,
                  subtitle: AppStrings.exploreAnxietyReliefDesc,
                  imageAsset: AssetManager.exploreAnxietyBanner,
                  gradientColors: [
                    const Color(0xFF3D2415),
                    const Color(0xFF5A3520),
                    const Color(0xFF8B5E3C),
                  ],
                  moodKey: 'gerginim',
                ),

                const SizedBox(height: 12),

                // 🧠 Düşüncelerim Durmuyor
                _buildMoodBannerCard(
                  context,
                  title: AppStrings.exploreMentalReset,
                  subtitle: AppStrings.exploreMentalResetDesc,
                  imageAsset: AssetManager.exploreOverthinkingBanner,
                  gradientColors: [
                    const Color(0xFF2A1540),
                    const Color(0xFF3D2060),
                    const Color(0xFF6B3FA0),
                  ],
                  moodKey: 'overthinking',
                ),

                const SizedBox(height: 12),

                // 🔋 Tükendim
                _buildMoodBannerCard(
                  context,
                  title: AppStrings.exploreEnergyRecharge,
                  subtitle: AppStrings.exploreEnergyRechargeDesc,
                  imageAsset: AssetManager.exploreBurnoutBanner,
                  gradientColors: [
                    const Color(0xFF2D1F0E),
                    const Color(0xFF4A3520),
                    const Color(0xFF6B5030),
                  ],
                  moodKey: 'tukendim',
                ),

                const SizedBox(height: 24),

                // 📦 3'lü Küçük Kartlar
                _buildQuickAccessRow(context),

                SizedBox(height: 24 + bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✨ Başlık Banner — "Keşfedebileceklerin ✨"
  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFD4A050),
            Color(0xFFC08840),
            Color(0xFFAA7030),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A050).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '${AppStrings.discover} ✨',
        style: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }

  /// 🎯 Mood Banner Kartı — Tam genişlik, görsel arka plan, gradient overlay
  Widget _buildMoodBannerCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageAsset,
    required List<Color> gradientColors,
    required String moodKey,
  }) {
    return GestureDetector(
      onTap: () => _navigateToMoodDetail(context, moodKey: moodKey, title: title, imageAsset: imageAsset),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan görseli
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: gradientColors.first,
                ),
              ),

              // Gradient overlay — soldan sağa koyu → şeffaf
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      gradientColors.first.withOpacity(0.95),
                      gradientColors[1].withOpacity(0.7),
                      gradientColors.last.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // İnce üst parlaklık efekti
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Metin içeriği
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ alt köşe ince border glow
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4A050).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📦 3'lü Küçük Kare Kartlar — Tüm Egzersizler, Tüm Sesler, Uyku Takibi
  Widget _buildQuickAccessRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            context,
            title: AppStrings.allExercises,
            imageAsset: AssetManager.exploreAllExercises,
            onTap: () => _navigateToBreathing(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickCard(
            context,
            title: AppStrings.allSounds,
            imageAsset: AssetManager.exploreAllSounds,
            onTap: () => _navigateToSounds(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickCard(
            context,
            title: AppStrings.sleepTracking,
            imageAsset: AssetManager.exploreSleepTracking,
            onTap: () => _navigateToSleepHub(context),
          ),
        ),
      ],
    );
  }

  /// Küçük kare kart — görsel arka plan + alt başlık
  Widget _buildQuickCard(
    BuildContext context, {
    required String title,
    required String imageAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan görseli
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                ),
              ),

              // Alt gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // Başlık
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // 🚀 Navigation & Session Methods
  // =============================================

  /// Mood kartına tıklayınca → MoodDetailScreen'e git
  void _navigateToMoodDetail(BuildContext context, {
    required String moodKey,
    required String title,
    required String imageAsset,
  }) {
    final preset = MoodPresets.getPreset(moodKey);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoodDetailScreen(
          preset: preset,
          title: title,
          imageAsset: imageAsset,
        ),
      ),
    );
  }

  /// Döngü seçim modalı
  void _showCycleSelectionModal(BuildContext context, BreathingExercise exercise, MoodPreset preset) {
    final List<int> cycleOptions = [5, 10, 15, 20, 25, 30];
    int selectedCycles = 10;
    final breathingProvider = context.read<BreathingProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 400;

            return Container(
              padding: EdgeInsets.all(isSmallScreen ? AppSpacing.medium : AppSpacing.large),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontSize: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? AppSpacing.tiny : AppSpacing.small),
                              Text(
                                AppStrings.howManyCycles,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(FeatherIcons.x, color: AppColors.textPrimary, size: isSmallScreen ? 20 : 24),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? AppSpacing.medium : AppSpacing.large),

                    // Döngü seçenekleri
                    SizedBox(
                      height: isSmallScreen ? 160 : 200,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: isSmallScreen ? 1.3 : 1.4,
                          crossAxisSpacing: isSmallScreen ? 4 : 6,
                          mainAxisSpacing: isSmallScreen ? 4 : 6,
                        ),
                        itemCount: cycleOptions.length,
                        itemBuilder: (context, index) {
                          final cycles = cycleOptions[index];
                          final isSelected = selectedCycles == cycles;
                          final estimatedMinutes = (cycles * exercise.totalDuration / 60).round();

                          return GestureDetector(
                            onTap: () => modalState(() => selectedCycles = cycles),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryAccent.withOpacity(0.2)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryAccent : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$cycles',
                                    style: TextStyle(
                                      color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.cycles,
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: isSmallScreen ? 9 : 10),
                                  ),
                                  Text(
                                    '~$estimatedMinutes${AppStrings.minutesShort}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: isSmallScreen ? 8 : 9),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? AppSpacing.large : AppSpacing.xLarge),

                    // Başlat butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final exerciseTrackingProvider = Provider.of<ExerciseTrackingProvider>(context, listen: false);
                          exerciseTrackingProvider.onExerciseStarted();

                          breathingProvider.setExercise(exercise, customCycles: selectedCycles);
                          breathingProvider.start();
                          Navigator.of(context).pop();

                          // Sesi başlat
                          try {
                            final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                            final sound = SoundItem.allSounds.firstWhere(
                              (s) => s.id == preset.defaultSoundId,
                              orElse: () => SoundItem.allSounds.first,
                            );
                            audioProvider.playExclusive(sound);
                          } catch (_) {}

                          final navContext = context;
                          Navigator.of(navContext).push(
                            MaterialPageRoute(
                              builder: (context) => BreathingScreen(moodPreset: preset),
                            ),
                          ).then((_) {
                            try {
                              final audioProvider = Provider.of<AudioProvider>(navContext, listen: false);
                              audioProvider.stopAllSounds();
                            } catch (_) {}
                            breathingProvider.stop();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? AppSpacing.small : AppSpacing.medium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.medium)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FeatherIcons.play, size: isSmallScreen ? 18 : 20),
                            SizedBox(width: isSmallScreen ? AppSpacing.tiny : AppSpacing.small),
                            Flexible(
                              child: Text(
                                '${AppStrings.start} ($selectedCycles ${AppStrings.cycles})',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? AppSpacing.small : AppSpacing.medium),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToBreathing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BreathingScreen()),
    );
  }

  void _navigateToSounds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SoundsScreen()),
    );
  }

  void _navigateToSleepHub(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SleepHubScreen()),
    );
  }
}