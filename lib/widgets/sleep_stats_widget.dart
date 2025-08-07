import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../providers/sleep_provider.dart';
import '../screens/sleep_input_screen.dart';

class SleepStatsWidget extends StatelessWidget {
  final bool isCompact;
  
  const SleepStatsWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        if (isCompact) {
          return _buildCompactView(context, sleepProvider);
        } else {
          return _buildFullView(context, sleepProvider);
        }
      },
    );
  }
  
  Widget _buildCompactView(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final isNegative = weeklyDebt.isNegative;
    
    return GestureDetector(
      onTap: () => _navigateToSleepInput(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sleep.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FeatherIcons.moon,
                    color: AppColors.sleep,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Uyku Borcu',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isNegative ? FeatherIcons.trendingDown : FeatherIcons.trendingUp,
                  color: isNegative ? AppColors.error : AppColors.success,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sleepProvider.formatSleepDebt(weeklyDebt),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNegative ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Son 7 günlük toplam',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullView(BuildContext context, SleepProvider sleepProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sleep.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.moon,
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
                      'Uyku Analizi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son 7 günlük uyku verilerin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _navigateToSleepInput(context),
                icon: Icon(
                  FeatherIcons.plus,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Ana istatistikler
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Uyku Borcu',
                  sleepProvider.formatSleepDebt(sleepProvider.weeklyDebt),
                  sleepProvider.weeklyDebt.isNegative ? AppColors.error : AppColors.success,
                  sleepProvider.weeklyDebt.isNegative ? FeatherIcons.trendingDown : FeatherIcons.trendingUp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Ortalama Uyku',
                  sleepProvider.formatDuration(sleepProvider.weeklyAverageSleep),
                  AppColors.primary,
                  FeatherIcons.clock,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Uyku kalitesi
          _buildQualityCard(context, sleepProvider),
          
          const SizedBox(height: 20),
          
          // Haftalık grafik
          _buildWeeklyChart(context, sleepProvider),
          
          const SizedBox(height: 20),
          
          // Aksiyon butonları
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Bugünü Kaydet',
                  FeatherIcons.plus,
                  AppColors.primary,
                  () => _navigateToSleepInput(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Hedef Ayarla',
                  FeatherIcons.target,
                  AppColors.focus,
                  () => _showTargetDialog(context, sleepProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQualityCard(BuildContext context, SleepProvider sleepProvider) {
    final qualityScore = sleepProvider.sleepQualityScore;
    Color qualityColor;
    String qualityText;
    
    if (qualityScore >= 80) {
      qualityColor = AppColors.success;
      qualityText = 'Mükemmel';
    } else if (qualityScore >= 60) {
      qualityColor = AppColors.warning;
      qualityText = 'İyi';
    } else {
      qualityColor = AppColors.error;
      qualityText = 'Geliştirilmeli';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: qualityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: qualityColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: qualityColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$qualityScore',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: qualityColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uyku Kalitesi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  qualityText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: qualityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Son 30 günlük ortalama',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  
  Widget _buildWeeklyChart(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Haftalık Uyku Grafiği',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyEntries.map((entry) {
              final sleepHours = entry.actualSleep.inMinutes / 60;
              final targetHours = entry.targetHours.toDouble();
              final barHeight = (sleepHours / 12) * 80; // 12 saat max için normalize
              
              final isToday = _isToday(entry.date);
              final color = sleepHours >= targetHours ? AppColors.success : AppColors.error;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Saat göstergesi
                  Text(
                    '${sleepHours.toStringAsFixed(1)}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bar
                  Container(
                    width: 24,
                    height: barHeight.clamp(8, 80),
                    decoration: BoxDecoration(
                      color: isToday ? color.withOpacity(0.8) : color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: isToday ? Border.all(color: color, width: 2) : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Gün
                  Text(
                    _getDayAbbreviation(entry.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Hedefte', AppColors.success),
            const SizedBox(width: 16),
            _buildLegendItem('Eksik', AppColors.error),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  void _navigateToSleepInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepInputScreen(),
      ),
    );
  }
  
  void _showTargetDialog(BuildContext context, SleepProvider sleepProvider) {
    int currentTarget = sleepProvider.defaultTargetHours;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hedef Uyku Süresi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Günlük uyku hedefinizi belirleyin:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                '$currentTarget saat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  value: currentTarget.toDouble(),
                  min: 4,
                  max: 12,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() {
                      currentTarget = value.toInt();
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                sleepProvider.setDefaultTargetHours(currentTarget);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hedef uyku süresi $currentTarget saat olarak güncellendi!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  String _getDayAbbreviation(DateTime date) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }
} 