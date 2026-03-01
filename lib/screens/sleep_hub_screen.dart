import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/sleep_provider.dart';
import '../widgets/global_background.dart';
import '../widgets/professional_app_bar.dart';
import '../ui/components/ad_container.dart';
import 'sleep_input_screen.dart';
import 'sleep_analytics_screen.dart';
import 'sleep_journal_screen.dart';

/// 🌙 Uyku Hub Ekranı
/// Uyku Girişi, Uyku Analizi ve Rüya Günlüğü'ne kolay erişim sağlar.
class SleepHubScreen extends StatefulWidget {
  const SleepHubScreen({super.key});

  @override
  State<SleepHubScreen> createState() => _SleepHubScreenState();
}

class _SleepHubScreenState extends State<SleepHubScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sleepProvider = context.watch<SleepProvider>();
    final topPadding = MediaQuery.of(context).padding.top;
    final hasData = sleepProvider.sleepEntries.isNotEmpty;

    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: ProfessionalAppBar(
          scrollController: _scrollController,
          title: AppStrings.sleepTrackingTitle,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            topPadding + kToolbarHeight + 12,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌙 Özet banner
              _buildSummaryBanner(sleepProvider),

              const SizedBox(height: 20),

              // 🎯 Hızlı Erişim — 3 kart yan yana
              _buildQuickActions(),

              const SizedBox(height: 20),

              // 📊 Haftalık Mini İstatistik (veri varsa)
              if (hasData) ...[
                _buildWeeklyMiniStats(sleepProvider),
                const SizedBox(height: 20),
              ],

              // 💡 İpucu Kartı (veri yoksa)
              if (!hasData) ...[
                _buildOnboardingTip(),
                const SizedBox(height: 20),
              ],

              // 📋 Son Kayıtlar
              _buildRecentEntries(sleepProvider),

              const SizedBox(height: 20),
              
              // 🎯 Banner Reklam
              const AdContainer(placement: 'sleep_hub_bottom'),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌙 Özet banner — haftalık ortalama + kalite skoru
  Widget _buildSummaryBanner(SleepProvider sleepProvider) {
    final weeklyAvg = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;
    final hasData = sleepProvider.sleepEntries.isNotEmpty;

    final avgHours = weeklyAvg.inHours;
    final avgMinutes = weeklyAvg.inMinutes % 60;

    Color qualityColor;
    String qualityLabel;
    if (qualityScore >= 80) {
      qualityColor = AppColors.success;
      qualityLabel = AppStrings.qualityGreat;
    } else if (qualityScore >= 60) {
      qualityColor = AppColors.warning;
      qualityLabel = AppStrings.qualityModerate;
    } else {
      qualityColor = AppColors.error;
      qualityLabel = AppStrings.qualityLow;
    }

    return GestureDetector(
      onTap: hasData
          ? () => _navigateTo(const SleepAnalyticsScreen())
          : () => _navigateTo(const SleepInputScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: hasData
            ? Row(
                children: [
                  // Sol — ikon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.sleep.withOpacity(0.15),
                    ),
                    child: const Icon(
                      FeatherIcons.moon,
                      color: AppColors.sleep,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Orta — ortalama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.weeklyAverageLabel,
                          style: const TextStyle(
                            color: Color(0xFFA09080),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.hoursMinFormat(avgHours, avgMinutes),
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sağ — kalite skoru
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: qualityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: qualityColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$qualityScore',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: qualityColor,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          qualityLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: qualityColor.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                    ),
                    child: const Icon(
                      FeatherIcons.moon,
                      color: Color(0xFFD4AF37),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.startSleepTracking,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.firstSleepDataPrompt,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                    color: AppColors.sleep.withOpacity(0.4),
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  /// 🎯 Hızlı Erişim — 3 aksiyon kartı
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
           AppStrings.whatWouldYouLikeToDo,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // Uyku Verisi Gir — ana CTA
        _buildActionCard(
          icon: FeatherIcons.plusCircle,
           title: AppStrings.enterSleepData,
          subtitle: AppStrings.recordBedAndWakeTime,
          color: AppColors.sleep,
          onTap: () => _navigateTo(const SleepInputScreen()),
        ),

        const SizedBox(height: 10),

        // Analiz + Rüya Günlüğü — yan yana
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                icon: FeatherIcons.barChart2,
                title: AppStrings.sleepAnalysisLabel,
                subtitle: AppStrings.weeklyTrendLabel,
                color: AppColors.focus,
                onTap: () => _navigateTo(const SleepAnalyticsScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: FeatherIcons.bookOpen,
                title: AppStrings.dreamJournalLabel,
                subtitle: AppStrings.recordYourDreams,
                color: const Color(0xFF9B8EC4),
                onTap: () => _navigateTo(const SleepJournalScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📊 Haftalık Mini İstatistik — veri varsa gösterilir
  Widget _buildWeeklyMiniStats(SleepProvider sleepProvider) {
    final weeklyAvg = sleepProvider.weeklyAverageSleep;
    final monthlyAvg = sleepProvider.monthlyAverageSleep;
    final debt = sleepProvider.weeklyDebt;
    final daysWithData = sleepProvider.daysWithDataCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
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
              Icon(FeatherIcons.activity, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                AppStrings.thisWeek,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.daysWithDataFormat.replaceAll('{0}', '$daysWithData'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                   AppStrings.weeklyAvgShort,
                   '${weeklyAvg.inHours}${AppStrings.hourShortSuffix} ${weeklyAvg.inMinutes % 60}${AppStrings.minuteShortSuffix}',
                  AppColors.sleep,
                ),
              ),
              Container(
                width: 0.5,
                height: 36,
                color: Colors.white.withOpacity(0.08),
              ),
              Expanded(
                child: _buildMiniStat(
                   AppStrings.monthlyAvgShort,
                   '${monthlyAvg.inHours}${AppStrings.hourShortSuffix} ${monthlyAvg.inMinutes % 60}${AppStrings.minuteShortSuffix}',
                  AppColors.focus,
                ),
              ),
              Container(
                width: 0.5,
                height: 36,
                color: Colors.white.withOpacity(0.08),
              ),
              Expanded(
                child: _buildMiniStat(
                   AppStrings.sleepDebt,
                  sleepProvider.formatSleepDebt(debt),
                  debt.isNegative ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 💡 Onboarding İpucu — veri yoksa gösterilir
  Widget _buildOnboardingTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFD4AF37).withOpacity(0.15),
            ),
            child: const Icon(
              FeatherIcons.info,
              color: Color(0xFFD4AF37),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   AppStrings.startSleepTrackingTip,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                   AppStrings.regularSleepTrackingDesc,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Son Kayıtlar bölümü — her zaman gösterilir
  Widget _buildRecentEntries(SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
               AppStrings.recentRecords,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (entries.length > 5)
              GestureDetector(
                onTap: () => _navigateTo(const SleepAnalyticsScreen()),
                child: Text(
                   AppStrings.viewAll,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  FeatherIcons.moon,
                  color: AppColors.textTertiary.withOpacity(0.5),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                   AppStrings.noSleepRecordsYet,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                   AppStrings.useButtonToCreateFirst,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...entries.take(5).map(
            (entry) => _buildEntryRow(entry, sleepProvider),
          ),
      ],
    );
  }

  /// 🎯 Aksiyon kartı — tam genişlik
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              FeatherIcons.chevronRight,
              color: Color(0xFFA09080),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 📦 Kompakt kart — yarım genişlik
  Widget _buildCompactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Son kayıt satırı
  Widget _buildEntryRow(dynamic entry, SleepProvider sleepProvider) {
    final hours = entry.actualSleep.inHours;
    final minutes = entry.actualSleep.inMinutes % 60;
    final isHealthy = hours >= 7 && hours <= 9;
    final color = isHealthy ? AppColors.success : AppColors.warning;

    return GestureDetector(
      onTap: () {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(entry.date),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.sleptDurationFormat(
                      AppStrings.hoursMinFormat(hours, minutes),
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              sleepProvider.formatSleepDebt(entry.sleepDebt),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              FeatherIcons.chevronRight,
              color: AppColors.textSecondary.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

   String _formatDate(DateTime date) {
    final locale = context.locale.toString();
    final formatter = DateFormat('d MMM - E', locale);
    return formatter.format(date);
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
