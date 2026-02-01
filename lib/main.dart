import 'package:breathe_flow/constants/app_strings.dart';
import 'package:breathe_flow/constants/app_theme.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/providers/audio_provider.dart';
import 'package:breathe_flow/providers/seamless_audio_provider.dart';
import 'package:breathe_flow/providers/breathing_provider.dart';
import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:breathe_flow/providers/sleep_provider.dart';
import 'package:breathe_flow/providers/user_preferences_provider.dart';
import 'package:breathe_flow/providers/exercise_tracking_provider.dart';
import 'package:breathe_flow/providers/journal_provider.dart';
import 'package:breathe_flow/providers/auth_provider.dart';
import 'package:breathe_flow/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:breathe_flow/firebase_options.dart';
import 'package:breathe_flow/providers/theme_provider.dart';
// 📦 FUTURE: Auth sistemi için
// import 'package:breathe_flow/providers/auth_provider.dart';
import 'package:breathe_flow/core/ads/ad_manager.dart';
import 'package:breathe_flow/services/ad_config.dart';
import 'package:breathe_flow/core/analytics/analytics_service.dart';
import 'package:breathe_flow/core/crashlytics/crashlytics_service.dart';
import 'package:breathe_flow/services/payment_service.dart';
import 'package:breathe_flow/services/ab_test_service.dart';
import 'package:breathe_flow/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/sound_item.dart';
import 'utils/performance_utils.dart';
import 'widgets/performance_overlay.dart';

// 🚀 IMAGE PRECACHING SERVICE - LAZY LOADING STRATEGY
class ImagePrecachingService {
  static bool _isBackgroundPrecachingStarted = false;
  
  /// ⚡ CRITICAL: Precaching devre dışı - performans için
  static Future<void> precacheCriticalImages(BuildContext context) async {
    // ⚠️ DISABLED: Image precaching sorun çıkarıyor
    // Görseller lazy load edilecek (ihtiyaç olduğunda)
    debugPrint('⚡ Image precaching disabled - using lazy loading');
    return;
  }
  
  /// 🌐 BACKGROUND: Precaching devre dışı
  static void startBackgroundPrecaching(BuildContext context) {
    // ⚠️ DISABLED: Arka plan precaching de devre dışı
    // Tüm görseller lazy load - sadece görüntülendiğinde yüklenecek
    debugPrint('⚡ Background precaching disabled - full lazy loading');
    return;
  }
}

void main() async {
  // 🚨 Crashlytics Global Error Handler - En üstte olmalı
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // 🚨 Platform Error Handler
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 😨 Zone içinde çalıştır - Uncaught exception'ı yakala
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 🌍 Easy Localization başlat
    await EasyLocalization.ensureInitialized();
    
    // ⚡ Sadece Firebase'i bekle - UI'yı bloklamadan
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // System UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 🌐 HEMEN UYGULAMAYI BAŞLAT - Splash screen göster
    // Splash screen'de diğer servisler yüklenecek
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr', 'TR'),
        useOnlyLangCode: false, // tr-TR.json formatı için
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // 🚨 Zone içindeki uncaught error'ları yakala
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProxyProvider<UserPreferencesProvider, AudioProvider>(
          create: (context) {
            final audioProvider = AudioProvider();
            final userPrefs = Provider.of<UserPreferencesProvider>(context, listen: false);
            audioProvider.setUserPreferencesProvider(userPrefs);
            return audioProvider;
          },
          update: (context, userPrefs, previousAudio) {
            if (previousAudio != null) {
              previousAudio.setUserPreferencesProvider(userPrefs);
              return previousAudio;
            }
            final audioProvider = AudioProvider();
            audioProvider.setUserPreferencesProvider(userPrefs);
            return audioProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => SeamlessAudioProvider()),
        ChangeNotifierProvider(create: (_) => BreathingProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseTrackingProvider()),
        // ChangeNotifierProvider(create: (_) {
        //   final provider = AnalyticsProvider();
        //   provider.initialize();
        //   return provider;
        // }),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = ABTestProvider();
          provider.initialize();
          return provider;
        }),
        // 🔐 Auth sistemi aktif
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BreatheFlow',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            debugShowCheckedModeBanner: false,
            // 📱 Responsive tasarım - Sistem yazı boyutunu sınırla
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                ),
                child: kDebugMode 
                    ? AppPerformanceOverlay(
                        enabled: true,
                        child: child!,
                      )
                    : child!,
              );
            },
            // 🌍 Çoklu dil desteği - easy_localization
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}

// 🚀 APP INITIALIZER WITH PRECACHING
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for first frame to be rendered
      await WidgetsBinding.instance.endOfFrame;
      
      // ⚡ OPTIMIZED: Hemen UI'yı göster
      if (mounted) {
        setState(() => _isInitialized = true);
      }
      
      // ⚡ Paralel yükleme - UI bloklanmıyor
      Future.wait([
        CrashlyticsService.instance.initialize(),
        AnalyticsService.instance.initialize(),
        // ⚡ Timezone'ı da parallel yükle
        Future.microtask(() => tz.initializeTimeZones()),
      ]).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Servis yükleme hatası: $e');
      });
      
      // � Firestore sync callback'lerini ayarla
      _setupSyncCallbacks();
      
      // �🔙 DİĞER SERVİSLERİ HEMEN ARKA PLANDA YÜKLE (non-blocking)
      _initializeNonCriticalServices();
      
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Init error (non-critical): $e');
      // ⚡ Hata olsa bile UI'yı göster
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }
  
  // 🔄 Firestore sync callback'lerini ayarla
  void _setupSyncCallbacks() {
    try {
      // Provider'ları al
      final userPrefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 🔄 Kullanıcı giriş yaptığında
      authProvider.setOnUserLoggedIn((String userId) async {
        if (kDebugMode) debugPrint('🔄 Kullanıcı giriş yaptı - Full sync başlatılıyor... (userId: $userId)');
        
        // 🔐 PaymentService'e kullanıcı ID'sini bildir
        PaymentService.instance.setCurrentUserId(userId);
        
        // Firestore sync
        await Future.wait([
          userPrefsProvider.performFullSync(),
          premiumProvider.performFullSync(),
          sleepProvider.performFullSync(),
          journalProvider.performFullSync(),
        ]);
        
        // 🔄 Google Play'den premium durumunu restore et (tek çağrı)
        await premiumProvider.restorePurchases();
        
        if (kDebugMode) debugPrint('✅ Full sync tamamlandı');
      });
      
      // 👋 Kullanıcı çıkış yaptığında - GÜVENLİK: Tüm kullanıcı verilerini temizle
      authProvider.setOnUserLoggedOut(() async {
        if (kDebugMode) debugPrint('👋 Kullanıcı çıkış yaptı - Tüm veriler temizleniyor...');
        
        // 🔐 PaymentService'e kullanıcı çıkışını bildir
        PaymentService.instance.setCurrentUserId(null);
        
        // 🔒 GÜVENLİK: Tüm kullanıcı verilerini temizle
        // Böylece yeni giriş yapan kullanıcı önceki kullanıcının verilerini göremez
        await Future.wait([
          premiumProvider.clearAllDataOnLogout(),
          userPrefsProvider.clearAllDataOnLogout(),
          sleepProvider.clearAllDataOnLogout(),
          journalProvider.clearAllDataOnLogout(),
        ]);
        
        if (kDebugMode) debugPrint('✅ Çıkış tamamlandı - Tüm veriler temizlendi');
      });
      
      if (kDebugMode) {
        debugPrint('🔄 Sync callbacks hazır - Auth aktif!');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Sync callback hatası: $e');
    }
  }
  
  // 🔄 Otomatik Premium Restore - Sadece giriş yapılmamışsa çalışır
  void _autoRestorePremium() {
    Future.microtask(() async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Kullanıcı giriş yapmışsa login callback zaten restore yapıyor
        if (authProvider.isAuthenticated) {
          if (kDebugMode) debugPrint('🔄 Kullanıcı giriş yapmış - login callback restore yapacak');
          return;
        }
        
        // Giriş yapılmamışsa local restore yap
        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
        await premiumProvider.restorePurchases();
        
        if (kDebugMode) debugPrint('🔄 Otomatik Premium Restore tamamlandı');
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Otomatik premium restore hatası: $e');
      }
    });
  }
  
  // 🌐 Kritik olmayan servisleri arka planda yükle
  void _initializeNonCriticalServices() {
    // ⚡ OPTIMIZED: Delay kaldırıldı - hemen yükle
    Future.microtask(() async {
      try {
        // ⚡ Production'da log yok
        
        await Future.wait([
          PerformanceOptimizer.optimizeForMediaPlayback(),
          PerformanceOptimizer.preWarmAudioSystem(),
          PerformanceOptimizer.preWarmVideoSystem(),
          AdManager.instance.initialize(),
          PaymentService.instance.initialize(),
          ABTestService.instance.initialize(),
          NotificationService.instance.initialize(),
        ]);
        
        if (kDebugMode) {
          AdConfig.printConfig();
        }
        
        debugPrint('✅ Arka plan servisleri hazır!');
        
        // 🔄 Otomatik Premium Restore - Uygulama açılışında
        _autoRestorePremium();
      } catch (e) {
        debugPrint('⚠️ Arka plan servis hatası: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const BeautifulSplashScreen();
    }

    // 🔐 Auth sistemi aktif - Giriş kontrolü
    return const AuthWrapper();
  }
}

// 🌟 BEAUTIFUL SPLASH SCREEN
class BeautifulSplashScreen extends StatefulWidget {
  const BeautifulSplashScreen({super.key});

  @override
  State<BeautifulSplashScreen> createState() => _BeautifulSplashScreenState();
}

class _BeautifulSplashScreenState extends State<BeautifulSplashScreen>
    with SingleTickerProviderStateMixin { // ⚡ Single ticker - optimized
  late AnimationController _controller; // ⚡ ONE controller for all animations
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // ⚡ OPTIMIZED: Tek controller ile tüm animasyonlar
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500), // Master duration
      vsync: this,
    );

    // ⚡ Interval kullanarak farklı timing'ler
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut), // İlk %40
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.5, curve: Curves.elasticOut), // %10-50
    ));

    _breathingAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut), // %30-100
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut), // Tüm süre
    ));

    // Animasyonu başlat
    _controller.forward().then((_) {
      // Breathing efekti için tekrarla
      if (mounted) {
        _controller.repeat(reverse: true, min: 0.7, max: 1.0);
      }
    });
  }

  // ⚡ Removed _startAnimations - artık gerek yok

  @override
  void dispose() {
    _controller.stop(); // ⚡ Stop first to prevent leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Arkaplan parçacıkları
            _buildBackgroundParticles(),
            
            // Ana içerik
            Center(
              child: AnimatedBuilder(
                animation: _controller, // ⚡ Tek controller dinle
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo ve animasyon
                          _buildAnimatedLogo(),
                          
                          const SizedBox(height: 40),
                          
                          // Uygulama adı
                          _buildAppName(),
                          
                          const SizedBox(height: 12),
                          
                          // Tagline
                          _buildTagline(),
                          
                          const SizedBox(height: 60),
                          
                          // Progress indicator
                          _buildProgressIndicator(),
                          
                          const SizedBox(height: 24),
                          
                          // Loading text
                          _buildLoadingText(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.spa,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return Text(
      AppStrings.appName,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      AppStrings.appTagline,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.cardBackground,
          ),
          child: Stack(
            children: [
              Container(
                width: 200 * _progressAnimation.value,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        String text = 'Hazırlanıyor...';
        if (_progressAnimation.value > 0.3) text = 'Görseller optimize ediliyor';
        if (_progressAnimation.value > 0.7) text = 'Neredeyse hazır!';
        
        return Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
            letterSpacing: 0.3,
          ),
        );
      },
    );
  }
}

// 🎨 PARTICLE PAINTER
class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryAccent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Rastgele parçacıklar çiz
    final random = math.Random(42); // Sabit seed için tutarlı görünüm
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
