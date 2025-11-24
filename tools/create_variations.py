#!/usr/bin/env python3
"""
Özellik Grafiği Varyasyon Oluşturucu
Farklı renk ve stil varyasyonları oluşturur
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Farklı renk temaları
COLOR_THEMES = {
    'blue_purple': {
        'name': 'Mavi-Mor (Varsayılan)',
        'top': (92, 184, 255),
        'middle': (67, 133, 234),
        'bottom': (138, 43, 226)
    },
    'ocean': {
        'name': 'Okyanus',
        'top': (64, 224, 208),
        'middle': (0, 191, 255),
        'bottom': (25, 25, 112)
    },
    'sunset': {
        'name': 'Gün Batımı',
        'top': (255, 182, 193),
        'middle': (255, 105, 180),
        'bottom': (138, 43, 226)
    },
    'forest': {
        'name': 'Orman',
        'top': (152, 251, 152),
        'middle': (34, 139, 34),
        'bottom': (0, 100, 0)
    },
    'night': {
        'name': 'Gece',
        'top': (72, 61, 139),
        'middle': (25, 25, 112),
        'bottom': (0, 0, 0)
    }
}

def create_variation(theme_name, theme_colors, output_suffix=''):
    """Belirli bir tema ile grafik oluştur"""
    width = 1024
    height = 500
    
    img = Image.new('RGBA', (width, height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient arka plan
    for y in range(height):
        ratio = y / height
        
        if ratio < 0.5:
            local_ratio = ratio * 2
            r = int(theme_colors['top'][0] + (theme_colors['middle'][0] - theme_colors['top'][0]) * local_ratio)
            g = int(theme_colors['top'][1] + (theme_colors['middle'][1] - theme_colors['top'][1]) * local_ratio)
            b = int(theme_colors['top'][2] + (theme_colors['middle'][2] - theme_colors['top'][2]) * local_ratio)
        else:
            local_ratio = (ratio - 0.5) * 2
            r = int(theme_colors['middle'][0] + (theme_colors['bottom'][0] - theme_colors['middle'][0]) * local_ratio)
            g = int(theme_colors['middle'][1] + (theme_colors['bottom'][1] - theme_colors['middle'][1]) * local_ratio)
            b = int(theme_colors['middle'][2] + (theme_colors['bottom'][2] - theme_colors['middle'][2]) * local_ratio)
        
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
        title_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguisb.ttf", 84)
        subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 36)
        feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 22)
        emoji_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguiemj.ttf", 28)
    except:
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
    
    # Ana başlık
    title = "Breath Flow"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = height // 2 - 80
    
    draw.text((title_x + 4, title_y + 4), title, fill=(0, 0, 0, 100), font=title_font)
    draw.text((title_x, title_y), title, fill=(255, 255, 255, 255), font=title_font)
    
    # Alt başlık
    subtitle = "Nefes Al, Rahatla, Huzur Bul"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = height // 2 + 20
    
    draw.text((subtitle_x + 2, subtitle_y + 2), subtitle, fill=(0, 0, 0, 80), font=subtitle_font)
    draw.text((subtitle_x, subtitle_y), subtitle, fill=(255, 255, 255, 240), font=subtitle_font)
    
    # Özellik kartları
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
        
        card_bg = Image.new('RGBA', (card_width, card_height), (255, 255, 255, 25))
        card_draw = ImageDraw.Draw(card_bg)
        card_draw.rectangle([0, 0, card_width - 1, card_height - 1],
                           outline=(255, 255, 255, 80), width=2)
        
        img.paste(card_bg, (card_x, card_y), card_bg)
        
        emoji_bbox = draw.textbbox((0, 0), emoji, font=emoji_font)
        emoji_width = emoji_bbox[2] - emoji_bbox[0]
        emoji_x = card_x + (card_width - emoji_width) // 2
        emoji_y = card_y + 15
        draw.text((emoji_x, emoji_y), emoji, font=emoji_font, embedded_color=True)
        
        text_bbox = draw.textbbox((0, 0), text, font=feature_font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = card_x + (card_width - text_width) // 2
        text_y = card_y + 55
        
        draw.text((text_x + 1, text_y + 1), text, fill=(0, 0, 0, 100), font=feature_font)
        draw.text((text_x, text_y), text, fill=(255, 255, 255, 255), font=feature_font)
    
    # Kaydet
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'play_store_assets', 'variations')
    os.makedirs(output_dir, exist_ok=True)
    
    filename = f'feature_graphic_{theme_name}{output_suffix}.png'
    output_path = os.path.join(output_dir, filename)
    
    img.save(output_path, 'PNG', quality=95)
    
    return output_path, os.path.getsize(output_path)

def main():
    print('🎨 Özellik Grafiği Varyasyonları Oluşturuluyor...')
    print('=' * 70)
    
    results = []
    
    for theme_key, theme_data in COLOR_THEMES.items():
        print(f'\n📌 {theme_data["name"]} teması oluşturuluyor...')
        
        try:
            output_path, file_size = create_variation(theme_key, theme_data)
            results.append({
                'name': theme_data['name'],
                'path': output_path,
                'size': file_size / 1024
            })
            print(f'   ✅ Başarılı! ({file_size / 1024:.2f} KB)')
        except Exception as e:
            print(f'   ❌ Hata: {str(e)}')
    
    print('\n' + '=' * 70)
    print('🎉 Tüm varyasyonlar oluşturuldu!')
    print('\n📊 Özet:')
    
    for result in results:
        print(f'   • {result["name"]}: {result["size"]:.2f} KB')
    
    print(f'\n📁 Varyasyonlar klasörü:')
    print(f'   play_store_assets/variations/')
    
    print('\n💡 İpucu: En beğendiğiniz varyasyonu seçip')
    print('   play_store_assets/feature_graphic.png olarak kopyalayın!')

if __name__ == '__main__':
    main()
