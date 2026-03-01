#!/usr/bin/env python3
"""
Play Store Özellik Grafiği Oluşturucu
1024x500 piksel PNG formatında
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_feature_graphic():
    # Boyutlar
    width = 1024
    height = 500
    
    # Yeni görsel oluştur
    img = Image.new('RGBA', (width, height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Modern gradient arka plan (Icon'daki mavi-mor gradient)
    for y in range(height):
        # Renk geçişi: Açık mavi -> Koyu mavi -> Mor
        ratio = y / height
        
        if ratio < 0.5:
            # Üst yarı: Açık mavi -> Koyu mavi
            local_ratio = ratio * 2
            r = int(92 + (67 - 92) * local_ratio)
            g = int(184 + (133 - 184) * local_ratio)
            b = int(255 + (234 - 255) * local_ratio)
        else:
            # Alt yarı: Koyu mavi -> Mor
            local_ratio = (ratio - 0.5) * 2
            r = int(67 + (138 - 67) * local_ratio)
            g = int(133 + (43 - 133) * local_ratio)
            b = int(234 + (226 - 234) * local_ratio)
        
        color = (r, g, b)
        draw.line([(0, y), (width, y)], fill=color, width=1)
    
    # Dekoratif nefes dalgaları (icon'daki stil) - Daha smooth
    # Sol taraf - Büyük dalga efekti
    
    # Üst dalga - Daha yumuşak
    for i in range(6):
        offset = i * 6
        alpha = 100 - i * 15
        wave_color = (255, 255, 255, max(20, alpha))
        draw.arc(
            [40 - offset, 70 - offset, 320 - offset, 190 - offset],
            start=0, end=180,
            fill=wave_color,
            width=2
        )
    
    # Orta dalga - Daha geniş
    for i in range(6):
        offset = i * 6
        alpha = 100 - i * 15
        wave_color = (255, 255, 255, max(20, alpha))
        draw.arc(
            [20 - offset, 160 - offset, 340 - offset, 280 - offset],
            start=0, end=180,
            fill=wave_color,
            width=2
        )
    
    # Alt dalga - Daha kompakt
    for i in range(6):
        offset = i * 6
        alpha = 100 - i * 15
        wave_color = (255, 255, 255, max(20, alpha))
        draw.arc(
            [50 - offset, 240 - offset, 300 - offset, 360 - offset],
            start=0, end=180,
            fill=wave_color,
            width=2
        )
    
    # Sağ taraf - Parlama efekti (glow circles)
    glow_centers = [
        (width - 150, 120, 60, (255, 255, 255, 30)),
        (width - 100, 250, 80, (255, 255, 255, 20)),
        (width - 200, 350, 50, (255, 255, 255, 25)),
    ]
    
    for cx, cy, radius, color in glow_centers:
        for i in range(3):
            r = radius + i * 20
            alpha = color[3] - i * 8
            draw.ellipse(
                [cx - r, cy - r, cx + r, cy + r],
                outline=(*color[:3], alpha),
                width=2
            )
    
    # Font yükleme (sistem fontları)
    try:
        # Windows için - Daha modern fontlar
        title_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguisb.ttf", 84)  # Segoe UI Semibold
        subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 36)
        feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 22)
        emoji_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguiemj.ttf", 28)  # Emoji font
    except:
        # Fallback
        try:
            title_font = ImageFont.truetype("C:\\Windows\\Fonts\\arialbd.ttf", 84)
            subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 36)
            feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 22)
            emoji_font = feature_font
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            feature_font = ImageFont.load_default()
            emoji_font = ImageFont.load_default()
    
    # Ana başlık - Gölgeli ve parlak
    title = "Breath Flow"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = height // 2 - 80
    
    # Gölge efekti
    shadow_offset = 4
    draw.text((title_x + shadow_offset, title_y + shadow_offset), title, 
              fill=(0, 0, 0, 100), font=title_font)
    
    # Ana başlık
    draw.text((title_x, title_y), title, fill=(255, 255, 255, 255), font=title_font)
    
    # Alt başlık - Daha yumuşak
    subtitle = "Nefes Al, Rahatla, Huzur Bul"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = height // 2 + 20
    
    # Alt başlık gölgesi
    draw.text((subtitle_x + 2, subtitle_y + 2), subtitle, 
              fill=(0, 0, 0, 80), font=subtitle_font)
    draw.text((subtitle_x, subtitle_y), subtitle, 
              fill=(255, 255, 255, 240), font=subtitle_font)
    
    # Özellikler - Modern kartlar halinde
    features = [
        ("🧘", "Nefes Egzersizleri"),
        ("🎵", "Rahatlatıcı Sesler"),
        ("😴", "Uyku Takibi")
    ]
    
    card_width = 280
    card_height = 90
    card_spacing = 30
    total_width = len(features) * card_width + (len(features) - 1) * card_spacing
    start_x = (width - total_width) // 2
    start_y = height - 130
    
    for i, (emoji, text) in enumerate(features):
        card_x = start_x + i * (card_width + card_spacing)
        card_y = start_y
        
        # Kart arka planı - Yarı saydam beyaz
        card_bg = Image.new('RGBA', (card_width, card_height), (255, 255, 255, 25))
        
        # Kart kenarlığı
        card_draw = ImageDraw.Draw(card_bg)
        card_draw.rectangle(
            [0, 0, card_width - 1, card_height - 1],
            outline=(255, 255, 255, 80),
            width=2
        )
        
        # Kartı ana görüntüye yapıştır
        img.paste(card_bg, (card_x, card_y), card_bg)
        
        # Emoji
        emoji_bbox = draw.textbbox((0, 0), emoji, font=emoji_font)
        emoji_width = emoji_bbox[2] - emoji_bbox[0]
        emoji_x = card_x + (card_width - emoji_width) // 2
        emoji_y = card_y + 15
        draw.text((emoji_x, emoji_y), emoji, font=emoji_font, embedded_color=True)
        
        # Metin
        text_bbox = draw.textbbox((0, 0), text, font=feature_font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = card_x + (card_width - text_width) // 2
        text_y = card_y + 55
        
        # Metin gölgesi
        draw.text((text_x + 1, text_y + 1), text, 
                  fill=(0, 0, 0, 100), font=feature_font)
        draw.text((text_x, text_y), text, 
                  fill=(255, 255, 255, 255), font=feature_font)
    
    # Kaydet
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'play_store_assets')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'feature_graphic.png')
    
    img.save(output_path, 'PNG', quality=95)
    print(f'✅ Özellik grafiği oluşturuldu: {output_path}')
    print(f'📏 Boyut: {width}x{height} piksel')
    print(f'📦 Dosya boyutu: {os.path.getsize(output_path) / 1024:.2f} KB')

if __name__ == '__main__':
    print('🎨 Play Store özellik grafiği oluşturuluyor...')
    create_feature_graphic()
    print('🎉 İşlem tamamlandı!')
