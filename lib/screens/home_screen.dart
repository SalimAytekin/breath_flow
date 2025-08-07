import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:breathe_flow/models/sound_item.dart';
import 'package:breathe_flow/screens/breathing_screen.dart';
import 'package:breathe_flow/screens/sounds_screen.dart';
import 'package:breathe_flow/screens/sleep_screen.dart';
import 'package:breathe_flow/screens/sleep_stories_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/mood_type.dart' as models;
import '../models/breathing_exercise.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/breathing_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/mood_card.dart';
import '../widgets/smart_premium_dialog.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/sleep_stats_widget.dart';
import '../widgets/professional_card.dart';
import '../widgets/professional_button.dart';
import '../constants/motivational_quotes.dart';
import '../widgets/professional_loading.dart';
import '../services/recommendation_service.dart';
import '../services/asset_manager.dart';
import '../models/smart_recommendation.dart';

/// 🏠 Professional Home Screen
/// Redesigned with Deep Night Serenity theme system
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Günaydın';
    } else if (hour < 17) {
      greeting = 'Tünaydın';
    } else {
      greeting = 'İyi Akşamlar';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<UserPreferencesProvider>(
        builder: (context, prefsProvider, child) {
          // Akıllı öneri servisini burada, güncel provider ile ilklendir
          final recommendationService = RecommendationService(prefsProvider, context);
          final recommendation = recommendationService.getSmartRecommendation();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent, // Arka plan gradyeninin görünmesi için
                expandedHeight: 120.0,
                pinned: true,
                floating: true,
                stretch: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                  centerTitle: false,
                  title: Text(
                    greeting,
                    style: AppTypography.displaySmall,
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                ),
              ),

              // Akıllı Öneri Kartı
              if (recommendation != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.pagePadding.copyWith(top: 0, bottom: AppSpacing.large),
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: _buildSmartRecommendationCard(context, recommendation),
                    ),
                  ),
                ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(top: 0),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildMotivationalQuote(context),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.large),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 300),
                        child: _buildMainActionButton(context),
                      ),
                      const SizedBox(height: AppSpacing.xxLarge),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: _buildDailyProgress(context),
                      ),
                      const SizedBox(height: AppSpacing.xxLarge),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                        child: _buildQuickAccess(context),
                      ),
                      const SizedBox(height: AppSpacing.xLarge),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🧘 Motivational Quote Card
  Widget _buildMotivationalQuote(BuildContext context) {
    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll.copyWith(top: AppSpacing.large, bottom: AppSpacing.large),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.heart,
                  color: AppColors.relaxation,
                  size: AppSpacing.iconMedium,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    MotivationalQuotes.getDailyQuote(),
                    style: AppTypography.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🫁 Main Action Button with Mood-based Gradient
  Widget _buildMainActionButton(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final mood = userPrefs.preferredMood;
        
        // Mood-based configuration
        final moodConfig = _getMoodConfiguration(mood);
        
        return GradientButton(
          text: moodConfig.buttonText,
          onPressed: () => _startMainAction(context, mood),
          gradient: moodConfig.gradient,
          buttonSize: ButtonSize.large,
          icon: moodConfig.icon,
          width: double.infinity,
          height: 120,
          isPulsing: true,
        );
      },
    );
  }

  /// 📊 Daily Progress with Professional Stats Design
  Widget _buildDailyProgress(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final progress = userPrefs.dailyGoalProgress;
        final goalMinutes = userPrefs.dailyGoalMinutes;
        final todayMinutes = (progress * goalMinutes).round();
        
        return ProfessionalCard(
          cardType: CardType.elevated,
          padding: AppSpacing.cardPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Circular Progress
              Row(
                children: [
                  // Circular Progress Indicator around the icon
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.primaryAccent.withOpacity(0.15),
                          color: AppColors.primaryAccent,
                          strokeWidth: 3.5,
                    ),
                        Center(
                    child: Icon(
                      FeatherIcons.target,
                      color: AppColors.primaryAccent,
                      size: AppSpacing.iconMedium,
                    ),
                  ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.large),
                  Expanded(
                    child: Text(
                      'Bugünkü İlerleme',
                      style: AppTypography.headlineSmall,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.medium),
              
              // Descriptive text
              Text(
                goalMinutes > 0
                    ? '$goalMinutes dakikalık günlük hedefinin $todayMinutes dakikasını tamamladın.'
                    : 'Henüz bir hedef belirlemedin.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ⚡ Quick Access with Professional Feature Cards
  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tiny),
          child: Row(
            children: [
              Text(
                'Hızlı Erişim',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(width: AppSpacing.small),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.large),
        
        // Quick Access Cards
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            child: Row(
              children: [
                Expanded(
                  child: FeatureCard(
                                          imageUrl: AssetManager.coverOcean,
                    title: 'Sesler',
                    subtitle: 'Rahatlatıcı sesler',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SoundsScreen()));
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: FeatureCard(
                                          imageUrl: AssetManager.backgroundBlurryGradient,
                    title: 'Uyku Hikayeleri',
                    subtitle: 'Huzurlu uykuya dalış',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SleepStoriesScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🎭 Mood Configuration Helper
  ({
    String buttonText,
    IconData icon,
    Gradient gradient,
  }) _getMoodConfiguration(models.MoodType mood) {
    switch (mood) {
      case models.MoodType.focus:
        return (
          buttonText: 'Odaklanmaya Başla',
          icon: FeatherIcons.target,
          gradient: AppColors.focusGradient,
        );
      case models.MoodType.relaxation:
        return (
          buttonText: 'Rahatlamaya Başla',
          icon: FeatherIcons.heart,
          gradient: AppColors.relaxationGradient,
        );
      case models.MoodType.sleep:
        return (
          buttonText: 'Uykuya Hazırlan',
          icon: FeatherIcons.moon,
          gradient: AppColors.sleepGradient,
        );
    }
  }

  /// 🚀 Main Action Handler
  void _startMainAction(BuildContext context, models.MoodType mood) {
    final breathingProvider = Provider.of<BreathingProvider>(context, listen: false);
    
    // Mood-based exercise selection
    BreathingExercise exercise;
    switch (mood) {
      case models.MoodType.focus:
        exercise = BreathingExercise.allExercises.firstWhere(
          (e) => e.type == BreathingType.boxBreathing,
          orElse: () => BreathingExercise.allExercises.first,
        );
        break;
      case models.MoodType.relaxation:
        exercise = BreathingExercise.allExercises.firstWhere(
          (e) => e.type == BreathingType.breathing478,
          orElse: () => BreathingExercise.allExercises.first,
        );
        break;
      case models.MoodType.sleep:
        exercise = BreathingExercise.allExercises.firstWhere(
          (e) => e.type == BreathingType.deepBreathing,
          orElse: () => BreathingExercise.allExercises.first,
        );
        break;
    }
    
    breathingProvider.setExercise(exercise);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BreathingScreen(),
      ),
    );
  }

  // YENİ WIDGET: Akıllı Öneri Kartı
  Widget _buildSmartRecommendationCard(BuildContext context, SmartRecommendation recommendation) {
    final Map<String, IconData> iconMap = {
      "sun": FeatherIcons.sun,
      "heart": FeatherIcons.heart,
      "moon": FeatherIcons.moon,
      "gift": FeatherIcons.gift,
    };

    return ProfessionalCard(
      cardType: CardType.glass,
      gradient: AppColors.recommendationGradient, // app_colors'a yeni bir gradyen eklenmeli
      padding: AppSpacing.cardPaddingAll,
      onTap: recommendation.onCtaPressed,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconMap[recommendation.icon] ?? FeatherIcons.star,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  recommendation.description,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Icon(
            FeatherIcons.chevronRight,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}