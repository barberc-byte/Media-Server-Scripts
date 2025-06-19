# Smart HEVC Re-Encoder Script (v7-b – CPU Edition, CRF 26)

$inputFolder  = "F:\Plex Convert\Expedition Unknown"
$outputFolder = "$inputFolder-HEVC-CPU"
$ffmpeg       = "C:\Users\clair\Downloads\ffmpeg\bin\ffmpeg.exe"
$ffprobe      = "C:\Users\clair\Downloads\ffmpeg\bin\ffprobe.exe"

# === CONFIGURABLE SIZE THRESHOLDS (in MB) ===
$skipThreshold1080pMB = 650
$skipThreshold720pMB  = 350
$skipThreshold1080p   = $skipThreshold1080pMB * 1MB
$skipThreshold720p    = $skipThreshold720pMB  * 1MB

# === LOG SET-UP ===
$showName = Split-Path $inputFolder -Leaf
$logDir   = "$HOME\Desktop\HEVC Logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$logFile  = Join-Path $logDir "$showName-CPU-SMART.log"
Add-Content $logFile "`n===== Encoding Session Started: $(Get-Date) ====="

# === GATHER FILES ===
$files  = Get-ChildItem -Path $inputFolder -Recurse -Include *.mp4, *.mkv, *.avi -File
$total  = $files.Count
$index  = 0

foreach ($file in $files) {
    $index++

    $input         = $file.FullName
    $relativePath  = $input.Substring($inputFolder.Length).TrimStart('\')
    $output        = Join-Path $outputFolder $relativePath
    $outputDir     = Split-Path  $output
    $originalSize  = $file.Length

    Write-Progress -Activity "Encoding $showName (CPU)" -Status "${index} of ${total}: $($file.Name)" -PercentComplete (($index / $total) * 100)

    # Ensure output directory exists
    if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

    # === STREAM INFO ===
    $codec = (& $ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "`"$input`"").Trim()
    $bit   = (& $ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate  -of default=nw=1:nk=1 "`"$input`"").Trim()
    $bit   = if ($bit -eq 'N/A' -or $bit -eq '') { 0 } else { [int]$bit }

    $res   = (& $ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "`"$input`"").Trim().Split(',')
    $width = [int]$res[0]; $height = [int]$res[1]

    # === SKIP RULES ===
    if ($codec -eq 'hevc') { Add-Content $logFile "[SKIP] [$index/$total] Already HEVC: $relativePath"; continue }
    if ($codec -eq 'h264' -and $bit -lt 2500000 -and $bit -ne 0) { Add-Content $logFile "[SKIP] [$index/$total] Efficient H264 <$bit bps: $relativePath"; continue }
    if ($width -ge 1920 -and $originalSize -lt $skipThreshold1080p) { Add-Content $logFile "[SKIP] [$index/$total] Small 1080p (<$skipThreshold1080pMB MB): $relativePath"; continue }
    if ($width -ge 1280 -and $originalSize -lt $skipThreshold720p)  { Add-Content $logFile "[SKIP] [$index/$total] Small 720p  (<$skipThreshold720pMB MB): $relativePath"; continue }

    # === ENCODE (CPU – libx265 CRF 26) ===
    Add-Content $logFile "[ENCODE] [$index/$total] CRF 26 : $relativePath"
    & $ffmpeg -hide_banner -loglevel warning -i "`"$input`"" -c:v libx265 -preset medium -crf 26 -c:a aac -b:a 160k -movflags +faststart "`"$output`"" 2>> $logFile

    if (Test-Path $output) {
        $newSize = (Get-Item $output).Length
        Add-Content $logFile "[SIZE] [$index/$total] Before: $([math]::Round($originalSize / 1MB, 2)) MB -> After: $([math]::Round($newSize / 1MB, 2)) MB"
    } else {
        Add-Content $logFile "[ERROR] [$index/$total] Output failed: $relativePath"
    }
}

Add-Content $logFile "`n===== Encoding session complete at $(Get-Date) ====="
Write-Host "`n✅ All CPU encodes finished. Log saved to: $logFile"
