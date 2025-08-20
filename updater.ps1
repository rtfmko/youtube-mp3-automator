param(
    [string]$ScriptDir,
    [string]$BatDir
)

# ----------------------
# Configuration
# ----------------------
$remoteVersionUrl = "https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/version.txt"
$baseUrl = "https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/"
$localVersionFile = Join-Path $ScriptDir "version.txt"
$backupDir = Join-Path $ScriptDir "backup"
$updateHistoryFile = Join-Path $ScriptDir "update_history.log"

$components = @{
    loader = "youtube-downloader.ps1"
    updater = "updater.ps1"
    launcher = "youtube-downloader.bat"
}

# ----------------------
# Functions
# ----------------------
function Write-Log($message, $level="INFO") {
    switch ($level) {
        "INFO"    { Write-Host "ℹ $message" -ForegroundColor White }
        "SUCCESS" { Write-Host "✅ $message" -ForegroundColor Green }
        "WARN"    { Write-Host "⚠ $message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "❌ $message" -ForegroundColor Red }
    }

    "$([DateTime]::Now) [$level] $message" | Out-File -FilePath $updateHistoryFile -Append -Encoding UTF8

    # Trim log to last 500 lines
    if (Test-Path $updateHistoryFile) {
        $lines = Get-Content $updateHistoryFile
        if ($lines.Count -gt 500) {
            $lines[-500..-1] | Set-Content $updateHistoryFile -Force -Encoding UTF8
        }
    }
}

function Backup-File($filePath) {
    Ensure-Folder $backupDir
    Copy-Item $filePath -Destination $backupDir -Force
}

function Restore-Backup($filePath) {
    $backupPath = Join-Path $backupDir (Split-Path $filePath -Leaf)
    if (Test-Path $backupPath) { Copy-Item $backupPath -Destination $filePath -Force }
}

function Ensure-Folder([string]$path) {
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Get-RemoteVersions() {
    try {
        $content = Invoke-WebRequest $remoteVersionUrl -UseBasicParsing -ErrorAction Stop
        $lines = $content.Content -split "`n"
        $dict = @{}
        foreach ($line in $lines) {
            if ($line -match '^\s*(\w+)\s*=\s*([0-9\.!]+)') { $dict[$Matches[1]] = $Matches[2] }
        }
        return $dict
    } catch {
        Write-Log "Cannot fetch remote version file. Offline mode?" "WARN"
        return $null
    }
}

function Get-LocalVersions() {
    $dict = @{}
    if (Test-Path $localVersionFile) {
        $lines = Get-Content $localVersionFile
        foreach ($line in $lines) {
            if ($line -match '^\s*(\w+)\s*=\s*([0-9\.]+)') { $dict[$Matches[1]] = $Matches[2] }
        }
    }
    return $dict
}

function Download-Component($component, $fileName) {
    $url = "$baseUrl$fileName"
    if ($component -eq "launcher") {
        $dest = Join-Path $BatDir $fileName    
    } else {
        $dest = Join-Path $ScriptDir $fileName    
    }
    try {
        Write-Log "Downloading $component from $url ..."
        
        # remove read-only if exists
        if (Test-Path $dest) { Attrib -R $dest }
        
        Invoke-WebRequest $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
        
        # set file to read-only after download
        Attrib +R $dest

        Write-Log "$component updated successfully." "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to download $component!" "ERROR"
        return $false
    }
}

function Show-PatchNotesByVersion($file, $localVersion, $remoteVersion) {
    $patchFileName = switch ($file) {
        "youtube-downloader.ps1" { "loader.patch" }
        "youtube-mp3.ps1" { "loader.patch" }
        "updater.ps1"     { "updater.patch" }
        "youtube-downloader.bat" { "launcher.patch" }
        "youtube-mp3.bat" { "launcher.patch" }
        default           { "$file.patch" }
    }

    $patchUrl = "$baseUrl" + "patch-notes/$patchFileName"

    try {
        $content = Invoke-WebRequest $patchUrl -UseBasicParsing -ErrorAction Stop
        $notes = $content.Content.Trim()

        if (-not $notes) {
            Write-Host "`n📌 Patch notes for ${file} version ${remoteVersion}: None`n" -ForegroundColor Cyan
            return
        }

        Write-Host "`n📌 Patch notes for ${file} version ${remoteVersion}:`n" -ForegroundColor Cyan

        $show = $false
        $currentVersion = $localVersion

        foreach ($line in $notes -split "`n") {
            if ($line -match '^v([0-9\.]+)') {
                $ver = $Matches[1]
                # Если версия больше текущей, начинаем показывать
                if ([version]$ver -gt [version]$currentVersion) { $show = $true } 
                else { $show = $false }
            }
            if ($show -and $line -notmatch '^v[0-9\.]+') {
                Write-Host "  $line" -ForegroundColor White
            }
        }

    } catch {
        Write-Host "`n📌 Patch notes for ${file}: None`n" -ForegroundColor Cyan
    }
}


# ----------------------
# Main Logic
# ----------------------
Ensure-Folder $ScriptDir
Ensure-Folder $backupDir

# Bootstrap if no local version
if (-not (Test-Path $localVersionFile)) {
    Write-Log "Local version file not found. Bootstrapping initial setup..." "WARN"
    $remoteVersions = Get-RemoteVersions
    if ($remoteVersions) {
        foreach ($comp in @("loader","updater","launcher")) {
            $fileName = $components[$comp]
            Download-Component $comp $fileName | Out-Null
        }
        $remoteVersions.GetEnumerator() |
            ForEach-Object { "$($_.Key)=$($_.Value)" } |
            Set-Content -Path $localVersionFile -Force -Encoding UTF8
        Attrib +R $localVersionFile
        Write-Log "Bootstrap complete. Launching loader..." "SUCCESS"
        $loaderPath = Join-Path $ScriptDir $components.loader
        if (Test-Path $loaderPath) {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$loaderPath`""
            exit
        }
    } else {
        Write-Log "Cannot bootstrap without remote version info!" "ERROR"
        exit 1
    }
}

$localVersions = Get-LocalVersions
$remoteVersions = Get-RemoteVersions

# Determine updates
$updatesNeeded = @()
foreach ($comp in $components.Keys) {
    $localVer = $localVersions[$comp]
    $remoteVerRaw = $remoteVersions[$comp]

    # Check for forced-by-exclamation
    $forceByExcl = $false
    if ($remoteVerRaw -match '^(.*)!$') {
        $remoteVer = $Matches[1]
        if ([version]$remoteVer -gt [version]$localVer) { $forceByExcl = $true }
    } else {
        $remoteVer = $remoteVerRaw
    }

    if ($remoteVer -and ($localVer -ne $remoteVer)) {
        $updatesNeeded += $comp
        Write-Log "$comp update available: current=$localVer, remote=$remoteVerRaw" "WARN"
        Show-PatchNotesByVersion $components[$comp] $localVer $remoteVerRaw
    }
}

# Separate auto-update (! versions) from interactive
$autoUpdate = @()
$interactiveUpdate = @()
foreach ($comp in $updatesNeeded) {
    $remoteVerRaw = $remoteVersions[$comp]
    $localVer = $localVersions[$comp]

    if ($remoteVerRaw -match '^(.*)!$') {
        $remoteVer = $Matches[1]
        if ([version]$remoteVer -gt [version]$localVer) {
            $autoUpdate += $comp
            Write-Log "$comp has ! version. Will auto-update from $localVer to $remoteVer." "INFO"
        } else {
            $interactiveUpdate += $comp
        }
    } else {
        $interactiveUpdate += $comp
    }
}

# Interactive loop for non-forced components
$toUpdate = $autoUpdate
$skipAll = $false
$updateAll = $false
$i = 0

if ($interactiveUpdate.Count -gt 0) {
    Write-Host "`n📌 Update options:`n" -ForegroundColor Cyan
    Write-Host "   y → Update this component" -ForegroundColor Green
    Write-Host "   n → Skip this component" -ForegroundColor Yellow
    Write-Host "   a → Update all remaining components automatically" -ForegroundColor Magenta
    Write-Host "   s → Skip all remaining components" -ForegroundColor DarkYellow
    Write-Host "   q → Quit updater`n" -ForegroundColor Red

    while ($i -lt $interactiveUpdate.Count) {
        $comp = $interactiveUpdate[$i]

        if ($skipAll) { $i++; continue }
        if ($updateAll) { $toUpdate += $comp; $i++; continue }

        $answer = Read-Host "Update $comp [y/n/a/s/q]"
        switch ($answer.ToLower()) {
            'y' { $toUpdate += $comp }
            'n' { Write-Log "User skipped $comp" "INFO" }
            'a' { 
                $updateAll = $true
                $toUpdate += $comp
            }
            's' { $skipAll = $true }
            'q' { $skipAll = $true; break }
            default { Write-Host "Invalid input. Continue..."; continue }
        }
        $i++
    }
}

# Perform updates
foreach ($comp in $toUpdate) {
    $fileName = $components[$comp]
    $filePath = Join-Path $ScriptDir $fileName
    if (Test-Path $filePath) { Backup-File $filePath }

    $success = Download-Component $comp $fileName
    if (-not $success) { Restore-Backup $filePath }
    else { $localVersions[$comp] = $remoteVersions[$comp].TrimEnd('!') }
}

# Save updated local version file
if (Test-Path $localVersionFile) { Attrib -R $localVersionFile }
$localVersions.GetEnumerator() |
    ForEach-Object { "$($_.Key)=$($_.Value)" } |
    Set-Content -Path $localVersionFile -Force -Encoding UTF8
Attrib +R $localVersionFile

# Launch loader
$loaderPath = Join-Path $ScriptDir $components.loader
if (Test-Path $loaderPath) {
    Write-Log "Launching loader..." "INFO"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$loaderPath`""
} else {
    Write-Log "Loader not found!" "ERROR"
}
