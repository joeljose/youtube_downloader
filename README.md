# yt — simple YouTube downloader

A thin wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp) that replaces complex flags with simple commands.

## Quick Start

```bash
git clone https://github.com/joeljose/youtube_downloader.git
cd youtube_downloader
./setup.sh
./yt download https://youtube.com/watch?v=xxxxx
```

## Prerequisites

- **ffmpeg** — required for merging formats and audio extraction
  ```bash
  # Ubuntu/Debian
  sudo apt install ffmpeg

  # macOS
  brew install ffmpeg
  ```
- **curl** or **wget** — for downloading the yt-dlp binary

## Commands

| Command | Description |
|---------|-------------|
| `yt download <url>` | Download video in best quality (mp4) |
| `yt audio <url>` | Extract audio as MP3 |
| `yt live <url>` | Record a live stream |
| `yt info <url>` | Show available formats |
| `yt update` | Update yt-dlp to latest version |

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `-o, --output <dir>` | Output directory | `./downloads` |
| `-f, --format <preset>` | Quality: `720p`, `1080p`, `4k`, `best` | `best` |
| `-v, --verbose` | Show full yt-dlp output | off |
| `--` | Pass remaining flags directly to yt-dlp | — |

## Examples

```bash
# Download in best quality
yt download https://youtube.com/watch?v=xxxxx

# Download in 720p
yt download https://youtube.com/watch?v=xxxxx -f 720p

# Extract audio
yt audio https://youtube.com/watch?v=xxxxx

# Save to custom directory
yt download https://youtube.com/watch?v=xxxxx -o ~/videos

# Record a live stream
yt live https://youtube.com/watch?v=xxxxx

# Check available formats
yt info https://youtube.com/watch?v=xxxxx

# Pass extra flags to yt-dlp
yt download https://youtube.com/watch?v=xxxxx -- --cookies-from-browser chrome

# Update yt-dlp when downloads break
yt update
```

## Add to PATH

To use `yt` from anywhere:

```bash
# Add to your shell config (.bashrc, .zshrc, etc.)
export PATH="/path/to/youtube_downloader:$PATH"
```
