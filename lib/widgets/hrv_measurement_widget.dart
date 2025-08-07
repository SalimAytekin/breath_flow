import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../providers/hrv_provider.dart';

class HRVMeasurementWidget extends StatefulWidget {
  final HRVProvider provider;
  final VoidCallback onComplete;
  
  const HRVMeasurementWidget({
    super.key,
    required this.provider,
    required this.onComplete,
  });

  @override
  State<HRVMeasurementWidget> createState() => _HRVMeasurementWidgetState();
}

class _HRVMeasurementWidgetState extends State<HRVMeasurementWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  bool _measurementStarted = false;
  int _countdownSeconds = 60;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
    
    // Pulse animasyonunu başlat
    _pulseController.repeat(reverse: true);
    
    // Countdown timer
    _startCountdown();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
        return true;
      }
      return false;
    }).then((_) {
      if (mounted && _countdownSeconds <= 0) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Countdown ve progress
        _buildProgressSection(),
        
        const SizedBox(height: 32),
        
        // Kamera ve ölçüm alanı
        Expanded(
          child: _buildMeasurementArea(),
        ),
        
        const SizedBox(height: 24),
        
        // Ölçüm verileri
        _buildMeasurementData(),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Countdown
        Text(
          _formatCountdown(_countdownSeconds),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.provider.measurementProgress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '${(widget.provider.measurementProgress * 100).toInt()}% tamamlandı',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Heart BPM Widget
            HeartBPMDialog(
              context: context,
              onRawData: (value) {
                widget.provider.onRawData(value);
                if (!_measurementStarted) {
                  setState(() {
                    _measurementStarted = true;
                  });
                  _progressController.forward();
                }
              },
              onBPM: (value) {
                widget.provider.onHeartRate(value);
                // Kalp atışı animasyonunu tetikle
                _triggerHeartBeat();
              },
              child: Container(
                height: 300,
                color: Colors.black,
              ),
            ),
            
            // Overlay instructions
            if (!_measurementStarted)
              _buildInstructionOverlay(),
            
            // Heart beat indicator
            if (_measurementStarted)
              _buildHeartBeatIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      FeatherIcons.smartphone,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInUp(
            child: Text(
              'Parmağınızı Kameraya Koyun',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'İşaret parmağınızı arka kameraya\ntamamen kapatacak şekilde yerleştirin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartBeatIndicator() {
    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FeatherIcons.heart,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementData() {
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
      child: Row(
        children: [
          // Kalp atış hızı
          Expanded(
            child: _buildDataItem(
              icon: FeatherIcons.heart,
              label: 'Kalp Atışı',
              value: widget.provider.currentHeartRate > 0 
                  ? '${widget.provider.currentHeartRate} BPM'
                  : '--',
              color: AppColors.error,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          
          // Veri sayısı
          Expanded(
            child: _buildDataItem(
              icon: FeatherIcons.activity,
              label: 'Veri Noktası',
              value: '${widget.provider.currentRawData.length}',
              color: AppColors.info,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          
          // Kalite göstergesi
          Expanded(
            child: _buildDataItem(
              icon: FeatherIcons.wifi,
              label: 'Kalite',
              value: _getSignalQuality(),
              color: _getSignalQualityColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
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
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getSignalQuality() {
    final dataCount = widget.provider.currentRawData.length;
    if (dataCount < 50) return 'Zayıf';
    if (dataCount < 200) return 'Orta';
    return 'İyi';
  }

  Color _getSignalQualityColor() {
    final dataCount = widget.provider.currentRawData.length;
    if (dataCount < 50) return AppColors.error;
    if (dataCount < 200) return AppColors.warning;
    return AppColors.success;
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _triggerHeartBeat() {
    if (mounted) {
      _pulseController.forward().then((_) {
        if (mounted) {
          _pulseController.reverse();
        }
      });
    }
  }
} 