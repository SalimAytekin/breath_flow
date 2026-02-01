import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/breathing_provider.dart';
import '../models/breathing_exercise.dart';
import '../models/sound_item.dart';
import '../widgets/professional_card.dart';
import '../widgets/breathing_exercise_card.dart';
import '../widgets/sound_card.dart';
import '../widgets/global_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/mixer_panel.dart';
import '../screens/breathing_screen.dart';
import '../screens/immersive_sound_player_screen.dart';
import '../screens/sounds_screen.dart';
import '../screens/home_screen.dart';
import '../providers/audio_provider.dart';

/// ⭐ Favoriler Ekranı - Premium Tasarım
/// Kullanıcının favori nefes egzersizleri ve ses içeriklerini gösterir
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AudioProvider? _audioProvider; // Provider referansını sakla

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // 🎵 Tab değişiminde mixer seslerini durdur
      _stopMixerSoundsOnTabChange();
      setState(() {}); // Tab değiştiğinde UI'yi güncelle
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider referansını güvenli şekilde al
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }

  /// Tab değişiminde mixer seslerini durdur
  void _stopMixerSoundsOnTabChange() {
    try {
      if (_audioProvider != null && _audioProvider!.isMixerActive) {
        _audioProvider!.stopAllSounds();
        debugPrint('✅ FavoritesScreen: Mixer sesleri tab değişiminde durduruldu');
      }
    } catch (e) {
      debugPrint('❌ FavoritesScreen tab change audio cleanup error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    // 🎵 Mixer ekranından çıkışta sesleri otomatik durdur
    // NOT: Context kullanmıyoruz, sadece önceden alınmış provider referansını kullanıyoruz
    try {
      if (_audioProvider != null && _audioProvider!.isMixerActive) {
        _audioProvider!.stopAllSounds();
        debugPrint('✅ FavoritesScreen dispose: Mixer sesleri otomatik durduruldu');
      }
    } catch (e) {
      debugPrint('❌ FavoritesScreen dispose audio error: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFavoritesBreathingExercises(),
                      _buildFavoritesSounds(),
                    ],
                  ),
                ),
              ],
            ),
            // MixerPanel'i sadece ses sekmesinde göster
            if (_tabController.index == 1)
              const Positioned(
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

  /// Premium AppBar tasarımı
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          FeatherIcons.arrowLeft,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Text(
          AppStrings.myFavoritesTitle,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: IconButton(
            icon: Icon(
              FeatherIcons.heart,
              color: AppColors.primaryAccent,
            ),
            onPressed: () {
              // Favori istatistikleri göster
              _showFavoritesStats();
            },
          ),
        ),
      ],
    );
  }

  /// Tab Bar tasarımı
  Widget _buildTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final showIcon = screenWidth >= 350;
        final tabLabelSize = screenWidth < 400 ? 11.0 : (screenWidth < 500 ? 12.0 : 14.0);
        
        return Container(
          margin: AppSpacing.pagePadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface.withOpacity(0.1),
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryAccent.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.6),
                ],
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: tabLabelSize,
            ),
            unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
              fontSize: tabLabelSize,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FeatherIcons.wind, size: showIcon ? 16 : 0),
                    if (showIcon) const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.breathLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FeatherIcons.music, size: showIcon ? 16 : 0),
                    if (showIcon) const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.soundLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Favori nefes egzersizleri listesi
  Widget _buildFavoritesBreathingExercises() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final favoriteIds = userPrefs.favoriteExerciseIds;
        
        if (favoriteIds.isEmpty) {
          return _buildEmptyState(
            icon: FeatherIcons.wind,
            title: AppStrings.noFavoriteExercises,
            subtitle: AppStrings.addFavoriteExercises,
            actionText: AppStrings.exploreExercises,
            onAction: () => _navigateToExerciseList(),
          );
        }

        // Favori egzersizleri filtrele - ID ile karşılaştır
        final favoriteExercises = BreathingExercise.allExercises
            .where((exercise) => favoriteIds.contains(exercise.type.name))
            .toList();

        return ListView.builder(
          padding: AppSpacing.pagePadding,
          physics: const BouncingScrollPhysics(),
          itemCount: favoriteExercises.length,
          itemBuilder: (context, index) {
            final exercise = favoriteExercises[index];
            return FadeInUp(
              duration: Duration(milliseconds: 600 + (index * 100)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.large),
                child: _buildModernExerciseCard(context, exercise),
              ),
            );
          },
        );
      },
    );
  }

  /// Favori ses içerikleri listesi
  Widget _buildFavoritesSounds() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final favoriteIds = userPrefs.favoriteSoundIds;
        
        if (favoriteIds.isEmpty) {
          return _buildEmptyState(
            icon: FeatherIcons.music,
            title: AppStrings.noFavoriteSounds,
            subtitle: AppStrings.addFavoriteSounds,
            actionText: AppStrings.exploreSounds,
            onAction: () => _navigateToSoundList(),
          );
        }

        // Favori sesleri filtrele
        final favoriteSounds = SoundItem.allSounds
            .where((sound) => favoriteIds.contains(sound.id))
            .toList();

        return ListView.builder(
          padding: EdgeInsets.only(
            left: AppSpacing.large,
            top: AppSpacing.large,
            right: AppSpacing.large,
            bottom: AppSpacing.large + 120, // MixerPanel için ekstra alan
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: favoriteSounds.length,
          itemBuilder: (context, index) {
            final sound = favoriteSounds[index];
            return FadeInUp(
              duration: Duration(milliseconds: 600 + (index * 100)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: GestureDetector(
                  onTap: () => _navigateToSoundPlayer(sound),
                  child: SoundCard(
                    sound: sound,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: EmptyState(
          icon: icon,
          title: title,
          message: subtitle,
          actionText: actionText,
          onAction: onAction,
        ),
      ),
    );
  }


  /// Egzersiz listesi ekranına git
  void _navigateToExerciseList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BreathingScreen(),
      ),
    );
  }

  /// Ses listesi ekranına git
  void _navigateToSoundList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SoundsScreen(),
      ),
    );
  }

  /// Nefes egzersizi ekranına git
  void _navigateToBreathingExercise(BreathingExercise exercise) {
    _showBreathingRepeatModal(exercise);
  }

  /// Nefes egzersizi tekrar seçme modal'ı
  void _showBreathingRepeatModal(BreathingExercise exercise) {
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
              margin: EdgeInsets.all(isSmallScreen ? AppSpacing.small : AppSpacing.medium),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? AppSpacing.medium : AppSpacing.large),
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
                                  AppStrings.howManyCyclesQuestion,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              FeatherIcons.x,
                              color: AppColors.textPrimary,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? AppSpacing.medium : AppSpacing.large),

                      // Döngü seçenekleri - Modern Grid Layout
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
                            onTap: () {
                              modalState(() {
                                selectedCycles = cycles;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getCategoryColor(exercise.category).withOpacity(0.2)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _getCategoryColor(exercise.category)
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$cycles',
                                    style: TextStyle(
                                      color: isSelected
                                          ? _getCategoryColor(exercise.category)
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.cyclesLabel,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 9 : 10,
                                    ),
                                  ),
                                  Text(
                                    '~${estimatedMinutes}dk',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 8 : 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                      SizedBox(height: isSmallScreen ? AppSpacing.large : AppSpacing.xLarge),

                      // Başlat butonu - Modern tasarım
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            breathingProvider.setExercise(exercise, customCycles: selectedCycles);
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const BreathingScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCategoryColor(exercise.category),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? AppSpacing.small : AppSpacing.medium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.medium),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FeatherIcons.play, size: isSmallScreen ? 14 : 16),
                              SizedBox(width: isSmallScreen ? AppSpacing.tiny : AppSpacing.small),
                              Flexible(
                                child: Text(
                                  AppStrings.startWithCyclesFormat(selectedCycles),
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Ses oynatıcı ekranına git
  void _navigateToSoundPlayer(SoundItem sound) {
    _showSoundRepeatModal(sound);
  }

  /// Ses tekrar seçme modal'ı
  void _showSoundRepeatModal(SoundItem sound) {
    final List<int> repeatOptions = [5, 10, 15, 20, 25, 30];
    int selectedRepeats = 10;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            return Container(
              margin: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
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
                                sound.name,
                                style: AppTypography.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                AppStrings.howManyMinutesQuestion,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FeatherIcons.x,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Tekrar seçenekleri - Modern Grid Layout
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: repeatOptions.length,
                        itemBuilder: (context, index) {
                          final repeats = repeatOptions[index];
                          final isSelected = selectedRepeats == repeats;
                          final estimatedMinutes = repeats;
                          
                          return GestureDetector(
                            onTap: () {
                              modalState(() {
                                selectedRepeats = repeats;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? sound.color.withOpacity(0.2)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? sound.color
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$repeats',
                                    style: TextStyle(
                                      color: isSelected
                                          ? sound.color
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.minutesLabel,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '~${estimatedMinutes}dk',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),

                    // Başlat butonu - Modern tasarım
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImmersiveSoundPlayerScreen(sound: sound),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sound.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.medium),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FeatherIcons.play, size: 16),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              AppStrings.startWithMinutesFormat(selectedRepeats),
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Favori istatistikleri göster
  void _showFavoritesStats() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFavoritesStatsModal(),
    );
  }

  /// Favori istatistikleri modal'ı
  Widget _buildFavoritesStatsModal() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final exerciseCount = userPrefs.favoriteExerciseIds.length;
        final soundCount = userPrefs.favoriteSoundIds.length;
        final totalCount = exerciseCount + soundCount;

        return Container(
          margin: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withOpacity(0.95),
                AppColors.surface.withOpacity(0.9),
              ],
            ),
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: AppSpacing.cardPaddingAll,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Row(
                  children: [
                    Icon(
                      FeatherIcons.barChart,
                      color: AppColors.primaryAccent,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Text(
                      AppStrings.favoriteStats,
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // İstatistik kartları
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: FeatherIcons.wind,
                        title: AppStrings.breathingExercisesLabel,
                        count: exerciseCount,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: _buildStatCard(
                        icon: FeatherIcons.music,
                        title: AppStrings.soundContents,
                        count: soundCount,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),

                // Toplam kartı
                _buildStatCard(
                  icon: FeatherIcons.heart,
                  title: AppStrings.totalFavorites,
                  count: totalCount,
                  color: AppColors.warning,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.large),

                // Kapatma butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.medium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppStrings.closeLabel,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// İstatistik kartı widget'ı
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    bool isFullWidth = false,
  }) {
    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            count.toString(),
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.tiny),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Modern egzersiz kartı - normal egzersiz listesindeki gibi
  Widget _buildModernExerciseCard(BuildContext context, BreathingExercise exercise) {
    final category = exercise.category;
    
    return GestureDetector(
      onTap: () => _navigateToBreathingExercise(exercise),
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface.withOpacity(0.9),
              AppColors.surface.withOpacity(0.8),
              _getCategoryColor(category).withOpacity(0.15),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getCategoryColor(category).withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: _getCategoryColor(category).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol: Mini thumbnail
              Center(child: _buildCompactThumbnail(exercise, category)),

              const SizedBox(width: AppSpacing.medium),

              // Orta: Bilgiler
              Expanded(child: _buildCompactInfo(exercise, category)),

              const SizedBox(width: AppSpacing.small),

              // Sağ: Favorite + Play
              _buildCompactActions(exercise, category),
            ],
          ),
        ),
      ),
    );
  }

  // Kompakt thumbnail widget
  Widget _buildCompactThumbnail(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final thumbnailSize = screenWidth < 400 ? 90.0 : (screenWidth < 500 ? 100.0 : 110.0);
    
    return Container(
      width: thumbnailSize,
      height: thumbnailSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(category).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Resim - Yüksek Kalite ve Sıkıştırmasız
            Container(
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  _getExerciseImage(exercise),
                  fit: BoxFit.contain,
                  cacheWidth: 300,
                  cacheHeight: 300,
                  isAntiAlias: true,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(category).withOpacity(0.6),
                            _getCategoryColor(category).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Icon(
                        _getExerciseIcon(exercise),
                        color: Colors.white.withOpacity(0.8),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Hafif overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kompakt bilgi widget
  Widget _buildCompactInfo(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth < 400 ? 16.0 : (screenWidth < 500 ? 17.0 : 18.0);
    final descFontSize = screenWidth < 400 ? 11.0 : (screenWidth < 500 ? 12.0 : 13.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Row(
                children: [
                  Flexible(
                    child: Text(
                      exercise.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Açıklama
              Text(
                _getExerciseShortDescription(exercise),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: descFontSize,
                  height: 1.4,
                ),
                softWrap: true,
              ),
            ],
          ),
          // Timing badge
          _buildTimingChips(exercise, category),
        ],
      ),
    );
  }

  Color _getStepColor(BreathingStepType type, BreathingCategory category) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppColors.success;
      case BreathingStepType.hold:
        return AppColors.warning;
      case BreathingStepType.exhale:
        return AppColors.info;
      default:
        return _getCategoryColor(category);
    }
  }

  String _getStepLabel(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppStrings.inhale;
      case BreathingStepType.hold:
        return AppStrings.hold;
      case BreathingStepType.exhale:
        return AppStrings.exhale;
      case BreathingStepType.holdAfterExhale:
        return AppStrings.holdAfterExhale;
      default:
        return '';
    }
  }

  Widget _buildTimingChips(BreathingExercise exercise, BreathingCategory category) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: exercise.steps
          .where((step) => _getStepLabel(step.type).isNotEmpty)
          .map((step) {
        final color = _getStepColor(step.type, category);
        final label = _getStepLabel(step.type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            '${step.duration}${AppStrings.secondsShort} $label',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Kompakt aksiyonlar widget
  Widget _buildCompactActions(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconButtonSize = screenWidth < 400 ? 38.0 : 44.0;
    final playButtonSize = screenWidth < 400 ? 46.0 : 54.0;
    final iconSize = screenWidth < 400 ? 20.0 : 26.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Favorite button
        Consumer<UserPreferencesProvider>(
          builder: (context, userPrefs, child) {
            final isFavorite = userPrefs.isFavoriteExercise(exercise.type.name);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                userPrefs.toggleFavoriteExercise(exercise.type.name);
              },
              child: Container(
                width: iconButtonSize,
                height: iconButtonSize,
                decoration: BoxDecoration(
                  color: isFavorite 
                      ? Colors.red.withOpacity(0.15)
                      : AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFavorite 
                        ? Colors.red.withOpacity(0.5)
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                  size: screenWidth < 400 ? 18 : 22,
                ),
              ),
            );
          },
        ),
        
        // Play button
        Container(
          width: playButtonSize,
          height: playButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(category).withOpacity(1),
                _getCategoryColor(category).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColor(category).withOpacity(0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            FeatherIcons.play,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppColors.focus;
      case BreathingCategory.kaygiVeStres:
        return AppColors.relaxation;
      case BreathingCategory.uykuVeRahatlama:
        return AppColors.sleep;
      case BreathingCategory.enerjiVeCanlilik:
        return AppColors.energy;
    }
  }

  IconData _getExerciseIcon(BreathingExercise exercise) {
    switch (exercise.name) {
      case 'Kutu Nefesi (4-4-4-4)':
        return FeatherIcons.square;
      case 'Basit Sayma Nefesi':
        return FeatherIcons.hash;
      case 'Farkındalık Nefesi':
        return FeatherIcons.eye;
      case 'Uzun Verme Nefesi (4-6)':
        return FeatherIcons.wind;
      case 'Diyafram Nefesi':
        return FeatherIcons.circle;
      case 'Eşit Nefes':
        return FeatherIcons.minimize2;
      case 'Yavaşlatıcı Nefes':
        return FeatherIcons.moon;
      case 'Vücut Tarama ile Nefes':
        return FeatherIcons.search;
      case 'Gevşeme Nefesi (3-6)':
        return FeatherIcons.sunset;
      case 'Canlandırıcı Diyafram':
        return FeatherIcons.sun;
      case 'Sabah Nefesi':
        return FeatherIcons.sunrise;
      case 'Güne Başlama Nefesi (6-4)':
        return FeatherIcons.zap;
      default:
        return FeatherIcons.wind;
    }
  }

  String _getExerciseImage(BreathingExercise exercise) {
    return exercise.imagePath;
  }

  String _getExerciseShortDescription(BreathingExercise exercise) {
    switch (exercise.name) {
      case 'Kutu Nefesi (4-4-4-4)':
        return AppStrings.boxBreathingDesc;
      case 'Basit Sayma Nefesi':
        return AppStrings.simpleCountingBreathDesc;
      case 'Farkındalık Nefesi':
        return AppStrings.awarenessBreathDesc;
      case 'Uzunca Nefes Ver (4-6)':
        return AppStrings.longExhaleDesc;
      case 'Diyafram Nefesi':
        return AppStrings.diaphragmBreathDesc;
      case 'Eşit Nefes':
        return AppStrings.equalBreathDesc;
      case 'Yavaşlatıcı Nefes':
        return AppStrings.slowingBreathDesc;
      case 'Beden Farkındalığı Nefesi':
        return AppStrings.bodyAwarenessBreathDesc;
      case 'Gevşeme Nefesi (3-6)':
        return AppStrings.relaxationBreathDesc;
      case 'Canlandırıcı Diyafram':
        return AppStrings.energizingDiaphragmDesc;
      case 'Sabah Nefesi':
        return AppStrings.morningBreathDesc;
      case 'Güne Başlama Nefesi (6-4)':
        return AppStrings.dayStartBreathDesc;
      default:
        return exercise.purpose;
    }
  }
}
