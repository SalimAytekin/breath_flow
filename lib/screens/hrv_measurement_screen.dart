import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/hrv_provider.dart';
import '../models/hrv_measurement.dart';
import '../widgets/hrv_measurement_widget.dart';
import '../widgets/hrv_results_widget.dart';

class HRVMeasurementScreen extends StatefulWidget {
  final String? sessionType;
  
  const HRVMeasurementScreen({
    super.key,
    this.sessionType,
  });

  @override
  State<HRVMeasurementScreen> createState() => _HRVMeasurementScreenState();
}

class _HRVMeasurementScreenState extends State<HRVMeasurementScreen> {
  bool _showInstructions = true;
  
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
          'Stres Seviyesi Ölçümü',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HRVProvider>(
        builder: (context, hrvProvider, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Durum göstergesi
                  _buildStatusCard(hrvProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Ana içerik
                  Expanded(
                    child: _buildMainContent(hrvProvider),
                  ),
                  
                  // Alt butonlar
                  if (hrvProvider.state == HRVMeasurementState.idle)
                    _buildStartButton(hrvProvider),
                    
                  if (hrvProvider.state == HRVMeasurementState.measuring)
                    _buildMeasurementControls(hrvProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(HRVProvider provider) {
    String statusText;
    IconData statusIcon;
    Color statusColor;
    
    switch (provider.state) {
      case HRVMeasurementState.idle:
        statusText = 'Ölçüm Hazır';
        statusIcon = FeatherIcons.activity;
        statusColor = AppColors.primary;
        break;
      case HRVMeasurementState.requesting_permission:
        statusText = 'İzin İsteniyor...';
        statusIcon = FeatherIcons.camera;
        statusColor = AppColors.warning;
        break;
      case HRVMeasurementState.preparing:
        statusText = 'Hazırlanıyor...';
        statusIcon = FeatherIcons.clock;
        statusColor = AppColors.info;
        break;
      case HRVMeasurementState.measuring:
        statusText = 'Ölçüm Yapılıyor...';
        statusIcon = FeatherIcons.heart;
        statusColor = AppColors.success;
        break;
      case HRVMeasurementState.processing:
        statusText = 'İşleniyor...';
        statusIcon = FeatherIcons.cpu;
        statusColor = AppColors.focus;
        break;
      case HRVMeasurementState.completed:
        statusText = 'Tamamlandı!';
        statusIcon = FeatherIcons.checkCircle;
        statusColor = AppColors.success;
        break;
      case HRVMeasurementState.error:
        statusText = 'Hata: ${provider.error?.message ?? 'Bilinmeyen hata'}';
        statusIcon = FeatherIcons.alertCircle;
        statusColor = AppColors.error;
        break;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (provider.state == HRVMeasurementState.measuring)
            Text(
              '${(provider.measurementProgress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(HRVProvider provider) {
    switch (provider.state) {
      case HRVMeasurementState.idle:
        return _showInstructions 
            ? _buildInstructions()
            : _buildLatestResults(provider);
            
      case HRVMeasurementState.measuring:
        return _buildMeasurementView(provider);
        
      case HRVMeasurementState.completed:
        return _buildCompletedView(provider);
        
      case HRVMeasurementState.error:
        return _buildErrorView(provider);
        
      default:
        return _buildLoadingView();
    }
  }

  Widget _buildInstructions() {
    return FadeInUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FeatherIcons.smartphone,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Stres Seviyenizi Ölçün',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Telefonunuzun arka kamerasına parmak ucunuzu koyarak kalp atış hızı değişkenliğinizi ölçebilir ve stres seviyenizi öğrenebilirsiniz.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          _buildInstructionSteps(),
          
          const SizedBox(height: 24),
          
          TextButton(
            onPressed: () {
              setState(() {
                _showInstructions = false;
              });
            },
            child: const Text('Geçmiş Sonuçları Gör'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSteps() {
    final steps = [
      {
        'icon': FeatherIcons.camera,
        'title': 'Kamerayı Açın',
        'description': 'Telefonunuzun arka kamerasına erişim izni verin'
      },
      {
        'icon': FeatherIcons.smartphone,
        'title': 'Parmağınızı Koyun',
        'description': 'İşaret parmağınızı kameraya tamamen kapatacak şekilde koyun'
      },
      {
        'icon': FeatherIcons.clock,
        'title': '60 Saniye Bekleyin',
        'description': 'Parmağınızı hareket ettirmeden 1 dakika bekleyin'
      },
    ];
    
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      step['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLatestResults(HRVProvider provider) {
    if (provider.measurements.isEmpty) {
      return FadeInUp(
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
              'Henüz Ölçüm Yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'İlk stres seviyesi ölçümünüzü yapmak için aşağıdaki butona tıklayın.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _showInstructions = true;
                });
              },
              child: const Text('Nasıl Çalışır?'),
            ),
          ],
        ),
      );
    }
    
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Ölçümler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showInstructions = true;
                  });
                },
                child: const Text('Nasıl Çalışır?'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: provider.measurements.take(5).length,
              itemBuilder: (context, index) {
                final measurement = provider.measurements[index];
                return HRVResultCard(measurement: measurement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementView(HRVProvider provider) {
    return HRVMeasurementWidget(
      provider: provider,
      onComplete: () {
        provider.completeMeasurement(sessionType: widget.sessionType);
      },
    );
  }

  Widget _buildCompletedView(HRVProvider provider) {
    final latestMeasurement = provider.latestMeasurement;
    if (latestMeasurement == null) return _buildLoadingView();
    
    return FadeInUp(
      child: HRVResultsWidget(measurement: latestMeasurement),
    );
  }

  Widget _buildErrorView(HRVProvider provider) {
    return FadeInUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FeatherIcons.alertCircle,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Bir Hata Oluştu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.error?.message ?? 'Bilinmeyen hata',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              provider.cancelMeasurement();
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildStartButton(HRVProvider provider) {
    return FadeInUp(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            provider.startMeasurement(sessionType: widget.sessionType);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FeatherIcons.activity),
              const SizedBox(width: 8),
              Text(
                'Ölçümü Başlat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementControls(HRVProvider provider) {
    return FadeInUp(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                provider.cancelMeasurement();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('İptal Et'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: provider.measurementProgress > 0.8 
                  ? () => provider.completeMeasurement(sessionType: widget.sessionType)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}

// HRV Sonuç Kartı
class HRVResultCard extends StatelessWidget {
  final HRVMeasurement measurement;
  
  const HRVResultCard({
    super.key,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stres seviyesi göstergesi
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(int.parse(measurement.stressLevelColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${measurement.stressLevel.toInt()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(measurement.stressLevelColor.substring(1), radix: 16) + 0xFF000000),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Ölçüm detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.stressLevelDescription,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${measurement.heartRate} BPM • ${_formatTime(measurement.timestamp)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Sağ ok
          Icon(
            FeatherIcons.chevronRight,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
} 