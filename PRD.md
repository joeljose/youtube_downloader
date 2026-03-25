# PRD: YouTube Downloader

## Problem Statement

yt-dlp is powerful but has a steep learning curve with hundreds of flags. Users who just want to download a video, extract audio, or record a live stream shouldn't need to remember arcane flag combinations.

**Who:** Developers / power users who want reliable YouTube downloads with a simple interface.

**Why now:** yt-dlp is the de facto standard but its CLI is complex. A thin wrapper with sensible defaults saves time on every use.

## User Stories

1. **As a user**, I want to download a YouTube video in the best available quality with a single command, so I don't have to figure out format codes.
2. **As a user**, I want to extract just the audio from a video as MP3, so I can listen offline.
3. **As a user**, I want to record a live stream, so I can watch it later.
4. **As a user**, I want to see available formats before downloading, so I can pick what I want.
5. **As a user**, I want to clone this repo on any machine and be ready to go, so there's zero setup friction.
6. **As a user**, I want to update yt-dlp easily, so downloads don't break when YouTube changes things.

## Proposed Solution

A self-contained repo with a yt-dlp binary and a thin shell wrapper script (`yt`) that translates simple commands into yt-dlp flags.

### Architecture

```
youtube_downloader/
├── setup.sh          # downloads yt-dlp binary, makes yt available
├── bin/
│   └── yt-dlp        # binary (gitignored, downloaded by setup.sh)
├── yt                # wrapper shell script
├── README.md
└── .gitignore
```

### Commands

| Command | What it does | yt-dlp equivalent |
|---------|-------------|-------------------|
| `yt download <url>` | Best video+audio, merged to mp4 | `yt-dlp -f "bv*+ba/b" --merge-output-format mp4` |
| `yt audio <url>` | Extract audio as MP3 | `yt-dlp -x --audio-format mp3` |
| `yt live <url>` | Record live stream | `yt-dlp --live-from-start --wait-for-video 5` |
| `yt info <url>` | Show available formats | `yt-dlp -F` |
| `yt update` | Update yt-dlp binary to latest | Re-downloads binary from GitHub releases |

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-o, --output <dir>` | Output directory | `./downloads` |
| `-f, --format <fmt>` | Quality preset: 720p, 1080p, 4k, best | `best` |
| `-v, --verbose` | Show full yt-dlp output | off |
| `--` | Pass remaining flags directly to yt-dlp | — |

### Prerequisites

- **ffmpeg** must be installed on the host system (required for merging formats and audio extraction)
- **curl** or **wget** for setup.sh to download the yt-dlp binary

## Key Decisions

### 1. No Docker
- yt-dlp is a single binary, ffmpeg is assumed present — Docker adds unnecessary startup overhead and volume mounting complexity for no real benefit.

### 2. Shell script wrapper (not Python CLI)
- Zero dependencies beyond bash. The logic is thin (flag translation) — yt-dlp does all the real work.
- Tradeoff: less testable, but the scope is small enough that this is acceptable.

### 3. Binary in repo (gitignored)
- `setup.sh` downloads the yt-dlp binary into `bin/`. The binary is gitignored so the repo stays small.
- `yt update` re-downloads the latest binary — critical because YouTube changes break old yt-dlp versions regularly.

### 4. Passthrough flags with `--`
- For advanced users who need raw yt-dlp flags (cookies, auth, etc.): `yt download <url> -- --cookies-from-browser chrome`
- Keeps the simple interface simple while not limiting power users.

## Scope

### v1 (MVP)
- `setup.sh` to download yt-dlp binary
- `yt` wrapper with `download`, `audio`, `live`, `info`, `update` commands
- Quality presets (720p, 1080p, 4k, best)
- Output directory flag
- Passthrough for raw yt-dlp flags
- README with usage examples

### Deferred
- Playlist / batch download support
- Progress bar / pretty output
- Config file for persistent defaults
- Subtitle download
- Shell completions

## Testing Plan

### Automated (CI)
- **setup.sh downloads a working binary** — run setup, check `bin/yt-dlp --version` exits 0
- **Shell script parses flags correctly** — test flag translation with bats or similar
- **Help output works** — `./yt --help` exits 0 with usage text
- **update command works** — run update, verify binary is refreshed
- **ffmpeg presence check** — wrapper should error clearly if ffmpeg is missing

### Manual verification
- Download a short public domain video
- Audio extraction produces valid MP3
- Live stream recording (test with a known live stream)
- Output file appears in correct directory
- Passthrough flags work (`--` syntax)

### Hard to test
- Actual YouTube downloads in CI (rate limiting, ToS) — use `--simulate` flag for CI
- Live stream availability is unpredictable — manual test only

## Open Questions

1. Should `setup.sh` also add `yt` to PATH (e.g., symlink to `~/.local/bin/`)? Or leave that to the user?
2. Do we need authentication support for private/age-restricted videos in v1, or is passthrough (`-- --cookies-from-browser`) enough?
