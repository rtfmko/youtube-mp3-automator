@echo off
setlocal

:: Path to updater script on GitHub
set "updaterUrl=https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/updater.ps1"

:: Local script directory
set "scriptDir=%LOCALAPPDATA%\yt-dlp"
set "batDir=%~dp0"
set "updaterPath=%scriptDir%\updater.ps1"

:: Ensure script directory exists
if not exist "%scriptDir%" mkdir "%scriptDir%"

if "%batDir:~-1%"=="\" set "batDir=%batDir:~0,-1%"

:: Check if updater.ps1 exists
if not exist "%updaterPath%" (
    echo 🔄 updater.ps1 not found, downloading...
	powershell -NoProfile -Command ^
		"try { Invoke-WebRequest -Uri '%updaterUrl%' -OutFile '%updaterPath%' -UseBasicParsing -ErrorAction Stop; Set-ItemProperty -Path '%updaterPath%' -Name IsReadOnly -Value $true } catch { exit 1 }"

    if errorlevel 1 (
        echo ❌ Failed to download updater.ps1
        pause
        exit /b
    )
)

:: Run updater.ps1 and pass scriptDir as argument
powershell -NoProfile -ExecutionPolicy Bypass -File "%updaterPath%" -scriptDir "%scriptDir%" -batDir "%batDir%"

endlocal
