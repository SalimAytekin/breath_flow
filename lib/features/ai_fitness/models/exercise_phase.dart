/// Egzersiz fazları — State Machine'in temel durumları
enum ExercisePhase {
  /// Kullanıcı henüz harekete başlamadı, bekleniyor
  waiting,

  /// Eksantrik faz (örn: Biceps Curl'de kol aşağıya iniyor)
  eccentric,

  /// Konsantrik faz (örn: Biceps Curl'de kol yukarı çıkıyor)
  concentric,

  /// Tekrar tamamlandı
  completed,
}

/// Egzersiz türleri
enum ExerciseType {
  bicepsCurl,
  squat,
  lunge,
  pushUp,
  shoulderPress,
  neckMovement,
}

/// Bir tekrarın sonucu
enum RepQuality {
  /// Mükemmel form
  perfect,

  /// Kabul edilebilir, küçük sapmalar var
  acceptable,

  /// Form bozuk — geri bildirim verilmeli
  bad,
}
