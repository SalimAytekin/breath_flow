import 'dart:ui'; // ImageFilter için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // groupBy için
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../widgets/professional_app_bar.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/breathing_animation.dart';
import '../widgets/professional_card.dart'; // Yeni kartlar için
import '../widgets/session_completion_dialog.dart';
import '../widgets/fullscreen_confetti_widget.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../services/asset_manager.dart';
import 'exercise_list_screen.dart'; // Bu dosya bir sonraki adımda oluşturulacak
import '../providers/audio_provider.dart';
import '../models/sound_item.dart';
import '../models/sound_category.dart';
import '../providers/exercise_tracking_provider.dart';
import '../core/ads/ad_manager.dart';
import '../core/ads/admob_provider.dart';
import '../widgets/global_background.dart';
import 'main_navigation_screen.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  late final ScrollController _scrollController;
  String? selectedSoundId;
  bool _isShowingConfetti = false; // Confetti animasyonu için
  bool _isLoadingInterstitial = false; // Interstisial yüklenirken loading
  final ValueNotifier<bool> _exerciseCompleted = ValueNotifier(false); // ⚡ ValueNotifier - optimized rebuild

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final breathingProvider = context.read<BreathingProvider>();
      breathingProvider.setOnSessionCompleted(() {
        _onSessionCompleted(breathingProvider);
      });
      
      // Reklamı gerektiğinde yükleyeceğiz
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _exerciseCompleted.dispose(); // ⚡ Dispose ValueNotifier
    
    // 🎯 Egzersizden çıkış kontrolü - 3 egzersiz başlatıp çıkarsa interstitial reklam göster
    if (mounted) {
      try {
        final exerciseTrackingProvider = Provider.of<ExerciseTrackingProvider>(context, listen: false);
        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
        
        // Premium kullanıcılar için reklam gösterme
        if (!premiumProvider.canAccessFeature('ad_free')) {
          if (exerciseTrackingProvider.shouldShowExitInterstitial()) {
            // Async olarak interstitial reklam göster
            AdManager.instance.showInterstitial(placement: 'breathing_exit_control').then((adShown) {
              if (adShown) {
 if (kDebugMode) debugPrint('✅ Egzersiz çıkış kontrolü interstitial reklamı gösterildi');
              }
            });
          }
        }
        
        Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
      } catch (e) {
        // Provider'a erişilemezse sessizce geç
        if (kDebugMode) print('Provider dispose error: $e');
      }
    }
    super.dispose();
  }

  /// Reklamı önceden yükle - gecikme olmasın
  void _preloadInterstitialAd() async {
    try {
      final premiumProvider = context.read<PremiumProvider>();
      if (!premiumProvider.canAccessFeature('ad_free')) {
 if (kDebugMode) debugPrint('🎯 Reklam önceden yükleniyor...');
        // Sadece yükleme yap, gösterme
        final adProvider = AdManager.instance.provider;
        if (adProvider != null) {
          await adProvider.loadInterstitial(placement: 'breathing_session_complete');
 if (kDebugMode) debugPrint('✅ Reklam önceden yüklendi!');
        } else {
 if (kDebugMode) debugPrint('❌ AdProvider bulunamadı');
        }
      }
    } catch (e) {
 if (kDebugMode) debugPrint('❌ Reklam önceden yüklenemedi: $e');
    }
  }

  void _onSessionCompleted(BreathingProvider provider) async {
    if (!mounted) return;
    
    final currentExercise = provider.currentExercise;
    if (currentExercise == null) return;
    
    try {
      // 🎵 Egzersiz bitiminde tüm sesleri durdur
      final audioProvider = context.read<AudioProvider>();
      await audioProvider.stopAllSounds();
      
      final userPrefsProvider = context.read<UserPreferencesProvider>();
      userPrefsProvider.recordBreathingSession(provider.actualSessionDurationMinutes);
      
      final premiumProvider = context.read<PremiumProvider>();
      premiumProvider.trackUserAction('breathing_session_completed', {
        'technique': currentExercise.name,
        'duration': provider.actualSessionDurationMinutes,
        'cycles': provider.totalCycles,
      });
      
      // 🎯 Egzersiz durumunu koru - kategori ekranına dönmesini engelle
 if (kDebugMode) debugPrint('🎯 Egzersiz tamamlandı - Durum korunuyor...');
      
      // Egzersiz tamamlandı flag'ini set et - ⚡ ValueNotifier kullan
      if (mounted) {
        _exerciseCompleted.value = true; // ⚡ No setState - optimized
      }

      // Analytics tracking
      // await AnalyticsService.instance.trackUserEngagement(
      //   action: 'breathing_session_completed',
      //   screen: 'breathing_screen',
      //   parameters: {
      //     'technique': currentExercise.name,
      //     'duration': provider.sessionDuration,
      //     'cycles': provider.totalCycles,
      //   },
      // );

      // 🎯 Egzersiz bitiminde hemen reklam göster
      bool adShown = false;
      if (!premiumProvider.canAccessFeature('ad_free')) {
        final exerciseTrackingProvider = context.read<ExerciseTrackingProvider>();
        
 if (kDebugMode) debugPrint('🎯 Egzersiz tamamlandı - Reklam kontrolü başlıyor...');
        
        if (exerciseTrackingProvider.shouldShowCompletionInterstitial()) {
 if (kDebugMode) debugPrint('✅ Reklam gösterim onayı alındı - Loading ekranı gösteriliyor...');
          
          // Loading ekranını göster
          if (mounted) {
            setState(() {
              _isLoadingInterstitial = true;
            });
          }
          
          // Kısa bir gecikme sonrası reklamı göster
          await Future.delayed(const Duration(milliseconds: 500));
          
 if (kDebugMode) debugPrint('✅ Interstitial yükleniyor...');
          adShown = await AdManager.instance.showInterstitial(placement: 'breathing_session_complete');
          
          // Loading ekranını kapat
          if (mounted) {
            setState(() {
              _isLoadingInterstitial = false;
            });
          }
          
          if (adShown) {
 if (kDebugMode) debugPrint('🎉 Nefes egzersizi interstitial reklamı başarıyla gösterildi!');
          } else {
 if (kDebugMode) debugPrint('❌ Interstitial reklamı gösterilemedi');
          }
        } else {
 if (kDebugMode) debugPrint('⏰ Rate limiting nedeniyle reklam gösterilmiyor');
        }
      } else {
 if (kDebugMode) debugPrint('💎 Premium kullanıcı - Reklam gösterilmiyor');
      }

      // ✅ Reklam gösterildiyse popup'ı reklam kapatılınca göster
      // Reklam gösterilmediyse hemen kategori ekranına dön ve popup göster
      if (mounted) {
        if (adShown) {
 if (kDebugMode) debugPrint('🎊 Reklam gösterildi, popup reklam kapatılınca gösterilecek');
          // Reklam kapatılınca popup gösterilecek (AdMob callback'inde)
          final adProvider = AdManager.instance.provider;
          if (adProvider is AdMobProvider) {
            adProvider.setInterstitialDismissedCallback(() {
              if (mounted) {
 if (kDebugMode) debugPrint('🎊 Reklam kapatıldı, kategori ekranına dönülüyor...');
                // Önce kategori ekranına dön
                final breathingProvider = context.read<BreathingProvider>();
                breathingProvider.stop();
                
                // Confetti animasyonu başlat
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
 if (kDebugMode) debugPrint('🎊 Confetti animasyonu başlatılıyor...');
                    setState(() {
                      _isShowingConfetti = true;
                    });
                  }
                });
              }
            });
          }
        } else {
 if (kDebugMode) debugPrint('🎊 Reklam gösterilmedi, kategori ekranına dönülüyor...');
          // Reklam gösterilmediyse kategori ekranına dön
          final breathingProvider = context.read<BreathingProvider>();
          breathingProvider.stop();
          
          // Confetti animasyonu başlat
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
 if (kDebugMode) debugPrint('🎊 Confetti animasyonu başlatılıyor...');
              setState(() {
                _isShowingConfetti = true;
              });
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Session complete error: $e');
      // Hata durumunda da kategori ekranına dön
      if (mounted) {
 if (kDebugMode) debugPrint('🎊 Hata durumunda kategori ekranına dönülüyor...');
        // Önce BreathingProvider'ı temizle ve kategori ekranına dön
        final breathingProvider = context.read<BreathingProvider>();
        breathingProvider.stop();
        
        // Confetti animasyonu başlat (hata durumunda da)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
 if (kDebugMode) debugPrint('🎊 Hata durumunda confetti animasyonu başlatılıyor...');
            setState(() {
              _isShowingConfetti = true;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BreathingProvider>(
      builder: (context, breathingProvider, child) {
        if (breathingProvider.isRunning && breathingProvider.currentExercise != null) {
          // Aktif seans sırasında özel arkaplan kullanılır
          return _buildBreathingSession(context, breathingProvider);
        }
        
        // Interstisial loading ekranı
        if (_isLoadingInterstitial) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reklam yükleniyor...',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Kategori seçimi sırasında genel arkaplan kullanılır
        return PopScope(
          canPop: false, // Geri tuşunu engelle
          onPopInvoked: (didPop) {
            if (!didPop) {
              _handleBackNavigation(context, breathingProvider);
            }
          },
          child: GlobalBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: ProfessionalAppBar(
                scrollController: _scrollController, 
                title: 'Nefes Egzersizleri',
                // Özel geri tuşu callback'i
                onBackPressed: () => _handleBackNavigation(context, breathingProvider),
              ),
              body: Stack(
                children: [
                  // Ana kategori ekranı (her zaman gösterilir)
                  _buildCategorySelection(context),
                  // Konfeti animasyonu overlay (sadece gösterildiğinde)
                  if (_isShowingConfetti)
                    FullscreenConfettiWidget(
                      sessionType: breathingProvider.currentExercise?.name ?? 'Nefes Egzersizi',
                      duration: breathingProvider.actualSessionDurationMinutes,
                      onAnimationComplete: () {
                        // Confetti bittikten sonra overlay'i kaldır
                        if (mounted) {
                          setState(() {
                            _isShowingConfetti = false;
                          });
                          // BreathingProvider'ı temizle
                          final breathingProvider = context.read<BreathingProvider>();
                          breathingProvider.stop();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Geri tuşu davranışını yönetir
  void _handleBackNavigation(BuildContext context, BreathingProvider breathingProvider) {
    // Egzersiz tamamlandıysa direkt ana sayfaya dön - ⚡ ValueNotifier value
    if (_exerciseCompleted.value) {
 if (kDebugMode) debugPrint('🎯 Egzersiz tamamlandı - Ana sayfaya dönülüyor...');
      
      // BreathingProvider'ı temizle
      breathingProvider.stop();
      
      // Navigation stack'i temizle ve ana sayfaya dön
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
        (route) => false, // Tüm önceki route'ları kaldır
      );
    } else {
      // Normal geri tuşu davranışı
      Navigator.of(context).pop();
    }
  }

  Widget _buildCategorySelection(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + kToolbarHeight + 20, 20, 10),
          sliver: SliverToBoxAdapter(
            // ⚡ PERFORMANCE: FadeInDown kaldırıldı - anında görünür
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.breathingExercises,
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Stres, uyku veya odaklanma. İhtiyacın olanı seç.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.large),
                _buildProgressIndicator(),
                const SizedBox(height: AppSpacing.large),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.odaklanma,
                  title: 'Odaklanma & Konsantrasyon',
                  subtitle: 'Dikkatini tek bir noktaya yönlendir, düşüncelerini toparla',
                  overlayColor: AppColors.focus,
                  background: Image.asset(
                    AssetManager.coverForest,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.kaygiVeStres,
                  title: 'Rahatlama & Huzur',
                  subtitle: 'Derin bir nefesle gerginliği bırak ve bedenini gevşet',
                  overlayColor: AppColors.relaxation,
                  background: Image.asset(
                    AssetManager.coverOcean,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.uykuVeRahatlama,
                  title: 'Huzurlu Uyku',
                  subtitle: 'Bedenini ve zihnini dinlendir, yavaşça gevşe',
                  overlayColor: AppColors.sleep,
                  background: Lottie.asset(
                    AssetManager.animationNightBackground,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: AppSpacing.xLarge),
                _buildCategoryCard(
                  context,
                  category: BreathingCategory.enerjiVeCanlilik,
                  title: 'Enerji & Zindelik',
                  subtitle: 'İçindeki enerjiyi uyandır ve günün tadını çıkar',
                  overlayColor: AppColors.energy,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.energy, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    // ⚡ PERFORMANCE: Use Selector to rebuild only when stats change
    return Selector<UserPreferencesProvider, ({int streak, int weeklyGoal, int completed, int todaySessions})>(
      selector: (context, prefs) => (
        streak: prefs.currentStreak,
        weeklyGoal: prefs.weeklyGoal,
        completed: prefs.completedSessionsThisWeek,
        todaySessions: prefs.todaySessionsCount, // 🆕 Bugünkü seans sayısı
      ),
      builder: (context, stats, child) {
        final streak = stats.streak;
        final weeklyGoal = stats.weeklyGoal;
        final completedThisWeek = stats.completed;
        final todaySessions = stats.todaySessions;
        final weeklyProgress = weeklyGoal > 0 ? (completedThisWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;
        
        // ⚡ PERFORMANCE: FadeInUp kaldırıldı - anında görünür
        return Column(
            children: [
              // 🆕 Günlük İlerleme Mesajı (Boş state dahil)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: ProfessionalCard(
                  cardType: CardType.glass,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.small),
                        decoration: BoxDecoration(
                          gradient: todaySessions > 0 
                              ? LinearGradient(
                                  colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Icon(
                          todaySessions > 0 ? Icons.celebration : Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todaySessions > 0 
                                  ? 'Bugün $todaySessions seans yaptın!'
                                  : '🌟 Bugün henüz seans yapmadın',
                              style: AppTypography.labelLarge.copyWith(
                                color: todaySessions > 0 
                                    ? AppColors.success 
                                    : AppColors.primaryAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getTodayMotivationMessage(todaySessions),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Mevcut İstatistikler
              ProfessionalCard(
                cardType: CardType.glass,
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Günlük Seri
                    _buildProgressItem(
                      icon: '🔥',
                      value: '$streak',
                      label: 'Günlük Seri',
                      subtitle: streak > 0 ? 'Harika gidiyorsun!' : 'Başlayalım!',
                      color: AppColors.energy,
                    ),
                    
                    // Ayırıcı çizgi
                    Container(
                      height: 60,
                      width: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.glassBorder.withOpacity(0.1),
                            AppColors.glassBorder.withOpacity(0.3),
                            AppColors.glassBorder.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    
                    // Haftalık Hedef
                    _buildProgressItem(
                      icon: null,
                      value: '$completedThisWeek/$weeklyGoal',
                      label: 'Bu Hafta (Pzt-Paz)', // ✅ Açıklayıcı başlık
                      subtitle: '${(weeklyProgress * 100).round()}% tamamlandı',
                      color: AppColors.focus,
                      progressValue: weeklyProgress,
                    ),
                  ],
                ),
              ),
            ],
        );
      },
    );
  }
  
  /// 🆕 Bugünkü seans sayısına göre motivasyon mesajı
  String _getTodayMotivationMessage(int sessions) {
    if (sessions == 0) {
      // ✅ Boş state için motivasyonlu mesaj
      return 'İlk adımı at ve kendine zaman ayır! Hazırsan aşağıdan bir egzersiz seç 💙';
    } else if (sessions == 1) {
      return 'Harika bir başlangıç! Devam et 🌟';
    } else if (sessions == 2) {
      return 'İki seans! Bugün harikasın 💪';
    } else if (sessions >= 3) {
      return 'Müthişsin! $sessions seans yaptın 🎉';
    }
    return 'Devam et!';
  }

  Widget _buildProgressItem({
    String? icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
    double? progressValue,
  }) {
    return Expanded(
      child: Column(
        children: [
          // İkon veya Progress Circle
          if (icon != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            )
          else if (progressValue != null)
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 4,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Icon(
                    FeatherIcons.target,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: AppSpacing.medium),
          
          // Değer
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: AppSpacing.tiny),
          
          // Label
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.tiny),
          
          // Subtitle
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required BreathingCategory category,
    required String title,
    required String subtitle,
    required Color overlayColor,
    required Widget background,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth < 400 ? 160.0 : (screenWidth < 500 ? 170.0 : 180.0);
    
    // ⚡ PERFORMANCE: FadeInUp kaldırıldı - category cards anında görünür
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExerciseListScreen(category: category, heroTag: title),
          ));
        },
        child: Container(
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4), // Side margins
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: overlayColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Stack(
              children: [
                // Arkaplan
                Positioned.fill(child: background),

                // ⚡ BackdropFilter kaldırıldı - GPU performansı için
                // Gradient overlay okunabilirlik için yeterli
                
                // Minimal gradyan overlay - Okunabilirlik için
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      gradient: LinearGradient(
                        colors: [
                          overlayColor.withOpacity(0.1), // 0.2'den 0.1'e düşürüldü
                          overlayColor.withOpacity(0.15), // 0.3'ten 0.15'e düşürüldü
                          Colors.black.withOpacity(0.15), // 0.25'ten 0.15'e düşürüldü
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Glassmorphism border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),

                // İçerik
                Padding(
                  padding: EdgeInsets.all(screenWidth < 400 ? 12.0 : (screenWidth < 500 ? 14.0 : AppSpacing.large)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üst kısım - Kategori ikonu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth < 400 ? 6 : 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: Colors.white,
                              size: screenWidth < 400 ? 16 : 20,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(screenWidth < 400 ? 4 : 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              FeatherIcons.arrowRight,
                              color: Colors.white.withOpacity(0.9),
                              size: screenWidth < 400 ? 14 : 18,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Alt kısım - Başlık ve açıklama
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth < 400 ? 18 : (screenWidth < 500 ? 20 : 24),
                              shadows: [
                                const Shadow(blurRadius: 15, color: Colors.black), // Çok güçlü shadow
                                const Shadow(blurRadius: 8, color: Colors.black87),
                                const Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500, // Biraz daha kalın
                              fontSize: screenWidth < 400 ? 12 : (screenWidth < 500 ? 13 : 14),
                              shadows: [
                                const Shadow(blurRadius: 12, color: Colors.black), // Çok güçlü shadow
                                const Shadow(blurRadius: 6, color: Colors.black87),
                                const Shadow(blurRadius: 3, color: Colors.black54),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

  Widget _buildBreathingSession(BuildContext context, BreathingProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2000), // 2 saniye yumuşak geçiş
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(provider),
      ),
      child: Stack(
        children: [
          // Ana animasyon alanı - tam ekran
          BreathingAnimation(
            provider: provider,
          ),
          
          // Üst kontroller - overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
                      onPressed: () {
                        try {
                          Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
                        } catch (e) {
                          if (kDebugMode) print('AudioProvider stop error: $e');
                        }
                        provider.stop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.currentExercise?.name ?? '',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(FeatherIcons.music, color: Colors.white),
                      onPressed: () {
                        _showSoundSelectionModal(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Alt kontroller - overlay
          if (provider.isRunning)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    children: [
                      // İlerleme bilgisi
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.completedCycles} / ${provider.totalCycles} Tekrar',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // İlerleme çubuğu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LinearProgressIndicator(
                          value: provider.totalCycles > 0
                              ? provider.completedCycles / provider.totalCycles
                              : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Pause/Resume butonu
                      FloatingActionButton(
                        onPressed: () {
                          if (provider.isPaused) {
                            provider.resume();
                          } else {
                            provider.pause();
                          }
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        child: Icon(
                          provider.isPaused ? FeatherIcons.play : FeatherIcons.pause,
                          size: MediaQuery.of(context).size.width < 400 ? 24 : 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Nefes durumuna göre arkaplan gradyanı
  LinearGradient _getBackgroundGradient(BreathingProvider provider) {
    final currentStep = provider.currentStep;
    if (currentStep == null) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary, AppColors.primaryBackground],
      );
    }

    switch (currentStep.type) {
      case BreathingStepType.inhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.focus.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.hold:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.focus.withOpacity(0.7),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.exhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.relaxation.withOpacity(0.8),
            AppColors.sleep.withOpacity(0.6),
            AppColors.primaryBackground,
          ],
        );
      case BreathingStepType.holdAfterExhale:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sleep.withOpacity(0.9),
            AppColors.relaxation.withOpacity(0.7),
            AppColors.primaryBackground,
          ],
        );
    }
  }

  void _showSoundSelectionModal(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    // Doğa seslerini doğru şekilde filtrele
    final natureSounds = SoundItem.allCategories
        .firstWhere((cat) => cat.id == 'nature')
        .sounds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 400;
            final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
            
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSmallScreen ? 20 : 24),
                  topRight: Radius.circular(isSmallScreen ? 20 : 24),
                ),
                border: Border.all(color: AppColors.glassBorder.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dragger
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Başlık
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? AppSpacing.medium : AppSpacing.large,
                      vertical: isSmallScreen ? AppSpacing.small : AppSpacing.medium,
                    ),
                    child: Text(
                      'Arkaplan Sesi Seç',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.small),
                  
                  // Scroll edilebilir içerik
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? AppSpacing.medium : AppSpacing.large,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: isSmallScreen ? 6 : AppSpacing.small,
                            runSpacing: isSmallScreen ? 6 : AppSpacing.small,
                            children: natureSounds.map((sound) {
                      final isPlaying = audioProvider.isPlaying(sound.id);
                      final isSelected = selectedSoundId == sound.id;

                      return ActionChip(
                        avatar: Icon(
                          sound.icon,
                          size: isSmallScreen ? 18 : 20,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        label: Text(
                          sound.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : (isMediumScreen ? 14 : 15),
                          ),
                        ),
                        backgroundColor: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.surfaceElevated,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 4 : 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : AppSpacing.medium),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.border.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          // Sadece bir sesin çalmasını sağla
                          // Önce tüm diğer sesleri durdur
                          audioProvider.stopAllSounds();

                          modalState(() {
                            if (isSelected) {
                              // Zaten seçiliyse, seçimi kaldır ve sesi durdur
                              selectedSoundId = null;
                            } else {
                              // Yeni bir ses seç, eskisini durdur ve yenisini çal
                              selectedSoundId = sound.id;
                              audioProvider.toggleMixerSound(sound);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: isSmallScreen ? AppSpacing.medium : AppSpacing.large),
                  // Sessizlik seçeneği
                  Container(
                    decoration: BoxDecoration(
                      color: selectedSoundId == null 
                          ? AppColors.primaryAccent.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : AppSpacing.medium),
                      border: Border.all(
                        color: selectedSoundId == null 
                            ? AppColors.primaryAccent
                            : AppColors.border.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: 4,
                      ),
                      leading: Icon(
                        FeatherIcons.volumeX, 
                        color: selectedSoundId == null 
                            ? AppColors.primaryAccent
                            : AppColors.textSecondary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      title: Text(
                        'Sessizlik',
                        style: AppTypography.bodyLarge.copyWith(
                          color: selectedSoundId == null 
                              ? AppColors.primaryAccent
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                        ),
                      ),
                      onTap: (){
                        audioProvider.stopAllSounds();
                        modalState(() {
                          selectedSoundId = null;
                        });
                      },
                      trailing: selectedSoundId == null 
                        ? Icon(
                            FeatherIcons.check, 
                            color: AppColors.primaryAccent,
                            size: isSmallScreen ? 20 : 24,
                          )
                        : null,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? AppSpacing.medium : AppSpacing.large),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 
