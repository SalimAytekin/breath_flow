import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/performance_monitor.dart';
import '../constants/app_colors.dart';

/// 🎯 Performans Overlay Widget
/// 
/// Ekranın üstünde performans metriklerini gösterir:
/// - FPS (Kare hızı)
/// - Frame time (Kare süresi)
/// - Jank percentage (Takılma yüzdesi)
/// - Memory usage (Bellek kullanımı - yaklaşık)
class AppPerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AppPerformanceOverlay({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppPerformanceOverlay> createState() => _AppPerformanceOverlayState();
}

class _AppPerformanceOverlayState extends State<AppPerformanceOverlay> {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  Timer? _updateTimer;
  PerformanceReport? _report;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _monitor.startMonitoring();
      
      // Her 500ms'de bir güncelle
      _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          setState(() {
            _report = _monitor.getReport();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _monitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPerformanceColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getPerformanceColor().withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactView() {
    if (_report == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'FPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _report!.emoji,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          '${_report!.fps.toStringAsFixed(0)} FPS',
          style: TextStyle(
            color: _getPerformanceColor(),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    if (_report == null) {
      return const SizedBox(
        width: 200,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _report!.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Performans',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 8),
        _buildMetricRow(
          'FPS',
          '${_report!.fps.toStringAsFixed(1)}',
          _getPerformanceColor(),
        ),
        const SizedBox(height: 4),
        _buildMetricRow(
          'Ort. Frame',
          '${_report!.averageFrameTimeMs.toStringAsFixed(1)}ms',
          _report!.averageFrameTimeMs < 16.67 ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 4),
        _buildMetricRow(
          'Max Frame',
          '${_report!.maxFrameTimeMs.toStringAsFixed(1)}ms',
          _report!.maxFrameTimeMs < 33 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 4),
        _buildMetricRow(
          'Jank',
          '${_report!.jankPercentage.toStringAsFixed(1)}%',
          _report!.jankPercentage < 5 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        Text(
          '${_report!.totalFrames} frame',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor() {
    if (_report == null) return Colors.white;
    
    switch (_report!.level) {
      case PerformanceLevel.excellent:
        return Colors.green;
      case PerformanceLevel.good:
        return Colors.yellow;
      case PerformanceLevel.fair:
        return Colors.orange;
      case PerformanceLevel.poor:
        return Colors.red;
    }
  }
}

/// 🎯 Performans Test Butonu
/// 
/// Debug modda performans testi yapmak için kullanılır
class PerformanceTestButton extends StatelessWidget {
  const PerformanceTestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showPerformanceDialog(context);
      },
      icon: const Icon(Icons.speed),
      label: const Text('Test'),
      backgroundColor: AppColors.primary,
    );
  }

  void _showPerformanceDialog(BuildContext context) {
    final monitor = PerformanceMonitor();
    final report = monitor.getReport();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _getColorForLevel(report.level),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Text(report.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text(
              'Performans Raporu',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportItem('FPS', '${report.fps.toStringAsFixed(1)}', report.level),
              _buildReportItem('Ortalama Frame', '${report.averageFrameTimeMs.toStringAsFixed(2)}ms', null),
              _buildReportItem('Max Frame', '${report.maxFrameTimeMs.toStringAsFixed(2)}ms', null),
              _buildReportItem('Jank Oranı', '${report.jankPercentage.toStringAsFixed(1)}%', null),
              _buildReportItem('Toplam Frame', '${report.totalFrames}', null),
              _buildReportItem('Jank Sayısı', '${report.jankCount}', null),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              _buildRecommendations(report),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              monitor.reset();
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String label, String value, PerformanceLevel? level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: level != null ? _getColorForLevel(level) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(PerformanceReport report) {
    final recommendations = <String>[];

    if (report.fps < 30) {
      recommendations.add('⚠️ FPS çok düşük - Uygulamayı yeniden başlatın');
      recommendations.add('⚠️ Arka plandaki uygulamaları kapatın');
      recommendations.add('⚠️ Cihaz belleği dolmuş olabilir');
    } else if (report.fps < 45) {
      recommendations.add('💡 Orta seviye performans');
      recommendations.add('💡 Bazı animasyonlar yavaş olabilir');
    } else if (report.fps < 55) {
      recommendations.add('✅ İyi performans');
    } else {
      recommendations.add('🎉 Mükemmel performans!');
    }

    if (report.jankPercentage > 10) {
      recommendations.add('⚠️ Yüksek jank oranı - Takılmalar olabilir');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Öneriler:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            rec,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        )),
      ],
    );
  }

  Color _getColorForLevel(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.excellent:
        return Colors.green;
      case PerformanceLevel.good:
        return Colors.yellow;
      case PerformanceLevel.fair:
        return Colors.orange;
      case PerformanceLevel.poor:
        return Colors.red;
    }
  }
}
