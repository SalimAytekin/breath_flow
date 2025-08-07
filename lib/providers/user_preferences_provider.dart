import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_type.dart';

// Yeni eklenen enum
enum MindfulSessionType { none, breathing, sleep, hrv, meditation }

class UserPreferencesProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _dailyGoalMinutes = 10;
  MoodType _preferredMood = MoodType.relaxation;
  bool _isFirstLaunch = true;
  
  // İstatistikler
  int _totalSessions = 0;
  int _totalMinutes = 0;
  int _currentStreak = 0;
  DateTime? _lastSessionDate;
  
  // --- FAZ 1: Akıllı Öneri Sistemi için Veri Alanları ---
  double? _lastSleepDurationHours;
  int? _lastHrvScore;
  MindfulSessionType _lastSessionType = MindfulSessionType.none;
  DateTime? _lastBreathingSessionTimestamp;
  DateTime? _lastSleepSessionTimestamp;
  DateTime? _lastHrvSessionTimestamp;
  // --- Bitiş: Akıllı Öneri Sistemi için Veri Alanları ---
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  MoodType get preferredMood => _preferredMood;
  bool get isFirstLaunch => _isFirstLaunch;
  int get totalSessions => _totalSessions;
  int get totalMinutes => _totalMinutes;
  int get currentStreak => _currentStreak;
  DateTime? get lastSessionDate => _lastSessionDate;
  
  // --- FAZ 1: Yeni Getter'lar ---
  double? get lastSleepDurationHours => _lastSleepDurationHours;
  int? get lastHrvScore => _lastHrvScore;
  MindfulSessionType get lastSessionType => _lastSessionType;
  DateTime? get lastBreathingSessionTimestamp => _lastBreathingSessionTimestamp;
  DateTime? get lastSleepSessionTimestamp => _lastSleepSessionTimestamp;
  DateTime? get lastHrvSessionTimestamp => _lastHrvSessionTimestamp;
  // --- Bitiş: Yeni Getter'lar ---
  
  UserPreferencesProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _dailyGoalMinutes = prefs.getInt('daily_goal_minutes') ?? 10;
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    
    // Reminder time
    final reminderHour = prefs.getInt('reminder_hour') ?? 20;
    final reminderMinute = prefs.getInt('reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    // Preferred mood
    final moodString = prefs.getString('preferred_mood') ?? 'relaxation';
    _preferredMood = MoodType.values.firstWhere(
      (mood) => mood.name.toLowerCase() == moodString.toLowerCase(),
      orElse: () => MoodType.relaxation,
    );
    
    // İstatistikler
    _totalSessions = prefs.getInt('total_sessions') ?? 0;
    _totalMinutes = prefs.getInt('total_minutes') ?? 0;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    
    final lastSessionString = prefs.getString('last_session_date');
    if (lastSessionString != null) {
      _lastSessionDate = DateTime.tryParse(lastSessionString);
    }
    
    // --- FAZ 1: Yeni Verileri Yükleme ---
    _lastSleepDurationHours = prefs.getDouble('last_sleep_duration_hours');
    _lastHrvScore = prefs.getInt('last_hrv_score');
    
    final lastSessionTypeString = prefs.getString('last_session_type');
    if (lastSessionTypeString != null) {
      _lastSessionType = MindfulSessionType.values.firstWhere(
        (e) => e.name == lastSessionTypeString, 
        orElse: () => MindfulSessionType.none
      );
    }

    final lastBreathingString = prefs.getString('last_breathing_timestamp');
    if (lastBreathingString != null) {
      _lastBreathingSessionTimestamp = DateTime.tryParse(lastBreathingString);
    }
    final lastSleepString = prefs.getString('last_sleep_timestamp');
    if (lastSleepString != null) {
      _lastSleepSessionTimestamp = DateTime.tryParse(lastSleepString);
    }
    final lastHrvString = prefs.getString('last_hrv_timestamp');
    if (lastHrvString != null) {
      _lastHrvSessionTimestamp = DateTime.tryParse(lastHrvString);
    }
    // --- Bitiş: Yeni Verileri Yükleme ---
    
    notifyListeners();
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    notifyListeners();
  }
  
  Future<void> setDailyGoalMinutes(int minutes) async {
    _dailyGoalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal_minutes', minutes);
    notifyListeners();
  }
  
  Future<void> setPreferredMood(MoodType mood) async {
    _preferredMood = mood;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_mood', mood.name.toLowerCase());
    notifyListeners();
  }
  
  Future<void> setFirstLaunchCompleted() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    notifyListeners();
  }
  
  Future<void> recordSession(int durationMinutes) async {
    _totalSessions++;
    _totalMinutes += durationMinutes;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Streak hesaplama
    if (_lastSessionDate != null) {
      final lastSessionDay = DateTime(
        _lastSessionDate!.year,
        _lastSessionDate!.month,
        _lastSessionDate!.day,
      );
      
      final daysDifference = today.difference(lastSessionDay).inDays;
      
      if (daysDifference == 1) {
        // Dün son seans yapılmış, streak devam ediyor
        _currentStreak++;
      } else if (daysDifference > 1) {
        // Streak kırılmış
        _currentStreak = 1;
      }
      // daysDifference == 0 ise bugün zaten seans yapılmış, streak aynı kalır
    } else {
      // İlk seans
      _currentStreak = 1;
    }
    
    _lastSessionDate = now;
    
    // Kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_sessions', _totalSessions);
    await prefs.setInt('total_minutes', _totalMinutes);
    await prefs.setInt('current_streak', _currentStreak);
    await prefs.setString('last_session_date', now.toIso8601String());
    
    // --- FAZ 1: İstatistikleri Sıfırlama ---
    await prefs.remove('last_sleep_duration_hours');
    await prefs.remove('last_hrv_score');
    await prefs.remove('last_session_type');
    await prefs.remove('last_breathing_timestamp');
    await prefs.remove('last_sleep_timestamp');
    await prefs.remove('last_hrv_timestamp');
    // --- Bitiş: İstatistikleri Sıfırlama ---
    
    notifyListeners();
  }
  
  Future<void> resetStatistics() async {
    _totalSessions = 0;
    _totalMinutes = 0;
    _currentStreak = 0;
    _lastSessionDate = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('total_sessions');
    await prefs.remove('total_minutes');
    await prefs.remove('current_streak');
    await prefs.remove('last_session_date');
    
    notifyListeners();
  }
  
  // Bugünkü hedef tamamlanmış mı?
  bool get isDailyGoalCompleted {
    if (_lastSessionDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastSessionDay = DateTime(
      _lastSessionDate!.year,
      _lastSessionDate!.month,
      _lastSessionDate!.day,
    );
    
    if (today.difference(lastSessionDay).inDays == 0) {
      // Bugün seans yapılmış
      return _getTodayMinutes() >= _dailyGoalMinutes;
    }
    
    return false;
  }
  
  int _getTodayMinutes() {
    // Bu basit implementasyon için total minutes kullanıyoruz
    // Gerçek uygulamada günlük kayıtlar tutulmalı
    return _totalMinutes;
  }
  
  double get dailyGoalProgress {
    final todayMinutes = _getTodayMinutes();
    return (todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0);
  }
  
  String get streakText {
    if (_currentStreak == 0) return 'Henüz seans yok';
    if (_currentStreak == 1) return '1 gün';
    return '$_currentStreak gün';
  }
  
  String get totalTimeText {
    if (_totalMinutes < 60) {
      return '$_totalMinutes dakika';
    } else {
      final hours = _totalMinutes ~/ 60;
      final minutes = _totalMinutes % 60;
      return '${hours}s ${minutes}dk';
    }
  }
  
  // Eksik getter ve methodlar
  int get longestStreak => _currentStreak; // Basit implementasyon
  int get dailyGoal => _dailyGoalMinutes;
  
  Future<void> setDailyGoal(int minutes) async {
    await setDailyGoalMinutes(minutes);
  }
  
  Future<void> resetAllData() async {
    await resetStatistics();
    
    // Tüm tercihleri sıfırla
    _notificationsEnabled = true;
    _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    _dailyGoalMinutes = 10;
    _preferredMood = MoodType.relaxation;
    _isFirstLaunch = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  // --- FAZ 1: Yeni Kayıt Metotları ---
  Future<void> recordHrvSession(int score) async {
    final now = DateTime.now();
    _lastHrvScore = score;
    _lastSessionType = MindfulSessionType.hrv;
    _lastHrvSessionTimestamp = now;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_hrv_score', score);
    await prefs.setString('last_session_type', MindfulSessionType.hrv.name);
    await prefs.setString('last_hrv_timestamp', now.toIso8601String());
    
    await recordSession(5); // Ortalama 5 dakika varsayalım
    notifyListeners();
  }

  Future<void> recordSleepSession(double durationHours) async {
    final now = DateTime.now();
    _lastSleepDurationHours = durationHours;
    _lastSessionType = MindfulSessionType.sleep;
    _lastSleepSessionTimestamp = now;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_sleep_duration_hours', durationHours);
    await prefs.setString('last_session_type', MindfulSessionType.sleep.name);
    await prefs.setString('last_sleep_timestamp', now.toIso8601String());

    await recordSession((durationHours * 60).toInt());
    notifyListeners();
  }

  Future<void> recordBreathingSession(int durationMinutes) async {
    final now = DateTime.now();
    _lastSessionType = MindfulSessionType.breathing;
    _lastBreathingSessionTimestamp = now;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_session_type', MindfulSessionType.breathing.name);
    await prefs.setString('last_breathing_timestamp', now.toIso8601String());

    await recordSession(durationMinutes);
    notifyListeners();
  }
  // --- Bitiş: Yeni Kayıt Metotları ---
} 