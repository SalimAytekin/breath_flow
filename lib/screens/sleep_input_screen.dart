import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/sleep_entry.dart';
import '../providers/sleep_provider.dart';
import '../providers/user_preferences_provider.dart';

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

class _SleepInputScreenState extends State<SleepInputScreen> {
  late DateTime selectedDate;
  late TimeOfDay bedTime;
  late TimeOfDay wakeTime;
  late int targetHours;
  
  @override
  void initState() {
    super.initState();
    
    selectedDate = widget.date ?? DateTime.now();
    
    if (widget.existingEntry != null) {
      bedTime = TimeOfDay.fromDateTime(widget.existingEntry!.bedTime);
      wakeTime = TimeOfDay.fromDateTime(widget.existingEntry!.wakeTime);
      targetHours = widget.existingEntry!.targetHours;
    } else {
      bedTime = const TimeOfDay(hour: 23, minute: 0);
      wakeTime = const TimeOfDay(hour: 7, minute: 0);
      targetHours = context.read<SleepProvider>().defaultTargetHours;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.existingEntry != null ? 'Uyku Verini Düzenle' : 'Uyku Verini Gir',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih seçimi
              _buildDateSection(),
              
              const SizedBox(height: 32),
              
              // Yatma saati
              _buildTimeSection(
                title: 'Yatma Saati',
                subtitle: 'Kaçta yattın?',
                icon: FeatherIcons.moon,
                time: bedTime,
                color: AppColors.sleep,
                onTap: () => _selectTime(context, true),
              ),
              
              const SizedBox(height: 24),
              
              // Uyanma saati
              _buildTimeSection(
                title: 'Uyanma Saati',
                subtitle: 'Kaçta uyandın?',
                icon: FeatherIcons.sun,
                time: wakeTime,
                color: AppColors.energy,
                onTap: () => _selectTime(context, false),
              ),
              
              const SizedBox(height: 32),
              
              // Hedef uyku süresi
              _buildTargetSection(),
              
              const SizedBox(height: 32),
              
              // Uyku özeti
              _buildSummarySection(),
              
              const SizedBox(height: 40),
              
              // Kaydet butonu
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.calendar,
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
                      'Tarih',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: Icon(
                  FeatherIcons.edit2,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required TimeOfDay time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                time.format(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTargetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.focus.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.target,
                  color: AppColors.focus,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hedef Uyku Süresi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kaç saat uyumayı hedefliyorsun?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '$targetHours saat',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.focus,
            ),
          ),
          
          const SizedBox(height: 12),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.focus,
              inactiveTrackColor: AppColors.focus.withOpacity(0.3),
              thumbColor: AppColors.focus,
              valueIndicatorColor: AppColors.focus,
            ),
            child: Slider(
              value: targetHours.toDouble(),
              min: 4,
              max: 12,
              divisions: 8,
              label: '$targetHours saat',
              onChanged: (value) {
                setState(() {
                  targetHours = value.toInt();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummarySection() {
    final actualSleep = _calculateDuration();
    final debt = actualSleep - Duration(hours: targetHours);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.barChart2,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Uyku Özeti',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Uyuduğun Süre',
                  _formatDuration(actualSleep),
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Hedef',
                  '${targetHours}s 0dk',
                  AppColors.focus,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildDebtCard(debt),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebtCard(Duration debt) {
    final isNegative = debt.isNegative;
    final color = isNegative ? AppColors.error : AppColors.success;
    final icon = isNegative ? FeatherIcons.trendingDown : FeatherIcons.trendingUp;
    
    String debtText;
    if (debt.inMinutes == 0) {
      debtText = 'Hedefinde! 🎯';
    } else {
      final sleepProvider = context.read<SleepProvider>();
      debtText = sleepProvider.formatSleepDebt(debt);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uyku Durumu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  debtText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(FeatherIcons.save),
        label: const Text('Kaydet'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          final sleepProvider = context.read<SleepProvider>();
          final prefsProvider = context.read<UserPreferencesProvider>();
          
          final entry = SleepEntry(
            date: selectedDate,
            bedTime: _combineDateAndTime(selectedDate, bedTime),
            wakeTime: _combineDateAndTime(selectedDate, wakeTime),
            targetHours: targetHours,
          );

          sleepProvider.addSleepEntry(entry);

          final duration = _calculateDuration();
          prefsProvider.recordSleepSession(duration.inMinutes / 60.0);

          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  void _saveSleepData() {
    final bedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      bedTime.hour,
      bedTime.minute,
    );
    
    final wakeDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      wakeTime.hour,
      wakeTime.minute,
    );
    
    final entry = SleepEntry(
      date: selectedDate,
      bedTime: bedDateTime,
      wakeTime: wakeDateTime,
      targetHours: targetHours,
    );
    
    context.read<SleepProvider>().addSleepEntry(entry);
    
    Navigator.of(context).pop();
    
    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingEntry != null ? 'Uyku veriniz güncellendi!' : 'Uyku veriniz kaydedildi!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
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
    final weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    
    return '${date.day} ${months[date.month - 1]}, ${weekdays[date.weekday - 1]}';
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}s ${minutes}dk';
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