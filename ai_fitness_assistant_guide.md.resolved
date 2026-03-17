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
PoseDetectorService (Kamera + MediaPipe)
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
        │   ├── landmark_point.dart       # MediaPipe landmark wrapper
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
        │   ├── pose_detector_service.dart   # MediaPipe bridge
        │   ├── exercise_controller.dart     # State machine + rep counter
        │   ├── landmark_smoother.dart       # Temporal smoothing
        │   └── feedback_engine.dart         # Haptic/Audio/Visual
        │
        ├── providers/
        │   └── fitness_session_provider.dart  # Riverpod/Provider state
        │
        └── screens/
            ├── fitness_exercise_screen.dart   # Ana egzersiz ekranı
            └── fitness_session_summary.dart   # Sonuç özeti
```

> [!IMPORTANT]
> Mevcut `lib/services/` veya `lib/screens/` klasörlerine **hiçbir şey eklemeyin**. Tüm AI Fitness kodu `lib/features/ai_fitness/` içinde izole kalmalıdır.

---

## 3. Hata Toleransı

### ML Kit'te Yaşadığınız Sorun: False Positives

ML Kit ve MediaPipe'ın ortak sorunu: Gövde kıvrıldığında ya da kamera açısı değiştiğinde landmark'lar **yanlış vücut bölgesine** atanabiliyor.

### 3.1 — Üç Katmanlı Filtre Sistemi

```dart
// landmark_smoother.dart
class LandmarkSmoother {
  // Katman 1: Confidence Score filtresi
  static const double _minConfidence = 0.65; // MediaPipe'ın visibility skoru

  // Katman 2: Son N frame'in ortalaması (Temporal Smoothing)
  final int _windowSize = 5;
  final Map<int, Queue<LandmarkPoint>> _history = {};

  LandmarkPoint? smooth(int landmarkIndex, LandmarkPoint raw) {
    // Katman 1: Düşük güvenilirlikli frame'leri at
    if (raw.visibility < _minConfidence) return null;

    // Katman 2: Geçmiş frame'lerle ortalama al
    _history.putIfAbsent(landmarkIndex, () => Queue());
    final queue = _history[landmarkIndex]!;
    queue.add(raw);
    if (queue.length > _windowSize) queue.removeFirst();

    final avgX = queue.map((p) => p.x).reduce((a, b) => a + b) / queue.length;
    final avgY = queue.map((p) => p.y).reduce((a, b) => a + b) / queue.length;
    final avgZ = queue.map((p) => p.z).reduce((a, b) => a + b) / queue.length;

    return LandmarkPoint(x: avgX, y: avgY, z: avgZ, visibility: raw.visibility);
  }

  // Katman 3: Z-ekseni derinlik tutarlılığı kontrolü
  bool isDepthConsistent(LandmarkPoint shoulder, LandmarkPoint elbow) {
    // Dirsek omuzdan daha önde ya da geride olamaz (belirli eşiğin üzerinde)
    return (shoulder.z - elbow.z).abs() < 0.3;
  }
}
```

### 3.2 — Güven Skoru Renk Skalası (UI'da gösterim)

| Skor | Durum | Kullanıcıya Gösterim |
|------|-------|----------------------|
| ≥ 0.80 | ✅ Güvenilir | Yeşil iskelet |
| 0.65–0.79 | ⚠️ Orta | Sarı iskelet |
| < 0.65 | ❌ Filtrelendi | Kırmızı + "Pozisyonu düzeltin" |

### 3.3 — Z-Ekseni ile Derinlik Doğrulaması

```dart
// Sadece 2D açı hesaplamak yanıltıcı olabilir
// Kol kameraya doğru dönmüşse "doğru açı" yanlış hareket gösterebilir

bool _isArmFacingCamera(LandmarkPoint wrist, LandmarkPoint shoulder) {
  // z pozitif = kameradan uzakta, negatif = kameraya yakın
  final zDiff = shoulder.z - wrist.z;
  return zDiff.abs() < 0.15; // Kol kameraya paralel
}
```

---

## 4. Performans

### 4.1 — Isınma Sorununun Kökü

Isınmanın 3 ana sebebi:
1. Her frame'de Flutter main thread'inde hesaplama yapmak
2. MediaPipe çıktısını UI thread'de parse etmek
3. Gereksiz `setState()` çağrıları

### 4.2 — Dart Isolate ile Hesaplamayı Ana Thread'den Ayırma

```dart
// exercise_controller.dart
import 'dart:isolate';

class ExerciseController {
  late Isolate _analysisIsolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  Future<void> initialize() async {
    _receivePort = ReceivePort();
    _analysisIsolate = await Isolate.spawn(
      _analysisLoop,          // Hesaplama fonksiyonu
      _receivePort.sendPort,  // Ana thread'e veri gönder
    );
    _sendPort = await _receivePort.first;
    _receivePort.listen(_onAnalysisResult);
  }

  // Bu fonksiyon ISOLATE'de çalışır — UI donmaz
  static void _analysisLoop(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      final landmarks = message as List<LandmarkPoint>;
      // Açı hesapla, faz kontrol et, feedback üret
      final result = _computeRepResult(landmarks);
      mainSendPort.send(result); // Sonucu ana thread'e gönder
    });
  }

  void processPose(List<PoseLandmark> landmarks) {
    // Ana thread'den Isolate'e landmark gönder
    _sendPort.send(landmarks);
  }
}
```

### 4.3 — Platform Channel ile Native Optimizasyon

```dart
// pose_detector_service.dart
class PoseDetectorService {
  static const _channel = MethodChannel('breath_flow/pose_detector');

  Future<List<LandmarkPoint>?> detectPose(CameraImage image) async {
    try {
      final result = await _channel.invokeMethod('detectPose', {
        'planes': image.planes.map((p) => p.bytes).toList(),
        'width': image.width,
        'height': image.height,
        'rotation': image.rotationDegrees,
      });
      return _parseLandmarks(result);
    } on PlatformException catch (e) {
      debugPrint('Pose detection failed: ${e.message}');
      return null;
    }
  }
}
```

### 4.4 — FPS Kontrolü: Throttle Mekanizması

```dart
// Her frame işleme gerek yok! 15-20 FPS yeterli.
class PoseDetectorService {
  int _lastProcessedTime = 0;
  static const int _frameIntervalMs = 66; // ~15 FPS

  void onNewFrame(CameraImage image) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedTime < _frameIntervalMs) return; // Atla
    _lastProcessedTime = now;
    detectPose(image);
  }
}
```

### 4.5 — Performans Özeti

| Teknik | Kazanım | Uygulanma Yeri |
|--------|---------|----------------|
| Frame throttling (15 FPS) | %50 CPU azalması | `PoseDetectorService` |
| Dart Isolate | UI donmalarını engeller | `ExerciseController` |
| Landmark smoothing (window=5) | Titreşen hesaplamalar engellenir | `LandmarkSmoother` |
| `RepaintBoundary` | Gereksiz widget rebuild'leri önlenir | `FitnessExerciseScreen` |
| Native MediaPipe (Android/iOS) | GPU/NPU kullanımı | Platform Channel |

---

## 5. UX ve Geri Bildirim

### 5.1 — Feedback Engine Mimarisi

```dart
// feedback_engine.dart
class FeedbackEngine {
  final AudioPlayer _audioPlayer;
  
  // Öncelik sistemi: Aynı anda birden fazla hata varsa hangisini söyle?
  Future<void> giveFeedback(List<FormError> errors) async {
    if (errors.isEmpty) {
      await _onCorrectForm(); // Vibration + yeşil flash
      return;
    }

    // En kritik hatayı bul (öncelik sırasına göre)
    final topError = errors.reduce((a, b) => a.priority > b.priority ? a : b);
    await _onFormError(topError);
  }

  // 1️⃣ GÖRSEL: Iskelet üzerindeki hatalı eklemler kırmızıya döner
  // 2️⃣ METİN: Ekran üstünde "Dirseklerini sabitle" gibi anlık mesaj
  // 3️⃣ SESLİ: TTS veya pre-recorded ses dosyası
  // 4️⃣ HAPTİK: Yanlış form = 2 kısa titreşim, doğru rep = 1 uzun titreşim
}
```

### 5.2 — Kullanıcı Geri Bildirim Katmanları

```
┌─────────────────────────────────────┐
│  📹 Kamera Önizlemesi               │
│                                     │
│  ─── Iskelet Overlay ───            │
│  Yeşil = doğru eklem               │
│  Kırmızı = hatalı eklem            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⚠️  "Sırtını dik tut!"     │   │← Anlık metin (3 saniye)
│  └─────────────────────────────┘   │
│                                     │
│  Açı: 145°  [████████░░] %80       │← Progress bar (doğru aralığa doğru)
│                                     │
│  Rep: 8 / 12  ⏱ 0:45              │← Sayaç + süre
└─────────────────────────────────────┘
```

### 5.3 — Anlık Geri Bildirim Zamanlaması

| Gecikme | Yöntem | Etki |
|---------|--------|------|
| < 100ms | Görsel (iskelet rengi) | Anlık, bilinçdışı algı |
| 200–400ms | Haptik titreşim | Refleks düzeltmesi |
| 500–800ms | Sesli uyarı | Bilinçli düzeltme |

> [!TIP]
> **Ses dosyaları için TTS yerine pre-recorded kullanın.** Türkçe TTS motoru (özellikle Android) `flutter_tts` paketi üzerinde 200-500ms gecikme yaratır. `AudioPlayer` ile önceden kaydedilmiş `.mp3` dosyaları kullanmak çok daha düşük gecikmeli ve doğal ses kalitesi sağlar.

### 5.4 — Haptik Titreşim Protokolü

```dart
import 'package:vibration/vibration.dart';

class HapticFeedbackService {
  // ✅ Doğru rep tamamlandı
  static Future<void> correctRep() async {
    await Vibration.vibrate(duration: 150, amplitude: 128);
  }

  // ❌ Yanlış form
  static Future<void> wrongForm() async {
    await Vibration.vibrate(pattern: [0, 80, 50, 80]); // 2 kısa darbe
  }

  // 🎉 Set tamamlandı
  static Future<void> setComplete() async {
    await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]);
  }
}
```

---

## 6. Matematiksel Analiz

### 6.1 — Temel: 3 Nokta Arasındaki Açı

```dart
// i_exercise_validator.dart
abstract class IExerciseValidator {
  // Her validator bu yardımcıyı kullanır
  double calculateAngle(
    LandmarkPoint a, // Örn: Omuz
    LandmarkPoint b, // Örn: Dirsek (orta nokta)
    LandmarkPoint c, // Örn: Bilek
  ) {
    final radians = math.atan2(c.y - b.y, c.x - b.x) -
                    math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * (180 / math.pi);
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  ExercisePhase evaluatePhase(List<LandmarkPoint> landmarks);
  List<FormError> validateForm(List<LandmarkPoint> landmarks);
}
```

### 6.2 — Biceps Curl için Açı Referansları

```dart
// biceps_curl_validator.dart
class BicepsCurlValidator implements IExerciseValidator {
  // Biomekaniğe göre kalibre edilmiş değerler
  static const double _startAngleMin = 155.0; // Kol uzatılmış
  static const double _startAngleMax = 180.0;
  static const double _endAngleMin = 30.0;   // Kol bükümlü
  static const double _endAngleMax = 60.0;

  @override
  ExercisePhase evaluatePhase(List<LandmarkPoint> landmarks) {
    final elbowAngle = calculateAngle(
      landmarks[PoseLandmark.leftShoulder],
      landmarks[PoseLandmark.leftElbow],
      landmarks[PoseLandmark.leftWrist],
    );

    if (elbowAngle >= _startAngleMin) return ExercisePhase.start;
    if (elbowAngle <= _endAngleMax) return ExercisePhase.peak;
    return ExercisePhase.transitioning;
  }

  @override
  List<FormError> validateForm(List<LandmarkPoint> landmarks) {
    final errors = <FormError>[];

    // Hata 1: Dirsek çok öne çıkıyor (cheat rep)
    final shoulderX = landmarks[PoseLandmark.leftShoulder].x;
    final elbowX = landmarks[PoseLandmark.leftElbow].x;
    if ((elbowX - shoulderX).abs() > 0.08) {
      errors.add(FormError(
        code: 'ELBOW_DRIFT',
        message: 'Dirseklerini sabit tut!',
        priority: 3,
      ));
    }

    // Hata 2: Gövde sallanıyor (trunk sway)
    final leftShoulder = landmarks[PoseLandmark.leftShoulder];
    final rightShoulder = landmarks[PoseLandmark.rightShoulder];
    final shoulderTilt = (leftShoulder.y - rightShoulder.y).abs();
    if (shoulderTilt > 0.05) {
      errors.add(FormError(
        code: 'TRUNK_SWAY',
        message: 'Sırtını dik tut!',
        priority: 2,
      ));
    }

    return errors;
  }
}
```

### 6.3 — Zaman Serisi Analizi: Gerekli mi?

| Yöntem | Ne Zaman Kullan | Karmaşıklık |
|--------|-----------------|-------------|
| Basit açı eşiği | Başlangıç için yeterli, %95 kullanım senaryosu | ⭐ Düşük |
| Velocity analizi | Çok hızlı/yavaş hareket tespiti için | ⭐⭐ Orta |
| DTW (Dynamic Time Warping) | Farklı hız ve ritimde 2 hareketi karşılaştırmak | ⭐⭐⭐ Yüksek |
| LSTM/CNN | Büyük veri seti varsa, kompleks hareket sınıflandırması | ⭐⭐⭐⭐ Çok Yüksek |

> [!NOTE]
> **Önerim:** Önce basit açı eşiği ile başlayın. Sonra velocity analizi ekleyin (kullanıcı çok hızlı yapıyor mu?). DTW ve ML modellerine ancak yüzlerce kullanıcıdan veri topladıktan sonra geçin.

### 6.4 — Pratik: Velocity Analizi (Tempo Kontrolü)

```dart
class RepVelocityAnalyzer {
  final List<double> _angleHistory = [];
  final List<int> _timestampHistory = [];

  void addFrame(double angle, int timestamp) {
    _angleHistory.add(angle);
    _timestampHistory.add(timestamp);
    if (_angleHistory.length > 10) {
      _angleHistory.removeAt(0);
      _timestampHistory.removeAt(0);
    }
  }

  // Saniyedeki açı değişimi (derece/saniye)
  double get angularVelocity {
    if (_angleHistory.length < 2) return 0;
    final angleDelta = _angleHistory.last - _angleHistory.first;
    final timeDeltaSeconds = 
      (_timestampHistory.last - _timestampHistory.first) / 1000.0;
    return angleDelta.abs() / timeDeltaSeconds;
  }

  RepTempo get tempo {
    if (angularVelocity > 120) return RepTempo.tooFast;
    if (angularVelocity < 20) return RepTempo.toSlow;
    return RepTempo.correct;
  }
}
```

---

## 7. Entegrasyon Yol Haritası

### Faz 1 — Temel Altyapı (1-2 hafta)

```
[ ] pubspec.yaml'a paketleri ekle
[ ] lib/features/ai_fitness/ klasör yapısını oluştur
[ ] LandmarkPoint ve ExercisePhase modellerini yaz
[ ] PoseDetectorService + Platform Channel kurulumu
[ ] LandmarkSmoother'ı implement et
[ ] BicepsCurlValidator ile başla (en basit egzersiz)
[ ] FitnessExerciseScreen iskeletini oluştur
```

### Faz 2 — Feedback ve Kalibrasyon (1 hafta)

```
[ ] FeedbackEngine'i implement et
[ ] Görsel: Iskelet overlay widget
[ ] Görsel: Açı progress bar
[ ] Haptik: vibration paketi entegrasyonu
[ ] Sesli: Pre-recorded uyarı sesleri (Türkçe)
[ ] SquatValidator ekle
[ ] FitnessSessionProvider'ı Provider'a bağla
```

### Faz 3 — Optimizasyon ve Genişleme (1 hafta)

```
[ ] Dart Isolate ile hesaplamayı ana thread'den ayır
[ ] Frame throttling (15 FPS)
[ ] LungeValidator ve PushUpValidator ekle
[ ] FitnessSessionSummary ekranı
[ ] MainNavigationScreen'e "Fitness" tab'ı ekle (opsiyonel)
[ ] Performans profiling (Flutter DevTools)
```

### Pubspec.yaml Eklentileri

```yaml
dependencies:
  # Pose estimation
  google_mlkit_pose_detection: ^0.10.0   # veya MediaPipe Flutter plugin
  
  # Kamera
  camera: ^0.10.5
  
  # Ses
  audioplayers: ^5.2.1   # Zaten kullanıyorsanız ekstra paket gerekmez
  flutter_tts: ^3.8.3    # Opsiyonel: TTS için
  
  # Haptik
  vibration: ^1.8.4
  
  # State management (zaten var)
  provider: ^6.1.1       # Mevcut providers/ yapısıyla uyumlu
```

---

## 8. Kritik Değerlendirme

### ✅ Güçlü Yönler

- **Strategy Pattern**: Her egzersiz izole → kolayca genişletilebilir, test edilebilir
- **State Machine**: Rep fazlarını net tanımlıyor → false positive oranı azalıyor
- **Modül izolasyonu**: Mevcut `breath_flow` koduna dokunmadan entegre edilebilir

### ⚠️ Dikkat Edilmesi Gereken Riskler

| Risk | Önlem |
|------|-------|
| Farklı vücut tiplerinde açı referansları tutmayabilir | Kullanıcıya kalibrasyon aşaması ekleyin (ilk kez açıldığında) |
| Gün ışığı vs iç mekan ışık farkı | Confidence score filtrelemesini sıkı tutun (≥ 0.65) |
| iOS ve Android kamera rotasyonu farkı | Platform Channel'da rotasyon normalizasyonu yapın |
| Pil tüketimi: Sürekli kamera + AI | Egzersiz bitince `PoseDetectorService.stop()` çağrın |
| MediaPipe Flutter plugin olgunluğu | `google_mlkit_pose_detection` şu an daha stabil |

### 🚫 Kaçınılacak Spaghetti Tuzakları

```dart
// ❌ YAPMAYIN — Tüm mantığı tek dosyada toplamak
class FitnessExerciseScreen extends StatefulWidget {
  void _detectPose() { ... }
  double _calculateAngle() { ... }
  void _countRep() { ... }
  void _giveHapticFeedback() { ... }
  // Bu ekran yüzlerce satıra dönüşür!
}

// ✅ YAPIN — Ekran yalnızca UI'ı yönetiyor
class FitnessExerciseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<FitnessSessionProvider>();
    return Scaffold(
      body: Stack([
        CameraPreviewWidget(controller: session.cameraController),
        SkeletonOverlayWidget(landmarks: session.landmarks),
        FeedbackOverlayWidget(feedback: session.currentFeedback),
        RepCounterWidget(count: session.repCount),
      ]),
    );
  }
}
```

---

## Sonuç

Bu rehber, `breath_flow` projenizin mevcut **Provider + modüler servisler** mimarisine tam uyumlu bir AI Fitness modülü tanımlamaktadır.

**Implementasyon sırası önerisi:**
1. `BicepsCurlValidator` → Temel sistemi doğrula
2. `FeedbackEngine` → UX'i kalibrasyon
3. Diğer `Validator`'lar → Kolayca genişlet

Sorularınız varsa her fazın detaylarına girebiliriz. 🚀
