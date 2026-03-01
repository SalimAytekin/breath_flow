import 'package:flutter/material.dart';
import '../data/premium_triggers_tr.dart';

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

  /// Hazır premium tetikleyicileri döndürür (çoklu dil desteği için data dosyasından)
  static List<PremiumTrigger> get predefinedTriggers {
    // TODO: Dil seçimine göre farklı data dosyaları kullanılabilir
    // Şimdilik Türkçe kullanıyoruz
    return PremiumTriggersData.getPredefinedTriggers();
  }

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
      primaryColor: const Color(0xFFC4956A),
      secondaryColor: const Color(0xFFD4A574),
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
      primaryColor: const Color(0xFFC4956A),
      secondaryColor: const Color(0xFFD4A574),
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
      primaryColor: const Color(0xFFC4956A),
      secondaryColor: const Color(0xFFD4A574),
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
      primaryColor: const Color(0xFFD4A574),
      secondaryColor: const Color(0xFFC4956A),
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
      primaryColor: const Color(0xFFC4956A),
      secondaryColor: const Color(0xFFD4A574),
    ),
  };
} 