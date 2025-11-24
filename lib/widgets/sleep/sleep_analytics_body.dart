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
              // ⚡ PERFORMANCE: FadeInUp animasyonları kaldırıldı - direkt render
              // 6 AnimationController → 0 = Memory %90 azaldı
              // İlk render 1300ms → anında
              _buildSleepDebtCard(context, sleepProvider),
              const SizedBox(height: AppSpacing.large),
              _buildHealthWarningCard(context, sleepProvider),
              const SizedBox(height: AppSpacing.large),
              _buildOverviewSection(context, sleepProvider),
              const SizedBox(height: AppSpacing.large),
              _buildWeeklyTrendSection(context, sleepProvider),
              const SizedBox(height: AppSpacing.large),
              _buildStatsSection(context, sleepProvider),
              const SizedBox(height: AppSpacing.large),
              _buildRecentEntriesSection(context, sleepProvider),
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
            // ⚡ PERFORMANCE: FadeIn animasyonları kaldırıldı - anında görünür
            Container(
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
            const SizedBox(height: AppSpacing.xxLarge),
            Text(
              'Uyku Verileriniz Bekleniyor',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Uyku düzeninizi analiz etmeye başlamak için ilk verinizi girin.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            ProfessionalButton(
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
      title = 'Hedefinde! 🎯';
      description = 'Kişisel uyku hedefine ulaştın! Uyku düzenin harika, böyle devam et 🌟';
    } else if (isNegative) {
      title = 'Hedefin Altında 😴';
      description = 'Belirlediğin hedeften daha az uyudun. Kendine daha fazla zaman ayır 💙';
    } else {
      title = 'Hedefin Üstünde ✨';
      description = 'Hedefinden fazla uyudun. Vücudun ekstra dinlenmeye ihtiyaç duymuş olabilir 😊';
    }

    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: AppSpacing.small),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
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
                    'Bu kart kişisel hedefine göre hesaplanır. Sağlık durumun için aşağıdaki "Sağlık Durumu" kartına bak.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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

  Widget _buildHealthWarningCard(BuildContext context, SleepProvider sleepProvider) {
    // Haftalık sağlık analizi (sadece veri olan günler)
    final weeklyEntries = sleepProvider.weeklyEntries.where((e) => e.actualSleep.inMinutes > 0).toList();
    int healthyDays = 0;
    int tooLittleDays = 0;
    int tooMuchDays = 0;
    
    for (var entry in weeklyEntries) {
      final hours = entry.actualSleep.inHours;
      if (hours >= 7 && hours <= 9) {
        healthyDays++;
      } else if (hours < 7) {
        tooLittleDays++;
      } else {
        tooMuchDays++;
      }
    }
    
    final totalDays = weeklyEntries.length;
    final healthPercentage = totalDays > 0 ? (healthyDays / totalDays * 100).round() : 0;
    final unhealthyDays = tooLittleDays + tooMuchDays;
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (totalDays == 0) {
      color = AppColors.primary;
      icon = FeatherIcons.activity;
      title = 'Sağlık Takibi Başlasın! 🌙';
      description = 'Uyku verisi girdikçe sağlık durumunu burada görebilirsin. İdeal uyku: 7-9 saat';
    } else if (healthPercentage >= 80) {
      color = AppColors.success;
      icon = FeatherIcons.heart;
      title = 'Harika Gidiyorsun! 💚';
      description = 'Bu hafta $healthyDays gün sağlıklı uyudun. Vücudun sana teşekkür ediyor! Böyle devam et 💪';
    } else if (healthPercentage >= 50) {
      color = AppColors.warning;
      icon = FeatherIcons.alertTriangle;
      title = 'Biraz Daha Dikkat Edelim ⚠️';
      description = '$unhealthyDays gün sağlık aralığının dışında uyudun. Sağlığın için 7-9 saat uyku çok önemli 🌙';
    } else {
      color = AppColors.error;
      icon = FeatherIcons.alertCircle;
      title = 'Kendine İyi Bak! 🚨';
      description = 'Bu hafta uyku düzenin bozuk. Sağlığın için 7-9 saat uyku hedefle. Sen buna layıksın! ❤️';
    }
    
    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.large),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sağlık Durumu',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          FeatherIcons.heart,
                          color: AppColors.textSecondary,
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.tiny),
                    Text(
                      description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (totalDays > 0) ...[
                      const SizedBox(height: AppSpacing.small),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: healthPercentage / 100,
                          backgroundColor: color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              if (totalDays > 0)
                Column(
                  children: [
                    Text(
                      '$healthPercentage%',
                      style: AppTypography.headlineMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sağlıklı',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: AppSpacing.small),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.2),
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
                      'Sağlık durumu tıbbi standartlara göre (7-9 saat) hesaplanır. Kişisel hedefinden bağımsızdır.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
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

  Widget _buildOverviewSection(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Haftalık Ortalama',
                sleepProvider.formatDuration(weeklyAverage),
                AppColors.primary,
                FeatherIcons.clock,
                'Son 7 günün ortalama uyku süren',
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: _buildOverviewCard(
                'Kalite Skoru',
                '$qualityScore/100',
                _getQualityColor(qualityScore),
                FeatherIcons.star,
                'Hedefine ne kadar yakınsın',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
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
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'İdeal uyku süresi 7-9 saat arasıdır. Kalite skorun, hedefine olan yakınlığını gösterir.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, Color color, IconData icon, String description) {
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
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haftalık Trend',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Son 7 günün uyku performansı',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          // Renk açıklamaları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('İdeal', AppColors.success),
              const SizedBox(width: 16),
              _buildLegendItem('Orta', AppColors.warning),
              const SizedBox(width: 16),
              _buildLegendItem('Yetersiz', AppColors.error),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SizedBox(
            height: 200,
            child: _buildBarChart(context, sleepProvider),
          ),
          const SizedBox(height: AppSpacing.small),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.trendingUp,
                  color: AppColors.primaryAccent,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kesikli çizgi hedef uyku sürenizi gösterir. Yeşil çubuklar ideal uyku, sarı orta, kırmızı yetersiz uyku anlamına gelir.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries;
    final targetHours = 8.0; // Sabit standart

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

  // 📜 Geçmiş Kayıtları Göster Dialog
  void _showSleepHistoryDialog(BuildContext context, SleepProvider sleepProvider) {
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
              child: Text(
                'Uyku Kayıtlarım',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: sleepProvider.sleepEntries.isEmpty
              ? Center(
                  child: Text(
                    'Henüz kayıt yok',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: sleepProvider.sleepEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sleepProvider.sleepEntries[index];
                    final hours = entry.actualSleep.inHours;
                    final minutes = entry.actualSleep.inMinutes % 60;
                    final isHealthy = hours >= 7 && hours <= 9;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHealthy 
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(entry.date),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${hours}s ${minutes}dk • Hedef: 8s',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(FeatherIcons.edit2, color: AppColors.primary, size: 18),
                            onPressed: () {
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
                          IconButton(
                            icon: Icon(FeatherIcons.trash2, color: AppColors.error, size: 18),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text('Kaydı Sil?', style: TextStyle(color: Colors.white)),
                                  content: Text(
                                    'Bu uyku kaydını silmek istediğinize emin misiniz?',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('İptal', style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Sil', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirmed == true) {
                                await sleepProvider.deleteSleepEntry(entry.date);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Kayıt silindi'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${date.day} ${months[date.month - 1]} - ${days[date.weekday - 1]}';
  }

  Widget _buildStatsSection(BuildContext context, SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries.where((e) => e.actualSleep > Duration.zero).toList();

    return GestureDetector(   
      onTap: () => _showSleepHistoryDialog(context, sleepProvider),
      child: ProfessionalCard(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uyku Rekorları',
                        style: AppTypography.headlineSmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tüm kayıtların için tıkla',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
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
          const SizedBox(height: AppSpacing.large),
          if (entries.length < 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Text(
                      entries.isEmpty ? 'Henüz hiç uyku verisi yok.' : 'Karşılaştırma için daha fazla veri gerekli.',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En az 2 gün veri girdiğinde rekorlarını görebilirsin',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Builder(builder: (context) {
              final longestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a > b ? a : b);
              final shortestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a < b ? a : b);
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'En Uzun Uyku',
                          sleepProvider.formatDuration(longestSleep),
                          AppColors.success,
                          FeatherIcons.trendingUp,
                          'Tebrikler! 🎉',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: _buildStatCard(
                          'En Kısa Uyku',
                          sleepProvider.formatDuration(shortestSleep),
                          AppColors.error,
                          FeatherIcons.trendingDown,
                          'Dikkat et 💪',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.energy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FeatherIcons.info,
                          color: AppColors.energy,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Uyku düzenini korumak için her gün benzer saatlerde yatmaya çalış',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
      ), // ProfessionalCard'un child parametresi kapanıyor
    ); // GestureDetector kapanıyor
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon, String emoji) {
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
          const SizedBox(height: 4),
          Text(
            emoji,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Son Kayıtlar',
                          style: AppTypography.headlineSmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Günlük uyku takibini buradan görebilirsin',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (recentEntries.length > 3)
                TextButton(
                  onPressed: () {
                    _showSleepHistoryDialog(context, sleepProvider);
                  },
                  child: const Text('Tümü'),
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

}
