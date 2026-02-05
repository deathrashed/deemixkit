# Scripts - Utility Scripts for DeemixKit

This folder contains utility scripts that work with the main DeemixKit tools.

## Playlist to Deemix

**The main utility script** - Get only the albums you **don't** already own from a playlist.

**What it does:**
1. Takes a playlist URL (Spotify or Deezer)
2. Extracts all album URLs from the playlist (full albums only, no singles)
3. Compares against your local music collection using CollectionMatcher
4. Copies **only missing albums** to clipboard for Deemix

**Usage:**
```bash
# From URL
./scripts/playlist-to-deemix.sh "https://www.deezer.com/playlist/123"

# Uses clipboard if no argument
./scripts/playlist-to-deemix.sh

# Verbose mode (shows which albums you have/need)
python3 scripts/playlist-to-deemix.py "URL" --verbose
```

**Output:**
```
Scanning collection...
Found 14158 albums in collection from 7561 artists

Fetching playlist albums...
Found 191 unique albums in playlist

Summary: 25 new, 166 already owned

Copied 25 album URLs to clipboard!
Paste into Deemix to download.
```

**Perfect for:** Found a great playlist? Run this script and only download the albums you don't already have.

**Requirements:**
- **CollectionMatcher** at `scripts/rileys-collection-matcher.py`
- **Spotify credentials** at `~/.config/deemixkit/credentials.json` (for Spotify playlists)
- **Deezer** works without credentials

**Documentation:**
- **[Riley's Collection Matcher Documentation](docs/Riley's%20Collection%20Matcher.md)** - Full documentation with source code

## paste-to-deemix.applescript

Utility script that pastes clipboard content to the Deemix application. Used by all the downloader tools.

**Not meant to be run directly** - it's called automatically by the downloader scripts.
