import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:breathe_flow/screens/breathing_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/breathing_exercise.dart';
import '../models/sound_item.dart';
import '../providers/breathing_provider.dart';
import '../constants/app_strings.dart';
import '../providers/exercise_tracking_provider.dart';
import '../services/asset_manager.dart';
import '../data/mood_presets.dart';
import '../providers/audio_provider.dart';
import 'mood_detail_screen.dart';
import 'immersive_sound_player_screen.dart';
import 'sleep_hub_screen.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';

/// 🏠 Professional Home Screen
/// Warm Night Comfort teması — sıcak, samimi, kişisel
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🌙 Son uyku günlüğü mood'u
  String? _lastSleepMood;

  @override
  void initState() {
    super.initState();
    _loadLastSleepMood();
  }

  /// SharedPreferences'tan dünün uyku günlüğü mood'unu yükle
  Future<void> _loadLastSleepMood() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('sleep_journal_entries');
      if (entriesJson != null) {
        final List<dynamic> entries = jsonDecode(entriesJson);
        if (entries.isNotEmpty) {
          // En son kaydı al
          final lastEntry = entries.last as Map<String, dynamic>;
          final entryDate = DateTime.parse(lastEntry['date'] as String);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
          
          // Sadece dünkü veya bugünkü kayıt gösterilsin (eski kayıtlar gösterilmesin)
          final difference = today.difference(entryDay).inDays;
          if (difference <= 1 && mounted) {
            setState(() {
              _lastSleepMood = lastEntry['mood'] as String?;
            });
          }
        }
      }
    } catch (_) {}
  }

  /// Mood'a göre kişiselleştirilmiş mesaj
  String _getSleepMoodMessage() {
    switch (_lastSleepMood) {
      case 'great':
        return AppStrings.homeSleepMoodGreat;
      case 'good':
        return AppStrings.homeSleepMoodGood;
      case 'neutral':
        return AppStrings.homeSleepMoodNeutral;
      case 'tired':
        return AppStrings.homeSleepMoodTired;
      case 'bad':
        return AppStrings.homeSleepMoodBad;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    String subGreeting;
    if (hour >= 5 && hour < 12) {
      greeting = AppStrings.morningGreeting;
      subGreeting = AppStrings.morningSubGreeting;
    } else if (hour >= 12 && hour < 17) {
      greeting = AppStrings.afternoonGreeting;
      subGreeting = AppStrings.afternoonSubGreeting;
    } else if (hour >= 17 && hour < 22) {
      greeting = AppStrings.eveningGreeting;
      subGreeting = AppStrings.eveningSubGreeting;
    } else {
      greeting = AppStrings.nightGreeting;
      subGreeting = AppStrings.nightSubGreeting;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🌅 GREETING BANNER — arka plan görselli
          SliverToBoxAdapter(
            child: _buildGreetingBanner(context, hour, greeting, subGreeting),
          ),

          // 🌙 UYKU MOOD KİŞİSELLEŞTİRME KARTI
          if (_lastSleepMood != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(top: 12),
                child: _buildSleepMoodCard(),
              ),
            ),

          // ▶ HERO CARD — Hızlı Başla
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(top: AppSpacing.large),
              child: _buildHeroCard(context, hour),
            ),
          ),

          // 🎧 HEMEN RAHATLA
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(top: 14),
              child: _buildInstantRelaxBanner(context, hour),
            ),
          ),

          // 🎭 NASIL HİSSEDİYORSUN — Dikey büyük kartlar
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(top: AppSpacing.large),
              child: _buildMoodSection(context),
            ),
          ),



          // Alt boşluk
          SliverToBoxAdapter(
            child: SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 🌅 GREETING BANNER — Arka plan görselli, organik geçiş
  // =========================================================
  Widget _buildGreetingBanner(BuildContext context, int hour, String greeting, String subGreeting) {
    final topPadding = MediaQuery.of(context).padding.top;
    final greetingImage = _getGreetingImage(hour);

    return Container(
      width: double.infinity,
      height: 160 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan görseli
          Image.asset(
            greetingImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _getGreetingGradient(hour),
                ),
              ),
            ),
          ),

          // Gradient overlay — gece için daha koyu
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: hour < 5 || hour >= 22
                    ? [
                        // Gece: daha koyu overlay
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.8),
                        const Color(0xFF1A1510).withOpacity(0.98),
                      ]
                    : [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.7),
                        const Color(0xFF1A1510).withOpacity(0.95),
                      ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // İçerik — sadece greeting, BreathFlow yazısı kaldırıldı
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Greeting — büyük font
                Text(
                  greeting,
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    color: Colors.white,
                    height: 1.05,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Sub greeting — büyük font
                Text(
                  subGreeting,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 🌙 UYKU MOOD KİŞİSELLEŞTİRME KARTI
  // =========================================================
  Widget _buildSleepMoodCard() {
    final message = _getSleepMoodMessage();
    if (message.isEmpty) return const SizedBox.shrink();

    final emoji = _getSleepMoodEmoji();
    final color = _getSleepMoodColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSleepMoodEmoji() {
    switch (_lastSleepMood) {
      case 'great': return '😊';
      case 'good': return '🙂';
      case 'neutral': return '😐';
      case 'tired': return '😴';
      case 'bad': return '😔';
      default: return '🌙';
    }
  }

  Color _getSleepMoodColor() {
    switch (_lastSleepMood) {
      case 'great': return AppColors.success;
      case 'good': return AppColors.primary;
      case 'neutral': return AppColors.focus;
      case 'tired': return AppColors.warning;
      case 'bad': return AppColors.error;
      default: return const Color(0xFFD4AF37);
    }
  }

  // =========================================================
  // ▶ HERO CARD — Hızlı Başla (nefes + ses kombinasyonu)
  // =========================================================
  Widget _buildHeroCard(BuildContext context, int hour) {
    String subtitle;
    String moodKey;
    String imageAsset;
    List<Color> gradientColors;

    if (hour >= 5 && hour < 12) {
      subtitle = AppStrings.homeQuickStartMorning;
      moodKey = 'tukendim';
      imageAsset = AssetManager.homeRelaxMorning;
      gradientColors = [const Color(0xFF2D1F0E), const Color(0xFF4A3520), const Color(0xFF6B5030)];
    } else if (hour >= 12 && hour < 17) {
      subtitle = AppStrings.homeQuickStartAfternoon;
      moodKey = 'overthinking';
      imageAsset = AssetManager.homeRelaxAfternoon;
      gradientColors = [const Color(0xFF1A3040), const Color(0xFF2A4A5A), const Color(0xFF3D6070)];
    } else if (hour >= 17 && hour < 22) {
      subtitle = AppStrings.homeQuickStartEvening;
      moodKey = 'gerginim';
      imageAsset = AssetManager.homeRelaxEvening;
      gradientColors = [const Color(0xFF3D2415), const Color(0xFF5A3520), const Color(0xFF8B5E3C)];
    } else {
      subtitle = AppStrings.homeQuickStartNight;
      moodKey = 'uyuyamiyorum';
      imageAsset = AssetManager.homeRelaxNight;
      gradientColors = [const Color(0xFF1A1040), const Color(0xFF2D1B69), const Color(0xFF4A2C8A)];
    }

    return GestureDetector(
      onTap: () {
          _startQuickMoodExercise(context, moodKey);
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan görseli
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      gradientColors.first.withOpacity(0.95),
                      gradientColors[1].withOpacity(0.7),
                      gradientColors.last.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // Üst parlaklık çizgisi
              Positioned(
                top: 0, left: 0, right: 0, height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // PRO badge (sağ üst) - Eğer seçilen exercise premium ise
              FutureBuilder<BreathingExercise>(
                // Her build'de yeniden hesaplanmaması için normalde state'te tutulmalı ama 
                // şimdilik hızlı çözüm olarak burada hesaplıyoruz.
                // Not: _buildHeroCard içinde exercise yok, moodKey var.
                // Aşağıdaki logic ile eşleşen exercise'ı buluyoruz.
                future: Future.value(() {
                   final preset = MoodPresets.getPreset(moodKey);
                   final allTypes = preset.allExercises;
                   final freeExercises = allTypes.where((type) {
                      final ex = BreathingExercise.allExercises.firstWhere((e) => e.type == type);
                      return !ex.isPremium;
                   }).toList();
                   final targetType = freeExercises.isNotEmpty ? freeExercises.first : preset.defaultExercise;
                   return BreathingExercise.allExercises.firstWhere((e) => e.type == targetType);
                }()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final exercise = snapshot.data!;
                  
                  if (!exercise.isPremium) return const SizedBox.shrink();
                  
                  return Consumer<PremiumProvider>(
                    builder: (context, premium, _) {
                      if (premium.isPremiumUser) return const SizedBox.shrink();
                      return Positioned(
                        top: 16,
                        left: 24, // Başlığın üstüne denk gelmesin diye
                         // Tasarım kararı: Sol üstte, 'Hemen Başla'nın biraz üstünde dursun
                         // Veya sağ tarafta play butonunun olduğu sütunda.
                         // Hero card tasarımı: Sol taraf metin, sağ taraf ikon.
                         // Sağ üst köşe uygundur.
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                               BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  );
                },
              ),

              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Başlık
                          Text(
                            AppStrings.homeQuickStartTitle,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Alt başlık
                          Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sağ: Nefes+Ses etiketi + Play butonu
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Play butonu — altın gradient
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            FeatherIcons.play,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Nefes+Ses etiketi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FeatherIcons.wind, color: Colors.white.withOpacity(0.8), size: 10),
                              const SizedBox(width: 3),
                              Text(
                                '+',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                              ),
                              const SizedBox(width: 3),
                              Icon(FeatherIcons.headphones, color: Colors.white.withOpacity(0.8), size: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Alt altın parlaklık çizgisi
              Positioned(
                bottom: 0, left: 0, right: 0, height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4A050).withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🎧 HEMEN RAHATLA — Ses görseli + açıklama kartı
  // =========================================================
  Widget _buildInstantRelaxBanner(BuildContext context, int hour) {
    // Saat bazında bir ses seç
    String soundId;
    if (hour >= 5 && hour < 12) {
      soundId = 'river';
    } else if (hour >= 12 && hour < 17) {
      soundId = 'light_rain';
    } else if (hour >= 17 && hour < 22) {
      soundId = 'campfire';
    } else {
      soundId = 'night_crickets';
    }

    // Sesi bul
    final sound = SoundItem.findById(soundId);
    if (sound == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // 🔒 PREMIUM KONTROLÜ
        if (sound.isPremium) {
           final premiumProvider = context.read<PremiumProvider>();
           if (!premiumProvider.canAccessPremiumContent(true)) {
               final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
                (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumSounds),
                orElse: () => PremiumTrigger.predefinedTriggers.first,
              );
              SmartPremiumDialog.show(context, trigger);
              return;
           }
        }
        
        // Direkt ImmersiveSoundPlayerScreen aç — ses hemen başlar
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImmersiveSoundPlayerScreen(sound: sound),
          ),
        );
      },
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: sound.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Sesin görseli — kart boyutuna crop
              Image.asset(
                sound.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: sound.color.withOpacity(0.3),
                ),
              ),

              // Gradient overlay — metin okunabilirliği
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // Üst parlaklık
              Positioned(
                top: 0, left: 0, right: 0, height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.instantRelaxTitle,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Sesin açıklaması
                          Text(
                            sound.description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Play butonu
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8A838).withOpacity(0.25),
                        border: Border.all(
                          color: const Color(0xFFE8A838).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8A838).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        FeatherIcons.play,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Alt altın parlaklık
              Positioned(
                bottom: 0, left: 0, right: 0, height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4A050).withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🎭 MOOD SECTION — Dikey büyük kartlar, arka plan görselli
  // =========================================================
  Widget _buildMoodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          AppStrings.homeMoodSectionTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Alt başlık
        Text(
          AppStrings.homeMoodSectionSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // 4 büyük dikey kart
        // 4 büyük dikey kart
        _buildMoodBannerCard(
          context,
          icon: FeatherIcons.heart,
          label: AppStrings.moodAnxiousLabel,
          subtitle: AppStrings.homeMoodAnxiousShort,
          moodKey: 'gerginim',
          backgroundImage: AssetManager.moodAnxiousBg,
          gradientStart: const Color(0xFFE8A838),
          gradientEnd: const Color(0xFFD4783C),
        ),
        const SizedBox(height: 12),
        _buildMoodBannerCard(
          context,
          icon: FeatherIcons.sunrise,
          label: AppStrings.moodOverthinkingLabel,
          subtitle: AppStrings.homeMoodOverthinkingShort,
          moodKey: 'overthinking',
          backgroundImage: AssetManager.moodOverthinkingBg,
          gradientStart: const Color(0xFF9B8EC4),
          gradientEnd: const Color(0xFF6B5FA0),
        ),
        const SizedBox(height: 12),
        _buildMoodBannerCard(
          context,
          icon: FeatherIcons.feather,
          label: AppStrings.moodSleeplessLabel,
          subtitle: AppStrings.homeMoodSleeplessShort,
          moodKey: 'uyuyamiyorum',
          backgroundImage: AssetManager.moodSleeplessBg,
          gradientStart: const Color(0xFF667EEA),
          gradientEnd: const Color(0xFF4A5CB8),
        ),
        const SizedBox(height: 12),
        _buildMoodBannerCard(
          context,
          icon: FeatherIcons.coffee,
          label: AppStrings.moodBurnoutLabel,
          subtitle: AppStrings.homeMoodBurnoutShort,
          moodKey: 'tukendim',
          backgroundImage: AssetManager.moodBurnoutBg,
          gradientStart: const Color(0xFF4ECDC4),
          gradientEnd: const Color(0xFF3AA89E),
        ),
      ],
    );
  }

  /// 🎭 Mood Banner Kartı — tam genişlik, arka plan görselli
  Widget _buildMoodBannerCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required String moodKey,
    required String backgroundImage,
    required Color gradientStart,
    required Color gradientEnd,
  }) {
    return GestureDetector(
      onTap: () => _startQuickMoodExercise(context, moodKey),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
              // 1. Arka plan görseli
              Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2D1F0E), // Fallback color
                ),
              ),

              // 2. Koyu Gradient Overlay (Metin okunabilirliği için)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.92), // Çok daha koyu
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3), // Sağ tarafı da biraz karart
                    ],
                    stops: const [0.0, 0.6, 1.0], // Gradyan geçişini yay

                  ),
                ),
              ),
              
              // 3. İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // İkon container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white, // İkon her zaman beyaz
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Metin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ok ikonu
                    Icon(
                      FeatherIcons.chevronRight,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🚀 Navigation & Session Methods
  // =========================================================

  /// Mood kartına tıklayınca → MoodDetailScreen'e git (Eski, artık kullanılmıyor olabilir)
  void _navigateToMoodDetail(BuildContext context, String moodKey, String title, String imageAsset) {
    final preset = MoodPresets.getPreset(moodKey);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoodDetailScreen(
          preset: preset,
          title: title,
          imageAsset: imageAsset,
        ),
      ),
    );
  }

  /// 🎯 Mood Session Hızlı Başlat — 1 Dakikalık otomatik seçim
  void _startQuickMoodExercise(BuildContext context, String moodKey) {
    final preset = MoodPresets.getPreset(moodKey);
    
    // 🧠 SMART SELECTION: O mood'daki ÜCRETSİZ bir egzersizi bul
    final allTypes = preset.allExercises;
    final freeExercises = allTypes.where((type) {
        final ex = BreathingExercise.allExercises.firstWhere((e) => e.type == type);
        return !ex.isPremium;
    }).toList();

    // Ücretsiz varsa onlardan birini, yoksa default'u al
    final targetType = freeExercises.isNotEmpty 
        ? freeExercises.first 
        : preset.defaultExercise;

    final exercise = BreathingExercise.allExercises.firstWhere(
      (e) => e.type == targetType,
      orElse: () => BreathingExercise.allExercises.first,
    );
    
    // 🔒 Güvenlik Kontrolü (Smart Selection bulamazsa)
    if (exercise.isPremium) {
       final premiumProvider = context.read<PremiumProvider>();
       if (!premiumProvider.canAccessPremiumContent(true)) {
           final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
            (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
            orElse: () => PremiumTrigger.predefinedTriggers.first,
          );
          SmartPremiumDialog.show(context, trigger);
          return;
       }
    }

    // 1 dakika ≈ 60 saniye / egzersizin bir döngü süresi
    final cyclesFor1Min = (60 / exercise.totalCycleTime).ceil().clamp(1, 10);
    
    final breathingProvider = Provider.of<BreathingProvider>(context, listen: false);
    final exerciseTrackingProvider = Provider.of<ExerciseTrackingProvider>(context, listen: false);
    exerciseTrackingProvider.onExerciseStarted();
    breathingProvider.setExercise(exercise, customCycles: cyclesFor1Min);
    
    // Arka plan sesini başlat
    _startMoodSound(context, preset.getSoundForExercise(exercise.type));
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BreathingScreen(moodPreset: preset),
      ),
    );
  }

  /// 🎯 Mood Session Başlat — Direkt nefes egzersizi + ses
  void _startMoodSession(BuildContext context, String moodKey) {
    final preset = MoodPresets.getPreset(moodKey);
    
    // Default egzersizi bul
    final exercise = BreathingExercise.allExercises.firstWhere(
      (e) => e.type == preset.defaultExercise,
      orElse: () => BreathingExercise.allExercises.first,
    );

    // Döngü seçim modalını göster
    _showMoodSessionModal(context, exercise, preset);
  }

  /// 🎯 Mood Session Modal — Döngü seç + başlat
  void _showMoodSessionModal(BuildContext context, BreathingExercise exercise, MoodPreset preset) {
    final List<int> cycleOptions = [5, 10, 15, 20, 25, 30];
    int selectedCycles = 10;
    final breathingProvider = Provider.of<BreathingProvider>(context, listen: false);

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
                                AppStrings.howManyCycles,
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
                                    AppStrings.cycles,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 9 : 10,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.cycles,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 9 : 10,
                                    ),
                                  ),
                                  // Removed minute label
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
                          // Egzersiz tracking
                          final exerciseTrackingProvider = Provider.of<ExerciseTrackingProvider>(context, listen: false);
                          exerciseTrackingProvider.onExerciseStarted();
                          
                          // Egzersizi set et ve başlat
                          breathingProvider.setExercise(exercise, customCycles: selectedCycles);
                          breathingProvider.start();
                          
                          // Arka planda ses başlat
                          _startMoodSound(context, preset.getSoundForExercise(exercise.type));
                          
                          Navigator.of(context).pop(); // Modal'ı kapat
                          
                          // BreathingScreen'e git (mood preset bilgisiyle)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BreathingScreen(moodPreset: preset),
                            ),
                          ).then((_) {
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
                                '${AppStrings.start} ($selectedCycles ${AppStrings.cyclesLabel})',
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

  /// 🎵 Mood sesi başlat
  void _startMoodSound(BuildContext context, String soundId) {
    try {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      final sound = SoundItem.allSounds.firstWhere(
        (s) => s.id == soundId,
        orElse: () => SoundItem.allSounds.first,
      );
      audioProvider.playExclusive(sound);
    } catch (e) {
      // Ses başlatılamazsa sessizce geç
    }
  }


  // =========================================================
  // 🌙 UYKU TAKİBİ CTA
  // =========================================================
  Widget _buildSleepTrackingCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SleepHubScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1535).withOpacity(0.6), // Gece mavisi/mor tonu
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // İkon Kutusu
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FeatherIcons.moon,
                color: Color(0xFF667EEA),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Metinler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Uyku Takibi & Analizi", // TODO: Localize AppStrings.sleepHubTitle
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Uykunu takip et, rüyalarını kaydet", // TODO: Localize
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Ok
            Icon(
              FeatherIcons.chevronRight,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


  // =========================================================
  // 🎨 Yardımcı Metodlar
  // =========================================================

  /// Saat bazlı greeting görseli
  String _getGreetingImage(int hour) {
    if (hour >= 5 && hour < 12) return AssetManager.homeSuggestionMorning;
    if (hour >= 12 && hour < 17) return AssetManager.homeSuggestionAfternoon;
    if (hour >= 17 && hour < 22) return AssetManager.homeSuggestionEvening;
    return AssetManager.homeSuggestionNight;
  }

  /// Saat bazlı greeting gradient renkleri
  List<Color> _getGreetingGradient(int hour) {
    if (hour >= 5 && hour < 12) {
      return [const Color(0xFF3D3020), const Color(0xFF2A1F15), const Color(0xFF1A1510)];
    } else if (hour >= 12 && hour < 17) {
      return [const Color(0xFF2D3A25), const Color(0xFF1F2A1A), const Color(0xFF151E12)];
    } else if (hour >= 17 && hour < 22) {
      return [const Color(0xFF3D2415), const Color(0xFF2A1A0E), const Color(0xFF1A1008)];
    } else {
      return [const Color(0xFF1A1535), const Color(0xFF120E25), const Color(0xFF0A0818)];
    }
  }

  /// Saat bazlı accent renk
  Color _getGreetingAccent(int hour) {
    if (hour >= 5 && hour < 12) return const Color(0xFFE8A838);
    if (hour >= 12 && hour < 17) return const Color(0xFF4ECDC4);
    if (hour >= 17 && hour < 22) return const Color(0xFFE8A838);
    return const Color(0xFF9B8EC4);
  }
}