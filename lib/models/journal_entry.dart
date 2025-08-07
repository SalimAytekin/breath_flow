import 'package:flutter/material.dart';

enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  excellent,
}

extension MoodLevelExtension on MoodLevel {
  String get name {
    switch (this) {
      case MoodLevel.veryBad:
        return 'Çok Kötü';
      case MoodLevel.bad:
        return 'Kötü';
      case MoodLevel.neutral:
        return 'Nötr';
      case MoodLevel.good:
        return 'İyi';
      case MoodLevel.excellent:
        return 'Mükemmel';
    }
  }
  
  String get emoji {
    switch (this) {
      case MoodLevel.veryBad:
        return '😢';
      case MoodLevel.bad:
        return '😕';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.good:
        return '😊';
      case MoodLevel.excellent:
        return '😄';
    }
  }
  
  Color get color {
    switch (this) {
      case MoodLevel.veryBad:
        return const Color(0xFFE53E3E);
      case MoodLevel.bad:
        return const Color(0xFFD69E2E);
      case MoodLevel.neutral:
        return const Color(0xFF718096);
      case MoodLevel.good:
        return const Color(0xFF38A169);
      case MoodLevel.excellent:
        return const Color(0xFF0BC5EA);
    }
  }
  
  int get value {
    switch (this) {
      case MoodLevel.veryBad:
        return 1;
      case MoodLevel.bad:
        return 2;
      case MoodLevel.neutral:
        return 3;
      case MoodLevel.good:
        return 4;
      case MoodLevel.excellent:
        return 5;
    }
  }
}

enum JournalEntryType {
  sessionFeedback,
  dailyReflection,
  gratitude,
  custom,
}

extension JournalEntryTypeExtension on JournalEntryType {
  String get name {
    switch (this) {
      case JournalEntryType.sessionFeedback:
        return 'Seans Değerlendirmesi';
      case JournalEntryType.dailyReflection:
        return 'Günlük Yansıma';
      case JournalEntryType.gratitude:
        return 'Şükran';
      case JournalEntryType.custom:
        return 'Kişisel Not';
    }
  }
  
  IconData get icon {
    switch (this) {
      case JournalEntryType.sessionFeedback:
        return Icons.psychology;
      case JournalEntryType.dailyReflection:
        return Icons.auto_stories;
      case JournalEntryType.gratitude:
        return Icons.favorite;
      case JournalEntryType.custom:
        return Icons.edit_note;
    }
  }
}

class JournalEntry {
  final String id;
  final DateTime timestamp;
  final MoodLevel mood;
  final JournalEntryType type;
  final String? title;
  final String? content;
  final String? sessionType; // Nefes egzersizi, meditasyon vs.
  final int? sessionDuration; // Dakika cinsinden
  final List<String> tags;
  
  const JournalEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.type,
    this.title,
    this.content,
    this.sessionType,
    this.sessionDuration,
    this.tags = const [],
  });
  
  /// Gün başlangıcını al (saat 00:00)
  DateTime get dayStart {
    return DateTime(timestamp.year, timestamp.month, timestamp.day);
  }
  
  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood.toString().split('.').last,
      'type': type.toString().split('.').last,
      'title': title,
      'content': content,
      'sessionType': sessionType,
      'sessionDuration': sessionDuration,
      'tags': tags,
    };
  }
  
  /// JSON'dan oluştur
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      mood: MoodLevel.values.firstWhere((m) => m.toString().split('.').last == json['mood']),
      type: JournalEntryType.values.firstWhere((t) => t.toString().split('.').last == json['type']),
      title: json['title'],
      content: json['content'],
      sessionType: json['sessionType'],
      sessionDuration: json['sessionDuration'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
  
  /// Kopyala ve değiştir
  JournalEntry copyWith({
    String? id,
    DateTime? timestamp,
    MoodLevel? mood,
    JournalEntryType? type,
    String? title,
    String? content,
    String? sessionType,
    int? sessionDuration,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      mood: mood ?? this.mood,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      sessionType: sessionType ?? this.sessionType,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      tags: tags ?? this.tags,
    );
  }
  
  @override
  String toString() {
    return 'JournalEntry(id: $id, mood: ${mood.name}, type: ${type.name})';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Seans feedback'i için yardımcı sınıf
class SessionFeedback {
  final MoodLevel mood;
  final String sessionType;
  final int duration;
  final String? note;
  final List<String> benefits;
  
  const SessionFeedback({
    required this.mood,
    required this.sessionType,
    required this.duration,
    this.note,
    this.benefits = const [],
  });
  
  JournalEntry toJournalEntry() {
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      mood: mood,
      type: JournalEntryType.sessionFeedback,
      title: '$sessionType Seansı',
      content: note,
      sessionType: sessionType,
      sessionDuration: duration,
      tags: benefits,
    );
  }
}

/// Günlük soru şablonları
class JournalPrompts {
  static const List<String> gratitudePrompts = [
    'Bugün minnettar olduğun 3 şey nedir?',
    'Seni mutlu eden küçük bir an neydi?',
    'Bugün sana destek olan kişi kimdi?',
    'Yaşadığın güzel bir deneyim neydi?',
    'Bugün öğrendiğin değerli bir şey var mı?',
  ];
  
  static const List<String> reflectionPrompts = [
    'Bugün nasıl hissettin? Neden?',
    'En çok gurur duyduğun an neydi?',
    'Yarın için kendine ne söylerdin?',
    'Bugün hangi zorlukla karşılaştın ve nasıl üstesinden geldin?',
    'İçindeki sakinliği en çok ne sağladı?',
  ];
  
  static const List<String> sessionBenefits = [
    'Daha sakin hissediyorum',
    'Stresi azaldı',
    'Odaklanabiliyorum',
    'İç huzur buldum',
    'Gevşedim',
    'Berrak düşünüyorum',
    'Gergin kaslar rahatladı',
    'Daha enerjik hissediyorum',
    'Pozitif hissediyorum',
    'Daha güçlü hissediyorum',
  ];
  
  static String getRandomGratitudePrompt() {
    return gratitudePrompts[(DateTime.now().millisecondsSinceEpoch % gratitudePrompts.length)];
  }
  
  static String getRandomReflectionPrompt() {
    return reflectionPrompts[(DateTime.now().millisecondsSinceEpoch % reflectionPrompts.length)];
  }
} 