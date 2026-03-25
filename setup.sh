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

# Verify yt-dlp
if "$YT_DLP" --version &>/dev/null; then
    echo "[ok] yt-dlp installed: $("$YT_DLP" --version)"
else
    echo "ERROR: yt-dlp binary failed to run."
    rm -f "$YT_DLP"
    exit 1
fi

# Download deno (required by yt-dlp for YouTube JS extraction)
DENO="$BIN_DIR/deno"
if [ -x "$DENO" ]; then
    echo "[ok] deno already installed: $("$DENO" --version 2>&1 | head -1)"
else
    echo "==> Downloading deno (required for YouTube extraction)..."
    local_os="$(uname -s)"
    local_arch="$(uname -m)"
    DENO_TARGET=""
    case "${local_os}-${local_arch}" in
        Linux-x86_64)   DENO_TARGET="x86_64-unknown-linux-gnu" ;;
        Linux-aarch64)  DENO_TARGET="aarch64-unknown-linux-gnu" ;;
        Darwin-x86_64)  DENO_TARGET="x86_64-apple-darwin" ;;
        Darwin-arm64)   DENO_TARGET="aarch64-apple-darwin" ;;
    esac

    if [ -n "$DENO_TARGET" ]; then
        DENO_URL="https://github.com/denoland/deno/releases/latest/download/deno-${DENO_TARGET}.zip"
        DENO_ZIP="$BIN_DIR/deno.zip"
        $DOWNLOAD "$DENO_ZIP" "$DENO_URL"
        unzip -o -q "$DENO_ZIP" -d "$BIN_DIR"
        rm -f "$DENO_ZIP"
        chmod +x "$DENO"
        if "$DENO" --version &>/dev/null; then
            echo "[ok] deno installed: $("$DENO" --version 2>&1 | head -1)"
        else
            echo "[WARN] deno binary failed to run — YouTube extraction may be limited."
        fi
    else
        echo "[WARN] Cannot download deno for ${local_os}-${local_arch} — YouTube extraction may be limited."
    fi
fi

echo ""
echo "==> Setup complete!"
echo "    Run: ./yt download <url>"
echo ""
echo "    To make 'yt' available everywhere, add to your PATH:"
echo "    export PATH=\"$REPO_DIR:\$PATH\""
