import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'session_completion_dialog.dart';

/// Tam ekran konfeti animasyonu widget'ı
/// Nefes egzersizi tamamlandığında gösterilir
class FullscreenConfettiWidget extends StatefulWidget {
  const FullscreenConfettiWidget({
    super.key,
    required this.onAnimationComplete,
    this.onPopupShow,
    this.sessionType,
    this.duration,
  });

  final VoidCallback onAnimationComplete;
  final VoidCallback? onPopupShow;
  final String? sessionType;
  final int? duration;

  @override
  State<FullscreenConfettiWidget> createState() => _FullscreenConfettiWidgetState();

  /// Tam ekran konfeti göstermek için static method
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => FullscreenConfettiWidget(
        onAnimationComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }
}

class _FullscreenConfettiWidgetState extends State<FullscreenConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Konfeti animasyonu controller'ı
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 3 saniye konfeti
      vsync: this,
    );

    // Fade out animasyonu
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Animasyonu başlat
    _startAnimation();
  }

  void _startAnimation() async {
    // Konfeti animasyonunu başlat
    _animationController.forward();
    
    // 2 saniye sonra popup'ı göster (confetti devam ederken)
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Popup'ı showDialog ile göster ama kategori ekranını yenilemeden
    if (mounted && widget.sessionType != null && widget.duration != null) {
      _showPopup();
    }
    
    // Animasyon tamamlandığında callback'i çağır
    if (mounted) {
      widget.onAnimationComplete();
    }
  }

  void _showPopup() {
    // Popup'ı overlay olarak göster - kategori ekranını yenilemeden
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Arka planı şeffaf yap
      builder: (context) => SessionCompletionDialog(
        sessionType: widget.sessionType!,
        duration: widget.duration!,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Lottie.asset(
              'assets/lottie/confetti_celebration.json',
              fit: BoxFit.cover,
              controller: _animationController,
              repeat: true,
              // Performans optimizasyonları
              frameRate: FrameRate.max, // Maksimum FPS
              options: LottieOptions(
                enableMergePaths: true, // Path'leri birleştir
              ),
              onLoaded: (composition) {
                // Animasyon yüklendiğinde controller'ı ayarla
                // Senin belirlediğin süreyi kullan (2.5 saniye)
                // _animationController.duration = composition.duration; // Bu satırı kaldırdık
              },
            ),
          );
        },
      ),
    );
  }
}
