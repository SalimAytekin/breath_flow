# 📋 Play Store Grafik Gereksinimleri - Özet

## ✅ Hazırlanan Kaynaklar

### 📁 Klasör Yapısı
```
play_store_assets/
├── app_icon/              ← 512x512 app icon buraya
├── feature_graphic/       ← 1024x500 feature graphic buraya
├── screenshots/
│   ├── phone/            ← 1080x2400 telefon ekran görüntüleri
│   ├── tablet_7inch/     ← 1200x1920 tablet ekran görüntüleri (opsiyonel)
│   └── tablet_10inch/    ← 1600x2560 tablet ekran görüntüleri (opsiyonel)
└── video/                ← YouTube video linki (opsiyonel)
```

### 📚 Rehber Dosyaları
1. **HIZLI_BASLANGIC.md** ⭐ BURADAN BAŞLA
   - 30 dakikada hazırlama rehberi
   - Adım adım talimatlar
   - En hızlı yöntemler

2. **PLAY_STORE_GRAFIK_REHBERI.md**
   - Kapsamlı detaylı rehber
   - Tüm gereksinimler
   - Araçlar ve kaynaklar

3. **CANVA_TEMPLATE_REHBERI.md**
   - Canva ile tasarım rehberi
   - Template önerileri
   - Hızlı başlangıç şablonları

4. **screenshots/phone/SCREENSHOT_CHECKLIST.md**
   - Ekran görüntüsü checklist
   - Hangi ekranlar alınmalı
   - Tasarım ipuçları

### 🔧 Araçlar
- **resize_screenshots.ps1** - PowerShell scripti (otomatik boyutlandırma)

---

## 🎯 Gerekli Minimum Görseller

### 1. App Icon (ZORUNLU)
- **Boyut**: 512 x 512 piksel
- **Format**: PNG (şeffaf arka plan önerilir)
- **Maksimum**: 1 MB
- **Konum**: `app_icon/icon_512x512.png`

### 2. Feature Graphic (ZORUNLU)
- **Boyut**: 1024 x 500 piksel
- **Format**: PNG veya JPEG
- **Maksimum**: 15 MB
- **Konum**: `feature_graphic/feature_1024x500.png`

### 3. Telefon Ekran Görüntüleri (ZORUNLU)
- **Adet**: Minimum 2, Önerilen 4-8
- **Boyut**: 1080 x 2400 piksel (veya 1080 x 1920)
- **Format**: PNG veya JPEG
- **Maksimum**: Her biri 8 MB
- **Konum**: `screenshots/phone/01_home.png`, `02_breathing.png`, vb.

### 4. Tablet Ekran Görüntüleri (OPSİYONEL)
- **7 inç**: 1200 x 1920 piksel
- **10 inç**: 1600 x 2560 piksel
- **Konum**: `screenshots/tablet_7inch/` ve `screenshots/tablet_10inch/`

### 5. Video (OPSİYONEL)
- **Platform**: YouTube
- **Gizlilik**: Herkese açık veya liste dışı
- **Özellikler**: Reklamlar kapalı, yaş kısıtlaması yok

---

## 🚀 Hızlı Başlangıç (30 Dakika)

### Adım 1: App Icon (10 dk)
```
1. https://www.canva.com/ → Giriş yap
2. Özel boyut: 512 x 512 piksel
3. Tasarım: Nefes temalı ikon + gradient arka plan
4. İndir: PNG, şeffaf arka plan
5. Kaydet: app_icon/icon_512x512.png
```

### Adım 2: Feature Graphic (10 dk)
```
1. Canva → Özel boyut: 1024 x 500 piksel
2. Tasarım: "BreathFlow" + slogan + gradient
3. İndir: PNG
4. Kaydet: feature_graphic/feature_1024x500.png
```

### Adım 3: Ekran Görüntüleri (10 dk)
```
1. Emülatörü başlat (Pixel 6 Pro)
2. Uygulamayı çalıştır
3. 4 ekran görüntüsü al:
   - Ana ekran
   - Nefes egzersizi
   - Ses dünyası
   - Uyku takibi
4. Kaydet: screenshots/phone/01_home.png, vb.
```

---

## 🛠️ Önerilen Araçlar

### Tasarım:
- **Canva** (en kolay): https://www.canva.com/
- **Figma** (profesyonel): https://www.figma.com/
- **Photopea** (online Photoshop): https://www.photopea.com/

### Mockup:
- **Mockuphone**: https://mockuphone.com/
- **Shots**: https://shots.so/
- **Smartmockups**: https://smartmockups.com/

### Boyutlandırma:
- **TinyPNG**: https://tinypng.com/
- **Squoosh**: https://squoosh.app/
- **ILoveIMG**: https://www.iloveimg.com/resize-image

### İkonlar:
- **Flaticon**: https://www.flaticon.com/
- **Icons8**: https://icons8.com/
- **Noun Project**: https://thenounproject.com/

---

## 📝 Checklist

### Yüklemeden Önce Kontrol Et:

#### App Icon:
- [ ] 512 x 512 piksel
- [ ] PNG formatı
- [ ] < 1 MB
- [ ] Net ve tanınabilir
- [ ] Küçük boyutta test edildi

#### Feature Graphic:
- [ ] 1024 x 500 piksel
- [ ] PNG veya JPEG
- [ ] < 15 MB
- [ ] Metin okunabilir
- [ ] Marka kimliği tutarlı

#### Ekran Görüntüleri:
- [ ] Minimum 4 adet
- [ ] 1080 x 2400 piksel
- [ ] Her biri < 8 MB
- [ ] Gerçek içerik
- [ ] Tutarlı tasarım
- [ ] Dark mode kullanılmış

---

## 📤 Play Console'a Yükleme

### Adımlar:
1. https://play.google.com/console → Giriş yap
2. Uygulamanı seç
3. Mağaza varlıkları → Ana mağaza girişi → Grafik
4. Görselleri yükle:
   - App Icon → `icon_512x512.png`
   - Feature Graphic → `feature_1024x500.png`
   - Telefon Ekran Görüntüleri → 4-8 adet
5. Önizleme yap
6. Kaydet ve yayınla

---

## 💡 İpuçları

### Zaman Kazanma:
✅ Canva template'leri kullan
✅ Emoji kullan (🌬️ hızlı icon için)
✅ Mockup'sız başla (sonra ekle)
✅ 4 ekran görüntüsü yeterli (ilk versiyonda)

### Kalite Artırma:
✅ Yüksek çözünürlük kullan
✅ Gerçek içerik göster
✅ Tutarlı renk paleti
✅ Dark mode kullan
✅ Önemli özellikleri vurgula

### Yapma:
❌ Düşük kaliteli görseller
❌ Test verileri gösterme
❌ Kişisel bilgiler
❌ Yanıltıcı özellikler
❌ Telif hakkı ihlali

---

## 🎨 BreathFlow Tasarım Rehberi

### Renk Paleti:
```
Ana Mavi: #4A90E2
Mor: #9B59B6
Koyu: #1a1a2e
Beyaz: #FFFFFF
Gri: #E0E0E0
```

### Tipografi:
```
Başlık: 48-60pt, Bold
Alt başlık: 24-32pt, Regular
Gövde: 16-18pt, Regular
```

### İkon Teması:
```
🌬️ Nefes
🫁 Akciğer
🌊 Dalga
🧘 Meditasyon
😴 Uyku
```

---

## 📞 Destek

### Sorularınız için:
- **Email**: dxdiag.app@gmail.com

### Yararlı Linkler:
- **Play Console**: https://play.google.com/console
- **Canva**: https://www.canva.com/
- **Mockuphone**: https://mockuphone.com/

---

## 🎯 Sonraki Adımlar

1. ✅ `HIZLI_BASLANGIC.md` dosyasını oku
2. ✅ Görselleri hazırla (30 dakika)
3. ✅ Kalite kontrolü yap
4. ✅ Play Console'a yükle
5. ✅ Önizleme yap
6. ✅ Yayınla!

---

**Başarılar! 🚀**

**Son Güncelleme**: 9 Kasım 2025
