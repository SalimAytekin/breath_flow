# 🎵 Ses Dosyaları ve Animasyon Kurulum Rehberi

Bu rehber, BreatheFlow uygulamasına ses dosyalarını ve Lottie animasyonlarını nasıl ekleyeceğinizi gösterir.

## 📁 Ses Dosyaları

Aşağıdaki ses dosyalarını indirip belirtilen konumlara yerleştirin:

### 1. Rain on Tent (Çadırda Yağmur)
- **İndirme Linki**: https://pixabay.com/sound-effects/rain-on-tent-102636/
- **Dosya Adı**: `rain_on_tent.mp3`
- **Konum**: `assets/audio/rain_on_tent.mp3`

### 2. Campfire (Kamp Ateşi)
- **İndirme Linki**: https://pixabay.com/sound-effects/campfire-1-177296/
- **Dosya Adı**: `campfire.mp3`
- **Konum**: `assets/audio/campfire.mp3`

### 3. Ocean Waves (Okyanus Dalgaları)
- **İndirme Linki**: https://pixabay.com/sound-effects/ocean-waves-ambience-17064/
- **Dosya Adı**: `ocean_waves.mp3`
- **Konum**: `assets/audio/ocean_waves.mp3`

### 4. Lo-fi Chill (Lo-fi Müzik)
- **İndirme Linki**: https://pixabay.com/music/lofi-chill-relax-112191/
- **Dosya Adı**: `lofi_chill.mp3`
- **Konum**: `assets/audio/lofi_chill.mp3`

## 🎬 Lottie Animasyonları

Aşağıdaki Lottie animasyonlarını indirip belirtilen konumlara yerleştirin:

### 1. Breathing Circle (Nefes Dairesi)
- **İndirme Linki**: https://lottiefiles.com/120094-breathing-circle
- **Dosya Adı**: `breathing_circle.json`
- **Konum**: `assets/lottie/breathing_circle.json`
- **Kullanım**: Derin nefes egzersizleri için

### 2. Calm Circle (Sakin Daire)
- **İndirme Linki**: https://lottiefiles.com/108435-calm-circle
- **Dosya Adı**: `calm_circle.json`
- **Konum**: `assets/lottie/calm_circle.json`
- **Kullanım**: Kutu nefes egzersizleri için

### 3. Soft Waves (Yumuşak Dalgalar)
- **İndirme Linki**: https://lottiefiles.com/142735-soft-waves
- **Dosya Adı**: `soft_waves.json`
- **Konum**: `assets/lottie/soft_waves.json`
- **Kullanım**: Diğer nefes egzersizleri için

## 📋 Kurulum Adımları

### 1. Ses Dosyalarını İndirin
```bash
# assets/audio klasörü zaten oluşturuldu
# Her ses dosyasını yukarıdaki linklerden indirin
# Dosya adlarını belirtilen şekilde değiştirin
```

### 2. Lottie Animasyonlarını İndirin
```bash
# assets/lottie klasörü zaten oluşturuldu
# Her animasyon dosyasını yukarıdaki linklerden JSON formatında indirin
# Dosya adlarını belirtilen şekilde değiştirin
```

### 3. Dosya Yapısını Kontrol Edin
```
assets/
├── audio/
│   ├── rain_on_tent.mp3
│   ├── campfire.mp3
│   ├── ocean_waves.mp3
│   └── lofi_chill.mp3
└── lottie/
    ├── breathing_circle.json
    ├── calm_circle.json
    └── soft_waves.json
```

### 4. Uygulamayı Yeniden Başlatın
```bash
flutter pub get
flutter run
```

## 🎯 Özellikler

### Ses Çalar Özellikleri:
- ✅ Çoklu ses çalma desteği
- ✅ Ses seviyesi kontrolü
- ✅ Premium ses kategorileri
- ✅ Modern glassmorphism tasarım
- ✅ Animasyonlu play/pause butonları
- ✅ Tüm sesleri durdurma

### Nefes Animasyonu Özellikleri:
- ✅ Lottie animasyon entegrasyonu
- ✅ Nefes adımlarına göre animasyon kontrolü
- ✅ Fallback animasyon desteği
- ✅ Dalga efektleri
- ✅ İlerleme göstergesi

## 🔧 Sorun Giderme

### Ses Çalmıyor?
1. Ses dosyalarının doğru konumda olduğundan emin olun
2. Dosya adlarının tam olarak eşleştiğinden emin olun
3. Dosya formatının MP3 olduğundan emin olun

### Lottie Animasyonu Görünmüyor?
1. JSON dosyalarının doğru konumda olduğundan emin olun
2. Dosya adlarının tam olarak eşleştiğinden emin olun
3. JSON formatının geçerli olduğundan emin olun
4. Fallback animasyon otomatik olarak devreye girecektir

### Performans Sorunları?
- Ses dosyalarının boyutunu kontrol edin (maksimum 5MB önerilir)
- Lottie animasyonlarının karmaşıklığını kontrol edin

## 📝 Notlar

- Tüm ses dosyaları loop (döngü) modunda çalacaktır
- Premium sesler için üyelik kontrolü yapılmaktadır
- Lottie animasyonları nefes adımlarına göre senkronize çalışır
- Ses dosyaları bulunamadığında uygulama hata vermeyecektir

## 🎨 Tasarım

Uygulama modern glassmorphism tasarım ile geliştirilmiştir:
- Gradient arka planlar
- Cam efektli kartlar
- Yumuşak gölgeler
- Feather Icons
- Google Fonts (Inter)
- Smooth animasyonlar

Keyifli kullanımlar! 🎵✨ 