import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../constants/app_colors.dart';

class PremiumAnalyticsWidget extends StatelessWidget {
  const PremiumAnalyticsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        final analytics = premiumProvider.getConversionAnalytics();
        final usageStats = premiumProvider.getPremiumUsageStats();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Premium Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Conversion Analytics
              _buildAnalyticsSection(
                context,
                'Dönüşüm Analitikleri',
                Icons.trending_up,
                AppColors.success,
                [
                  _buildAnalyticsItem(
                    'Toplam Tetikleyici Gösterimi',
                    '${analytics['totalTriggersShown']}',
                    Icons.visibility,
                  ),
                  _buildAnalyticsItem(
                    'Dismiss Edilen',
                    '${analytics['dismissedCount']}',
                    Icons.close,
                  ),
                  _buildAnalyticsItem(
                    'Ortalama Gösterim',
                    '${analytics['averageShowsPerTrigger']?.toStringAsFixed(1) ?? '0'}',
                    Icons.repeat,
                  ),
                  _buildAnalyticsItem(
                    'En Çok Gösterilen',
                    '${analytics['mostShownTrigger'] ?? 'Yok'}',
                    Icons.star,
                  ),
                  _buildAnalyticsItem(
                    'Dönüşüm Oranı',
                    '${(analytics['conversionRate'] * 100).toInt()}%',
                    Icons.percent,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Usage Stats
              if (premiumProvider.isPremiumUser)
                _buildAnalyticsSection(
                  context,
                  'Premium Kullanım İstatistikleri',
                  Icons.star,
                  AppColors.warning,
                  [
                    _buildAnalyticsItem(
                      'Premium Ses Kullanımı',
                      '${usageStats['premiumSoundsUsed']}',
                      Icons.music_note,
                    ),
                    _buildAnalyticsItem(
                      'Gelişmiş Nefes Teknikleri',
                      '${usageStats['advancedBreathingUsed']}',
                      Icons.air,
                    ),
                    _buildAnalyticsItem(
                      'Uzman İçerik Erişimi',
                      '${usageStats['expertContentAccessed']}',
                      Icons.school,
                    ),
                    _buildAnalyticsItem(
                      'Premium Hikaye Dinleme',
                      '${usageStats['premiumStoriesListened']}',
                      Icons.auto_stories,
                    ),
                    _buildAnalyticsItem(
                      'Gelişmiş HRV Kullanımı',
                      '${usageStats['advancedHRVUsed']}',
                      Icons.favorite,
                    ),
                  ],
                ),
              
              const SizedBox(height: 20),
              
              // User Journey
              _buildUserJourneySection(context, premiumProvider),
              
              const SizedBox(height: 20),
              
              // Debug Actions
              if (!premiumProvider.isPremiumUser)
                _buildDebugActions(context, premiumProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserJourneySection(BuildContext context, PremiumProvider provider) {
    final journeys = provider.userContext['userJourneys'] as List<String>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text(
              'Kullanıcı Yolculuğu',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: journeys.isEmpty
              ? const Text(
                  'Henüz yolculuk verisi yok',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: journeys.takeLast(5).map((journey) {
                    final parts = journey.split(': ');
                    if (parts.length == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parts[1],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    DateTime.parse(parts[0]).toString().substring(0, 16),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildDebugActions(BuildContext context, PremiumProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text(
              'Debug Aksiyonları',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDebugButton(
              'Stres Yolculuğu Tamamlandı',
              () => provider.debugTrigger('stress_journey_completed'),
            ),
            _buildDebugButton(
              'Ses Karıştırıcı Limiti',
              () => provider.debugTrigger('sound_mixer_limit'),
            ),
            _buildDebugButton(
              'Uzman İçerik',
              () => provider.debugTrigger('expert_content_teaser'),
            ),
            _buildDebugButton(
              'Güçlü Kullanıcı',
              () => provider.debugTrigger('power_user_offer'),
            ),
            _buildDebugButton(
              'Nefes Ustası',
              () => provider.debugTrigger('breathing_master'),
            ),
            _buildDebugButton(
              'HRV Analizi',
              () => provider.debugTrigger('hrv_advanced_analysis'),
            ),
            _buildDebugButton(
              'Haftalık Hedef',
              () => provider.debugTrigger('weekly_goal_achieved'),
            ),
            _buildDebugButton(
              'Premium Hikaye',
              () => provider.debugTrigger('story_series_premium'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebugButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warning.withOpacity(0.1),
        foregroundColor: AppColors.warning,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// Extension to get last N elements from list
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
} 