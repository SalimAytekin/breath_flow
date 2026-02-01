import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/premium_provider.dart';
import '../models/premium_trigger.dart';
import 'smart_premium_dialog.dart';

/// 🏷️ Premium Badge - Küçük elmas rozeti
class PremiumBadge extends StatelessWidget {
  final double size;
  final bool showBackground;
  
  const PremiumBadge({
    super.key,
    this.size = 20,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showBackground) {
      return Container(
        padding: EdgeInsets.all(size * 0.3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(size * 0.4),
          border: Border.all(
            color: AppColors.premium.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.diamond,
          color: AppColors.premium,
          size: size,
        ),
      );
    }
    
    return Icon(
      Icons.diamond,
      color: AppColors.premium,
      size: size,
    );
  }
}

/// 🔒 Premium Lock Overlay - İçeriği kilitle
class PremiumLockOverlay extends StatelessWidget {
  final Widget child;
  final String featureId;
  final String? featureName;
  final bool showLockIcon;
  
  const PremiumLockOverlay({
    super.key,
    required this.child,
    required this.featureId,
    this.featureName,
    this.showLockIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        // Premium kullanıcılar için direkt içeriği göster
        if (premium.isPremiumUser) {
          return child;
        }
        
        // Premium değilse kilit overlay ekle
        return GestureDetector(
          onTap: () => _showPremiumDialog(context),
          child: Stack(
            children: [
              // Orijinal içerik (blur/dim)
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
                child: child,
              ),
              
              // Kilit ikonu
              if (showLockIcon)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.premium,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock,
                        color: AppColors.premium,
                        size: 32,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _showPremiumDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
      (t) => t.targetFeatures.contains(featureId),
      orElse: () => PremiumTrigger.predefinedTriggers.first,
    );
    SmartPremiumDialog.show(context, trigger);
  }
}

/// 🎯 Premium Gated Widget - Premium kontrolü ile widget göster
class PremiumGated extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;
  final String featureId;
  final bool showDialog;
  
  const PremiumGated({
    super.key,
    required this.child,
    required this.featureId,
    this.lockedChild,
    this.showDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (premium.isPremiumUser) {
          return child;
        }
        
        if (lockedChild != null) {
          return GestureDetector(
            onTap: showDialog ? () => _showPremiumDialog(context) : null,
            child: lockedChild,
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  void _showPremiumDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
      (t) => t.targetFeatures.contains(featureId),
      orElse: () => PremiumTrigger.predefinedTriggers.first,
    );
    SmartPremiumDialog.show(context, trigger);
  }
}

/// 💎 Premium Satın Al Butonu
class PremiumPurchaseButton extends StatelessWidget {
  final String? text;
  final bool compact;
  final VoidCallback? onTap;
  
  const PremiumPurchaseButton({
    super.key,
    this.text,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        // Zaten premium ise gösterme
        if (premium.isPremiumUser) {
          return const SizedBox.shrink();
        }
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (onTap != null) {
              onTap!();
            } else {
              _showPremiumDialog(context);
            }
          },
          child: Container(
            padding: compact 
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.premium,
                  AppColors.premium.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(compact ? 16 : 24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premium.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: compact ? 16 : 20,
                ),
                SizedBox(width: compact ? 6 : 8),
                Text(
                  text ?? AppStrings.upgradeToPremium,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showPremiumDialog(BuildContext context) {
    final trigger = PremiumTrigger.predefinedTriggers.first;
    SmartPremiumDialog.show(context, trigger);
  }
}

/// 🏅 Premium Status Badge - Kullanıcı durumu göster
class PremiumStatusBadge extends StatelessWidget {
  const PremiumStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (!premium.isPremiumUser) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.premium,
                AppColors.premium.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 🎨 Premium Content Badge - İçerik üzerinde PRO rozeti
class PremiumContentBadge extends StatelessWidget {
  final bool isPremiumContent;
  final EdgeInsets? margin;
  
  const PremiumContentBadge({
    super.key,
    required this.isPremiumContent,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremiumContent) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.premium.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.premium.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
