import 'package:cloud_firestore/cloud_firestore.dart';
import 'mood_type.dart';

/// Firestore için kullanıcı tercihleri modeli
class UserPreferencesData {
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int dailyGoalMinutes;
  final String preferredMood;
  final bool isFirstLaunch;
  final DateTime? lastSyncedAt;

  UserPreferencesData({
    required this.notificationsEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.dailyGoalMinutes,
    required this.preferredMood,
    required this.isFirstLaunch,
    this.lastSyncedAt,
  });

  /// Firestore'dan oku
  factory UserPreferencesData.fromFirestore(Map<String, dynamic> data) {
    return UserPreferencesData(
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      reminderHour: data['reminderHour'] ?? 20,
      reminderMinute: data['reminderMinute'] ?? 0,
      dailyGoalMinutes: data['dailyGoalMinutes'] ?? 10,
      preferredMood: data['preferredMood'] ?? 'relaxation',
      isFirstLaunch: data['isFirstLaunch'] ?? true,
      lastSyncedAt: data['lastSyncedAt'] != null 
          ? (data['lastSyncedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'dailyGoalMinutes': dailyGoalMinutes,
      'preferredMood': preferredMood,
      'isFirstLaunch': isFirstLaunch,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    };
  }

  /// SharedPreferences'tan oluştur
  factory UserPreferencesData.fromLocal({
    required bool notificationsEnabled,
    required int reminderHour,
    required int reminderMinute,
    required int dailyGoalMinutes,
    required MoodType preferredMood,
    required bool isFirstLaunch,
  }) {
    return UserPreferencesData(
      notificationsEnabled: notificationsEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      dailyGoalMinutes: dailyGoalMinutes,
      preferredMood: preferredMood.name.toLowerCase(),
      isFirstLaunch: isFirstLaunch,
    );
  }

  UserPreferencesData copyWith({
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? dailyGoalMinutes,
    String? preferredMood,
    bool? isFirstLaunch,
    DateTime? lastSyncedAt,
  }) {
    return UserPreferencesData(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      preferredMood: preferredMood ?? this.preferredMood,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
