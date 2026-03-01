import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore için kullanıcı favorileri modeli
class UserFavoritesData {
  final List<String> exerciseIds;
  final List<String> soundIds;
  final DateTime? lastSyncedAt;

  UserFavoritesData({
    required this.exerciseIds,
    required this.soundIds,
    this.lastSyncedAt,
  });

  /// Firestore'dan oku
  factory UserFavoritesData.fromFirestore(Map<String, dynamic> data) {
    return UserFavoritesData(
      exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
      soundIds: List<String>.from(data['soundIds'] ?? []),
      lastSyncedAt: data['lastSyncedAt'] != null
          ? (data['lastSyncedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'exerciseIds': exerciseIds,
      'soundIds': soundIds,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    };
  }

  /// SharedPreferences'tan oluştur
  factory UserFavoritesData.fromLocal({
    required List<String> exerciseIds,
    required List<String> soundIds,
  }) {
    return UserFavoritesData(
      exerciseIds: exerciseIds,
      soundIds: soundIds,
    );
  }

  UserFavoritesData copyWith({
    List<String>? exerciseIds,
    List<String>? soundIds,
    DateTime? lastSyncedAt,
  }) {
    return UserFavoritesData(
      exerciseIds: exerciseIds ?? this.exerciseIds,
      soundIds: soundIds ?? this.soundIds,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
