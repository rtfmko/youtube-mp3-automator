# === Bat auto-update check ===
$batPath = "$PSScriptRoot\youtube-mp3.bat"
$versionFile = "$PSScriptRoot\version.txt"
$updateScriptUrl = "https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/refs/heads/main/update-bat.ps1"
$tmpUpdateScript = "$PSScriptRoot\update-bat.ps1"

# Если version.txt нет — старый батник
if (-not (Test-Path $versionFile)) {
    Write-Host "⚠ Old bat detected, downloading updater..." -ForegroundColor Yellow

    try {
        Invoke-WebRequest $updateScriptUrl -OutFile $tmpUpdateScript -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "⚠ Failed to download updater, please update manually." -ForegroundColor Red
        exit
    }

    Write-Host "🔄 Starting bat updater and exiting current session..." -ForegroundColor Green

    # Запускаем update-bat.ps1 и закрываем текущий ps1
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tmpUpdateScript`"" -WindowStyle Hidden

    exit
}

# =======================
# Configuration
# =======================
$installDir = Join-Path $env:LOCALAPPDATA "yt-dlp"
$downloadsDir = Join-Path (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path "YouTubeMusic"
$cookiesPath = $null       # Store path to cookies if specified
$maxParallel = 5           # Max parallel count for multi (-m) mode
$optionsFile = Join-Path $installDir "options.txt"

# =======================
# Localization
# =======================
$loc = @{
    "en" = @{
        "commandsHeader" = "`n💡 Commands:"
        "commands" = @(
            "  📥 Enter YouTube links or IDs separated by space, comma, or semicolon",
            "  🍪 -c <path>  → Set cookies file",
            "  ⚡ -s         → Single download mode (one by one)",
            "  ⚡ -m [N]     → Multi download mode (parallel downloads), optional N = 2-12, default 5",
			"  📂 -o         → Open downloads folder"
            "  🧹 clear      → Clear console",
            "  ❌ q, e       → Exit script"
        )
        "promptInput" = "`n🎥 Links, IDs, or command"
        "clearing" = "🧹 Clearing..."
        "fileNotFound" = "⚠ File not found: "
        "modeMultiSet" = "⚡ Mode set to multi download, parallel: "
        "modeSingleSet" = "⚡ Mode set to single download"
        "downloadingStartMulti" = "📥 Downloading start... ({0} tracks, mode: {1}, parallel: {2})"
        "downloadingStartSingle" = "📥 Downloading start... ({0} tracks, mode: {1})"
        "downloadingItem" = "📥 Downloading: {0}"
        "done" = "✅ Done! Files are in: "
        "selectedModeSingle" = "⚡ Selected mode: {0}"
        "selectedModeMulti" = "⚡ Selected mode: {0}, parallel: {1}"
        "failedSaveOptions" = "⚠ Failed to save options file"
        "failedLoadOptions" = "⚠ Failed to read options file, using defaults"
        "downloadFFmpeg" = "⬇ Downloading ffmpeg..."
        "downloadYtDlp" = "⬇ Downloading yt-dlp..."
        "alarmRange" = "⚠ Value must be in range 2 - 12, set to "
        "exiting" = "👋 Exit..."
        "note" = " 💾 Selected download mode and parallel count are saved and automatically applied on next run."
		"cookiesSet" = "🍪 Cookies set:"
		"openFolder" = "📂 Opening downloads folder:"
		"folderNotFound" = "⚠ Folder not found:"
		"cookieUsed" = "🍪 Using cookie: {0}"
		"cookieNotUsed" = "🍪 No cookie used for this session"
    }
    "uk" = @{
        "commandsHeader" = "`n💡 Команди:"
        "commands" = @(
            "  📥 Введіть посилання YouTube або ID, розділені пробілом, комою або крапкою з комою",
            "  🍪 -c <шлях>  → Встановити файл cookie",
            "  ⚡ -s         → Режим одиночного завантаження",
            "  ⚡ -m [N]     → Режим множинного завантаження (паралельні завантаження), необов’язково N = 2-12, за замовчуванням 5",
			"  📂 -o         → Відкрити папку завантажень"
            "  🧹 clear      → Очистити консоль",
            "  ❌ q, e       → Вихід із скрипту"
        )
        "promptInput" = "`n🎥 Посилання, ID або команда"
        "clearing" = "🧹 Очищення..."
        "fileNotFound" = "⚠ Файл не знайдено: "
        "modeMultiSet" = "⚡ Режим множинного завантаження, паралель: "
        "modeSingleSet" = "⚡ Режим одиночного завантаження"
        "downloadingStartMulti" = "📥 Початок завантаження... ({0} треків, режим: {1}, паралель: {2})"
        "downloadingStartSingle" = "📥 Початок завантаження... ({0} треків, режим: {1})"
        "downloadingItem" = "📥 Завантаження: {0}"
        "done" = "✅ Готово! Файли збережено в: "
        "selectedModeSingle" = "⚡ Вибраний режим: {0}"
        "selectedModeMulti" = "⚡ Вибраний режим: {0}, паралель: {1}"
        "failedSaveOptions" = "⚠ Не вдалося зберегти файл налаштувань"
        "failedLoadOptions" = "⚠ Не вдалося прочитати файл налаштувань, використовуються значення за замовчуванням"
        "downloadFFmpeg" = "⬇ Завантаження ffmpeg..."
        "downloadYtDlp" = "⬇ Завантаження yt-dlp..."
        "alarmRange" = "⚠ Значення має бути в діапазоні 2 - 12, встановлено "
        "exiting" = "👋 Вихід..."
        "note" = " 💾 Вибраний режим та кількість паралельних завантажень зберігаються та застосовуються автоматично при наступному запуску."
		"cookiesSet" = "🍪 Файл cookie встановлено:"
		"openFolder" = "📂 Відкриття папки завантажень:"
		"folderNotFound" = "⚠ Папку не знайдено:"
		"cookieUsed" = "🍪 Використовується cookie: {0}"
		"cookieNotUsed" = "🍪 Cookie не використовується у цій сесії"
    }
    "ru" = @{
        "commandsHeader" = "`n💡 Команды:"
        "commands" = @(
            "  📥 Введите ссылки YouTube или ID через пробел, запятую или точку с запятой",
            "  🍪 -c <путь>  → Установить файл cookie",
            "  ⚡ -s         → Режим одиночной загрузки",
            "  ⚡ -m [N]     → Режим множественной загрузки (параллельные загрузки), необязательно N = 2-12, по умолчанию 5",
			"  📂 -o         → Открыть папку загрузок"
            "  🧹 clear      → Очистить консоль",
            "  ❌ q, e       → Выход из скрипта"
        )
        "promptInput" = "`n🎥 Ссылки, ID или команда"
        "clearing" = "🧹 Очистка..."
        "fileNotFound" = "⚠ Файл не найден: "
        "modeMultiSet" = "⚡ Режим множественной загрузки, параллель: "
        "modeSingleSet" = "⚡ Режим одиночной загрузки"
        "downloadingStartMulti" = "📥 Начало загрузки... ({0} треков, режим: {1}, параллель: {2})"
        "downloadingStartSingle" = "📥 Начало загрузки... ({0} треков, режим: {1})"
        "downloadingItem" = "📥 Загрузка: {0}"
        "done" = "✅ Готово! Файлы сохранены в: "
        "selectedModeSingle" = "⚡ Выбран режим: {0}"
        "selectedModeMulti" = "⚡ Выбран режим: {0}, параллель: {1}"
        "failedSaveOptions" = "⚠ Не удалось сохранить файл настроек"
        "failedLoadOptions" = "⚠ Не удалось прочитать файл настроек, используются значения по умолчанию"
        "downloadFFmpeg" = "⬇ Загрузка ffmpeg..."
        "downloadYtDlp" = "⬇ Загрузка yt-dlp..."
        "alarmRange" = "⚠ Значение должно быть в диапазоне 2 - 12, установлено "
        "exiting" = "👋 Выход..."
        "note" = " 💾 Выбранный режим и количество параллельных загрузок сохраняются и автоматически применяются при следующем запуске."
		"cookiesSet" = "🍪 Файл cookie установлен:"
		"openFolder" = "📂 Открытие папки загрузок:"
		"folderNotFound" = "⚠ Папку не найдено:"
		"cookieUsed" = "🍪 Используется cookie: {0}"
		"cookieNotUsed" = "🍪 Cookie не используется в этой сессии"
    }
}

# =======================
# Detect UI language
# =======================
$uiLang = (Get-UICulture).TwoLetterISOLanguageName
$lang = if ($loc.ContainsKey($uiLang)) { $uiLang } else { "en" }

# =======================
# Helper Functions
# =======================

# Ensure folder exists
function Ensure-Folder { param([string]$Path); if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null } }

# Install yt-dlp if missing
function Install-YtDlp { param([string]$InstallDir)
    $ytDlpPath = Join-Path $InstallDir "yt-dlp.exe"
    if (-not (Test-Path $ytDlpPath)) { Write-Host $loc[$lang].downloadYtDlp; Invoke-WebRequest "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile $ytDlpPath }
}

# Install ffmpeg if missing
function Install-FFmpeg { param([string]$InstallDir)
    $ffmpegPath = Join-Path $InstallDir "ffmpeg.exe"
    if (-not (Test-Path $ffmpegPath)) {
        Write-Host $loc[$lang].downloadFFmpeg
        $ffmpegZip = Join-Path $InstallDir "ffmpeg.zip"
        Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $ffmpegZip
        $tempDir = Join-Path $InstallDir "ffmpeg_temp"
        Expand-Archive $ffmpegZip -DestinationPath $tempDir -Force
        $ffmpegExe = Get-ChildItem "$tempDir" -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
        Copy-Item $ffmpegExe.FullName $ffmpegPath -Force
        Remove-Item $ffmpegZip -Force
        Remove-Item $tempDir -Recurse -Force
    }
}

# Load options safely
function Load-Options { param([string]$FilePath)
    $options = @{ downloadMode = "single"; maxParallel = 5 }
    if (-not (Test-Path $FilePath)) { return $options }
    try {
        Get-Content $FilePath | ForEach-Object {
            $_ = $_.Trim()
            if ($_ -match '^(\w+)\s*=\s*(.+)$') { $options[$Matches[1]] = $Matches[2] }
        }
    } catch { Write-Host $loc[$lang].failedLoadOptions }
    return $options
}

# Save options safely
function Save-Options { param([string]$FilePath, [hashtable]$Options)
    try {
        if (Test-Path $FilePath) { $attribs = (Get-Item $FilePath).Attributes; if ($attribs -band [System.IO.FileAttributes]::ReadOnly) { (Get-Item $FilePath).Attributes = $attribs -bxor [System.IO.FileAttributes]::ReadOnly } }
        $Options.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Set-Content -Path $FilePath -Force
        (Get-Item $FilePath).Attributes = (Get-Item $FilePath).Attributes -bor [System.IO.FileAttributes]::ReadOnly
    } catch { Write-Host $loc[$lang].failedSaveOptions }
}

# Show selected mode
function Show-SelectedMode { param([string]$Mode,[int]$Parallel)
    if ($Mode -eq "single") { Write-Host ($loc[$lang].selectedModeSingle -f $Mode) -ForegroundColor Cyan }
    else { Write-Host ($loc[$lang].selectedModeMulti -f $Mode, $Parallel) -ForegroundColor Green }
}

# =======================
# Initialize
# =======================
Ensure-Folder $installDir
Ensure-Folder $downloadsDir
Install-YtDlp $installDir
Install-FFmpeg $installDir

# Load options
$options = Load-Options -FilePath $optionsFile
$downloadMode = $options.downloadMode
$maxParallel = [int]$options.maxParallel

# Show header
function Show-Header {
	Write-Host "`n🎵 YouTube → MP3 (320 kbps) Downloader" -ForegroundColor Magenta
	Show-SelectedMode -Mode $downloadMode -Parallel $maxParallel
	
	# Mini-info: cookie usage
	if ($cookiesPath -ne $null) {
		Write-Host ($loc[$lang].cookieUsed -f $cookiesPath) -ForegroundColor Yellow
	} else {
		Write-Host ($loc[$lang].cookieNotUsed) -ForegroundColor DarkGray
	}

	# Commands list
	Write-Host $loc[$lang].commandsHeader -ForegroundColor White
	$loc[$lang].commands | ForEach-Object { Write-Host $_ -ForegroundColor White } 

	# Note
	Write-Host "`n"$loc[$lang].note -ForegroundColor Gray
}

Show-Header

# =======================
# Main Loop
# =======================
while ($true) {
    $inputLine = Read-Host $loc[$lang].promptInput

    if ([string]::IsNullOrWhiteSpace($inputLine) -or $inputLine -match '^(q|quit|e|exit)$') { Write-Host $loc[$lang].exiting; break }
	
	# Open downloads folder
	if ($inputLine -match '^-o$') {
		if (Test-Path $downloadsDir) {
			Write-Host $loc[$lang].openFolder$downloadsDir -ForegroundColor Green
			Start-Process $downloadsDir
		} else {
			Write-Host $loc[$lang].folderNotFound$downloadsDir -ForegroundColor Red
		}
		continue
}

    # Clear console
    if ($inputLine -match '^(clear|clean)$') { 
		Clear-Host; 
		Write-Host $loc[$lang].clearing; 
		Start-Sleep -Milliseconds 300
		Clear-Host; 
		Show-Header
		continue 
	}

    # Set cookies
    if ($inputLine -match '^-c\s+(.+)$') {
        $newPath = $Matches[1].Trim('"')
        if (Test-Path $newPath) { $cookiesPath = $newPath;  Write-Host $loc[$lang].cookiesSet$cookiesPath }
        else { Write-Host $loc[$lang].fileNotFound$newPath }
        continue
    }

    # Set download mode
    if ($inputLine -match '^-s$') { $downloadMode = "single"; $options.downloadMode = $downloadMode; Save-Options -FilePath $optionsFile -Options $options; Show-SelectedMode -Mode $downloadMode -Parallel $maxParallel; continue }
    if ($inputLine -match '^-m\s*(\d*)$') {
        $num = $Matches[1]
        if (-not $num) { $num = $maxParallel }
        $num = [int]$num
        if ($num -lt 2) { $num = 2; Write-Host $loc[$lang].alarmRange + $num -ForegroundColor Red }
        if ($num -gt 12) { $num = 12; Write-Host $loc[$lang].alarmRange + $num -ForegroundColor Red }
        $downloadMode = "multi"; $maxParallel = $num; $options.downloadMode = $downloadMode; $options.maxParallel = $maxParallel
        Save-Options -FilePath $optionsFile -Options $options
        Show-SelectedMode -Mode $downloadMode -Parallel $maxParallel
        continue
    }

    # Split URLs
    $urls = $inputLine -split '[ ,;]+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $total = $urls.Count
    $completed = 0

    if ($downloadMode -eq "multi") { Write-Host ($loc[$lang].downloadingStartMulti -f $total, $downloadMode, $maxParallel) -ForegroundColor Cyan }
    else { Write-Host ($loc[$lang].downloadingStartSingle -f $total, $downloadMode) -ForegroundColor Cyan }

    # Downloading
    if ($downloadMode -eq "single") {
        foreach ($u in $urls) {
            $url = if ($u -match '^[A-Za-z0-9_-]{11}$') { "https://www.youtube.com/watch?v=$u" } else { $u }
            Write-Host ($loc[$lang].downloadingItem -f $url)
            $cmdArgs = @("-x","--audio-format","mp3","--audio-quality","320K","-o","$downloadsDir\%(title)s.%(ext)s",$url)
            if ($cookiesPath) { $cmdArgs = @("--cookies",$cookiesPath) + $cmdArgs }
            & "$installDir\yt-dlp.exe" @cmdArgs
        }
    } else {
        $jobs = @()
        foreach ($u in $urls) {
            while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $maxParallel) { Start-Sleep -Milliseconds 100 }
            $jobs += Start-Job -ScriptBlock {
                param($u,$InstallDir,$DownloadsDir,$CookiesPath)
                $url = if ($u -match '^[A-Za-z0-9_-]{11}$') { "https://www.youtube.com/watch?v=$u" } else { $u }
                Write-Host ("📥 Downloading: {0}" -f $url)
                $cmdArgs = @("-x","--audio-format","mp3","--audio-quality","320K","-o","$DownloadsDir\%(title)s.%(ext)s",$url)
                if ($CookiesPath) { $cmdArgs = @("--cookies",$CookiesPath) + $cmdArgs }
                & "$InstallDir\yt-dlp.exe" @cmdArgs
            } -ArgumentList $u,$installDir,$downloadsDir,$cookiesPath
        }
        while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -gt 0) { Start-Sleep -Milliseconds 300 }
        Receive-Job -Job $jobs | Out-Null
        Remove-Job -Job $jobs
    }

    Write-Host ($loc[$lang].done + $downloadsDir)
}
