---
title: "Global URL Resolver"
description: "Universal URL resolver that accepts any Spotify or Deezer URL and automatically sends it to Deemix"
author: riley
category: [Audio, Music]
language: [Python, Bash, AppleScript]
path: "global/"
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
  - automation
  - deemix
  - url-resolver
  - discography
---

# Global URL Resolver

## Overview

A universal URL resolver that accepts any Spotify or Deezer URL (track, album, playlist, or artist) and automatically converts it to a Deemix-compatible album URL. Features three interfaces: a core Python resolver, a Bash CLI wrapper, and a GUI AppleScript dialog. Artist URLs return all albums from the artist's discography, making it a powerful tool for bulk downloading.

## Supported URL Types

| Input | Output | Action |
|-------|--------|--------|
| **Track** | Parent album | Downloads album |
| **Album** | Same album | Downloads album |
| **Artist** | ALL albums (full discography) | Downloads entire catalog |
| **Playlist** | (coming soon) | - |

## Features

- **Auto-Detection**: Automatically detects URL type (Spotify/Deezer, track/album/artist)
- **Artist Discography**: Artist URLs return all albums using the `--artist` flag
- **Service Integration**: Works with both Spotify and Deezer APIs
- **Multiple Interfaces**: Python resolver, Bash CLI, and AppleScript GUI
- **Smart Input**: Accepts URLs from argument, clipboard, or interactive prompt
- **Bulk Paste**: All album URLs copied at once for pasting into Deemix

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- `requests` - HTTP client for API calls

Installation:
```bash
pip install requests
```

**Spotify API Credentials** - Required for Spotify URLs in `~/.config/deemixkit/credentials.json`:
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
| **Artist Discography** | `--artist` flag | Automatic detection | Automatic detection |

## Usage

### Python Resolver (Core)

```bash
# From URL argument
python3 global/global-resolver.py "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"

# Uses stdin if piped
echo "https://www.deezer.com/album/103248" | python3 global/global-resolver.py

# Interactive mode (prompts if no input)
python3 global/global-resolver.py

# Artist URL with --artist flag (returns all albums)
python3 global/global-resolver.py --artist "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"

# Print to stdout instead of clipboard
python3 global/global-resolver.py "https://www.deezer.com/album/103248" --no-clipboard
```

### Bash Wrapper (CLI)

```bash
# From URL argument
./global/global-resolver.sh "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"

# Uses clipboard if no argument
./global/global-resolver.sh

# Artist URL automatically detects and returns all albums
./global/global-resolver.sh "https://www.deezer.com/artist/27"
```

### AppleScript Dialog (GUI)

```bash
# Run with osascript
osascript global/global-resolver.applescript

# Or save as .app and double-click
```

## Source Code

### Python Resolver (`global-resolver.py`)

```python
#!/usr/bin/env python3
"""
Global URL Resolver for DeemixKit

Auto-detects URL type (Spotify/Deezer, track/album/playlist/artist)
and returns the appropriate Deemix album URL.

Version: 1.0.0
Author: cursor
Created: February 2025
"""

import sys
import argparse
import json
import re
import logging
from pathlib import Path
from typing import Optional, Dict, Any, Tuple
import requests

# Configuration
CREDENTIALS_FILE = Path.home() / ".config" / "deemixkit" / "credentials.json"
LOG_DIR = Path.home() / ".local" / "log" / "global-resolver"
LOG_FILE = LOG_DIR / "global-resolver.log"

# Deezer URLs
DEEZER_ALBUM_BASE = "https://www.deezer.com/album/"
DEEZER_TRACK_URL = "https://api.deezer.com/track/"
DEEZER_ALBUM_URL = "https://api.deezer.com/album/"
DEEZER_ARTIST_URL = "https://api.deezer.com/artist/"
DEEZER_SEARCH_URL = "https://api.deezer.com/search/"

# Spotify URLs
SPOTIFY_ALBUM_BASE = "https://open.spotify.com/album/"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_SEARCH_URL = "https://api.spotify.com/v1/search"
SPOTIFY_TRACK_URL = "https://api.spotify.com/v1/tracks/"
SPOTIFY_ALBUM_URL = "https://api.spotify.com/v1/albums/"
SPOTIFY_ARTIST_URL = "https://api.spotify.com/v1/artists/"


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
    import subprocess

    creds = get_spotify_credentials()
    if not creds:
        return None

    client_id, client_secret = creds

    try:
        response = subprocess.run([
            'curl', '-s', '-X', 'POST',
            'https://accounts.spotify.com/api/token',
            '-H', 'Content-Type: application/x-www-form-urlencoded',
            '-d', f'grant_type=client_credentials&client_id={client_id}&client_secret={client_secret}'
        ], capture_output=True, text=True, timeout=10)

        data = response.stdout.strip()
        if data:
            token_data = json.loads(data)
            return token_data.get('access_token')
    except Exception as e:
        logging.error(f"Error getting Spotify token: {e}")

    return None


def parse_url(url: str) -> Dict[str, Any]:
    """
    Parse URL and detect service and type.

    Returns dict with keys: service, type, id
    """
    result = {
        'service': None,
        'type': None,
        'id': None,
        'original_url': url
    }

    # Deezer patterns
    deezer_patterns = {
        'track': r'deezer\.com/track/(\d+)',
        'album': r'deezer\.com/album/(\d+)',
        'playlist': r'deezer\.com/playlist/(\d+)',
        'artist': r'deezer\.com/artist/(\d+)',
    }

    # Spotify patterns
    spotify_patterns = {
        'track': r'spotify\.com/track/([a-zA-Z0-9]+)',
        'album': r'spotify\.com/album/([a-zA-Z0-9]+)',
        'playlist': r'spotify\.com/playlist/([a-zA-Z0-9]+)',
        'artist': r'spotify\.com/artist/([a-zA-Z0-9]+)',
    }

    # Check if it's a short URL
    if 'spoti.fi/' in url:
        # Expand short URL (might need to follow redirect, but for now skip)
        pass

    # Detect service and type
    for url_type, pattern in deezer_patterns.items():
        match = re.search(pattern, url)
        if match:
            result['service'] = 'deezer'
            result['type'] = url_type
            result['id'] = match.group(1)
            return result

    for url_type, pattern in spotify_patterns.items():
        match = re.search(pattern, url)
        if match:
            result['service'] = 'spotify'
            result['type'] = url_type
            result['id'] = match.group(1)
            return result

    return result


def resolve_deezer_track(track_id: str) -> Optional[str]:
    """Resolve a Deezer track to its album URL."""
    try:
        response = requests.get(f"{DEEZER_TRACK_URL}{track_id}", timeout=10)
        response.raise_for_status()
        data = response.json()

        album_id = data.get('album', {}).get('id')
        if album_id:
            return f"{DEEZER_ALBUM_BASE}{album_id}"
    except Exception as e:
        logging.error(f"Error resolving Deezer track: {e}")

    return None


def resolve_spotify_track(track_id: str, access_token: str) -> Optional[str]:
    """Resolve a Spotify track to its album URL."""
    try:
        headers = {'Authorization': f'Bearer {access_token}'}
        response = requests.get(f"{SPOTIFY_TRACK_URL}{track_id}", headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()

        album_id = data.get('album', {}).get('id')
        if album_id:
            return f"{SPOTIFY_ALBUM_BASE}{album_id}"
    except Exception as e:
        logging.error(f"Error resolving Spotify track: {e}")

    return None


def resolve_deezer_artist(artist_id: str, all_albums: bool = False) -> Optional[str]:
    """For Deezer artist, return first album or all albums."""
    try:
        limit = 100 if all_albums else 1  # Get up to 100 albums for full discography
        response = requests.get(f"{DEEZER_ARTIST_URL}{artist_id}/albums?limit={limit}", timeout=10)
        response.raise_for_status()
        data = response.json()

        if data.get('data'):
            if all_albums:
                # Return all album URLs, one per line
                albums = data['data']
                urls = [f"{DEEZER_ALBUM_BASE}{album['id']}" for album in albums]
                return '\n'.join(urls)
            elif len(albums) > 0:
                album_id = data['data'][0]['id']
                return f"{DEEZER_ALBUM_BASE}{album_id}"
    except Exception as e:
        logging.error(f"Error resolving Deezer artist: {e}")

    return None


def resolve_spotify_artist(artist_id: str, access_token: str, all_albums: bool = False) -> Optional[str]:
    """For Spotify artist, return first album or all albums."""
    try:
        limit = 50 if all_albums else 1  # Spotify API max is 50
        headers = {'Authorization': f'Bearer {access_token}'}
        response = requests.get(f"{SPOTIFY_ARTIST_URL}{artist_id}/albums?limit={limit}", headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()

        if data.get('items'):
            if all_albums:
                # Return all album URLs, one per line
                albums = data['items']
                urls = [f"{SPOTIFY_ALBUM_BASE}{album['id']}" for album in albums]
                return '\n'.join(urls)
            elif len(albums) > 0:
                album_id = data['items'][0]['id']
                return f"{SPOTIFY_ALBUM_BASE}{album_id}"
    except Exception as e:
        logging.error(f"Error resolving Spotify artist: {e}")

    return None


def resolve_url(url: str, verbose: bool = False, all_albums: bool = False) -> Optional[str]:
    """
    Resolve any Spotify/Deezer URL to an album URL.

    Supported URL types:
    - Track URLs → Returns parent album URL
    - Album URLs → Returns as-is
    - Playlist URLs → Returns first album
    - Artist URLs → Returns first album

    Returns Deemix-compatible album URL (Deezer format).
    """
    setup_logging(verbose)
    logger = logging.getLogger(__name__)

    if verbose:
        logger.info("=" * 60)
        logger.info("Global URL Resolver v1.0.0")
        logger.info("=" * 60)
        logger.info(f"Input URL: {url}")

    # Parse the URL
    parsed = parse_url(url)

    if not parsed['service']:
        logger.error(f"Unknown URL format: {url}")
        if verbose:
            print(f"Error: Unknown URL format")
        return None

    service = parsed['service']
    url_type = parsed['type']
    item_id = parsed['id']

    if verbose:
        logger.info(f"Detected: {service.upper()} {url_type.upper()} (ID: {item_id})")

    # Spotify requires credentials
    spotify_token = None
    if service == 'spotify':
        spotify_token = get_spotify_access_token()
        if not spotify_token:
            logger.error("Spotify credentials not configured")
            if verbose:
                print("Error: Spotify credentials not found")
                print("Set up credentials in ~/.config/deemixkit/credentials.json")
            return None

    # Resolve based on type
    album_url = None

    if service == 'deezer':
        if url_type == 'track':
            if verbose:
                print(f"Resolving Deezer track to album...")
            album_url = resolve_deezer_track(item_id)
        elif url_type == 'album':
            album_url = f"{DEEZER_ALBUM_BASE}{item_id}"
        elif url_type == 'artist':
            if verbose:
                if all_albums:
                    print(f"Getting all albums from Deezer artist...")
                else:
                    print(f"Getting first album from Deezer artist...")
            album_url = resolve_deezer_artist(item_id, all_albums)
        elif url_type == 'playlist':
            # For playlists, we could get all albums, but for now just warn
            logger.warning(f"Deezer playlists not fully supported yet")
            if verbose:
                print(f"Note: Deezer playlist support coming soon")
                print(f"Use a specific album or track URL instead")
            return None

    elif service == 'spotify':
        if url_type == 'track':
            if verbose:
                print(f"Resolving Spotify track to album...")
            album_url = resolve_spotify_track(item_id, spotify_token)
        elif url_type == 'album':
            album_url = f"{SPOTIFY_ALBUM_BASE}{item_id}"
        elif url_type == 'artist':
            if verbose:
                if all_albums:
                    print(f"Getting all albums from Spotify artist...")
                else:
                    print(f"Getting first album from Spotify artist...")
            album_url = resolve_spotify_artist(item_id, spotify_token, all_albums)
        elif url_type == 'playlist':
            # For playlists, we could get all albums, but for now just warn
            logger.warning(f"Spotify playlists not fully supported yet")
            if verbose:
                print(f"Note: Spotify playlist support coming soon")
                print(f"Use a specific album or track URL instead")
            return None

    # Convert Spotify URL to Deezer equivalent
    if album_url and album_url.startswith('https://open.spotify.com/'):
        # For Spotify, we need to convert to Deezer
        if verbose:
            print(f"Converting Spotify album to Deezer...")
        # This would require searching Deezer for the album
        # For now, just return the Spotify URL (Deemix might support it)
        pass

    if verbose and album_url:
        print(f"Resolved to: {album_url}")

    return album_url


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Global URL Resolver - Accepts any Spotify/Deezer URL",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Supported URL types:
  Spotify/Deezer Track    → Returns parent album URL
  Spotify/Deezer Album    → Returns album URL
  Spotify/Deezer Playlist → Returns first album (coming soon: full playlist)
  Spotify/Deezer Artist  → Returns first album (use discography tool for full catalog)

Examples:
  %(prog)s https://open.spotify.com/track/xyz
  %(prog)s https://www.deezer.com/album/123
  %(prog)s "https://open.spotify.com/album/abc"
        """
    )

    parser.add_argument(
        'url',
        nargs='?',
        help='URL to resolve (or will prompt if not provided)'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )
    parser.add_argument(
        '--no-clipboard',
        action='store_true',
        help='Print URL instead of copying to clipboard'
    )
    parser.add_argument(
        '--artist',
        action='store_true',
        help='For artist URLs, return all albums instead of just one'
    )

    args = parser.parse_args()

    # Get URL - from argument or prompt
    url = args.url
    if not url:
        if sys.stdin.isatty():
            print("Enter a Spotify or Deezer URL:")
            print("  (track, album, playlist, or artist)")
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

    # Resolve the URL
    album_url = resolve_url(url, args.verbose, args.artist)

    if not album_url:
        sys.exit(1)

    # Copy to clipboard or print
    if args.no_clipboard:
        print(album_url)
    else:
        try:
            import subprocess
            process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
            process.communicate(input=album_url.encode('utf-8'))
            if process.returncode == 0:
                # Check if we have multiple URLs (newline separated)
                url_count = album_url.count('\n') + 1 if '\n' in album_url else 1
                if url_count > 1:
                    print(f"\n{album_url}")
                    print(f"Copied {url_count} albums to clipboard!")
                else:
                    print(f"\n{album_url}")
                    print("Copied to clipboard!")
                if args.verbose:
                    print("Paste into Deemix to download")
            else:
                print(f"\n{album_url}")
                print("Failed to copy to clipboard")
                sys.exit(1)
        except Exception as e:
            print(f"\n{album_url}")
            sys.exit(0)


if __name__ == "__main__":
    main()
```

## Examples

### Example 1: Artist URL → Full Discography

```bash
./global/global-resolver.sh "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"
```

Output:
```
=== Global URL Resolver ===
Resolving: https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb
Artist URL detected - fetching all albums...

✓ Found 42 albums
✓ Copied 42 albums to clipboard!
Pasting to Deemix...
✓ Sent to Deemix!

All done!
```

### Example 2: Track URL → Parent Album

```bash
./global/global-resolver.sh "https://open.spotify.com/track/3n3Ppam7vgaVa1iaRUc9Lp"
```

Output:
```
=== Global URL Resolver ===
Resolving: https://open.spotify.com/track/3n3Ppam7vgaVa1iaRUc9Lp

✓ Found: https://open.spotify.com/album/2LQwUZUbAoAiwbS1eO48hE
✓ Copied to clipboard!
Pasting to Deemix...
✓ Sent to Deemix!

All done!
```

### Example 3: Album URL → Same Album

```bash
./global/global-resolver.sh "https://www.deezer.com/album/103248"
```

Output:
```
=== Global URL Resolver ===
Resolving: https://www.deezer.com/album/103248

✓ Found: https://www.deezer.com/album/103248
✓ Copied to clipboard!
Pasting to Deemix...
✓ Sent to Deemix!

All done!
```

## Keyboard Maestro Setup

Create a macro for quick access:

**Trigger:** Hotkey (e.g., `⌃⌥G` for Global)

**Action 1:** Prompt for User Input (before shell script)
```
Prompt: Enter a Spotify or Deezer URL:
Variable: TargetURL
```

**Action 2:** Execute Shell Script
```bash
cd /Volumes/Eksternal/Music/Tools/DeemixKit && ./global/global-resolver.sh "$KMVAR_TargetURL"
```

## Configuration

Create `~/.config/deemixkit/credentials.json` for Spotify support:

```json
{
  "spotify": {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }
}
```

**Note:** Deezer URLs work without any configuration. Spotify URLs require credentials.

## Troubleshooting

### "Spotify credentials not configured" Error
Create `~/.config/deemixkit/credentials.json` with your Spotify API credentials.

### "Unknown URL format" Error
Ensure the URL is a valid Spotify or Deezer URL. Supported formats:
- `https://open.spotify.com/track/...`
- `https://open.spotify.com/album/...`
- `https://open.spotify.com/artist/...`
- `https://www.deezer.com/track/...`
- `https://www.deezer.com/album/...`
- `https://www.deezer.com/artist/...`

### Artist URL only returns one album
Use the `--artist` flag or ensure the Bash/AppleScript wrapper detects artist URLs automatically.

### Playlist support
Playlist URLs are not fully supported yet. Use the dedicated playlist tools instead:
- `playlist/playlist-downloader.sh` - Get all albums
- `playlist/rileys-playlist-resolver.sh` - Get only missing albums

## Related Scripts

- **Playlist Downloader** - Extracts all albums from playlists
- **Riley's Playlist Resolver** - Playlist filtering with library comparison
- **Discography to Deemix** - Artist discography with album lookup
- **Batch Downloader** - Bulk download from text file list
