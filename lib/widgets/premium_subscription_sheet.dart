import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/premium_provider.dart';
import '../models/premium_trigger.dart';
import '../services/payment_service.dart';

/// Premium abonelik seçim ekranı
/// Aylık ve yıllık abonelik seçeneklerini gösterir
class PremiumSubscriptionSheet extends StatefulWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onPurchaseSuccess;

  const PremiumSubscriptionSheet({
    super.key,
    this.onDismiss,
    this.onPurchaseSuccess,
  });

  /// Bottom sheet olarak göster
  static void show(BuildContext context, {
    VoidCallback? onDismiss,
    VoidCallback? onPurchaseSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumSubscriptionSheet(
        onDismiss: onDismiss,
        onPurchaseSuccess: onPurchaseSuccess,
      ),
    );
  }

  @override
  State<PremiumSubscriptionSheet> createState() => _PremiumSubscriptionSheetState();
}

class _PremiumSubscriptionSheetState extends State<PremiumSubscriptionSheet> {
  int _selectedPlanIndex = 1; // Varsayılan: Yıllık (daha karlı)
  bool _isLoading = false;

  // Abonelik planları
  final List<_SubscriptionPlan> _plans = [
    _SubscriptionPlan(
      id: 'monthly',
      name: 'Aylık',
      price: '₺69,99',
      period: '/ay',
      description: 'Her ay yenilenir',
      offerType: PremiumOfferType.specificFeature,
      savings: null,
      isBestValue: false,
    ),
    _SubscriptionPlan(
      id: 'yearly',
      name: 'Yıllık',
      price: '₺419,99',
      period: '/yıl',
      description: 'Aylık ₺35 - %50 tasarruf',
      offerType: PremiumOfferType.bundleOffer,
      savings: '%50 Tasarruf',
      isBestValue: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPlanCards(),
                  const SizedBox(height: 24),
                  _buildFeaturesList(),
                  const SizedBox(height: 24),
                  _buildSubscribeButton(),
                  const SizedBox(height: 12),
                  _buildRestoreButton(),
                  const SizedBox(height: 16),
                  _buildTermsText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Premium badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'PREMIUM',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tüm Özelliklerin Kilidini Aç',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Reklamsız deneyim, premium sesler ve daha fazlası',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCards() {
    return Row(
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        final isSelected = _selectedPlanIndex == index;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == _plans.length - 1 ? 0 : 6,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryAccent.withOpacity(0.1)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryAccent 
                      : AppColors.cardBackground,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Best value badge
                  if (plan.isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'EN AVANTAJLI',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 24),
                  
                  // Plan name
                  Text(
                    plan.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.price,
                        style: AppTypography.headlineSmall.copyWith(
                          color: isSelected 
                              ? AppColors.primaryAccent 
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan.period,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    plan.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: plan.savings != null 
                          ? AppColors.success 
                          : AppColors.textSecondary,
                      fontWeight: plan.savings != null 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? AppColors.primaryAccent 
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primaryAccent 
                            : AppColors.textSecondary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
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

  Widget _buildFeaturesList() {
    final features = [
      ('Reklamsız deneyim', Icons.block_rounded),
      ('Tüm nefes egzersizleri', Icons.air_rounded),
      ('Premium ses kütüphanesi', Icons.music_note_rounded),
      ('Gelişmiş uyku analizi', Icons.nightlight_round),
      ('Sınırsız mix kaydetme', Icons.playlist_add_rounded),
      ('Öncelikli destek', Icons.support_agent_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Özellikleri',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.$2,
                    color: AppColors.primaryAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  feature.$1,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _plans[_selectedPlanIndex];
    
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePurchase,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Abone Ol - ${selectedPlan.price}${selectedPlan.period}',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleRestore,
      child: Text(
        'Satın Alımları Geri Yükle',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz. '
      'Satın alma işlemi Google Play hesabınızdan gerçekleştirilir.',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    
    try {
      final selectedPlan = _plans[_selectedPlanIndex];
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      
      final success = await premiumProvider.purchasePremium(selectedPlan.offerType);
      
      if (success && mounted) {
        Navigator.pop(context);
        widget.onPurchaseSuccess?.call();
        
        // Başarı mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Premium aboneliğiniz aktif!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma hatası: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    
    try {
      final paymentService = PaymentService.instance;
      final restored = await paymentService.restoreAndSyncPurchases();
      
      if (mounted) {
        if (restored) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Satın alımlar geri yüklendi!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Geri yüklenecek satın alım bulunamadı'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Abonelik planı modeli
class _SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final PremiumOfferType offerType;
  final String? savings;
  final bool isBestValue;

  const _SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.offerType,
    this.savings,
    this.isBestValue = false,
  });
}
