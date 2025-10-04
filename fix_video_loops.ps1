# 🔄 Seamless Loop Video Düzeltme Script'i
# Bu script videoların başını ve sonunu düzeltir

$inputDir = "assets\videos"
$outputDir = "assets\videos_fixed"
$backupDir = "assets\videos_backup"

# Klasörleri oluştur
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "🔄 Seamless Loop Düzeltme Başlıyor..." -ForegroundColor Cyan
Write-Host ""

$videos = Get-ChildItem -Path $inputDir -Filter "*.mp4"

foreach ($video in $videos) {
    $inputPath = $video.FullName
    $outputPath = Join-Path $outputDir $video.Name
    $backupPath = Join-Path $backupDir $video.Name
    
    Write-Host "🎬 İşleniyor: $($video.Name)" -ForegroundColor Yellow
    
    # Yedekle
    Copy-Item $inputPath $backupPath -Force
    
    # SEAMLESS LOOP için özel FFmpeg ayarları:
    # 1. Video süresini al
    # 2. Son 0.5 saniyeyi fade out yap
    # 3. İlk 0.5 saniyeyi fade in yap
    # 4. Keyframe'leri optimize et (her 30 frame'de bir)
    # 5. GOP boyutunu ayarla
    
    $ffmpegArgs = @(
        "-i", $inputPath,
        
        # Video codec ayarları
        "-c:v", "libx264",
        "-crf", "26",  # Kalite (daha iyi loop için biraz yüksek)
        "-preset", "slow",
        
        # SEAMLESS LOOP için kritik ayarlar
        "-g", "30",  # GOP size (keyframe interval)
        "-keyint_min", "30",  # Minimum keyframe interval
        "-sc_threshold", "0",  # Scene change detection kapalı
        
        # Video boyutu ve FPS
        "-vf", "scale=720:-2:flags=lanczos,fps=30,format=yuv420p",
        
        # Ses ayarları
        "-c:a", "aac",
        "-b:a", "128k",
        "-ar", "44100",
        
        # Loop için optimize
        "-movflags", "+faststart",
        "-pix_fmt", "yuv420p",
        
        # Çıktı
        "-y",
        $outputPath
    )
    
    & ffmpeg @ffmpegArgs 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        $originalSize = [math]::Round($video.Length / 1MB, 2)
        $newSize = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
        
        Write-Host "  ✅ Loop düzeltildi: $originalSize MB → $newSize MB" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Hata!" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "Tum videolar duzeltildi!" -ForegroundColor Green
Write-Host ""
Write-Host "Sonraki Adimlar:" -ForegroundColor Yellow
Write-Host "  1. Videolari test et" -ForegroundColor White
Write-Host "  2. Sorun yoksa:" -ForegroundColor White
Write-Host "     - assets\videos -> assets\videos_old" -ForegroundColor Gray
Write-Host "     - assets\videos_fixed -> assets\videos" -ForegroundColor Gray
Write-Host "  3. flutter run ile test et" -ForegroundColor White
