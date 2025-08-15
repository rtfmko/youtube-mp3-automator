# YouTube MP3 Downloader (PowerShell + BAT)

This project is a simple automation to download high-quality MP3 audio from YouTube videos using **PowerShell**.  

**Important:** This script automates the use of [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [ffmpeg](https://ffmpeg.org/), which are required for downloading and converting videos. We do not claim ownership of these tools; we simply automate their setup and usage.

## Features

- ✅ Automatically downloads and sets up **yt-dlp** and **ffmpeg**.
- 🎵 Converts YouTube videos to **MP3 (320 kbps)**.
- ⬇ Saves downloaded files directly to your **Downloads** folder.
- 🔄 Simple loop: input YouTube links one by one.
- ⚡ Easy to use via a single **BAT file**.

## How to Use

1. Download the `youtube-mp3.bat` file from this repository.
2. Run the BAT file — it will automatically:
   - Download the PS1 script.
   - Download and set up **yt-dlp** and **ffmpeg**.
3. After setup, the BAT file will start the PS1 script.  
4. Paste YouTube links when prompted — MP3s will be saved in your Downloads folder.
5. Next time, just run the BAT file to start downloading music again.

## License

This project is licensed under the [MIT License](LICENSE).
