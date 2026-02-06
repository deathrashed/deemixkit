---
title: "DeemixKit"
description: "Complete automation toolkit for resolving Spotify/Deezer albums and downloading via Deemix"
author: riley
category: [Audio, Music]
language: [Python, JavaScript, Bash, AppleScript]
path: ".//"
created: "23rd January, 2026"
tags:
  - toolkit
  - music
  - spotify
  - deezer
  - deemix
  - automation
  - download
---

# DeemixKit

## Overview

A comprehensive automation toolkit that bridges Spotify and Deezer with Deemix for seamless music downloading. Includes multiple interfaces (CLI, AppleScript dialogs, one-click workflows) to search for albums and automatically open them in Deemix. Supports both Spotify (with API authentication) and Deezer (free, no credentials), with standalone Python resolvers, integrated Bash wrappers, AppleScript applications, and a Node.js utility for currently playing tracks.

## Quick Start

### Search Spotify & Download

```bash
# Using Bash wrapper (auto-pastes into Deemix)
./spotify/spotify-to-deemix.sh "Metallica" "Master of Puppets"

# Using AppleScript dialog
osascript ./spotify/spotify-to-deemix.applescript

# Using Python resolver (clipboard only, no Deemix paste)
python3 ./spotify/spotify-resolver.py --band "Metallica" --album "Master of Puppets"
```

### Search Deezer & Download

```bash
# Using Bash wrapper (auto-pastes into Deemix)
./deezer/deezer-to-deemix.sh "Metallica" "Master of Puppets"

# Using AppleScript dialog
osascript ./deezer/deezer-to-deemix.applescript

# Using Python resolver (clipboard only, no Deemix paste)
python3 ./deezer/deezer-resolver.py --band "Metallica" --album "Master of Puppets"
```

### Download Currently Playing

```bash
node ./spotify/currently-playing-spotify-to-deemix.js
```

### Download Full Discography

```bash
# Using Bash wrapper (auto-pastes into Deemix)
./discography/discography-to-deemix.sh "America" "Ventura Highway"

# Using AppleScript dialog
osascript ./discography/discography-to-deemix.applescript

# Using Python resolver (URLs only, no Deemix paste)
python3 ./discography/discography-resolver.py --band "Radiohead" --album "OK Computer"
```

## Scripts in DeemixKit

### Python Resolvers

| Script | Purpose | Auth | Features |
|--------|---------|------|----------|
| `spotify-resolver.py` | Search Spotify API for albums | Required | Clipboard, logging, config file, retry logic |
| `deezer-resolver.py` | Search Deezer API for albums | None | Clipboard, logging, config file, retry logic |
| `discography-resolver.py` | Resolve full artist discography from Deezer | None | Artist disambiguation via album, outputs URLs to stdout |

**Key Differences**:
- Spotify requires Client ID/Secret in `~/.config/spotify-resolver/config.json`
- Deezer uses free public API - no credentials needed
- Both support: `--band` + `--album`, `--query`, stdin piping, interactive mode
- Both include `--verbose` and `--no-clipboard` options
- `discography-to-deemix.py` adds full discography support with artist disambiguation via album lookup

### Complete Workflows (CLI + GUI)

| Workflow | CLI (Bash) | GUI (AppleScript) | Includes |
|----------|-----------|-------------------|----------|
| **Spotify to Deemix** | `spotify-to-deemix.sh` | `spotify-to-deemix.applescript` | Single album resolution + auto-paste |
| **Deezer to Deemix** | `deezer-to-deemix.sh` | `deezer-to-deemix.applescript` | Single album resolution + auto-paste |
| **Discography to Deemix** | `discography-to-deemix.sh` | `discography-to-deemix.applescript` | Full discography + loop paste |

**Features**:
- **Bash wrappers**: Fast, scriptable, perfect for keyboard shortcuts and automation
- **AppleScript dialogs**: Native macOS UI, user-friendly, can be saved as standalone .app applications
- Both handle the complete workflow: resolve album(s) → copy to clipboard → open Deemix → auto-paste → submit

### Supporting Utilities

| Script | Purpose | Use Case |
|--------|---------|----------|
| `paste-to-deemix.applescript` | Pastes clipboard URL into Deemix | Called by bash wrappers and AppleScripts |
| `currently-playing-spotify-to-deemix.js` | One-click download of current track | Hotkey/command, no user input |
| `discography-resolver.py` | Resolve full artist discography | Outputs URLs to stdout |

## Directory Structure

```
DeemixKit/
├── spotify/                              # Spotify workflows
│   ├── spotify-resolver.py               # Python resolver
│   ├── spotify-to-deemix.sh              # CLI wrapper
│   ├── spotify-to-deemix.applescript     # GUI dialog
│   └── currently-playing-to-deemix.js    # Currently playing track
├── deezer/                               # Deezer workflows
│   ├── deezer-resolver.py                # Python resolver
│   ├── deezer-to-deemix.sh               # CLI wrapper
│   └── deezer-to-deemix.applescript      # GUI dialog
├── discography/                          # Discography workflow
│   ├── discography-resolver.py           # Python resolver
│   ├── discography-to-deemix.sh          # CLI wrapper
│   └── discography-to-deemix.applescript # GUI dialog
├── global/                               # Universal resolver
│   ├── global-resolver.py
│   ├── global-resolver.sh
│   └── global-resolver.applescript
├── playlist/                             # Playlist workflows
│   ├── playlist-downloader.py
│   ├── playlist-downloader.sh
│   └── rileys-playlist-resolver.py
├── batch/                                # Batch download
│   ├── batch-downloader.sh
│   ├── batch-downloader.applescript
│   └── albums.txt
├── scripts/                              # Utility scripts
│   ├── paste-to-deemix.applescript       # Shared paste utility
│   └── rileys-collection-matcher.py      # Fuzzy matching module
├── docs/                                 # Documentation
│   ├── CREDENTIALS.md
│   ├── AGENTS.md
│   ├── DeemixKit.md                      (This file)
│   ├── Keyboard Maestro DeemixKit.md
│   └── Shell Functions.md
├── macros/                               # Keyboard Maestro macro files
└── examples/                             # Example configurations
    └── credentials.json.example
```

## Workflow Comparison

### Manual Input Workflows

**CLI (Bash)**:
```
User Input (args) → Bash Script → Resolver → Clipboard → Paste Script → Deemix (automated)
```

**GUI (AppleScript)**:
```
Native Dialog → String Parse → Resolver → Clipboard → Paste Script → Deemix (automated)
```

### Automatic Workflows

**Currently Playing**:
```
Spotify (AppleScript) → API Search → Clipboard → Deemix (automated)
```

## Dependencies Summary

### Python
- `requests` library (for HTTP/API calls)
- `pyperclip` library (optional, falls back to pbcopy)
- Config files: `~/.config/spotify-resolver/config.json` (Spotify credentials only)

### Node.js
- No external packages (built-in `child_process` only)
- Node.js 14+ with ES module support

### Bash
- Standard shell utilities
- `python3`, `osascript`, `curl` in PATH

### AppleScript
- Standard macOS tools
- System Events for keyboard automation

## Common Tasks

### 1. Get Album Link Only (No Download)

```bash
# Spotify - copies URL to clipboard
python3 ./spotify/spotify-resolver.py --band "Metallica" --album "Master of Puppets"

# Deezer - copies URL to clipboard
python3 ./deezer/deezer-resolver.py --band "Metallica" --album "Master of Puppets"
```

### 2. Search & Download (Fastest)

```bash
# Spotify
./spotify/spotify-to-deemix.sh "Metallica" "Master of Puppets"

# Deezer
./deezer/deezer-to-deemix.sh "Metallica" "Master of Puppets"
```

### 3. Search & Download (User-Friendly Dialog)

```bash
# Spotify
osascript ./spotify/spotify-to-deemix.applescript

# Deezer
osascript ./deezer/deezer-to-deemix.applescript
```

### 4. Download Current Track

```bash
node ./spotify/currently-playing-spotify-to-deemix.js
```

### 5. Download Full Discography

```bash
# Bash wrapper (handles bands with same name like "America", "Boston")
./discography/discography-to-deemix.sh "America" "Ventura Highway"

# AppleScript dialog
osascript ./discography/discography-to-deemix.applescript

# Resolver only (get URLs without sending to Deemix)
python3 ./discography/discography-resolver.py -b "Radiohead" -a "OK Computer"
```

### 6. Use with Keyboard Maestro

See `Keyboard Maestro DeemixKit.md` for complete macro setup instructions.

**Quick Example - Shell Script Macro:**
```
Prompt user for: Artist, Album
Execute Shell: /path/to/DeemixKit/spotify/spotify-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
Display: "Album added to Deemix!"
```

**Alternative - Python Resolver + AppleScript:**
```
Prompt user for: Artist, Album
Execute Shell: python3 /path/to/DeemixKit/deezer/deezer-resolver.py --band "$KMVAR_Artist" --album "$KMVAR_Album"
Execute AppleScript: (paste-to-deemix logic)
Display: "Added to Deemix."
```

### 7. Use with Raycast

Create a script:
```bash
#!/bin/bash
osascript "/path/to/DeemixKit/spotify/spotify-to-deemix.applescript"
```

### 8. Save AppleScript as Dock App

```bash
# Using Script Editor (macOS native)
1. Open Script Editor
2. Copy content from Spotify to Deemix.applescript
3. Save as "Spotify to Deemix" with File Format: Application
4. Drag to Dock for one-click access
```

## Configuration

### Spotify (Required for Spotify scripts)

Create `~/.config/spotify-resolver/config.json`:
```json
{
  "client_id": "YOUR_CLIENT_ID",
  "client_secret": "YOUR_CLIENT_SECRET",
  "timeout": 10,
  "max_retries": 3,
  "default_market": "US"
}
```

**Get Spotify Credentials**:
1. Go to https://developer.spotify.com/dashboard
2. Create an app
3. Copy Client ID and Client Secret
4. Paste into config.json

### Deezer

No configuration needed - uses free public API

## Performance

| Operation | Time | Notes |
|-----------|------|-------|
| Spotify search | ~2-3s | Includes token fetch + API search |
| Deezer search | ~1-2s | No auth needed (faster) |
| Paste to Deemix | ~6-7s | Includes delays for app responsiveness |
| Currently playing | ~3-4s | Track fetch + album lookup |
| **CLI workflow** | **~10-12s** | Search + paste total |
| **GUI workflow** | **~12-14s** | Dialog overhead + search + paste |

## Troubleshooting

### "Spotify API credentials not configured" Error

**Cause**: Spotify credentials not in `~/.config/spotify-resolver/config.json`  
**Fix**: Create config file with your API credentials (see Configuration section)

### "Failed to resolve Spotify/Deezer link" Error

**Cause**: Invalid artist/album name or network issue  
**Fix**:
- Check spelling and try exact album title
- Verify network connection
- For Spotify, ensure credentials are valid

### AppleScript Hangs on First Run

**Cause**: System Events accessibility permission needed  
**Fix**: Grant permission when prompted, or manually in System Preferences → Security & Privacy → Accessibility

### Deemix Doesn't Open

**Cause**: Deemix not installed or not in standard location  
**Fix**: Install Deemix from https://deemix.app or check installation location

### "Failed to copy to clipboard"

**Cause**: Neither pyperclip nor pbcopy available  
**Fix**: Install pyperclip: `pip install pyperclip`

## Documentation Guide

Each script has comprehensive documentation. Choose the doc for your use case:

| Want to know about... | Read this doc |
|----------------------|---------------|
| Spotify search (CLI or GUI) | `Spotify to Deemix.md` |
| Deezer search (CLI or GUI) | `Deezer to Deemix.md` |
| Spotify resolver options | `Spotify Resolver.md` |
| Deezer resolver options | `Deezer Resolver.md` |
| Full discography download | `Discography to Deemix.md` |
| Paste automation | `Paste to Deemix.md` |
| Currently playing script | `Currently Playing Spotify to Deemix.md` |
| Keyboard Maestro macros | `Keyboard Maestro DeemixKit.md` |

## Security Notes

- **Spotify Credentials**: Currently hardcoded in `Currently Playing Spotify to Deemix.js`
  - For production, use environment variables
- **Clipboard**: Album URLs are short and safe
- **API Keys**: Spotify credentials in config file are read-only
- **No User Data**: Scripts don't store or transmit any personal user data

## Related Directories

- `/path/to/DeemixKit` - Location of this toolkit
- `~/.config/deemixkit/` - Unified credentials file
- `~/.config/spotify-resolver/` - Spotify resolver config
- `~/.config/deezer-resolver/` - Deezer resolver config
- `~/.local/log/spotify-resolver/` - Spotify resolver logs
- `~/.local/log/deezer-resolver/` - Deezer resolver logs
- `~/.local/log/discography-resolver/` - Discography resolver logs

## Version History

- **v1.1** (27 Jan 2026) - Discography support
  - Added `discography-resolver.py` - resolves full artist discography from Deezer
  - Added `discography-to-deemix.sh` - bash wrapper for CLI usage
  - Added `discography-to-deemix.applescript` - GUI dialog for discography
  - Uses album lookup to disambiguate artists with same name (e.g., "America", "Boston")
  - Follows same pattern as other resolvers (resolver.py + .sh + .applescript)

- **v1.0** (23 Jan 2026) - Initial DeemixKit release
  - 2 Python resolvers (Spotify, Deezer)
  - 2 Bash wrappers (Spotify, Deezer)
  - 3 AppleScript utilities (Spotify dialog, Deezer dialog, paste utility)
  - 1 Node.js script (currently playing)
  - Consolidated documentation (6 .md files)

## Feature Comparison

| Feature | Spotify | Deezer | Discography | Currently Playing |
|---------|---------|--------|-------------|-------------------|
| **No setup required** | ❌ | ✅ | ✅ | ❌ |
| **CLI interface** | ✅ | ✅ | ✅ | ❌ |
| **GUI interface** | ✅ | ✅ | ❌ | ❌ |
| **Auto-paste to Deemix** | ✅ | ✅ | ✅ | ✅ |
| **Full discography** | ❌ | ❌ | ✅ | ❌ |
| **Artist disambiguation** | ❌ | ❌ | ✅ | ❌ |
| **Dry run mode** | ❌ | ❌ | ✅ | ❌ |
| **One-click operation** | ❌ (with .app) | ❌ (with .app) | ❌ | ✅ |

## Future Enhancements

- [ ] Config file auto-generation
- [ ] Album art caching
- [ ] Playlist support
- [ ] Download progress notification
- [ ] Multiple platform support (Windows, Linux)
- [ ] GUI application wrapper
- [ ] Spotify Web API library integration
- [ ] Search history/favorites
