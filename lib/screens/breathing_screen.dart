import 'dart:ui'; // ImageFilter için eklendi
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // groupBy için
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../widgets/professional_app_bar.dart';
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
import '../services/ad_service.dart';
import '../widgets/simple_banner_ad.dart';
import '../widgets/global_background.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  late final ScrollController _scrollController;
  String? selectedSoundId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final breathingProvider = context.read<BreathingProvider>();
      breathingProvider.setOnSessionCompleted(() {
        _onSessionCompleted(breathingProvider);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Ekran kapanırken tüm sesleri durdur
    Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
    super.dispose();
  }

  void _onSessionCompleted(BreathingProvider provider) async {
    if (!mounted) return;
    
    final currentExercise = provider.currentExercise;
    if (currentExercise == null) return;
    
    try {
      final userPrefsProvider = context.read<UserPreferencesProvider>();
      userPrefsProvider.recordBreathingSession(provider.sessionDuration);
      
      final premiumProvider = context.read<PremiumProvider>();
      premiumProvider.trackUserAction('breathing_session_completed', {
        'technique': currentExercise.name,
        'duration': provider.sessionDuration,
        'cycles': provider.totalCycles,
      });

      // 🎯 Nefes egzersizi sonrası interstitial reklam göster
      // Premium kullanıcılar için reklam gösterme
      if (!premiumProvider.isPremiumUser) {
        await AdService.instance.showInterstitialAd();
      }

      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => SessionFeedbackDialog(
            sessionType: currentExercise.name,
            duration: provider.sessionDuration,
          ),
        );
      }
    } catch (e) {
      print('❌ Session complete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BreathingProvider>(
      builder: (context, breathingProvider, child) {
        if (breathingProvider.isRunning && breathingProvider.currentExercise != null) {
          // Aktif seans sırasında özel arkaplan kullanılır
          return _buildBreathingSession(context, breathingProvider);
        }
        // Kategori seçimi sırasında genel arkaplan kullanılır
        return GlobalBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: ProfessionalAppBar(scrollController: _scrollController, title: 'Nefes Egzersizleri'),
            body: _buildCategorySelection(context),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + kToolbarHeight + 20, 20, 10),
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
                  const SizedBox(height: AppSpacing.large),
                  // Banner reklam - Progress indicator'dan sonra
                  const SimpleBannerAd(
                    placement: 'breathing_screen',
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  ),
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
                  title: 'Odaklanma & Konsantrasyon',
                  subtitle: 'Dikkatini tek bir noktaya yönlendir, düşüncelerini toparla',
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
                  title: 'Rahatlama & Huzur',
                  subtitle: 'Derin bir nefesle gerginliği bırak ve bedenini gevşet',
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
                  title: 'Huzurlu Uyku',
                  subtitle: 'Bedenini ve zihnini dinlendir, yavaşça gevşe',
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
                  title: 'Enerji & Zindelik',
                  subtitle: 'İçindeki enerjiyi uyandır ve günün tadını çıkar',
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
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final streak = userPrefs.currentStreak;
        final weeklyGoal = userPrefs.weeklyGoal;
        final completedThisWeek = userPrefs.completedSessionsThisWeek;
        final weeklyProgress = weeklyGoal > 0 ? (completedThisWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;
        
        return FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: ProfessionalCard(
            cardType: CardType.glass,
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Günlük Seri
                _buildProgressItem(
                  icon: '🔥',
                  value: '$streak',
                  label: 'Günlük Seri',
                  subtitle: streak > 0 ? 'Harika gidiyorsun!' : 'Başlayalım!',
                  color: AppColors.energy,
                ),
                
                // Ayırıcı çizgi
                Container(
                  height: 60,
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.glassBorder.withOpacity(0.1),
                        AppColors.glassBorder.withOpacity(0.3),
                        AppColors.glassBorder.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                
                // Haftalık Hedef
                _buildProgressItem(
                  icon: null,
                  value: '$completedThisWeek/$weeklyGoal',
                  label: 'Haftalık Hedef',
                  subtitle: '${(weeklyProgress * 100).round()}% tamamlandı',
                  color: AppColors.focus,
                  progressValue: weeklyProgress,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem({
    String? icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
    double? progressValue,
  }) {
    return Expanded(
      child: Column(
        children: [
          // İkon veya Progress Circle
          if (icon != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            )
          else if (progressValue != null)
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 4,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Icon(
                    FeatherIcons.target,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: AppSpacing.medium),
          
          // Değer
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: AppSpacing.tiny),
          
          // Label
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.tiny),
          
          // Subtitle
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
          height: 180, // Biraz daha yüksek
          margin: const EdgeInsets.symmetric(horizontal: 4), // Kenar boşlukları
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: overlayColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Stack(
              children: [
                // Arkaplan
                Positioned.fill(child: background),

                // Çok hafif blur efekti
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5), // 1.5'ten 0.5'e düşürüldü
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                
                // Minimal gradyan overlay - Sadece okunabilirlik için
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      gradient: LinearGradient(
                        colors: [
                          overlayColor.withOpacity(0.1), // 0.2'den 0.1'e düşürüldü
                          overlayColor.withOpacity(0.15), // 0.3'ten 0.15'e düşürüldü
                          Colors.black.withOpacity(0.15), // 0.25'ten 0.15'e düşürüldü
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Glassmorphism border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),

                // İçerik
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üst kısım - Kategori ikonu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              FeatherIcons.arrowRight,
                              color: Colors.white.withOpacity(0.9),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      
                      // Alt kısım - Başlık ve açıklama
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(blurRadius: 15, color: Colors.black), // Çok güçlü shadow
                                const Shadow(blurRadius: 8, color: Colors.black87),
                                const Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500, // Biraz daha kalın
                              shadows: [
                                const Shadow(blurRadius: 12, color: Colors.black), // Çok güçlü shadow
                                const Shadow(blurRadius: 6, color: Colors.black87),
                                const Shadow(blurRadius: 3, color: Colors.black54),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return FeatherIcons.target;
      case BreathingCategory.kaygiVeStres:
        return FeatherIcons.heart;
      case BreathingCategory.uykuVeRahatlama:
        return FeatherIcons.moon;
      case BreathingCategory.enerjiVeCanlilik:
        return FeatherIcons.zap;
    }
  }

  Widget _buildBreathingSession(BuildContext context, BreathingProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2000), // 2 saniye yumuşak geçiş
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(provider),
      ),
      child: Stack(
        children: [
          // Ana animasyon alanı - tam ekran
          BreathingAnimation(
            provider: provider,
          ),
          
          // Üst kontroller - overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
                      onPressed: () {
                        Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
                        provider.stop();
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      provider.currentExercise?.name ?? '', 
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      )
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(FeatherIcons.music, color: Colors.white),
                      onPressed: () {
                        _showSoundSelectionModal(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Alt kontroller - overlay
          if (provider.isRunning)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    children: [
                      // İlerleme bilgisi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.completedCycles} / ${provider.totalCycles} Döngü',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // İlerleme çubuğu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LinearProgressIndicator(
                          value: provider.totalCycles > 0
                              ? provider.completedCycles / provider.totalCycles
                              : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Pause/Resume butonu
                      FloatingActionButton(
                        onPressed: () {
                          if (provider.isPaused) {
                            provider.resume();
                          } else {
                            provider.pause();
                          }
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        child: Icon(
                          provider.isPaused ? FeatherIcons.play : FeatherIcons.pause,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Nefes durumuna göre arkaplan gradyanı
  LinearGradient _getBackgroundGradient(BreathingProvider provider) {
    final currentStep = provider.currentStep;
    if (currentStep == null) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary, AppColors.primaryBackground],
      );
    }

    switch (currentStep.type) {
      case BreathingStepType.inhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.focus.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.hold:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.focus.withOpacity(0.7),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.exhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.relaxation.withOpacity(0.8),
            AppColors.sleep.withOpacity(0.6),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.holdAfterExhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sleep.withOpacity(0.9),
            AppColors.relaxation.withOpacity(0.7),
            AppColors.primaryBackground,
          ],
        );
    }
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