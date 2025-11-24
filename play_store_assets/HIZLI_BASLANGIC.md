# 🚀 Play Store Grafikleri - Hızlı Başlangıç

## ⏱️ 30 Dakikada Hazırla!

Bu rehber, Play Store için gerekli minimum görselleri 30 dakikada hazırlamanı sağlar.

---

## 📋 Gerekli Minimum Görseller

1. ✅ **App Icon** (512x512) - ZORUNLU
2. ✅ **Feature Graphic** (1024x500) - ZORUNLU
3. ✅ **4 Telefon Ekran Görüntüsü** (1080x2400) - ZORUNLU

---

## 🎯 Adım Adım Plan

### ⏰ 0-10 Dakika: App Icon

#### Yöntem 1: Canva (Önerilen - En Kolay)
```
1. https://www.canva.com/ → Giriş yap
2. "Özel boyut" → 512 x 512 piksel
3. Tasarım:
   - Arka plan: Gradient (Mavi-Mor)
   - İkon: 🌬️ emoji veya nefes ikonu
   - Metin: "BF" veya "BreathFlow" (opsiyonel)
4. İndir → PNG → Şeffaf arka plan
5. Kaydet: play_store_assets/app_icon/icon_512x512.png
```

**Canva Hızlı Template:**
- Sol menü → "Öğeler" → Arama: "breath" veya "meditation"
- Bir ikon seç
- Arka plan → Gradient → Mavi (#4A90E2) → Mor (#9B59B6)
- İndir

#### Yöntem 2: Mevcut Logo Varsa
```
1. Logonu aç (Photoshop, GIMP, Paint)
2. Boyutlandır: 512 x 512 piksel
3. PNG olarak kaydet
4. Kaydet: play_store_assets/app_icon/icon_512x512.png
```

---

### ⏰ 10-20 Dakika: Feature Graphic

#### Canva ile (Önerilen)
```
1. Canva → "Özel boyut" → 1024 x 500 piksel
2. Tasarım:
   
   ┌────────────────────────────────────────┐
   │  🌬️   BreathFlow                      │
   │       Zihinsel Huzur ve Nefesin Gücü  │
   └────────────────────────────────────────┘
   
3. Arka plan: Gradient (Koyu mavi → Mor)
4. Sol: Emoji 🌬️ veya app icon
5. Orta: Başlık ve slogan
6. İndir → PNG
7. Kaydet: play_store_assets/feature_graphic/feature_1024x500.png
```

**Hızlı Tasarım:**
- Arka plan: Gradient (#1a1a2e → #16213e → #0f3460)
- Başlık: "BreathFlow" (48pt, Bold, Beyaz)
- Alt başlık: "Zihinsel Huzur ve Nefesin Gücü" (24pt, Beyaz)
- Sol: 🌬️ emoji (büyük boyut)

---

### ⏰ 20-30 Dakika: 4 Ekran Görüntüsü

#### Adım 1: Emülatörü Başlat
```bash
# Android Studio'da:
1. Tools → Device Manager
2. Pixel 6 Pro seç (veya oluştur)
3. Başlat
```

#### Adım 2: Uygulamayı Çalıştır
```bash
# Terminal'de:
cd c:\breath\breath_flow
flutter run
```

#### Adım 3: Ekran Görüntülerini Al
```
Emülatör yan panel → Kamera ikonu → Save

Alınacak 4 Ekran:
1. Ana ekran (Nefes egzersizleri listesi)
2. Nefes egzersizi animasyonu (aktif)
3. Ses dünyası ekranı
4. Uyku takibi veya istatistikler
```

#### Adım 4: Kaydet
```
Dosya adları:
- 01_home.png
- 02_breathing.png
- 03_sounds.png
- 04_sleep.png

Konum: play_store_assets/screenshots/phone/
```

---

## ✅ Kontrol Listesi

Yüklemeden önce kontrol et:

- [ ] **App Icon**
  - [ ] 512 x 512 piksel
  - [ ] PNG formatı
  - [ ] < 1 MB
  - [ ] Dosya adı: icon_512x512.png

- [ ] **Feature Graphic**
  - [ ] 1024 x 500 piksel
  - [ ] PNG veya JPEG
  - [ ] < 15 MB
  - [ ] Dosya adı: feature_1024x500.png

- [ ] **Ekran Görüntüleri**
  - [ ] Minimum 4 adet
  - [ ] 1080 x 2400 piksel (veya 1080 x 1920)
  - [ ] PNG veya JPEG
  - [ ] Her biri < 8 MB
  - [ ] Dosya adları: 01_home.png, 02_breathing.png, vb.

---

## 🎨 Alternatif: Online Araçlar (Daha Hızlı)

### App Icon Oluştur (5 Dakika)
```
1. https://www.canva.com/create/app-icons/
2. Template seç
3. Özelleştir (BreathFlow, nefes teması)
4. İndir (512x512)
```

### Feature Graphic Oluştur (5 Dakika)
```
1. https://www.canva.com/
2. "Banner" ara → 1024x500 boyutunda template seç
3. Özelleştir
4. İndir
```

### Ekran Görüntüleri Mockup (10 Dakika)
```
1. Emülatörden 4 ekran görüntüsü al
2. https://mockuphone.com/ → Google Pixel 6 Pro seç
3. Ekran görüntülerini yükle
4. İndir
```

---

## 🔧 Boyutlandırma Gerekirse

### Windows Paint ile:
```
1. Resmi aç
2. Yeniden Boyutlandır → Piksel
3. Boyutları gir (1080 x 2400)
4. Kaydet
```

### Online Araç:
```
https://www.iloveimg.com/resize-image
- Görseli yükle
- Boyut: 1080 x 2400
- İndir
```

### PowerShell Script:
```powershell
cd play_store_assets
.\resize_screenshots.ps1
# Menüden seçim yap
```

---

## 📤 Play Console'a Yükleme

### Adım 1: Play Console'a Git
```
https://play.google.com/console
→ Uygulamanı seç
→ Mağaza varlıkları
→ Ana mağaza girişi
→ Grafik
```

### Adım 2: Görselleri Yükle
```
1. App Icon → icon_512x512.png yükle
2. Feature Graphic → feature_1024x500.png yükle
3. Telefon Ekran Görüntüleri → 4 görseli yükle
4. Kaydet
```

### Adım 3: Önizleme
```
"Önizleme" butonuna tıkla
Görsellerin nasıl göründüğünü kontrol et
```

### Adım 4: Yayınla
```
"Kaydet" → "İncelemeye gönder"
```

---

## 💡 Pro İpuçları

### Zaman Kazanma:
1. **Template Kullan**: Canva'da hazır template'ler var
2. **Emoji Kullan**: Hızlı icon için 🌬️ emoji kullan
3. **Mockup Atla**: İlk versiyonda mockup'sız da olur
4. **4 Ekran Yeter**: Minimum 4 ekran görüntüsü yeterli

### Kalite Artırma:
1. **Yüksek Çözünürlük**: Emülatörde yüksek çözünürlük kullan
2. **Gerçek İçerik**: Test verileri yerine gerçek içerik göster
3. **Dark Mode**: Uygulamanız dark mode, ekran görüntüleri de öyle olsun
4. **Tutarlılık**: Tüm görsellerde aynı renk paletini kullan

---

## 🚨 Sık Yapılan Hatalar

### ❌ Yapma:
- Düşük çözünürlük görseller
- Test verileri gösterme
- Kişisel bilgiler gösterme
- Yanıltıcı özellikler
- Telif hakkı olan görseller

### ✅ Yap:
- Yüksek kaliteli görseller
- Gerçek içerik
- Tutarlı tasarım
- Uygulamanın en iyi özellikleri
- Orijinal görseller

---

## 📞 Yardım Gerekirse

### Canva Yardım:
- https://www.canva.com/help/

### Play Console Yardım:
- https://support.google.com/googleplay/android-developer/

### ImageMagick Yardım:
- https://imagemagick.org/script/command-line-processing.php

### Destek:
- dxdiag.app@gmail.com

---

## 🎉 Başarı Kriterleri

Aşağıdakileri tamamladıysan hazırsın:

- ✅ App icon oluşturuldu (512x512)
- ✅ Feature graphic oluşturuldu (1024x500)
- ✅ 4 ekran görüntüsü alındı (1080x2400)
- ✅ Tüm görseller doğru klasörlerde
- ✅ Dosya boyutları limitlerin altında
- ✅ Kalite kontrolü yapıldı

**Tebrikler! Play Console'a yüklemeye hazırsın! 🚀**

---

## 📚 Ek Kaynaklar

### Detaylı Rehberler:
- `PLAY_STORE_GRAFIK_REHBERI.md` - Kapsamlı rehber
- `CANVA_TEMPLATE_REHBERI.md` - Canva detayları
- `screenshots/phone/SCREENSHOT_CHECKLIST.md` - Ekran görüntüsü detayları

### Araçlar:
- `resize_screenshots.ps1` - Otomatik boyutlandırma scripti

---

**Başarılar! 🎨**
