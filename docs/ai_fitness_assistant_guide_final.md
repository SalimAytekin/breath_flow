# 🏋️ Flutter + MediaPipe AI Fitness Asistanı
## Breath Flow Uygulamasına Entegrasyon — Teknik Rehber

> **Hedef:** Mevcut `breath_flow` mimarisini bozmadan, spaghetti koda dönüştürmeden, gerçek zamanlı egzersiz analizi yapan modüler bir AI Fitness modülü entegre etmek.

---

## 📋 İçindekiler

1. [Mimari Tasarım — Neden Strategy + State Machine?](#1-mimari-tasarım)
2. [Klasör Yapısı ve Dosya Organizasyonu](#2-klasör-yapısı)
3. [Hata Toleransı — Confidence Score ve Temporal Smoothing](#3-hata-toleransı)
4. [Performans Optimizasyonu — Dart Isolate + Platform Channel](#4-performans)
5. [UX ve Geri Bildirim Sistemi](#5-ux-ve-geri-bildirim)
6. [Matematiksel Analiz — Açılar, Vektörler ve Zaman Serisi](#6-matematiksel-analiz)
7. [Adım Adım Entegrasyon Yol Haritası](#7-entegrasyon-yol-haritası)
8. [Kritik Değerlendirme ve Kaçınılacak Hatalar](#8-kritik-değerlendirme)
9. [Test Ekranı ve Projeye Entegrasyon (ÖNEMLİ)](#9-test-ekranı)

---

## 1. Mimari Tasarım

### ❌ Neden Saf Strategy Pattern Yetmez?

Sadece Strategy Pattern kullanırsanız şu sorunu yaşarsınız:

```dart
// ❌ Kötü yaklaşım — State yönetimi karmaşıklaşır
class ExerciseValidator {
  bool validate(List<Landmark> landmarks) { ... } // Hangi aşamadayız?
}
```

Tek bir `validate()` metodu yetmez; çünkü egzersizin **hangi fazında** olduğunuzu bilmeniz gerekir: bekleme → iniş → dip nokta → çıkış → tamamlandı.

### ✅ Önerilen: Strategy + State Machine Kombinasyonu

```
PoseDetectorService (Kamera + ML Kit)
         │
         ▼
ExerciseController (State Machine + Sayaç)
         │
    ┌────┴────┐
    ▼         ▼
IExerciseValidator  FeedbackEngine
(Strategy Pattern)  (Haptic/Audio/Visual)
    │
    ├── BicepsCurlValidator
    ├── SquatValidator
    ├── LungeValidator
    └── PushUpValidator
```

**Neden bu yapı?**
- `PoseDetectorService` → Tek sorumluluk: Ham landmark verisi üretmek
- `ExerciseController` → Tek sorumluluk: Rep saymak + fazı yönetmek
- `IExerciseValidator` → Tek sorumluluk: O egzersizin geometrik kuralları
- `FeedbackEngine` → Tek sorumluluk: Kullanıcıya geri bildirim vermek

Yeni bir egzersiz eklemek = Yalnızca yeni bir `Validator` sınıfı oluşturmak.

---

## 2. Klasör Yapısı

Mevcut `lib/` yapınıza **dokunmadan** yeni bir modül klasörü açıyoruz:

```
lib/
├── screens/          ← Mevcut (değişmez)
├── services/         ← Mevcut (değişmaz)
├── providers/        ← Mevcut (değişmaz)
│
└── features/         ← YENİ MODÜL (sadece burası ekleniyor)
    └── ai_fitness/
        ├── models/
        │   ├── exercise_phase.dart       # Enum: waiting/down/up/complete
        │   ├── landmark_point.dart       # ML Kit landmark wrapper
        │   ├── rep_result.dart           # Tek tekrarın sonucu
        │   └── exercise_config.dart      # Egzersiz ayarları (açı eşikleri)
        │
        ├── validators/
        │   ├── i_exercise_validator.dart # Abstract interface
        │   ├── biceps_curl_validator.dart
        │   ├── squat_validator.dart
        │   ├── lunge_validator.dart
        │   └── pushup_validator.dart
        │
        ├── services/
        │   ├── pose_detector_service.dart   # ML Kit entegrasyonu
        │   ├── exercise_controller.dart     # State machine + rep counter
        │   ├── landmark_smoother.dart       # Temporal smoothing
        │   └── feedback_engine.dart         # Haptic/Audio/Visual
        │
        ├── providers/
        │   └── fitness_session_provider.dart  # Riverpod/Provider state
        │
        └── screens/
            ├── fitness_exercise_screen.dart   # Ana egzersiz Kamerası ve UI
            └── fitness_session_summary.dart   # Sonuç özeti
```

> [!IMPORTANT]
> Mevcut `lib/services/` veya `lib/screens/` klasörlerine **hiçbir şey eklemeyin**. Tüm AI Fitness kodu `lib/features/ai_fitness/` içinde izole kalmalıdır.

---

## 3. Hata Toleransı

### ML Kit'te Yaşadığınız Sorun: False Positives

ML Kit'in ortak sorunu: Gövde kıvrıldığında ya da kamera açısı değiştiğinde landmark'lar **yanlış vücut bölgesine** atanabiliyor.

### 3.1 — Üç Katmanlı Filtre Sistemi

```dart
// landmark_smoother.dart
class LandmarkSmoother {
  // Katman 1: Confidence Score filtresi
  static const double _minConfidence = 0.65; // ML Kit visibility skoru

  // Katman 2: Son N frame'in ortalaması (Temporal Smoothing)
  final int _windowSize = 5;
  final Map<int, Queue<LandmarkPoint>> _history = {};

  LandmarkPoint? smooth(int landmarkIndex, LandmarkPoint raw) {
    if (raw.visibility < _minConfidence) return null;

    _history.putIfAbsent(landmarkIndex, () => Queue());
    final queue = _history[landmarkIndex]!;
    queue.add(raw);
    if (queue.length > _windowSize) queue.removeFirst();

    final avgX = queue.map((p) => p.x).reduce((a, b) => a + b) / queue.length;
    final avgY = queue.map((p) => p.y).reduce((a, b) => a + b) / queue.length;
    final avgZ = queue.map((p) => p.z).reduce((a, b) => a + b) / queue.length;

    return LandmarkPoint(x: avgX, y: avgY, z: avgZ, visibility: raw.visibility);
  }
}
```

---

## 4. Performans

### 4.1 — Native vs Flutter Optimizasyonu (KAPALI KUTU)
Native klasörlerde (`android/app/src/main/java` veya `ios/Runner`) hiçbir özel C++/Java kurulumu **yapılmayacak!** Bunun yerine doğrudan pub.dev üzerindeki `google_mlkit_pose_detection` paketi kullanılacak. Paketin içi zaten C++ ve Native Java/Swift köprüsünü hazır bulunduruyor. Yani görüntü işleme yükü tamamen Native'de olacak, biz sadece sonuçları (koordinatları) dinleyeceğiz.

```dart
// pose_detector_service.dart
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  int _lastProcessedTime = 0;
  static const int _frameIntervalMs = 66; // ~15 FPS Throttle

  Future<List<LandmarkPoint>?> detectPose(InputImage inputImage) async {
    // 15 FPS Limiti: Cihazın ısınmasını önler
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedTime < _frameIntervalMs) return null;
    _lastProcessedTime = now;

    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;
      
      // Sadece Flutter tarafına noktalar döner (Native taraf ağır işi halletti bile)
      return _parseLandmarks(poses.first);
    } catch (e) {
      // Hata yönetimi
      return null;
    }
  }
}
```

### 4.2 — Dart Isolate ile Matematiksel İşlemleri Ayırma
Açı hesaplama gibi işlemleri `Isolate` (arka plan iş parçacığı) ile yapın ki UI takılmasın.

---

## 5. UX ve Geri Bildirim

Sadece `vibration` eklentisi ve pre-recorded (önceden kaydedilmiş mp3) seslerle delay (gecikme) yaratmadan geri bildirim sunun.

```dart
import 'package:vibration/vibration.dart';

class HapticFeedbackService {
  static Future<void> correctRep() async {
    await Vibration.vibrate(duration: 150, amplitude: 128);
  }

  static Future<void> wrongForm() async {
    await Vibration.vibrate(pattern: [0, 80, 50, 80]); // 2 kısa darbe
  }
}
```

---

## 6. Matematiksel Analiz

Basit açı hesaplama motoru kullanın. Her validator `IExerciseValidator`'dan türetilmeli ve `calculateAngle()` kullanmalıdır. DTW (zaman serisi) algoritmaları V1 için uygulanmamalıdır.

---

## 7. Entegrasyon Yol Haritası

### Faz 1 — Temel Altyapı
- `pubspec.yaml`'a `google_mlkit_pose_detection`, `camera`, `vibration` paketlerini ekle.
- `lib/features/ai_fitness/` klasör hiyerarşisini kur.
- `BicepsCurlValidator` yaz.

### Faz 2 — UI ve Kamera Entegrasyonu
- `FitnessExerciseScreen` yaz ve kamerayı canlı ön izleme ile ekrana oturt (Stack widget kullanımı).
- İskeleti UI üzerinde çiz (`CustomPaint`).

---

## 8. Kritik Değerlendirme

Tüm mantığı tek dosyada (`FitnessExerciseScreen.dart`) toplamaktan **kesinlikle kaçının.** Ekran sadece kamerayı göstermeli ve Provider/Bloc üzerinden gelen state ile çizim yapmalıdır. Ağır iş `PoseDetectorService`'de, sayım işi `ExerciseController`'da olmalıdır.

---

## 9. Test Ekranı ve Projeye Entegrasyon (AI İÇİN TALİMAT!) 🚨

**Bu belgeyi uygulayacak olan Yazılımcı / AI Asistanının dikkatine:** 

Modül geliştirmesi bittikten sonra, bu modülü gerçek cihazda test edebilmemiz için şu adımları TIKPA TIK uygula:

1. **Test Giriş Noktası:** Mevcut projede bulunan `MainNavigationScreen.dart` (alt navigasyon barının olduğu ana sayfa) veya `ExploreScreen.dart` içerisine **"AI Fitness Test"** adında geçici bir `ElevatedButton` veya FAB (Floating Action Button) ekle.
2. **Yönlendirme:** Bu butona tıklandığında `Navigator.push` kullanarak kullanıcıyı yeni yazdığın `FitnessExerciseScreen` ekranına yönlendir.
3. **FitnessExerciseScreen'in İçeriği:** Bu ekran şunları zorunlu olarak içermelidir:
   - Tam ekran kamera önizlemesi (`CameraPreview`).
   - Kamera önizlemesi üzerinde `CustomPaint` ile çizilen MediaPipe eklem noktaları (Skeleton).
   - Ekranın üst kısmında büyük puntolarla anlık omuz-dirsek-bilek **AÇISI (Derece)**.
   - Ekranın altında **Rep Sayacı (Örn: 5/12)**.
4. **Hafıza Yönetimi:** Test ekranından geri dönüldüğünde (Pop) `dispose()` metodunda `CameraController`'ı ve ML Kit arka plan işlemlerini kesinlikle kapat ve belleği temizle. Aksi taktirde cihazda hafıza sızıntısı ve aşırı ısınma meydana gelir.
