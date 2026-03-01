import 'dart:async';
import 'dart:ui'; // ImageFilter için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // groupBy için
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../widgets/professional_app_bar.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/breathing_animation.dart';
import '../widgets/session_completion_dialog.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'exercise_list_screen.dart'; // Bu dosya bir sonraki adımda oluşturulacak
import '../providers/audio_provider.dart';
import '../models/sound_item.dart';
import '../providers/exercise_tracking_provider.dart';
import '../core/ads/ad_manager.dart';
import '../core/ads/admob_provider.dart';
import '../widgets/global_background.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import 'main_navigation_screen.dart';
import '../data/mood_presets.dart';

class BreathingScreen extends StatefulWidget {
  final MoodPreset? moodPreset;
  
  const BreathingScreen({super.key, this.moodPreset});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  late final ScrollController _scrollController;
  String? selectedSoundId;
  bool _isLoadingInterstitial = false; // Interstisial yüklenirken loading
  final ValueNotifier<bool> _exerciseCompleted = ValueNotifier(false); // ⚡ ValueNotifier - optimized rebuild
  
  // Auto-hide kontrol paneli
  bool _controlsVisible = true;
  Timer? _autoHideTimer;
  bool _isImmersive = false; // Tam ekran modu takibi

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Mood preset'ten geliyorsa, default sesi selectedSoundId'ye ata
    if (widget.moodPreset != null) {
      final provider = context.read<BreathingProvider>();
      final currentType = provider.currentExercise?.type;
      if (currentType != null) {
        selectedSoundId = widget.moodPreset!.getSoundForExercise(currentType);
      } else {
        selectedSoundId = widget.moodPreset!.defaultSoundId;
      }
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final breathingProvider = context.read<BreathingProvider>();
      breathingProvider.setOnSessionCompleted(() {
        _onSessionCompleted(breathingProvider);
      });
      
      // Reklamı erkenden yükle
      _preloadInterstitialAd();
    });
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _startAutoHideTimer();
  }

  void _exitImmersiveMode() {
    if (_isImmersive) {
      _isImmersive = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _exitImmersiveMode();
    _autoHideTimer?.cancel();
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
        // Yeni API ile preload
        AdManager.instance.preloadInterstitial(placement: 'breathing_session_complete');
      }
    } catch (e) {
 if (kDebugMode) debugPrint('❌ Reklam önceden yüklenemedi: $e');
    }
  }

  void _onSessionCompleted(BreathingProvider provider) async {
    if (!mounted) return;
    
    final currentExercise = provider.currentExercise;
    if (currentExercise == null) return;
    
    // Session bilgilerini stop() öncesinde kaydet
    final sessionName = currentExercise.name;
    final sessionDurationMin = provider.actualSessionDurationMinutes;
    
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

      // 🎯 Egzersiz bitiminde reklam göster
      bool adShown = false;
      if (!premiumProvider.canAccessFeature('ad_free')) {
        final exerciseTrackingProvider = context.read<ExerciseTrackingProvider>();
        
        if (kDebugMode) debugPrint('🎯 Egzersiz tamamlandı - Reklam kontrolü başlıyor...');
        
        // Egzersiz tamamlanınca HER ZAMAN reklam kontrolü yap (Rate limit AdManager içinde zaten var)
        // Ancak kullanıcı deneyimi için sadece belirli durumlarda göster
        // Burada: Egzersiz tamamen bittiği için gösterim yapıyoruz.
        
        if (exerciseTrackingProvider.shouldShowCompletionInterstitial()) {
           if (kDebugMode) debugPrint('✅ Reklam gösterim onayı alındı - Loading ekranı gösteriliyor...');
           
           // Loading ekranını göster
           if (mounted) {
             setState(() {
               _isLoadingInterstitial = true;
             });
           }
 
           // 🛠️ FIX: Reklamı göstermeden ÖNCE callback'i ayarla
           final adProvider = AdManager.instance.provider;
           if (adProvider is AdMobProvider) {
             adProvider.setInterstitialDismissedCallback(() {
               if (mounted) {
                 if (kDebugMode) debugPrint('🎊 Reklam kapatıldı, tebrikler dialog\'u gösteriliyor...');
                 // Tebrikler dialog'unu göster
                 Future.delayed(const Duration(milliseconds: 300), () {
                   if (mounted) {
                     SessionCompletionDialog.show(
                       context,
                       sessionType: sessionName,
                       duration: sessionDurationMin,
                     ).then((_) {
                       if (mounted) {
                         try { context.read<AudioProvider>().stopAllSounds(); } catch (_) {}
                         context.read<BreathingProvider>().stop();
                       }
                     });
                   }
                 });
               }
             });
           }
           
           // Kısa bir gecikme
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
             // Provider'a reklam gösterildiğini bildir
             exerciseTrackingProvider.markAdShown();
           } else {
             if (kDebugMode) debugPrint('❌ Interstitial reklamı gösterilemedi');
           }
        } else {
          if (kDebugMode) debugPrint('⏰ Rate limiting nedeniyle reklam gösterilmiyor');
        }
      } else {
        if (kDebugMode) debugPrint('💎 Premium kullanıcı - Reklam gösterilmiyor');
      }

      // ✅ Reklam GÖSTERİLMEDİYSE popup'ı hemen göster
      // Reklam gösterildiyse, yukarıdaki callback çalışacak
      if (mounted && !adShown) {
        if (kDebugMode) debugPrint('🎊 Reklam gösterilmedi (veya gerekmedi), tebrikler dialog\'u gösteriliyor...');
        // Tebrikler dialog'unu göster
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            SessionCompletionDialog.show(
              context,
              sessionType: sessionName,
              duration: sessionDurationMin,
            ).then((_) {
              if (mounted) {
                try { context.read<AudioProvider>().stopAllSounds(); } catch (_) {}
                context.read<BreathingProvider>().stop();
              }
            });
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ Session complete error: $e');
      // Hata durumunda da kategori ekranına dön
      if (mounted) {
 if (kDebugMode) debugPrint('🎊 Hata durumunda tebrikler dialog\'u gösteriliyor...');
        // Tebrikler dialog'unu göster (hata durumunda da)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            SessionCompletionDialog.show(
              context,
              sessionType: sessionName,
              duration: sessionDurationMin,
            ).then((_) {
              if (mounted) {
                try { context.read<AudioProvider>().stopAllSounds(); } catch (_) {}
                context.read<BreathingProvider>().stop();
              }
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
          // Tam ekran modu — status bar ve nav bar gizle
          if (!_isImmersive) {
            _isImmersive = true;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          }
          // Aktif seans sırasında özel arkaplan kullanılır
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                _exitImmersiveMode();
                try {
                  Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
                } catch (_) {}
                breathingProvider.stop();
                Navigator.of(context).pop();
              }
            },
            child: _buildBreathingSession(context, breathingProvider),
          );
        }
        
        // Egzersiz bittiyse immersive modu kapat
        if (_isImmersive) {
          _exitImmersiveMode();
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
                    AppStrings.loadingAd,
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
          onPopInvokedWithResult: (didPop, _) {
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
                title: AppStrings.breathingExercisesScreenTitle,
                // Özel geri tuşu callback'i
                onBackPressed: () => _handleBackNavigation(context, breathingProvider),
              ),
              body: _buildCategorySelection(context),
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
      
      // Sesleri ve egzersizi durdur
      try { context.read<AudioProvider>().stopAllSounds(); } catch (_) {}
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

  /// Koleksiyon tanımları — aynı egzersiz birden fazla koleksiyonda (Netflix derinliği)
  List<_ExerciseCollection> _getCollections() {
    final all = BreathingExercise.allExercises;
    
    // Type'a göre egzersiz bul (null-safe)
    BreathingExercise? _find(BreathingType type) {
      try { return all.firstWhere((e) => e.type == type); } catch (_) { return null; }
    }

    return [
      _ExerciseCollection(
        title: AppStrings.collectionPanic,
        icon: FeatherIcons.alertCircle,
        color: AppColors.relaxation,
        exercises: [_find(BreathingType.custom), _find(BreathingType.extendedExhale), _find(BreathingType.boxBreathing)]
            .whereType<BreathingExercise>().toList(),
        badge: '2 dk',
      ),
      _ExerciseCollection(
        title: AppStrings.collectionQuickRelief,
        icon: FeatherIcons.heart,
        color: AppColors.relaxation,
        exercises: [_find(BreathingType.diaphragmaticBreathing), _find(BreathingType.samaVritti), _find(BreathingType.deepBreathing)]
            .whereType<BreathingExercise>().toList(),
      ),
      _ExerciseCollection(
        title: AppStrings.collectionSleepTransition,
        icon: FeatherIcons.moon,
        color: AppColors.sleep,
        exercises: [_find(BreathingType.moonBreathing), _find(BreathingType.bodyScan), _find(BreathingType.progressiveRelaxation)]
            .whereType<BreathingExercise>().toList(),
      ),
      _ExerciseCollection(
        title: AppStrings.collectionMindClear,
        icon: FeatherIcons.target,
        color: AppColors.focus,
        exercises: [_find(BreathingType.boxBreathing), _find(BreathingType.custom), _find(BreathingType.deepBreathing)]
            .whereType<BreathingExercise>().toList(),
      ),
      _ExerciseCollection(
        title: AppStrings.collectionEnergyBoost,
        icon: FeatherIcons.zap,
        color: AppColors.energy,
        exercises: [_find(BreathingType.energizing), _find(BreathingType.vitalizing), _find(BreathingType.samaVritti)]
            .whereType<BreathingExercise>().toList(),
      ),
    ];
  }

  // _getFilteredCollections kaldırıldı — chip filter artık yok

  /// Quick Start için rastgele egzersiz öner (saat bazlı) - ÖNCELİKLE ÜCRETSİZ
  BreathingExercise _getQuickStartExercise() {
    final hour = DateTime.now().hour;
    final all = BreathingExercise.allExercises;
    
    // 🧠 SMART SELECTION: Ücretsiz egzersizleri filtrele
    final freeExercises = all.where((e) => !e.isPremium).toList();
    // Eğer ücretsiz yoksa (imkansız ama) hepsini kullan
    final targetList = freeExercises.isNotEmpty ? freeExercises : all;

    if (hour >= 22 || hour < 6) {
      // Gece → uyku egzersizi
      return targetList.firstWhere((e) => e.category == BreathingCategory.uykuVeRahatlama, orElse: () => targetList.first);
    } else if (hour >= 6 && hour < 10) {
      // Sabah → enerji
      return targetList.firstWhere((e) => e.category == BreathingCategory.enerjiVeCanlilik, orElse: () => targetList.first);
    } else if (hour >= 10 && hour < 17) {
      // Gündüz → odak
      return targetList.firstWhere((e) => e.category == BreathingCategory.odaklanma, orElse: () => targetList.first);
    } else {
      // Akşam → rahatlama
      return targetList.firstWhere((e) => e.category == BreathingCategory.kaygiVeStres, orElse: () => targetList.first);
    }
  }

  String _getQuickStartMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 6) return AppStrings.quickStartRelax;
    if (hour >= 6 && hour < 10) return AppStrings.quickStartEnergy;
    if (hour >= 10 && hour < 17) return AppStrings.quickStartFocus;
    return AppStrings.quickStartUnwind;
  }

  Widget _buildCategorySelection(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final allExercises = BreathingExercise.allExercises;
    final collections = _getCollections();

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Başlık + Alt başlık
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + kToolbarHeight + 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.practiceScreenTitle,
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  AppStrings.practiceScreenSubtitle,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // Quick Start Kartı
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildQuickStartCard()),
        ),

        // Progress Indicator
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildProgressIndicator()),
        ),

        // Koleksiyonlar
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCollectionSection(collections[index]),
              childCount: collections.length,
            ),
          ),
        ),

        // Tüm Pratikler linki
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          sliver: SliverToBoxAdapter(child: _buildPracticeLibraryLink(allExercises.length)),
        ),
      ],
    );
  }

  // _buildChipFilter kaldırıldı — chip filter artık yok

  /// 🔥 Quick Start — "Bugün Sana İyi Gelecek" büyük kart
  Widget _buildQuickStartCard() {
    final exercise = _getQuickStartExercise();
    final message = _getQuickStartMessage();
    final durationMin = (exercise.totalCycleTime * 5 / 60).ceil().clamp(1, 5);

    return GestureDetector(
      onTap: () {
        // Güvenlik kontrolü (Eğer ücretsiz bulunamazsa)
        if (exercise.isPremium) {
           final premiumProvider = context.read<PremiumProvider>();
           // FIX: all_exercises -> featurePremiumExercises (gerçi burada canAccessPremiumContent kullanılıyor bu doğru)
           if (!premiumProvider.canAccessPremiumContent(true)) {
               final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
                (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
                orElse: () => PremiumTrigger.predefinedTriggers.first,
              );
              SmartPremiumDialog.show(context, trigger);
              return;
           }
        }
        _showDurationSelectionModal(context, exercise, AppColors.primaryAccent);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryAccent.withOpacity(0.25),
              AppColors.primaryAccent.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.quickStartTitle,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.name} · $durationMin ${AppStrings.minuteShort}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    AppStrings.quickStartButton,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            
            // PRO Badge
            if (exercise.isPremium)
              Consumer<PremiumProvider>(
                builder: (context, premium, _) {
                  if (premium.isPremiumUser) return const SizedBox.shrink();
                  return Positioned(
                    top: 0,
                    right: 48, // Butonun soluna gelsin diye ayarladım ama buton sağda. 
                    // Aslında başlığın sağına koysak daha iyi olur ya da sağ üst köşeye.
                    // Row yapısı var, stack ile sarmaladım. Sağ üst köşe butonun üstüne gelebilir.
                    // En iyisi sol üst köşeye (icon gibi) veya başlığın yanına.
                    // Stack kullandım, sağ üst (butonun üstünde olmasın diye ayarlama gerekebilir).
                    // Basitlik için en sağ üste koyuyorum.
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
          ],
        ),
      ),
    );
  }

  /// 📦 Koleksiyon bölümü — başlık + yatay kaydırmalı egzersiz kartları
  Widget _buildCollectionSection(_ExerciseCollection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            collection.title,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: collection.exercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildCollectionExerciseCard(collection.exercises[index], collection.color);
            },
          ),
        ),
      ],
    );
  }

  /// 🎴 Koleksiyon içi egzersiz kartı — görsel + gradient overlay
  Widget _buildCollectionExerciseCard(BreathingExercise exercise, Color accentColor) {
    return GestureDetector(
      onTap: () {
        final premiumProvider = context.read<PremiumProvider>();
        // FIX: 'all_exercises' -> featurePremiumExercises
        if (exercise.isPremium && !premiumProvider.canAccessFeature(PremiumProvider.featurePremiumExercises)) {
          final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
            (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
            orElse: () => PremiumTrigger.predefinedTriggers.first,
          );
          SmartPremiumDialog.show(context, trigger);
          return;
        }
        _showDurationSelectionModal(context, exercise, accentColor);
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Arkaplan görseli
              Positioned.fill(
                child: Image.asset(
                  exercise.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: accentColor.withOpacity(0.2),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // PRO badge (sağ üst)
              if (exercise.isPremium)
                Consumer<PremiumProvider>(
                  builder: (context, premium, _) {
                    if (premium.isPremiumUser) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      right: 8,
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
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              // İsim (alt)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  exercise.name,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      const Shadow(blurRadius: 6, color: Colors.black),
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

  IconData _getExerciseIcon(BreathingType type) {
    switch (type) {
      case BreathingType.boxBreathing: return FeatherIcons.square;
      case BreathingType.custom: return FeatherIcons.hash;
      case BreathingType.deepBreathing: return FeatherIcons.eye;
      case BreathingType.extendedExhale: return FeatherIcons.wind;
      case BreathingType.diaphragmaticBreathing: return FeatherIcons.circle;
      case BreathingType.samaVritti: return FeatherIcons.minimize2;
      case BreathingType.moonBreathing: return FeatherIcons.moon;
      case BreathingType.bodyScan: return FeatherIcons.search;
      case BreathingType.progressiveRelaxation: return FeatherIcons.sunset;
      case BreathingType.energizing: return FeatherIcons.sunrise;
      case BreathingType.vitalizing: return FeatherIcons.zap;
      case BreathingType.stimulatingBreath: return FeatherIcons.activity;
      default: return FeatherIcons.wind;
    }
  }

  /// 📚 Tüm Pratikler linki — minimal, en altta
  Widget _buildPracticeLibraryLink(int totalCount) {
    return GestureDetector(
      onTap: () {
        // Tüm egzersizleri gösteren ExerciseListScreen'e git (ilk kategori ile)
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ExerciseListScreen(
            heroTag: AppStrings.practiceLibraryLink,
          ),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(FeatherIcons.grid, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.practiceLibraryLink,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(FeatherIcons.chevronRight, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Selector<UserPreferencesProvider, ({int streak, int weeklyGoal, int completed})>(
      selector: (context, prefs) => (
        streak: prefs.currentStreak,
        weeklyGoal: prefs.weeklyGoal,
        completed: prefs.completedSessionsThisWeek,
      ),
      builder: (context, stats, child) {
        final streak = stats.streak;
        final weeklyGoal = stats.weeklyGoal;
        final completedThisWeek = stats.completed;
        final weeklyProgress = weeklyGoal > 0 ? (completedThisWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // 🔥 Streak
              Text('🔥', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.energy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.dailyStreakLabel,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              
              // Ayırıcı
              Container(
                height: 16,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white.withOpacity(0.15),
              ),
              
              // 🎯 Haftalık
              Icon(FeatherIcons.target, color: AppColors.focus, size: 16),
              const SizedBox(width: 6),
              Text(
                '$completedThisWeek/$weeklyGoal',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.focus,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${(weeklyProgress * 100).round()}%',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // _buildCategoryCard ve _getCategoryIcon kaldırıldı — koleksiyon bazlı yapıya geçildi

  Widget _buildBreathingSession(BuildContext context, BreathingProvider provider) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    // İlk build'de auto-hide timer'ı başlat
    if (_controlsVisible && _autoHideTimer == null) {
      _startAutoHideTimer();
    }
    
    return GestureDetector(
      onTap: _showControls,
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 2000),
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
            
            // Üst kontroller - glassmorphism overlay (auto-hide)
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Geri butonu — glassmorphism circle
                        _buildGlassButton(
                          icon: FeatherIcons.arrowLeft,
                          onPressed: () {
                            _exitImmersiveMode();
                            try {
                              Provider.of<AudioProvider>(context, listen: false).stopAllSounds();
                            } catch (e) {
                              if (kDebugMode) print('AudioProvider stop error: $e');
                            }
                            provider.stop();
                            Navigator.of(context).pop();
                          },
                          size: isSmallScreen ? 40 : 44,
                        ),
                        
                        // Egzersiz adı — pill
                        Flexible(
                          child: GestureDetector(
                            onTap: widget.moodPreset != null
                                ? () => _switchToNextExercise(context, provider)
                                : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 14 : 18,
                                vertical: isSmallScreen ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      provider.currentExercise?.name ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                        fontSize: isSmallScreen ? 13 : 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (widget.moodPreset != null) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      FeatherIcons.refreshCw,
                                      color: Colors.white.withOpacity(0.6),
                                      size: isSmallScreen ? 12 : 14,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Müzik butonu — ses aktifse teal renk
                        _buildGlassButton(
                          icon: FeatherIcons.music,
                          onPressed: () => _showSoundSelectionModal(context),
                          size: isSmallScreen ? 40 : 44,
                          isActive: selectedSoundId != null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Alt kontroller - overlay (auto-hide)
            if (provider.isRunning)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isSmallScreen ? 16 : 24,
                          0,
                          isSmallScreen ? 16 : 24,
                          isSmallScreen ? 24 : 36,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Süre bilgisi pill — geçen süre / toplam tahmini süre
                            Builder(
                              builder: (context) {
                                final elapsedSec = provider.actualSessionDurationSeconds;
                                final elapsedMin = elapsedSec ~/ 60;
                                final elapsedSecRem = elapsedSec % 60;
                                
                                // Toplam tahmini süre
                                final cycleTime = provider.currentExercise?.totalCycleTime ?? 0;
                                final totalEstSec = provider.totalCycles * cycleTime;
                                final totalEstMin = totalEstSec ~/ 60;
                                final totalEstSecRem = totalEstSec % 60;
                                
                                final elapsed = '${elapsedMin.toString().padLeft(2, '0')}:${elapsedSecRem.toString().padLeft(2, '0')}';
                                final total = '${totalEstMin.toString().padLeft(2, '0')}:${totalEstSecRem.toString().padLeft(2, '0')}';
                                
                                // Progress: süre bazlı
                                final progress = totalEstSec > 0
                                    ? (elapsedSec / totalEstSec).clamp(0.0, 1.0)
                                    : (provider.totalCycles > 0
                                        ? (provider.completedCycles / provider.totalCycles).clamp(0.0, 1.0)
                                        : 0.0);
                                
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 14 : 18,
                                        vertical: isSmallScreen ? 6 : 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            FeatherIcons.clock,
                                            color: Colors.white.withOpacity(0.7),
                                            size: isSmallScreen ? 13 : 15,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$elapsed / $total',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              decoration: TextDecoration.none,
                                              fontSize: isSmallScreen ? 13 : 14,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // İnce progress bar — süre bazlı
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.white.withOpacity(0.12),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          minHeight: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Pause/Resume butonu — frosted glass
                            GestureDetector(
                              onTap: () {
                                final audioProvider = context.read<AudioProvider>();
                                if (provider.isPaused) {
                                  provider.resume();
                                  audioProvider.resumeAll();
                                } else {
                                  provider.pause();
                                  audioProvider.pauseAll();
                                }
                                _showControls(); // Dokunma sonrası timer'ı sıfırla
                              },
                              child: Container(
                                width: isSmallScreen ? 56 : 64,
                                height: isSmallScreen ? 56 : 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  provider.isPaused ? FeatherIcons.play : FeatherIcons.pause,
                                  color: Colors.white,
                                  size: isSmallScreen ? 24 : 28,
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
          ],
        ),
      ),
    );
  }

  /// Glassmorphism circle button helper
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 44,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? const Color(0xFF4ECDC4).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isActive
                ? const Color(0xFF4ECDC4).withOpacity(0.5)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF4ECDC4) : Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }

  // Nefes durumuna göre arkaplan gradyanı — daha belirgin, immersive
  LinearGradient _getBackgroundGradient(BreathingProvider provider) {
    final currentStep = provider.currentStep;
    if (currentStep == null) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1628), // Koyu navy
          Color(0xFF0D1117), // Çok koyu
        ],
      );
    }

    switch (currentStep.type) {
      case BreathingStepType.inhale:
        // Teal/Cyan tonları — halka rengiyle uyumlu
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2B3E), // Koyu teal
            Color(0xFF0A1E2C), // Orta koyu
            Color(0xFF0D1117), // Çok koyu
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case BreathingStepType.hold:
        // Amber/Gold tonları — sıcak, sakin
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A1F0A), // Koyu amber
            Color(0xFF1A1408), // Orta koyu
            Color(0xFF0D1117), // Çok koyu
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case BreathingStepType.exhale:
        // Mavi/İndigo tonları — soğuk, rahatlatıcı
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F1B3D), // Koyu indigo
            Color(0xFF0C1429), // Orta koyu
            Color(0xFF0D1117), // Çok koyu
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case BreathingStepType.holdAfterExhale:
        // Mor tonları — derin, huzurlu
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0D2E), // Koyu mor
            Color(0xFF120A1F), // Orta koyu
            Color(0xFF0D1117), // Çok koyu
          ],
        );
    }
  }

  /// 🔄 Otomatik sıradaki egzersize geç — bottom sheet yok, direkt kayar
  void _switchToNextExercise(BuildContext context, BreathingProvider provider) {
    final preset = widget.moodPreset;
    if (preset == null) return;

    // Mood'a uygun tüm egzersizleri al
    final exerciseTypes = preset.allExercises;
    final exercises = exerciseTypes
        .map((type) => BreathingExercise.allExercises
            .where((e) => e.type == type)
            .firstOrNull)
        .where((e) => e != null)
        .cast<BreathingExercise>()
        .toList();

    if (exercises.length < 2) return;

    // Mevcut egzersizin index'ini bul
    final currentType = provider.currentExercise?.type;
    int currentIndex = exercises.indexWhere((e) => e.type == currentType);
    if (currentIndex == -1) currentIndex = 0;

    // Sıradaki egzersize geç (döngüsel)
    final nextIndex = (currentIndex + 1) % exercises.length;
    final nextExercise = exercises[nextIndex];

    // Mevcut döngü sayısını koru
    final currentCycles = provider.totalCycles > 0 ? provider.totalCycles : 10;

    // Egzersizi değiştir
    provider.stop();
    provider.setExercise(nextExercise, customCycles: currentCycles);
    provider.start();

    // Sesi de değiştir + selectedSoundId güncelle
    final newSoundId = preset.getSoundForExercise(nextExercise.type);
    setState(() {
      selectedSoundId = newSoundId;
    });
    try {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.stopAllSounds();
      final sound = SoundItem.allSounds.firstWhere(
        (s) => s.id == newSoundId,
        orElse: () => SoundItem.allSounds.first,
      );
      audioProvider.playExclusive(sound);
    } catch (e) {
      // Ses değiştirilemezse sessizce geç
    }
  }

  void _showSoundSelectionModal(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    final allCategories = SoundItem.allCategories;

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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E).withOpacity(0.97),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          FeatherIcons.music,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.selectBackgroundSound,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Scroll edilebilir içerik — kategoriler ve sesler
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Her kategori için sesler
                          ...allCategories.map((category) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kategori başlığı
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        category.icon,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Ses chip'leri
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: category.sounds.map((sound) {
                                    final isSelected = selectedSoundId == sound.id;
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        audioProvider.stopAllSounds();
                                        modalState(() {
                                          if (isSelected) {
                                            selectedSoundId = null;
                                          } else {
                                            selectedSoundId = sound.id;
                                            audioProvider.toggleMixerSound(sound);
                                          }
                                        });
                                        // Ana widget'ı da güncelle
                                        setState(() {});
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 12 : 14,
                                          vertical: isSmallScreen ? 8 : 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF4ECDC4).withOpacity(0.15)
                                              : Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF4ECDC4).withOpacity(0.5)
                                                : Colors.white.withOpacity(0.08),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              sound.icon,
                                              size: isSmallScreen ? 16 : 18,
                                              color: isSelected
                                                  ? const Color(0xFF4ECDC4)
                                                  : Colors.white.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              sound.name,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? const Color(0xFF4ECDC4)
                                                    : Colors.white.withOpacity(0.8),
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                fontSize: isSmallScreen ? 13 : 14,
                                              ),
                                            ),
                                            if (sound.isPremium) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8A838).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'PRO',
                                                  style: TextStyle(
                                                    color: Color(0xFFE8A838),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }),
                          
                          // Sessizlik seçeneği
                          GestureDetector(
                            onTap: () {
                              audioProvider.stopAllSounds();
                              modalState(() {
                                selectedSoundId = null;
                              });
                              setState(() {});
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: selectedSoundId == null
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedSoundId == null
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    FeatherIcons.volumeX,
                                    color: selectedSoundId == null
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppStrings.silenceOption,
                                    style: TextStyle(
                                      color: selectedSoundId == null
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (selectedSoundId == null)
                                    Icon(
                                      FeatherIcons.check,
                                      color: const Color(0xFF4ECDC4),
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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

  void _showDurationSelectionModal(BuildContext context, BreathingExercise exercise, Color accentColor) {
    final userPrefs = context.read<UserPreferencesProvider>();
    final totalSessions = userPrefs.totalSessions;
    final lockStatus = _getDurationLockStatus(totalSessions);
    final List<int> durationOptions = [1, 2, 3, 4, 5, 10]; // dakika cinsinden
    int selectedMinutes = 3; // varsayılan: 3dk
    int? lockedInfoMinutes; // kilitli süre bilgi mesajı için
    // accentColor parametresini kullanacağız (ExerciseListScreen'deki catColor'a denk gelir)

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
                          final durationLabel = AppStrings.durationMinuteFormat(minutes);

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
                                          ? accentColor.withOpacity(0.15)
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
                                        durationLabel,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    if (isLocked) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        durationLabel,
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
                                        AppStrings.lockedReason(_getRemainingSessionsToUnlock(lockedInfoMinutes!, totalSessions), lockedInfoMinutes!),
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
                        AppStrings.approximateCyclesInfo(estimatedCycles),
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
                              colors: [Color(0xFFD4912A), Color(0xFFA6711F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4912A).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact(); // Feedback
                              Navigator.pop(context); // Close modal
                              
                              // Start exercise with selected duration
                              final provider = context.read<BreathingProvider>();
                              provider.setSessionDuration(selectedMinutes); // Set duration
                              provider.setExercise(exercise); // Start
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppStrings.startButtonText,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: 0.5,
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

/// Koleksiyon veri modeli
class _ExerciseCollection {
  final String title;
  final IconData icon;
  final Color color;
  final List<BreathingExercise> exercises;
  final String? badge;

  _ExerciseCollection({
    required this.title,
    required this.icon,
    required this.color,
    required this.exercises,
    this.badge,
  });
}
