import 'package:flutter/material.dart';

enum PremiumTriggerType {
  sessionCompleted,     // Seans tamamlandığında
  featureLimit,        // Özellik limitine ulaşıldığında
  contentFinished,     // İçerik tamamlandığında
  userEngagement,      // Kullanıcı etkileşimi yüksek olduğunda
  timeBasedUsage,      // Belirli kullanım süresinden sonra
  achievementUnlocked, // Başarı kazanıldığında
  weeklyGoalReached,   // Haftalık hedef ulaşıldığında
}

enum PremiumOfferType {
  fullPremium,         // Tam premium paket
  specificFeature,     // Belirli özellik odaklı
  trialOffer,         // Deneme sürümü
  discountOffer,      // İndirimli teklif
  bundleOffer,        // Paket teklif
}

class PremiumTrigger {
  final String id;
  final PremiumTriggerType type;
  final String title;
  final String description;
  final String actionText;
  final IconData icon;
  final Color color;
  final PremiumOfferType offerType;
  final Map<String, dynamic> conditions;
  final int priority; // Yüksek öncelik = daha önemli
  final Duration cooldown; // Tekrar gösterilme süresi
  final List<String> targetFeatures; // Hangi özellikleri vurgular

  const PremiumTrigger({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionText,
    required this.icon,
    required this.color,
    required this.offerType,
    required this.conditions,
    this.priority = 1,
    this.cooldown = const Duration(days: 7),
    this.targetFeatures = const [],
  });

  factory PremiumTrigger.fromJson(Map<String, dynamic> json) {
    return PremiumTrigger(
      id: json['id'],
      type: PremiumTriggerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PremiumTriggerType.sessionCompleted,
      ),
      title: json['title'],
      description: json['description'],
      actionText: json['actionText'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      offerType: PremiumOfferType.values.firstWhere(
        (e) => e.name == json['offerType'],
        orElse: () => PremiumOfferType.fullPremium,
      ),
      conditions: Map<String, dynamic>.from(json['conditions']),
      priority: json['priority'] ?? 1,
      cooldown: Duration(days: json['cooldownDays'] ?? 7),
      targetFeatures: List<String>.from(json['targetFeatures'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'actionText': actionText,
      'icon': icon.codePoint,
      'color': color.value,
      'offerType': offerType.name,
      'conditions': conditions,
      'priority': priority,
      'cooldownDays': cooldown.inDays,
      'targetFeatures': targetFeatures,
    };
  }

  // Roadmap'teki örneklere göre hazır tetikleyiciler
  static final List<PremiumTrigger> predefinedTriggers = [
    // 1. Stres azaltma yolculuğu tamamlandığında
    PremiumTrigger(
      id: 'stress_journey_completed',
      type: PremiumTriggerType.achievementUnlocked,
      title: 'Harika bir başlangıç yaptın! 🎉',
      description: 'Şimdi "İleri Seviye Farkındalık" yolculuğu ile devam etmek için Premium\'a geç.',
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
      description: 'Sınırsız manzara kaydetmek ve yeni HD seslere erişmek için Premium\'a geç.',
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
      description: 'Bu serinin tüm bölümlerine ve özel hikayelere erişim için Premium\'a geç.',
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
      description: 'Gelişmiş HRV analizi ve kişiselleştirilmiş öneriler için Premium\'a geç.',
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
      description: 'Başarını sürdürmek için Premium özelliklerle kendini daha da geliştir.',
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
      description: 'Gelişmiş nefes teknikleri ve kişiselleştirilmiş programlar için Premium\'a geç.',
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
  ];

  // Tetikleyici koşullarını kontrol et
  bool checkConditions(Map<String, dynamic> userContext) {
    for (final entry in conditions.entries) {
      final key = entry.key;
      final expectedValue = entry.value;
      final actualValue = userContext[key];

      if (actualValue == null) return false;

      // Sayısal karşılaştırmalar
      if (expectedValue is num && actualValue is num) {
        if (actualValue < expectedValue) return false;
      }
      // String karşılaştırmaları
      else if (expectedValue is String && actualValue is String) {
        if (expectedValue != 'any' && actualValue != expectedValue) return false;
      }
      // Boolean karşılaştırmaları
      else if (expectedValue is bool && actualValue is bool) {
        if (actualValue != expectedValue) return false;
      }
      // Liste kontrolü
      else if (expectedValue is List && actualValue is List) {
        final expectedList = expectedValue.cast<String>();
        final actualList = actualValue.cast<String>();
        if (!expectedList.every((item) => actualList.contains(item))) return false;
      }
    }

    return true;
  }
}

class PremiumOffer {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final String price;
  final String originalPrice;
  final int discountPercentage;
  final Duration validFor;
  final String ctaText;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isLimitedTime;

  const PremiumOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.price,
    this.originalPrice = '',
    this.discountPercentage = 0,
    this.validFor = const Duration(days: 7),
    required this.ctaText,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.isLimitedTime = false,
  });

  static final Map<PremiumOfferType, PremiumOffer> offers = {
    PremiumOfferType.fullPremium: PremiumOffer(
      id: 'full_premium',
      title: 'BreatheFlow Premium',
      subtitle: 'Tüm özelliklere sınırsız erişim',
      description: 'Stres yönetiminde bir sonraki seviyeye çık',
      features: [
        'Sınırsız premium ses kütüphanesi',
        'Gelişmiş nefes teknikleri',
        'Kişiselleştirilmiş programlar',
        'Detaylı HRV analizi',
        'Uzman içerikleri',
        'Reklamsız deneyim',
        'Öncelikli destek'
      ],
      price: '₺19,99/ay',
      ctaText: 'Premium\'a Başla',
      icon: Icons.star,
      primaryColor: const Color(0xFF7D8AFF),
      secondaryColor: const Color(0xFFB8C2FF),
    ),

    PremiumOfferType.specificFeature: PremiumOffer(
      id: 'specific_feature',
      title: 'Özel Özellik Paketi',
      subtitle: 'İhtiyacın olan özelliklere odaklan',
      description: 'Sadece kullandığın özellikler için ödeme yap',
      features: [
        'Seçili premium içerikler',
        'Gelişmiş analitikler',
        'Özel ses koleksiyonu'
      ],
      price: '₺19,99/ay',
      ctaText: 'Özel Paketi Al',
      icon: Icons.tune,
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF81C784),
    ),

    PremiumOfferType.trialOffer: PremiumOffer(
      id: 'trial_offer',
      title: '7 Gün Ücretsiz Deneme',
      subtitle: 'Risk almadan tüm özellikleri dene',
      description: 'İstediğin zaman iptal edebilirsin',
      features: [
        'Tüm premium özellikler',
        'İstediğin zaman iptal',
        'Otomatik yenileme yok'
      ],
      price: 'Ücretsiz',
      originalPrice: '₺29,99',
      ctaText: 'Ücretsiz Dene',
      icon: Icons.free_breakfast,
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF64B5F6),
    ),

    PremiumOfferType.discountOffer: PremiumOffer(
      id: 'discount_offer',
      title: 'Özel İndirim!',
      subtitle: '%50 indirimle premium',
      description: 'Sadece bugün geçerli özel fırsat',
      features: [
        'Tüm premium özellikler',
        '%50 indirim',
        'Sınırlı süre'
      ],
      price: '₺9,99/ay',
      originalPrice: '₺19,99',
      discountPercentage: 50,
      ctaText: 'İndirimi Yakala',
      icon: Icons.local_offer,
      primaryColor: const Color(0xFFFF5722),
      secondaryColor: const Color(0xFFFF8A65),
      isLimitedTime: true,
    ),

    PremiumOfferType.bundleOffer: PremiumOffer(
      id: 'bundle_offer',
      title: 'Yıllık Premium',
      subtitle: '2 ay bedava!',
      description: 'Yıllık ödeme ile en iyi fiyat',
      features: [
        'Tüm premium özellikler',
        '2 ay ücretsiz',
        'Yıllık faturalama'
      ],
      price: '₺299,99/yıl',
      originalPrice: '₺359,88',
      discountPercentage: 17,
      ctaText: 'Yıllık Paketi Al',
      icon: Icons.card_giftcard,
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFBA68C8),
    ),
  };
} 