# ==============================================
# Update youtube-mp3.bat from GitHub
# ==============================================
# This script searches for old youtube-mp3.bat files in Downloads,
# replaces them with the latest version from GitHub, restarts the bat,
# removes old C:\yt-dlp folder, and deletes itself after execution.
# ==============================================

$batUrl = "https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/youtube-mp3.bat"
$downloadsDir = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$foundBats = Get-ChildItem -Path $downloadsDir -Filter "youtube-mp3.bat" -Recurse -ErrorAction SilentlyContinue

if ($foundBats.Count -eq 0) { Write-Host "❌ No youtube-mp3.bat found in Downloads."; exit }

# --- Download new bat as binary ---
$tmpBat = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "youtube-mp3.tmp.bat")
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($batUrl, $tmpBat)
$wc.Dispose()
Write-Host "⬇ Download completed: $tmpBat"

foreach ($bat in $foundBats) {
    while (Get-Process | Where-Object { $_.Path -eq $bat.FullName }) { Start-Sleep -Milliseconds 500 }
    Move-Item -Path $tmpBat -Destination $bat.FullName -Force
    Start-Process -FilePath "`"$($bat.FullName)`""
    Write-Host "✅ Bat updated and restarted: $($bat.FullName)"
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
