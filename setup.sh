#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$REPO_DIR/bin"
YT_DLP="$BIN_DIR/yt-dlp"

# Detect OS and architecture
detect_platform() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux)
            case "$arch" in
                x86_64)  echo "yt-dlp_linux" ;;
                aarch64) echo "yt-dlp_linux_aarch64" ;;
                armv7l)  echo "yt-dlp_linux_armv7l" ;;
                *)       echo ""; return 1 ;;
            esac
            ;;
        Darwin)
            case "$arch" in
                x86_64)  echo "yt-dlp_macos" ;;
                arm64)   echo "yt-dlp_macos" ;;
                *)       echo ""; return 1 ;;
            esac
            ;;
        *)
            echo ""; return 1
            ;;
    esac
}

echo "==> Setting up youtube_downloader"

# Check for curl or wget
if command -v curl &>/dev/null; then
    DOWNLOAD="curl -fSL -o"
elif command -v wget &>/dev/null; then
    DOWNLOAD="wget -q -O"
else
    echo "ERROR: curl or wget required. Install one and re-run."
    exit 1
fi

# Check ffmpeg
if command -v ffmpeg &>/dev/null; then
    echo "[ok] ffmpeg found: $(ffmpeg -version 2>&1 | head -1)"
else
    echo "[WARN] ffmpeg not found — merging and audio extraction won't work."
    echo "       Install it: sudo apt install ffmpeg  (or brew install ffmpeg)"
fi

# Detect platform
BINARY_NAME="$(detect_platform)" || true
if [ -z "$BINARY_NAME" ]; then
    echo "ERROR: Unsupported platform: $(uname -s) $(uname -m)"
    exit 1
fi
echo "[ok] Platform: $(uname -s) $(uname -m) → $BINARY_NAME"

# Download yt-dlp
mkdir -p "$BIN_DIR"
RELEASE_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/$BINARY_NAME"
echo "==> Downloading yt-dlp from $RELEASE_URL"
$DOWNLOAD "$YT_DLP" "$RELEASE_URL"
chmod +x "$YT_DLP"

# Verify
if "$YT_DLP" --version &>/dev/null; then
    echo "[ok] yt-dlp installed: $("$YT_DLP" --version)"
else
    echo "ERROR: yt-dlp binary failed to run."
    rm -f "$YT_DLP"
    exit 1
fi

echo ""
echo "==> Setup complete!"
echo "    Run: ./yt download <url>"
echo ""
echo "    To make 'yt' available everywhere, add to your PATH:"
echo "    export PATH=\"$REPO_DIR:\$PATH\""
