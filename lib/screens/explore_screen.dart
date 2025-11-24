import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/professional_card.dart';
import '../widgets/global_background.dart';
import '../services/asset_manager.dart';
import '../ui/components/ad_container.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import 'breathing_screen.dart';
import 'sounds_screen.dart';
import 'sleep_screen.dart';
import 'sleep_input_screen.dart';
import 'sleep_analytics_screen.dart';
import 'sleep_journal_screen.dart';

// 🚧 V2.0 Features - Temporarily Disabled
// import 'sleep_stories_screen.dart';
// import 'journeys_screen.dart';
// import 'hrv_measurement_screen.dart';
// import 'journal_screen.dart';

/// 🧭 Professional Explore Screen
/// Redesigned with Deep Night Serenity theme system
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 🧭 Professional Header
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: _buildProfessionalHeader(context),
              ),
              
              const SizedBox(height: AppSpacing.xxLarge),
              
              // 🫁 Nefes Egzersizleri
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 50),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.wind,
                  title: 'Nefes Egzersizleri',
                  subtitle: 'Stres azaltma ve odaklanma teknikleri',
                  children: [
                    // Ana kart - Tüm egzersizler
                    _buildFeatureCard(
                      title: 'Tüm Egzersizler',
                      subtitle: 'Kategoriler ve tüm nefes teknikleri',
                      imageUrl: AssetManager.coverMeditationBell,
                      onTap: () => _navigateToBreathing(context),
                    ),
                    // Popüler egzersizler - Direkt başlatma
                    _buildFeatureCard(
                      title: 'Kutu Nefes',
                      subtitle: '4-4-4-4 ritmi ile sakinleşme',
                      imageUrl: AssetManager.kutuNefesi,
                      onTap: () => _navigateToDirectExercise(context, 'Kutu Nefesi (4-4-4-4)'),
                    ),
                    _buildFeatureCard(
                      title: 'Yavaşlatıcı Nefes',
                      subtitle: 'Her nefeste ritmi yavaşlat, uykuya hazırlan',
                      imageUrl: AssetManager.yavaslaticiNefes,
                      onTap: () => _navigateToDirectExercise(context, 'Yavaşlatıcı Nefes'),
                    ),
                    _buildFeatureCard(
                      title: 'Diyafram Nefesi',
                      subtitle: 'Karnından nefes al, stresi azalt',
                      imageUrl: AssetManager.diyaframNefesi,
                      onTap: () => _navigateToDirectExercise(context, 'Diyafram Nefesi'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // 🎵 Ses Koleksiyonu
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.music,
                  title: 'Ses Koleksiyonu',
                  subtitle: 'Rahatlatıcı sesler ve karıştırıcı',
                  children: [
                    _buildFeatureCard(
                      title: 'Tüm Sesler',
                      subtitle: 'Tüm ses koleksiyonunu keşfet',
                      imageUrl: AssetManager.coverOcean,
                      onTap: () => _navigateToSounds(context),
                    ),
                    _buildFeatureCard(
                      title: 'Uyku İçin',
                      subtitle: 'Derin uykuya dalmanıza yardımcı',
                      imageUrl: AssetManager.coverRain,
                      onTap: () => _navigateToSoundsFiltered(
                        context,
                        title: 'Uyku İçin Sesler',
                        tags: ['sleep'],
                      ),
                    ),
                    _buildFeatureCard(
                      title: 'Meditasyon & Rahatlama',
                      subtitle: 'Huzurlu anlar için sesler',
                      imageUrl: AssetManager.coverMeditationBell,
                      onTap: () => _navigateToSoundsFiltered(
                        context,
                        title: 'Meditasyon & Rahatlama',
                        tags: ['meditation', 'relaxation'],
                      ),
                    ),
                    _buildFeatureCard(
                      title: 'Odaklanma & Çalışma',
                      subtitle: 'Konsantrasyonunuzu artırın',
                      imageUrl: AssetManager.coverLofi,
                      onTap: () => _navigateToSoundsFiltered(
                        context,
                        title: 'Odaklanma & Çalışma',
                        tags: ['focus'],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxLarge),
              
              // 🌙 Uyku Takibi
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 150),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.moon,
                  title: 'Uyku Takibi',
                  subtitle: 'Uyku kalitenizi takip edin ve analiz edin',
                  children: [
                    _buildFeatureCard(
                      title: 'Uyku Kaydı',
                      subtitle: 'Ne kadar uyuduğunu kaydet',
                      imageUrl: AssetManager.sleepRecord,
                      onTap: () => _navigateToSleepInput(context),
                    ),
                    _buildFeatureCard(
                      title: 'Uyku İstatistikleri',
                      subtitle: 'Kalite ve trendlerini gör',
                      imageUrl: AssetManager.sleepStats,
                      onTap: () => _navigateToSleepAnalytics(context),
                    ),
                    _buildFeatureCard(
                      title: 'Uyku Günlüğü',
                      subtitle: 'Rüyalarını ve notlarını kaydet',
                      imageUrl: AssetManager.sleepJournal,
                      onTap: () => _navigateToSleepJournal(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🧭 Professional Header with Glass Effect
  Widget _buildProfessionalHeader(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Keşfet sayfası',
      child: ProfessionalCard(
        cardType: CardType.glass,
        padding: AppSpacing.cardPaddingAll,
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withOpacity(0.2),
                    AppColors.primaryAccent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                FeatherIcons.compass,
                color: AppColors.primaryAccent,
                size: AppSpacing.iconLarge,
              ),
            ),
            
            const SizedBox(width: AppSpacing.large),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keşfet',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.tiny),
                  Text(
                    'Tüm özellikler ve içerikler burada',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primaryAccent,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.displaySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.tiny),
              Text(
                subtitle,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        // ♿ Accessibility: Semantics wrapper for horizontal scroll hint
        Semantics(
          label: '$title kategorisi',
          hint: 'Yatay kaydırarak ${children.length} farklı seçenek arasından gezinebilirsiniz',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 400;
            final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
            final cardHeight = isSmallScreen ? 180.0 : (isMediumScreen ? 190.0 : 200.0);
            
            return SizedBox(
              height: cardHeight,
              child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.9, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
            child: ListView.separated(
              itemCount: children.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.medium),
              itemBuilder: (context, index) => children[index],
              ),
            ),
          );
        },
      ),
      ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    VoidCallback? onTap,
  }) {
    // ♿ Accessibility wrapper
    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      enabled: onTap != null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
          final cardWidth = isSmallScreen ? 140.0 : (isMediumScreen ? 150.0 : 160.0);
          
          return SizedBox(
            width: cardWidth,
            child: FeatureCard(
              title: title,
              subtitle: subtitle,
              imageUrl: imageUrl,
              onTap: onTap,
            ),
          );
        },
      ),
    );
  }
  

  // 🚀 Navigation Methods
  void _navigateToBreathing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BreathingScreen(),
      ),
    );
  }

  /// Direkt spesifik egzersizi başlat - Döngü seçimi ile
  void _navigateToDirectExercise(BuildContext context, String exerciseName) {
    try {
      // Egzersizi bul
      final exercise = BreathingExercise.allExercises
          .firstWhere((ex) => ex.name == exerciseName);
      
      // Döngü seçim modalını göster
      _showCycleSelectionModal(context, exercise);
    } on StateError {
      // Egzersiz bulunamadı - kullanıcıyı bilgilendir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Egzersiz bulunamadı, tüm egzersizler sayfasına yönlendiriliyorsunuz'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      // Fallback olarak normal breathing screen'e git
      _navigateToBreathing(context);
    }
  }

  /// Döngü seçim modalı - ExerciseListScreen'den uyarlandı
  void _showCycleSelectionModal(BuildContext context, BreathingExercise exercise) {
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
                  topLeft: Radius.circular(AppSpacing.large),
                  topRight: Radius.circular(AppSpacing.large),
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
                                'Kaç tekrar yapmak istiyorsun?',
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
                          onTap: () {
                            modalState(() {
                              selectedCycles = cycles;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryAccent.withOpacity(0.2)
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryAccent
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
                                        ? AppColors.primaryAccent
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                Text(
                                  'tekrar',
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

                    // Başlat butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Egzersizi set et ve başlat
                          breathingProvider.setExercise(exercise, customCycles: selectedCycles);
                          breathingProvider.start();
                          
                          Navigator.of(context).pop(); // Modal'ı kapat
                          
                          // BreathingScreen'e git
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BreathingScreen(),
                            ),
                          ).then((_) {
                            // Ekrandan döndüğünde egzersizi durdur
                            breathingProvider.stop();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
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
                            Icon(FeatherIcons.play, size: isSmallScreen ? 18 : 20),
                            SizedBox(width: isSmallScreen ? AppSpacing.tiny : AppSpacing.small),
                            Flexible(
                              child: Text(
                                'Başlat ($selectedCycles tekrar)',
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

  void _navigateToSounds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SoundsScreen(),
      ),
    );
  }

  void _navigateToSoundsFiltered(
    BuildContext context, {
    required String title,
    required List<String> tags,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SoundsScreen(
          customTitle: title,
          filterTags: tags,
        ),
      ),
    );
  }

  void _navigateToSleep(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepScreen(),
      ),
    );
  }

  // 🚧 V2.0 Features - Temporarily Disabled
  // void _navigateToSleepStories(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const SleepStoriesScreen(),
  //     ),
  //   );
  // }

  // void _navigateToJourneys(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const JourneysScreen(),
  //     ),
  //   );
  // }

  // void _navigateToHRV(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const HRVMeasurementScreen(),
  //     ),
  //   );
  // }

  // void _navigateToJournal(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const JournalScreen(),
  //     ),
  //   );
  // }

  void _navigateToSleepInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepInputScreen(),
      ),
    );
  }

  void _navigateToSleepAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepAnalyticsScreen(),
      ),
    );
  }

  void _navigateToSleepJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepJournalScreen(),
      ),
    );
  }
}