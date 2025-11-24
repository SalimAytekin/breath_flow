import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../services/asset_manager.dart';

class SessionCompletionDialog extends StatefulWidget {
  final String sessionType;
  final int duration;
  
  const SessionCompletionDialog({
    super.key,
    required this.sessionType,
    required this.duration,
  });

  @override
  State<SessionCompletionDialog> createState() => _SessionCompletionDialogState();
}

class _SessionCompletionDialogState extends State<SessionCompletionDialog> 
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250), // Daha hızlı
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300), // Daha hızlı
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack, // Daha performanslı
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Ana dialog içeriği
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isSmallScreen = screenWidth < 400;
                      final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
                      
                      return Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.9,
                        ),
                        margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                            ? const Color(0xFF1A1A1A).withOpacity(0.95)
                            : Colors.white.withOpacity(0.98),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                          border: Border.all(
                            color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 20 : (isMediumScreen ? 24 : 32)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(isSmallScreen, isMediumScreen),
                                SizedBox(height: isSmallScreen ? 20 : 32),
                                _buildActionButton(isSmallScreen, isMediumScreen),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(bool isSmallScreen, bool isMediumScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // 🎉 Tebrik ikonu
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Container(
            width: isSmallScreen ? 80 : (isMediumScreen ? 90 : 100),
            height: isSmallScreen ? 80 : (isMediumScreen ? 90 : 100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF2E7D32),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              FeatherIcons.checkCircle,
              color: Colors.white,
              size: isSmallScreen ? 40 : (isMediumScreen ? 44 : 48),
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 20 : 28),

        // Tebrik başlığı
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Tebrikler! 🎉',
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : (isMediumScreen ? 25 : 28),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Alt başlık
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 150),
          child: Text(
            '${widget.sessionType} seansını\n${widget.duration} dakika boyunca tamamladın',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: isSmallScreen ? 20 : 28),

        // Başarı istatistikleri
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : (isMediumScreen ? 20 : 24)),
            decoration: BoxDecoration(
              color: isDarkMode 
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFF4CAF50).withOpacity(0.08),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: isDarkMode 
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : const Color(0xFF4CAF50).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.clock,
                      color: const Color(0xFF4CAF50),
                      size: isSmallScreen ? 18 : 22,
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Text(
                      '${widget.duration} dakika',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Kendine zaman ayırdığın için teşekkürler',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : (isMediumScreen ? 14 : 15),
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(bool isSmallScreen, bool isMediumScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.arrowRight,
                size: isSmallScreen ? 18 : 20,
                color: Colors.white,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Devam Et',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Dialog'u göstermek için static method
  static Future<void> show(
    BuildContext context, {
    required String sessionType,
    required int duration,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionCompletionDialog(
        sessionType: sessionType,
        duration: duration,
      ),
    );
  }
}
