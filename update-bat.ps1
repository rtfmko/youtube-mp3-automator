# ==============================================
# Update youtube-mp3.bat from GitHub
# ==============================================
# This script searches for old youtube-mp3.bat files in Downloads,
# replaces them with the latest version from GitHub, restarts the bat,
# removes old C:\yt-dlp folder, and deletes itself after execution.
# ==============================================

# --- Get the Downloads folder ---
try {
    $downloadsDir = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
} catch {
    Write-Host "⚠ Failed to get Downloads folder" -ForegroundColor Red
    exit
}

Write-Host "📂 Scanning Downloads folder: $downloadsDir"

# --- Bat file URL ---
$batUrl = "https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/refs/heads/main/youtube-mp3.bat"

# --- Find all youtube-mp3.bat files in Downloads recursively ---
$foundBats = Get-ChildItem -Path $downloadsDir -Filter "youtube-mp3.bat" -Recurse -ErrorAction SilentlyContinue

if ($foundBats.Count -eq 0) {
    Write-Host "❌ No youtube-mp3.bat found in Downloads." -ForegroundColor Red
    exit
}

foreach ($bat in $foundBats) {
    Write-Host "⚡ Found bat: $($bat.FullName)"

    $tmpBat = "$($bat.DirectoryName)\youtube-mp3.tmp.bat"

    try {
        # --- Download new bat with progress ---
        Write-Host "⬇ Downloading new bat..."
        Invoke-WebRequest -Uri $batUrl -OutFile $tmpBat -UseBasicParsing -ErrorAction Stop -Verbose
        Write-Host "✅ Download completed: $tmpBat" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Failed to download new bat: $_" -ForegroundColor Red
        continue
    }

    # --- Wait until the old bat is not running ---
    while (Get-Process | Where-Object { $_.Path -eq $bat.FullName }) {
        Start-Sleep -Milliseconds 500
    }

    try {
        # --- Replace old bat with new ---
        Move-Item -Path $tmpBat -Destination $bat.FullName -Force
        Write-Host "✅ Bat updated: $($bat.FullName)" -ForegroundColor Green

        # --- Restart bat ---
        Start-Process -FilePath $bat.FullName
        Write-Host "🚀 Bat restarted: $($bat.FullName)" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠ Failed to replace or restart bat: $_" -ForegroundColor Red
    }
}

# ==============================================
# Cleanup
# ==============================================

# --- Remove old C:\yt-dlp folder ---
try {
    if (Test-Path "C:\yt-dlp") {
        Remove-Item -Path "C:\yt-dlp" -Recurse -Force
        Write-Host "🗑️  Old folder C:\yt-dlp removed." -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠ Failed to remove C:\yt-dlp: $_" -ForegroundColor Red
}

# --- Remove this update script itself ---
try {
    $selfPath = $MyInvocation.MyCommand.Path
    Remove-Item -Path $selfPath -Force
    Write-Host "🧹 Update script removed: $selfPath" -ForegroundColor Gray
} catch {
    Write-Host "⚠ Failed to remove update-bat.ps1: $_" -ForegroundColor Red
}
