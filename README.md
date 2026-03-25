# yt — simple YouTube downloader

A thin wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp) that replaces complex flags with simple commands.

## Quick Start

```bash
git clone https://github.com/joeljose/youtube_downloader.git
cd youtube_downloader
./setup.sh
./yt download https://youtube.com/watch?v=xxxxx
```

`setup.sh` downloads both **yt-dlp** and **deno** (required for YouTube JS extraction) into `bin/`. Nothing is installed system-wide.

## Prerequisites

- **ffmpeg** — required for merging formats and audio extraction
  ```bash
  # Ubuntu/Debian
  sudo apt install ffmpeg

  # macOS
  brew install ffmpeg
  ```
- **curl** or **wget** — for downloading binaries
- **unzip** — for extracting deno

## Commands

| Command | Description |
|---------|-------------|
| `yt download <url>` | Download video in best quality (mp4) |
| `yt audio <url>` | Extract audio as MP3 |
| `yt live <url>` | Record a live stream |
| `yt info <url>` | Show available formats |
| `yt update` | Update yt-dlp to latest version |

## Options

| Flag | Description | Default | Commands |
|------|-------------|---------|----------|
| `-o, --output <dir>` | Output directory | `./downloads` | all |
| `-f, --format <preset>` | Quality: `720p`, `1080p`, `4k`, `best` | `best` | download |
| `-t, --duration <secs>` | Recording duration in seconds | unlimited | live |
| `--no-audio` | Download video only, skip audio | off | download, live |
| `-v, --verbose` | Show full yt-dlp output | off | all |
| `--` | Pass remaining flags directly to yt-dlp | — | all |

## Examples

```bash
# Download in best quality
yt download https://youtube.com/watch?v=xxxxx

# Download in 720p
yt download https://youtube.com/watch?v=xxxxx -f 720p

# Download video only (no audio)
yt download https://youtube.com/watch?v=xxxxx --no-audio

# Extract audio as MP3
yt audio https://youtube.com/watch?v=xxxxx

# Save to custom directory
yt download https://youtube.com/watch?v=xxxxx -o ~/videos

# Record 10 minutes of a live stream (video only)
yt live https://youtube.com/watch?v=xxxxx -t 600 --no-audio

# Record a live stream indefinitely (Ctrl+C to stop)
yt live https://youtube.com/watch?v=xxxxx

# Check available formats before downloading
yt info https://youtube.com/watch?v=xxxxx

# Pass extra flags to yt-dlp
yt download https://youtube.com/watch?v=xxxxx -- --cookies-from-browser chrome

# Update yt-dlp when downloads break
yt update
```

## How it works

- `setup.sh` downloads **yt-dlp** and **deno** binaries into `bin/` (gitignored)
- `yt` is a shell script that translates simple commands into yt-dlp flags
- Live streams use **ffmpeg as the downloader** for clean duration limiting and proper file finalization
- Output filenames include a timestamp so re-downloading never overwrites

## Add to PATH

To use `yt` from anywhere:

```bash
# Add to your shell config (.bashrc, .zshrc, etc.)
export PATH="/path/to/youtube_downloader:$PATH"
```
