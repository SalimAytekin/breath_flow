import 'dart:ui';

import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../widgets/professional_app_bar.dart';
import '../widgets/global_background.dart';
import 'breathing_screen.dart';

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
  double _opacity = 0.0;

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
    super.dispose();
  }

  void _onScroll() {
    const scrollThreshold = 100.0;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0;
    final newOpacity = (offset / scrollThreshold).clamp(0.0, 1.0);

    if (newOpacity != _opacity) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  String _getCategoryTitle(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return 'Odaklanma & Konsantrasyon';
      case BreathingCategory.kaygiVeStres:
        return 'Rahatlama & Huzur';
      case BreathingCategory.uykuVeRahatlama:
        return 'Huzurlu Uyku';
      case BreathingCategory.enerjiVeCanlilik:
        return 'Enerji & Zindelik';
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
        return 'Dikkatini tek bir noktaya yönlendir, düşüncelerini toparla. Zihnini netleştir ve anın tadını çıkar.';
      case BreathingCategory.kaygiVeStres:
        return 'Derin bir nefesle gerginliği bırak ve bedenini yavaşça gevşet. İç huzurunu hisset ve günün stresini geride bırak.';
      case BreathingCategory.uykuVeRahatlama:
        return 'Bedenini ve zihnini dinlendir, yavaşça gevşe. Gözlerini kapat ve huzurlu bir uykuya doğru yol al.';
      case BreathingCategory.enerjiVeCanlilik:
        return 'İçindeki enerjiyi uyandır ve günün tadını çıkar. Taze bir nefesle kendini zinde ve motive hisset.';
    }
  }

  String _getExerciseShortDescription(BreathingExercise exercise) {
    switch (exercise.name) {
      case 'Kutu Nefesi (4-4-4-4)':
        return 'Nefesini dört aşamada düzenle: al, tut, ver ve bekle. Zihinsel dengeyi artırır.';
      case 'Basit Sayma Nefesi':
        return 'Nefes alırken ve verirken sayılara odaklan. Zihni toparlamaya yardımcı olur.';
      case 'Farkındalık Nefesi':
        return 'Nefesini doğal akışında gözlemle. Değiştirmeden sadece fark et.';
      case 'Uzunca Nefes Ver (4-6)':
        return 'Kısa al, uzun ver. Bu ritim sinir sistemini sakinleştirir.';
      case 'Diyafram Nefesi':
        return 'Nefesi karına doğru al. Göğüsten değil karından nefes almak stresi azaltır.';
      case 'Eşit Nefes':
        return 'Nefesi aynı sürede alıp ver. Zihinsel denge ve iç huzur sağlar.';
      case 'Yavaşlatıcı Nefes':
        return 'Her nefeste ritmi biraz daha yavaşlat. Bedenini uykuya hazırlar.';
      case 'Beden Farkındalığı Nefesi':
        return 'Nefes alırken bedenine odaklan. Gerginlikleri fark et ve bırak.';
      case 'Gevşeme Nefesi (3-6)':
        return 'Kısa nefes al, uzun nefes ver. Vücudun derin rahatlama yaşar.';
      case 'Canlandırıcı Diyafram':
        return 'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.';
      case 'Sabah Nefesi':
        return 'Güne derin ve canlı nefeslerle başla. Sabah enerjini yükseltir.';
      case 'Güne Başlama Nefesi (6-4)':
        return 'Pozitif enerjiyle nefes al, hafif şekilde ver. Güne hazırlar.';
      default:
        return exercise.purpose;
    }
  }

  IconData _getExerciseIcon(BreathingExercise exercise) {
    switch (exercise.name) {
      case 'Kutu Nefesi (4-4-4-4)':
        return FeatherIcons.square;
      case 'Basit Sayma Nefesi':
        return FeatherIcons.hash;
      case 'Farkındalık Nefesi':
        return FeatherIcons.eye;
      case 'Uzun Verme Nefesi (4-6)':
        return FeatherIcons.wind;
      case 'Diyafram Nefesi':
        return FeatherIcons.circle;
      case 'Eşit Nefes':
        return FeatherIcons.minimize2;
      case 'Yavaşlatıcı Nefes':
        return FeatherIcons.moon;
      case 'Vücut Tarama ile Nefes':
        return FeatherIcons.search;
      case 'Gevşeme Nefesi (3-6)':
        return FeatherIcons.sunset;
      case 'Canlandırıcı Diyafram':
        return FeatherIcons.sun;
      case 'Sabah Nefesi':
        return FeatherIcons.sunrise;
      case 'Güne Başlama Nefesi (6-4)':
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
              // Kategori başlığı ve açıklama
              SliverToBoxAdapter(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
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
              ),
              
              // Egzersiz listesi
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = exercises[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 100 * index),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                          child: _buildModernExerciseCard(context, breathingProvider, exercise, widget.category),
                        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _getCategoryColor(category).withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withOpacity(0.95),
                AppColors.surface.withOpacity(0.85),
                _getCategoryColor(category).withOpacity(0.08),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            border: Border.all(
              color: _getCategoryColor(category).withOpacity(0.15),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                splashColor: _getCategoryColor(category).withOpacity(0.15),
                highlightColor: _getCategoryColor(category).withOpacity(0.08),
                onTap: () {
                  if (exercise.isPremium && !context.read<PremiumProvider>().isPremiumUser) {
                    context.read<PremiumProvider>().showFeatureLimitTrigger('advanced_breathing');
                    return;
                  }
                  _showCycleSelectionModal(context, provider, exercise, category);
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Row(
                    children: [
                      // Sol taraf - Renkli ikon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(category).withOpacity(0.2),
                              _getCategoryColor(category).withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _getCategoryColor(category).withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(category).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            _getExerciseIcon(exercise),
                            color: _getCategoryColor(category),
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: AppSpacing.large),
                      
                      // Orta - İçerik
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık ve premium badge
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exercise.name,
                                    style: AppTypography.headlineSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ),
                                if (exercise.isPremium)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.premium,
                                          AppColors.premium.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.premium.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(FeatherIcons.award, color: Colors.white, size: 10),
                                        const SizedBox(width: 3),
                                        Text(
                                          'PRO',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: AppSpacing.small),
                            
                            // Kısa açıklama
                            Text(
                              _getExerciseShortDescription(exercise),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: AppSpacing.medium),
                            
                            // Sadece timing bilgisi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.medium,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(category).withOpacity(0.15),
                                    _getCategoryColor(category).withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getCategoryColor(category).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FeatherIcons.clock,
                                    size: 12,
                                    color: _getCategoryColor(category),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    exercise.timingsFormatted,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: AppSpacing.medium),
                      
                      // Sağ taraf - Renkli play butonu
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(category).withOpacity(0.8),
                              _getCategoryColor(category).withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(category).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            FeatherIcons.play,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
              margin: const EdgeInsets.all(AppSpacing.medium),
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
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
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
                                style: AppTypography.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Kaç döngü yapmak istiyorsun?',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FeatherIcons.x,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Döngü seçenekleri - Modern Grid Layout
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'döngü',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '~${estimatedMinutes}dk',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),

                    // Başlat butonu - Modern tasarım
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.setExercise(exercise, customCycles: selectedCycles);
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => const BreathingScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getCategoryColor(category),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.medium),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FeatherIcons.play, size: 16),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              'Başlat ($selectedCycles döngü)',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 