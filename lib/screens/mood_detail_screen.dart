import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../widgets/global_background.dart';
import '../ui/components/ad_container.dart';
import '../data/mood_presets.dart';
import '../models/breathing_exercise.dart';
import '../models/sound_item.dart';
import '../providers/breathing_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/exercise_tracking_provider.dart';
import '../providers/user_preferences_provider.dart';
import 'breathing_screen.dart';
import 'immersive_sound_player_screen.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';

/// 🎯 Mood Detay Ekranı — State Driven Experience
/// Hero başlat + süre seçimi + filtrelenmiş egzersizler + arka plan sesleri
class MoodDetailScreen extends StatefulWidget {
  final MoodPreset preset;
  final String title;
  final String imageAsset;

  const MoodDetailScreen({
    super.key,
    required this.preset,
    required this.title,
    required this.imageAsset,
  });

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen> {
  int _selectedMinutes = 3;
  String? _selectedSoundId;
  BreathingType? _selectedExerciseType;

  @override
  void initState() {
    super.initState();
    _selectedSoundId = widget.preset.defaultSoundId;
    _selectedExerciseType = widget.preset.defaultExercise;
  }

  /// Mood'a göre alt başlık döndürür
  String _getSubtitle() {
    switch (widget.preset.moodKey) {
      case 'gerginim':
        return AppStrings.moodDetailAnxietySubtitle;
      case 'overthinking':
        return AppStrings.moodDetailOverthinkingSubtitle;
      case 'uyuyamiyorum':
        return AppStrings.moodDetailSleepSubtitle;
      case 'tukendim':
        return AppStrings.moodDetailBurnoutSubtitle;
      default:
        return AppStrings.moodDetailAnxietySubtitle;
    }
  }

  /// Seçilen dakikayı döngü sayısına çevirir
  int _minutesToCycles(BreathingExercise exercise) {
    final totalSeconds = _selectedMinutes * 60;
    final cycleTime = exercise.totalCycleTime;
    if (cycleTime <= 0) return 3;
    return (totalSeconds / cycleTime).round().clamp(1, 1000);
  }

  /// Belirli bir sesi başlatır
  void _playSoundById(String soundId) {
    try {
      final audioProvider = context.read<AudioProvider>();
      final sound = SoundItem.allSounds.firstWhere(
        (s) => s.id == soundId,
        orElse: () => SoundItem.allSounds.first,
      );
      audioProvider.playExclusive(sound);
    } catch (_) {}
  }

  /// Belirli bir egzersiz + opsiyonel ses ile BreathingScreen'e git
  void _navigateToBreathing(BreathingExercise exercise, {String? soundId}) {
    final cycles = _minutesToCycles(exercise);
    final breathingProvider = context.read<BreathingProvider>();
    final exerciseTrackingProvider = context.read<ExerciseTrackingProvider>();

    exerciseTrackingProvider.onExerciseStarted();
    breathingProvider.setExercise(exercise, customCycles: cycles);

    if (soundId != null) {
      _playSoundById(soundId);
    }

    final navContext = context;
    Navigator.of(navContext).push(
      MaterialPageRoute(
        builder: (context) => BreathingScreen(moodPreset: widget.preset),
      ),
    ).then((_) {
      try {
        final audioProvider = Provider.of<AudioProvider>(navContext, listen: false);
        audioProvider.stopAllSounds();
      } catch (_) {}
      breathingProvider.stop();
    });
  }

  /// 🎯 Hero "Hemen Başla" — Mood'a ait rastgele egzersiz + ses başlatır
  void _startQuickSession() {
    final allTypes = widget.preset.allExercises;
    
    // 🧠 SMART SELECTION: Öncelikle ÜCRETSİZ egzersizleri bul
    final freeExercises = allTypes.where((type) {
      final exercise = BreathingExercise.allExercises.firstWhere(
        (e) => e.type == type,
        orElse: () => BreathingExercise.allExercises.first,
      );
      return !exercise.isPremium;
    }).toList();

    // Eğer ücretsiz seçenek varsa onlardan seç, yoksa (çok nadir) mecburen hepsinden seç
    final targetTypes = freeExercises.isNotEmpty ? freeExercises : allTypes.toList();
    
    final randomType = (targetTypes..shuffle()).first;
    final exercise = BreathingExercise.allExercises.firstWhere(
      (e) => e.type == randomType,
      orElse: () => BreathingExercise.allExercises.first,
    );
    
    // 🔒 Eğer seçilen (mecburen) premium ise kontrol et
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

    final soundId = widget.preset.getSoundForExercise(randomType);
    _navigateToBreathing(exercise, soundId: soundId);
  }

  /// 🎨 Kullanıcının seçtiği egzersiz/ses ile başlat
  void _startCustomSession() {
    final hasExercise = _selectedExerciseType != null;
    final hasSound = _selectedSoundId != null;

    if (!hasExercise && !hasSound) return;

    final premiumProvider = context.read<PremiumProvider>();

    // 🔒 SES KONTROLÜ (Sadece ses modunda veya egzersiz+ses modunda)
    if (hasSound) {
      final sound = SoundItem.findById(_selectedSoundId!);
      if (sound != null && sound.isPremium) {
        if (!premiumProvider.canAccessPremiumContent(true)) {
          final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
            (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumSounds),
            orElse: () => PremiumTrigger.predefinedTriggers.first,
          );
          SmartPremiumDialog.show(context, trigger);
          return;
        }
      }
    }
    
    // 🔒 EGZERSİZ KONTROLÜ
    if (hasExercise) {
       final exercise = BreathingExercise.allExercises.firstWhere(
        (e) => e.type == _selectedExerciseType,
        orElse: () => BreathingExercise.allExercises.first,
      );
      
      if (exercise.isPremium) {
        if (!premiumProvider.canAccessPremiumContent(true)) {
          final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
            (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
            orElse: () => PremiumTrigger.predefinedTriggers.first,
          );
          SmartPremiumDialog.show(context, trigger);
          return;
        }
      }
    }

    // Sadece ses → ses player ekranına git
    if (!hasExercise && hasSound) {
      final sound = SoundItem.allSounds.firstWhere(
        (s) => s.id == _selectedSoundId,
        orElse: () => SoundItem.allSounds.first,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImmersiveSoundPlayerScreen(sound: sound),
        ),
      );
      return;
    }

    // Egzersiz (+ opsiyonel ses)
    final exercise = BreathingExercise.allExercises.firstWhere(
      (e) => e.type == _selectedExerciseType,
      orElse: () => BreathingExercise.allExercises.first,
    );
    _navigateToBreathing(exercise, soundId: hasSound ? _selectedSoundId : null);
  }

  /// Kullanıcının bir şey seçip seçmediğini kontrol eder
  bool get _hasCustomSelection =>
      _selectedExerciseType != null || _selectedSoundId != null;

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.preset.gradientColors.isNotEmpty
        ? widget.preset.gradientColors
        : [const Color(0xFF2D1F0E), const Color(0xFF4A3520), const Color(0xFF6B5030)];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: Stack(
          children: [
            // Mood'a özel gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientColors.first.withOpacity(0.6),
                    gradientColors[1 % gradientColors.length].withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // 🎯 Hero Section
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: _buildHeroSection(),
                          ),

                          const SizedBox(height: 24),

                          // ⏱ Süre Seçimi
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: const Duration(milliseconds: 100),
                            child: _buildTimeSelector(),
                          ),

                          const SizedBox(height: 24),

                          // 🧘 Diğer Egzersizler
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: const Duration(milliseconds: 200),
                            child: _buildExercisesSection(),
                          ),

                          const SizedBox(height: 24),

                          // 🎵 Arka Plan Sesi
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: const Duration(milliseconds: 300),
                            child: _buildSoundsSection(),
                          ),

                          // 🎯 Banner Reklam
                          const Padding(
                            padding: EdgeInsets.only(top: 24, bottom: 24),
                            child: AdContainer(placement: 'mood_detail_bottom'),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // 🎨 Sticky "Seçimimi Başlat" butonu — kullanıcı seçim yaptığında görünür
                  if (_hasCustomSelection)
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCustomStartButton(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Kullanıcının seçimini başlatan sticky buton
  Widget _buildCustomStartButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _startCustomSession,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4A050).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FeatherIcons.play, color: Color(0xFFD4A050), size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _getSelectionSummary().isNotEmpty
                          ? _getSelectionSummary().replaceFirst('${AppStrings.moodDetailRecommended}: ', '')
                          : '',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(FeatherIcons.arrowRight, color: Colors.white.withOpacity(0.7), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App Bar — geri butonu + başlık
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Seçili egzersiz ve ses bilgisini açıklama metni olarak döndürür
  String _getSelectionSummary() {
    final exerciseName = _selectedExerciseType != null
        ? BreathingExercise.allExercises
            .firstWhere((e) => e.type == _selectedExerciseType,
                orElse: () => BreathingExercise.allExercises.first)
            .name
        : null;
    final soundName = _selectedSoundId != null
        ? SoundItem.findById(_selectedSoundId!)?.name
        : null;

    if (exerciseName != null && soundName != null) {
      return '${AppStrings.moodDetailRecommended}: $exerciseName + $soundName';
    } else if (exerciseName != null) {
      return '${AppStrings.moodDetailRecommended}: $exerciseName';
    } else if (soundName != null) {
      return '${AppStrings.moodDetailRecommended}: $soundName';
    }
    return '';
  }

  /// 🎯 Hero Section — Glassmorphism kart + Hemen Başla butonu
  Widget _buildHeroSection() {

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood ikonu + başlık
              Row(
                children: [
                  Icon(
                    widget.preset.icon,
                    color: const Color(0xFFD4A050),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Alt başlık
              Text(
                _getSubtitle(),
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // Hemen Başla butonu — rastgele egzersiz + ses
              GestureDetector(
                onTap: _startQuickSession,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A050),
                        const Color(0xFFC08840),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A050).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(FeatherIcons.play, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.moodDetailStartNow,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getSubtitle(),
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(FeatherIcons.arrowRight, color: Colors.white.withOpacity(0.8), size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _lockedDurationInfo; // Kilitli süreye tıklandığında bilgi göstermek için

  int _getRemainingSessionsToUnlock(int durationMinutes, int totalSessions) {
    switch (durationMinutes) {
      case 5: return (3 - totalSessions).clamp(0, 3);
      case 10: return (10 - totalSessions).clamp(0, 10);
      default: return 0;
    }
  }

  /// ⏱ Süre Seçimi — "Ne kadar vaktin var?"
  Widget _buildTimeSelector() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, _) {
        final totalSessions = userPrefs.totalSessions;
        // Yeni süre seçenekleri: [1, 2, 3, 4, 5, 10]
        final List<int> displayOptions = [1, 2, 3, 4, 5, 10];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.moodDetailHowMuchTime,
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: displayOptions.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  
                  // Kilit mantığı
                  bool isLocked = false;
                  if (minutes == 5 && totalSessions < 3) isLocked = true;
                  if (minutes == 10 && totalSessions < 10) isLocked = true;

                  // Bu süreye ait bilgi mesajı açık mı?
                  final isInfoVisible = _lockedDurationInfo == minutes;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (isLocked) {
                          // Kilitli ise bilgi mesajını toggle et
                          setState(() {
                            _lockedDurationInfo = isInfoVisible ? null : minutes;
                          });
                        } else {
                          // Açık ise seç ve bilgi mesajını kapat
                          setState(() {
                            _selectedMinutes = minutes;
                            _lockedDurationInfo = null;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4A050).withOpacity(0.25)
                              : isInfoVisible 
                                  ? const Color(0xFFD4A050).withOpacity(0.15) // Bilgi mesajı açıkken hafif highlight
                                  : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4A050).withOpacity(0.6)
                                : isInfoVisible
                                    ? const Color(0xFFD4A050).withOpacity(0.3)
                                    : Colors.white.withOpacity(isLocked ? 0.05 : 0.1),
                            width: isSelected || isInfoVisible ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLocked) ...[
                              Icon(
                                FeatherIcons.lock, 
                                size: 14, 
                                color: isInfoVisible ? const Color(0xFFD4A050) : Colors.white.withOpacity(0.4)
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '$minutes ${AppStrings.moodDetailMinute}',
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFD4A050)
                                    : isInfoVisible
                                        ? const Color(0xFFD4A050).withOpacity(0.9)
                                        : Colors.white.withOpacity(isLocked ? 0.4 : 0.7),
                                fontWeight: (isSelected || isInfoVisible) ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Kilitli süre bilgi mesajı — sürelerin hemen altında
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _lockedDurationInfo != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A050).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4A050).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            FeatherIcons.info,
                            color: Color(0xFFD4A050),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.lockedReason(
                                _getRemainingSessionsToUnlock(_lockedDurationInfo!, totalSessions),
                                _lockedDurationInfo!,
                              ),
                              style: const TextStyle(
                                color: Colors.white, // Daha net okunması için beyaz
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  /// 🧘 Diğer Egzersizler — Mood'a uygun filtrelenmiş egzersizler
  Widget _buildExercisesSection() {
    final exerciseTypes = widget.preset.allExercises;
    final exercises = exerciseTypes
        .map((type) => BreathingExercise.allExercises.firstWhere(
              (e) => e.type == type,
              orElse: () => BreathingExercise.allExercises.first,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.moodDetailOtherExercises,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isSelected = _selectedExerciseType == exercise.type;
              return _buildExerciseCard(exercise, isSelected);
            },
          ),
        ),
      ],
    );
  }

  /// Egzersiz kartı — kare, görsel arka plan
  Widget _buildExerciseCard(BreathingExercise exercise, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle: tekrar tıklarsa deselect et
          if (_selectedExerciseType == exercise.type) {
            _selectedExerciseType = null;
          } else {
            _selectedExerciseType = exercise.type;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4A050).withOpacity(0.7)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFD4A050).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan görseli
              Image.asset(
                exercise.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.2, 0.5, 1.0],
                  ),
                ),
              ),

              // PRO Badge
              if (exercise.isPremium)
                Consumer<PremiumProvider>(
                  builder: (context, premium, _) {
                    if (premium.isPremiumUser) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
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
                            const SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 9, 
                                fontWeight: FontWeight.w800
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Seçili göstergesi
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A050),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),

              // Egzersiz adı
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  exercise.name,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎵 Arka Plan Sesi — Mood'a uygun sesler
  Widget _buildSoundsSection() {
    // Önerilen ses ID'lerinden sesleri al
    final recommendedSounds = widget.preset.recommendedSoundIds
        .map((id) => SoundItem.findById(id))
        .where((s) => s != null)
        .cast<SoundItem>()
        .toList();

    // Eğer önerilen sesler yoksa, tag'lere göre filtrele
    final sounds = recommendedSounds.isNotEmpty
        ? recommendedSounds
        : SoundItem.getSoundsByTags(widget.preset.soundTags).take(4).toList();

    if (sounds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.moodDetailBackgroundSound,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sounds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sound = sounds[index];
              final isSelected = _selectedSoundId == sound.id;
              return _buildSoundCard(sound, isSelected);
            },
          ),
        ),
      ],
    );
  }

  /// Ses kartı — kare, cover görseli
  Widget _buildSoundCard(SoundItem sound, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSoundId = isSelected ? null : sound.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4A050).withOpacity(0.7)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFD4A050).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover görseli
              Image.asset(
                sound.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: sound.color.withOpacity(0.3),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // PRO Badge
              if (sound.isPremium)
                Consumer<PremiumProvider>(
                  builder: (context, premium, _) {
                    if (premium.isPremiumUser) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
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
                            const SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 9, 
                                fontWeight: FontWeight.w800
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Seçili göstergesi
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A050),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),

              // Ses adı
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  sound.name,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
