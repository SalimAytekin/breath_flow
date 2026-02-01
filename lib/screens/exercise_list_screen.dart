import 'dart:ui';

import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:breathe_flow/widgets/smart_premium_dialog.dart';
import 'package:breathe_flow/models/premium_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:animate_do/animate_do.dart';

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
import '../services/asset_manager.dart';
import '../ui/components/ad_container.dart';

class ExerciseListScreen extends StatefulWidget {
  final BreathingCategory category;
  final String heroTag;

  const ExerciseListScreen({
    super.key,
    required this.category,
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
    final exercises = BreathingExercise.allExercises
        .where((ex) => ex.category == widget.category)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: ProfessionalAppBar(
        scrollController: _scrollController,
        title: _getCategoryTitle(widget.category),
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
                          _getCategoryDescription(widget.category),
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
                                _getCategoryColor(widget.category),
                                _getCategoryColor(widget.category).withOpacity(0.3),
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
                        child: _buildModernExerciseCard(context, breathingProvider, exercise, widget.category),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
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
        constraints: BoxConstraints(minHeight: isSmallScreen ? 150 : 160),
        padding: EdgeInsets.all(isSmallScreen ? AppSpacing.small : AppSpacing.medium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface.withOpacity(0.9),
              AppColors.surface.withOpacity(0.8),
              _getCategoryColor(category).withOpacity(0.15),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getCategoryColor(category).withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: _getCategoryColor(category).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sol: Mini thumbnail
                  Center(child: _buildCompactThumbnail(exercise, category)),

                  SizedBox(width: isSmallScreen ? AppSpacing.small : AppSpacing.medium),

                  // Orta: Bilgiler
                  Expanded(child: _buildCompactInfo(exercise, category)),

                  SizedBox(width: isSmallScreen ? 4 : AppSpacing.small),

                  // Sağ: Favorite + Play
                  _buildCompactActions(exercise, category),
                ],
              ),
            ),
            // PRO Badge artık _buildCompactInfo içinde başlık yanında gösteriliyor
          ],
        ),
      ),
    );
  }

  // Kompakt thumbnail widget
  Widget _buildCompactThumbnail(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final thumbnailSize = screenWidth < 400 ? 90.0 : (screenWidth < 500 ? 100.0 : 110.0);
    
    return Container(
      width: thumbnailSize,
      height: thumbnailSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(category).withOpacity(0.25),
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
            // Resim - Yüksek Kalite ve Sıkıştırmasız
            Container(
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  _getExerciseImage(exercise),
                  fit: BoxFit.contain,
                  cacheWidth: 300,
                  cacheHeight: 300,
                  isAntiAlias: true,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(category).withOpacity(0.6),
                            _getCategoryColor(category).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Icon(
                        _getExerciseIcon(exercise),
                        color: Colors.white.withOpacity(0.8),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Hafif overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kompakt bilgi widget
  Widget _buildCompactInfo(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final titleFontSize = isSmallScreen ? 16.0 : (screenWidth < 500 ? 17.0 : 18.0);
    final descFontSize = isSmallScreen ? 11.0 : (screenWidth < 500 ? 12.0 : 13.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2.0 : 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık + PRO Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 🔒 PRO Badge - Başlık yanında
                  if (exercise.isPremium)
                    Consumer<PremiumProvider>(
                      builder: (context, premium, _) {
                        if (premium.isPremiumUser) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.premium,
                                AppColors.premium.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond, color: Colors.white, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              // Açıklama
              Text(
                _getExerciseShortDescription(exercise),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: descFontSize,
                  height: 1.4,
                ),
                maxLines: isSmallScreen ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          // Timing badge
          _buildTimingChips(exercise, category),
        ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Wrap(
      spacing: isSmallScreen ? 4.0 : 6.0,
      runSpacing: isSmallScreen ? 3.0 : 4.0,
      children: exercise.steps
          .where((step) => _getStepLabel(step.type).isNotEmpty)
          .map((step) {
        final color = _getStepColor(step.type, category);
        final label = _getStepLabel(step.type);
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 6 : 8,
            vertical: isSmallScreen ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            '${step.duration}${AppStrings.secondsShort} $label',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Kompakt aksiyonlar widget
  Widget _buildCompactActions(BreathingExercise exercise, BreathingCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconButtonSize = screenWidth < 400 ? 38.0 : 44.0;
    final playButtonSize = screenWidth < 400 ? 46.0 : 54.0;
    final iconSize = screenWidth < 400 ? 20.0 : 26.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Favorite button
        Consumer<UserPreferencesProvider>(
          builder: (context, userPrefs, child) {
            final isFavorite = userPrefs.isFavoriteExercise(exercise.type.name);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                userPrefs.toggleFavoriteExercise(exercise.type.name);
              },
              child: Container(
                width: iconButtonSize,
                height: iconButtonSize,
                decoration: BoxDecoration(
                  color: isFavorite 
                      ? Colors.red.withOpacity(0.15)
                      : AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFavorite 
                        ? Colors.red.withOpacity(0.5)
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                  size: screenWidth < 400 ? 18 : 22,
                ),
              ),
            );
          },
        ),
        
        // Play button
        Container(
          width: playButtonSize,
          height: playButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(category).withOpacity(1),
                _getCategoryColor(category).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColor(category).withOpacity(0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            FeatherIcons.play,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ],
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

  void _showCycleSelectionModal(BuildContext context, BreathingProvider provider, BreathingExercise exercise, BreathingCategory category) {
    final List<int> cycleOptions = [5, 10, 15, 20, 25, 30];
    int selectedCycles = 10;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            return Container(
              margin: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? AppSpacing.small : AppSpacing.medium),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? AppSpacing.medium : AppSpacing.large),
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
                                    fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 20,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.width < 400 ? AppSpacing.tiny : AppSpacing.small),
                                Text(
                                  AppStrings.howManyCyclesQuestion,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              FeatherIcons.x,
                              color: AppColors.textPrimary,
                              size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width < 400 ? AppSpacing.medium : AppSpacing.large),

                      // Döngü seçenekleri - Modern Grid Layout
                      SizedBox(
                        height: MediaQuery.of(context).size.width < 400 ? 160 : 200,
                        child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: MediaQuery.of(context).size.width < 400 ? 1.3 : 1.4,
                          crossAxisSpacing: MediaQuery.of(context).size.width < 400 ? 4 : 6,
                          mainAxisSpacing: MediaQuery.of(context).size.width < 400 ? 4 : 6,
                        ),
                        itemCount: cycleOptions.length,
                        itemBuilder: (context, index) {
                          final cycles = cycleOptions[index];
                          final isSelected = selectedCycles == cycles;
                          final estimatedMinutes = (cycles * exercise.totalDuration / 60).round();
                          
                          return GestureDetector(
                            onTap: () {
                              modalState(() {
                                selectedCycles = cycles;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getCategoryColor(category).withOpacity(0.2)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _getCategoryColor(category)
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
                                          ? _getCategoryColor(category)
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.cyclesLabel,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: MediaQuery.of(context).size.width < 400 ? 9 : 10,
                                    ),
                                  ),
                                  Text(
                                    '~${estimatedMinutes}${AppStrings.minutesShort}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: MediaQuery.of(context).size.width < 400 ? 8 : 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                      SizedBox(height: MediaQuery.of(context).size.width < 400 ? AppSpacing.large : AppSpacing.xLarge),

                      // Başlat butonu - Modern tasarım
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            provider.setExercise(exercise, customCycles: selectedCycles);
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const BreathingScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCategoryColor(category),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width < 400 ? AppSpacing.small : AppSpacing.medium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.medium),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FeatherIcons.play, size: MediaQuery.of(context).size.width < 400 ? 14 : 16),
                              SizedBox(width: MediaQuery.of(context).size.width < 400 ? AppSpacing.tiny : AppSpacing.small),
                              Flexible(
                                child: Text(
                                  AppStrings.startWithCyclesFormat(selectedCycles),
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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