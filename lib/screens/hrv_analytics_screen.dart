import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../providers/hrv_provider.dart';
import '../models/hrv_measurement.dart';
import '../widgets/hrv_results_widget.dart';

class HRVAnalyticsScreen extends StatefulWidget {
  const HRVAnalyticsScreen({super.key});

  @override
  State<HRVAnalyticsScreen> createState() => _HRVAnalyticsScreenState();
}

class _HRVAnalyticsScreenState extends State<HRVAnalyticsScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  String _selectedPeriod = 'Hafta';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'HRV Analitiği',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış'),
            Tab(text: 'Trend'),
            Tab(text: 'Detaylar'),
          ],
        ),
      ),
      body: Consumer<HRVProvider>(
        builder: (context, hrvProvider, child) {
          if (hrvProvider.measurements.isEmpty) {
            return _buildEmptyState();
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(hrvProvider),
              _buildTrendTab(hrvProvider),
              _buildDetailsTab(hrvProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.activity,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz HRV Verisi Yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'İlk stres seviyesi ölçümünüzü yaparak analitikleri görmeye başlayın.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(HRVProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dönem seçici
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Ana metrikler
          FadeInUp(
            child: _buildMainMetrics(provider),
          ),
          
          const SizedBox(height: 24),
          
          // Stres dağılımı
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildStressDistribution(provider),
          ),
          
          const SizedBox(height: 24),
          
          // Son ölçümler
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildRecentMeasurements(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTab(HRVProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dönem seçici
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Stres trend grafiği
          FadeInUp(
            child: _buildStressTrendChart(provider),
          ),
          
          const SizedBox(height: 24),
          
          // Kalp atış hızı trend grafiği
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildHeartRateTrendChart(provider),
          ),
          
          const SizedBox(height: 24),
          
          // HRV metrik trendleri
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildHRVMetricTrends(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(HRVProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dönem seçici
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Detaylı istatistikler
          FadeInUp(
            child: _buildDetailedStats(provider),
          ),
          
          const SizedBox(height: 24),
          
          // Ölçüm geçmişi
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildMeasurementHistory(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Hafta', 'Ay', 'Tümü'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainMetrics(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
    if (measurements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Bu dönemde ölçüm bulunamadı',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    final avgStress = measurements.map((m) => m.stressLevel).reduce((a, b) => a + b) / measurements.length;
    final avgHeartRate = measurements.map((m) => m.heartRate).reduce((a, b) => a + b) / measurements.length;
    final avgRMSSD = measurements.map((m) => m.hrvMetrics['RMSSD'] ?? 0).reduce((a, b) => a + b) / measurements.length;
    
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
          Text(
            'Ana Metrikler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Ortalama Stres',
                  '${avgStress.toStringAsFixed(0)}',
                  FeatherIcons.activity,
                  _getStressColor(avgStress),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Ortalama Kalp Atışı',
                  '${avgHeartRate.toStringAsFixed(0)} BPM',
                  FeatherIcons.heart,
                  AppColors.error,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Ortalama RMSSD',
                  '${avgRMSSD.toStringAsFixed(1)} ms',
                  FeatherIcons.barChart2,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Toplam Ölçüm',
                  '${measurements.length}',
                  FeatherIcons.calendar,
                  AppColors.focus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStressDistribution(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
    final lowStress = measurements.where((m) => m.stressLevel < 30).length;
    final mediumStress = measurements.where((m) => m.stressLevel >= 30 && m.stressLevel < 60).length;
    final highStress = measurements.where((m) => m.stressLevel >= 60 && m.stressLevel < 80).length;
    final veryHighStress = measurements.where((m) => m.stressLevel >= 80).length;
    
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
          Text(
            'Stres Dağılımı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (measurements.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (lowStress > 0)
                      PieChartSectionData(
                        value: lowStress.toDouble(),
                        title: 'Düşük\n$lowStress',
                        color: AppColors.success,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (mediumStress > 0)
                      PieChartSectionData(
                        value: mediumStress.toDouble(),
                        title: 'Orta\n$mediumStress',
                        color: AppColors.warning,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (highStress > 0)
                      PieChartSectionData(
                        value: highStress.toDouble(),
                        title: 'Yüksek\n$highStress',
                        color: AppColors.focus,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (veryHighStress > 0)
                      PieChartSectionData(
                        value: veryHighStress.toDouble(),
                        title: 'Çok Yüksek\n$veryHighStress',
                        color: AppColors.error,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('Veri bulunamadı'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStressTrendChart(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
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
          Text(
            'Stres Seviyesi Trendi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (measurements.length >= 2) ...[
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: measurements.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.stressLevel);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('Trend göstermek için en az 2 ölçüm gerekli'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeartRateTrendChart(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
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
          Text(
            'Kalp Atış Hızı Trendi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (measurements.length >= 2) ...[
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: measurements.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.heartRate.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppColors.error,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.error.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('Trend göstermek için en az 2 ölçüm gerekli'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHRVMetricTrends(HRVProvider provider) {
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
          Text(
            'HRV Metrik Trendleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Bu bölüm geliştirilmekte...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
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
          Text(
            'Detaylı İstatistikler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (measurements.isNotEmpty) ...[
            _buildStatRow('Toplam Ölçüm', '${measurements.length}'),
            _buildStatRow('En Düşük Stres', '${measurements.map((m) => m.stressLevel).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}'),
            _buildStatRow('En Yüksek Stres', '${measurements.map((m) => m.stressLevel).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}'),
            _buildStatRow('En Düşük Kalp Atışı', '${measurements.map((m) => m.heartRate).reduce((a, b) => a < b ? a : b)} BPM'),
            _buildStatRow('En Yüksek Kalp Atışı', '${measurements.map((m) => m.heartRate).reduce((a, b) => a > b ? a : b)} BPM'),
          ] else ...[
            Text(
              'Bu dönemde ölçüm bulunamadı',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMeasurements(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider).take(5).toList();
    
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
          Text(
            'Son Ölçümler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...measurements.map((measurement) => _buildMeasurementTile(measurement)),
        ],
      ),
    );
  }

  Widget _buildMeasurementHistory(HRVProvider provider) {
    final measurements = _getFilteredMeasurements(provider);
    
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
          Text(
            'Ölçüm Geçmişi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...measurements.map((measurement) => _buildMeasurementTile(measurement)),
        ],
      ),
    );
  }

  Widget _buildMeasurementTile(HRVMeasurement measurement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStressColor(measurement.stressLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStressColor(measurement.stressLevel).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStressColor(measurement.stressLevel).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${measurement.stressLevel.toInt()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStressColor(measurement.stressLevel),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.stressLevelDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${measurement.heartRate} BPM • ${_formatDateTime(measurement.timestamp)}',
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

  List<HRVMeasurement> _getFilteredMeasurements(HRVProvider provider) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'Hafta':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Ay':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        return provider.measurements;
    }
    
    return provider.measurements.where((m) => m.timestamp.isAfter(startDate)).toList();
  }

  Color _getStressColor(double stressLevel) {
    if (stressLevel < 30) {
      return AppColors.success;
    } else if (stressLevel < 60) {
      return AppColors.warning;
    } else if (stressLevel < 80) {
      return AppColors.focus;
    } else {
      return AppColors.error;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 