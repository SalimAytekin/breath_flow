import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/sleep_provider.dart';
import '../widgets/global_background.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import '../services/asset_manager.dart';
import 'sleep_input_screen.dart';

/// 📊 Profesyonel Uyku Analizi Sayfası
/// Kullanıcının uyku verilerini detaylı analiz eder ve görselleştirir.
/// Bu ekran, ana iskeleti sağlar ve tüm karmaşık UI mantığını
/// `SleepAnalyticsBody` widget'ına devreder.
class SleepAnalyticsScreen extends StatefulWidget {
  const SleepAnalyticsScreen({super.key});

  @override
  State<SleepAnalyticsScreen> createState() => _SleepAnalyticsScreenState();
}

class _SleepAnalyticsScreenState extends State<SleepAnalyticsScreen> 
    with TickerProviderStateMixin {
  String get _heroCardBg => AssetManager.sleepHeroBackground;

  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // ⚡ PERFORMANCE: Animation Controllers - duration optimize edildi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // 1500ms → 600ms
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 2500ms → 2000ms
      vsync: this,
    );
    
    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildPremiumAppBar(context),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Consumer<SleepProvider>(
                  builder: (context, sleepProvider, child) {
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Top padding for AppBar
                        SliverToBoxAdapter(
                          child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10),
                        ),
                        

                        // Main Content
                        sleepProvider.sleepEntries.isEmpty
                            ? SliverToBoxAdapter(child: _buildPremiumEmptyState(context))
                            : SliverToBoxAdapter(child: _buildPremiumAnalyticsContent(context, sleepProvider)),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: _buildPremiumFAB(context),
      ),
    );
  }

  // 🎨 Premium AppBar with Optimized Glassmorphism
  // ⚡ PERFORMANCE: BackdropFilter kaldırıldı, gradient+shadow ile %95 aynı görünüm
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.4), // Daha koyu - okunabilirlik için
              Colors.black.withOpacity(0.3),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            AppStrings.sleepAnalysisMainTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 Premium Empty State
  Widget _buildPremiumEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Hero Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D1F1A),
                  Color(0xFF1E1410),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.2),
                              const Color(0xFFD4AF37).withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          FeatherIcons.moon,
                          size: 45,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  AppStrings.sleepAnalysisEmptyTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  AppStrings.sleepAnalysisEmptyDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA09080),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Feature Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF76FF03).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FeatherIcons.barChart2,
                          color: Color(0xFF76FF03),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.sleepAnalysisFeature1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FeatherIcons.target,
                          color: Color(0xFFD4AF37),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.sleepAnalysisFeature2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF76FF03).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FeatherIcons.trendingUp,
                          color: Color(0xFF76FF03),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.sleepAnalysisFeature3,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // CTA Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFB8941F),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(FeatherIcons.plus, color: Color(0xFF1E1410), size: 20),
              label: Text(
                AppStrings.sleepAnalysisAddFirstRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1410),
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepInputScreen(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppStrings.sleepAnalysisFooter,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFA09080),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📊 Premium Analytics Content
  Widget _buildPremiumAnalyticsContent(BuildContext context, SleepProvider sleepProvider) {
    final isPremium = context.watch<PremiumProvider>().isPremiumUser;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uyku Takip Özeti (Tıklanabilir) - Herkese açık
          _buildPremiumStatsCard(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Sleep Debt Card - Herkese açık
          _buildPremiumSleepDebtCard(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Weekly Overview Cards - Herkese açık
          _buildPremiumOverviewCards(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // 🔒 Weekly Trend Chart - Premium özellik
          if (isPremium)
            _buildPremiumTrendChart(context, sleepProvider)
          else
            _buildPremiumLockedCard(
              context,
              title: AppStrings.weeklyTrendChart,
              description: AppStrings.trackTrendsVisually,
              icon: FeatherIcons.trendingUp,
              featureId: PremiumProvider.featureSleepAnalytics,
            ),
           
          const SizedBox(height: 24),
           
          // 🔒 Monthly Summary Card - Premium özellik
          if (isPremium)
            _buildMonthlySummaryCard(context, sleepProvider)
          else
            _buildPremiumLockedCard(
              context,
              title: AppStrings.monthlySummaryTitle,
              description: AppStrings.monthlyStatsDesc,
              icon: FeatherIcons.calendar,
              featureId: PremiumProvider.featureSleepAnalytics,
            ),
           
          const SizedBox(height: 24),
           
          // Sleep Records - Herkese açık (son 7 kayıt)
          _buildPremiumSleepRecords(context, sleepProvider),
           
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }
  
  // 🔒 Premium Kilitli Kart
  Widget _buildPremiumLockedCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String featureId,
  }) {
    return GestureDetector(
      onTap: () {
        final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
          (t) => t.targetFeatures.contains(featureId),
          orElse: () => PremiumTrigger.predefinedTriggers.first,
        );
        SmartPremiumDialog.show(context, trigger);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.premium.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.premium.withOpacity(0.3),
                        AppColors.premium.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.premium, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.premium.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.pro,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FeatherIcons.lock,
                  color: AppColors.premium.withOpacity(0.7),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.premium,
                    AppColors.premium.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.upgradeToPremiumBtn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Uyku Takip Özeti Kartı (Tıklanabilir)
  Widget _buildPremiumStatsCard(BuildContext context, SleepProvider sleepProvider) {
    final daysWithData = sleepProvider.daysWithDataCount;
    final totalEntries = sleepProvider.sleepEntries.length;

    return GestureDetector(
      onTap: () => _showSleepHistoryDialog(context, sleepProvider),
      child: _buildSleepImageCard(
        assetPath: _heroCardBg,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.28)),
                    ),
                    child: const Icon(
                      FeatherIcons.moon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.sleepTrackingSummary,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.daysActiveFormat(daysWithData, totalEntries),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF3D7A2).withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: Colors.white.withOpacity(0.88),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 📜 Geçmiş Kayıtları Göster (Glassmorphism Modal)
  void _showSleepHistoryDialog(BuildContext context, SleepProvider sleepProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (modalContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Consumer<SleepProvider>(
          builder: (context, provider, child) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1410).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      FeatherIcons.list,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.mySleepRecordsTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.x, color: Colors.white.withOpacity(0.7), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: provider.sleepEntries.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noRecordsYetShort,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.sleepEntries.length,
                  itemBuilder: (context, index) {
                    final entry = provider.sleepEntries[index];
                    final hours = entry.actualSleep.inHours;
                    final minutes = entry.actualSleep.inMinutes % 60;
                    final isHealthy = hours >= 7 && hours <= 9;
                    
                    return GestureDetector(
                      onTap: () {
                        // Detay göster - Glassmorphism Modal
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.7),
                          builder: (context) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1410).withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Header
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.white.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF76FF03).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                                  color: const Color(0xFF76FF03),
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _formatDateForDialog(entry.date),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          '✓',
                                                          style: TextStyle(
                                                            color: Color(0xFF76FF03),
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          AppStrings.idealSleepStatusText,
                                                          style: const TextStyle(
                                                            color: Color(0xFF76FF03),
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Content
                                        Flexible(
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildGlassDetailRow(FeatherIcons.moon, AppStrings.sleepDuration, AppStrings.hoursMinFormat(hours, minutes)),
                                                const SizedBox(height: 12),
                                                _buildGlassDetailRow(FeatherIcons.circle, AppStrings.remLabel, AppStrings.hoursMinFormat(hours, 0)),
                                                const SizedBox(height: 12),
                                                _buildGlassDetailRow(FeatherIcons.circle, AppStrings.lightSleepLabel, AppStrings.hoursMinFormat(hours, 0)),
                                                const SizedBox(height: 12),
                                                _buildGlassDetailRow(FeatherIcons.sunset, AppStrings.bedTimeLabelText, _formatTime(entry.bedTime)),
                                                const SizedBox(height: 12),
                                                _buildGlassDetailRow(FeatherIcons.sunrise, AppStrings.wakeTimeLabelText, _formatTime(entry.wakeTime)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Actions
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.white.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextButton.icon(
                                                  icon: const Icon(FeatherIcons.trash2, color: Colors.red, size: 16),
                                                  label: Text(AppStrings.deleteButtonText, style: const TextStyle(color: Colors.red)),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    final confirmed = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        backgroundColor: AppColors.surface,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        title: Text(AppStrings.deleteRecord, style: const TextStyle(color: Colors.white)),
                                                        content: Text(
                                                          AppStrings.confirmDeleteSleep,
                                                          style: TextStyle(color: AppColors.textSecondary),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: Text(AppStrings.cancel, style: const TextStyle(color: Colors.white)),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: Text(AppStrings.deleteButtonText, style: const TextStyle(color: Colors.red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    
                                                    if (confirmed == true) {
                                                      await provider.deleteSleepEntry(entry.date);
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(AppStrings.recordDeleted),
                                                            backgroundColor: AppColors.success,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextButton.icon(
                                                  icon: const Icon(FeatherIcons.edit2, color: Color(0xFFD4AF37), size: 16),
                                                  label: Text(AppStrings.editButtonText, style: const TextStyle(color: Color(0xFFD4AF37))),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => SleepInputScreen(
                                                          date: entry.date,
                                                          existingEntry: entry,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text(AppStrings.closeButtonText, style: const TextStyle(color: Colors.white)),
                                                ),
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
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2D1F1A),
                              Color(0xFF1E1410),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                    color: isHealthy ? const Color(0xFF76FF03) : const Color(0xFFD4AF37),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _formatDateForDialog(entry.date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF76FF03).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF76FF03).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isHealthy
                                        ? AppStrings.onTargetText
                                        : hours < 7
                                            ? AppStrings.deficitFormat(AppStrings.hoursMinFormat(7 - hours, 0))
                                            : AppStrings.surplusFormat(AppStrings.hoursMinFormat(hours - 8, 0)),
                                    style: TextStyle(
                                      color: isHealthy ? const Color(0xFF76FF03) : const Color(0xFFD4AF37),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isHealthy 
                                ? AppStrings.perfectBalanceDesc 
                                : hours < 7 
                                  ? AppStrings.sleepDebtAdvice
                                  : AppStrings.sleepingTooMuchDesc,
                              style: const TextStyle(
                                color: Color(0xFFA09080),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(FeatherIcons.moon, color: const Color(0xFFA09080), size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppStrings.sleepDuration,
                                              style: const TextStyle(
                                                color: Color(0xFFA09080),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppStrings.hoursMinFormat(hours, minutes),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(FeatherIcons.star, color: const Color(0xFFA09080), size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppStrings.qualityScore,
                                              style: const TextStyle(
                                                color: Color(0xFFA09080),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sleepProvider.sleepQualityScoreForEntry(entry).toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
        ),
      ),
    );
  }

  String _formatDateForDialog(DateTime date) {
    final months = [AppStrings.monthJan, AppStrings.monthFeb, AppStrings.monthMar, AppStrings.monthApr, AppStrings.monthMay2, AppStrings.monthJun, AppStrings.monthJul, AppStrings.monthAug, AppStrings.monthSep, AppStrings.monthOct, AppStrings.monthNov, AppStrings.monthDec];
    final days = [AppStrings.dayMon, AppStrings.dayTue, AppStrings.dayWed, AppStrings.dayThu, AppStrings.dayFri, AppStrings.daySat, AppStrings.daySun];
    return '${date.day} ${months[date.month - 1]} - ${days[date.weekday - 1]}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFA09080), size: 16),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA09080),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSleepDebtCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final daysWithData = sleepProvider.daysWithDataCount;
    
    // Ortalama günlük borcu hesapla (toplam borç / gün sayısı)
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (weeklyDebt.inMinutes.abs() <= 30) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      title = AppStrings.perfectBalance;
      description = AppStrings.perfectBalanceDesc;
    } else if (weeklyDebt.inMinutes < 0) {
      color = AppColors.warning;
      icon = FeatherIcons.alertCircle;
      title = AppStrings.sleepDebt;
      description = AppStrings.sleepDebtAdvice;
    } else {
      color = AppColors.success;
      icon = FeatherIcons.trendingUp;
      title = AppStrings.sleepingTooMuch;
      description = AppStrings.sleepingTooMuchDesc;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEA463).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3D2A3A),
                Color(0xFF2A1B14),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(
                    painter: _NoisePainter(),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.32)),
                          ),
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (daysWithData > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.22)),
                            ),
                            child: Text(
                              sleepProvider.formatSleepDebt(weeklyDebt),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEED9B0).withOpacity(0.95),
                        ),
                      ),
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

  // 📈 Premium Overview Cards (Tam Glassmorphism)
  Widget _buildPremiumOverviewCards(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFullGlassDataTile(
                AppStrings.weeklyAverage,
                sleepProvider.formatDuration(weeklyAverage),
                icon: FeatherIcons.clock,
                accentColor: const Color(0xFFE6C995),
                subtitle: AppStrings.thisWeekRangeText,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFullGlassDataTile(
                AppStrings.qualityScore,
                '$qualityScore/100',
                icon: FeatherIcons.star,
                accentColor: _getQualityColor(qualityScore),
                subtitle: AppStrings.proximityToTargetText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getQualityColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  // 📊 Premium Trend Chart (Gradient + Noise)
  Widget _buildPremiumTrendChart(BuildContext context, SleepProvider sleepProvider) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEA463).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3D2A3A),
                Color(0xFF2A1B14),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(
                    painter: _NoisePainter(),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.weeklyChartTitle,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.last7DaysPerformanceText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFEED9B0).withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Pro Badge (if needed here, currently it seems to be missing from this specific block but might be in the parent container in other designs. 
                        // The user mentioned overflow, so constraining text is the key.)
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.24),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: _buildWeeklyBarChart(context, sleepProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  // 📊 Weekly Bar Chart Implementation
  Widget _buildWeeklyBarChart(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries;
    final targetHours = 8.0; // Sabit standart

    if (weeklyEntries.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noDataYet,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(MediaQuery.of(context).size.width - 60, weeklyEntries.length * 50.0), // Min width or content width
        child: BarChart(
      BarChartData(
        maxY: sleepProvider.maxSleepForChart,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.focus.withOpacity(0.9),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = weeklyEntries[groupIndex];
              if (entry.actualSleep.inMinutes == 0) {
                return BarTooltipItem(
                  AppStrings.noDataShort,
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }
              final hours = entry.actualSleep.inHours;
              final minutes = entry.actualSleep.inMinutes % 60;
              return BarTooltipItem(
                AppStrings.hoursMinFormat(hours, minutes),
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= weeklyEntries.length) return const SizedBox();
                final entry = weeklyEntries[value.toInt()];
                final dayName = _getDayName(entry.date.weekday);
                final hasData = entry.actualSleep.inMinutes > 0;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          color: hasData ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: hasData ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                      if (!hasData) Text(
                        '—',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                // Sadece hedef çizgisini (8 saat) göster
                if (value == 8.0) {
                  return Text(
                    AppStrings.hoursShortLabel,
                    style: TextStyle(
                      color: AppColors.focus,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: targetHours > 0 ? targetHours : 2,
          getDrawingHorizontalLine: (value) {
            if (value == targetHours) {
              return FlLine(
                color: AppColors.focus.withOpacity(0.6),
                strokeWidth: 2,
                dashArray: [4, 4],
              );
            }
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: weeklyEntries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final hours = entry.actualSleep.inMinutes / 60.0;
          final hasData = entry.actualSleep.inMinutes > 0;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hasData ? hours : 0.5, // Daha görünür minimum yükseklik
                color: hasData ? const Color(0xFF76FF03) : Colors.white.withOpacity(0.08),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                gradient: hasData ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: const [
                    Color(0xFF76FF03),
                    Color(0xFF00E5FF),
                  ],
                ) : null,
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeOutCubic,
    ),
      ),
    );
  }

  // Helper methods for chart
  String _getDayName(int weekday) {
    final days = [AppStrings.dayMonText, AppStrings.dayTueText, AppStrings.dayWedText, AppStrings.dayThuText, AppStrings.dayFriText, AppStrings.daySatText, AppStrings.daySunText];
    return days[weekday - 1];
  }

  // 📅 Monthly Summary Card (Koyu Kahve + İç Işıma)
  Widget _buildMonthlySummaryCard(BuildContext context, SleepProvider sleepProvider) {
    final monthlyAverage = sleepProvider.monthlyAverageSleep;
    final monthlyDays = sleepProvider.monthlyDaysWithDataCount;
    final monthlyHours = monthlyAverage.inHours;
    final monthlyMinutes = monthlyAverage.inMinutes % 60;
    
    final isHealthy = monthlyHours >= 7 && monthlyHours <= 9;
    Color color = isHealthy ? AppColors.success : AppColors.warning;
    IconData icon = isHealthy ? FeatherIcons.trendingUp : FeatherIcons.alertTriangle;
    String status = isHealthy ? AppStrings.healthyStatusText : AppStrings.needsImprovementStatusText;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEA463).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1410),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4AF37).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.monthlySleepStatusTitle,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFullGlassDataTile(
                            AppStrings.averageSleepLabelText,
                            AppStrings.hoursMinFormat(monthlyHours, monthlyMinutes),
                            icon: FeatherIcons.clock,
                            accentColor: const Color(0xFFE2C78C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFullGlassDataTile(
                            AppStrings.statusLabelText,
                            status,
                            icon: FeatherIcons.activity,
                            accentColor: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      monthlyDays < 7
                          ? AppStrings.needMoreDataForAnalysisText
                          : isHealthy
                              ? AppStrings.monthlyHealthyMessage
                              : AppStrings.monthlyNeedsImprovementMessage,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEED9B0).withOpacity(0.9),
                      ),
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

  // 🏆 Premium Sleep Records (Koyu Kahve + İç Işıma)
  Widget _buildPremiumSleepRecords(BuildContext context, SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries.where((e) => e.actualSleep > Duration.zero).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEA463).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1410),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4AF37).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(FeatherIcons.award, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.sleepRecordsTitleText,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (entries.length < 2)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.38),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          AppStrings.needMoreDataForComparison,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Builder(builder: (context) {
                        final longestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a > b ? a : b);
                        final shortestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a < b ? a : b);
                        return Row(
                          children: [
                            Expanded(
                              child: _buildRecordCard(
                                AppStrings.longestSleepLabel,
                                sleepProvider.formatDuration(longestSleep),
                                AppColors.success,
                                FeatherIcons.trendingUp,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRecordCard(
                                AppStrings.shortestSleepLabel,
                                sleepProvider.formatDuration(shortestSleep),
                                AppColors.error,
                                FeatherIcons.trendingDown,
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(String title, String value, Color color, IconData icon) {
    return _buildFullGlassDataTile(
      title,
      value,
      icon: icon,
      accentColor: color,
    );
  }

  Widget _buildSleepImageCard({
    required String assetPath,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEA463).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2A1B14),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2C1B12).withOpacity(0.32),
                      Colors.black.withOpacity(0.40),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullGlassDataTile(
    String title,
    String value, {
    required IconData icon,
    required Color accentColor,
    String? subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1410).withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.86),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFEED9B0).withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPremiumFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFB8941F),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SleepInputScreen()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(FeatherIcons.plus, color: Colors.white, size: 24),
            ),
          ),
        );
      },
    );
  }
}

// Noise Painter - Dokulu efekt için
class _NoisePainter extends CustomPainter {
  final _random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 2000; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final opacity = _random.nextDouble() * 0.5;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
