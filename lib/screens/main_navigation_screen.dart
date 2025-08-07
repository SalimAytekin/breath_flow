import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';

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

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    ProfileScreen(),
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
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
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

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true,
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        // Base deep night gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.8, 1.0],
              colors: [
                Color(0xFF0B0B1A),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F0F1E),
              ],
            ),
          ),
        ),
        
        // Floating aurora-like orbs
        Positioned(
          top: -50,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4A5568).withOpacity(0.15),
                  const Color(0xFF4A5568).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B46C1).withOpacity(0.12),
                  const Color(0xFF6B46C1).withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        Positioned(
          top: 200,
          right: 50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4C6EF5).withOpacity(0.08),
                  const Color(0xFF4C6EF5).withOpacity(0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        // Subtle animated shimmer overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.transparent,
                Colors.white.withOpacity(0.01),
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // Gentle blur layer for depth
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.02),
                  Colors.transparent,
                  Colors.black.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
        
        // Content layer
        FadeTransition(
          opacity: _fadeAnimation,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _widgetOptions,
          ),
        ),
      ],
    ),
    bottomNavigationBar: _buildBottomNavBar(Theme.of(context).brightness == Brightness.dark),
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