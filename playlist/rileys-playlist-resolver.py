#!/usr/bin/env python3
"""
Playlist to Deemix - Get only albums you don't have from a playlist

Uses spotify-kit's collection matcher for accurate deduplication.

Usage:
    python3 playlist-to-deemix.py "PLAYLIST_URL"
    python3 playlist-to-deemix.py --clipboard

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
        epilog="Example: python3 playlist-to-deemix.py https://www.deezer.com/playlist/123"
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
