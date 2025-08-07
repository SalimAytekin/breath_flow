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

  SmartRecommendation? getSmartRecommendation() {
    final now = DateTime.now();

    // Kural 0: Yeni kullanıcı karşılama
    if (_prefsProvider.isFirstLaunch) {
      return SmartRecommendation(
        title: "Breathe Flow'a Hoş Geldin!",
        description: "Zihinsel sağlık yolculuğun burada başlıyor. 3 dakikalık bir rahatlama nefesiyle tanışmaya ne dersin?",
        ctaText: "Hadi Başlayalım",
        icon: "gift", // FeatherIcons.gift
        onCtaPressed: () {
          // TODO: Kullanıcıyı rahatlama nefesi egzersizine yönlendir
          Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          
          // İlk açılış kartı görevini tamamladı, bir daha gösterme
          _prefsProvider.setFirstLaunchCompleted();
        },
      );
    }

    // --- HATA AYIKLAMA İÇİN EKLENDİ ---
    print('--- RecommendationService Debug ---');
    print('Mevcut Zaman: $now');
    print('Son Uyku Süresi: ${_prefsProvider.lastSleepDurationHours} saat');
    print('Son Uyku Zaman Damgası: ${_prefsProvider.lastSleepSessionTimestamp}');
    // --- HATA AYIKLAMA BİTTİ ---

    // Kural 1: Dün gece az uyuduysa (6 saatten az)
    final lastSleepDuration = _prefsProvider.lastSleepDurationHours;
    if (lastSleepDuration != null && lastSleepDuration < 6.0) {
      // --- HATA AYIKLAMA İÇİN EKLENDİ ---
      print('DEBUG: Koşul 1.1 (Uyku Süresi < 6s) SAĞLANDI.');
      // --- HATA AYIKLAMA BİTTİ ---
      final lastSleepTime = _prefsProvider.lastSleepSessionTimestamp;
      if (lastSleepTime != null && now.difference(lastSleepTime).inHours < 18) {
        // --- HATA AYIKLAMA İÇİN EKLENDİ ---
        print('DEBUG: Koşul 1.2 (Son Uykudan Beri < 18s) SAĞLANDI. Öneri gösterilecek.');
        // --- HATA AYIKLAMA BİTTİ ---
        return SmartRecommendation(
          title: "Yorgun Bir Gece Miydi?",
          description: "Görünüşe göre dün gece pek dinlenemedin. Güne 5 dakikalık bir enerji nefesiyle başlayarak zindelik kazan.",
          ctaText: "Enerji Nefesi Yap",
          icon: "sun", // FeatherIcons.sun gibi bir şeye map'lenecek
          onCtaPressed: () {
            // TODO: Enerji nefesi egzersizini başlat
            Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          },
        );
      } else {
        // --- HATA AYIKLAMA İÇİN EKLENDİ ---
        print('DEBUG: Koşul 1.2 (Son Uykudan Beri < 18s) SAĞLANAMADI.');
        // --- HATA AYIKLAMA BİTTİ ---
      }
    } else {
      // --- HATA AYIKLAMA İÇİN EKLENDİ ---
      print('DEBUG: Koşul 1.1 (Uyku Süresi < 6s) SAĞLANAMADI.');
      // --- HATA AYIKLAMA BİTTİ ---
    }

    // Kural 2: Stres seviyesi yüksek ölçüldüyse
    final lastHrv = _prefsProvider.lastHrvScore;
    if (lastHrv != null && lastHrv > 70) { // 70'i stres eşiği varsayalım
      final lastHrvTime = _prefsProvider.lastHrvSessionTimestamp;
      if (lastHrvTime != null && now.difference(lastHrvTime).inHours < 12) {
        return SmartRecommendation(
          title: "Stres Seviyen Yüksek",
          description: "Vücudun biraz gergin görünüyor. 4-7-8 tekniği ile anında rahatlayarak dengeyi yeniden bul.",
          ctaText: "4-7-8 Nefesi Yap",
          icon: "heart", // FeatherIcons.heart
          onCtaPressed: () {
            // TODO: 4-7-8 egzersizini başlat
            Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const BreathingScreen()));
          },
        );
      }
    }

    // Kural 3: Akşam olduysa ve gün içinde hiç seans yapılmadıysa
    if (now.hour >= 20) {
       final lastSessionTime = _prefsProvider.lastSessionDate;
       bool sessionToday = lastSessionTime != null && now.difference(lastSessionTime).inDays == 0;
       if (!sessionToday) {
         return SmartRecommendation(
           title: "Günü Sakin Kapat",
           description: "Bugün kendine hiç zaman ayırmadın. Kısa bir uyku hikayesi ile zihnini dinlendir ve geceye huzurlu başla.",
           ctaText: "Uyku Hikayesi Dinle",
           icon: "moon", // FeatherIcons.moon
           onCtaPressed: () {
             Navigator.of(_context).push(MaterialPageRoute(builder: (ctx) => const SleepScreen()));
           },
         );
       }
    }
    
    // Hiçbir kural uymuyorsa öneri yok
    return null;
  }
} 