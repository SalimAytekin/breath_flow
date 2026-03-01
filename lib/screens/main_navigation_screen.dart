import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../providers/audio_provider.dart';
import '../ui/components/ad_container.dart';
import '../providers/premium_provider.dart';
import '../services/payment_service.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import '../data/premium_triggers_tr.dart';
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
  
  // 🔒 Dialog gösterildi bayrağı
  bool _hasShownExpiredDialog = false;

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
    
    // 🔔 Premium süresi doldu kontrolü (uygulama açılışında)
    _checkPremiumExpired();
    
    // 🔔 Premium süresi doldu callback'ini dinle (runtime'da)
    PaymentService.instance.onPremiumExpired = () {
      if (mounted) {
        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
        
        // 🔒 Dialog gösterildi kontrolü
        if (_hasShownExpiredDialog) {
          if (kDebugMode) print('🔔 Expired callback ama dialog zaten gösterildi - atlanıyor');
          return;
        }
        
        // 🔔 YENİ MANTIK: Sadece gerçekten premium değilse dialog göster
        if (!premiumProvider.isPremiumUser) {
          if (kDebugMode) print('🔔 Premium expired callback - Dialog gösteriliyor');
          _hasShownExpiredDialog = true;
          _showPremiumExpiredDialog();
        } else {
          if (kDebugMode) print('🔔 Premium expired callback ama kullanıcı premium - dialog gösterilmiyor');
        }
      }
    };
  }
  
  /// Premium süresi dolmuş mu kontrol et ve dialog göster
  void _checkPremiumExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentService = PaymentService.instance;
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      
      // 🔒 Dialog gösterildi kontrolü
      if (_hasShownExpiredDialog) {
        if (kDebugMode) print('🔔 Expired dialog zaten gösterildi - atlanıyor');
        paymentService.clearPremiumExpiredFlag(); // Flag'i temizle
        return;
      }
      
      // 🔔 YENİ MANTIK: Hem PaymentService hem PremiumProvider durumunu kontrol et
      // Sadece her ikisi de premium değilse expired dialog göster
      if (paymentService.premiumExpired && !premiumProvider.isPremiumUser) {
        if (kDebugMode) print('🔔 Premium süresi doldu - Dialog gösteriliyor');
        _hasShownExpiredDialog = true;
        _showPremiumExpiredDialog();
        paymentService.clearPremiumExpiredFlag();
      } else if (paymentService.premiumExpired && premiumProvider.isPremiumUser) {
        // Premium durum düzeltilmiş - flag'i sadece temizle
        if (kDebugMode) print('🔔 Premium expired flag var ama kullanıcı premium - sadece temizleniyor');
        paymentService.clearPremiumExpiredFlag();
      }
    });
  }
  
  /// Premium süresi doldu dialog’u
  void _showPremiumExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.premiumExpiredTitle,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.premiumExpiredDesc,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.primaryAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.premiumExpiredBenefit,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.laterButton,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // SmartPremiumDialog ile yenileme
              final triggers = PremiumTriggersData.getPredefinedTriggers();
              final expiredTrigger = triggers.firstWhere(
                (t) => t.type == PremiumTriggerType.featureLimit,
                orElse: () => triggers.first,
              );
              SmartPremiumDialog.show(context, expiredTrigger);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(AppStrings.premiumExpiredRenewBtn),
          ),
        ],
      ),
    );
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
      // 🎉 Satın alma başarılı olduğunda kutlama dialog’u göster
      if (premiumProvider.justPurchased) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            PremiumCelebrationDialog.show(context);
            // Bildirimi temizle
            premiumProvider.clearPurchaseNotification();
          }
        });
      }

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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 
            0, 
            20, 
            20 + MediaQuery.of(context).padding.bottom // Extra padding for floating effect
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70, // Consistent height for floating bar
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E1E24).withOpacity(0.85) // Koyu mod için elit bir yüzey rengi
                        : AppColors.surface.withOpacity(0.9),
                    border: Border.all(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.08) 
                          : AppColors.cardStroke.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better spacing
                    children: <Widget>[
                      _buildNavItem(FeatherIcons.home, AppStrings.navHome, 0),
                      _buildNavItem(FeatherIcons.compass, AppStrings.navExplore, 1),
                      _buildNavItem(FeatherIcons.user, AppStrings.navProfile, 2),
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