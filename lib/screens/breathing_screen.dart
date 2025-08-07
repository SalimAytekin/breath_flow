import 'dart:ui'; // ImageFilter için eklendi
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // groupBy için
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/breathing_animation.dart';
import '../widgets/professional_card.dart'; // Yeni kartlar için
import '../widgets/session_feedback_dialog.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../services/asset_manager.dart';
import 'exercise_list_screen.dart'; // Bu dosya bir sonraki adımda oluşturulacak
import '../providers/audio_provider.dart';
import '../models/sound_item.dart';
import '../models/sound_category.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  String? selectedSoundId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final breathingProvider = context.read<BreathingProvider>();
      breathingProvider.setOnSessionCompleted(() {
        _onSessionCompleted(breathingProvider);
      });
    });
  }

  @override
  void dispose() {
    // Ekran kapanırken tüm sesleri durdur
    Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
    super.dispose();
  }

  void _onSessionCompleted(BreathingProvider provider) {
    if (mounted && provider.currentExercise != null) {
      final userPrefsProvider = context.read<UserPreferencesProvider>();
      userPrefsProvider.recordBreathingSession(provider.sessionDuration);
      final premiumProvider = context.read<PremiumProvider>();
      premiumProvider.trackUserAction('breathing_session_completed', {
        'technique': provider.currentExercise!.name,
        'duration': provider.sessionDuration,
        'cycles': provider.totalCycles,
      });
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SessionFeedbackDialog(
          sessionType: provider.currentExercise!.name,
          duration: provider.sessionDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<BreathingProvider>(
          builder: (context, breathingProvider, child) {
            if (breathingProvider.isRunning && breathingProvider.currentExercise != null) {
              return _buildBreathingSession(context, breathingProvider);
            }
            return _buildCategorySelection(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final breathingProvider = context.read<BreathingProvider>();
          final lastExercise = BreathingExercise.allExercises.first; // Şimdilik ilk egzersiz
          breathingProvider.setExercise(lastExercise);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(FeatherIcons.play, color: Colors.white),
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          sliver: SliverToBoxAdapter(
            child: FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.breathingExercises,
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Stres, uyku veya odaklanma. İhtiyacın olanı seç.',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _buildProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.odaklanma,
                  title: 'Odaklanma',
                  subtitle: 'Zihinsel netlik ve konsantrasyon',
                  overlayColor: AppColors.focus,
                  background: Image.asset(
                    AssetManager.coverForest,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.kaygiVeStres,
                  title: 'Kaygı & Stres',
                  subtitle: 'Stresi azalt ve anında sakinleş',
                  overlayColor: AppColors.relaxation,
                  background: Image.asset(
                    AssetManager.coverOcean,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.uykuVeRahatlama,
                  title: 'Uyku & Rahatlama',
                  subtitle: 'Zihnini ve vücudunu dinlendir',
                  overlayColor: AppColors.sleep,
                  background: Lottie.asset(
                    AssetManager.animationNightBackground,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.enerjiVeCanlilik,
                  title: 'Enerji & Canlılık',
                  subtitle: 'Güne başla veya anında canlan',
                  overlayColor: AppColors.energy,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.energy, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    const int streak = 3;
    const double weeklyGoalProgress = 0.6;

    return ProfessionalCard(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '🔥',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '$streak Günlük Seri',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            height: 50,
            width: 1,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: weeklyGoalProgress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Haftalık Hedef',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required BreathingCategory category,
    required String title,
    required String subtitle,
    required Color overlayColor,
    required Widget background,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 + (category.index * 100)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExerciseListScreen(category: category, heroTag: title),
          ));
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Stack(
              children: [
                Positioned.fill(child: background),

                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      gradient: LinearGradient(
                        colors: [
                          overlayColor.withOpacity(0.3),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                Container(
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(blurRadius: 4, color: Colors.black87)
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        subtitle,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                           shadows: [
                            const Shadow(blurRadius: 2, color: Colors.black54)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: AppSpacing.medium,
                  right: AppSpacing.medium,
                  child: Icon(
                    FeatherIcons.arrowRight,
                    color: Colors.white.withOpacity(0.8),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingSession(BuildContext context, BreathingProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(FeatherIcons.arrowLeft),
                onPressed: () {
                  Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
                  provider.stop();
                },
              ),
              Text(provider.currentExercise?.name ?? '', style: AppTypography.headlineSmall),
              IconButton(
                icon: const Icon(FeatherIcons.music),
                onPressed: () {
                  _showSoundSelectionModal(context);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BreathingAnimation(
            provider: provider,
          ),
        ),
        if (provider.isRunning)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              children: [
                Text(
                  '${provider.completedCycles} / ${provider.totalCycles} Döngü',
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: provider.totalCycles > 0
                      ? provider.completedCycles / provider.totalCycles
                      : 0,
                  backgroundColor: AppColors.surface.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showSoundSelectionModal(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    // Doğa seslerini doğru şekilde filtrele
    final natureSounds = SoundItem.allCategories
        .firstWhere((cat) => cat.id == 'nature')
        .sounds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.large),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.large),
                  topRight: Radius.circular(AppSpacing.large),
                ),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arkaplan Sesi Seç',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: natureSounds.map((sound) {
                      final isPlaying = audioProvider.isPlaying(sound.id);
                      final isSelected = selectedSoundId == sound.id;

                      return ActionChip(
                        avatar: Icon(
                          sound.icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.textSecondary,
                        ),
                        label: Text(sound.name),
                        backgroundColor: isSelected
                            ? AppColors.primaryAccent.withOpacity(0.2)
                            : AppColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.medium),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        onPressed: () {
                          // Sadece bir sesin çalmasını sağla
                          // Önce tüm diğer sesleri durdur
                          audioProvider.stopAllSounds();

                          modalState(() {
                            if (isSelected) {
                              // Zaten seçiliyse, seçimi kaldır ve sesi durdur
                              selectedSoundId = null;
                            } else {
                              // Yeni bir ses seç, eskisini durdur ve yenisini çal
                              selectedSoundId = sound.id;
                              audioProvider.toggleMixerSound(sound);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: AppSpacing.xlarge),
                  // Sessizlik seçeneği
                  ListTile(
                     leading: const Icon(FeatherIcons.volumeX, color: AppColors.textSecondary),
                     title: const Text('Sessizlik'),
                     onTap: (){
                        audioProvider.stopAllSounds();
                        modalState(() {
                          selectedSoundId = null;
                        });
                     },
                     trailing: selectedSoundId == null 
                      ? const Icon(FeatherIcons.check, color: AppColors.primaryAccent)
                      : null,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
} 