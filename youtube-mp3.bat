@echo off
set "scriptPath=C:\yt-dlp\youtube-mp3.ps1"

:: Create folder
if not exist "C:\yt-dlp" mkdir "C:\yt-dlp"

:: Download .ps1, if not exists
if not exist "%scriptPath%" powershell -NoProfile -Command ^
    "Invoke-WebRequest 'https://raw.githubusercontent.com/rtfmko/youtube-mp3-automator/refs/heads/main/youtube-mp3.ps1' -OutFile '%scriptPath%'"

:: Launch
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%"
