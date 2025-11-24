# 🎨 BreathFlow - Play Store Assets

## 📁 Klasör Yapısı

```
play_store_assets/
├── app_icon/               # 512x512 PNG uygulama simgesi
├── feature_graphic/        # 1024x500 PNG/JPEG özellik grafiği
├── screenshots/
│   ├── phone/             # Telefon ekran görüntüleri (1080x2400)
│   ├── tablet_7inch/      # 7" tablet ekran görüntüleri (opsiyonel)
│   └── tablet_10inch/     # 10" tablet ekran görüntüleri (opsiyonel)
└── video/                 # YouTube video linki
```

## ✅ Gereksinimler Kontrol Listesi

### 1. App Icon (ZORUNLU)
- [ ] Boyut: 512 x 512 piksel
- [ ] Format: PNG (şeffaf arka plan önerilir)
- [ ] Dosya boyutu: < 1 MB
- [ ] Dosya adı: `icon_512x512.png`

### 2. Feature Graphic (ZORUNLU)
- [ ] Boyut: 1024 x 500 piksel
- [ ] Format: PNG veya JPEG
- [ ] Dosya boyutu: < 15 MB
- [ ] Dosya adı: `feature_1024x500.png`

### 3. Telefon Screenshots (ZORUNLU - Minimum 2, Önerilen 4-8)
- [ ] Boyut: 1080 x 2400 piksel (veya 1080 x 1920)
- [ ] Format: PNG veya JPEG
- [ ] Her dosya: < 8 MB
- [ ] Dosya adları: `01_home.png`, `02_breathing.png`, vb.

### 4. Tablet Screenshots (OPSİYONEL)
- [ ] 7": 1200 x 1920 piksel
- [ ] 10": 1600 x 2560 piksel
- [ ] Format: PNG veya JPEG
- [ ] Her dosya: < 8 MB

### 5. Video (OPSİYONEL)
- [ ] YouTube linki
- [ ] Herkese açık veya liste dışı
- [ ] Reklamlar kapalı
- [ ] Yaş kısıtlaması yok

## 🎯 Önerilen Ekran Görüntüleri Sırası

1. **01_home.png** - Ana ekran (Nefes egzersizleri listesi)
2. **02_breathing.png** - Nefes egzersizi animasyonu
3. **03_sounds.png** - Ses dünyası ekranı
4. **04_mix_panel.png** - Mix panel özelliği
5. **05_sleep_tracking.png** - Uyku takibi ve analiz
6. **06_statistics.png** - İstatistikler ve ilerleme
7. **07_premium.png** - Premium özellikler
8. **08_profile.png** - Profil ve ayarlar

## 🛠️ Nasıl Hazırlanır?

### Yöntem 1: Emülatörden Ekran Görüntüsü
```bash
# Android Studio'da emülatör çalıştır
# Pixel 6 Pro - 1440 x 3120 çözünürlük
# Ekran görüntüsü al (emülatör yan panel - kamera ikonu)
```

### Yöntem 2: Gerçek Cihazdan
```bash
# Uygulamayı gerçek cihazda çalıştır
# Ekran görüntüsü al (Güç + Ses Kısma)
# Bilgisayara aktar
```

### Yöntem 3: Online Araçlar
- **Canva**: https://www.canva.com/ (tasarım)
- **Mockuphone**: https://mockuphone.com/ (mockup)
- **Figma**: https://www.figma.com/ (profesyonel)

## 📐 Boyutlandırma Komutları

### ImageMagick ile (Windows):
```powershell
# Yükle: https://imagemagick.org/script/download.php

# Ekran görüntüsünü boyutlandır
magick convert input.png -resize 1080x2400 output.png

# App icon oluştur
magick convert input.png -resize 512x512 icon_512x512.png

# Feature graphic oluştur
magick convert input.png -resize 1024x500 feature_1024x500.png
```

### Online Araçlar:
- **TinyPNG**: https://tinypng.com/ (boyut küçültme)
- **Squoosh**: https://squoosh.app/ (boyutlandırma + optimizasyon)

## 🎨 Tasarım İpuçları

### App Icon:
- Basit ve tanınabilir
- Nefes/meditasyon teması
- Mavi-mor gradient (uygulama renkleri)
- Küçük boyutlarda da net görünmeli

### Feature Graphic:
- Uygulama adı: "BreathFlow"
- Slogan: "Zihinsel Huzur ve Nefesin Gücü"
- Gradient arka plan
- Uygulama ekranı mockup'ı (opsiyonel)

### Screenshots:
- Dark mode kullan (uygulamanız dark mode)
- Gerçek içerik göster
- Tutarlı renk paleti
- Net ve yüksek kaliteli

## 📊 Dosya Boyutları

| Asset Tipi | Maksimum Boyut |
|------------|----------------|
| App Icon | 1 MB |
| Feature Graphic | 15 MB |
| Her Screenshot | 8 MB |

## 🚀 Yükleme Adımları

1. Tüm görselleri hazırla
2. Bu klasöre uygun isimlerde kaydet
3. Play Console'a git: https://play.google.com/console
4. Uygulama → Mağaza varlıkları → Grafik
5. Her görseli ilgili alana yükle
6. Önizleme yap
7. Kaydet ve yayınla

## 📝 Notlar

- Görseller yüklenmeden önce mutlaka önizleme yapın
- Yanıltıcı bilgi içermemeli
- Telif hakkı sorunu olmamalı
- Tutarlı tasarım dili kullanın

## 📞 Destek

Sorularınız için: dxdiag.app@gmail.com

---

**Son Güncelleme**: 9 Kasım 2025
**Durum**: Hazırlanıyor 🚧
