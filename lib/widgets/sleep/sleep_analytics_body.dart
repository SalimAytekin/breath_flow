import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/sleep_entry.dart';
import '../../providers/sleep_provider.dart';
import '../../screens/sleep_input_screen.dart';
import '../professional_button.dart';
import '../professional_card.dart';

/// The main body for the sleep analytics screen.
/// This widget is responsible for displaying either the empty state
/// or the detailed analytics view based on data availability.
class SleepAnalyticsBody extends StatelessWidget {
  final ScrollController controller;

  const SleepAnalyticsBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        if (sleepProvider.sleepEntries.isEmpty) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Haftalık Uyku Borcu Kartı
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _buildSleepDebtCard(context, sleepProvider),
              ),
              const SizedBox(height: AppSpacing.large),
              // Genel Durum Özeti
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: _buildOverviewSection(context, sleepProvider),
              ),
              const SizedBox(height: AppSpacing.large),
              // Haftalık Trend
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: _buildWeeklyTrendSection(context, sleepProvider),
              ),
              const SizedBox(height: AppSpacing.large),
              // İstatistikler
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 300),
                child: _buildStatsSection(context, sleepProvider),
              ),
              const SizedBox(height: AppSpacing.large),
              // Son Kayıtlar
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                delay: const Duration(milliseconds: 400),
                child: _buildRecentEntriesSection(context, sleepProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the empty state widget when no sleep data is available.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xlarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.sleep.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sleep.withOpacity(0.2), width: 2),
                ),
                child: Icon(
                  FeatherIcons.moon,
                  size: 64,
                  color: AppColors.sleep,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Uyku Verileriniz Bekleniyor',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Uyku düzeninizi analiz etmeye başlamak için ilk verinizi girin.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 400),
              child: ProfessionalButton(
                text: 'İlk Uykunu Ekle',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SleepInputScreen(),
                    ),
                  );
                },
                icon: FeatherIcons.plusCircle,
                buttonType: ButtonType.primary,
                gradient: AppColors.sleepGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for data view

  Widget _buildSleepDebtCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final isNegative = weeklyDebt.isNegative;
    final isBalanced = weeklyDebt.inMinutes.abs() < 30;
    final color = isBalanced
        ? AppColors.primaryAccent
        : (isNegative ? AppColors.error : AppColors.success);
    final icon = isBalanced
        ? FeatherIcons.checkCircle
        : (isNegative ? FeatherIcons.arrowDownCircle : FeatherIcons.arrowUpCircle);

    String title;
    String description;
    if (isBalanced) {
      title = 'Harika Denge!';
      description = 'Haftalık uyku hedefinize ulaştınız.';
    } else if (isNegative) {
      title = 'Uyku Borcu';
      description = 'Bu hafta dinlenmeye daha fazla zaman ayırın.';
    } else {
      title = 'Uyku Fazlası';
      description = 'Vücudunuz dinlenmiş görünüyor, harika!';
    }

    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  description,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Text(
            sleepProvider.formatSleepDebt(weeklyDebt),
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Haftalık Ortalama',
            sleepProvider.formatDuration(weeklyAverage),
            AppColors.primary,
            FeatherIcons.clock,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: _buildOverviewCard(
            'Kalite Skoru',
            '$qualityScore/100',
            _getQualityColor(qualityScore),
            FeatherIcons.star,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, Color color, IconData icon) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
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

  Widget _buildWeeklyTrendSection(BuildContext context, SleepProvider sleepProvider) {
    return ProfessionalCard(
      padding: AppSpacing.cardPaddingAll.copyWith(bottom: AppSpacing.small, right: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.focus.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.barChart2,
                  color: AppColors.focus,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Haftalık Trend',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          SizedBox(
            height: 200,
            child: _buildBarChart(context, sleepProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries;
    final targetHours = sleepProvider.defaultTargetHours.toDouble();

    return BarChart(
      BarChartData(
        maxY: sleepProvider.maxSleepForChart,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.primary.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = weeklyEntries[groupIndex];
              final hours = entry.actualSleep.inHours;
              final minutes = entry.actualSleep.inMinutes % 60;
              return BarTooltipItem(
                '${hours}s ${minutes}dk',
                AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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
                final dayName = _getDayName(weeklyEntries[value.toInt()].date.weekday);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(dayName, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                 if (value == 0 || value >= sleepProvider.maxSleepForChart) return const SizedBox();
                return Text('${value.toInt()}s', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: targetHours > 0 ? targetHours : 8,
          getDrawingHorizontalLine: (value) {
            if (value == targetHours) {
              return FlLine(
                color: AppColors.primaryAccent.withOpacity(0.5),
                strokeWidth: 2,
                dashArray: [4, 4],
              );
            }
            return FlLine(
              color: AppColors.textSecondary.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: weeklyEntries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final hours = entry.actualSleep.inMinutes / 60.0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hours > 0 ? hours : 0.1, // 0 değerler için çok küçük bir çubuk göster
                color: _getSleepQualityColor(entry),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 450),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  Color _getSleepQualityColor(SleepEntry entry) {
    if (entry.actualSleep.inMinutes == 0) return AppColors.textSecondary.withOpacity(0.2);
    final debt = entry.sleepDebt.inMinutes.abs();
    if (debt <= 30) return AppColors.success;
    if (debt <= 75) return AppColors.warning;
    return AppColors.error;
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  Widget _buildStatsSection(BuildContext context, SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries.where((e) => e.actualSleep > Duration.zero).toList();

    return ProfessionalCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.energy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.award,
                  color: AppColors.energy,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Uyku Rekorları',
                style: AppTypography.headlineSmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          if (entries.length < 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  entries.isEmpty ? 'Henüz hiç uyku verisi yok.' : 'Karşılaştırma için daha fazla veri gerekli.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
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
                    child: _buildStatCard(
                      'En Uzun Uyku',
                      sleepProvider.formatDuration(longestSleep),
                      AppColors.success,
                      FeatherIcons.trendingUp,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: _buildStatCard(
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

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntriesSection(
      BuildContext context, SleepProvider sleepProvider) {
    if (sleepProvider.sleepEntries.isEmpty) return const SizedBox.shrink();

    final recentEntries = sleepProvider.sleepEntries.take(5).toList();

    return ProfessionalCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sleep.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FeatherIcons.list,
                      color: AppColors.sleep,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Son Kayıtlar',
                    style: AppTypography.headlineSmall
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (recentEntries.length > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Tüm kayıtları gösteren bir sayfaya yönlendir
                  },
                  child: const Text('Tümünü Gör'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          ...recentEntries
              .map((entry) => _buildEntryCard(entry, sleepProvider))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEntryCard(SleepEntry entry, SleepProvider sleepProvider) {
    final debt = entry.sleepDebt;
    final isGood = !debt.isNegative && debt.inMinutes.abs() <= 30;
    final color = isGood
        ? AppColors.success
        : (debt.isNegative ? AppColors.error : AppColors.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sleepProvider.formatDuration(entry.actualSleep)} uyundu',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              sleepProvider.formatSleepDebt(debt),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    if (difference <= 7) return '${difference} gün önce';

    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
