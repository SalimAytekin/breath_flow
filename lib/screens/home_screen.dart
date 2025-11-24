import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:breathe_flow/screens/breathing_screen.dart';
import 'package:breathe_flow/screens/immersive_sound_player_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/breathing_exercise.dart';
import '../models/sound_item.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/breathing_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/professional_button.dart';
import '../constants/app_strings.dart';
import '../widgets/weekly_summary_card.dart';
import '../ui/components/ad_container.dart';
import '../providers/exercise_tracking_provider.dart';

/// 🏠 Professional Home Screen
/// Redesigned with Deep Night Serenity theme system
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // 🎭 Seçili mood - ⚡ ValueNotifier ile optimize edildi
  final ValueNotifier<String> _selectedMood = ValueNotifier('rahatlama');
  
  // 🫁 Breathing Animasyonu
  AnimationController? _breathingController;
  Animation<double>? _breathingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Breathing animasyonu - sürekli tekrarde, rahatlatıcı ritim
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2500), // AppConstants.breathingAnimationDuration
      vsync: this,
    )..repeat(reverse: true); // İleri geri sürekli tekrar
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15, // %15 büyüme - subtle ama fark edilir
    ).animate(CurvedAnimation(
      parent: _breathingController!,
      curve: Curves.easeInOut, // Yumuşak geçiş
    ));
  }

  @override
  void dispose() {
    _breathingController?.stop(); // ⚡ Stop first to prevent leaks
    _breathingController?.dispose();
    _selectedMood.dispose(); // ⚡ Dispose ValueNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = AppStrings.morningGreeting;
    } else if (hour < 17) {
      greeting = AppStrings.afternoonGreeting;
    } else if (hour < 22) {
      greeting = AppStrings.eveningGreeting;
    } else {
      greeting = AppStrings.nightGreeting;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 📱 Header - Scroll edilince kaybolur
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 80.0,
                pinned: false, // Scroll edilince kaybolur
                floating: false,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                  centerTitle: false,
                  title: Text(
                    greeting,
                    style: AppTypography.displaySmall,
                  ),
                ),
              ),

              // 🫁 HERO CARD - Saate göre değişen ana aksiyon
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildHeroCard(context, hour),
                  ),
                ),
              ),
              
              // 🎭 MOOD SEÇİCİ - ⚡ ValueListenableBuilder ile optimize edildi
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(top: AppSpacing.large),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _selectedMood,
                      builder: (context, mood, child) => _buildMoodSelector(context),
                    ),
                  ),
                ),
              ),
              
              // 🎯 MOOD BAZLI ÖNERİLER - ⚡ ValueListenableBuilder ile optimize edildi
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(top: AppSpacing.large),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 150),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _selectedMood,
                      builder: (context, mood, child) => _buildMoodBasedRecommendations(context),
                    ),
                  ),
                ),
              ),
              
              
              // 📊 BU HAFTA KARTI (Aşağıya taşındı)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(
                    top: AppSpacing.xxLarge, 
                    bottom: 150 + MediaQuery.of(context).padding.bottom, // Reklam + bottom bar için ekstra boşluk
                  ),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: const WeeklySummaryCard(),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// 🫁 Hero Card - Saate göre değişen ana aksiyon kartı
  Widget _buildHeroCard(BuildContext context, int hour) {
    // Saate göre içerik belirle
    String title;
    String description;
    IconData icon;
    Gradient gradient;
    BreathingType exerciseType;
    String exerciseName;
    
    if (hour < 12) {
      title = AppStrings.energeticStart;
      description = AppStrings.energeticStartDesc;
      icon = FeatherIcons.sun;
      gradient = AppColors.energyGradient;
      exerciseType = BreathingType.deepBreathing;
      exerciseName = 'Sabah Nefesi';
    } else if (hour < 17) {
      title = AppStrings.lunchBreak;
      description = AppStrings.lunchBreakDesc;
      icon = FeatherIcons.coffee;
      gradient = AppColors.focusGradient;
      exerciseType = BreathingType.boxBreathing;
      exerciseName = 'Kutu Nefesi (4-4-4-4)';
    } else if (hour < 22) {
      title = AppStrings.eveningRelax;
      description = AppStrings.eveningRelaxDesc;
      icon = FeatherIcons.sunset;
      gradient = AppColors.relaxationGradient;
      exerciseType = BreathingType.extendedExhale;
      exerciseName = 'Uzunca Nefes Ver (4-6)';
    } else {
      title = AppStrings.sleepPrep;
      description = AppStrings.sleepPrepDesc;
      icon = FeatherIcons.moon;
      gradient = AppColors.sleepGradient;
      exerciseType = BreathingType.custom;
      exerciseName = 'Yavaşlatıcı Nefes';
    }
    
    return Semantics(
      button: true,
      label: '$title. $description. Başla butonuna dokunun.',
      hint: 'Nefes egzersizi başlatmak için çift dokunun',
      child: Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Saate özel egzersiz için tekrar seçim modalını göster
            _showBreathingDurationDialog(context, exerciseType, exerciseName);
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 🫁 Breathing animasyonlu icon
                    _breathingAnimation != null
                        ? AnimatedBuilder(
                            animation: _breathingAnimation!,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _breathingAnimation!.value,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.medium),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1 * _breathingAnimation!.value),
                                        blurRadius: 20 * _breathingAnimation!.value,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.all(AppSpacing.medium),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                        vertical: AppSpacing.small,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      child: Text(
                        AppStrings.fiveMinutes,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  title,
                  style: AppTypography.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.start,
                        style: AppTypography.labelLarge.copyWith(
                          color: gradient.colors.first,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Icon(
                        FeatherIcons.arrowRight,
                        color: gradient.colors.first,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎭 Mood Seçici Widget - GÜZEL VERSİYON
  Widget _buildMoodSelector(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final emojiSize = screenWidth < 400 ? 28.0 : (screenWidth < 500 ? 32.0 : 36.0);
    final labelFontSize = screenWidth < 400 ? 11.0 : 12.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.tiny, bottom: AppSpacing.medium),
          child: Text(
            AppStrings.whatDoYouWantToDo,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Mood Butonları
        Row(
          children: [
            Expanded(
              child: _buildMoodButton(
                emoji: '😌',
                label: AppStrings.relaxationMood,
                value: 'rahatlama',
                isSelected: _selectedMood.value == 'rahatlama',
                gradient: AppColors.relaxationGradient,
                emojiSize: emojiSize,
                labelFontSize: labelFontSize,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: _buildMoodButton(
                emoji: '🌊',
                label: AppStrings.calmnessMood,
                value: 'sakinlesme',
                isSelected: _selectedMood.value == 'sakinlesme',
                gradient: AppColors.focusGradient,
                emojiSize: emojiSize,
                labelFontSize: labelFontSize,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: _buildMoodButton(
                emoji: '😴',
                label: AppStrings.sleepMood,
                value: 'uyku',
                isSelected: _selectedMood.value == 'uyku',
                gradient: AppColors.sleepGradient,
                emojiSize: emojiSize,
                labelFontSize: labelFontSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🎭 Mood Butonu - GÜZEL VERSİYON
  Widget _buildMoodButton({
    required String emoji,
    required String label,
    required String value,
    required bool isSelected,
    required Gradient gradient,
    required double emojiSize,
    required double labelFontSize,
  }) {
    return GestureDetector(
      onTap: () {
        _selectedMood.value = value; // ⚡ No setState - ValueNotifier kullan
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.large,
            horizontal: AppSpacing.small,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: emojiSize,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: labelFontSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Mood Bazlı Öneriler
  Widget _buildMoodBasedRecommendations(BuildContext context) {
    // Mood'a göre önerileri belirle
    final recommendations = _getMoodRecommendations();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.tiny),
          child: Row(
            children: [
              Text(
                AppStrings.personalRecommendations,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(width: AppSpacing.small),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        
        // Öneriler
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: _buildRecommendationItem(
            context,
            emoji: rec['emoji'] as String,
            title: rec['title'] as String,
            subtitle: rec['subtitle'] as String,
            color: rec['color'] as Color,
            gradient: rec['gradient'] as Gradient,
            isBreathing: rec['isBreathing'] as bool,
            onTap: rec['onTap'] as VoidCallback,
          ),
        )),
      ],
    );
  }

  /// 🎯 Mood'a Göre Önerileri Al - GÖRSEL VERSİYON
  List<Map<String, dynamic>> _getMoodRecommendations() {
    switch (_selectedMood.value) { // ⚡ ValueNotifier value
      case 'rahatlama':
        return [
          {
            'emoji': '🌬️',
            'title': AppStrings.awarenessBreath,
            'subtitle': AppStrings.awarenessBreathDesc,
            'color': AppColors.relaxation,
            'gradient': AppColors.relaxationGradient,
            'isBreathing': true,
            'onTap': () => _showBreathingDurationDialog(context, BreathingType.deepBreathing, AppStrings.awarenessBreath),
          },
          {
            'emoji': '🌲',
            'title': AppStrings.forestSoundsTitle,
            'subtitle': AppStrings.forestSoundsDesc,
            'color': AppColors.relaxation,
            'gradient': AppColors.relaxationGradient,
            'isBreathing': false,
            'onTap': () => _playSound(context, 'forest'),
          },
        ];
      case 'sakinlesme':
        return [
          {
            'emoji': '🫧',
            'title': AppStrings.extendedExhale,
            'subtitle': AppStrings.extendedExhaleDesc,
            'color': AppColors.focus,
            'gradient': AppColors.focusGradient,
            'isBreathing': true,
            'onTap': () => _showBreathingDurationDialog(context, BreathingType.extendedExhale, AppStrings.extendedExhale),
          },
          {
            'emoji': '🌧️',
            'title': AppStrings.heavyRainTitle,
            'subtitle': AppStrings.heavyRainDesc,
            'color': AppColors.focus,
            'gradient': AppColors.focusGradient,
            'isBreathing': false,
            'onTap': () => _playSound(context, 'heavy_rain'),
          },
        ];
      case 'uyku':
        return [
          {
            'emoji': '🌙',
            'title': AppStrings.slowingBreath,
            'subtitle': AppStrings.slowingBreathDesc,
            'color': AppColors.sleep,
            'gradient': AppColors.sleepGradient,
            'isBreathing': true,
            'onTap': () => _showBreathingDurationDialog(context, BreathingType.custom, AppStrings.slowingBreath),
          },
          {
            'emoji': '🦗',
            'title': AppStrings.nightCrickets,
            'subtitle': AppStrings.nightCricketsDesc,
            'color': AppColors.sleep,
            'gradient': AppColors.sleepGradient,
            'isBreathing': false,
            'onTap': () => _playSound(context, 'night_crickets'),
          },
        ];
      default:
        return [];
    }
  }

  /// 🎯 Öneri Öğesi - GRADIENT + EMOJI VERSİYON
  Widget _buildRecommendationItem(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required Gradient gradient,
    required bool isBreathing,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final emojiContainerWidth = screenWidth < 400 ? 70.0 : (screenWidth < 500 ? 80.0 : 90.0);
    final emojiFontSize = screenWidth < 400 ? 36.0 : (screenWidth < 500 ? 40.0 : 42.0);
    final containerHeight = screenWidth < 400 ? 80.0 : 90.0;
    
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      hint: 'Başlatmak için çift dokunun',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
          child: Container(
            height: containerHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Gradient Emoji Sol Taraf
                Container(
                  width: emojiContainerWidth,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusXLarge),
                      bottomLeft: Radius.circular(AppSpacing.radiusXLarge),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: emojiFontSize),
                    ),
                  ),
                ),
                
                // Text Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Minimize column size
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2, // Prevent text overflow
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Nefes/Ses Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.small,
                                vertical: AppSpacing.tiny,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                border: Border.all(
                                  color: color.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isBreathing ? FeatherIcons.wind : FeatherIcons.volume2,
                                    size: 10,
                                    color: color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isBreathing ? 'Nefes' : 'Ses',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.tiny),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Play Button
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.large),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      FeatherIcons.play,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔄 Döngü Seçim Modal'ı Göster (Keşfet ekranındaki gibi)
  void _showBreathingDurationDialog(BuildContext context, BreathingType type, String exerciseName) {
    // Egzersizi bul
    final exercise = BreathingExercise.allExercises.firstWhere(
      (e) => e.type == type,
      orElse: () => BreathingExercise.allExercises.first,
    );
    
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
                                exerciseName,
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
                                  '~${estimatedMinutes}dk',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: isSmallScreen ? 8 : 9,
                                  ),
                                ),
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
                          // Egzersiz başlatma tracking
                          final exerciseTrackingProvider = Provider.of<ExerciseTrackingProvider>(context, listen: false);
                          exerciseTrackingProvider.onExerciseStarted();
                          
                          // Egzersizi set et ve başlat
                          breathingProvider.setExercise(exercise, customCycles: selectedCycles);
                          breathingProvider.start();
                          
                          Navigator.of(context).pop(); // Modal'ı kapat
                          
                          // BreathingScreen'e git
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BreathingScreen(),
                            ),
                          ).then((_) {
                            // Ekrandan döndüğünde egzersizi durdur
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
                                'Başlat ($selectedCycles tekrar)',
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


  /// 🎵 Ses Çal - Direkt tam ekran oynatıcıda başlat
  void _playSound(BuildContext context, String soundId) {
    // Sesi bul
    final sound = SoundItem.allSounds.firstWhere(
      (s) => s.id == soundId,
      orElse: () => SoundItem.allSounds.first,
    );
    
    // 🎵 AudioProvider.playExclusive kullanmıyoruz
    // Crossfade sistem ImmersiveSoundPlayerScreen içinde kullanılıyor
    // Bu şekilde iki sistem çakışmıyor ve ses dispose sırasında temiz kapanıyor
    
    // Direkt tam ekran oynatıcıya git
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImmersiveSoundPlayerScreen(sound: sound),
      ),
    );
  }

  /// 🎯 Günlük Hedef Belirleme Dialog'u
  void _showDailyGoalDialog(BuildContext context) {
    final userPrefs = Provider.of<UserPreferencesProvider>(context, listen: false);
    int selectedMinutes = userPrefs.dailyGoalMinutes > 0 ? userPrefs.dailyGoalMinutes : 10;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: const Icon(
                  FeatherIcons.target,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Günlük Hedef',
                style: AppTypography.headlineMedium,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Her gün kaç dakika aktivite yapmak istiyorsun?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Container(
                padding: const EdgeInsets.all(AppSpacing.large),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Text(
                  '$selectedMinutes\ndakika',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Slider(
                value: selectedMinutes.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                activeColor: AppColors.primaryAccent,
                inactiveColor: AppColors.primaryAccent.withOpacity(0.2),
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value.toInt();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5 dk',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '60 dk',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ProfessionalButton(
                    text: 'İptal',
                    onPressed: () => Navigator.of(context).pop(),
                    buttonType: ButtonType.ghost,
                    buttonSize: ButtonSize.medium,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: ProfessionalButton(
                    text: 'Kaydet',
                    onPressed: () {
                      userPrefs.setDailyGoalMinutes(selectedMinutes);
                      Navigator.of(context).pop();
                    },
                    buttonType: ButtonType.primary,
                    buttonSize: ButtonSize.medium,
                    icon: FeatherIcons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}