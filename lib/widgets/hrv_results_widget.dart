import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../models/hrv_measurement.dart';

class HRVResultsWidget extends StatelessWidget {
  final HRVMeasurement measurement;
  
  const HRVResultsWidget({
    super.key,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana sonuç kartı
          FadeInUp(
            child: _buildMainResultCard(context),
          ),
          
          const SizedBox(height: 24),
          
          // Detaylı metriker
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildDetailedMetrics(context),
          ),
          
          const SizedBox(height: 24),
          
          // HRV grafiği
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildHRVChart(context),
          ),
          
          const SizedBox(height: 24),
          
          // Öneriler
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildRecommendations(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResultCard(BuildContext context) {
    final stressColor = Color(
      int.parse(measurement.stressLevelColor.substring(1), radix: 16) + 0xFF000000
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stressColor.withOpacity(0.1),
            stressColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stressColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Stres seviyesi göstergesi
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stressColor.withOpacity(0.1),
              border: Border.all(color: stressColor, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${measurement.stressLevel.toInt()}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stressColor,
                  ),
                ),
                Text(
                  'STRES',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: stressColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            measurement.stressLevelDescription,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: stressColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _getStressLevelExplanation(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Kalp atış hızı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.heart,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${measurement.heartRate} BPM',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            'Detaylı HRV Metrikleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildMetricRow(
            context,
            'RMSSD',
            '${measurement.hrvMetrics['RMSSD']?.toStringAsFixed(1) ?? 'N/A'} ms',
            'Parasempatik aktivite göstergesi',
            FeatherIcons.activity,
            AppColors.primary,
          ),
          
          const SizedBox(height: 16),
          
          _buildMetricRow(
            context,
            'SDNN',
            '${measurement.hrvMetrics['SDNN']?.toStringAsFixed(1) ?? 'N/A'} ms',
            'Genel HRV varyasyonu',
            FeatherIcons.barChart2,
            AppColors.info,
          ),
          
          const SizedBox(height: 16),
          
          _buildMetricRow(
            context,
            'pNN50',
            '${measurement.hrvMetrics['pNN50']?.toStringAsFixed(1) ?? 'N/A'}%',
            'Kalp ritmi düzenliliği',
            FeatherIcons.percent,
            AppColors.success,
          ),
          
          const SizedBox(height: 16),
          
          _buildMetricRow(
            context,
            'Mean NN',
            '${measurement.hrvMetrics['meanNN']?.toStringAsFixed(0) ?? 'N/A'} ms',
            'Ortalama R-R aralığı',
            FeatherIcons.clock,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHRVChart(BuildContext context) {
    if (measurement.rrIntervals.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'HRV verisi mevcut değil',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
          Text(
            'R-R Aralık Grafiği',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartSpots(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minX: 0,
                maxX: measurement.rrIntervals.length.toDouble() - 1,
                minY: measurement.rrIntervals.reduce((a, b) => a < b ? a : b) - 50,
                maxY: measurement.rrIntervals.reduce((a, b) => a > b ? a : b) + 50,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Bu grafik kalp atışları arasındaki zaman değişimini gösterir. '
            'Düzenli değişim sağlıklı bir kalp ritmi işaretidir.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final recommendations = _getRecommendations();
    
    return Container(
      width: double.infinity,
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
                FeatherIcons.info,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Öneriler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartSpots() {
    return measurement.rrIntervals.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  String _getStressLevelExplanation() {
    if (measurement.stressLevel < 30) {
      return 'Harika! Stres seviyen çok düşük. Rahat ve sakin hissediyorsun.';
    } else if (measurement.stressLevel < 60) {
      return 'İyi durumdasın. Hafif stres var ama yönetilebilir seviyede.';
    } else if (measurement.stressLevel < 80) {
      return 'Stres seviyen yüksek. Rahatlama egzersizleri yapman önerilir.';
    } else {
      return 'Stres seviyen çok yüksek. Derhal dinlenme ve rahatlama teknikleri uygula.';
    }
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    
    if (measurement.stressLevel < 30) {
      recommendations.addAll([
        'Mevcut rahatlama durumunu korumak için düzenli uyku düzenine devam et',
        'Pozitif ruh halini sürdürmek için sevdiğin aktiviteleri yapmaya devam et',
        'Bu sakin dönemde yeni hedefler belirleyebilirsin',
      ]);
    } else if (measurement.stressLevel < 60) {
      recommendations.addAll([
        'Günde 10-15 dakika nefes egzersizi yap',
        'Düzenli yürüyüş veya hafif egzersiz yap',
        'Uyku düzenine dikkat et, günde 7-8 saat uyumaya çalış',
      ]);
    } else if (measurement.stressLevel < 80) {
      recommendations.addAll([
        'Günde 2-3 kez derin nefes egzersizi yap',
        'Meditasyon veya mindfulness egzersizleri dene',
        'Kafein tüketimini azalt',
        'Stres kaynaklarını belirleyip çözüm yolları ara',
      ]);
    } else {
      recommendations.addAll([
        'Hemen derin nefes egzersizi yap ve rahatlamaya odaklan',
        'Mümkünse stresli ortamdan uzaklaş',
        'Uzman yardımı almayı düşün',
        'Acil durumda sevdiklerinle konuş',
      ]);
    }
    
    // Kalp atış hızına göre ek öneriler
    if (measurement.heartRate > 100) {
      recommendations.add('Kalp atış hızın yüksek, yavaş ve derin nefes al');
    } else if (measurement.heartRate < 60) {
      recommendations.add('Kalp atış hızın düşük, hafif aktivite yapabilirsin');
    }
    
    return recommendations;
  }
} 