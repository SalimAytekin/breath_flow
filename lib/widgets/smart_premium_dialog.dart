import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/premium_trigger.dart';
import '../providers/premium_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../screens/login_screen.dart';

class SmartPremiumDialog extends StatefulWidget {
  final PremiumTrigger trigger;
  final VoidCallback? onDismiss;
  final VoidCallback? onPurchase;

  const SmartPremiumDialog({
    Key? key,
    required this.trigger,
    this.onDismiss,
    this.onPurchase,
  }) : super(key: key);

  @override
  State<SmartPremiumDialog> createState() => _SmartPremiumDialogState();

  static void show(
    BuildContext context, 
    PremiumTrigger trigger, {
    VoidCallback? onDismiss,
    VoidCallback? onPurchase,
  }) {
    // 🔐 Misafir kullanıcı kontrolü - önce giriş yapmasını iste
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showLoginRequiredDialog(context);
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmartPremiumDialog(
        trigger: trigger,
        onDismiss: onDismiss,
        onPurchase: onPurchase,
      ),
    );
  }
  
  /// Misafir kullanıcıya giriş yapması gerektiğini söyle
  static void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primaryAccent, size: 28),
            const SizedBox(width: 12),
            Text(
              'Giriş Gerekli',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Premium satın almak için önce giriş yapmanız gerekiyor. Bu sayede satın alımınız hesabınıza kaydedilir ve tüm cihazlarınızda kullanabilirsiniz.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Vazgeç',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Login ekranına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}

class _SmartPremiumDialogState extends State<SmartPremiumDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Seçili plan: 0 = Aylık, 1 = Yıllık
  int _selectedPlanIndex = 1; // Varsayılan: Yıllık (daha karlı)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = PremiumOffer.offers[widget.trigger.offerType]!;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildDialogContent(context, offer),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent(BuildContext context, PremiumOffer offer) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            offer.primaryColor.withOpacity(0.95),
            offer.secondaryColor.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: offer.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, offer),
          _buildContent(context, offer),
          _buildActions(context, offer),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PremiumOffer offer) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => _handleDismiss(context, false),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              widget.trigger.icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Title - Lokalize edilmiş
          Text(
            AppStrings.greatStartTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Description - Lokalize edilmiş
          Text(
            AppStrings.continueWithPremium,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PremiumOffer offer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Plan seçim kartları
          _buildPlanSelector(context),
          
          const SizedBox(height: 16),
          
          // Özellikler listesi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildCompactFeaturesList(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanSelector(BuildContext context) {
    final plans = [
      _PlanOption(
        name: AppStrings.monthlyPlan,
        price: '₺69,99',
        period: AppStrings.perMonth,
        description: AppStrings.renewsMonthly,
        offerType: PremiumOfferType.specificFeature,
        isBestValue: false,
      ),
      _PlanOption(
        name: AppStrings.yearlyPlan,
        price: '₺419,99',
        period: AppStrings.perYear,
        description: AppStrings.yearlySavings,
        offerType: PremiumOfferType.bundleOffer,
        isBestValue: true,
      ),
    ];
    
    return Row(
      children: List.generate(plans.length, (index) {
        final plan = plans[index];
        final isSelected = _selectedPlanIndex == index;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == plans.length - 1 ? 0 : 4,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Best value badge
                  if (plan.isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.bestValueBadge,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                  
                  // Plan name
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.price,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan.period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    plan.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: plan.isBestValue 
                          ? Colors.amber.shade200 
                          : Colors.white.withOpacity(0.7),
                      fontWeight: plan.isBestValue 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Selection indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Colors.white 
                          : Colors.transparent,
                      border: Border.all(
                        color: Colors.white.withOpacity(isSelected ? 1 : 0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: widget.trigger.color,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildCompactFeaturesList(BuildContext context) {
    final features = [
      AppStrings.featureAdFree,
      AppStrings.featureAllExercises,
      AppStrings.featurePremiumSounds,
      AppStrings.featureAdvancedAnalytics,
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: features.map((feature) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white.withOpacity(0.9),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildActions(BuildContext context, PremiumOffer offer) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Primary action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handlePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.trigger.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.getSpecialOffer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Secondary actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _handleDismiss(context, false),
                child: Text(
                  AppStrings.laterButton,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              
              TextButton(
                onPressed: () => _handleDismiss(context, true),
                child: Text(
                  AppStrings.dontShowAgainButton,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Seçili planın offerType'ını döndür
  PremiumOfferType _getSelectedOfferType() {
    return _selectedPlanIndex == 0 
        ? PremiumOfferType.specificFeature  // Aylık
        : PremiumOfferType.bundleOffer;     // Yıllık
  }
  
  void _handlePurchase(BuildContext context) {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    final selectedOfferType = _getSelectedOfferType();
    
    if (premiumProvider.isTestMode) {
      // Test modunda simüle et
      premiumProvider.purchasePremium(selectedOfferType);
      premiumProvider.trackUserAction('premium_purchase_attempted', {
        'triggerId': widget.trigger.id,
        'offerType': selectedOfferType.name,
        'planType': _selectedPlanIndex == 0 ? 'monthly' : 'yearly',
        'source': 'smart_dialog',
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.premiumSuccessTitle} (TEST)'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onPurchase?.call();
      return;
    }

    // Production: Google Play Billing ile gerçek satın alma
    _initiateGooglePlayPurchase(context, premiumProvider);
  }

  /// 🔄 Google Play Billing ile satın alma başlat
  /// PaymentService üzerinden merkezi satın alma - callback ile anında güncelleme
  Future<void> _initiateGooglePlayPurchase(BuildContext context, PremiumProvider premiumProvider) async {
    final selectedOfferType = _getSelectedOfferType();
    
    try {
      // Analytics tracking
      premiumProvider.trackUserAction('premium_purchase_attempted', {
        'triggerId': widget.trigger.id,
        'offerType': selectedOfferType.name,
        'planType': _selectedPlanIndex == 0 ? 'monthly' : 'yearly',
        'source': 'smart_dialog',
      });
      
      // 🔔 PaymentService üzerinden satın alma başlat
      // PaymentService.onPurchaseSuccess callback'i PremiumProvider'ı otomatik güncelleyecek
      final success = await premiumProvider.purchasePremium(selectedOfferType);
      
      if (success) {
        // Dialog'u kapat
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.purchaseStarted),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        
        // onPurchase callback'i çağır
        widget.onPurchase?.call();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.purchaseCannotStart),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDismiss(BuildContext context, bool permanent) {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    // 🚨 DEBUG: Premium durumunu kontrol et
    if (kDebugMode) print('🚨 DEBUG: Dismiss öncesi premium durumu: ${premiumProvider.isPremiumUser}');
    
    // Dismiss tracking
    premiumProvider.trackUserAction('premium_trigger_dismissed', {
      'triggerId': widget.trigger.id,
      'permanent': permanent,
      'source': 'smart_dialog',
    });
    
    // Dismiss trigger
    premiumProvider.dismissTrigger(widget.trigger.id, permanent: permanent);
    
    // 🚨 DEBUG: Premium durumunu tekrar kontrol et
    if (kDebugMode) print('🚨 DEBUG: Dismiss sonrası premium durumu: ${premiumProvider.isPremiumUser}');
    
    Navigator.of(context).pop();
    widget.onDismiss?.call();
  }
}

/// Plan seçeneği modeli
class _PlanOption {
  final String name;
  final String price;
  final String period;
  final String description;
  final PremiumOfferType offerType;
  final bool isBestValue;

  const _PlanOption({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.offerType,
    this.isBestValue = false,
  });
}

// Kompakt premium banner widget'ı
class SmartPremiumBanner extends StatelessWidget {
  final PremiumTrigger trigger;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const SmartPremiumBanner({
    Key? key,
    required this.trigger,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [trigger.color, trigger.color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: trigger.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    trigger.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trigger.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        trigger.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Action button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppStrings.exploreButton,
                    style: TextStyle(
                      color: trigger.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Dismiss button
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Premium özellik kilidi widget'ı
class PremiumFeatureLock extends StatelessWidget {
  final String featureName;
  final String description;
  final IconData icon;
  final VoidCallback? onUnlock;

  const PremiumFeatureLock({
    Key? key,
    required this.featureName,
    required this.description,
    required this.icon,
    this.onUnlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.textSecondary,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            featureName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: onUnlock,
            icon: const Icon(Icons.star),
            label: Text(AppStrings.unlockWithPremium),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 