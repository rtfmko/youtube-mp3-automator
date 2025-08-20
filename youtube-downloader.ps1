# =======================
# Configuration
# =======================
$installDir = Join-Path $env:LOCALAPPDATA "yt-dlp"
$optionsFile = Join-Path $installDir "options.txt"
$cookiesPath = $null       # Store path to cookies if specified
$maxParallel = 5           # Max parallel count for multi (-m) mode

# --- Added for download mode ---
$dm = "audio"              # Default download type: audio or video
$videoQuality = "best"     # Default video quality (best if not set)


# Try to detect default Downloads\YouTubeMusic path
function Get-DefaultDownloads {
    try {
        return Join-Path (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path "YouTubeMusic"
    } catch {
        # fallback: C:\Users\<User>\Downloads\YouTubeMusic
        return Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\YouTubeMusic"
    }
}

# --- Added for video default downloads ---
function Get-DefaultDownloadsVideo {
    try {
        return Join-Path (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path "YouTubeVideo"
    } catch {
        return Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\YouTubeVideo"
    }
}


# =======================
# Localization
# =======================
$loc = @{
    "en" = @{
        "commandsHeader" = "`n💡 Commands:"
        "commands" = @(
            "  📥 Enter YouTube links or IDs separated by space, comma, or semicolon",
            "  🍪 -c <path>       → Set cookies file",
            "  ⚡ -s              → Single download mode (one by one)",
            "  ⚡ -m [N]          → Multi download mode (parallel downloads), optional N = 2-12, default 5",
            "  ♻  -r              → Reinstall yt-dlp and ffmpeg",
            "  📂 -o              → Open downloads folder",
            "  📂 -dir audio <p>  → Set custom audio downloads folder",
            "  📂 -dir video <p>  → Set custom video downloads folder",
            "  🌐 -l <en|uk|ru>   → Change interface language",
            "  🎚  -dm audio       → Set download mode: audio",
            "  🎚  -dm video [q]   → Set download mode: video, optional q = 720,1080,1440,2160",
            "  🧹 clear           → Clear console",
            "  ❌ q, e            → Exit script"
        )
        "promptInput" = "`n🎥 Links, IDs, or command"
        "clearing" = "🧹 Clearing..."
        "fileNotFound" = "⚠ File not found: "
        "modeMultiSet" = "⚡ Mode set to multi download, parallel: "
        "modeSingleSet" = "⚡ Mode set to single download"
        "downloadingStartMulti" = "📥 Downloading start... ({0} links, mode: {1}, parallel: {2})"
        "downloadingStartSingle" = "📥 Downloading start... ({0} links, mode: {1})"
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
        "langSet" = "🌐 Language set to:"
        "reinstall" = "♻ Reinstalling yt-dlp and ffmpeg..."
        "dmSet" = "🎚  Download mode set to:"
        "videoQSet" = "📹 Video quality set to:"
        "downloadFolder" = "📂 Download folder:"
        "currentMode" = "🎚  Current mode:"
        "videoQuality" = "📹 Video quality:"
        "folderSet" = " folder set: "
		"title" = "🎬 Title:      {0}"
		"duration" = "⏱  Duration:   {0}"
		"type" = "📦 Type:       {0}"
		"format" = "🎯 Format:     {0}"
		"savingTo" = "📂 Saving to:  {0}"
		"createdFolder" = "📁 Created folder: {0}"
		"successfully" = "✅ Successfully saved: {0}"
		"donwloadingError" = "❌ Error downloading: {0}"
		"retry" = "🔄 Trying fallback with best available format..."
		"exception" = "❌ Exception occurred while downloading"
		"qualityError" = "⚠️ Invalid quality: {0}. Allowed: 720, 1080, 1440, 2160"
    }
    "uk" = @{
        "commandsHeader" = "`n💡 Команди:"
        "commands" = @(
            "  📥 Введіть посилання YouTube або ID, розділені пробілом, комою або крапкою з комою",
            "  🍪 -c <шлях>       → Встановити файл cookie",
            "  ⚡ -s              → Режим одиночного завантаження",
            "  ⚡ -m [N]          → Режим множинного завантаження (паралельні завантаження), необов’язково N = 2-12, за замовчуванням 5",
			"  ♻  -r              → Перевстановити yt-dlp та ffmpeg",
			"  📂 -o              → Відкрити папку завантажень"
			"  📂 -dir audio <p>  → Встановити власну папку для завантаження музики",
			"  📂 -dir video <p>  → Встановити власну папку для завантаження відео",
			"  🌐 -l <en|uk|ru>   → Змінити мову інтерфейсу",
			"  🎚  -dm audio       → Встановити режим завантаження: музики",
            "  🎚  -dm video [q]   → Встановити режим завантаження: відео, (необов’язково) q = 720,1080,1440,2160"
            "  🧹 clear           → Очистити консоль",
            "  ❌ q, e            → Вихід із скрипту"
        )
        "promptInput" = "`n🎥 Посилання, ID або команда"
        "clearing" = "🧹 Очищення..."
        "fileNotFound" = "⚠ Файл не знайдено: "
        "modeMultiSet" = "⚡ Режим множинного завантаження, паралель: "
        "modeSingleSet" = "⚡ Режим одиночного завантаження"
        "downloadingStartMulti" = "📥 Початок завантаження... ({0} посилань, режим: {1}, паралель: {2})"
        "downloadingStartSingle" = "📥 Початок завантаження... ({0} посилань, режим: {1})"
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
		"langSet" = "🌐 Мову змінено на:"
		"reinstall" = "♻  Перевстановлення yt-dlp та ffmpeg..."
		"dmSet" = "🎚  Режим завантаження встановлено на:"
        "videoQSet" = "📹 Якість відео встановлено на:"
		"downloadFolder" = "📂 Папка для завантаження:"
		"currentMode" = "🎚  Поточний режим:"
		"videoQuality" = "📹 Якість відео:"
		"folderSet" = " папка встановлена: "
		"title" = "🎬 Назва:        {0}"
		"duration" = "⏱  Тривалість:   {0}"
		"type" = "📦 Тип:          {0}"
		"format" = "🎯 Формат:       {0}"
		"savingTo" = "📂 Збереження в:    {0}"
		"createdFolder" = "📁 Створено папку: {0}"
		"successfully" = "✅ Успішно збережено: {0}"
		"donwloadingError" = "❌ Помилка завантаження: {0}"
		"retry" = "🔄 Спроба альтернативного варіанту з найкращим доступним форматом..."
		"exception" = "❌ Під час завантаження сталася помилка"
		"qualityError" = "⚠️ Недійсна якість: {0}. Дозволено: 720, 1080, 1440, 2160"
    }
    "ru" = @{
        "commandsHeader" = "`n💡 Команды:"
        "commands" = @(
            "  📥 Введите ссылки YouTube или ID через пробел, запятую или точку с запятой",
            "  🍪 -c <путь>       → Установить файл cookie",
            "  ⚡ -s              → Режим одиночной загрузки",
            "  ⚡ -m [N]          → Режим множественной загрузки (параллельные загрузки), (необязательно) N = 2-12, по умолчанию 5",
			"  ♻  -r              → Переустановить yt-dlp и ffmpeg",
			"  📂 -o              → Открыть папку загрузок"
			"  📂 -dir audio <p>  → Установить свою папку для загрузки музыки",
			"  📂 -dir video <p>  → Установить свою папку для загрузки видео",
			"  🌐 -l <en|uk|ru>   → Сменить язык интерфейса",
			"  🎚  -dm audio       → Установить режим загрузки: музыки",
            "  🎚  -dm video [q]   → Установить режим загрузки: видео, (необязательно) q = 720,1080,1440,2160"
            "  🧹 clear           → Очистить консоль",
            "  ❌ q, e            → Выход из скрипта"
        )
        "promptInput" = "`n🎥 Ссылки, ID или команда"
        "clearing" = "🧹 Очистка..."
        "fileNotFound" = "⚠ Файл не найден: "
        "modeMultiSet" = "⚡ Режим множественной загрузки, параллель: "
        "modeSingleSet" = "⚡ Режим одиночной загрузки"
        "downloadingStartMulti" = "📥 Начало загрузки... ({0} ссылок, режим: {1}, параллель: {2})"
        "downloadingStartSingle" = "📥 Начало загрузки... ({0} ссылок, режим: {1})"
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
		"langSet" = "🌐 Язык изменён на:"
		"reinstall" = "♻  Переустановка yt-dlp и ffmpeg..."
		"dmSet" = "🎚  Режим загрузки установлен на:"
        "videoQSet" = "📹 Качество видео установлено на:"
		"downloadFolder" = "📂 Папка для загрузок:"
		"currentMode" = "🎚  Текущий режим:"
		"videoQuality" = "📹 Качество видео:"
		"folderSet" = " папка установлена: "
		"title" = "🎬 Название:           {0}"
		"duration" = "⏱  Продолжительность:  {0}"
		"type" = "📦 Тип:                {0}"
		"format" = "🎯 Формат:             {0}"
		"savingTo" = "📂 Сохранение в:     {0}"
		"createdFolder" = "📁 Создано папку: {0}"
		"successfully" = "✅ Успешно сохранено: {0}"
		"donwloadingError" = "❌ Ошибка загрузки: {0}"
		"retry" = "🔄 Попытка альтернативного варианта с лучшим доступным форматом..."
		"exception" = "❌ При загрузке произошла ошибка"
		"qualityError" = "⚠️ Недопустимое качество: {0}. Разрешено: 720, 1080, 1440, 2160"
    }
}

# =======================
# Helper Functions
# =======================

# Ensure folder exists
function Ensure-Folder { param([string]$Path); if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null } }

# Write log to file
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("info","error")]
        [string]$Type,
        [string]$InstallDir = $null
    )

    if (-not $InstallDir) {
        if ($script:installDir) {
            $InstallDir = $script:installDir
        } else {
            throw "Write-Log: InstallDir is null or empty"
        }
    }

    $logDir = Join-Path $InstallDir "logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    $logFile = if ($Type -eq "error") {
        Join-Path $logDir "error.log"
    } else {
        Join-Path $logDir "info.log"
    }

    # Line limit
    $maxLines = if ($Type -eq "error") { 2000 } else { 500 }

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "[$timestamp] [$Type] $Message"

    # Добавляем запись построчно
    Add-Content -Path $logFile -Value $entry -Encoding UTF8

    # Чистим лишние строки (если файл слишком длинный)
    $lines = Get-Content $logFile
    if ($lines.Count -gt $maxLines) {
        $lines = $lines[-$maxLines..-1]
        $lines | Set-Content -Path $logFile -Encoding UTF8
    }
}


# Install yt-dlp if missing
function Install-YtDlp { 
	param(
		[string]$InstallDir
		)
		
    $ytDlpPath = Join-Path $InstallDir "yt-dlp.exe"
    if (-not (Test-Path $ytDlpPath)) { 
		Write-Log -Message "Started downloading yt-dlp" -Type "info" -InstallDir $installDir
		Write-Host $loc[$lang].downloadYtDlp; 
		Invoke-WebRequest "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile $ytDlpPath 
	}
}

# Install ffmpeg if missing
function Install-FFmpeg { param([string]$InstallDir)
    $ffmpegPath = Join-Path $InstallDir "ffmpeg.exe"
    if (-not (Test-Path $ffmpegPath)) {
		Write-Log -Message "Started downloading ffmpeg" -Type "info" -InstallDir $installDir
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
function Load-Options {
    param([string]$FilePath)

    $options = @{
        downloadMode    = "single"
        maxParallel     = 5
        downloadsDirMusic = $null
        downloadsDirVideo = $null
        dm              = "audio"
        videoQuality    = "1080"
    }

    if (-not (Test-Path $FilePath)) { return $options }

    try {
        Get-Content $FilePath | ForEach-Object {
            $_ = $_.Trim()
            if ($_ -match '^(\w+)\s*=\s*(.+)$') {
                $options[$Matches[1]] = $Matches[2]
            }
        }
    }
    catch {
        Write-Host "⚠ Failed to read options file, using defaults"
    }

    # ✅ Validation for videoQuality
    $allowedQualities = @(720, 1080, 1440, 2160)
    if (-not ($allowedQualities -contains [int]$options.videoQuality)) {
        $options.videoQuality = "1080"
    }

    return $options
}


# Save options safely
function Save-Options { param([string]$FilePath, [hashtable]$Options)
    try {
        if (Test-Path $FilePath) {
            $attribs = (Get-Item $FilePath).Attributes
            if ($attribs -band [System.IO.FileAttributes]::ReadOnly) {
                (Get-Item $FilePath).Attributes = $attribs -bxor [System.IO.FileAttributes]::ReadOnly
            }
        }
        $Options.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Set-Content -Path $FilePath -Force
        (Get-Item $FilePath).Attributes = (Get-Item $FilePath).Attributes -bor [System.IO.FileAttributes]::ReadOnly
    } catch { Write-Host $loc[$lang].failedSaveOptions }
}
# Show selected mode
function Show-SelectedMode { param([string]$Mode,[int]$Parallel)
    if ($Mode -eq "single") { Write-Host ($loc[$lang].selectedModeSingle -f $Mode) -ForegroundColor Cyan }
    else { Write-Host ($loc[$lang].selectedModeMulti -f $Mode, $Parallel) -ForegroundColor Green }
}

# Load options
$options = Load-Options -FilePath $optionsFile
$downloadMode = $options.downloadMode
$maxParallel = [int]$options.maxParallel
$dm = $options.dm
$videoQuality = $options.videoQuality

if (-not $options.downloadsDirMusic) {
    $downloadsDirMusic = Get-DefaultDownloads
    $options.downloadsDirMusic = $downloadsDirMusic
} else {
    $downloadsDirMusic = $options.downloadsDirMusic
}
Ensure-Folder $downloadsDirMusic

if (-not $options.downloadsDirVideo) {
    $downloadsDirVideo = Get-DefaultDownloadsVideo
    $options.downloadsDirVideo = $downloadsDirVideo
} else {
    $downloadsDirVideo = $options.downloadsDirVideo
}
Ensure-Folder $downloadsDirVideo
Save-Options -FilePath $optionsFile -Options $options


function Detect-Language {
    $sysLang = (Get-Culture).TwoLetterISOLanguageName
    switch ($sysLang) {
		"uk" { return "uk" }
        "ru" { return "ru" }
        default { return "en" }
    }
}

# Initialize language
if ($options.lang) {
    $lang = $options.lang
} else {
    $lang = Detect-Language
    $options.lang = $lang
    Save-Options -FilePath $optionsFile -Options $options
}


# =======================
# Initialize
# =======================
Ensure-Folder $installDir
Install-YtDlp $installDir
Install-FFmpeg $installDir

# Show header
function Show-Header {
	Write-Host "`n🎵 YouTube → Downloader" -ForegroundColor Magenta
	Show-SelectedMode -Mode $downloadMode -Parallel $maxParallel
	
	# Mini-info: cookie usage
	if ($cookiesPath -ne $null) {
		Write-Host ($loc[$lang].cookieUsed -f $cookiesPath) -ForegroundColor Yellow
	} else {
		Write-Host ($loc[$lang].cookieNotUsed) -ForegroundColor DarkGray
	}
	if ($Options.dm -eq "video") {
		Write-Host "$($loc[$lang].downloadFolder) $downloadsDirVideo" -ForegroundColor Green
	} else {
		Write-Host "$($loc[$lang].downloadFolder) $downloadsDirMusic" -ForegroundColor Green	
	}
	Write-Host "$($loc[$lang].currentMode) $($options.dm)" -ForegroundColor Cyan
	if ($options.dm -eq "video" -and $options.videoQuality) {
		Write-Host "$($loc[$lang].videoQuality) $($options.videoQuality)p" -ForegroundColor Green
	}

	# Commands list
	Write-Host $loc[$lang].commandsHeader -ForegroundColor White
	$loc[$lang].commands | ForEach-Object { Write-Host $_ -ForegroundColor White } 

	# Note
	Write-Host "`n"$loc[$lang].note -ForegroundColor Gray
}

Show-Header

# =======================
# Download function with fallback
# =======================
function Download-Item {
    param(
        [string[]]$Urls,
        [string]$InstallDir,
        [string]$DownloadsDir,
        [string]$CookiesPath = $null,
        [int]$MaxParallel = 5,
        [string]$DownloadMode = "single",
        [string]$Type = "audio",
        [string]$VideoQuality = $null,
        [int]$MaxRetries = 3
    )

    Write-Log -Type info -Message (
        "Download-Item called with Urls='{0}', InstallDir='{1}', DownloadsDir='{2}', CookiesPathSet={3}, MaxParallel={4}, DownloadMode='{5}', Type='{6}', VideoQuality='{7}', MaxRetries={8}" -f `
        ($Urls -join ', '), $InstallDir, $DownloadsDir, ([bool]$CookiesPath), $MaxParallel, $DownloadMode, $Type, $VideoQuality, $MaxRetries
    ) -InstallDir $installDir

    # Check and create folder if not exists
    if (-not (Test-Path $DownloadsDir)) {
        New-Item -ItemType Directory -Path $DownloadsDir | Out-Null
        Write-Log -Message "Creating folder while download: $DownloadsDir" -Type "info" -InstallDir $installDir
        Write-Host ($Loc[$Lang].createdFolder -f $DownloadsDir) -ForegroundColor White
    }

    # ======= Helper retry wrapper =======
    function Invoke-WithRetry {
        param([scriptblock]$Action, [string]$Title, [int]$MaxRetries = 3)

        $attempt = 1
        while ($attempt -le $MaxRetries) {
            Write-Log -Type info -Message ("[{0}] attempt {1}/{2} starting" -f $Title,$attempt,$MaxRetries) -InstallDir $InstallDir

            & $Action
            $exitCode = $LASTEXITCODE

            if ($exitCode -eq 0) {
                Write-Log -Type info -Message ("[{0}] success on attempt {1}" -f $Title,$attempt) -InstallDir $InstallDir
                return $true
            } else {
                Write-Host ($loc[$Lang].donwloadingError -f $Title) -ForegroundColor Red
                Write-Host ($loc[$Lang].retry) -ForegroundColor Yellow
                Write-Log -Type error -Message ("[{0}] failed on attempt {1}/{2}, ExitCode={3}" -f $Title,$attempt,$MaxRetries,$exitCode) -InstallDir $InstallDir
                $attempt++
                if ($attempt -le $MaxRetries) { Start-Sleep -Seconds 2 }
            }
        }

        Write-Log -Type error -Message ("[{0}] all attempts failed" -f $Title) -InstallDir $InstallDir
        return $false
    }

    # Method for single download
    function Download-Single {
        param($Url)

        $urlFull = if ($Url -match '^[A-Za-z0-9_-]{11}$') { "https://www.youtube.com/watch?v=$Url" } else { $Url }

        try {
            # Get video/audio info
            $infoArgs = @("--dump-json","--no-warnings","--extractor-args","youtube:player-client=web_embedded,web,tv",$urlFull)
            if ($CookiesPath) { $infoArgs = @("--cookies",$CookiesPath) + $infoArgs }
            
            Write-Log -Type info -Message ("InfoArgs: {0}" -f ($infoArgs -join ' ')) -InstallDir $installDir

            $infoJsonRaw = & "$InstallDir\yt-dlp.exe" @infoArgs 2>$null
            $infoJson = $infoJsonRaw | ConvertFrom-Json

            $downloadType = if ($Type -eq "audio") { "Audio Only" } else { "Video + Audio" }
            $formatText = if ($Type -eq "audio") { "mp3" } else { "mp4" }

            # Pretty console output
            Write-Host "───────────────────────────────" -ForegroundColor DarkGray
            Write-Host ($loc[$lang].title -f $infoJson.title) -ForegroundColor Cyan
            Write-Host ($loc[$lang].duration -f ([TimeSpan]::FromSeconds($infoJson.duration))) -ForegroundColor Yellow
            Write-Host ($loc[$lang].type -f $downloadType) -ForegroundColor Magenta
            Write-Host ($loc[$lang].format -f $formatText) -ForegroundColor Green
            Write-Host ($loc[$lang].title -f $DownloadsDir) -ForegroundColor White
            Write-Host "───────────────────────────────" -ForegroundColor DarkGray

            Write-Log -Type info -Message ("Prepare download: Title='{0}', DurationSec={1}, Type='{2}', Format='{3}', SavingTo='{4}'" -f `
                $infoJson.title, $infoJson.duration, $downloadType, $formatText, $DownloadsDir) -InstallDir $installDir

            # Build yt-dlp args
            if ($Type -eq "audio") {
                $cmdArgs = @(
                    "-x","--audio-format","mp3","--audio-quality","320K",
                    "-o","$DownloadsDir\%(title)s.%(ext)s",
                    $urlFull
                )
            } else {
                if ($VideoQuality) {
                    $cmdArgs = @(
                        "-f", "bestvideo[height<=$videoQuality]+bestaudio/best",
                        "--merge-output-format", "mp4",
                        "-o","$DownloadsDir\%(title)s.%(ext)s",
                        $urlFull
                    )
                } else {
                    $cmdArgs = @(
                        "-f","bestvideo+bestaudio/best",
                        "--merge-output-format", "mp4",
                        "-o","$DownloadsDir\%(title)s.%(ext)s",
                        $urlFull
                    )
                }
            }
            if ($CookiesPath) { $cmdArgs = @("--cookies",$CookiesPath) + $cmdArgs }
            $cmdArgs += @("--extractor-args","youtube:player-client=web_embedded,web,tv")

            Write-Log -Type info -Message ("CmdArgs: {0}" -f ($cmdArgs -join ' ')) -InstallDir $installDir

            # Run with retry wrapper
            $success = Invoke-WithRetry -Title $infoJson.title -Action {
                Start-Process -FilePath "$InstallDir\yt-dlp.exe" -ArgumentList $cmdArgs -Wait -PassThru | Out-Null
            }

            if ($success) {
                Write-Host ($loc[$Lang].successfully -f $infoJson.title) -ForegroundColor Green
            } else {
                Write-Host ($loc[$Lang].donwloadingError -f $infoJson.title) -ForegroundColor Red
            }

            Write-Log -Type info -Message ("Finished: {0}" -f $infoJson.title) -InstallDir $installDir

        } catch {
            Write-Log -Type error -Message ("Exception while downloading '{0}': {1}" -f $urlFull, $_) -InstallDir $installDir
            Write-Host ($loc[$lang].exception) -ForegroundColor Red
            Write-Host ($_) -ForegroundColor Red
        }
    }

    # Run depending on mode
    if ($DownloadMode -eq "single") {
        foreach ($u in $Urls) {
            Write-Log -Type info -Message ("Queue(single): {0}" -f $u) -InstallDir $InstallDir
            Download-Single $u
        }
    } else {
        $jobs = @()
        foreach ($u in $Urls) {
            while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $MaxParallel) {
                Start-Sleep -Milliseconds 100
            }

            Write-Log -Type info -Message ("Queue(job): {0}" -f $u) -InstallDir $InstallDir

            $jobs += Start-Job -ScriptBlock {
                param($Url, $InstallDir, $DownloadsDir, $CookiesPath, $Type, $Lang, $Loc, $VideoQuality, $MaxRetries)

                function Invoke-WithRetry {
                    param([scriptblock]$Action, [string]$Title, [int]$MaxRetries)

                    $attempt = 1
                    while ($attempt -le $MaxRetries) {
                        $null = & $Action
                        if ($LASTEXITCODE -eq 0) {
                            return $true
                        } else {
                            $attempt++
                            if ($attempt -le $MaxRetries) { Start-Sleep -Seconds 2 }
                        }
                    }
                    return $false
                }

                function Download-Single-Job {
                    param($UrlJob)

                    $urlFull = if ($UrlJob -match '^[A-Za-z0-9_-]{11}$') { "https://www.youtube.com/watch?v=$UrlJob" } else { $UrlJob }

                    try {
                        $infoArgs = @("--dump-json","--no-warnings","--extractor-args","youtube:player-client=web_embedded,web,tv",$urlFull)
                        if ($CookiesPath) { $infoArgs = @("--cookies",$CookiesPath) + $infoArgs }

                        $infoJsonRaw = & "$InstallDir\yt-dlp.exe" @infoArgs 2>$null
                        $infoJson = $infoJsonRaw | ConvertFrom-Json
                        $title = $infoJson.title
                        $downloadType = if ($Type -eq "audio") { "Audio Only" } else { "Video + Audio" }
                        $formatText = if ($Type -eq "audio") { "mp3" } else { "mp4" }

                        # Pretty console output
                        Write-Host "───────────────────────────────" -ForegroundColor DarkGray
                        Write-Host ($loc[$lang].title -f $infoJson.title) -ForegroundColor Cyan
                        Write-Host ($loc[$lang].duration -f ([TimeSpan]::FromSeconds($infoJson.duration))) -ForegroundColor Yellow
                        Write-Host ($loc[$lang].type -f $downloadType) -ForegroundColor Magenta
                        Write-Host ($loc[$lang].format -f $formatText) -ForegroundColor Green
                        Write-Host ($loc[$lang].title -f $DownloadsDir) -ForegroundColor White
                        Write-Host "───────────────────────────────" -ForegroundColor DarkGray

                        # Build args
                        $cmdArgs = if ($Type -eq "audio") {
                            @("-x","--audio-format","mp3","--audio-quality","320K",
                              "-o","$DownloadsDir\%(title)s.%(ext)s",$urlFull)
                        } elseif ($VideoQuality) {
                            @("-f","bestvideo[height<=$videoQuality]+bestaudio/best",
                              "--merge-output-format","mp4",
                              "-o","$DownloadsDir\%(title)s.%(ext)s",$urlFull)
                        } else {
                            @("-f","bestvideo+bestaudio/best",
                              "--merge-output-format","mp4",
                              "-o","$DownloadsDir\%(title)s.%(ext)s",$urlFull)
                        }
                        if ($CookiesPath) { $cmdArgs = @("--cookies",$CookiesPath) + $cmdArgs }
                        $cmdArgs += @("--extractor-args","youtube:player-client=web_embedded,web,tv")

                        $success = Invoke-WithRetry -Title $title -MaxRetries $MaxRetries -Action {
                            Start-Process -FilePath "$InstallDir\yt-dlp.exe" -ArgumentList $cmdArgs -Wait -PassThru | Out-Null
                        }

                        if ($success) {
                            Write-Host ($loc[$Lang].successfully -f $title) -ForegroundColor Green
                        } else {
                            Write-Host ($loc[$Lang].donwloadingError -f $title) -ForegroundColor Red
                        }

                    }
                    catch {
                        Write-Host ($loc[$lang].exception) -ForegroundColor Red
                        Write-Host ($_) -ForegroundColor Red
                    }
                }

                Download-Single-Job $Url

            } -ArgumentList $u, $InstallDir, $DownloadsDir, $CookiesPath, $Type, $Lang, $Loc, $VideoQuality, $MaxRetries
        }

        while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -gt 0) { Start-Sleep -Milliseconds 300 }
        Receive-Job -Job $jobs | Out-Null
        Write-Log -Type info -Message ("All jobs completed: {0} item(s)" -f $Urls.Count) -InstallDir $installDir
        Remove-Job -Job $jobs
    }
}

# =======================
# Main Loop
# =======================
while ($true) {
    $inputLine = Read-Host $loc[$lang].promptInput

    if ([string]::IsNullOrWhiteSpace($inputLine) -or $inputLine -match '^(q|quit|e|exit)$') { Write-Host $loc[$lang].exiting; break }
	
	 # --- Added for download mode ---
	if ($inputLine -match '^-dm\s+(audio|video)(?:\s+(\d+))?$') {
		$dm = $Matches[1]
		$options.dm = $dm

		if ($dm -eq "video" -and $Matches[2]) {
			$videoQuality = [int]$Matches[2]
			$allowedQualities = @(720, 1080, 1440, 2160)

			if ($allowedQualities -contains $videoQuality) {
				$options.videoQuality = $videoQuality
				Write-Host "$($loc[$lang].videoQSet) ${videoQuality}p" -ForegroundColor Green
			}
			else {
				Write-Host ($loc[$lang].qualityError -f $videoQuality) -ForegroundColor Red
				continue
			}
		}

		Save-Options -FilePath $optionsFile -Options $options
		Write-Host "$($loc[$lang].dmSet) $dm" -ForegroundColor Cyan
		continue
	}

	
	 # --- Added for -dir audio/video ---
    if ($inputLine -match '^-dir\s+(audio|video)\s+(.+)$') {
        $target = $Matches[1]
        $newDir = $Matches[2].Trim('"')
        Ensure-Folder $newDir
        if ($target -eq "audio") {
            $downloadsDirMusic = $newDir
            $options.downloadsDirMusic = $downloadsDirMusic
        } else {
            $downloadsDirVideo = $newDir
            $options.downloadsDirVideo = $downloadsDirVideo
        }
        Save-Options -FilePath $optionsFile -Options $options
        Write-Host "📂 $target$($loc[$lang].folderSet)$newDir" -ForegroundColor Green
        continue
    }

	
	# Handle -r (reinstall yt-dlp and ffmpeg)
	if ($inputLine -eq "-r") {
		Write-Host $loc[$lang].reinstall -ForegroundColor Cyan
		$ytDlpPath = Join-Path $installDir "yt-dlp.exe"
		$ffmpegPath = Join-Path $installDir "ffmpeg.exe"
		if (Test-Path $ytDlpPath) { Remove-Item $ytDlpPath -Force }
		if (Test-Path $ffmpegPath) { Remove-Item $ffmpegPath -Force }
		Install-YtDlp $installDir
		Install-FFmpeg $installDir
		Clear-Host;
		Show-Header
		continue
	}
	
	# Open downloads folder
	if ($inputLine -match '^-o$') {
		if ($Options.dm -eq "video") {
			if (Test-Path $downloadsDirVideo) {
				Write-Host $loc[$lang].openFolder$downloadsDirVideo -ForegroundColor Green
				Start-Process $downloadsDirVideo
			} else {
				Write-Host $loc[$lang].folderNotFound$downloadsDirVideo -ForegroundColor Red
			}
		} else {
			if (Test-Path $downloadsDirMusic) {
			Write-Host $loc[$lang].openFolder$downloadsDirMusic -ForegroundColor Green
			Start-Process $downloadsDirMusic
			} else {
				Write-Host $loc[$lang].folderNotFound$downloadsDirMusic -ForegroundColor Red
			}
		}
		continue
	}

	# Change language
    if ($inputLine -match '^-l\s+(en|uk|ru)$') {
        $newLang = $Matches[1]
        $lang = $newLang
        $options.lang = $lang
        Save-Options -FilePath $optionsFile -Options $options
		Clear-Host; 
		Write-Host "$($loc[$lang].langSet) $lang" -ForegroundColor Blue
        Show-Header
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
	if ($Options.dm -eq "video") {
		$downloadsDirCurrent = $downloadsDirVideo
	} else {
		$downloadsDirCurrent = $downloadsDirMusic
	}

	# Вызов функции для загрузки
	if ($downloadMode -eq "single") {
		foreach ($u in $urls) {
			Download-Item -Urls @($u) `
						-InstallDir $installDir `
						-DownloadsDir $downloadsDirCurrent `
						-CookiesPath $cookiesPath `
						-MaxParallel $maxParallel `
						-DownloadMode "single" `
						-Type ($Options.dm) `
						-VideoQuality $videoQuality
		}
	} else {
		Download-Item -Urls $urls `
					-InstallDir $installDir `
					-DownloadsDir $downloadsDirCurrent `
					-CookiesPath $cookiesPath `
					-MaxParallel $maxParallel `
					-DownloadMode "multi" `
					-Type ($Options.dm) `
					-VideoQuality $videoQuality
	}
}
