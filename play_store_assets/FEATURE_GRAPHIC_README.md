# 🎨 Özellik Grafiği (Feature Graphic) Rehberi

## 📋 Genel Bilgiler

Bu dosya, Play Store için otomatik olarak oluşturulan özellik grafiğini açıklar.

### Teknik Özellikler
- **Boyut**: 1024x500 piksel (Play Store standardı)
- **Format**: PNG
- **Maksimum Dosya Boyutu**: 15 MB (mevcut: ~65 KB)
- **Renk Profili**: RGB
- **Şeffaflık**: Destekleniyor (RGBA)

## 🎨 Tasarım Özellikleri

### Renk Paleti
Grafik, uygulama icon'unuzdaki renk paletini kullanır:
- **Açık Mavi**: `#5CB8FF` (RGB: 92, 184, 255)
- **Koyu Mavi**: `#4385EA` (RGB: 67, 133, 234)
- **Mor**: `#8A2BE2` (RGB: 138, 43, 226)

### Gradient Sistemi
- Üstten alta doğru yumuşak geçiş
- Açık mavi → Koyu mavi → Mor

### Dekoratif Elementler
1. **Sol Taraf - Nefes Dalgaları**
   - 3 dalga katmanı
   - Her dalga 6 çizgiden oluşur
   - Beyaz renk, yarı saydam (alpha: 20-100)

2. **Sağ Taraf - Parlama Efekti**
   - 3 adet glow circle
   - Farklı boyutlarda (50-80px radius)
   - Beyaz renk, çok hafif saydam

### Tipografi
- **Ana Başlık**: Segoe UI Semibold, 84px
  - Metin: "Breath Flow"
  - Renk: Beyaz (#FFFFFF)
  - Gölge: Siyah, 4px offset

- **Alt Başlık**: Segoe UI, 36px
  - Metin: "Nefes Al, Rahatla, Huzur Bul"
  - Renk: Beyaz, %94 opacity
  - Gölge: Siyah, 2px offset

- **Özellik Kartları**: Segoe UI, 22px
  - 3 kart: Nefes Egzersizleri, Rahatlatıcı Sesler, Uyku Takibi
  - Emoji: 28px
  - Kart boyutu: 280x90px
  - Arka plan: Beyaz, %10 opacity
  - Kenarlık: Beyaz, %31 opacity

## 🔧 Grafiği Yeniden Oluşturma

### Gereksinimler
```bash
pip install Pillow
```

### Çalıştırma
```bash
python tools/generate_feature_graphic.py
```

### Çıktı
Grafik şu konuma kaydedilir:
```
play_store_assets/feature_graphic.png
```

## ✏️ Özelleştirme

### Metinleri Değiştirme

`tools/generate_feature_graphic.py` dosyasını açın:

```python
# Ana başlık (satır ~112)
title = "Breath Flow"

# Alt başlık (satır ~127)
subtitle = "Nefes Al, Rahatla, Huzur Bul"

# Özellikler (satır ~140)
features = [
    ("🧘", "Nefes Egzersizleri"),
    ("🎵", "Rahatlatıcı Sesler"),
    ("😴", "Uyku Takibi")
]
```

### Renkleri Değiştirme

```python
# Gradient renkleri (satır ~20-35)
# Üst yarı
r = int(92 + (67 - 92) * local_ratio)
g = int(184 + (133 - 184) * local_ratio)
b = int(255 + (234 - 255) * local_ratio)

# Alt yarı
r = int(67 + (138 - 67) * local_ratio)
g = int(133 + (43 - 133) * local_ratio)
b = int(234 + (226 - 234) * local_ratio)
```

### Font Boyutlarını Değiştirme

```python
# Font boyutları (satır ~94-96)
title_font = ImageFont.truetype("...", 84)      # Ana başlık
subtitle_font = ImageFont.truetype("...", 36)   # Alt başlık
feature_font = ImageFont.truetype("...", 22)    # Özellikler
emoji_font = ImageFont.truetype("...", 28)      # Emoji
```

### Kart Boyutlarını Değiştirme

```python
# Kart boyutları (satır ~146-148)
card_width = 280
card_height = 90
card_spacing = 30
```

## 📱 Play Store'a Yükleme

1. [Google Play Console](https://play.google.com/console)'a giriş yapın
2. Uygulamanızı seçin
3. **Store presence** > **Main store listing** bölümüne gidin
4. **Graphic assets** kısmında **Feature graphic** alanını bulun
5. `feature_graphic.png` dosyasını yükleyin

## 🎯 İpuçları

### Tasarım İpuçları
- ✅ Basit ve okunabilir tutun
- ✅ Uygulama icon'unuzla uyumlu renkler kullanın
- ✅ Çok fazla metin eklemeyin
- ✅ Yüksek kontrast kullanın
- ❌ Çok karmaşık tasarımlardan kaçının
- ❌ Küçük fontlar kullanmayın

### Teknik İpuçları
- Grafiği oluşturduktan sonra farklı cihazlarda test edin
- Play Store'da önizleme yapın
- Dosya boyutunu 1 MB altında tutmaya çalışın
- PNG formatını kullanın (JPEG kalite kaybına neden olur)

## 🔄 Versiyon Geçmişi

### v2.0 (Mevcut)
- Icon renk paletine uyumlu gradient
- Nefes dalgaları eklendi
- Modern glassmorphism kartlar
- Gölge efektleri
- Daha büyük ve okunabilir fontlar

### v1.0 (İlk Versiyon)
- Basit koyu arka plan
- Temel metin düzeni
- Basit daireler

## 📞 Destek

Sorun yaşarsanız veya özelleştirme yardımı isterseniz:
1. `tools/generate_feature_graphic.py` dosyasını kontrol edin
2. Python ve Pillow kurulu olduğundan emin olun
3. Hata mesajlarını okuyun

## 🎉 Başarılar!

Play Store yayınlama sürecinizde başarılar dileriz! 🚀
