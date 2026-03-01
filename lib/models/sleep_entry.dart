class SleepEntry {
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  
  // Sabit standart: 8 saat
  static const int standardTargetHours = 8;
  
  const SleepEntry({
    required this.date,
    required this.bedTime,
    required this.wakeTime,
  });
  
  /// Gerçekte kaç saat uyuduğu
  Duration get actualSleep {
    if (wakeTime.isBefore(bedTime)) {
      // Ertesi gün uyandıysa
      final nextDayWake = wakeTime.add(const Duration(days: 1));
      return nextDayWake.difference(bedTime);
    }
    return wakeTime.difference(bedTime);
  }
  
  /// Hedef uyku süresi (sabit 8 saat standart)
  Duration get targetSleep => const Duration(hours: standardTargetHours);
  
  /// Uyku borcu (negatif ise eksik, pozitif ise fazla)
  Duration get sleepDebt => actualSleep - targetSleep;
  
  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
    };
  }
  
  /// JSON'dan oluştur
  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      date: DateTime.parse(json['date']),
      bedTime: DateTime.parse(json['bedTime']),
      wakeTime: DateTime.parse(json['wakeTime']),
    );
  }
  
  @override
  String toString() {
    return 'SleepEntry(date: $date, actualSleep: ${actualSleep.inHours}h ${actualSleep.inMinutes % 60}m)';
  }
} 