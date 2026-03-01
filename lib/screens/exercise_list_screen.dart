import 'dart:ui';

import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:breathe_flow/widgets/smart_premium_dialog.dart';
import 'package:breathe_flow/models/premium_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/professional_app_bar.dart';
import '../widgets/global_background.dart';
import 'breathing_screen.dart';
import '../ui/components/ad_container.dart';

class ExerciseListScreen extends StatefulWidget {
  final BreathingCategory? category;
  final String heroTag;

  const ExerciseListScreen({
    super.key,
    this.category,
    required this.heroTag,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late final ScrollController _scrollController;
  final ValueNotifier<double> _opacity = ValueNotifier(0.0); // ⚡ Optimized - no setState

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _opacity.dispose(); // ⚡ Dispose ValueNotifier
    super.dispose();
  }

  void _onScroll() {
    const scrollThreshold = 100.0;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0;
    final newOpacity = (offset / scrollThreshold).clamp(0.0, 1.0);

    if (newOpacity != _opacity.value) {
      _opacity.value = newOpacity; // ⚡ No setState - huge performance boost
    }
  }

  String _getCategoryTitle(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppStrings.focusAndConcentrationTitle;
      case BreathingCategory.kaygiVeStres:
        return AppStrings.relaxationAndPeaceTitle;
      case BreathingCategory.uykuVeRahatlama:
        return AppStrings.peacefulSleepTitle;
      case BreathingCategory.enerjiVeCanlilik:
        return AppStrings.energyAndVitalityTitle;
    }
  }

  Color _getCategoryColor(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppColors.focus;
      case BreathingCategory.kaygiVeStres:
        return AppColors.relaxation;
      case BreathingCategory.uykuVeRahatlama:
        return AppColors.sleep;
      case BreathingCategory.enerjiVeCanlilik:
        return AppColors.energy;
    }
  }

  String _getCategoryDescription(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppStrings.focusConcentrationDesc;
      case BreathingCategory.kaygiVeStres:
        return AppStrings.relaxationPeaceDesc;
      case BreathingCategory.uykuVeRahatlama:
        return AppStrings.peacefulSleepDesc;
      case BreathingCategory.enerjiVeCanlilik:
        return AppStrings.energyVitalityDesc;
    }
  }

  String _getExerciseShortDescription(BreathingExercise exercise) {
    // Egzersiz description'ı zaten lokalize - direkt kullan
    return exercise.description;
  }

  IconData _getExerciseIcon(BreathingExercise exercise) {
    // Type'a göre ikon belirle (dil bağımsız)
    switch (exercise.type) {
      case BreathingType.boxBreathing:
        return FeatherIcons.square;
      case BreathingType.custom: // Basit Sayma Nefesi
        return FeatherIcons.hash;
      case BreathingType.deepBreathing: // Farkındalık Nefesi
        return FeatherIcons.eye;
      case BreathingType.extendedExhale:
        return FeatherIcons.wind;
      case BreathingType.diaphragmaticBreathing:
        return FeatherIcons.circle;
      case BreathingType.samaVritti: // Eşit Nefes
        return FeatherIcons.minimize2;
      case BreathingType.moonBreathing: // Yavaşlatıcı Nefes
        return FeatherIcons.moon;
      case BreathingType.bodyScan: // Beden Farkındalığı
        return FeatherIcons.search;
      case BreathingType.progressiveRelaxation: // Gevşeme Nefesi
        return FeatherIcons.sunset;
      case BreathingType.energizing: // Sabah Nefesi
        return FeatherIcons.sunrise;
      case BreathingType.vitalizing: // Güne Başlangıç
        return FeatherIcons.zap;
      default:
        return FeatherIcons.wind;
    }
  }

  IconData _getCategoryIcon(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return FeatherIcons.target;
      case BreathingCategory.kaygiVeStres:
        return FeatherIcons.heart;
      case BreathingCategory.uykuVeRahatlama:
        return FeatherIcons.moon;
      case BreathingCategory.enerjiVeCanlilik:
        return FeatherIcons.zap;
    }
  }

  String _getExerciseImage(BreathingExercise exercise) {
    return exercise.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final breathingProvider = Provider.of<BreathingProvider>(context, listen: false);
    final exercises = widget.category != null
        ? BreathingExercise.allExercises.where((ex) => ex.category == widget.category).toList()
        : BreathingExercise.allExercises;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: ProfessionalAppBar(
        scrollController: _scrollController,
        title: widget.category != null ? _getCategoryTitle(widget.category!) : AppStrings.practiceLibraryLink,
      ),
      body: GlobalBackground(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Kategori başlığı ve açıklama - ⚡ Animation removed
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category != null
                              ? _getCategoryDescription(widget.category!)
                              : AppStrings.practiceScreenSubtitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Container(
                          height: 2,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.category != null
                                    ? _getCategoryColor(widget.category!)
                                    : AppColors.primaryAccent,
                                (widget.category != null
                                    ? _getCategoryColor(widget.category!)
                                    : AppColors.primaryAccent).withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // 📺 Banner Reklam - Kategori açıklamasından sonra
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.medium),
                  child: const AdContainer(
                    placement: 'exercise_list_screen',
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  ),
                ),
              ),
              
              // Egzersiz listesi
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = exercises[index];
                      // ⚡ OPTIMIZED: FadeInUp animasyonu kaldırıldı - instant render
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.large),
                        child: _buildModernExerciseCard(context, breathingProvider, exercise, widget.category ?? exercise.category),
                      );
                    },
                    childCount: exercises.length,
                  ),
                ),
              ),
              
              // Alt boşluk
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernExerciseCard(
    BuildContext context, BreathingProvider provider, BreathingExercise exercise, BreathingCategory category) {
    final catColor = _getCategoryColor(category);
    
    return GestureDetector(
      onTap: () {
        // 🔒 Premium egzersiz kontrolü
        if (exercise.isPremium) {
          final premiumProvider = context.read<PremiumProvider>();
          if (!premiumProvider.canAccessPremiumContent(exercise.isPremium)) {
            HapticFeedback.heavyImpact();
            final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
              (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
              orElse: () => PremiumTrigger.predefinedTriggers.first,
            );
            SmartPremiumDialog.show(context, trigger);
            return;
          }
        }
        _showCycleSelectionModal(context, provider, exercise, category);
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface.withOpacity(0.6),
          border: Border.all(color: catColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sol: Geniş görsel
            SizedBox(
              width: 130,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      exercise.imagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      errorBuilder: (_, __, ___) => Container(
                        color: catColor.withOpacity(0.2),
                        child: Icon(_getExerciseIcon(exercise), color: catColor, size: 36),
                      ),
                    ),
                    // Hafif sağ kenar gradient (görsel-bilgi geçişi)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              AppColors.surface.withOpacity(0.4),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // PRO badge
                    if (exercise.isPremium)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                AppStrings.proTag,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Sağ: Bilgi + aksiyonlar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      exercise.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Açıklama
                    Expanded(
                      child: Text(
                        exercise.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Alt satır: adımlar + aksiyonlar
                    Row(
                      children: [
                        // Adım chip'leri (kompakt)
                        Expanded(
                          child: _buildTimingChips(exercise, category),
                        ),
                        const SizedBox(width: 8),
                        // Favori
                        Consumer<UserPreferencesProvider>(
                          builder: (context, userPrefs, _) {
                            final isFav = userPrefs.isFavoriteExercise(exercise.type.name);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                userPrefs.toggleFavoriteExercise(exercise.type.name);
                              },
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : AppColors.textSecondary.withOpacity(0.5),
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        // Play
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [catColor, catColor.withOpacity(0.7)],
                            ),
                          ),
                          child: const Icon(FeatherIcons.play, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStepColor(BreathingStepType type, BreathingCategory category) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppColors.success;
      case BreathingStepType.hold:
        return AppColors.warning;
      case BreathingStepType.exhale:
        return AppColors.info;
      default:
        return _getCategoryColor(category);
    }
  }

  String _getStepLabel(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppStrings.inhale;
      case BreathingStepType.hold:
        return AppStrings.hold;
      case BreathingStepType.exhale:
        return AppStrings.exhale;
      case BreathingStepType.holdAfterExhale:
        return AppStrings.holdAfterExhale;
      default:
        return '';
    }
  }

  Widget _buildTimingChips(BreathingExercise exercise, BreathingCategory category) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 3.0,
      children: exercise.steps
          .where((step) => _getStepLabel(step.type).isNotEmpty)
          .map((step) {
        final color = _getStepColor(step.type, category);
        final label = _getStepLabel(step.type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '${step.duration}${AppStrings.secondsShort} $label',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Başlangıç badge'i kaldırıldı çünkü tüm egzersizler başlangıç seviyesi

  Widget _buildModernInfoTag({required IconData icon, required String text, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Kademeli kilit sistemi: totalSessions'a göre hangi sürelerin açık olduğunu döndürür
  Map<int, bool> _getDurationLockStatus(int totalSessions) {
    // 1-2-3-4 dk her zaman açık
    // 5dk: 3+ seans sonra açılır
    // 10dk: 10+ seans sonra açılır
    return {
      1: true,
      2: true,
      3: true,
      4: true,
      5: totalSessions >= 3,
      10: totalSessions >= 10,
    };
  }

  /// Kilitli süre için kalan seans sayısını döndürür
  int _getRemainingSessionsToUnlock(int durationMinutes, int totalSessions) {
    switch (durationMinutes) {
      case 5: return (3 - totalSessions).clamp(0, 3);
      case 10: return (10 - totalSessions).clamp(0, 10);
      default: return 0;
    }
  }

  /// Kullanıcı deneyim seviyesine göre sağlık ipucu
  String _getHealthTip(int totalSessions) {
    if (totalSessions < 3) return AppStrings.healthTipBeginner;
    if (totalSessions < 10) return AppStrings.healthTipIntermediate;
    return AppStrings.healthTipAdvanced;
  }

  void _showCycleSelectionModal(BuildContext context, BreathingProvider provider, BreathingExercise exercise, BreathingCategory category) {
    final userPrefs = context.read<UserPreferencesProvider>();
    final totalSessions = userPrefs.totalSessions;
    final lockStatus = _getDurationLockStatus(totalSessions);
    final List<int> durationOptions = [1, 2, 3, 4, 5, 10]; // dakika cinsinden
    int selectedMinutes = 3; // varsayılan: 3dk
    int? lockedInfoMinutes; // kilitli süre bilgi mesajı için
    final catColor = _getCategoryColor(category);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            // Seçilen süreye göre tekrar hesapla
            final cycleDurationSec = exercise.totalCycleTime;
            final estimatedCycles = cycleDurationSec > 0
                ? (selectedMinutes * 60 / cycleDurationSec).round().clamp(1, 999)
                : selectedMinutes;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.97),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Egzersiz adı
                      Text(
                        exercise.name,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Açıklama
                      Text(
                        exercise.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),

                      // Süre seçenekleri — yatay pill'ler
                      Row(
                        children: durationOptions.map((minutes) {
                          final isSelected = selectedMinutes == minutes;
                          final isLocked = !(lockStatus[minutes] ?? true);

                          return Expanded(
                            child: GestureDetector(
                              onTap: isLocked
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      modalState(() {
                                        lockedInfoMinutes = lockedInfoMinutes == minutes ? null : minutes;
                                      });
                                    }
                                  : () {
                                      HapticFeedback.selectionClick();
                                      modalState(() {
                                        selectedMinutes = minutes;
                                      });
                                    },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? Colors.white.withOpacity(0.03)
                                      : isSelected
                                          ? catColor.withOpacity(0.15)
                                          : Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isLocked
                                        ? Colors.white.withOpacity(0.06)
                                        : isSelected
                                            ? const Color(0xFFD4912A)
                                            : Colors.white.withOpacity(0.1),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFD4912A).withOpacity(0.2),
                                            blurRadius: 12,
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLocked)
                                      Icon(
                                        FeatherIcons.lock,
                                        color: Colors.white.withOpacity(0.25),
                                        size: 14,
                                      )
                                    else
                                      Text(
                                        '$minutes dk',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    if (isLocked) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '$minutes dk',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.2),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Kilitli süre bilgi mesajı — modal içinde
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: lockedInfoMinutes != null
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8A838).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8A838).withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FeatherIcons.lock,
                                      color: const Color(0xFFE8A838).withOpacity(0.8),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        AppStrings.lockedReason(
                                          _getRemainingSessionsToUnlock(lockedInfoMinutes!, totalSessions),
                                          lockedInfoMinutes!,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Tekrar bilgisi
                      Text(
                        '\u2248 $estimatedCycles tekrar \u00B7 ${AppStrings.beginnerIdealInfo}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Başla butonu — amber/gold gradient
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8A838), Color(0xFFD4912A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4912A).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              // Süreyi tekrara çevir
                              final cycleDuration = exercise.totalCycleTime;
                              final cycles = cycleDuration > 0
                                  ? (selectedMinutes * 60 / cycleDuration).round().clamp(1, 999)
                                  : selectedMinutes;
                              provider.setExercise(exercise, customCycles: cycles);
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (ctx) => const BreathingScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppStrings.startButtonText,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 