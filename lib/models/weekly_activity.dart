/// 📊 Haftalık Aktivite Modeli
/// Son 7 günün aktivite verilerini tutar
class WeeklyActivity {
  final DateTime date;
  final int breathingSessions;
  final int soundSessions;
  final int sleepSessions;
  final int totalMinutes;
  
  // 🆕 Aktivite tipine göre dakikalar
  final int breathingMinutes;
  final int soundMinutes;
  final int sleepMinutes;

  WeeklyActivity({
    required this.date,
    this.breathingSessions = 0,
    this.soundSessions = 0,
    this.sleepSessions = 0,
    this.totalMinutes = 0,
    this.breathingMinutes = 0,
    this.soundMinutes = 0,
    this.sleepMinutes = 0,
  });

  int get totalSessions => breathingSessions + soundSessions + sleepSessions;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'breathingSessions': breathingSessions,
      'soundSessions': soundSessions,
      'sleepSessions': sleepSessions,
      'totalMinutes': totalMinutes,
      'breathingMinutes': breathingMinutes,
      'soundMinutes': soundMinutes,
      'sleepMinutes': sleepMinutes,
    };
  }

  factory WeeklyActivity.fromJson(Map<String, dynamic> json) {
    return WeeklyActivity(
      date: DateTime.parse(json['date']),
      breathingSessions: json['breathingSessions'] ?? 0,
      soundSessions: json['soundSessions'] ?? 0,
      sleepSessions: json['sleepSessions'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      breathingMinutes: json['breathingMinutes'] ?? 0,
      soundMinutes: json['soundMinutes'] ?? 0,
      sleepMinutes: json['sleepMinutes'] ?? 0,
    );
  }

  WeeklyActivity copyWith({
    DateTime? date,
    int? breathingSessions,
    int? soundSessions,
    int? sleepSessions,
    int? totalMinutes,
    int? breathingMinutes,
    int? soundMinutes,
    int? sleepMinutes,
  }) {
    return WeeklyActivity(
      date: date ?? this.date,
      breathingSessions: breathingSessions ?? this.breathingSessions,
      soundSessions: soundSessions ?? this.soundSessions,
      sleepSessions: sleepSessions ?? this.sleepSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      breathingMinutes: breathingMinutes ?? this.breathingMinutes,
      soundMinutes: soundMinutes ?? this.soundMinutes,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
    );
  }
}

/// 📈 Haftalık Özet
class WeeklySummary {
  final List<WeeklyActivity> activities;

  WeeklySummary({required this.activities});

  int get totalSessions => activities.fold(0, (sum, activity) => sum + activity.totalSessions);
  int get totalMinutes => activities.fold(0, (sum, activity) => sum + activity.totalMinutes);
  int get totalBreathingSessions => activities.fold(0, (sum, activity) => sum + activity.breathingSessions);
  int get totalSoundSessions => activities.fold(0, (sum, activity) => sum + activity.soundSessions);
  int get totalSleepSessions => activities.fold(0, (sum, activity) => sum + activity.sleepSessions);
  
  // 🆕 Aktivite tipine göre toplam dakikalar
  int get totalBreathingMinutes => activities.fold(0, (sum, activity) => sum + activity.breathingMinutes);
  int get totalSoundMinutes => activities.fold(0, (sum, activity) => sum + activity.soundMinutes);
  int get totalSleepMinutes => activities.fold(0, (sum, activity) => sum + activity.sleepMinutes);

  /// ✅ DÜZELTME: Son 7 gün yerine BU HAFTA (Pazartesi-Pazar)
  /// Bu metod artık tutarlı bir şekilde hafta başlangıcını kullanıyor
  static WeeklySummary getLast7Days(List<WeeklyActivity> allActivities) {
    final now = DateTime.now();
    
    // ✅ DÜZELTME: Pazartesi'yi hafta başı olarak al
    // weekday: 1=Pazartesi, 7=Pazar
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = now.subtract(Duration(days: daysToSubtract));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    // Bu haftaki aktiviteleri al (Pazartesi'den bugüne kadar)
    final currentWeek = allActivities
        .where((activity) {
          final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
          return activityDate.isAfter(startOfWeekDay) || activityDate.isAtSameMomentAs(startOfWeekDay);
        })
        .toList();
    
    return WeeklySummary(activities: currentWeek);
  }
  
  /// 🆕 Gerçekten son 7 gün isteyenler için ayrı metod
  static WeeklySummary getLastSevenDays(List<WeeklyActivity> allActivities) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    final last7Days = allActivities
        .where((activity) => activity.date.isAfter(sevenDaysAgo))
        .toList();
    
    return WeeklySummary(activities: last7Days);
  }
}
