import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/sleep_provider.dart';
import '../widgets/global_background.dart';
import '../widgets/simple_banner_ad.dart';
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
    
    // Animation Controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
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
                    return Column(
                      children: [
                        // Top padding for AppBar
                        SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10),
                        
                        // Banner Reklam
                        SimpleBannerAd(
                          placement: 'sleep_analytics',
                          showPlaceholder: true,
                        ),
                        
                        // Main Content
                        Expanded(
                          child: sleepProvider.sleepEntries.isEmpty
                              ? _buildPremiumEmptyState(context)
                              : _buildPremiumAnalyticsContent(context, sleepProvider),
                        ),
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

  // 🎨 Premium AppBar with Advanced Glassmorphism
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
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
                'Uyku Analizi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
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
            'Uyku Analiziniz Hazırlanıyor',
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
            'Uyku düzeninizi analiz etmeye başlamak için\nilk verinizi girin ve kişiselleştirilmiş\nönerilerinizi keşfedin.',
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
                'İlk Uykunu Kaydet',
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
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Header Stats
          _buildPremiumHeaderStats(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Sleep Debt Card with improved logic
          _buildPremiumSleepDebtCard(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Weekly Overview Cards
          _buildPremiumOverviewCards(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Weekly Trend Chart
          _buildPremiumTrendChart(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Sleep Records
          _buildPremiumSleepRecords(context, sleepProvider),
          
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  // 🏆 Premium Header Stats
  Widget _buildPremiumHeaderStats(BuildContext context, SleepProvider sleepProvider) {
    final daysWithData = sleepProvider.daysWithDataCount;
    final totalEntries = sleepProvider.sleepEntries.length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryAccent.withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
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
                  'Uyku Takip Özeti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$daysWithData gün aktif • $totalEntries toplam kayıt',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💤 Premium Sleep Debt Card (Improved Logic)
  Widget _buildPremiumSleepDebtCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final daysWithData = sleepProvider.daysWithDataCount;
    final isNegative = weeklyDebt.isNegative;
    final isBalanced = weeklyDebt.inMinutes.abs() < 30;
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (daysWithData == 0) {
      color = AppColors.primary;
      icon = FeatherIcons.clock;
      title = 'Veri Bekleniyor';
      description = 'Uyku borcu hesaplamak için veri girin.';
    } else if (isBalanced) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      title = 'Mükemmel Denge!';
      description = 'Uyku hedefinize ulaştınız, harika gidiyorsunuz.';
    } else if (isNegative) {
      color = AppColors.error;
      icon = FeatherIcons.alertCircle;
      title = 'Uyku Borcu';
      description = 'Daha fazla dinlenmeye odaklanın.';
    } else {
      color = AppColors.success;
      icon = FeatherIcons.trendingUp;
      title = 'Uyku Fazlası';
      description = 'Vücudunuz çok iyi dinlenmiş görünüyor!';
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
      child: Row(
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
          if (daysWithData > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Text(
                sleepProvider.formatSleepDebt(weeklyDebt),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 📈 Premium Overview Cards
  Widget _buildPremiumOverviewCards(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;
    
    return Row(
      children: [
        Expanded(
          child: _buildPremiumStatCard(
            'Haftalık Ortalama',
            sleepProvider.formatDuration(weeklyAverage),
            AppColors.primary,
            FeatherIcons.clock,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Kalite Skoru',
            '$qualityScore/100',
            _getQualityColor(qualityScore),
            FeatherIcons.star,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(String title, String value, Color color, IconData icon) {
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
              Text(
                'Haftalık Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
    final targetHours = sleepProvider.defaultTargetHours.toDouble();

    if (weeklyEntries.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
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
                  'Veri yok',
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
                '${hours}s ${minutes}dk',
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
                if (value == 0 || value >= sleepProvider.maxSleepForChart) return const SizedBox();
                return Text(
                  '${value.toInt()}s',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                );
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
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
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
              Text(
                'Uyku Rekorları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
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
              child: Center(
                child: Text(
                  entries.isEmpty 
                      ? 'Henüz hiç uyku verisi yok.' 
                      : 'Karşılaştırma için daha fazla veri gerekli.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
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
                      'En Uzun Uyku',
                      sleepProvider.formatDuration(longestSleep),
                      AppColors.success,
                      FeatherIcons.trendingUp,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecordCard(
                      'En Kısa Uyku',
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

  // 🎯 Premium Floating Action Button
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
