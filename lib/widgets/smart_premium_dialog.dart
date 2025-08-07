import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/premium_trigger.dart';
import '../providers/premium_provider.dart';
import '../constants/app_colors.dart';

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
}

class _SmartPremiumDialogState extends State<SmartPremiumDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

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
          
          // Title
          Text(
            widget.trigger.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            widget.trigger.description,
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Offer title
          Text(
            offer.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            offer.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Price
          _buildPriceSection(context, offer),
          
          const SizedBox(height: 16),
          
          // Features
          _buildFeaturesList(context, offer),
          
          // Limited time indicator
          if (offer.isLimitedTime) ...[
            const SizedBox(height: 16),
            _buildLimitedTimeIndicator(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, PremiumOffer offer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (offer.originalPrice.isNotEmpty) ...[
          Text(
            offer.originalPrice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        Text(
          offer.price,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        if (offer.discountPercentage > 0) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-%${offer.discountPercentage}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context, PremiumOffer offer) {
    return Column(
      children: offer.features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLimitedTimeIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Sınırlı Süre!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
                offer.ctaText,
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
                  'Daha Sonra',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              
              TextButton(
                onPressed: () => _handleDismiss(context, true),
                child: Text(
                  'Tekrar Gösterme',
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

  void _handlePurchase(BuildContext context) {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    // Premium satın alma simülasyonu
    premiumProvider.purchasePremium(widget.trigger.offerType);
    
    // Analytics tracking
    premiumProvider.trackUserAction('premium_purchase_attempted', {
      'triggerId': widget.trigger.id,
      'offerType': widget.trigger.offerType.name,
      'source': 'smart_dialog',
    });
    
    Navigator.of(context).pop();
    
    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Premium aktifleştirildi! 🎉'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    widget.onPurchase?.call();
  }

  void _handleDismiss(BuildContext context, bool permanent) {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    // Dismiss tracking
    premiumProvider.trackUserAction('premium_trigger_dismissed', {
      'triggerId': widget.trigger.id,
      'permanent': permanent,
      'source': 'smart_dialog',
    });
    
    // Dismiss trigger
    premiumProvider.dismissTrigger(widget.trigger.id, permanent: permanent);
    
    Navigator.of(context).pop();
    widget.onDismiss?.call();
  }
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
                    'Keşfet',
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
            label: const Text('Premium ile Aç'),
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