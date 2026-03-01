import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../providers/user_preferences_provider.dart';
import 'main_navigation_screen.dart';
import '../widgets/legal_dialogs.dart';

/// Sevecen Onboarding Ekranı
/// İlk açılışta kullanıcıyı sıcak bir şekilde karşılar
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      lottieAsset: 'assets/lottie/night_background.json',
      title: 'onboarding_title_1',
      subtitle: 'onboarding_subtitle_1',
      icon: Icons.headphones_rounded,
      gradient: const [Color(0xFF1E1410), Color(0xFF2D1F1A)],
    ),
    _OnboardingPage(
      lottieAsset: 'assets/lottie/calm_circle.json',
      title: 'onboarding_title_2',
      subtitle: 'onboarding_subtitle_2',
      icon: Icons.nights_stay_rounded,
      gradient: const [Color(0xFF1A1208), Color(0xFF2E2010)],
    ),
    _OnboardingPage(
      lottieAsset: 'assets/lottie/Particle_wave.json',
      title: 'onboarding_title_3',
      subtitle: 'onboarding_subtitle_3',
      icon: Icons.favorite_rounded,
      gradient: const [Color(0xFF15100A), Color(0xFF2A1E14)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final userPrefs = Provider.of<UserPreferencesProvider>(context, listen: false);
    await userPrefs.setIsFirstLaunch(false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 🎬 TAM EKRAN Lottie Animasyon Arka Plan
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: SizedBox.expand(
                key: ValueKey<int>(_currentPage),
                child: Lottie.asset(
                  _pages[_currentPage].lottieAsset,
                  fit: BoxFit.cover,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),

            // 🌑 Gradient Overlay — metinlerin okunabilirliği için
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    _pages[_currentPage].gradient[0].withOpacity(0.7),
                    _pages[_currentPage].gradient[0].withOpacity(0.4),
                    _pages[_currentPage].gradient[1].withOpacity(0.6),
                    _pages[_currentPage].gradient[1].withOpacity(0.95),
                  ],
                ),
              ),
            ),

            // ✨ Parıltı efekti — üst kısımda hafif ışık
            Positioned(
              top: -100,
              left: -50,
              right: -50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Sayfa içeriği (sadece metin + ikon)
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),

            // Alt kısım: Dot indicator + Butonlar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xLarge,
                    vertical: AppSpacing.large,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white.withOpacity(0.3),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Ana buton — glassmorphism efekti
                      // Ana buton — Gold gradient
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'onboarding_start'.tr()
                                  : 'onboarding_next'.tr(),
                              style: AppTypography.buttonText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_currentPage == _pages.length - 1) ...[
                        // Terms & Privacy notice
                        Text.rich(
                          TextSpan(
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.75),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: '${AppStrings.signupTermsPrefix} '),
                              TextSpan(
                                text: AppStrings.termsOfService,
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => showTermsOfUseDialog(context),
                              ),
                              TextSpan(text: ' ${AppStrings.signupTermsConnector} '),
                              TextSpan(
                                text: AppStrings.privacyPolicy,
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => showPrivacyPolicyDialog(context),
                              ),
                              TextSpan(text: ' ${AppStrings.signupTermsSuffix}'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ✨ Dekoratif ince çizgi — premium minimal ayırıcı
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Başlık — daha büyük ve etkileyici
          Text(
            page.title.tr(),
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 36,
              height: 1.15,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
                Shadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Alt başlık — daha geniş ve okunabilir
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              page.subtitle.tr(),
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.85),
                height: 1.7,
                fontSize: 17,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Alt butonlar için boşluk
          SizedBox(height: screenHeight * 0.22),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String lottieAsset;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  _OnboardingPage({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
