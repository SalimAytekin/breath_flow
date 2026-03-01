import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sleep_entry.dart';
import '../providers/sleep_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/global_background.dart';
import 'sleep_analytics_screen.dart';
import '../core/ads/ad_manager.dart';
import '../providers/premium_provider.dart';


class SleepInputScreen extends StatefulWidget {
  final DateTime? date;
  final SleepEntry? existingEntry;
  
  const SleepInputScreen({
    super.key,
    this.date,
    this.existingEntry,
  });

  @override
  State<SleepInputScreen> createState() => _SleepInputScreenState();
}

class _SleepInputScreenState extends State<SleepInputScreen> 
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  
  late DateTime selectedDate;
  late TimeOfDay bedTime;
  late TimeOfDay wakeTime;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // ⚡ PERFORMANCE: Animation Controllers - duration optimize edildi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // 1200ms → 500ms
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
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
    ));
    
    selectedDate = widget.date ?? DateTime.now();
    
    if (widget.existingEntry != null) {
      bedTime = TimeOfDay.fromDateTime(widget.existingEntry!.bedTime);
      wakeTime = TimeOfDay.fromDateTime(widget.existingEntry!.wakeTime);
    } else {
      bedTime = const TimeOfDay(hour: 23, minute: 0);
      wakeTime = const TimeOfDay(hour: 7, minute: 0);
    }
    
    // Start animations
    _animationController.forward();
    
    // 🎯 Reklam ön yükleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final premiumProvider = context.read<PremiumProvider>();
      if (!premiumProvider.canAccessFeature('ad_free')) {
        AdManager.instance.preloadInterstitial(placement: 'sleep_save');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Klavyeyi kapat
        FocusScope.of(context).unfocus();
      },
      child: GlobalBackground(
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kompakt Header
                      _buildPremiumHeader(context),
                      
                      const SizedBox(height: 24),
                      
                      // Date Selection
                      _buildPremiumDateSection(),
                      
                      const SizedBox(height: 16),
                      
                      // Time Sections - Side by Side
                      _buildPremiumTimeRow(),
                      
                      const SizedBox(height: 20),
                      
                      // Sleep Summary
                      _buildPremiumSummarySection(),
                      
                      const SizedBox(height: 28),
                      
                      // Save Button
                      _buildPremiumSaveButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  // 🎨 Minimal AppBar — BackdropFilter kaldırıldı, performans dostu
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.3),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.existingEntry != null ? AppStrings.sleepDataEdit : AppStrings.sleepDataEntry,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 Kompakt Header — minimal, soft
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFD4AF37).withOpacity(0.15),
            ),
            child: const Icon(
              FeatherIcons.moon,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.sleepTracking,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.sleepTrackingDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📅 Tarih Seçimi — minimal, soft
  Widget _buildPremiumDateSection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
              child: const Icon(
                FeatherIcons.calendar,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectDateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ⏰ Premium Time Row - Side by Side Layout
  Widget _buildPremiumTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPremiumTimeCard(
            title: AppStrings.bedTime,
            time: bedTime,
            icon: FeatherIcons.moon,
            color: AppColors.sleep,
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumTimeCard(
            title: AppStrings.wakeTime,
            time: wakeTime,
            icon: FeatherIcons.sun,
            color: AppColors.energy,
            onTap: () => _selectTime(context, false),
          ),
        ),
      ],
    );
  }

  // 🎯 Saat Kartı — minimal, soft
  Widget _buildPremiumTimeCard({
    required String title,
    required TimeOfDay time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1F1A),
              Color(0xFF1E1410),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                time.format(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Uyku Özeti — minimal, soft
  Widget _buildPremiumSummarySection() {
    final actualSleep = _calculateDuration();
    final debt = actualSleep - const Duration(hours: SleepEntry.standardTargetHours);
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.barChart2, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                AppStrings.sleepSummary,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPremiumSummaryCard(
                  AppStrings.sleptDuration,
                  _formatDuration(actualSleep),
                  AppColors.sleep,
                  FeatherIcons.clock,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPremiumSummaryCard(
                  AppStrings.target,
                  '${SleepEntry.standardTargetHours}${AppStrings.hourShortSuffix} 0${AppStrings.minuteShortSuffix}',
                  AppColors.focus,
                  FeatherIcons.target,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildPremiumDebtCard(debt),
        ],
      ),
    );
  }

  Widget _buildPremiumSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDebtCard(Duration debt) {
    final actualSleep = _calculateDuration();
    final actualHours = actualSleep.inHours;
    
    // Hedef kontrolü
    final isOnTarget = debt.inMinutes.abs() <= 30;
    
    // Sağlık kontrolü (7-9 saat)
    final isHealthy = actualHours >= 7 && actualHours <= 9;
    
    Color color;
    IconData icon;
    String debtText;
    String? healthWarning;
    
    if (isOnTarget && isHealthy) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      debtText = AppStrings.perfectOnTarget;
    } else if (isOnTarget && !isHealthy) {
      color = AppColors.warning;
      icon = FeatherIcons.alertTriangle;
      debtText = AppStrings.onTargetButWarning;
      if (actualHours < 7) {
        healthWarning = AppStrings.needMoreSleepHealth.replaceAll('{0}', (7 - actualHours).toString());
      } else {
        healthWarning = AppStrings.tooMuchSleepWarning;
      }
    } else if (!isOnTarget && isHealthy) {
      color = AppColors.success;
      icon = FeatherIcons.checkCircle;
      final sleepProvider = context.read<SleepProvider>();
      debtText = sleepProvider.formatSleepDebt(debt);
      healthWarning = AppStrings.healthyRangeSleep;
    } else {
      color = AppColors.error;
      icon = FeatherIcons.trendingDown;
      final sleepProvider = context.read<SleepProvider>();
      debtText = sleepProvider.formatSleepDebt(debt);
      if (actualHours < 7) {
        healthWarning = AppStrings.needMoreSleepDeserve.replaceAll('{0}', (7 - actualHours).toString());
      } else {
        healthWarning = AppStrings.exceededTargetWarning;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sleepStatus,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      debtText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (healthWarning != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(FeatherIcons.heart, color: color.withOpacity(0.7), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      healthWarning,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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

  // � Kaydet Butonu — minimal, soft
  Widget _buildPremiumSaveButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFB8941F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(FeatherIcons.save, color: Colors.white, size: 18),
        label: Text(
          widget.existingEntry != null ? AppStrings.editAndAnalyze : AppStrings.saveAndAnalyze,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
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
              onPressed: _isSaving ? null : () async {
                // Validasyon: Uyku süresi kontrolü
                final duration = _calculateDuration();
                if (duration.inMinutes < 60) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(FeatherIcons.alertCircle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(AppStrings.sleepMinimumError),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                if (duration.inHours > 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(FeatherIcons.alertCircle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(AppStrings.sleepMaximumError),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                
                final sleepProvider = context.read<SleepProvider>();
                final prefsProvider = context.read<UserPreferencesProvider>();
                
                // Aynı tarihte kayıt var mı kontrol et
                final existingEntry = sleepProvider.getSleepEntryForDate(selectedDate);
                if (existingEntry != null && widget.existingEntry == null) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        AppStrings.recordExistsForDate,
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        AppStrings.sleepRecordExistsMessage.replaceAll('{0}', _formatDate(selectedDate)),
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(AppStrings.cancel, style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(AppStrings.overwrite, style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;
                }

                setState(() => _isSaving = true);
                
                final entry = SleepEntry(
                  date: selectedDate,
                  bedTime: _combineDateAndTime(selectedDate, bedTime),
                  wakeTime: _combineDateAndTime(selectedDate, wakeTime),
                );

                sleepProvider.addSleepEntry(entry);
                
                prefsProvider.recordSleepSession(duration.inMinutes / 60.0);
                
                // 🎯 Reklam Gösterimi (Save sonrası)
                final premiumProvider = context.read<PremiumProvider>();
                if (!premiumProvider.canAccessFeature('ad_free')) {
                  // Reklam yüklü değilse biraz bekle (max 2sn)
                  if (!AdManager.instance.isInterstitialLoaded) {
                     int retries = 0;
                     while (!AdManager.instance.isInterstitialLoaded && retries < 10) {
                       await Future.delayed(const Duration(milliseconds: 50));
                       retries++;
                     }
                  }
                  
                  await AdManager.instance.showInterstitial(placement: 'sleep_save');
                }

                setState(() => _isSaving = false);

                if (!context.mounted) return;
                Navigator.of(context).pop();
                
                // Uyku analizi sayfasına yönlendir
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SleepAnalyticsScreen(),
                  ),
                );
              },
      ),
    );
  }

  // 🔧 Helper Methods
  
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      locale: context.locale,
      confirmText: AppStrings.ok,
      cancelText: AppStrings.cancel,
      helpText: AppStrings.selectDateLabel,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context, bool isBedTime) async {
    final initialTime = isBedTime ? bedTime : wakeTime;
    int selectedHour = initialTime.hour;
    int selectedMinute = (initialTime.minute / 5).round() * 5;
    if (selectedMinute >= 60) selectedMinute = 55;

    final hourController = FixedExtentScrollController(initialItem: selectedHour);
    final minuteController = FixedExtentScrollController(initialItem: selectedMinute ~/ 5);

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D1F1A),
                    Color(0xFF1E1410),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBedTime ? AppStrings.bedTime : AppStrings.wakeTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, TimeOfDay(hour: selectedHour, minute: selectedMinute));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppStrings.confirmSelection,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Wheel Pickers
                  Expanded(
                    child: Row(
                      children: [
                        // Hour label
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(
                            AppStrings.selectHour,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Hour wheel
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: hourController,
                            itemExtent: 48,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedHour = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (context, index) {
                                final isSelected = index == selectedHour;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 28 : 18,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFFD4AF37)
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Separator
                        const Text(
                          ':',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        // Minute wheel
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: minuteController,
                            itemExtent: 48,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedMinute = index * 5);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (context, index) {
                                final minute = index * 5;
                                final isSelected = minute == selectedMinute;
                                return Center(
                                  child: Text(
                                    minute.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 28 : 18,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFFD4AF37)
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Minute label
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Text(
                            AppStrings.selectMinute,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isBedTime) {
          bedTime = picked;
        } else {
          wakeTime = picked;
        }
      });
    }
  }
  
  String _formatDate(DateTime date) {
    final locale = context.locale.toString();
    final formatter = DateFormat('d MMMM, EEEE', locale);
    return formatter.format(date);
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}${AppStrings.hourShortSuffix} ${minutes}${AppStrings.minuteShortSuffix}';
  }

  Duration _calculateDuration() {
    final start = _combineDateAndTime(selectedDate, bedTime);
    var end = _combineDateAndTime(selectedDate, wakeTime);

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    
    return end.difference(start);
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
} 