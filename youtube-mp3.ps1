# === Configuration ===
$installDir = Join-Path $env:LOCALAPPDATA "yt-dlp"
$downloadsDir = Join-Path (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path "YouTubeMusic"

# Create music folder if not exist
if (-not (Test-Path $downloadsDir)) {
    New-Item -ItemType Directory -Path $downloadsDir | Out-Null
}

# === Check folder ===
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# === yt-dlp ===
if (-not (Test-Path "$installDir\yt-dlp.exe")) {
    Write-Host "⬇ Downloading yt-dlp..."
    Invoke-WebRequest "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile "$installDir\yt-dlp.exe"
}

# === ffmpeg ===
if (-not (Test-Path "$installDir\ffmpeg.exe")) {
    Write-Host "⬇ Downloading ffmpeg..."
    $ffmpegZip = "$installDir\ffmpeg.zip"
    Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $ffmpegZip
    
    # Unzip to temp folder
    $tempDir = "$installDir\ffmpeg_temp"
    Expand-Archive $ffmpegZip -DestinationPath $tempDir -Force
    
    # Copy ffmpeg.exe to main folder
    $ffmpegExe = Get-ChildItem "$tempDir" -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
    Copy-Item $ffmpegExe.FullName "$installDir\ffmpeg.exe" -Force
    
    # Detele temp files
    Remove-Item $ffmpegZip -Force
    Remove-Item $tempDir -Recurse -Force
}

# === Main cycle ===
Write-Host "🎵 YouTube → MP3 (320 kbps) Downloader"
Write-Host "Enter the link to YouTube (or q / e for exit)"

$cookiesPath = $null  # store path to cookies if specified

while ($true) {
   $inputLine = Read-Host "🎥 Links, ID, or command (-c path/to/cookies.txt)"
    if ([string]::IsNullOrWhiteSpace($inputLine) -or $inputLine -match '^(q|quit|e|exit)$') {
        Write-Host "👋 Exit..."
        break
    }

    # Checking the cookie installation command
    if ($inputLine -match '^-c\s+(.+)$') {
        $newPath = $Matches[1].Trim('"')
        if (Test-Path $newPath) {
            $cookiesPath = $newPath
            Write-Host "🍪 Cookies set: $cookiesPath"
        } else {
            Write-Host "⚠ File not found: $newPath"
        }
        continue
    }

    # Split by spaces, commas, semicolons
    $urls = $inputLine -split '[ ,;]+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($u in $urls) {
        $url = $u.Trim()

        # If only ID is entered (11 characters, without http), add a prefix
        if ($url -match '^[A-Za-z0-9_-]{11}$') {
            $url = "https://www.youtube.com/watch?v=$url"
        }

         Write-Host "⬇ Downloading: $url"

        $cmdArgs = @("-x", "--audio-format", "mp3", "--audio-quality", "320K", "-o", "$downloadsDir\%(title)s.%(ext)s", "$url")
        
        # Add cookies if any
        if ($cookiesPath) {
            $cmdArgs = @("--cookies", $cookiesPath) + $cmdArgs
        }

        & "$installDir\yt-dlp.exe" @cmdArgs
    }

    Write-Host "✅ Done! Files in: $downloadsDir"
}
