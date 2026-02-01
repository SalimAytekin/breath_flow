# Data Klasörü - Çoklu Dil Desteği

Bu klasör, uygulamanın çoklu dil desteği için veri dosyalarını içerir.

## 📁 Dosya Yapısı

```
lib/data/
├── breathing_exercises_loader.dart  # 🌍 Lokalize egzersiz yükleyici (YENİ)
├── breathing_exercises_tr.dart      # Türkçe nefes egzersizleri (eski - referans)
├── premium_triggers_tr.dart         # Türkçe premium tetikleyiciler
└── README.md                        # Bu dosya
```

## 🌍 Çoklu Dil Desteği

### Mevcut Diller
- ✅ **Türkçe (TR)** - Varsayılan dil
- ✅ **İngilizce (EN)** - Tam destek

### Lokalizasyon Sistemi
Egzersiz verileri artık `easy_localization` paketi ile JSON dosyalarından yükleniyor:
- `assets/translations/tr-TR.json` - Türkçe çeviriler
- `assets/translations/en-US.json` - İngilizce çeviriler

## 📝 Nasıl Kullanılır?

### Nefes Egzersizleri (YENİ - Lokalize)

```dart
import 'package:breathe_flow/data/breathing_exercises_loader.dart';

// Tüm egzersizleri al (otomatik lokalize)
final exercises = BreathingExercisesLoader.getAllExercises();

// Step type text'i al (lokalize)
final stepText = BreathingExercisesLoader.getStepTypeText(BreathingStepType.inhale);

// Kategori adını al (lokalize)
final categoryName = BreathingExercisesLoader.getCategoryName(BreathingCategory.odaklanma);
```

### Model Üzerinden Kullanım

```dart
import 'package:breathe_flow/models/breathing_exercise.dart';

// Model'deki allExercises getter otomatik lokalize veri döndürür
final exercises = BreathingExercise.allExercises;
```

### Premium Trigger'lar

```dart
import 'package:breathe_flow/data/premium_triggers_tr.dart';

// Tüm trigger'ları al
final triggers = PremiumTriggersTR.getPredefinedTriggers();
```

## 🔧 Yeni Dil Ekleme

1. **JSON dosyası oluştur:**
   ```
   assets/translations/de-DE.json
   ```

2. **Egzersiz key'lerini ekle:**
   ```json
   {
     "exercise_box_breathing_name": "Kastenatemung (4-4-4-4)",
     "exercise_box_breathing_desc": "...",
     "inhale": "ein",
     "hold": "halten",
     "exhale": "aus",
     "holdAfterExhale": "warten"
   }
   ```

3. **main.dart'ta dili ekle:**
   ```dart
   supportedLocales: [
     Locale('tr', 'TR'),
     Locale('en', 'US'),
     Locale('de', 'DE'), // Yeni
   ],
   ```

## 📊 İstatistikler

### Nefes Egzersizleri (TR)
- **Toplam Egzersiz:** 12 adet
- **Kategoriler:** 4 (Odaklanma, Sakinleşme, Uyku, Enerji)
- **Toplam String:** ~100+ satır

### Premium Trigger'lar (TR)
- **Toplam Trigger:** 10 adet
- **Trigger Tipleri:** 6 farklı tip
- **Toplam String:** ~50+ satır

## ⚠️ Önemli Notlar

1. **Model dosyaları sadece yapı içerir** - Hardcoded string'ler bu data dosyalarında
2. **Her dil için ayrı dosya** - Kolay yönetim ve bakım
3. **Merkezi dil yönetimi** - Gelecekte `LanguageProvider` ile entegre edilecek

## 🎯 Avantajlar

- ✅ **Organize:** Her dil ayrı dosyada
- ✅ **Bakım Kolay:** String değişiklikleri tek yerden
- ✅ **Ölçeklenebilir:** Yeni dil eklemek çok kolay
- ✅ **Temiz Kod:** Model dosyaları sadece yapı içerir
- ✅ **Performans:** Lazy loading ile sadece gerekli dil yüklenir

## 📅 Tarihçe

- **2024-11-24:** İlk versiyon oluşturuldu (TR)
- **Gelecek:** EN, DE, FR dilleri eklenecek
