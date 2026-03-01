import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_type.dart';
import '../models/weekly_activity.dart';
import '../services/notification_service.dart';
import '../services/user_data_sync_service.dart';
import '../models/user_preferences_data.dart';
import '../models/user_stats_data.dart';
import '../models/user_favorites_data.dart';

// Yeni eklenen enum
enum MindfulSessionType { none, breathing, sleep, hrv, meditation }

class UserPreferencesProvider extends ChangeNotifier {
  // 🔄 Firestore sync servisi
  final UserDataSyncService _syncService = UserDataSyncService();
  bool _isSyncing = false;
  bool _isLoaded = false;
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
  bool get isLoaded => _isLoaded;
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
    
    // 🔄 ADIM 1: Local verileri yükle (hızlı başlangıç)
    await _loadLocalPreferences(prefs);
    
    // 🔄 ADIM 2: Firestore'dan sync et (arka planda)
    if (_syncService.isUserLoggedIn) {
      _syncFromFirestore();
    }
  }
  
  Future<void> _loadLocalPreferences(SharedPreferences prefs) async {
    
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
    
    _isLoaded = true;
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
    
    // 🔄 Firestore'a sync et
    _syncPreferencesToFirestore();
    
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
    
    // 🔄 Firestore'a sync et
    _syncPreferencesToFirestore();
    
    notifyListeners();
  }
  
  Future<void> setDailyGoalMinutes(int minutes) async {
    _dailyGoalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal_minutes', minutes);
    
    // 🔄 Firestore'a sync et
    _syncPreferencesToFirestore();
    
    notifyListeners();
  }
  
  Future<void> setPreferredMood(MoodType mood) async {
    _preferredMood = mood;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_mood', mood.name.toLowerCase());
    
    // 🔄 Firestore'a sync et
    _syncPreferencesToFirestore();
    
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
    
    // 🔄 Firestore'a sync et
    _syncStatsToFirestore();
    
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
      if (kDebugMode) debugPrint('❌ Bugünkü dakika hesaplama hatası: $e');
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
        if (kDebugMode) debugPrint('🚫 Yinelenen ses seansı algılandı (diff=${diff}s), kayıt atlandı');
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
    
    if (kDebugMode) debugPrint('🎵 Ses dinleme seansı kaydedildi: $durationMinutes dakika');
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
    
    // 🔄 Firestore'a sync et
    _syncActivitiesToFirestore();
    
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
      if (kDebugMode) debugPrint('✅ Haftalık aktiviteler kaydedildi (${_weeklyActivities.length} kayıt)');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Haftalık aktivite kaydetme hatası: $e');
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
              if (kDebugMode) debugPrint('⚠️ Tek aktivite parse edilemedi, atlanıyor: $itemError');
              // Continue with other items instead of losing all data
            }
          }
          
          _weeklyActivities = loadedActivities;
          
          if (loadedActivities.isEmpty && activitiesJson.isNotEmpty) {
            // All items failed to parse - corrupted data
            if (kDebugMode) debugPrint('❌ Tüm aktivite verileri bozuk, yedekten geri yükleme deneniyor');
            await _tryRestoreFromBackup(prefs);
          }
        } catch (e) {
          if (kDebugMode) debugPrint('❌ JSON parse hatası: $e');
          // Try to restore from backup before giving up
          await _tryRestoreFromBackup(prefs);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Haftalık aktivite yükleme hatası: $e');
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
        if (kDebugMode) debugPrint('✅ Yedekten ${_weeklyActivities.length} aktivite geri yüklendi');
      } else {
        _weeklyActivities = [];
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Yedek geri yükleme başarısız: $e');
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
    
    // 🔄 Firestore'a sync et
    _syncFavoritesToFirestore();
    
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
    
    // 🔄 Firestore'a sync et
    _syncFavoritesToFirestore();
    
    notifyListeners();
  }
  
  /// Tüm favorileri temizle
  Future<void> clearAllFavorites() async {
    _favoriteExerciseIds.clear();
    _favoriteSoundIds.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_exercises');
    await prefs.remove('favorite_sounds');
    
    _syncFavoritesToFirestore();
    
    notifyListeners();
  }
  
  // ================================
  // 🔄 FIRESTORE SYNC METODLARI
  // ================================
  
  /// Firestore'dan tüm verileri yükle ve local ile birleştir
  Future<void> _syncFromFirestore() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      if (kDebugMode) debugPrint('🔄 Firestore sync başlatılıyor...');
      
      // Paralel olarak tüm verileri yükle
      final results = await Future.wait([
        _syncService.loadPreferences(),
        _syncService.loadStats(),
        _syncService.loadFavorites(),
        _syncService.loadWeeklyActivities(),
      ]);
      
      final remotePrefs = results[0] as UserPreferencesData?;
      final remoteStats = results[1] as UserStatsData?;
      final remoteFavorites = results[2] as UserFavoritesData?;
      final remoteActivities = results[3] as List<WeeklyActivity>;
      
      // Tercihleri birleştir
      if (remotePrefs != null) {
        _notificationsEnabled = remotePrefs.notificationsEnabled;
        _reminderTime = TimeOfDay(
          hour: remotePrefs.reminderHour,
          minute: remotePrefs.reminderMinute,
        );
        _dailyGoalMinutes = remotePrefs.dailyGoalMinutes;
        _preferredMood = MoodType.values.firstWhere(
          (mood) => mood.name.toLowerCase() == remotePrefs.preferredMood.toLowerCase(),
          orElse: () => MoodType.relaxation,
        );
        _isFirstLaunch = remotePrefs.isFirstLaunch;
        
        // Local'e de kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', _notificationsEnabled);
        await prefs.setInt('reminder_hour', _reminderTime.hour);
        await prefs.setInt('reminder_minute', _reminderTime.minute);
        await prefs.setInt('daily_goal_minutes', _dailyGoalMinutes);
        await prefs.setString('preferred_mood', _preferredMood.name.toLowerCase());
        await prefs.setBool('is_first_launch', _isFirstLaunch);
      }
      
      // İstatistikleri birleştir
      if (remoteStats != null) {
        // 🔄 Remote öncelikli birleştirme (cross-device sync için)
        // En yüksek değerleri kullan (conflict resolution)
        final shouldUseRemote = remoteStats.totalSessions > _totalSessions ||
            (_totalSessions == 0 && remoteStats.totalSessions > 0);
        
        if (shouldUseRemote) {
          _totalSessions = remoteStats.totalSessions;
          _totalMinutes = remoteStats.totalMinutes;
          _currentStreak = remoteStats.currentStreak;
          _lastSessionDate = remoteStats.lastSessionDate;
          
          if (kDebugMode) debugPrint('📊 Remote stats alındı: sessions=$_totalSessions, streak=$_currentStreak');
          
          // Local'e kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('total_sessions', _totalSessions);
          await prefs.setInt('total_minutes', _totalMinutes);
          await prefs.setInt('current_streak', _currentStreak);
          if (_lastSessionDate != null) {
            await prefs.setString('last_session_date', _lastSessionDate!.toIso8601String());
          }
        }
      }
      
      // Favorileri birleştir
      if (remoteFavorites != null) {
        // Birleştir (union)
        final allExercises = {..._favoriteExerciseIds, ...remoteFavorites.exerciseIds}.toList();
        final allSounds = {..._favoriteSoundIds, ...remoteFavorites.soundIds}.toList();
        
        _favoriteExerciseIds = allExercises;
        _favoriteSoundIds = allSounds;
        
        // Local'e kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('favorite_exercises', jsonEncode(_favoriteExerciseIds));
        await prefs.setString('favorite_sounds', jsonEncode(_favoriteSoundIds));
      }
      
      // Haftalık aktiviteleri birleştir
      if (remoteActivities.isNotEmpty) {
        // 🔄 Tarih bazlı birleştirme - EN YÜKSEK değerleri kullan (duplicate önleme)
        final activityMap = <String, WeeklyActivity>{};
        
        // Local aktiviteleri ekle
        for (final activity in _weeklyActivities) {
          final key = activity.date.toIso8601String().split('T')[0];
          activityMap[key] = activity;
        }
        
        // Remote aktiviteleri ekle/güncelle
        for (final activity in remoteActivities) {
          final key = activity.date.toIso8601String().split('T')[0];
          if (activityMap.containsKey(key)) {
            // 🔄 EN YÜKSEK değerleri kullan (duplicate önleme için toplama yerine max)
            final existing = activityMap[key]!;
            activityMap[key] = WeeklyActivity(
              date: activity.date,
              breathingSessions: existing.breathingSessions > activity.breathingSessions 
                  ? existing.breathingSessions : activity.breathingSessions,
              soundSessions: existing.soundSessions > activity.soundSessions 
                  ? existing.soundSessions : activity.soundSessions,
              sleepSessions: existing.sleepSessions > activity.sleepSessions 
                  ? existing.sleepSessions : activity.sleepSessions,
              totalMinutes: existing.totalMinutes > activity.totalMinutes 
                  ? existing.totalMinutes : activity.totalMinutes,
              breathingMinutes: existing.breathingMinutes > activity.breathingMinutes 
                  ? existing.breathingMinutes : activity.breathingMinutes,
              soundMinutes: existing.soundMinutes > activity.soundMinutes 
                  ? existing.soundMinutes : activity.soundMinutes,
              sleepMinutes: existing.sleepMinutes > activity.sleepMinutes 
                  ? existing.sleepMinutes : activity.sleepMinutes,
            );
          } else {
            activityMap[key] = activity;
          }
        }
        
        _weeklyActivities = activityMap.values.toList();
        await _saveWeeklyActivities();
        if (kDebugMode) debugPrint('📊 Haftalık aktiviteler birleştirildi: ${_weeklyActivities.length} gün');
      }
      
      if (kDebugMode) debugPrint('✅ Firestore sync tamamlandı');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore sync hatası: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Tercihleri Firestore'a kaydet
  Future<void> _syncPreferencesToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    final data = UserPreferencesData.fromLocal(
      notificationsEnabled: _notificationsEnabled,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      dailyGoalMinutes: _dailyGoalMinutes,
      preferredMood: _preferredMood,
      isFirstLaunch: _isFirstLaunch,
    );
    
    // Arka planda sync et (await kullanma)
    _syncService.syncPreferences(data).catchError((e) {
      if (kDebugMode) debugPrint('❌ Tercih sync hatası: $e');
    });
  }
  
  /// İstatistikleri Firestore'a kaydet
  Future<void> _syncStatsToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    final data = UserStatsData.fromLocal(
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      currentStreak: _currentStreak,
      lastSessionDate: _lastSessionDate,
    );
    
    // Arka planda sync et
    _syncService.syncStats(data).catchError((e) {
      if (kDebugMode) debugPrint('❌ İstatistik sync hatası: $e');
    });
  }
  
  /// Favorileri Firestore'a kaydet
  Future<void> _syncFavoritesToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    final data = UserFavoritesData.fromLocal(
      exerciseIds: _favoriteExerciseIds,
      soundIds: _favoriteSoundIds,
    );
    
    // Arka planda sync et
    _syncService.syncFavorites(data).catchError((e) {
      if (kDebugMode) debugPrint('❌ Favori sync hatası: $e');
    });
  }
  
  /// Haftalık aktiviteleri Firestore'a kaydet
  Future<void> _syncActivitiesToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    // Arka planda sync et
    _syncService.syncWeeklyActivities(_weeklyActivities).catchError((e) {
      if (kDebugMode) debugPrint('❌ Aktivite sync hatası: $e');
    });
  }
  
  /// Manuel full sync (kullanıcı giriş yaptığında çağrılır)
  Future<void> performFullSync() async {
    if (kDebugMode) debugPrint('🔄 Full sync başlatılıyor...');
    
    // Önce Firestore'dan yükle
    await _syncFromFirestore();
    
    // Sonra local verileri Firestore'a gönder
    await Future.wait([
      _syncPreferencesToFirestore(),
      _syncStatsToFirestore(),
      _syncFavoritesToFirestore(),
      _syncActivitiesToFirestore(),
    ]);
    
    if (kDebugMode) debugPrint('✅ Full sync tamamlandı');
  }
  
  // ================================
  // 🚪 OTURUM KAPATMA - VERİ TEMİZLEME
  // ================================
  
  /// Oturum kapatıldığında TÜM kullanıcı verilerini temizle
  /// Yeni kullanıcı giriş yaptığında Firestore'dan kendi verilerini çekecek
  Future<void> clearAllDataOnLogout() async {
    if (kDebugMode) debugPrint('🚪 UserPreferences verileri temizleniyor...');
    
    // 1. Memory'deki verileri varsayılana sıfırla
    _notificationsEnabled = true;
    _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    _dailyGoalMinutes = 10;
    _preferredMood = MoodType.relaxation;
    // _isFirstLaunch DEĞİŞTİRİLMEZ — logout yapılsa bile onboarding tekrar gösterilmemeli
    
    // İstatistikler
    _totalSessions = 0;
    _totalMinutes = 0;
    _currentStreak = 0;
    _lastSessionDate = null;
    
    // Akıllı öneri verileri
    _lastSleepDurationHours = null;
    _lastHrvScore = null;
    _lastSessionType = MindfulSessionType.none;
    _lastBreathingSessionTimestamp = null;
    _lastSleepSessionTimestamp = null;
    _lastHrvSessionTimestamp = null;
    _lastSoundSessionTimestamp = null;
    
    // Haftalık aktiviteler ve favoriler
    _weeklyActivities.clear();
    _favoriteExerciseIds.clear();
    _favoriteSoundIds.clear();
    
    // 2. SharedPreferences'tan temizle (DOĞRU KEY İSİMLERİ)
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tercihler (key isimleri _loadLocalPreferences ile eşleşmeli)
      await prefs.remove('notifications_enabled');
      await prefs.remove('reminder_hour');        // ✅ Doğru key
      await prefs.remove('reminder_minute');      // ✅ Doğru key
      await prefs.remove('daily_goal_minutes');
      await prefs.remove('preferred_mood');
      // is_first_launch SİLİNMEZ — logout yapılsa bile onboarding tekrar gösterilmemeli
      
      // İstatistikler
      await prefs.remove('total_sessions');
      await prefs.remove('total_minutes');
      await prefs.remove('current_streak');
      await prefs.remove('last_session_date');
      
      // Akıllı öneri verileri (key isimleri _loadLocalPreferences ile eşleşmeli)
      await prefs.remove('last_sleep_duration_hours');
      await prefs.remove('last_hrv_score');
      await prefs.remove('last_session_type');
      await prefs.remove('last_breathing_timestamp');  // ✅ Doğru key
      await prefs.remove('last_sleep_timestamp');      // ✅ Doğru key
      await prefs.remove('last_hrv_timestamp');        // ✅ Doğru key
      await prefs.remove('last_sound_timestamp');
      
      // Haftalık aktiviteler ve favoriler (key isimleri eşleşmeli)
      await prefs.remove('weekly_activities');
      await prefs.remove('favorite_exercises');   // ✅ Doğru key
      await prefs.remove('favorite_sounds');      // ✅ Doğru key
      
      if (kDebugMode) debugPrint('✅ UserPreferences SharedPreferences temizlendi');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ UserPreferences temizleme hatası: $e');
    }
    
    // 3. UI'ı güncelle
    notifyListeners();
    
    if (kDebugMode) debugPrint('✅ UserPreferences verileri temizlendi');
  }
} 
