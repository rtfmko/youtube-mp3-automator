@echo off
setlocal enabledelayedexpansion

:: === Configuration ===
set "scriptDir=%LOCALAPPDATA%\yt-dlp"
set "scriptPath=%scriptDir%\youtube-mp3.ps1"
set "scriptUrl=https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/youtube-mp3.ps1"
set "versionFileUrl=https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/main/version.txt"
set "localVersionFile=%scriptDir%\version.txt"

echo.

:: === Create folder if not ===
if not exist "%scriptDir%" mkdir "%scriptDir%"

:: === Download the version from GitHub to a temporary file ===
powershell -NoProfile -Command ^
    "Invoke-WebRequest -Uri '%versionFileUrl%' -OutFile '%scriptDir%\version.tmp' -UseBasicParsing -ErrorAction SilentlyContinue"

:: === Read the remote version and remove BOM/invisible characters ===
for /f "usebackq tokens=* delims=" %%A in (`powershell -NoProfile -Command ^
    "(Get-Content '%scriptDir%\version.tmp' -Raw).Trim()"`) do set "remoteVersion=%%A"

:: === Read the local version and remove BOM/invisible characters ===
set "localVersion="
if exist "%localVersionFile%" for /f "usebackq tokens=* delims=" %%A in (`powershell -NoProfile -Command ^
    "(Get-Content '%localVersionFile%' -Raw).Trim()"`) do set "localVersion=%%A"

:: === Compare versions ===
if not "!remoteVersion!"=="!localVersion!" (
    echo 🔄 Updating script to version !remoteVersion!...
    powershell -NoProfile -Command "Invoke-WebRequest '%scriptUrl%' -OutFile '%scriptPath%' -UseBasicParsing"
    echo !remoteVersion! > "%localVersionFile%"
) else (
    echo ✅ Script is up to date (version !localVersion!^)
)

:: === Delete the temporary file ===
del "%scriptDir%\version.tmp"

:: === Run the script ===
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%"

echo.

