#!/usr/bin/env python3
"""
Özellik Grafiği Hızlı Özelleştirme Aracı
Bu script ile grafiği kolayca özelleştirebilirsiniz.
"""

# ============================================
# BURADAN ÖZELLEŞTİRİN
# ============================================

# Metinler
TITLE = "Breath Flow"
SUBTITLE = "Nefes Al, Rahatla, Huzur Bul"

# Özellikler (Emoji, Metin)
FEATURES = [
    ("🧘", "Nefes Egzersizleri"),
    ("🎵", "Rahatlatıcı Sesler"),
    ("😴", "Uyku Takibi")
]

# Renk Paleti (RGB formatında)
# Gradient: Üstten alta doğru
COLOR_TOP = (92, 184, 255)      # Açık mavi
COLOR_MIDDLE = (67, 133, 234)   # Koyu mavi
COLOR_BOTTOM = (138, 43, 226)   # Mor

# Font Boyutları
FONT_SIZE_TITLE = 84
FONT_SIZE_SUBTITLE = 36
FONT_SIZE_FEATURE = 22
FONT_SIZE_EMOJI = 28

# Kart Ayarları
CARD_WIDTH = 280
CARD_HEIGHT = 90
CARD_SPACING = 30
CARD_OPACITY = 25  # 0-255 arası

# Gölge Ayarları
SHADOW_OFFSET_TITLE = 4
SHADOW_OFFSET_SUBTITLE = 2
SHADOW_OPACITY = 100  # 0-255 arası

# ============================================
# BURADAN SONRASINI DEĞİŞTİRMEYİN
# ============================================

from PIL import Image, ImageDraw, ImageFont
import os

def create_custom_feature_graphic():
    width = 1024
    height = 500
    
    img = Image.new('RGBA', (width, height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient arka plan
    for y in range(height):
        ratio = y / height
        
        if ratio < 0.5:
            local_ratio = ratio * 2
            r = int(COLOR_TOP[0] + (COLOR_MIDDLE[0] - COLOR_TOP[0]) * local_ratio)
            g = int(COLOR_TOP[1] + (COLOR_MIDDLE[1] - COLOR_TOP[1]) * local_ratio)
            b = int(COLOR_TOP[2] + (COLOR_MIDDLE[2] - COLOR_TOP[2]) * local_ratio)
        else:
            local_ratio = (ratio - 0.5) * 2
            r = int(COLOR_MIDDLE[0] + (COLOR_BOTTOM[0] - COLOR_MIDDLE[0]) * local_ratio)
            g = int(COLOR_MIDDLE[1] + (COLOR_BOTTOM[1] - COLOR_MIDDLE[1]) * local_ratio)
            b = int(COLOR_MIDDLE[2] + (COLOR_BOTTOM[2] - COLOR_MIDDLE[2]) * local_ratio)
        
        draw.line([(0, y), (width, y)], fill=(r, g, b), width=1)
    
    # Nefes dalgaları
    for i in range(6):
        offset = i * 6
        alpha = max(20, 100 - i * 15)
        wave_color = (255, 255, 255, alpha)
        
        draw.arc([40 - offset, 70 - offset, 320 - offset, 190 - offset],
                 start=0, end=180, fill=wave_color, width=2)
        draw.arc([20 - offset, 160 - offset, 340 - offset, 280 - offset],
                 start=0, end=180, fill=wave_color, width=2)
        draw.arc([50 - offset, 240 - offset, 300 - offset, 360 - offset],
                 start=0, end=180, fill=wave_color, width=2)
    
    # Glow circles
    glow_centers = [
        (width - 150, 120, 60, (255, 255, 255, 30)),
        (width - 100, 250, 80, (255, 255, 255, 20)),
        (width - 200, 350, 50, (255, 255, 255, 25)),
    ]
    
    for cx, cy, radius, color in glow_centers:
        for i in range(3):
            r = radius + i * 20
            alpha = color[3] - i * 8
            draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                        outline=(*color[:3], alpha), width=2)
    
    # Font yükleme
    try:
        title_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguisb.ttf", FONT_SIZE_TITLE)
        subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", FONT_SIZE_SUBTITLE)
        feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", FONT_SIZE_FEATURE)
        emoji_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguiemj.ttf", FONT_SIZE_EMOJI)
    except:
        try:
            title_font = ImageFont.truetype("C:\\Windows\\Fonts\\arialbd.ttf", FONT_SIZE_TITLE)
            subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", FONT_SIZE_SUBTITLE)
            feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", FONT_SIZE_FEATURE)
            emoji_font = feature_font
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            feature_font = ImageFont.load_default()
            emoji_font = ImageFont.load_default()
    
    # Ana başlık
    title_bbox = draw.textbbox((0, 0), TITLE, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = height // 2 - 80
    
    draw.text((title_x + SHADOW_OFFSET_TITLE, title_y + SHADOW_OFFSET_TITLE), 
              TITLE, fill=(0, 0, 0, SHADOW_OPACITY), font=title_font)
    draw.text((title_x, title_y), TITLE, fill=(255, 255, 255, 255), font=title_font)
    
    # Alt başlık
    subtitle_bbox = draw.textbbox((0, 0), SUBTITLE, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = height // 2 + 20
    
    draw.text((subtitle_x + SHADOW_OFFSET_SUBTITLE, subtitle_y + SHADOW_OFFSET_SUBTITLE), 
              SUBTITLE, fill=(0, 0, 0, int(SHADOW_OPACITY * 0.8)), font=subtitle_font)
    draw.text((subtitle_x, subtitle_y), SUBTITLE, 
              fill=(255, 255, 255, 240), font=subtitle_font)
    
    # Özellik kartları
    total_width = len(FEATURES) * CARD_WIDTH + (len(FEATURES) - 1) * CARD_SPACING
    start_x = (width - total_width) // 2
    start_y = height - 130
    
    for i, (emoji, text) in enumerate(FEATURES):
        card_x = start_x + i * (CARD_WIDTH + CARD_SPACING)
        card_y = start_y
        
        card_bg = Image.new('RGBA', (CARD_WIDTH, CARD_HEIGHT), (255, 255, 255, CARD_OPACITY))
        card_draw = ImageDraw.Draw(card_bg)
        card_draw.rectangle([0, 0, CARD_WIDTH - 1, CARD_HEIGHT - 1],
                           outline=(255, 255, 255, 80), width=2)
        
        img.paste(card_bg, (card_x, card_y), card_bg)
        
        # Emoji
        emoji_bbox = draw.textbbox((0, 0), emoji, font=emoji_font)
        emoji_width = emoji_bbox[2] - emoji_bbox[0]
        emoji_x = card_x + (CARD_WIDTH - emoji_width) // 2
        emoji_y = card_y + 15
        draw.text((emoji_x, emoji_y), emoji, font=emoji_font, embedded_color=True)
        
        # Metin
        text_bbox = draw.textbbox((0, 0), text, font=feature_font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = card_x + (CARD_WIDTH - text_width) // 2
        text_y = card_y + 55
        
        draw.text((text_x + 1, text_y + 1), text, 
                  fill=(0, 0, 0, 100), font=feature_font)
        draw.text((text_x, text_y), text, 
                  fill=(255, 255, 255, 255), font=feature_font)
    
    # Kaydet
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'play_store_assets')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'feature_graphic.png')
    
    img.save(output_path, 'PNG', quality=95)
    
    print(f'✅ Özelleştirilmiş grafik oluşturuldu!')
    print(f'📁 Konum: {output_path}')
    print(f'📏 Boyut: {width}x{height} piksel')
    print(f'📦 Dosya boyutu: {os.path.getsize(output_path) / 1024:.2f} KB')
    print(f'\n🎨 Kullanılan Ayarlar:')
    print(f'   - Başlık: "{TITLE}"')
    print(f'   - Alt başlık: "{SUBTITLE}"')
    print(f'   - Özellik sayısı: {len(FEATURES)}')
    print(f'   - Renk paleti: RGB{COLOR_TOP} → RGB{COLOR_MIDDLE} → RGB{COLOR_BOTTOM}')

if __name__ == '__main__':
    print('🎨 Özelleştirilmiş özellik grafiği oluşturuluyor...')
    print('=' * 60)
    create_custom_feature_graphic()
    print('=' * 60)
    print('🎉 İşlem tamamlandı!')
    print('\n💡 İpucu: Ayarları değiştirmek için bu dosyanın')
    print('   başındaki değişkenleri düzenleyin.')
