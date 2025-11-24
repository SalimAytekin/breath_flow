import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_type.dart';
import '../models/weekly_activity.dart';
import '../services/notification_service.dart';

// Yeni eklenen enum
enum MindfulSessionType { none, breathing, sleep, hrv, meditation }

class UserPreferencesProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _dailyGoalMinutes = 10; // AppConstants.dailyGoalMinutesDefault
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
  
  // 🎵 Son ses seansı zaman damgası (de-dupe için)
  DateTime? _lastSoundSessionTimestamp;
  
  // 📊 Haftalık Aktivite Takibi
  List<WeeklyActivity> _weeklyActivities = [];
  
  // ⭐ Favoriler (LİSTELER - Çoklu favori)
  List<String> _favoriteExerciseIds = [];
  List<String> _favoriteSoundIds = [];
  
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
  
  // ⭐ Favori Getters (LİSTELER)
  List<String> get favoriteExerciseIds => _favoriteExerciseIds;
  List<String> get favoriteSoundIds => _favoriteSoundIds;
  
  // ⭐ Favori kontrol metodları
  bool isFavoriteExercise(String exerciseId) => _favoriteExerciseIds.contains(exerciseId);
  bool isFavoriteSound(String soundId) => _favoriteSoundIds.contains(soundId);
  
  // --- FAZ 1: Yeni Getter'lar ---
  double? get lastSleepDurationHours => _lastSleepDurationHours;
  int? get lastHrvScore => _lastHrvScore;
  MindfulSessionType get lastSessionType => _lastSessionType;
  DateTime? get lastBreathingSessionTimestamp => _lastBreathingSessionTimestamp;
  DateTime? get lastSleepSessionTimestamp => _lastSleepSessionTimestamp;
  DateTime? get lastHrvSessionTimestamp => _lastHrvSessionTimestamp;
  DateTime? get lastSoundSessionTimestamp => _lastSoundSessionTimestamp;
  // --- Bitiş: Yeni Getter'lar ---
  
  // 📊 Haftalık Aktivite Getter'ı
  WeeklySummary get weeklySummary => WeeklySummary.getLast7Days(_weeklyActivities);
  
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
      
      // Streak kontrolü - Eğer son seans 1 günden fazla önceyse streak'i sıfırla
      if (_lastSessionDate != null && _currentStreak > 0) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastSessionDay = DateTime(
          _lastSessionDate!.year,
          _lastSessionDate!.month,
          _lastSessionDate!.day,
        );
        
        final daysDifference = today.difference(lastSessionDay).inDays;
        
        if (daysDifference > 1) {
          // Streak kırılmış, sıfırla
          _currentStreak = 0;
          await prefs.setInt('current_streak', 0);
        }
      }
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
    // 🎵 Son ses seansı zaman damgasını yükle
    final lastSoundString = prefs.getString('last_sound_timestamp');
    if (lastSoundString != null) {
      _lastSoundSessionTimestamp = DateTime.tryParse(lastSoundString);
    }
    // --- Bitiş: Yeni Verileri Yükleme ---
    
    // 📊 Haftalık aktiviteleri yükle
    await _loadWeeklyActivities();
    
    // ⭐ Favorileri yükle (LİSTELER)
    final exercisesString = prefs.getString('favorite_exercises');
    if (exercisesString != null) {
      _favoriteExerciseIds = List<String>.from(jsonDecode(exercisesString));
    }
    
    final soundsString = prefs.getString('favorite_sounds');
    if (soundsString != null) {
      _favoriteSoundIds = List<String>.from(jsonDecode(soundsString));
    }
    
    notifyListeners();
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    // Bildirimleri etkinleştir/deaktifleştir
    final notificationService = NotificationService.instance;
    notificationService.setNotificationsEnabled(enabled);
    
    if (enabled) {
      // Günlük hatırlatmayı zamanla
      await notificationService.scheduleDailyBreathingReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      // Tüm hatırlatmaları iptal et
      await notificationService.cancelAllReminders();
    }
    
    notifyListeners();
  }
  
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    
    // Eğer bildirimler aktifse, hatırlatma saatini güncelle
    if (_notificationsEnabled) {
      final notificationService = NotificationService.instance;
      await notificationService.cancelAllReminders();
      await notificationService.scheduleDailyBreathingReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
    
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
  
  Future<void> setIsFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', value);
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
    await prefs.remove('last_sound_timestamp');
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
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Bugünün aktivitesini bul
      final todayActivity = _weeklyActivities.firstWhere(
        (activity) {
          final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
          return activityDate.isAtSameMomentAs(today);
        },
        orElse: () => WeeklyActivity(
          date: today,
          breathingSessions: 0,
          soundSessions: 0,
          sleepSessions: 0,
          totalMinutes: 0,
        ),
      );
      
      return todayActivity.totalMinutes;
    } catch (e) {
      debugPrint('❌ Bugünkü dakika hesaplama hatası: $e');
      return 0; // Hata durumunda 0 döndür
    }
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
      return '$_totalMinutes dk';
    } else {
      final hours = _totalMinutes ~/ 60;
      final minutes = _totalMinutes % 60;
      if (minutes == 0) {
        return '$hours sa';
      }
      return '$hours sa $minutes dk';
    }
  }
  
  // Eksik getter ve methodlar
  int get longestStreak => _currentStreak; // Basit implementasyon
  int get dailyGoal => _dailyGoalMinutes;
  
  int get weeklyGoal => 7; // Haftada 7 seans hedefi
  
  /// 🆕 Bugünkü seans sayısı (basit implementasyon)
  int get todaySessionsCount {
    if (_lastSessionDate == null) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastSessionDay = DateTime(
      _lastSessionDate!.year,
      _lastSessionDate!.month,
      _lastSessionDate!.day,
    );
    
    // Eğer son seans bugün yapılmışsa 1, değilse 0
    return today.isAtSameMomentAs(lastSessionDay) ? 1 : 0;
  }
  
  int get completedSessionsThisWeek {
    if (_lastSessionDate == null) return 0;
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    // Basit implementasyon - gerçek uygulamada haftalık kayıtlar tutulmalı
    if (_lastSessionDate!.isAfter(startOfWeekDay)) {
      return _currentStreak.clamp(0, 7);
    }
    return 0;
  }
  
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

    final minutes = (durationHours * 60).toInt();
    await recordSession(minutes);
    
    // 📊 Haftalık aktiviteyi güncelle - yeni parametrelerle
    await _updateTodayActivity(
      sleepSessions: 1, 
      minutes: minutes,
      sleepMinutes: minutes, // 🆕
    );
    
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
    
    // 📊 Haftalık aktiviteyi güncelle - yeni parametrelerle
    await _updateTodayActivity(
      breathingSessions: 1, 
      minutes: durationMinutes,
      breathingMinutes: durationMinutes, // 🆕
    );
    
    notifyListeners();
  }
  
  Future<void> recordSoundSession(int durationMinutes) async {
    final now = DateTime.now();
    
    // 🔒 De-dupe: Son 2 dakika içinde ses seansı kaydedildiyse tekrarı yoksay
    if (_lastSoundSessionTimestamp != null) {
      final diff = now.difference(_lastSoundSessionTimestamp!).inSeconds;
      if (diff >= 0 && diff < 120) {
        debugPrint('🚫 Yinelenen ses seansı algılandı (diff=${diff}s), kayıt atlandı');
        return;
      }
    }
    
    // Zaman damgasını güncelle ve kalıcılaştır
    _lastSoundSessionTimestamp = now;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sound_timestamp', now.toIso8601String());
    } catch (_) {}
    
    // 📊 Haftalık aktiviteyi güncelle - yeni parametrelerle
    await _updateTodayActivity(
      soundSessions: 1, 
      minutes: durationMinutes,
      soundMinutes: durationMinutes, // 🆕
    );
    
    debugPrint('🎵 Ses dinleme seansı kaydedildi: $durationMinutes dakika');
    notifyListeners();
  }
  // --- Bitiş: Yeni Kayıt Metotları ---
  
  // 📊 HAFTALIK AKTİVİTE TAKİBİ
  
  /// Bugünün aktivitesini güncelle
  Future<void> _updateTodayActivity({
    int breathingSessions = 0,
    int soundSessions = 0,
    int sleepSessions = 0,
    int minutes = 0,
    int breathingMinutes = 0,
    int soundMinutes = 0,
    int sleepMinutes = 0,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Bugünün aktivitesini bul
    final todayIndex = _weeklyActivities.indexWhere((activity) {
      final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
      return activityDate.isAtSameMomentAs(today);
    });
    
    if (todayIndex != -1) {
      // Bugün zaten var, güncelle
      final todayActivity = _weeklyActivities[todayIndex];
      _weeklyActivities[todayIndex] = todayActivity.copyWith(
        breathingSessions: todayActivity.breathingSessions + breathingSessions,
        soundSessions: todayActivity.soundSessions + soundSessions,
        sleepSessions: todayActivity.sleepSessions + sleepSessions,
        totalMinutes: todayActivity.totalMinutes + minutes,
        breathingMinutes: todayActivity.breathingMinutes + breathingMinutes,
        soundMinutes: todayActivity.soundMinutes + soundMinutes,
        sleepMinutes: todayActivity.sleepMinutes + sleepMinutes,
      );
    } else {
      // Yeni gün ekle
      _weeklyActivities.add(WeeklyActivity(
        date: today,
        breathingSessions: breathingSessions,
        soundSessions: soundSessions,
        sleepSessions: sleepSessions,
        totalMinutes: minutes,
        breathingMinutes: breathingMinutes,
        soundMinutes: soundMinutes,
        sleepMinutes: sleepMinutes,
      ));
    }
    
    // Eski verileri temizle (30 günden eski)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    _weeklyActivities.removeWhere((activity) => activity.date.isBefore(thirtyDaysAgo));
    
    // Kaydet
    await _saveWeeklyActivities();
    notifyListeners();
  }
  
  Future<void> _saveWeeklyActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = _weeklyActivities.map((a) => a.toJson()).toList();
      final jsonString = jsonEncode(activitiesJson);
      
      // 💾 Create backup before saving new data
      final currentData = prefs.getString('weekly_activities');
      if (currentData != null && currentData.isNotEmpty) {
        await prefs.setString('weekly_activities_backup', currentData);
      }
      
      await prefs.setString('weekly_activities', jsonString);
      debugPrint('✅ Haftalık aktiviteler kaydedildi (${_weeklyActivities.length} kayıt)');
    } catch (e) {
      debugPrint('❌ Haftalık aktivite kaydetme hatası: $e');
      // Don't throw - continue app execution
    }
  }
  
  Future<void> _loadWeeklyActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesString = prefs.getString('weekly_activities');
      
      if (activitiesString != null && activitiesString.isNotEmpty) {
        try {
          final List<dynamic> activitiesJson = jsonDecode(activitiesString);
          
          // 🛡️ CRITICAL FIX: Robust error recovery
          final List<WeeklyActivity> loadedActivities = [];
          for (final json in activitiesJson) {
            try {
              if (json is Map<String, dynamic>) {
                loadedActivities.add(WeeklyActivity.fromJson(json));
              }
            } catch (itemError) {
              debugPrint('⚠️ Tek aktivite parse edilemedi, atlanıyor: $itemError');
              // Continue with other items instead of losing all data
            }
          }
          
          _weeklyActivities = loadedActivities;
          
          if (loadedActivities.isEmpty && activitiesJson.isNotEmpty) {
            // All items failed to parse - corrupted data
            debugPrint('❌ Tüm aktivite verileri bozuk, yedekten geri yükleme deneniyor');
            await _tryRestoreFromBackup(prefs);
          }
        } catch (e) {
          debugPrint('❌ JSON parse hatası: $e');
          // Try to restore from backup before giving up
          await _tryRestoreFromBackup(prefs);
        }
      }
    } catch (e) {
      debugPrint('❌ Haftalık aktivite yükleme hatası: $e');
      _weeklyActivities = [];
    }
  }
  
  /// 🔄 Try to restore from backup
  Future<void> _tryRestoreFromBackup(SharedPreferences prefs) async {
    try {
      final backupString = prefs.getString('weekly_activities_backup');
      if (backupString != null && backupString.isNotEmpty) {
        final List<dynamic> backupJson = jsonDecode(backupString);
        _weeklyActivities = backupJson
            .map((json) => WeeklyActivity.fromJson(json))
            .toList();
        debugPrint('✅ Yedekten ${_weeklyActivities.length} aktivite geri yüklendi');
      } else {
        _weeklyActivities = [];
      }
    } catch (e) {
      debugPrint('❌ Yedek geri yükleme başarısız: $e');
      _weeklyActivities = [];
    }
  }
  
  // ⭐ FAVORİ YÖNETİMİ (LİSTELER)
  
  /// Favori egzersiz ekle/kaldır (TOGGLE)
  Future<void> toggleFavoriteExercise(String exerciseId) async {
    if (_favoriteExerciseIds.contains(exerciseId)) {
      _favoriteExerciseIds.remove(exerciseId);
    } else {
      _favoriteExerciseIds.add(exerciseId);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_exercises', jsonEncode(_favoriteExerciseIds));
    
    notifyListeners();
  }
  
  /// Favori ses ekle/kaldır (TOGGLE)
  Future<void> toggleFavoriteSound(String soundId) async {
    if (_favoriteSoundIds.contains(soundId)) {
      _favoriteSoundIds.remove(soundId);
    } else {
      _favoriteSoundIds.add(soundId);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_sounds', jsonEncode(_favoriteSoundIds));
    
    notifyListeners();
  }
  
  /// Tüm favorileri temizle
  Future<void> clearAllFavorites() async {
    _favoriteExerciseIds.clear();
    _favoriteSoundIds.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_exercises');
    await prefs.remove('favorite_sounds');
    
    notifyListeners();
  }
} 