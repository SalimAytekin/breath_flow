# BreathFlow - Play Store Screenshot Boyutlandırma Scripti
# Bu script ekran görüntülerini otomatik olarak Play Store gereksinimlerine göre boyutlandırır

Write-Host "🎨 BreathFlow - Play Store Screenshot Boyutlandırma" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ImageMagick kontrolü
$imageMagickPath = "magick"
try {
    $null = & $imageMagickPath --version 2>&1
    Write-Host "✅ ImageMagick bulundu" -ForegroundColor Green
} catch {
    Write-Host "❌ ImageMagick bulunamadı!" -ForegroundColor Red
    Write-Host ""
    Write-Host "ImageMagick'i yüklemek için:" -ForegroundColor Yellow
    Write-Host "1. https://imagemagick.org/script/download.php adresine git" -ForegroundColor Yellow
    Write-Host "2. Windows Binary Release'i indir" -ForegroundColor Yellow
    Write-Host "3. Yükle ve PATH'e ekle" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternatif: Online araçlar kullanabilirsiniz:" -ForegroundColor Yellow
    Write-Host "- https://www.iloveimg.com/resize-image" -ForegroundColor Yellow
    Write-Host "- https://squoosh.app/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Klasörleri kontrol et
$phoneDir = "screenshots\phone"
$tablet7Dir = "screenshots\tablet_7inch"
$tablet10Dir = "screenshots\tablet_10inch"
$appIconDir = "app_icon"
$featureDir = "feature_graphic"

# Boyutlandırma fonksiyonu
function Resize-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [string]$Size
    )
    
    Write-Host "  📐 Boyutlandırılıyor: $([System.IO.Path]::GetFileName($InputPath)) → $Size" -ForegroundColor Gray
    
    try {
        & $imageMagickPath convert "$InputPath" -resize "$Size" -quality 95 "$OutputPath"
        
        # Dosya boyutunu kontrol et
        $fileSize = (Get-Item $OutputPath).Length / 1MB
        if ($fileSize -gt 8) {
            Write-Host "    ⚠️  Uyarı: Dosya boyutu 8MB'dan büyük ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Yellow
        } else {
            Write-Host "    ✅ Başarılı ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
        }
        return $true
    } catch {
        Write-Host "    ❌ Hata: $_" -ForegroundColor Red
        return $false
    }
}

# Ana menü
Write-Host "Ne yapmak istersiniz?" -ForegroundColor Cyan
Write-Host "1. Telefon ekran görüntülerini boyutlandır (1080x2400)" -ForegroundColor White
Write-Host "2. Tablet 7'' ekran görüntülerini boyutlandır (1200x1920)" -ForegroundColor White
Write-Host "3. Tablet 10'' ekran görüntülerini boyutlandır (1600x2560)" -ForegroundColor White
Write-Host "4. App icon oluştur (512x512)" -ForegroundColor White
Write-Host "5. Feature graphic oluştur (1024x500)" -ForegroundColor White
Write-Host "6. Tümünü yap" -ForegroundColor White
Write-Host "0. Çıkış" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Seçiminiz (0-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "📱 Telefon Ekran Görüntüleri Boyutlandırılıyor..." -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path $phoneDir) {
            $images = Get-ChildItem -Path $phoneDir -Include *.png,*.jpg,*.jpeg -Recurse
            
            if ($images.Count -eq 0) {
                Write-Host "❌ $phoneDir klasöründe görsel bulunamadı!" -ForegroundColor Red
                Write-Host "   Lütfen ekran görüntülerini bu klasöre kopyalayın." -ForegroundColor Yellow
            } else {
                $count = 0
                foreach ($img in $images) {
                    $outputPath = Join-Path $phoneDir "resized_$($img.Name)"
                    if (Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1080x2400") {
                        $count++
                    }
                }
                Write-Host ""
                Write-Host "✅ $count adet görsel başarıyla boyutlandırıldı!" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ $phoneDir klasörü bulunamadı!" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "📱 Tablet 7'' Ekran Görüntüleri Boyutlandırılıyor..." -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path $tablet7Dir) {
            $images = Get-ChildItem -Path $tablet7Dir -Include *.png,*.jpg,*.jpeg -Recurse
            
            if ($images.Count -eq 0) {
                Write-Host "❌ $tablet7Dir klasöründe görsel bulunamadı!" -ForegroundColor Red
            } else {
                $count = 0
                foreach ($img in $images) {
                    $outputPath = Join-Path $tablet7Dir "resized_$($img.Name)"
                    if (Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1200x1920") {
                        $count++
                    }
                }
                Write-Host ""
                Write-Host "✅ $count adet görsel başarıyla boyutlandırıldı!" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ $tablet7Dir klasörü bulunamadı!" -ForegroundColor Red
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "📱 Tablet 10'' Ekran Görüntüleri Boyutlandırılıyor..." -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path $tablet10Dir) {
            $images = Get-ChildItem -Path $tablet10Dir -Include *.png,*.jpg,*.jpeg -Recurse
            
            if ($images.Count -eq 0) {
                Write-Host "❌ $tablet10Dir klasöründe görsel bulunamadı!" -ForegroundColor Red
            } else {
                $count = 0
                foreach ($img in $images) {
                    $outputPath = Join-Path $tablet10Dir "resized_$($img.Name)"
                    if (Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1600x2560") {
                        $count++
                    }
                }
                Write-Host ""
                Write-Host "✅ $count adet görsel başarıyla boyutlandırıldı!" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ $tablet10Dir klasörü bulunamadı!" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "🎨 App Icon Oluşturuluyor..." -ForegroundColor Cyan
        Write-Host ""
        
        $iconSource = Read-Host "Kaynak görsel yolu (örn: C:\path\to\icon.png)"
        
        if (Test-Path $iconSource) {
            $outputPath = Join-Path $appIconDir "icon_512x512.png"
            if (Resize-Image -InputPath $iconSource -OutputPath $outputPath -Size "512x512") {
                Write-Host ""
                Write-Host "✅ App icon başarıyla oluşturuldu: $outputPath" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ Kaynak görsel bulunamadı!" -ForegroundColor Red
        }
    }
    
    "5" {
        Write-Host ""
        Write-Host "🎨 Feature Graphic Oluşturuluyor..." -ForegroundColor Cyan
        Write-Host ""
        
        $featureSource = Read-Host "Kaynak görsel yolu (örn: C:\path\to\feature.png)"
        
        if (Test-Path $featureSource) {
            $outputPath = Join-Path $featureDir "feature_1024x500.png"
            if (Resize-Image -InputPath $featureSource -OutputPath $outputPath -Size "1024x500") {
                Write-Host ""
                Write-Host "✅ Feature graphic başarıyla oluşturuldu: $outputPath" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ Kaynak görsel bulunamadı!" -ForegroundColor Red
        }
    }
    
    "6" {
        Write-Host ""
        Write-Host "🚀 Tüm Görseller İşleniyor..." -ForegroundColor Cyan
        Write-Host ""
        
        # Telefon
        Write-Host "📱 Telefon ekran görüntüleri..." -ForegroundColor Yellow
        if (Test-Path $phoneDir) {
            $images = Get-ChildItem -Path $phoneDir -Include *.png,*.jpg,*.jpeg -Recurse
            foreach ($img in $images) {
                $outputPath = Join-Path $phoneDir "resized_$($img.Name)"
                Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1080x2400" | Out-Null
            }
        }
        
        # Tablet 7"
        Write-Host "📱 Tablet 7'' ekran görüntüleri..." -ForegroundColor Yellow
        if (Test-Path $tablet7Dir) {
            $images = Get-ChildItem -Path $tablet7Dir -Include *.png,*.jpg,*.jpeg -Recurse
            foreach ($img in $images) {
                $outputPath = Join-Path $tablet7Dir "resized_$($img.Name)"
                Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1200x1920" | Out-Null
            }
        }
        
        # Tablet 10"
        Write-Host "📱 Tablet 10'' ekran görüntüleri..." -ForegroundColor Yellow
        if (Test-Path $tablet10Dir) {
            $images = Get-ChildItem -Path $tablet10Dir -Include *.png,*.jpg,*.jpeg -Recurse
            foreach ($img in $images) {
                $outputPath = Join-Path $tablet10Dir "resized_$($img.Name)"
                Resize-Image -InputPath $img.FullName -OutputPath $outputPath -Size "1600x2560" | Out-Null
            }
        }
        
        Write-Host ""
        Write-Host "✅ Tüm görseller işlendi!" -ForegroundColor Green
    }
    
    "0" {
        Write-Host "Çıkılıyor..." -ForegroundColor Gray
        exit 0
    }
    
    default {
        Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "İşlem tamamlandı!" -ForegroundColor Green
Write-Host ""
Write-Host "Sonraki adımlar:" -ForegroundColor Yellow
Write-Host "1. Görselleri kontrol edin" -ForegroundColor White
Write-Host "2. Play Console'a yükleyin" -ForegroundColor White
Write-Host "3. Önizleme yapın" -ForegroundColor White
Write-Host ""
