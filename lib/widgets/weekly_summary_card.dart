import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/weekly_activity.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/professional_card.dart';

/// 📊 Haftalık Özet Kartı
/// Son 7 günün aktivite özetini gösterir
class WeeklySummaryCard extends StatefulWidget {
  const WeeklySummaryCard({super.key});

  @override
  State<WeeklySummaryCard> createState() => _WeeklySummaryCardState();
}

class _WeeklySummaryCardState extends State<WeeklySummaryCard> {
  int _selectedTab = 0; // 0: Nefes, 1: Ses

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 400 ? 20.0 : 24.0;
    final titleFontSize = screenWidth < 400 ? 16.0 : 18.0;
    final valueFontSize = screenWidth < 400 ? 28.0 : 32.0;
    
    // ⚡ PERFORMANCE: Use Selector to rebuild only when weekly summary changes
    return Selector<UserPreferencesProvider, WeeklySummary>(
      selector: (context, prefs) => prefs.weeklySummary,
      builder: (context, weeklySummary, child) {
        // ✅ Gerçek haftalık veriler
        final breathingSessions = weeklySummary.totalBreathingSessions;
        final soundSessions = weeklySummary.totalSoundSessions;
        
        // Tab'a göre değerleri hesapla - 🆕 Artık gerçek dakikaları kullanıyoruz
        final displaySessions = _selectedTab == 0 ? breathingSessions : soundSessions;
        final displayMinutes = _selectedTab == 0 
            ? weeklySummary.totalBreathingMinutes 
            : weeklySummary.totalSoundMinutes;
        
        return ProfessionalCard(
          cardType: CardType.elevated,
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      FeatherIcons.barChart2,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.large),
                  Expanded(
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
                                      'Bu Hafta (Pzt-Paz)', // ✅ Açıklayıcı başlık
                                      style: AppTypography.headlineSmall.copyWith(
                                        fontSize: titleFontSize,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.tiny),
                                    Text(
                                      AppStrings.activitySummary,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          // 🆕 Info Butonu
                          IconButton(
                            icon: Icon(
                              FeatherIcons.info,
                              color: AppColors.primaryAccent,
                              size: 20,
                            ),
                            onPressed: () => _showInfoDialog(context),
                            tooltip: 'Nasıl hesaplanıyor?',
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.border.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // Tab Selector
              _buildTabSelector(),
              
              const SizedBox(height: AppSpacing.large),
              
              // Aktivite İstatistikleri
              Row(
                children: [
                  // Toplam Seans
                  Expanded(
                    child: _buildStatItem(
                      icon: FeatherIcons.activity,
                      value: displaySessions.toString(),
                      label: AppStrings.session,
                      color: _selectedTab == 0 ? AppColors.focus : AppColors.relaxation,
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border.withOpacity(0.3),
                  ),
                  
                  // Toplam Dakika
                  Expanded(
                    child: _buildStatItem(
                      icon: FeatherIcons.clock,
                      value: displayMinutes.toString(),
                      label: AppStrings.minutes,
                      color: _selectedTab == 0 ? AppColors.focus : AppColors.relaxation,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.medium),
              
              // Motivasyon Mesajı
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  color: (_selectedTab == 0 ? AppColors.focus : AppColors.relaxation).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: (_selectedTab == 0 ? AppColors.focus : AppColors.relaxation).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FeatherIcons.trendingUp,
                      color: _selectedTab == 0 ? AppColors.focus : AppColors.relaxation,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Text(
                        _getMotivationalMessage(displaySessions, _selectedTab),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 400 ? 20.0 : 24.0;
    final valueFontSize = screenWidth < 400 ? 28.0 : 32.0;
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          value,
          style: AppTypography.displaySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
          ),
        ),
        const SizedBox(height: AppSpacing.tiny),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTab(
            icon: FeatherIcons.wind,
            label: AppStrings.breathActivity,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: _buildTab(
            icon: FeatherIcons.volume2,
            label: AppStrings.soundActivity,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected 
        ? (_selectedTab == 0 ? AppColors.focus : AppColors.relaxation)
        : AppColors.textSecondary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.small),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(int sessions, int tabIndex) {
    final activityName = tabIndex == 0 ? 'nefes egzersizi' : 'ses dinleme';
    
    if (sessions == 0) {
      // ✅ Daha motivasyonlu boş state mesajı
      return tabIndex == 0 
          ? '🌟 İlk adımı atmaya hazır mısın? Bir nefes egzersizi ile başla!'
          : '🎵 Rahatlatıcı seslerle huzuru keşfet. İlk seansını başlat!';
    } else if (sessions == 1) {
      // 🆕 İlk seansı kutlama mesajı
      return '🎉 Harika başlangıç! İlk $activityName seansını tamamladın. Devam et!';
    } else if (sessions < 5) {
      return '💪 ${AppStrings.greatStart} $sessions seans yaptın, hedefine yaklaşıyorsun!';
    } else if (sessions < 10) {
      return '⭐ ${AppStrings.goingSuperb} $sessions seans! Muhteşem bir hafta geçiriyorsun!';
    } else {
      return '🏆 ${AppStrings.amazingWeek} $sessions seans! Sen bir şampiyonsun!';
    }
  }

  /// 🆕 İstatistik açıklama dialogu
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Icon(
                FeatherIcons.barChart2,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                'Haftalık İstatistikler',
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
            _buildInfoItem(
              icon: FeatherIcons.calendar,
              title: 'Hafta Tanımı',
              description: 'Pazartesi\'den Pazar\'a kadar olan 7 günlük periyodu gösterir.',
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildInfoItem(
              icon: FeatherIcons.activity,
              title: 'Seans Sayısı',
              description: 'Bu hafta yaptığın tüm nefes egzersizi veya ses dinleme seanslarının toplamıdır.',
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildInfoItem(
              icon: FeatherIcons.clock,
              title: 'Toplam Dakika',
              description: 'Bu hafta aktivitelere ayırdığın toplam süre dakika cinsinden gösterilir.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Anladım',
              style: TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.tiny),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryAccent,
            size: 16,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.tiny),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
