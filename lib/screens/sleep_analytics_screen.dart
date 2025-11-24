import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/sleep_provider.dart';
import '../widgets/global_background.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import '../ui/components/ad_container.dart';
import 'sleep_input_screen.dart';

/// 📊 Profesyonel Uyku Analizi Sayfası
/// Kullanıcının uyku verilerini detaylı analiz eder ve görselleştirir.
/// Bu ekran, ana iskeleti sağlar ve tüm karmaşık UI mantığını
/// `SleepAnalyticsBody` widget'ına devreder.
class SleepAnalyticsScreen extends StatefulWidget {
  const SleepAnalyticsScreen({super.key});

  @override
  State<SleepAnalyticsScreen> createState() => _SleepAnalyticsScreenState();
}

class _SleepAnalyticsScreenState extends State<SleepAnalyticsScreen> 
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // ⚡ PERFORMANCE: Animation Controllers - duration optimize edildi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // 1500ms → 600ms
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 2500ms → 2000ms
      vsync: this,
    );
    
    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildPremiumAppBar(context),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Consumer<SleepProvider>(
                  builder: (context, sleepProvider, child) {
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Top padding for AppBar
                        SliverToBoxAdapter(
                          child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10),
                        ),
                        
                        // 💰 OPTIMIZATION: Banner sadece veri varsa gösterilir
                        // Empty state'te banner göstermek low quality impression = düşük eCPM
                        if (sleepProvider.sleepEntries.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              child: AdContainer(
                                placement: 'sleep_analytics',
                              ),
                            ),
                          ),
                        
                        // Main Content
                        sleepProvider.sleepEntries.isEmpty
                            ? SliverToBoxAdapter(child: _buildPremiumEmptyState(context))
                            : SliverToBoxAdapter(child: _buildPremiumAnalyticsContent(context, sleepProvider)),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: _buildPremiumFAB(context),
      ),
    );
  }

  // 🎨 Premium AppBar with Optimized Glassmorphism
  // ⚡ PERFORMANCE: BackdropFilter kaldırıldı, gradient+shadow ile %95 aynı görünüm
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.4), // Daha koyu - okunabilirlik için
              Colors.black.withOpacity(0.3),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'Uyku Analizi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 Premium Empty State
  Widget _buildPremiumEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.sleep.withOpacity(0.3),
                        AppColors.sleep.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.sleep.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sleep.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    FeatherIcons.moon,
                    size: 50,
                    color: AppColors.sleep,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          Text(
            'Uyku Analiziniz Hazırlanıyor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Uyku düzeninizi analiz etmeye başlamak için\nilk verinizi girin ve kişiselleştirilmiş\nönerilerinizi keşfedin.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 50),
          
          // Premium Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.sleep,
                  AppColors.sleep.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sleep.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(FeatherIcons.plus, color: Colors.white, size: 20),
              label: Text(
                'İlk Uykunu Kaydet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepInputScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 📊 Premium Analytics Content
  Widget _buildPremiumAnalyticsContent(BuildContext context, SleepProvider sleepProvider) {
    final isPremium = context.read<PremiumProvider>().isPremiumUser;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uyku Takip Özeti (Tıklanabilir)
          _buildPremiumStatsCard(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Sleep Debt Card with improved logic
          _buildPremiumSleepDebtCard(context, sleepProvider),
          
          // Sağlık Durumu Kartı artık her zaman 8 saat standarda göre çalışır
          // Bu bölüm kaldırıldı çünkü artık hedef belirleme yok
          
          const SizedBox(height: 24),
          
          // Weekly Overview Cards (basic visible for all)
          _buildPremiumOverviewCards(context, sleepProvider),
          
          const SizedBox(height: 24),
          
          // Weekly Trend Chart - Premium sistemi askıya alındı, herkese açık
          _buildPremiumTrendChart(context, sleepProvider),
           
          const SizedBox(height: 24),
           
          // Monthly Summary Card - Premium sistemi askıya alındı, herkese açık
          _buildMonthlySummaryCard(context, sleepProvider),
           
          const SizedBox(height: 24),
           
          // Sleep Records - Premium sistemi askıya alındı, herkese açık
          _buildPremiumSleepRecords(context, sleepProvider),
           
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  // 📊 Uyku Takip Özeti Kartı (Tıklanabilir)
  Widget _buildPremiumStatsCard(BuildContext context, SleepProvider sleepProvider) {
    final daysWithData = sleepProvider.daysWithDataCount;
    final totalEntries = sleepProvider.sleepEntries.length;
    
    return GestureDetector(
      onTap: () => _showSleepHistoryDialog(context, sleepProvider),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.2),
              AppColors.primaryAccent.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      FeatherIcons.barChart2,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uyku Takip Özeti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysWithData gün aktif • $totalEntries toplam kayıt',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tüm kayıtlarını görmek için tıkla',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 📜 Geçmiş Kayıtları Göster (Tam Ekran Modal)
  void _showSleepHistoryDialog(BuildContext context, SleepProvider sleepProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Consumer<SleepProvider>(
        builder: (context, provider, child) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FeatherIcons.list,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uyku Kayıtlarım',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detay görmek için kayda tıkla',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.x, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: provider.sleepEntries.isEmpty
              ? Center(
                  child: Text(
                    'Henüz kayıt yok',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.sleepEntries.length,
                  itemBuilder: (context, index) {
                    final entry = provider.sleepEntries[index];
                    final hours = entry.actualSleep.inHours;
                    final minutes = entry.actualSleep.inMinutes % 60;
                    final isHealthy = hours >= 7 && hours <= 9;
                    
                    return GestureDetector(
                      onTap: () {
                        // Detay göster
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                    color: isHealthy ? AppColors.success : AppColors.warning,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDateForDialog(entry.date),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        isHealthy ? 'İdeal Uyku ✓' : 'Yetersiz Uyku',
                                        style: TextStyle(
                                          color: isHealthy ? AppColors.success : AppColors.warning,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(FeatherIcons.moon, 'Uyku Süresi', '${hours}s ${minutes}dk'),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.target, 'Hedef', '8s 0dk'),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.sunset, 'Yatma Saati', _formatTime(entry.bedTime)),
                                const SizedBox(height: 12),
                                _buildDetailRow(FeatherIcons.sunrise, 'Uyanma Saati', _formatTime(entry.wakeTime)),
                                const SizedBox(height: 16),
                                // Sağlık durumu açıklaması
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isHealthy ? FeatherIcons.thumbsUp : FeatherIcons.info,
                                        color: isHealthy ? AppColors.success : AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          isHealthy 
                                            ? 'Harika! İdeal uyku süresinde uyudun. Böyle devam et! 💪'
                                            : hours < 7 
                                              ? 'Az uyudun! Sağlığın için daha fazla uyuman önemli. Kendine daha fazla zaman ayır 💙'
                                              : 'Çok fazla uyudun! Aşırı uyku da yorgunluk yapabilir. Uyku düzenini ayarla ⏰',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.start,
                            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            actions: [
                              TextButton.icon(
                                icon: Icon(FeatherIcons.trash2, color: AppColors.error, size: 18),
                                label: Text('Sil', style: TextStyle(color: AppColors.error)),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('Kaydı Sil?', style: TextStyle(color: Colors.white)),
                                      content: Text(
                                        'Bu uyku kaydını silmek istediğinize emin misiniz?',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text('İptal', style: TextStyle(color: Colors.white)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text('Sil', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirmed == true) {
                                    await provider.deleteSleepEntry(entry.date);
                                    if (context.mounted) {
                                      Navigator.pop(context); // Detail dialog'u kapat
                                      // Consumer sayesinde liste otomatik güncellenecek
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Kayıt silindi'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              TextButton.icon(
                                icon: Icon(FeatherIcons.edit2, color: AppColors.primary, size: 18),
                                label: Text('Düzenle', style: TextStyle(color: AppColors.primary)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SleepInputScreen(
                                        date: entry.date,
                                        existingEntry: entry,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Kapat', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.15),
                              (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isHealthy ? AppColors.success : AppColors.warning).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isHealthy ? FeatherIcons.checkCircle : FeatherIcons.alertTriangle,
                                color: isHealthy ? AppColors.success : AppColors.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateForDialog(entry.date),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(FeatherIcons.moon, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${hours}s ${minutes}dk',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(FeatherIcons.target, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Hedef: 8s',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isHealthy 
                                      ? '✓ İdeal uyku süresi' 
                                      : hours < 7 
                                        ? '⚠️ Daha fazla uyumaya çalış'
                                        : '⚠️ Çok fazla uyudun',
                                    style: TextStyle(
                                      color: isHealthy ? AppColors.success : AppColors.warning,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              FeatherIcons.chevronRight,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _formatDateForDialog(DateTime date) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${date.day} ${months[date.month - 1]} - ${days[date.weekday - 1]}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSleepDebtCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyDebt = sleepProvider.weeklyDebt;
    final daysWithData = sleepProvider.daysWithDataCount;
    final isNegative = weeklyDebt.isNegative;
    
    // Ortalama günlük borcu hesapla (toplam borç / gün sayısı)
    final averageDailyDebt = daysWithData > 0 
        ? weeklyDebt.inMinutes / daysWithData 
        : 0.0;
    final isBalanced = averageDailyDebt.abs() <= 30; // ±30dk tolerans
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (daysWithData == 0) {
      color = AppColors.primary;
      icon = FeatherIcons.clock;
      title = 'Veri Bekleniyor';
      description = 'Uyku borcu hesaplamak için veri girin.';
    } else if (isBalanced) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      title = 'Süpersin! Tam dengede uyuyorsun 🎯';
      description = 'Uyku süren hedefinde. Uyku düzenin harika, böyle devam et 🌟';
    } else if (isNegative) {
      color = AppColors.error;
      icon = FeatherIcons.arrowDownCircle;
      title = 'Biraz yorgun görünüyorsun 😴';
      description = 'Bu hafta biraz uykun eksik kalmış. Yarın biraz erken yatmayı dene, kendini daha dinç hissedeceksin!';
    } else {
      color = AppColors.warning;
      icon = FeatherIcons.arrowUpCircle;
      title = 'Çok mu uyuyorsun? 🛌';
      description = 'Fazla uyku bazen daha çok yorar, 8 saat civarı tutmaya çalış';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (daysWithData > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              sleepProvider.formatSleepDebt(weeklyDebt),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (daysWithData > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.target,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Haftalık uyku borcun (Pzt-Paz). Günlük ortalama 8 saat hedefe göre hesaplanır.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 📈 Premium Overview Cards
  Widget _buildPremiumOverviewCards(BuildContext context, SleepProvider sleepProvider) {
    final weeklyAverage = sleepProvider.weeklyAverageSleep;
    final qualityScore = sleepProvider.sleepQualityScore;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPremiumStatCard(
                'Haftalık Ortalama',
                sleepProvider.formatDuration(weeklyAverage),
                AppColors.primary,
                FeatherIcons.clock,
                'Bu hafta (Pzt-Paz)',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPremiumStatCard(
                'Kalite Skoru',
                '$qualityScore/100',
                _getQualityColor(qualityScore),
                FeatherIcons.star,
                'Hedefe yakınlık',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                FeatherIcons.info,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kalite skoru, 8 saat hedefe ne kadar yakın olduğunu gösterir.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(String title, String value, Color color, IconData icon, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  // 📊 Premium Trend Chart with Real Data
  Widget _buildPremiumTrendChart(BuildContext context, SleepProvider sleepProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.focus.withOpacity(0.15),
            AppColors.focus.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.focus.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.focus.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.focus.withOpacity(0.3),
                      AppColors.focus.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.trendingUp,
                  color: AppColors.focus,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haftalık Uyku Grafiği',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son 7 günün uyku performansı',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Renk açıklamaları
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendItem('İdeal', AppColors.success),
              _buildLegendItem('Orta', AppColors.warning),
              _buildLegendItem('Yetersiz', AppColors.error),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.focus.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.focus.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.focus,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hedef: 8s',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.focus,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildWeeklyBarChart(context, sleepProvider),
            ),
          ),
        ],
      ),
    );
  }

  // 📊 Weekly Bar Chart Implementation
  Widget _buildWeeklyBarChart(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries;
    final targetHours = 8.0; // Sabit standart

    if (weeklyEntries.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: sleepProvider.maxSleepForChart,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.focus.withOpacity(0.9),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = weeklyEntries[groupIndex];
              if (entry.actualSleep.inMinutes == 0) {
                return BarTooltipItem(
                  'Veri yok',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }
              final hours = entry.actualSleep.inHours;
              final minutes = entry.actualSleep.inMinutes % 60;
              return BarTooltipItem(
                '${hours}s ${minutes}dk',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= weeklyEntries.length) return const SizedBox();
                final dayName = _getDayName(weeklyEntries[value.toInt()].date.weekday);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                // Sadece hedef çizgisini (8 saat) göster
                if (value == 8.0) {
                  return Text(
                    '8s',
                    style: TextStyle(
                      color: AppColors.focus,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: targetHours > 0 ? targetHours : 2,
          getDrawingHorizontalLine: (value) {
            if (value == targetHours) {
              return FlLine(
                color: AppColors.focus.withOpacity(0.6),
                strokeWidth: 2,
                dashArray: [4, 4],
              );
            }
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: weeklyEntries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final hours = entry.actualSleep.inMinutes / 60.0;
          final hasData = entry.actualSleep.inMinutes > 0;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hasData ? hours : 0.2, // Minimum height for empty days
                color: hasData ? _getSleepQualityColor(entry) : Colors.white.withOpacity(0.2),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                gradient: hasData ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _getSleepQualityColor(entry).withOpacity(0.7),
                    _getSleepQualityColor(entry),
                  ],
                ) : null,
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  // Helper methods for chart
  Color _getSleepQualityColor(dynamic entry) {
    if (entry.actualSleep.inMinutes == 0) return Colors.white.withOpacity(0.2);
    final debt = entry.sleepDebt.inMinutes.abs();
    if (debt <= 30) return AppColors.success;
    if (debt <= 75) return AppColors.warning;
    return AppColors.error;
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 📅 Monthly Summary Card
  Widget _buildMonthlySummaryCard(BuildContext context, SleepProvider sleepProvider) {
    final monthlyAverage = sleepProvider.monthlyAverageSleep;
    final monthlyDays = sleepProvider.monthlyDaysWithDataCount;
    final monthlyHours = monthlyAverage.inHours;
    final monthlyMinutes = monthlyAverage.inMinutes % 60;
    
    // Aylık sağlık durumu
    final isHealthy = monthlyHours >= 7 && monthlyHours <= 9;
    Color color = isHealthy ? AppColors.success : AppColors.warning;
    IconData icon = isHealthy ? FeatherIcons.trendingUp : FeatherIcons.alertTriangle;
    String status = isHealthy ? 'Sağlıklı' : 'Geliştirilmeli';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aylık Uyku Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son 30 gün • $monthlyDays gün aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ortalama Uyku',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${monthlyHours}s ${monthlyMinutes}dk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Durum',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.info,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    monthlyDays < 7 
                        ? 'Daha doğru analiz için en az 7 gün veri gir.'
                        : isHealthy
                            ? 'Aylık uyku düzenin harika! Böyle devam et 🌟'
                            : 'Her gün 8 saat uyumaya çalış, vücudun sana teşekkür edecek!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏆 Premium Sleep Records
  Widget _buildPremiumSleepRecords(BuildContext context, SleepProvider sleepProvider) {
    final entries = sleepProvider.sleepEntries.where((e) => e.actualSleep > Duration.zero).toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.energy.withOpacity(0.15),
            AppColors.energy.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.energy.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.energy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.energy.withOpacity(0.3),
                      AppColors.energy.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.award,
                  color: AppColors.energy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uyku Rekorları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'En iyi ve en kötü uyku performansın',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (entries.length < 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    entries.isEmpty 
                        ? 'Henüz hiç uyku verisi yok.' 
                        : 'Karşılaştırma için daha fazla veri gerekli.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'En az 2 gün veri girdiğinde rekorlarını görebilirsin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Builder(builder: (context) {
              final longestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a > b ? a : b);
              final shortestSleep = entries.map((e) => e.actualSleep).reduce((a, b) => a < b ? a : b);
              return Row(
                children: [
                  Expanded(
                    child: _buildRecordCard(
                      'En Uzun Uyku',
                      sleepProvider.formatDuration(longestSleep),
                      AppColors.success,
                      FeatherIcons.trendingUp,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecordCard(
                      'En Kısa Uyku',
                      sleepProvider.formatDuration(shortestSleep),
                      AppColors.error,
                      FeatherIcons.trendingDown,
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecordCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 💚 Sağlık Durumu Kartı (Sadece hedef 7-9 dışındaysa)
  Widget _buildHealthStatusCard(BuildContext context, SleepProvider sleepProvider) {
    final weeklyEntries = sleepProvider.weeklyEntries.where((e) => e.actualSleep.inMinutes > 0).toList();
    int healthyDays = 0;
    int unhealthyDays = 0;
    
    for (var entry in weeklyEntries) {
      final hours = entry.actualSleep.inHours;
      if (hours >= 7 && hours <= 9) {
        healthyDays++;
      } else {
        unhealthyDays++;
      }
    }
    
    final totalDays = weeklyEntries.length;
    final healthPercentage = totalDays > 0 ? (healthyDays / totalDays * 100).round() : 0;
    
    Color color;
    IconData icon;
    String title;
    String description;
    
    if (totalDays == 0) {
      color = AppColors.warning;
      icon = FeatherIcons.alertCircle;
      title = 'Sağlık Uyarısı ⚠️';
      description = 'Standart hedef 8 saat. Veri girdikçe sağlık durumunu görebilirsin.';
    } else if (healthPercentage >= 80) {
      color = AppColors.success;
      icon = FeatherIcons.heart;
      title = 'Sağlıklı Uyuyorsun! 💚';
      description = 'Bu hafta $healthyDays gün sağlıklı uyudun. Böyle devam et!';
    } else if (healthPercentage >= 50) {
      color = AppColors.warning;
      icon = FeatherIcons.alertTriangle;
      title = 'Dikkat: Sağlıksız Uyku ⚠️';
      description = '$unhealthyDays gün sağlık aralığının dışında uyudun. 8 saat hedefi için çaba göster.';
    } else {
      color = AppColors.error;
      icon = FeatherIcons.alertCircle;
      title = 'Acil: Sağlığını Düşün! 🚨';
      description = 'Bu hafta çok sağlıksız uyudun. Sağlığın için 8 saat uyku hedefle!';
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sağlık Durumu',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          FeatherIcons.heart,
                          color: Colors.white.withOpacity(0.6),
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (totalDays > 0)
                Column(
                  children: [
                    Text(
                      '$healthPercentage%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      'Sağlıklı',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.info,
                  color: AppColors.success,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Standart hedef 8 saattir. Sağlığın için bu hedefe ulaşmaya çalış.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.sleep,
                  AppColors.sleep.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sleep.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SleepInputScreen()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(FeatherIcons.plus, color: Colors.white, size: 24),
            ),
          ),
        );
      },
    );
  }
}
