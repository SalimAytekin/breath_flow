import 'package:flutter/material.dart';
import '../models/premium_trigger.dart';

/// Türkçe premium trigger mesajları
/// Bu dosya çoklu dil desteği için oluşturulmuştur.
/// İngilizce versiyonu için premium_triggers_en.dart dosyasını oluşturun.
class PremiumTriggersTR {
  
  /// Tüm Türkçe premium trigger'ları döndürür
  static List<PremiumTrigger> getPredefinedTriggers() => [
        // 1. Stres azaltma yolculuğu tamamlandığında
        PremiumTrigger(
          id: 'stress_journey_completed',
          type: PremiumTriggerType.achievementUnlocked,
          title: 'Harika bir başlangıç yaptın! 🎉',
          description:
              'Şimdi "İleri Seviye Farkındalık" yolculuğu ile devam etmek için Premium\'a geç.',
          actionText: 'İleri Seviye Yolculuğa Başla',
          icon: Icons.psychology,
          color: const Color(0xFF4CAF50),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'journeyCompleted': true,
            'completionRate': 0.7, // %70 tamamlanma yeterli
          },
          priority: 3,
          cooldown: Duration(days: 3), // 7 gün yerine 3 gün
          targetFeatures: ['advanced_journeys', 'expert_content'],
        ),

        // 2. Ses manzarası kaydetme limiti
        PremiumTrigger(
          id: 'sound_mixer_limit',
          type: PremiumTriggerType.featureLimit,
          title: 'Ses tasarımcısı oldun! 🎵',
          description:
              'Sınırsız manzara kaydetmek ve yeni HD seslere erişmek için Premium\'a geç.',
          actionText: 'Sınırsız Ses Erişimi',
          icon: Icons.music_note,
          color: const Color(0xFFFF9800),
          offerType: PremiumOfferType.specificFeature,
          conditions: {
            'savedMixesCount': 2, // Daha erken tetikle
            'featureUsage': 'sound_mixer',
          },
          priority: 2,
          cooldown: Duration(days: 2), // Daha kısa cooldown
          targetFeatures: ['unlimited_mixes', 'hd_sounds'],
        ),

        // 3. Uzman dersi dinlendikten sonra
        PremiumTrigger(
          id: 'expert_content_teaser',
          type: PremiumTriggerType.contentFinished,
          title: 'Dr. Ayşe Yılmaz\'ın dersini beğendin mi? 👩‍⚕️',
          description: 'Serinin tamamına erişmek için Premium\'a geç.',
          actionText: 'Uzman Serisine Erişim',
          icon: Icons.school,
          color: const Color(0xFF2196F3),
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
          title: 'Hikayenin devamı Premium\'da! 📚',
          description:
              'Bu serinin tüm bölümlerine ve özel hikayelere erişim için Premium\'a geç.',
          actionText: 'Hikayelerin Devamını Dinle',
          icon: Icons.auto_stories,
          color: const Color(0xFF9C27B0),
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
          title: 'Stres seviyeni ölçtük! 📊',
          description:
              'Gelişmiş HRV analizi ve kişiselleştirilmiş öneriler için Premium\'a geç.',
          actionText: 'Detaylı Analiz Al',
          icon: Icons.favorite,
          color: const Color(0xFFE91E63),
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
          title: 'Bu hafta süperdin! ⭐',
          description:
              'Başarını sürdürmek için Premium özelliklerle kendini daha da geliştir.',
          actionText: 'Daha Fazla Başarı İçin',
          icon: Icons.emoji_events,
          color: const Color(0xFFFFD700),
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
          title: 'BreatheFlow\'un gerçek bir uzmanısın! 🧘‍♀️',
          description: 'Tüm premium özelliklere özel indirimli erişim fırsatı.',
          actionText: '%50 İndirimle Premium Al',
          icon: Icons.star,
          color: const Color(0xFF673AB7),
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
          title: 'Nefes egzersizi ustası oldun! 🌬️',
          description:
              'Gelişmiş nefes teknikleri ve kişiselleştirilmiş programlar için Premium\'a geç.',
          actionText: 'Uzman Tekniklerini Keşfet',
          icon: Icons.air,
          color: const Color(0xFF00BCD4),
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
          title: 'Uyku düzenin harika! 😴',
          description:
              'Gelişmiş uyku analizi ve kişiselleştirilmiş öneriler için Premium\'a geç.',
          actionText: 'Detaylı Uyku Analizi',
          icon: Icons.nightlight_round,
          color: const Color(0xFF5E35B1),
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
          title: 'Favorilerin doldu! ⭐',
          description:
              'Sınırsız favori eklemek ve tüm özelliklere erişmek için Premium\'a geç.',
          actionText: 'Sınırsız Favori Ekle',
          icon: Icons.favorite,
          color: const Color(0xFFE91E63),
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
  static PremiumTrigger get subscriptionExpired => const PremiumTrigger(
    id: 'subscription_expired',
    type: PremiumTriggerType.timeBasedUsage,
    title: 'Premium Süreniz Doldu ⏰',
    description:
        'Premium aboneliğiniz sona erdi. Reklamsız deneyim, tüm egzersizler ve premium sesler için aboneliğinizi yenileyin.',
    actionText: 'Aboneliği Yenile',
    icon: Icons.access_time_rounded,
    color: Color(0xFFFF9800),
    offerType: PremiumOfferType.fullPremium,
    conditions: {},
    priority: 5, // En yüksek öncelik
    cooldown: Duration(hours: 12), // 12 saat sonra tekrar gösterilebilir
    targetFeatures: ['ad_free', 'all_exercises', 'premium_sounds'],
  );
}
