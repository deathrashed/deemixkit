---
title: "Discography to Deemix"
description: "Download an artist's full discography to Deemix using album lookup for disambiguation"
author: riley
category: [Audio, Music]
language: [Python, Bash, AppleScript]
path: ".//"
created: "27th January, 2026"
tags:
  - script
  - python
  - music
  - deezer
  - api
  - discography
  - automation
  - deemix
  - bulk-download
---

# Discography to Deemix

## Overview

A set of scripts that download an artist's complete discography to Deemix. Uses a known album to identify the correct artist among bands with the same name (e.g., multiple bands named "America" or "Boston"), then fetches their entire catalog (albums and EPs only, excluding singles) and copies all URLs to clipboard for pasting into Deemix.

## Scripts

| Script | Purpose |
|--------|---------|
| `discography-resolver.py` | Core Python resolver - outputs album URLs to stdout (albums + EPs only, excludes singles) |
| `discography-to-deemix.applescript` | GUI dialog + copies all URLs to clipboard |
| `discography-to-deemix.sh` | CLI wrapper - copies all URLs to clipboard |

## Features

- **Artist Disambiguation**: Uses album search to find the correct artist among duplicates
- **Deezer API Integration**: Free API, no authentication required
- **Smart Filtering**: Includes albums and EPs, excludes singles by default (can include with flag)
- **Bulk URL Copy**: Copies all album URLs to clipboard at once for pasting into Deemix
- **Multiple Interfaces**: CLI (bash), GUI (AppleScript dialog), or resolver-only
- **Multiple Input Methods**: CLI arguments, stdin piping, or interactive mode

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- `requests` - HTTP client for Deezer API calls

Installation:
```bash
pip install requests
```

**No API Credentials Required** - Deezer API is public

## Usage

### Using Bash Wrapper (CLI)

```bash
# Fast, scriptable, perfect for automation
.//discography-to-deemix.sh "Radiohead" "OK Computer"
.//discography-to-deemix.sh "America" "Ventura Highway"
```

### Using AppleScript Dialog (GUI)

```bash
# Native macOS dialog, user-friendly
osascript .//discography-to-deemix.applescript
```

### Using Python Resolver Only (URLs to stdout)

```bash
# Just get the URLs without sending to Deemix
python3 .//discography-resolver.py --band "Radiohead" --album "OK Computer"

# Piped input
echo "The Beatles - Abbey Road" | python3 .//discography-resolver.py

# Interactive mode
python3 .//discography-resolver.py
```

## Command Line Options (Resolver)

| Option | Short | Description |
|--------|-------|-------------|
| `--band` | `-b` | Band/artist name |
| `--album` | `-a` | Album name (used to identify correct artist) |
| `--include-singles` | | Include singles in results (default: albums + EPs only) |
| `--verbose` | `-v` | Enable verbose logging |
| `--config` | | Path to config file |

## How It Works

### Workflow

```
User Input (Band + Album) → Resolver → Deezer Album Search → Extract Artist ID →
Fetch Full Discography → Filter (albums + EPs only) → Output URLs → Copy to Clipboard → Paste into Deemix
```

### Bash Wrapper Flow
```
Arguments → discography-resolver.py → URLs (albums + EPs only) → Extract URLs from output → Copy all to clipboard
```

### AppleScript Flow
```
Dialog Input → discography-resolver.py → URLs (albums + EPs only) → Extract URLs → Copy all to clipboard → Notify user
```

## Examples

### Example 1: CLI Usage

```bash
.//discography-to-deemix.sh "Metallica" "Ride the Lightning"
```

Output:
```
Searching for: Metallica - Ride the Lightning
Found artist: Metallica
Fetching discography...
Found 25 unique albums (EPs + Albums only)
Found 25 albums. Copying to clipboard...
All 25 album URLs copied to clipboard!
Now paste into Deemix to download all albums.
```

All 25 album URLs are now in your clipboard, ready to paste into Deemix.

### Example 2: Resolver Only

```bash
python3 .//discography-resolver.py -b "Pink Floyd" -a "The Wall"
```

Output (URLs to stdout):
```
https://www.deezer.com/album/302127
https://www.deezer.com/album/302128
https://www.deezer.com/album/302129
...
```

### Example 3: GUI Dialog

```bash
osascript .//discography-to-deemix.applescript
```

Shows native macOS dialog asking for "Artist - Album", confirms album count, then copies all URLs to clipboard. A notification appears when complete.

## Configuration

Create `~/.config/discography-resolver/config.json` (optional):

```json
{
  "timeout": 10,
  "max_retries": 3,
  "retry_delay": 1,
  "log_level": "INFO",
  "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
}
```

## Notes

- **Always Provide Both Band and Album**: The album is required to find the correct artist among bands with the same name
- **Default Filtering Excludes Singles**: By default, only albums and EPs are included. Use `--include-singles` to include singles
- **Bulk Paste**: All URLs are copied to clipboard at once - paste into Deemix to download all albums simultaneously
- **Duplicate Handling**: Resolver automatically filters out duplicate album titles
- **Pagination**: Handles artists with large discographies (100+ albums) via API pagination
- **Status Output**: Resolver outputs status messages to stderr, URLs to stdout
- **Exit Codes**: Returns 0 on success, 1 on error, 130 on user interrupt (Ctrl+C)
- **Logging**: Logs saved to `~/.local/log/discography-resolver/discography-resolver.log`

## Related Scripts

- `deezer-resolver.py` - Single album resolver
- `deezer-to-deemix.sh` - Single album with auto-paste
- `spotify-resolver.py` - Spotify to Deezer resolver
- `spotify-to-deemix.sh` - Spotify to Deemix with auto-paste
