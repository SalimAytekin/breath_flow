import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore için kullanıcı istatistikleri modeli
class UserStatsData {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final DateTime? lastSessionDate;
  final DateTime? lastSyncedAt;

  UserStatsData({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    this.lastSessionDate,
    this.lastSyncedAt,
  });

  /// Firestore'dan oku
  factory UserStatsData.fromFirestore(Map<String, dynamic> data) {
    return UserStatsData(
      totalSessions: data['totalSessions'] ?? 0,
      totalMinutes: data['totalMinutes'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      lastSessionDate: data['lastSessionDate'] != null
          ? (data['lastSessionDate'] as Timestamp).toDate()
          : null,
      lastSyncedAt: data['lastSyncedAt'] != null
          ? (data['lastSyncedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'lastSessionDate': lastSessionDate != null
          ? Timestamp.fromDate(lastSessionDate!)
          : null,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    };
  }

  /// SharedPreferences'tan oluştur
  factory UserStatsData.fromLocal({
    required int totalSessions,
    required int totalMinutes,
    required int currentStreak,
    DateTime? lastSessionDate,
  }) {
    return UserStatsData(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
      lastSessionDate: lastSessionDate,
    );
  }

  UserStatsData copyWith({
    int? totalSessions,
    int? totalMinutes,
    int? currentStreak,
    DateTime? lastSessionDate,
    DateTime? lastSyncedAt,
  }) {
    return UserStatsData(
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
