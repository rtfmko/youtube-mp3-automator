param(
    [string]$ScriptDir
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
    loader = "youtube-mp3.ps1"
    updater = "updater.ps1"
    launcher = "youtube-mp3.bat"
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
            if ($line -match '^\s*(\w+)\s*=\s*([0-9\.]+)') { $dict[$Matches[1]] = $Matches[2] }
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
    $dest = Join-Path $ScriptDir $fileName
    try {
        Write-Log "Downloading $component from $url ..."
        Invoke-WebRequest $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Write-Log "$component updated successfully." "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to download $component!" "ERROR"
        return $false
    }
}

function Show-PatchNotes($file){
    $patchFileName = switch ($file) {
		"youtube-mp3.ps1" { "loader.patch" }
		"updater.ps1"     { "updater.patch" }
		"youtube-mp3.bat" { "launcher.patch" }
		default           { "$file.patch" }
	}
	
	$patchUrl = "$baseUrl" + "patch-notes/$patchFileName"
    try {
        $content = Invoke-WebRequest $patchUrl -UseBasicParsing -ErrorAction Stop
        $notes = $content.Content.Trim()
        if ($notes) {
            Write-Host "`n📌 Patch notes for ${file}:`n" -ForegroundColor Cyan
            $notes -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        } else {
            Write-Host "`n📌 Patch notes for ${file}: None`n" -ForegroundColor Cyan
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

# Parse force flag if any: force=loader,updater,launcher
$forceComponents = @()
foreach ($arg in $args) {
    if ($arg -match '^force=(.+)$') { $forceComponents = $Matches[1].Split(",") }
}

$localVersions = Get-LocalVersions
$remoteVersions = Get-RemoteVersions

$updatesNeeded = @()

foreach ($comp in $components.Keys) {
    $localVer = $localVersions[$comp]
    $remoteVer = $remoteVersions[$comp]

    if ($remoteVer -and ($localVer -ne $remoteVer -or $forceComponents -contains $comp)) {
        $updatesNeeded += $comp
        Write-Log "$comp update available: current=$localVer, remote=$remoteVer" "WARN"
        Show-PatchNotes $components[$comp]
    }
}

if ($updatesNeeded.Count -eq 0) {
    Write-Log "All components are up-to-date." "SUCCESS"
} else {
    # Interactive update loop with proper skip all / update all
    $toUpdate = @()
    $skipAll = $false
    $updateAll = $false
    $i = 0

    Write-Host "`n📌 Update options:"
    Write-Host "  y → Update this component"
    Write-Host "  n → Skip this component"
    Write-Host "  a → Update all remaining components automatically"
    Write-Host "  s → Skip all remaining components"
    Write-Host "  q → Quit updater`n"

    while ($i -lt $updatesNeeded.Count) {
        $comp = $updatesNeeded[$i]

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
            's' { 
                $skipAll = $true
            }
            'q' { break }
            default { Write-Host "Invalid input. Continue..."; continue }
        }
        $i++
    }

    foreach ($comp in $toUpdate) {
        $fileName = $components[$comp]
        $filePath = Join-Path $ScriptDir $fileName
        if (Test-Path $filePath) { Backup-File $filePath }

        $success = Download-Component $comp $fileName
        if (-not $success) { Restore-Backup $filePath }
        else { $localVersions[$comp] = $remoteVersions[$comp] }
    }

	# Save updated local version file (with read-only toggle)
		if (Test-Path $localVersionFile) {
			Attrib -R $localVersionFile
		}

		$localVersions.GetEnumerator() |
			ForEach-Object { "$($_.Key)=$($_.Value)" } |
			Set-Content -Path $localVersionFile -Force -Encoding UTF8

		Attrib +R $localVersionFile
}

# ----------------------
# Launch loader
# ----------------------
$loaderPath = Join-Path $ScriptDir $components.loader
if (Test-Path $loaderPath) {
    Write-Log "Launching loader..." "INFO"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$loaderPath`""
} else {
    Write-Log "Loader not found!" "ERROR"
}
