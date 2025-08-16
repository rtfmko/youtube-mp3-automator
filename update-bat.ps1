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

