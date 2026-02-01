import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/sleep_provider.dart';
import '../widgets/global_background.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import '../ui/components/ad_container.dart';
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
                        
                        // 💰 OPTIMIZATION: Banner sadece veri varsa gösterilir
                        // Empty state'te banner göstermek low quality impression = düşük eCPM
                        if (sleepProvider.sleepEntries.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              child: AdContainer(
                                placement: 'sleep_analytics',
                              ),
                            ),
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
          const SizedBox(height: 80),
          
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.sleep.withOpacity(0.3),
                        AppColors.sleep.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.sleep.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sleep.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    FeatherIcons.moon,
                    size: 50,
                    color: AppColors.sleep,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          Text(
            AppStrings.preparingAnalysis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppStrings.startAnalysisDesc,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 50),
          
          // Premium Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.sleep,
                  AppColors.sleep.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sleep.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(FeatherIcons.plus, color: Colors.white, size: 20),
              label: Text(
                AppStrings.recordFirstSleep,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
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
        ],
      ),
    );
  }

  // 📊 Premium Analytics Content
  Widget _buildPremiumAnalyticsContent(BuildContext context, SleepProvider sleepProvider) {
    final isPremium = context.read<PremiumProvider>().isPremiumUser;
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
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.2),
              AppColors.primaryAccent.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      FeatherIcons.barChart2,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.sleepTrackingSummary,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.daysActiveFormat(daysWithData, totalEntries),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.clickToSeeAll,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 📜 Geçmiş Kayıtları Göster (Tam Ekran Modal)
  void _showSleepHistoryDialog(BuildContext context, SleepProvider sleepProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Consumer<SleepProvider>(
        builder: (context, provider, child) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FeatherIcons.list,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.mySleepRecordsText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.clickForDetailsText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.x, color: Colors.white),
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
                        // Detay göster
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                    color: isHealthy ? AppColors.success : AppColors.warning,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDateForDialog(entry.date),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        isHealthy ? AppStrings.idealSleepStatusText : AppStrings.insufficientSleepStatusText,
                                        style: TextStyle(
                                          color: isHealthy ? AppColors.success : AppColors.warning,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(FeatherIcons.moon, AppStrings.sleepDuration, AppStrings.hoursMinFormat(hours, minutes)),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.target, AppStrings.target, AppStrings.targetSleepTime),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.sunset, AppStrings.bedTimeLabelText, _formatTime(entry.bedTime)),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.sunrise, AppStrings.wakeTimeLabelText, _formatTime(entry.wakeTime)),
                                const SizedBox(height: 16),
                                // Sağlık durumu açıklaması
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isHealthy ? FeatherIcons.thumbsUp : FeatherIcons.info,
                                        color: isHealthy ? AppColors.success : AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          isHealthy 
                                            ? AppStrings.idealSleepMessage
                                            : hours < 7 
                                              ? AppStrings.tooLittleSleepMessage
                                              : AppStrings.tooMuchSleepMessage,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.start,
                            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            actions: [
                              TextButton.icon(
                                icon: Icon(FeatherIcons.trash2, color: AppColors.error, size: 18),
                                label: Text(AppStrings.deleteButtonText, style: TextStyle(color: AppColors.error)),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(AppStrings.deleteRecord, style: TextStyle(color: Colors.white)),
                                      content: Text(
                                        AppStrings.confirmDeleteSleep,
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text(AppStrings.cancel, style: TextStyle(color: Colors.white)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text(AppStrings.deleteButtonText, style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirmed == true) {
                                    await provider.deleteSleepEntry(entry.date);
                                    if (context.mounted) {
                                      Navigator.pop(context); // Detail dialog'u kapat
                                      // Consumer sayesinde liste otomatik güncellenecek
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
                              TextButton.icon(
                                icon: Icon(FeatherIcons.edit2, color: AppColors.primary, size: 18),
                                label: Text(AppStrings.editButtonText, style: TextStyle(color: AppColors.primary)),
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
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(AppStrings.closeButtonText, style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.15),
                              (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                color: isHealthy ? AppColors.success : AppColors.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateForDialog(entry.date),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(FeatherIcons.moon, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.hoursMinFormat(hours, minutes),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(FeatherIcons.target, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.targetHours,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isHealthy 
                                      ? AppStrings.idealSleepDurationText 
                                      : hours < 7 
                                        ? AppStrings.tryToSleepMore
                                        : AppStrings.sleptTooMuch,
                                    style: TextStyle(
                                      color: isHealthy ? AppColors.success : AppColors.warning,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              FeatherIcons.chevronRight,
                              color: AppColors.textSecondary,
                              size: 20,
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
    );
  }

  String _formatDateForDialog(DateTime date) {
    const months = [AppStrings.monthJan, AppStrings.monthFeb, AppStrings.monthMar, AppStrings.monthApr, AppStrings.monthMay2, AppStrings.monthJun, AppStrings.monthJul, AppStrings.monthAug, AppStrings.monthSep, AppStrings.monthOct, AppStrings.monthNov, AppStrings.monthDec];
    const days = [AppStrings.dayMon, AppStrings.dayTue, AppStrings.dayWed, AppStrings.dayThu, AppStrings.dayFri, AppStrings.daySat, AppStrings.daySun];
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

  Widget _buildPremiumSleepDebtCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final daysWithData = sleepProvider.daysWithDataCount;
    final isNegative = weeklyDebt.isNegative;
    
    // Ortalama günlük borcu hesapla (toplam borç / gün sayısı)
    final averageDailyDebt = daysWithData > 0 
        ? weeklyDebt.inMinutes / daysWithData 
        : 0.0;
    final isBalanced = averageDailyDebt.abs() <= 30; // ±30dk tolerans
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (daysWithData == 0) {
      color = AppColors.primary;
      icon = FeatherIcons.clock;
      title = 'waitingForData'.tr();
      description = 'enterDataForDebt'.tr();
    } else if (isBalanced) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      title = 'perfectBalance'.tr();
      description = 'perfectBalanceDesc'.tr();
    } else if (isNegative) {
      color = AppColors.error;
      icon = FeatherIcons.arrowDownCircle;
      title = 'lookingTired'.tr();
      description = 'lookingTiredDesc'.tr();
    } else {
      color = AppColors.warning;
      icon = FeatherIcons.arrowUpCircle;
      title = 'sleepingTooMuch'.tr();
      description = 'sleepingTooMuchDesc'.tr();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (daysWithData > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              sleepProvider.formatSleepDebt(weeklyDebt),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (daysWithData > 0) ...[
            const SizedBox(height: 16),
            Container(
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
                  Icon(
                    FeatherIcons.target,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.weeklyDebtInfoText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 📈 Premium Overview Cards
  Widget _buildPremiumOverviewCards(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPremiumStatCard(
                AppStrings.weeklyAverage,
                sleepProvider.formatDuration(weeklyAverage),
                AppColors.primary,
                FeatherIcons.clock,
                AppStrings.thisWeekRangeText,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPremiumStatCard(
                AppStrings.qualityScore,
                '$qualityScore/100',
                _getQualityColor(qualityScore),
                FeatherIcons.star,
                AppStrings.proximityToTargetText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                FeatherIcons.info,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.qualityScoreInfo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(String title, String value, Color color, IconData icon, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  // 📊 Premium Trend Chart with Real Data
  Widget _buildPremiumTrendChart(BuildContext context, SleepProvider sleepProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.focus.withOpacity(0.15),
            AppColors.focus.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.focus.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.focus.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.focus.withOpacity(0.3),
                      AppColors.focus.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.trendingUp,
                  color: AppColors.focus,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.weeklyChartTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.last7DaysPerformanceText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Renk açıklamaları
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendItem(AppStrings.legendIdealText, AppColors.success),
              _buildLegendItem(AppStrings.legendModerateText, AppColors.warning),
              _buildLegendItem(AppStrings.legendInsufficientText, AppColors.error),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.focus.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.focus.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.focus,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.targetHoursLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.focus,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildWeeklyBarChart(context, sleepProvider),
            ),
          ),
        ],
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

    return BarChart(
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
                final dayName = _getDayName(weeklyEntries[value.toInt()].date.weekday);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 28,
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
                toY: hasData ? hours : 0.2, // Minimum height for empty days
                color: hasData ? _getSleepQualityColor(entry) : Colors.white.withOpacity(0.2),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                gradient: hasData ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _getSleepQualityColor(entry).withOpacity(0.7),
                    _getSleepQualityColor(entry),
                  ],
                ) : null,
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  // Helper methods for chart
  Color _getSleepQualityColor(dynamic entry) {
    if (entry.actualSleep.inMinutes == 0) return Colors.white.withOpacity(0.2);
    final debt = entry.sleepDebt.inMinutes.abs();
    if (debt <= 30) return AppColors.success;
    if (debt <= 75) return AppColors.warning;
    return AppColors.error;
  }

  String _getDayName(int weekday) {
    final days = [AppStrings.dayMonText, AppStrings.dayTueText, AppStrings.dayWedText, AppStrings.dayThuText, AppStrings.dayFriText, AppStrings.daySatText, AppStrings.daySunText];
    return days[weekday - 1];
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 📅 Monthly Summary Card
  Widget _buildMonthlySummaryCard(BuildContext context, SleepProvider sleepProvider) {
    final monthlyAverage = sleepProvider.monthlyAverageSleep;
    final monthlyDays = sleepProvider.monthlyDaysWithDataCount;
    final monthlyHours = monthlyAverage.inHours;
    final monthlyMinutes = monthlyAverage.inMinutes % 60;
    
    // Aylık sağlık durumu
    final isHealthy = monthlyHours >= 7 && monthlyHours <= 9;
    Color color = isHealthy ? AppColors.success : AppColors.warning;
    IconData icon = isHealthy ? FeatherIcons.trendingUp : FeatherIcons.alertTriangle;
    String status = isHealthy ? AppStrings.healthyStatusText : AppStrings.needsImprovementStatusText;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.monthlySleepStatusTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.last30Days.replaceAll('{0}', monthlyDays.toString()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.averageSleepLabelText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.hoursMinFormat(monthlyHours, monthlyMinutes),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.statusLabelText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
                Icon(
                  FeatherIcons.info,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    monthlyDays < 7 
                        ? AppStrings.needMoreDataForAnalysisText
                        : isHealthy
                            ? AppStrings.monthlyHealthyMessage
                            : AppStrings.monthlyNeedsImprovementMessage,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏆 Premium Sleep Records
  Widget _buildPremiumSleepRecords(BuildContext context, SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries.where((e) => e.actualSleep > Duration.zero).toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.energy.withOpacity(0.15),
            AppColors.energy.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.energy.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.energy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.energy.withOpacity(0.3),
                      AppColors.energy.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.award,
                  color: AppColors.energy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sleepRecordsTitleText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.bestAndWorstPerformanceText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (entries.length < 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    entries.isEmpty 
                        ? AppStrings.noSleepDataYet 
                        : AppStrings.needMoreDataForComparison,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.seeRecordsAfter2Days,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  const SizedBox(width: 16),
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
    );
  }

  Widget _buildRecordCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 💚 Sağlık Durumu Kartı (Sadece hedef 7-9 dışındaysa)
  Widget _buildHealthStatusCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries.where((e) => e.actualSleep.inMinutes > 0).toList();
    int healthyDays = 0;
    int unhealthyDays = 0;
    
    for (var entry in weeklyEntries) {
      final hours = entry.actualSleep.inHours;
      if (hours >= 7 && hours <= 9) {
        healthyDays++;
      } else {
        unhealthyDays++;
      }
    }
    
    final totalDays = weeklyEntries.length;
    final healthPercentage = totalDays > 0 ? (healthyDays / totalDays * 100).round() : 0;
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (totalDays == 0) {
      color = AppColors.warning;
      icon = FeatherIcons.alertCircle;
      title = AppStrings.healthWarningTitle;
      description = AppStrings.standardTarget8Hours;
    } else if (healthPercentage >= 80) {
      color = AppColors.success;
      icon = FeatherIcons.heart;
      title = AppStrings.healthySleeping;
      description = AppStrings.healthySleepingDesc.replaceAll('{0}', healthyDays.toString());
    } else if (healthPercentage >= 50) {
      color = AppColors.warning;
      icon = FeatherIcons.alertTriangle;
      title = AppStrings.unhealthySleepWarning;
      description = AppStrings.unhealthySleepDesc.replaceAll('{0}', unhealthyDays.toString());
    } else {
      color = AppColors.error;
      icon = FeatherIcons.alertCircle;
      title = AppStrings.urgentSleepWarning;
      description = AppStrings.urgentSleepDesc;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppStrings.healthStatus,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          FeatherIcons.heart,
                          color: Colors.white.withOpacity(0.6),
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (totalDays > 0)
                Column(
                  children: [
                    Text(
                      '$healthPercentage%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      AppStrings.healthyStatusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
                Icon(
                  FeatherIcons.info,
                  color: AppColors.success,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.standardTargetMessage,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  AppColors.sleep,
                  AppColors.sleep.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sleep.withOpacity(0.4),
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
