---
title: "Playlist Downloader"
description: "Extracts all albums from a Spotify or Deezer playlist and sends them to Deemix"
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
  - bulk-download
---

# Playlist Downloader

## Overview

A generic playlist tool that extracts **all albums** from a Spotify or Deezer playlist and sends them to Deemix for downloading. Perfect for public sharing or when you want everything from a playlist without filtering. Features three interfaces: Python resolver, Bash CLI wrapper, and AppleScript GUI dialog.

## Features

- **Universal Playlist Support**: Works with both Spotify and Deezer playlists
- **Complete Album Extraction**: Gets ALL albums from playlist (no filtering)
- **Duplicate Removal**: Automatically removes duplicate albums
- **Pagination Handling**: Handles large playlists with proper API pagination
- **Multiple Interfaces**: Python resolver, Bash CLI, and AppleScript GUI
- **Bulk Paste**: All album URLs copied at once for pasting into Deemix

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- `requests` - HTTP client for API calls

Installation:
```bash
pip install requests
```

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

## Interface Comparison

| Aspect | Python Resolver | Bash Wrapper | AppleScript GUI |
|--------|----------------|--------------|-----------------|
| **Invocation** | python3 script.py | ./script.sh | osascript script.applescript |
| **Input** | Argument, stdin, prompt | Argument, clipboard, prompt | Dialog, clipboard |
| **Feedback** | Console output | Colored terminal | Dialog alerts |
| **Best For** | Scripting, pipelines | Keyboard Maestro, terminal | One-off searches, Dock |

## Usage

### Python Resolver (Core)

```bash
# From URL argument
python3 playlist/playlist-downloader.py "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"

# Uses stdin if piped
echo "https://www.deezer.com/playlist/123456789" | python3 playlist/playlist-downloader.py

# Interactive mode (prompts if no input)
python3 playlist/playlist-downloader.py

# Verbose output
python3 playlist/playlist-downloader.py "https://open.spotify.com/playlist/..." --verbose

# Print to stdout instead of clipboard
python3 playlist/playlist-downloader.py "https://www.deezer.com/playlist/..." --no-clipboard
```

### Bash Wrapper (CLI)

```bash
# From URL argument
./playlist/playlist-downloader.sh "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"

# Uses clipboard if no argument
./playlist/playlist-downloader.sh
```

### AppleScript Dialog (GUI)

```bash
# Run with osascript
osascript playlist/playlist-downloader.applescript

# Or save as .app and double-click
```

## Source Code

### Python Resolver (`playlist-downloader.py`)

```python
#!/usr/bin/env python3
"""
Playlist Downloader for DeemixKit

Extracts all album URLs from a playlist and outputs them for Deemix.
Supports both Spotify and Deezer playlists.

Version: 1.0.0
Created: February 2025
"""

import sys
import argparse
import json
import re
import logging
import time
import base64
from pathlib import Path
from typing import Optional, Dict, Any, Tuple, Set, List
import requests

# Configuration
CREDENTIALS_FILE = Path.home() / ".config" / "deemixkit" / "credentials.json"
LOG_DIR = Path.home() / ".local" / "log" / "playlist-downloader"
LOG_FILE = LOG_DIR / "playlist-downloader.log"

# Deezer API
DEEZER_PLAYLIST_URL = "https://api.deezer.com/playlist/"
DEEZER_ALBUM_BASE = "https://www.deezer.com/album/"

# Spotify API
SPOTIFY_PLAYLIST_URL = "https://api.spotify.com/v1/playlists/"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_ALBUM_BASE = "https://open.spotify.com/album/"


def setup_logging(verbose: bool = False) -> None:
    """Set up logging configuration."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    level = logging.DEBUG if verbose else logging.INFO
    format_str = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

    handlers = [logging.FileHandler(LOG_FILE)]
    if verbose:
        handlers.append(logging.StreamHandler(sys.stderr))

    logging.basicConfig(
        level=level,
        format=format_str,
        handlers=handlers
    )


def get_spotify_credentials() -> Optional[Tuple[str, str]]:
    """Get Spotify credentials from config file."""
    if CREDENTIALS_FILE.exists():
        try:
            with open(CREDENTIALS_FILE, 'r') as f:
                config = json.load(f)
                if 'spotify' in config:
                    client_id = config['spotify'].get('client_id')
                    client_secret = config['spotify'].get('client_secret')
                    if client_id and client_secret:
                        return client_id, client_secret
        except (json.JSONDecodeError, IOError):
            pass
    return None


def get_spotify_access_token() -> Optional[str]:
    """Get Spotify API access token."""
    creds = get_spotify_credentials()
    if not creds:
        return None

    client_id, client_secret = creds

    try:
        auth_header = base64.b64encode(
            f'{client_id}:{client_secret}'.encode()
        ).decode('ascii')

        headers = {'Authorization': f'Basic {auth_header}'}
        data = {'grant_type': 'client_credentials'}

        response = requests.post(SPOTIFY_TOKEN_URL, data=data, headers=headers, timeout=10)
        response.raise_for_status()
        token_data = response.json()

        return token_data.get('access_token')
    except Exception as e:
        logging.error(f"Error getting Spotify token: {e}")
        return None


def extract_playlist_id(url: str, service: str) -> str:
    """Extract playlist ID from URL."""
    patterns = {
        'deezer': r'deezer\.com/playlist/(\d+)',
        'spotify': r'spotify\.com/playlist/([a-zA-Z0-9]+)'
    }

    pattern = patterns.get(service, '')
    match = re.search(pattern, url)
    if match:
        return match.group(1)

    raise ValueError(f"Could not extract {service} playlist ID from URL")


def get_deezer_playlist_albums(playlist_id: str, verbose: bool = False) -> Tuple[Set[str], str]:
    """Get all unique album URLs from a Deezer playlist."""
    albums = set()
    playlist_name = "Unknown Playlist"

    try:
        # Get playlist info
        response = requests.get(f"{DEEZER_PLAYLIST_URL}{playlist_id}?limit=1", timeout=10)
        response.raise_for_status()
        data = response.json()

        playlist_name = data.get('title', 'Unknown Playlist')

        # Get all tracks from playlist
        if verbose:
            print(f"Fetching tracks from Deezer playlist: {playlist_name}")

        # Deezer API pagination
        url = f"{DEEZER_PLAYLIST_URL}{playlist_id}/tracks"
        while url:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()

            if 'data' not in data:
                break

            for track in data['data']:
                if track.get('album'):
                    album_id = track['album'].get('id')
                    if album_id:
                        albums.add(f"{DEEZER_ALBUM_BASE}{album_id}")

            # Get next page
            url = data.get('next') if isinstance(data.get('next'), str) else None

            # Small delay to be respectful to the API
            if url:
                time.sleep(0.2)

    except Exception as e:
        logging.error(f"Error fetching Deezer playlist: {e}")
        if verbose:
            print(f"Error: {e}")

    return albums, playlist_name


def get_spotify_playlist_albums(playlist_id: str, verbose: bool = False) -> Tuple[Set[str], str]:
    """Get all unique album URLs from a Spotify playlist."""
    albums = set()
    playlist_name = "Unknown Playlist"

    access_token = get_spotify_access_token()
    if not access_token:
        if verbose:
            print("Error: Spotify credentials not configured")
            print("Set up credentials in ~/.config/deemixkit/credentials.json")
        return albums, playlist_name

    try:
        headers = {'Authorization': f'Bearer {access_token}'}

        # Get playlist info first
        response = requests.get(f"{SPOTIFY_PLAYLIST_URL}{playlist_id}", headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()

        playlist_name = data.get('name', 'Unknown Playlist')

        if verbose:
            print(f"Fetching tracks from Spotify playlist: {playlist_name}")

        # Get tracks with pagination
        url = f"{SPOTIFY_PLAYLIST_URL}{playlist_id}/tracks"
        while url:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()

            if 'items' not in data:
                break

            for item in data['items']:
                track = item.get('track')
                if track and track.get('album'):
                    album_id = track['album'].get('id')
                    if album_id:
                        albums.add(f"{SPOTIFY_ALBUM_BASE}{album_id}")

            # Get next page
            url = data.get('next')

            # Small delay to be respectful to the API
            if url:
                time.sleep(0.1)

    except Exception as e:
        logging.error(f"Error fetching Spotify playlist: {e}")
        if verbose:
            print(f"Error: {e}")

    return albums, playlist_name


def process_playlist(url: str, verbose: bool = False) -> Tuple[Set[str], str]:
    """Process a playlist URL and extract album URLs."""
    setup_logging(verbose)
    logger = logging.getLogger(__name__)

    if verbose:
        logger.info("=" * 60)
        logger.info("Playlist Downloader v1.0.0")
        logger.info("=" * 60)
        logger.info(f"Input URL: {url}")

    # Detect service
    if 'deezer.com/playlist/' in url:
        playlist_id = extract_playlist_id(url, 'deezer')
        albums, playlist_name = get_deezer_playlist_albums(playlist_id, verbose)
    elif 'spotify.com/playlist/' in url:
        playlist_id = extract_playlist_id(url, 'spotify')
        albums, playlist_name = get_spotify_playlist_albums(playlist_id, verbose)
    else:
        logger.error("Unknown playlist URL format")
        if verbose:
            print("Error: URL must be a Spotify or Deezer playlist URL")
        return set(), ""

    return albums, playlist_name


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Playlist Downloader - Extract album URLs from playlists",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M
  %(prog)s "https://www.deezer.com/playlist/123456789"
  %(prog)s https://open.spotify.com/playlist/abc123 --verbose
        """
    )

    parser.add_argument(
        'url',
        nargs='?',
        help='Playlist URL to process'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )
    parser.add_argument(
        '--no-clipboard',
        action='store_true',
        help='Print URLs instead of copying to clipboard'
    )

    args = parser.parse_args()

    # Get URL - from argument or prompt
    url = args.url
    if not url:
        if sys.stdin.isatty():
            print("Enter a Spotify or Deezer playlist URL:")
            url = input("> ").strip()
            if not url:
                print("No URL provided")
                sys.exit(1)
        else:
            # Read from stdin
            url = sys.stdin.read().strip()
            if not url:
                print("No URL provided")
                sys.exit(1)

    # Process playlist
    albums, playlist_name = process_playlist(url, args.verbose)

    if not albums:
        print("No albums found")
        sys.exit(1)

    # Sort albums for consistent output
    sorted_albums = sorted(albums)
    album_count = len(sorted_albums)

    if args.verbose:
        print(f"\nFound {album_count} unique albums in '{playlist_name}'")
        print("")

    # Copy to clipboard or print
    if args.no_clipboard:
        for album in sorted_albums:
            print(album)
    else:
        try:
            import subprocess
            # Join all URLs with newlines
            album_text = '\n'.join(sorted_albums)
            process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
            process.communicate(input=album_text.encode('utf-8'))
            if process.returncode == 0:
                if args.verbose:
                    for album in sorted_albums:
                        print(f"  {album}")
                    print("")
                print(f"Copied {album_count} album URLs to clipboard!")
                print("Paste into Deemix to download all albums.")
            else:
                for album in sorted_albums:
                    print(album)
                print("Failed to copy to clipboard")
                sys.exit(1)
        except Exception as e:
            for album in sorted_albums:
                print(album)
            sys.exit(0)


if __name__ == "__main__":
    main()
```

## Examples

### Example 1: Spotify Playlist

```bash
./playlist/playlist-downloader.sh "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"
```

Output:
```
=== Playlist Downloader ===
Processing playlist...

✓ Found 191 unique albums in playlist
✓ Copied 191 albums to clipboard!

Pasting to Deemix...
✓ Sent to Deemix!

All done!
```

### Example 2: Deezer Playlist

```bash
./playlist/playlist-downloader.sh "https://www.deezer.com/playlist/123456789"
```

Output:
```
=== Playlist Downloader ===
Processing playlist...

✓ Found 85 unique albums in playlist
✓ Copied 85 albums to clipboard!

Pasting to Deemix...
✓ Sent to Deemix!

All done!
```

### Example 3: From Clipboard

```bash
# Copy playlist URL to clipboard, then run:
./playlist/playlist-downloader.sh
```

Output:
```
Using playlist URL from clipboard: https://open.spotify.com/playlist/...

=== Playlist Downloader ===
Processing playlist...
...
```

## Keyboard Maestro Setup

Create a macro for quick access:

**Trigger:** Hotkey (e.g., `⌃⌥P` for Playlist)

**Action 1:** Prompt for User Input
```
Prompt: Enter a Spotify or Deezer playlist URL:
Variable: PlaylistURL
```

**Action 2:** Execute Shell Script
```bash
cd /Volumes/Eksternal/Music/Tools/DeemixKit && ./playlist/playlist-downloader.sh "$KMVAR_PlaylistURL"
```

## Configuration

Create `~/.config/deemixkit/credentials.json` for Spotify playlist support:

```json
{
  "spotify": {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }
}
```

**Note:** Deezer playlists work without any configuration. Spotify playlists require credentials.

## Troubleshooting

### "Spotify credentials not configured" Error
Create `~/.config/deemixkit/credentials.json` with your Spotify API credentials.

### "Invalid playlist URL format" Error
Ensure the URL is a valid Spotify or Deezer playlist URL:
- `https://open.spotify.com/playlist/...`
- `https://www.deezer.com/playlist/...`

### Private/Restricted Playlists
Spotify private playlists require proper API credentials. Some playlists may not be accessible via the public API.

### "No albums found" Error
This can happen if:
- The playlist is empty
- The playlist contains only tracks without albums
- The playlist ID is invalid

## Which Playlist Tool Should I Use?

| Use Case | Tool |
|----------|------|
| **Public sharing** | `playlist-downloader` - Get all albums |
| **Personal use** | `rileys-playlist-resolver` - Get only what you don't have |
| **New to DeemixKit** | `playlist-downloader` - Simpler, no setup needed |
| **Existing library owner** | `rileys-playlist-resolver` - Avoids duplicates |

## Related Scripts

- **Riley's Playlist Resolver** - Playlist filtering with library comparison (personal use)
- **Global URL Resolver** - Universal resolver for any URL type
- **Batch Downloader** - Bulk download from text file list
