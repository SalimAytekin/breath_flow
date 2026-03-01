#!/usr/bin/env python3
"""
Premium 3D Mockup Feature Graphic Generator
Telefon mockup, dinamik efektler ve profesyonel tasarım
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import math

def create_premium_feature_graphic():
    width = 1024
    height = 500
    
    # Ana canvas
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # ============================================
    # 1. NIGHT GRADIENT BACKGROUND - Koyu Mor Lacivert
    # ============================================
    for y in range(height):
        ratio = y / height
        
        # Night gradient - koyu lacivert, mor, derin mor
        if ratio < 0.4:
            local_ratio = ratio / 0.4
            r = int(25 + (75 - 25) * local_ratio)
            g = int(25 + (0 - 25) * local_ratio)
            b = int(112 + (130 - 112) * local_ratio)
        elif ratio < 0.7:
            local_ratio = (ratio - 0.4) / 0.3
            r = int(75 + (88 - 75) * local_ratio)
            g = int(0 + (24 - 0) * local_ratio)
            b = int(130 + (150 - 130) * local_ratio)
        else:
            local_ratio = (ratio - 0.7) / 0.3
            r = int(88 + (72 - 88) * local_ratio)
            g = int(24 + (61 - 24) * local_ratio)
            b = int(150 + (139 - 150) * local_ratio)
        
        draw.line([(0, y), (width, y)], fill=(r, g, b), width=1)
    
    # ============================================
    # 2. SUBTLE BACKGROUND EFFECTS - Minimal
    # ============================================
    
    # Hafif dekoratif elementler - sağ alt köşe
    for i in range(3):
        alpha = 30 - i * 8
        radius = 100 + i * 40
        cx, cy = width - 120, height - 100
        draw.ellipse(
            [cx - radius, cy - radius, cx + radius, cy + radius],
            outline=(255, 255, 255, alpha),
            width=2
        )
    
    # Glow particles kaldırıldı - daha temiz görünüm
    
    # ============================================
    # 6. LOAD FONTS
    # ============================================
    
    try:
        title_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguisb.ttf", 88)
        subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 32)
        feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguisb.ttf", 20)
        stats_font = ImageFont.truetype("C:\\Windows\\Fonts\\segoeui.ttf", 18)
        emoji_font = ImageFont.truetype("C:\\Windows\\Fonts\\seguiemj.ttf", 26)
    except:
        try:
            title_font = ImageFont.truetype("C:\\Windows\\Fonts\\arialbd.ttf", 88)
            subtitle_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 32)
            feature_font = ImageFont.truetype("C:\\Windows\\Fonts\\arialbd.ttf", 20)
            stats_font = ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 18)
            emoji_font = feature_font
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            feature_font = ImageFont.load_default()
            stats_font = ImageFont.load_default()
            emoji_font = ImageFont.load_default()
    
    # ============================================
    # 7. MAIN TITLE - Sol üst köşe
    # ============================================
    
    title = "Breath Flow"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = 60  # Sol tarafa
    title_y = 80
    
    # Gölge efekti
    draw.text((title_x + 4, title_y + 4), title, 
              fill=(0, 0, 0, 100), font=title_font)
    
    # Ana başlık
    draw.text((title_x, title_y), title, fill=(255, 255, 255, 255), font=title_font)
    
    # ============================================
    # 8. SUBTITLE
    # ============================================
    
    subtitle = "Nefes Al, Rahatla, Huzur Bul"
    subtitle_x = title_x
    subtitle_y = title_y + 100
    
    draw.text((subtitle_x + 2, subtitle_y + 2), subtitle, 
              fill=(0, 0, 0, 70), font=subtitle_font)
    draw.text((subtitle_x, subtitle_y), subtitle, 
              fill=(255, 255, 255, 230), font=subtitle_font)
    
    # ============================================
    # 9. FEATURES - Basit liste (kare yok)
    # ============================================
    
    features = [
        ("🧘", "Nefes Egzersizleri"),
        ("🎵", "Rahatlatıcı Sesler"),
        ("😴", "Uyku Takibi")
    ]
    
    features_start_x = title_x
    features_start_y = subtitle_y + 80
    feature_spacing = 60
    
    for i, (emoji, text) in enumerate(features):
        feature_y = features_start_y + i * feature_spacing
        
        # Emoji
        draw.text((features_start_x, feature_y), emoji, 
                  font=emoji_font, embedded_color=True)
        
        # Text - emoji'nin yanında
        text_x = features_start_x + 45
        draw.text((text_x + 1, feature_y + 1), text, 
                  fill=(0, 0, 0, 80), font=feature_font)
        draw.text((text_x, feature_y), text, 
                  fill=(255, 255, 255, 255), font=feature_font)
    
    # ============================================
    # 10. 3D PHONE MOCKUP - Profesyonel çerçeve
    # ============================================
    
    try:
        # Screenshot'u yükle
        screenshot_path = os.path.join(
            os.path.dirname(__file__), 
            '..', 
            'play_store_assets', 
            'screenshots', 
            'phone', 
            '02_breathing_categories.png'
        )
        
        if os.path.exists(screenshot_path):
            phone_screen = Image.open(screenshot_path)
            
            # Screenshot boyutlandırma - daha büyük
            target_height = 420
            phone_width = int(phone_screen.width * (target_height / phone_screen.height))
            phone_screen = phone_screen.resize((phone_width, target_height), Image.Resampling.LANCZOS)
            
            # Telefon konumu - sağ orta
            phone_x = width - phone_width - 100
            phone_y = (height - target_height) // 2
            
            # Screenshot'u doğrudan yapıştır (gölge yok - tamamen temiz)
            img.paste(phone_screen, (phone_x, phone_y), phone_screen)
            
            # İnce parlak çerçeve - sadece vurgu için
            for i in range(2):
                alpha = 100 - i * 40
                draw.rounded_rectangle(
                    [phone_x - 1 - i, phone_y - 1 - i, 
                     phone_x + phone_width + i, phone_y + target_height + i],
                    radius=30,
                    outline=(255, 255, 255, alpha),
                    width=1
                )
            
            print("✅ Profesyonel telefon mockup eklendi!")
        else:
            print("⚠️ Screenshot bulunamadı, mockup olmadan devam ediliyor...")
            
    except Exception as e:
        print(f"⚠️ Mockup eklenirken hata: {e}")
    
    # ============================================
    # 12. FINAL TOUCHES - Genel parlaklık ayarı
    # ============================================
    
    # Hafif parlaklık artırma
    enhancer = ImageEnhance.Brightness(img)
    img = enhancer.enhance(1.05)
    
    # Hafif kontrast artırma
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.1)
    
    # ============================================
    # 13. SAVE
    # ============================================
    
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'play_store_assets')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'feature_graphic_premium.png')
    
    img.save(output_path, 'PNG', quality=95)
    
    print(f'✅ Premium grafik oluşturuldu: {output_path}')
    print(f'📏 Boyut: {width}x{height} piksel')
    print(f'📦 Dosya boyutu: {os.path.getsize(output_path) / 1024:.2f} KB')
    
    return output_path

if __name__ == '__main__':
    print('🎨 Premium 3D Mockup Feature Graphic oluşturuluyor...')
    print('=' * 70)
    print('\n🌟 Özellikler:')
    print('   • Advanced gradient background')
    print('   • Dynamic wave effects')
    print('   • Glow particles')
    print('   • Lens flare')
    print('   • 3D phone mockup')
    print('   • Stats badges')
    print('   • Enhanced shadows')
    print('   • Brightness & contrast optimization')
    print('\n' + '=' * 70)
    
    create_premium_feature_graphic()
    
    print('=' * 70)
    print('🎉 Premium grafik hazır!')
    print('\n💡 İpucu: feature_graphic_premium.png dosyasını kontrol edin.')
    print('   Beğendiyseniz feature_graphic.png olarak kopyalayın!')
