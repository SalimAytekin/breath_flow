import 'package:cloud_firestore/cloud_firestore.dart';

/// Uyku günlüğü kaydı modeli
class JournalEntry {
  final DateTime date;
  final String mood;
  final String note;
  final String dream;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.note,
    required this.dream,
  });

  /// JSON'dan oluştur (SharedPreferences için)
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'] ?? 'neutral',
      note: json['note'] ?? '',
      dream: json['dream'] ?? '',
    );
  }

  /// JSON'a dönüştür (SharedPreferences için)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'note': note,
      'dream': dream,
    };
  }

  /// Firestore'dan oluştur
  factory JournalEntry.fromFirestore(Map<String, dynamic> data) {
    return JournalEntry(
      date: (data['date'] as Timestamp).toDate(),
      mood: data['mood'] ?? 'neutral',
      note: data['note'] ?? '',
      dream: data['dream'] ?? '',
    );
  }

  /// Firestore'a dönüştür
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'note': note,
      'dream': dream,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  JournalEntry copyWith({
    DateTime? date,
    String? mood,
    String? note,
    String? dream,
  }) {
    return JournalEntry(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      dream: dream ?? this.dream,
    );
  }
}
