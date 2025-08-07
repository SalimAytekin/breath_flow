import 'package:breathe_flow/constants/app_strings.dart';
import 'package:breathe_flow/constants/app_theme.dart';
import 'package:breathe_flow/providers/audio_provider.dart';
import 'package:breathe_flow/providers/breathing_provider.dart';
import 'package:breathe_flow/providers/hrv_provider.dart';
import 'package:breathe_flow/providers/journal_provider.dart';
import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:breathe_flow/providers/sleep_provider.dart';
import 'package:breathe_flow/providers/story_provider.dart';
import 'package:breathe_flow/providers/user_preferences_provider.dart';
import 'package:breathe_flow/screens/auth_wrapper.dart';
import 'package:breathe_flow/screens/breathing_screen.dart';
import 'package:breathe_flow/screens/exercise_list_screen.dart';
import 'package:breathe_flow/screens/home_screen.dart';
import 'package:breathe_flow/screens/hrv_analytics_screen.dart';
import 'package:breathe_flow/screens/hrv_measurement_screen.dart';
import 'package:breathe_flow/screens/journal_screen.dart';
import 'package:breathe_flow/screens/journey_detail_screen.dart';
import 'package:breathe_flow/screens/journeys_screen.dart';
import 'package:breathe_flow/screens/main_navigation_screen.dart';
import 'package:breathe_flow/screens/profile_screen.dart';
import 'package:breathe_flow/screens/sleep_input_screen.dart';
import 'package:breathe_flow/screens/sleep_screen.dart';
import 'package:breathe_flow/screens/sounds_screen.dart';
import 'package:breathe_flow/screens/splash_screen.dart';
import 'package:breathe_flow/screens/story_player_screen.dart';
import 'package:breathe_flow/screens/story_series_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:breathe_flow/firebase_options.dart';
import 'package:breathe_flow/providers/theme_provider.dart';
import 'package:breathe_flow/providers/auth_provider.dart';
import 'models/sound_item.dart';
import 'utils/performance_utils.dart';

// 🚀 IMAGE PRECACHING SERVICE
class ImagePrecachingService {
  static Future<void> precacheAllSoundImages(BuildContext context) async {
    debugPrint('🖼️ Starting image precaching...');
    
    final List<String> imagePaths = SoundItem.allSounds
        .map((sound) => sound.imagePath)
        .toSet() // Remove duplicates
        .toList();
    
    // Precache images in parallel for better performance
    final List<Future> precacheFutures = imagePaths.map((imagePath) {
      return precacheImage(
        AssetImage(imagePath),
        context,
      ).catchError((error) {
        debugPrint('🚨 Failed to precache image: $imagePath - $error');
      });
    }).toList();
    
    await Future.wait(precacheFutures);
    debugPrint('✅ All sound images precached! Total: ${imagePaths.length}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 Performance optimizations for seamless video/audio
  await PerformanceOptimizer.optimizeForMediaPlayback();
  await PerformanceOptimizer.preWarmAudioSystem();
  await PerformanceOptimizer.preWarmVideoSystem();
  
  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => BreathingProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProxyProvider<UserPreferencesProvider, HRVProvider>(
          create: (context) => HRVProvider(
            Provider.of<UserPreferencesProvider>(context, listen: false),
          ),
          update: (context, userPrefs, previousHrv) => 
              HRVProvider(userPrefs),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
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
      
      if (mounted) {
        // 🖼️ Precache all sound images for fast loading
        await ImagePrecachingService.precacheAllSoundImages(context);
        
        // Small delay to ensure smooth transition
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('🚨 App initialization error: $e');
      // Even if precaching fails, continue with app
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
              SizedBox(height: 24),
              Text(
                'BreatheFlow hazırlanıyor...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Görseller optimize ediliyor',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const AuthWrapper();
  }
}
