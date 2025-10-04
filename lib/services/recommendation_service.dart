import 'package:flutter/material.dart';
import '../providers/user_preferences_provider.dart';
import '../models/smart_recommendation.dart';
import '../models/mood_type.dart';
import '../screens/breathing_screen.dart';
import '../screens/sleep_screen.dart';

class RecommendationService {
  final UserPreferencesProvider _prefsProvider;
  final BuildContext _context;

  RecommendationService(this._prefsProvider, this._context);

  List<SmartRecommendation> getSmartRecommendations() {
    final now = DateTime.now();
    final recommendations = <SmartRecommendation>[];

    // Kural 0: Yeni kullanıcı karşılama (Bu kural tek başına çalışır ve diğerlerini engeller)
    if (_prefsProvider.isFirstLaunch) {
      recommendations.add(SmartRecommendation(
        title: "Breathe Flow'a Hoş Geldin!",
        description: "Zihinsel sağlık yolculuğun burada başlıyor. 3 dakikalık bir rahatlama nefesiyle tanışmaya ne dersin?",
        ctaText: "Hadi Başlayalım",
        icon: "gift",
        onCtaPressed: () {
          Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          _prefsProvider.setFirstLaunchCompleted();
        },
      ));
      return recommendations; // Yeni kullanıcıya sadece bu kartı göster
    }

    // Kural 1: Dün gece az uyuduysa (6 saatten az)
    final lastSleepDuration = _prefsProvider.lastSleepDurationHours;
    if (lastSleepDuration != null && lastSleepDuration < 6.0) {
      final lastSleepTime = _prefsProvider.lastSleepSessionTimestamp;
      if (lastSleepTime != null && now.difference(lastSleepTime).inHours < 18) {
        recommendations.add(SmartRecommendation(
          title: "Yorgun Bir Gece Miydi?",
          description: "Görünüşe göre dün gece pek dinlenemedin. Güne 5 dakikalık bir enerji nefesiyle başlayarak zindelik kazan.",
          ctaText: "Enerji Nefesi Yap",
          icon: "sun",
          onCtaPressed: () {
            Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          },
        ));
      }
    }

    // Kural 2: Stres seviyesi yüksek ölçüldüyse
    final lastHrv = _prefsProvider.lastHrvScore;
    if (lastHrv != null && lastHrv > 70) { // 70'i stres eşiği varsayalım
      final lastHrvTime = _prefsProvider.lastHrvSessionTimestamp;
      if (lastHrvTime != null && now.difference(lastHrvTime).inHours < 12) {
        recommendations.add(SmartRecommendation(
          title: "Stres Seviyen Yüksek",
          description: "Vücudun biraz gergin görünüyor. 4-7-8 tekniği ile anında rahatlayarak dengeyi yeniden bul.",
          ctaText: "4-7-8 Nefesi Yap",
          icon: "heart",
          onCtaPressed: () {
            Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          },
        ));
      }
    }

    // Kural 3: Akşam olduysa ve gün içinde hiç seans yapılmadıysa
    if (now.hour >= 20) {
      final lastSessionTime = _prefsProvider.lastSessionDate;
      bool sessionToday = lastSessionTime != null && now.difference(lastSessionTime).inDays == 0;
      if (!sessionToday) {
        recommendations.add(SmartRecommendation(
          title: "Günü Sakin Kapat",
          description: "Bugün kendine hiç zaman ayırmadın. Kısa bir uyku hikayesi ile zihnini dinlendir ve geceye huzurlu başla.",
          ctaText: "Uyku Hikayesi Dinle",
          icon: "moon",
          onCtaPressed: () {
            Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const SleepScreen()));
          },
        ));
      }
    }

    return recommendations;
  }
}