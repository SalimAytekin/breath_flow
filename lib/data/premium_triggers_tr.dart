import 'package:flutter/material.dart';
import '../models/premium_trigger.dart';
import '../constants/app_strings.dart';

/// Lokalize premium trigger mesajları
/// Bu dosya çoklu dil desteğini JSON çeviri dosyalarından alır.
class PremiumTriggersData {
  
  /// Tüm lokalize premium trigger'ları döndürür
  static List<PremiumTrigger> getPredefinedTriggers() => [
        // 1. Stres azaltma yolculuğu tamamlandığında
        PremiumTrigger(
          id: 'stress_journey_completed',
          type: PremiumTriggerType.achievementUnlocked,
          title: AppStrings.triggerStressJourneyTitle,
          description: AppStrings.triggerStressJourneyDesc,
          actionText: AppStrings.triggerStressJourneyAction,
          icon: Icons.psychology,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'journeyCompleted': true,
            'completionRate': 0.7,
          },
          priority: 3,
          cooldown: Duration(days: 3),
          targetFeatures: ['advanced_journeys', 'expert_content'],
        ),

        // 2. Ses manzarası kaydetme limiti
        PremiumTrigger(
          id: 'sound_mixer_limit',
          type: PremiumTriggerType.featureLimit,
          title: AppStrings.triggerSoundMixerTitle,
          description: AppStrings.triggerSoundMixerDesc,
          actionText: AppStrings.triggerSoundMixerAction,
          icon: Icons.music_note,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'savedMixesCount': 2,
            'featureUsage': 'sound_mixer',
          },
          priority: 2,
          cooldown: Duration(days: 2),
          targetFeatures: ['unlimited_mixes', 'hd_sounds'],
        ),

        // 3. Uzman dersi dinlendikten sonra
        PremiumTrigger(
          id: 'expert_content_teaser',
          type: PremiumTriggerType.contentFinished,
          title: AppStrings.triggerExpertContentTitle,
          description: AppStrings.triggerExpertContentDesc,
          actionText: AppStrings.triggerExpertContentAction,
          icon: Icons.school,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'expertContentId': 'dr_ayse_stress_management',
            'completionRate': 1.0,
          },
          priority: 3,
          targetFeatures: ['expert_content', 'full_series'],
        ),

        // 4. Hikaye serisi premium bölümüne ulaşıldığında
        PremiumTrigger(
          id: 'story_series_premium',
          type: PremiumTriggerType.featureLimit,
          title: AppStrings.triggerStorySeriesTitle,
          description: AppStrings.triggerStorySeriesDesc,
          actionText: AppStrings.triggerStorySeriesAction,
          icon: Icons.auto_stories,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'storySeriesId': 'any_premium_series',
            'episodeType': 'premium',
          },
          priority: 2,
          targetFeatures: ['premium_stories', 'exclusive_content'],
        ),

        // 5. HRV ölçümü sonrası gelişmiş analiz
        PremiumTrigger(
          id: 'hrv_advanced_analysis',
          type: PremiumTriggerType.sessionCompleted,
          title: AppStrings.triggerHrvAnalysisTitle,
          description: AppStrings.triggerHrvAnalysisDesc,
          actionText: AppStrings.triggerHrvAnalysisAction,
          icon: Icons.favorite,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'feature': 'hrv_measurement',
            'measurementCount': 3,
          },
          priority: 2,
          targetFeatures: ['advanced_hrv', 'personalized_insights'],
        ),

        // 6. Haftalık hedef tamamlandığında
        PremiumTrigger(
          id: 'weekly_goal_achieved',
          type: PremiumTriggerType.weeklyGoalReached,
          title: AppStrings.triggerWeeklyGoalTitle,
          description: AppStrings.triggerWeeklyGoalDesc,
          actionText: AppStrings.triggerWeeklyGoalAction,
          icon: Icons.emoji_events,
          color: const Color(0xFFD4A574),
          offerType: PremiumOfferType.fullPremium,
          conditions: {
            'weeklyGoalCompletion': 1.0,
            'consecutiveWeeks': 1,
          },
          priority: 1,
          targetFeatures: ['all_features'],
        ),

        // 7. Yoğun kullanım sonrası
        PremiumTrigger(
          id: 'power_user_offer',
          type: PremiumTriggerType.userEngagement,
          title: AppStrings.triggerPowerUserTitle,
          description: AppStrings.triggerPowerUserDesc,
          actionText: AppStrings.triggerPowerUserAction,
          icon: Icons.star,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.discountOffer,
          conditions: {
            'dailyUsageDays': 7,
            'totalSessions': 20,
            'featuresUsed': 5,
          },
          priority: 3,
          cooldown: Duration(days: 30),
          targetFeatures: ['all_features'],
        ),

        // 8. Nefes egzersizi ustası
        PremiumTrigger(
          id: 'breathing_master',
          type: PremiumTriggerType.achievementUnlocked,
          title: AppStrings.triggerBreathingMasterTitle,
          description: AppStrings.triggerBreathingMasterDesc,
          actionText: AppStrings.triggerBreathingMasterAction,
          icon: Icons.air,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'breathingSessionsCompleted': 15,
            'differentTechniquesUsed': 3,
          },
          priority: 2,
          targetFeatures: ['advanced_breathing', 'custom_programs'],
        ),

        // 9. Uyku takibi başarısı
        PremiumTrigger(
          id: 'sleep_tracking_success',
          type: PremiumTriggerType.achievementUnlocked,
          title: AppStrings.triggerSleepTrackingTitle,
          description: AppStrings.triggerSleepTrackingDesc,
          actionText: AppStrings.triggerSleepTrackingAction,
          icon: Icons.nightlight_round,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'consecutiveSleepDays': 7,
            'averageSleepQuality': 0.8,
          },
          priority: 2,
          targetFeatures: ['advanced_sleep_analysis', 'sleep_insights'],
        ),

        // 10. Favori özellik kullanımı
        PremiumTrigger(
          id: 'favorite_feature_limit',
          type: PremiumTriggerType.featureLimit,
          title: AppStrings.triggerFavoriteLimitTitle,
          description: AppStrings.triggerFavoriteLimitDesc,
          actionText: AppStrings.triggerFavoriteLimitAction,
          icon: Icons.favorite,
          color: const Color(0xFFC4956A),
          offerType: PremiumOfferType.fullPremium,
          conditions: {
            'favoritesCount': 10,
          },
          priority: 2,
          cooldown: Duration(days: 7),
          targetFeatures: ['unlimited_favorites', 'all_features'],
        ),
      ];
  
  /// Abonelik süresi dolduğunda gösterilecek trigger
  static PremiumTrigger get subscriptionExpired => PremiumTrigger(
    id: 'subscription_expired',
    type: PremiumTriggerType.timeBasedUsage,
    title: AppStrings.triggerSubscriptionExpiredTitle,
    description: AppStrings.triggerSubscriptionExpiredDesc,
    actionText: AppStrings.triggerSubscriptionExpiredAction,
    icon: Icons.access_time_rounded,
    color: const Color(0xFFD4A574),
    offerType: PremiumOfferType.fullPremium,
    conditions: {},
    priority: 5,
    cooldown: Duration(hours: 12),
    targetFeatures: ['ad_free', 'all_exercises', 'premium_sounds'],
  );
}
