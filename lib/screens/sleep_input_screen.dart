import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sleep_entry.dart';
import '../providers/sleep_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/global_background.dart';
import 'sleep_analytics_screen.dart';

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
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _pulseAnimation;
  
  late DateTime selectedDate;
  late TimeOfDay bedTime;
  late TimeOfDay wakeTime;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // ⚡ PERFORMANCE: Animation Controllers - duration optimize edildi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // 1200ms → 500ms
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800), // 2000ms → 1800ms
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
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
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
                      // Premium Header
                      _buildPremiumHeader(context),
                      
                      const SizedBox(height: 40),
                      
                      // Date Selection - Premium Style
                      _buildPremiumDateSection(),
                      
                      const SizedBox(height: 28),
                      
                      // Time Sections - Side by Side Premium Layout
                      _buildPremiumTimeRow(),
                      
                      const SizedBox(height: 32),
                      
                      // Sleep Summary - Premium Cards
                      _buildPremiumSummarySection(),
                      
                      const SizedBox(height: 40),
                      
                      // Premium Save Button
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

  // 🎨 Premium AppBar with Advanced Glassmorphism
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
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
                widget.existingEntry != null ? AppStrings.sleepDataEdit : AppStrings.sleepDataEntry,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 Premium Header with Floating Elements
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryAccent.withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    FeatherIcons.moon,
                    color: Colors.white,
                    size: 32,
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
                  AppStrings.sleepTracking,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.sleepTrackingDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📅 Premium Date Section with Neumorphism
  Widget _buildPremiumDateSection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                FeatherIcons.calendar,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectDateLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FeatherIcons.chevronRight,
                color: Colors.white70,
                size: 18,
              ),
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

  // 🎯 Premium Time Card with Advanced Styling
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
        padding: const EdgeInsets.all(20),
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
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Text(
                time.format(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Premium Summary Section with Cards
  Widget _buildPremiumSummarySection() {
    final actualSleep = _calculateDuration();
    final debt = actualSleep - const Duration(hours: SleepEntry.standardTargetHours);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.08),
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
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
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
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  FeatherIcons.barChart2,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.sleepSummary,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildPremiumSummaryCard(
                  AppStrings.sleptDuration,
                  _formatDuration(actualSleep),
                  AppColors.primary,
                  FeatherIcons.clock,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPremiumSummaryCard(
                  AppStrings.target,
                  '${SleepEntry.standardTargetHours}s 0dk',
                  AppColors.focus,
                  FeatherIcons.target,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildPremiumDebtCard(debt),
        ],
      ),
    );
  }

  Widget _buildPremiumSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
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
    final isNegative = debt.isNegative;
    
    // Hedef kontrolü
    final isOnTarget = debt.inMinutes.abs() <= 30; // ±30 dakika tolerans
    
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sleepStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debtText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (healthWarning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.heart,
                    color: color.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      healthWarning,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
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

  // 💎 Premium Save Button with Advanced Effects
  Widget _buildPremiumSaveButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.02,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryAccent,
                  AppColors.primaryAccent.withOpacity(0.8),
                  Colors.purple.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FeatherIcons.save,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              label: Text(
                widget.existingEntry != null ? AppStrings.editAndAnalyze : AppStrings.saveAndAnalyze,
                style: const TextStyle(
                  fontSize: 18,
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
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
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
                        'Bu Tarihte Kayıt Var',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        '${_formatDate(selectedDate)} tarihinde zaten bir uyku kaydınız var. Üzerine yazmak ister misiniz?',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('İptal', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Üzerine Yaz', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;
                }
                
                final entry = SleepEntry(
                  date: selectedDate,
                  bedTime: _combineDateAndTime(selectedDate, bedTime),
                  wakeTime: _combineDateAndTime(selectedDate, wakeTime),
                );

                sleepProvider.addSleepEntry(entry);

                prefsProvider.recordSleepSession(duration.inMinutes / 60.0);

                Navigator.of(context).pop();
                
                // Uyku analizi sayfasına yönlendir
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SleepAnalyticsScreen(),
                  ),
                );
              },
            ),
          ),
        );
      },
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
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? bedTime : wakeTime,
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
    final locale = context.locale.toString();
    if (locale.startsWith('tr')) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${hours}h ${minutes}m';
    }
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