---
title: "Riley's Playlist Resolver"
description: "Extracts albums from playlists and filters out ones you already own using collection matching"
author: riley
category: [Audio, Music]
language: [Python, Bash, AppleScript]
path: "playlist/"
created: "3rd February, 2026"
tags:
  - script
  - python
  - bash
  - applescript
  - music
  - spotify
  - deezer
  - api
  - playlist
  - automation
  - deemix
  - collection-matching
  - deduplication
---

# Riley's Playlist Resolver

## Overview

A personalized playlist tool that extracts albums from a Spotify or Deezer playlist, **filters out albums you already own**, and sends only the missing albums to Deemix. Uses sophisticated fuzzy matching to compare against your local music collection (14,000+ albums) to avoid downloading duplicates. Perfect for personal use when building an existing library.

## Features

- **Smart Filtering**: Compares playlist against your local music collection
- **Fuzzy Matching**: Uses advanced text normalization and fuzzy matching algorithms
- **Full Albums Only**: Filters to full albums only (no singles/EPs)
- **Collection Scanning**: Scans `/Volumes/Eksternal/Audio` with genre/letter/artist/album structure
- **Detailed Summary**: Shows "X new, Y already owned" breakdown
- **Multiple Interfaces**: Python resolver, Bash CLI, and AppleScript GUI

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- `requests` - HTTP client for API calls

Installation:
```bash
pip install requests
```

**Required Files**:
- `scripts/rileys-collection-matcher.py` - Collection matching module
- Collection at `/Volumes/Eksternal/Audio` with structure: `Genre/Letter/Artist/Album/`

**Spotify API Credentials** - Required for Spotify playlists in `~/.config/deemixkit/credentials.json`:
```json
{
  "spotify": {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }
}
```

**Deezer** - No credentials required (public API)

## Collection Structure

The script expects your collection to be organized as:
```
/Volumes/Eksternal/Audio/
├── Rock/
│   ├── M/
│   │   ├── Metallica/
│   │   │   ├── 1986 - Master of Puppets/
│   │   │   └── 1988 - ...And Justice for All/
│   │   └── Megadeth/
│   └── P/
│       └── Pink Floyd/
└── Hip-Hop/
    ├── E/
    │   └── Eminem/
    └── A/
        └── A Tribe Called Quest/
```

Album folders should be named `YYYY - Album Name` or just `Album Name`.

## Usage

### Python Resolver (Core)

```bash
# From URL argument
python3 playlist/rileys-playlist-resolver.py "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"

# Verbose mode shows details
python3 playlist/rileys-playlist-resolver.py "https://..." --verbose

# Use clipboard
python3 playlist/rileys-playlist-resolver.py --clipboard
```

### Bash Wrapper (CLI)

```bash
# From URL argument
./playlist/rileys-playlist-resolver.sh "https://open.spotify.com/playlist/..."

# Uses clipboard if no argument
./playlist/rileys-playlist-resolver.sh
```

### AppleScript Dialog (GUI)

```bash
# Run with osascript
osascript playlist/rileys-playlist-resolver.applescript

# Or save as .app and double-click
```

## Source Code

### Python Resolver (`rileys-playlist-resolver.py`)

```python
#!/usr/bin/env python3
"""
Playlist to Deemix - Get only albums you don't have from a playlist

Uses spotify-kit's collection matcher for accurate deduplication.

Usage:
    python3 rileys-playlist-resolver.py "PLAYLIST_URL"
    python3 rileys-playlist-resolver.py --clipboard

Version: 2.0.0
Created: February 2025
"""

import sys
import argparse
import json
import re
import time
import base64
from pathlib import Path
from typing import Set, Tuple, Optional, Dict, List
import subprocess

# Load collection matcher from file with dashes in name
import importlib.util
DEEMIXKIT = Path("/Volumes/Eksternal/Music/Tools/DeemixKit")
matcher_file = DEEMIXKIT / "scripts" / "rileys-collection-matcher.py"

try:
    spec = importlib.util.spec_from_file_location("rileys_collection_matcher", matcher_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    CollectionMatcher = module.CollectionMatcher
except Exception as e:
    print(f"Error loading collection matcher: {e}", file=sys.stderr)
    print(f"Expected at: {matcher_file}", file=sys.stderr)
    sys.exit(1)

# APIs
SPOTIFY_PLAYLIST_API = "https://api.spotify.com/v1/playlists/"
SPOTIFY_TOKEN_API = "https://accounts.spotify.com/api/token"
DEEZER_PLAYLIST_API = "https://api.deezer.com/playlist/"

# Credentials
CREDS_FILE = Path.home() / ".config" / "deemixkit" / "credentials.json"


def get_spotify_token() -> Optional[str]:
    """Get Spotify API token using subprocess curl."""
    if not CREDS_FILE.exists():
        return None

    try:
        with open(CREDS_FILE, 'r') as f:
            config = json.load(f)
            if 'spotify' in config:
                client_id = config['spotify'].get('client_id')
                client_secret = config['spotify'].get('client_secret')
                if client_id and client_secret:
                    result = subprocess.run([
                        'curl', '-s', '-X', 'POST',
                        'https://accounts.spotify.com/api/token',
                        '-H', 'Content-Type: application/x-www-form-urlencoded',
                        '-d', f'grant_type=client_credentials&client_id={client_id}&client_secret={client_secret}'
                    ], capture_output=True, text=True, timeout=10)

                    if result.returncode == 0 and result.stdout:
                        token_data = json.loads(result.stdout)
                        return token_data.get('access_token')
    except Exception as e:
        print(f"Error getting Spotify token: {e}", file=sys.stderr)

    return None


def extract_playlist_id(url: str, service: str) -> str:
    """Extract playlist ID from URL."""
    patterns = {
        'deezer': r'deezer\.com/playlist/(\d+)',
        'spotify': r'spotify\.com/playlist/([a-zA-Z0-9]+)'
    }
    match = re.search(patterns[service], url)
    if match:
        return match.group(1)
    raise ValueError(f"Could not extract {service} playlist ID")


def get_deezer_playlist_albums(playlist_id: str) -> List[Dict]:
    """Get albums from Deezer playlist. Returns list of album dicts."""
    albums = []
    import requests

    try:
        url = f"{DEEZER_PLAYLIST_API}{playlist_id}/tracks"
        while url:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()

            for track in data.get('data', []):
                if track.get('album'):
                    album = track['album']
                    album_id = album.get('id')
                    if album_id:
                        albums.append({
                            'url': f"https://www.deezer.com/album/{album_id}",
                            'artist': track.get('artist', {}).get('name', ''),
                            'album': album.get('name', ''),
                            'id': str(album_id)
                        })

            url = data.get('next')
            if url:
                time.sleep(0.2)
    except Exception as e:
        print(f"Error fetching Deezer playlist: {e}", file=sys.stderr)

    return albums


def get_spotify_playlist_albums(playlist_id: str) -> List[Dict]:
    """Get albums from Spotify playlist. Returns list of album dicts."""
    albums = []
    token = get_spotify_token()
    if not token:
        print("Spotify credentials not configured", file=sys.stderr)
        return albums

    try:
        headers = {'Authorization': f'Bearer {token}'}
        url = f"{SPOTIFY_PLAYLIST_API}{playlist_id}/tracks"

        while url:
            response = subprocess.run([
                'curl', '-s', url,
                '-H', f'Authorization: Bearer {token}'
            ], capture_output=True, text=True, timeout=10)

            if response.returncode != 0:
                break

            data = json.loads(response.stdout)

            for item in data.get('items', []):
                track = item.get('track')
                if track and track.get('album'):
                    album = track['album']
                    # Filter to only full albums, exclude singles/compilations
                    if album.get('album_type') != 'album':
                        continue
                    album_id = album.get('id')
                    if album_id:
                        artist = ', '.join([a.get('name', '') for a in track.get('artists', [])])
                        albums.append({
                            'url': f"https://open.spotify.com/album/{album_id}",
                            'artist': artist,
                            'album': album.get('name', ''),
                            'id': album_id
                        })

            # Get next page
            next_url = data.get('next')
            url = next_url if next_url else None
            if url:
                time.sleep(0.1)

    except Exception as e:
        print(f"Error fetching Spotify playlist: {e}", file=sys.stderr)

    return albums


def main():
    parser = argparse.ArgumentParser(
        description="Get albums from playlist that you don't own",
        epilog="Example: python3 rileys-playlist-resolver.py https://www.deezer.com/playlist/123"
    )
    parser.add_argument('url', nargs='?', help='Playlist URL')
    parser.add_argument('--clipboard', action='store_true', help='Use URL from clipboard')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show details')

    args = parser.parse_args()

    # Get URL
    url = args.url
    if args.clipboard:
        result = subprocess.run(['pbpaste'], capture_output=True, text=True)
        url = result.stdout.strip()

    if not url:
        if sys.stdin.isatty():
            url = input("Enter playlist URL: ").strip()
        else:
            url = sys.stdin.read().strip()

    if not url:
        print("No URL provided")
        sys.exit(1)

    # Initialize collection matcher (this scans your library)
    print(f"Scanning collection...")
    matcher = CollectionMatcher()
    stats = matcher.get_collection_stats()
    print(f"Indexed {stats['total_albums']} albums from {stats['total_artists']} artists")
    print()

    # Extract albums from playlist
    print("Fetching playlist albums...")
    if 'deezer.com/playlist/' in url:
        playlist_id = extract_playlist_id(url, 'deezer')
        albums = get_deezer_playlist_albums(playlist_id)
    elif 'spotify.com/playlist/' in url:
        playlist_id = extract_playlist_id(url, 'spotify')
        albums = get_spotify_playlist_albums(playlist_id)
    else:
        print("Invalid playlist URL")
        sys.exit(1)

    if not albums:
        print("No albums found in playlist")
        sys.exit(1)

    print(f"Found {len(albums)} unique albums in playlist")
    print()

    # Filter using collection matcher
    new_albums, existing_albums = matcher.filter_existing_albums(albums)

    if args.verbose:
        print("=== Already in Collection ===")
        for album in existing_albums[:10]:
            print(f"  ✓ {album['artist']} - {album['album']}")
        if len(existing_albums) > 10:
            print(f"  ... and {len(existing_albums) - 10} more")

        print("\n=== Missing from Collection ===")
        for album in new_albums[:10]:
            print(f"  ✗ {album['artist']} - {album['album']}")
        if len(new_albums) > 10:
            print(f"  ... and {len(new_albums) - 10} more")

    print()
    print(f"Summary: {len(new_albums)} new, {len(existing_albums)} already owned")

    if new_albums:
        # Copy to clipboard
        album_urls = [album['url'] for album in new_albums]
        album_text = '\n'.join(album_urls)
        process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
        process.communicate(input=album_text.encode('utf-8'))

        print(f"\nCopied {len(new_albums)} album URLs to clipboard!")
        print("Paste into Deemix to download.")

    sys.exit(0 if not new_albums else 1)


if __name__ == "__main__":
    main()
```

## Examples

### Example 1: Spotify Playlist with Library Comparison

```bash
./playlist/rileys-playlist-resolver.sh "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"
```

Output:
```
Scanning collection...
Indexed 14158 albums from 7561 artists

Fetching playlist albums...
Found 191 unique albums in playlist

Summary: 25 new, 166 already owned

Copied 25 album URLs to clipboard!
Paste into Deemix to download.
```

### Example 2: Verbose Mode with Details

```bash
python3 playlist/rileys-playlist-resolver.py "https://..." --verbose
```

Output:
```
Scanning collection...
Indexed 14158 albums from 7561 artists

Fetching playlist albums...
Found 191 unique albums in playlist

=== Already in Collection ===
  ✓ Metallica - Master of Puppets
  ✓ Pink Floyd - The Dark Side of the Moon
  ✓ Radiohead - OK Computer
  ... and 163 more

=== Missing from Collection ===
  ✗ Daft Punk - Random Access Memories
  ✗ Tame Impala - Currents
  ✗ Kendrick Lamar - To Pimp a Butterfly
  ... and 22 more

Summary: 25 new, 166 already owned

Copied 25 album URLs to clipboard!
Paste into Deemix to download.
```

### Example 3: Using Clipboard

```bash
# Copy playlist URL to clipboard, then run:
python3 playlist/rileys-playlist-resolver.py --clipboard
```

## Fuzzy Matching Algorithm

The collection matcher uses sophisticated text normalization:

1. **Text Normalization**:
   - Converts to lowercase
   - Removes diacritics/accents (é → e, ø → o)
   - Removes edition keywords: "Remastered", "Deluxe", "Anniversary", etc.
   - Removes parenthetical content: "(Deluxe Edition)", "[Remastered]"
   - Removes articles at start: "The", "A", "An"
   - Removes special characters and extra whitespace

2. **Fuzzy Matching**:
   - Levenshtein distance calculation
   - Substring matching for plurals and variations
   - 85% similarity threshold for albums
   - 90% similarity threshold for artists

3. **Example Matches**:
   - "The Dark Side of the Moon" matches "Dark Side of the Moon"
   - "Master of Puppets (Remastered)" matches "Master of Puppets"
   - "Random Access Memories (Deluxe)" matches "Random Access Memories"

## Keyboard Maestro Setup

Create a macro for quick access:

**Trigger:** Hotkey (e.g., `⌃⌥R` for Riley's Playlist)

**Action 1:** Prompt for User Input
```
Prompt: Enter a Spotify or Deezer playlist URL:
Variable: PlaylistURL
```

**Action 2:** Execute Shell Script
```bash
cd /Volumes/Eksternal/Music/Tools/DeemixKit && ./playlist/rileys-playlist-resolver.sh "$KMVAR_PlaylistURL"
```

## Configuration

### Required: Collection Matcher

The script requires `scripts/rileys-collection-matcher.py` in the DeemixKit directory.

### Required: Spotify Credentials

Create `~/.config/deemixkit/credentials.json`:

```json
{
  "spotify": {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }
}
```

### Optional: Custom Collection Path

Edit `rileys-collection-matcher.py` to change the default collection path:

```python
def __init__(self, collection_path: str = "/Volumes/Eksternal/Audio"):
```

## Troubleshooting

### "Error loading collection matcher"
Ensure `scripts/rileys-collection-matcher.py` exists in the DeemixKit directory.

### "Collection path does not exist"
Verify your collection path is correct in `rileys-collection-matcher.py`. The default is `/Volumes/Eksternal/Audio`.

### "Spotify credentials not configured"
Create `~/.config/deemixkit/credentials.json` with your Spotify API credentials.

### Albums not matching correctly
The fuzzy matching may need adjustment. Try:
- Check folder naming matches expected format
- Use verbose mode to see what's being matched
- Edit normalization rules in `rileys-collection-matcher.py`

### Large collections take time to scan
The collection is indexed once on startup. For very large collections (10,000+ albums), this may take 10-30 seconds.

## Which Playlist Tool Should I Use?

| Use Case | Tool |
|----------|------|
| **Personal use with existing library** | `rileys-playlist-resolver` - Avoid duplicates |
| **Public sharing** | `playlist-downloader` - Get all albums |
| **New to DeemixKit** | `playlist-downloader` - Simpler setup |
| **Large library owner** | `rileys-playlist-resolver` - Saves time/bandwidth |

## Related Scripts

- **Playlist Downloader** - Generic playlist tool (gets all albums)
- **Riley's Collection Matcher** - Core fuzzy matching module
- **Global URL Resolver** - Universal resolver for any URL type
- **Batch Downloader** - Bulk download from text file list
