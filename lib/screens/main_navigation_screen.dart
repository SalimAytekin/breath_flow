import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../ui/components/ad_container.dart';
import '../widgets/smart_premium_dialog.dart';
import '../providers/premium_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';
import '../widgets/global_background.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  AudioProvider? _audioProvider; // Provider referansını sakla

  // ⚡ PERFORMANS: Sayfalar const olarak tanımlanıyor - gereksiz rebuild'leri engeller
  // RepaintBoundary ile her sayfa izole ediliyor - bir sayfadaki değişiklik diğerlerini etkilemiyor
  static const List<Widget> _widgetOptions = <Widget>[ // ⚡ Const list
    RepaintBoundary(child: HomeScreen()),
    RepaintBoundary(child: ExploreScreen()),
    RepaintBoundary(child: ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: AppSpacing.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppSpacing.easeOutQuart,
    ));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider referansını güvenli şekilde al
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // 🎵 Ana navigasyon değişiminde mixer seslerini durdur
      _stopMixerSoundsOnNavigation();
      
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: AppSpacing.animationMedium,
        curve: AppSpacing.easeOutQuart,
      );
    }
  }

  /// Ana navigasyon değişiminde mixer seslerini durdur
  void _stopMixerSoundsOnNavigation() {
    try {
      if (_audioProvider != null && _audioProvider!.isMixerActive) {
        _audioProvider!.stopAllSounds();
        debugPrint('✅ MainNavigation: Mixer sesleri ana navigasyon değişiminde durduruldu');
      }
    } catch (e) {
      debugPrint('❌ MainNavigation audio cleanup error: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return Consumer<PremiumProvider>(
    builder: (context, premiumProvider, child) {
      // Premium tetikleyici kontrolü - ASKIYA ALINDI
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (premiumProvider.currentActiveTrigger != null) {
      //     SmartPremiumDialog.show(
      //       context,
      //       premiumProvider.currentActiveTrigger!,
      //       onPurchase: () {
      //         // Premium satın alma başarılı
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //             content: Text('Premium aktifleştirildi! 🎉'),
      //             backgroundColor: Colors.green,
      //           ),
      //         );
      //       },
      //       onDismiss: () {
      //         // Tetikleyici dismiss edildi
      //       },
      //     );
      //   }
      // });

      return PopScope(
        canPop: false, // Geri tuşu davranışını kontrol et
        onPopInvoked: (didPop) {
          if (!didPop) {
            // 🎵 Geri tuşu basıldığında mixer seslerini durdur
            _stopMixerSoundsOnNavigation();
            // Uygulamadan çık
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: GlobalBackground(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(), // Performans optimizasyonu
                onPageChanged: (index) {
                  // 🎵 Sayfa değişiminde mixer seslerini durdur
                  _stopMixerSoundsOnNavigation();
                  
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: _widgetOptions,
              ),
            ),
          ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ⚡ OPTIMIZED: Tek banner tüm ekranlar için - 3x memory tasarrufu
        // RepaintBoundary ile izole edildi - gereksiz rebuild'leri engeller
        RepaintBoundary(
          child: AdContainer(
            key: const ValueKey('main_navigation_banner'),
            placement: 'main_navigation',
            height: 50.0,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
        ),
        _buildBottomNavBar(Theme.of(context).brightness == Brightness.dark),
      ],
    ),
        ),
      );
    },
  );
}


  Widget _buildBottomNavBar(bool isDarkMode) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80 + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? DarkAppColors.background.withOpacity(0.8)
                  : AppColors.surface.withOpacity(0.8),
              border: Border(
                  top: BorderSide(
                      color: AppColors.cardStroke.withOpacity(0.2), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(FeatherIcons.home, 'Ana Sayfa', 0),
                _buildNavItem(FeatherIcons.compass, 'Keşfet', 1),
                _buildNavItem(FeatherIcons.user, 'Profil', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color color =
        isSelected ? DarkAppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 