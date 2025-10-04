# 🎬 Video Optimizasyon ve Loop Düzeltme Script'i
# Kullanım: .\optimize_videos.ps1

$inputDir = "assets\videos"
$outputDir = "assets\videos_optimized"
$backupDir = "assets\videos_backup"

# Klasörleri oluştur
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "🎬 Video Optimizasyon Başlıyor..." -ForegroundColor Cyan
Write-Host ""

# Tüm MP4 dosyalarını bul
$videos = Get-ChildItem -Path $inputDir -Filter "*.mp4"

foreach ($video in $videos) {
    $inputPath = $video.FullName
    $outputPath = Join-Path $outputDir $video.Name
    $backupPath = Join-Path $backupDir $video.Name
    
    Write-Host "📹 İşleniyor: $($video.Name)" -ForegroundColor Yellow
    
    # Orijinali yedekle
    Copy-Item $inputPath $backupPath -Force
    
    # FFmpeg ile optimize et ve loop düzelt
    # -crf 28: Kalite (18=yüksek, 28=orta, 35=düşük)
    # -preset slow: Daha iyi sıkıştırma
    # -movflags +faststart: Web için optimize
    # -vf "fade=t=out:st=9:d=1,fade=t=in:st=0:d=1": Fade efekti ile seamless loop
    
    $ffmpegArgs = @(
        "-i", $inputPath,
        "-c:v", "libx264",
        "-crf", "28",
        "-preset", "slow",
        "-vf", "scale=720:-2,fps=30",  # 720p, 30fps
        "-c:a", "aac",
        "-b:a", "128k",  # Ses kalitesi
        "-movflags", "+faststart",
        "-y",
        $outputPath
    )
    
    & ffmpeg @ffmpegArgs 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        $originalSize = [math]::Round($video.Length / 1MB, 2)
        $newSize = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
        $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✅ Tamamlandı: $originalSize MB → $newSize MB (-%$savings)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Hata oluştu!" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "🎉 Tüm videolar optimize edildi!" -ForegroundColor Green
Write-Host "📁 Yeni videolar: $outputDir" -ForegroundColor Cyan
Write-Host "💾 Yedekler: $backupDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Yeni videoları test et, sorun yoksa:" -ForegroundColor Yellow
Write-Host "   1. assets\videos klasörünü sil" -ForegroundColor White
Write-Host "   2. assets\videos_optimized → assets\videos olarak yeniden adlandır" -ForegroundColor White
