#!/usr/bin/env python3
"""
Discography Resolver

Resolves an artist's full discography from Deezer.
Uses a known album to identify the correct artist among duplicates.
Outputs all album URLs to stdout (one per line).

Version: 1.0.0
Created: January 27th, 2026
"""

import sys
import json
import logging
import argparse
import subprocess
import time
from pathlib import Path
from typing import Optional, Dict, Any, List
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Try to import clipboard functionality
try:
    import pyperclip
    CLIPBOARD_AVAILABLE = True
except ImportError:
    CLIPBOARD_AVAILABLE = False

# Configuration
CONFIG_DIR = Path.home() / ".config" / "discography-resolver"
CONFIG_FILE = CONFIG_DIR / "config.json"
LOG_DIR = Path.home() / ".local" / "log" / "discography-resolver"
LOG_FILE = LOG_DIR / "discography-resolver.log"

# Deezer API endpoints
DEEZER_SEARCH_ALBUM_URL = "https://api.deezer.com/search/album"
DEEZER_ARTIST_ALBUMS_URL = "https://api.deezer.com/artist/{artist_id}/albums"
DEEZER_ALBUM_BASE = "https://www.deezer.com/album/"


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


def load_config(config_file: Optional[Path] = None) -> Dict[str, Any]:
    """Load configuration from file, creating default if missing."""
    default_config = {
        "timeout": 10,
        "max_retries": 3,
        "retry_delay": 1,
        "log_level": "INFO",
        "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }

    config_path = config_file if config_file else CONFIG_FILE
    if config_path.exists():
        try:
            with open(config_path, 'r') as f:
                user_config = json.load(f)
                default_config.update(user_config)
        except (json.JSONDecodeError, IOError) as e:
            logging.warning(f"Error loading config: {e}. Using defaults.")

    return default_config


def create_session(config: Dict[str, Any]) -> requests.Session:
    """Create a requests session with retry strategy."""
    session = requests.Session()

    retry_strategy = Retry(
        total=config.get("max_retries", 3),
        backoff_factor=config.get("retry_delay", 1),
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"]
    )

    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    session.headers.update({
        'User-Agent': config.get("user_agent", "Discography-Resolver/1.0"),
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9'
    })

    return session


def search_album(session: requests.Session, band: str, album: str, config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Search for a specific album to find the artist."""
    query = f"{band} {album}"
    try:
        logging.info(f"Searching for album: {query}")
        response = session.get(
            DEEZER_SEARCH_ALBUM_URL,
            params={'q': query, 'limit': 20},
            timeout=config.get("timeout", 10)
        )
        response.raise_for_status()
        data = response.json()
        albums = data.get('data', [])

        if not albums:
            logging.warning(f"No album found for: {query}")
            return None

        return albums[0]

    except requests.exceptions.Timeout:
        logging.error("Request timed out while searching Deezer")
        return None
    except requests.exceptions.RequestException as e:
        logging.error(f"Network error searching Deezer: {e}")
        return None
    except (KeyError, json.JSONDecodeError) as e:
        logging.error(f"Error parsing Deezer response: {e}")
        return None


def get_artist_discography(session: requests.Session, artist_id: int, config: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Get all albums for an artist."""
    albums = []
    url = DEEZER_ARTIST_ALBUMS_URL.format(artist_id=artist_id)

    try:
        while url:
            logging.debug(f"Fetching albums from: {url}")
            response = session.get(url, params={'limit': 100}, timeout=config.get("timeout", 10))
            response.raise_for_status()
            data = response.json()

            albums.extend(data.get('data', []))
            url = data.get('next')

            if url:
                time.sleep(0.3)

        logging.info(f"Found {len(albums)} albums in discography")
        return albums

    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching discography: {e}")
        return albums


def filter_albums(albums: List[Dict[str, Any]], include_singles: bool = False) -> List[Dict[str, Any]]:
    """Filter albums by record type (album and EP only, exclude singles by default)."""
    if include_singles:
        return albums
    
    filtered = []
    for alb in albums:
        record_type = alb.get('record_type', '').lower()
        # Include albums and EPs, exclude singles
        if record_type in ['album', 'ep']:
            filtered.append(alb)
        elif record_type == 'single':
            logging.debug(f"Excluding single: {alb.get('title', 'Unknown')}")
    
    return filtered


def build_album_url(album_id: int) -> str:
    """Build Deezer album URL."""
    return f"{DEEZER_ALBUM_BASE}{album_id}"


def parse_input(args: argparse.Namespace) -> tuple:
    """Parse input from arguments or prompt user."""
    if args.band and args.album:
        return args.band, args.album
    else:
        if sys.stdin.isatty():
            print("Enter band and album name:", file=sys.stderr)
            print("Format: 'Band Name - Album Name'", file=sys.stderr)
            user_input = input("> ").strip()
            if not user_input:
                logging.error("No input provided")
                sys.exit(1)

            if " - " in user_input:
                parts = user_input.split(" - ", 1)
                return parts[0].strip(), parts[1].strip()
            else:
                print("Error: Please use format 'Band Name - Album Name'", file=sys.stderr)
                sys.exit(1)
        else:
            user_input = sys.stdin.read().strip()
            if not user_input:
                logging.error("No input from stdin")
                sys.exit(1)
            if " - " in user_input:
                parts = user_input.split(" - ", 1)
                return parts[0].strip(), parts[1].strip()
            else:
                print("Error: Please use format 'Band Name - Album Name'", file=sys.stderr)
                sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Resolve an artist's full discography from Deezer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --band "Radiohead" --album "OK Computer"
  %(prog)s -b "America" -a "Ventura Highway"
  echo "The Beatles - Abbey Road" | %(prog)s
  %(prog)s  # Interactive mode
        """
    )

    parser.add_argument(
        '--band', '-b',
        help='Band/artist name'
    )
    parser.add_argument(
        '--album', '-a',
        help='Album name (used to identify correct artist)'
    )
    parser.add_argument(
        '--include-singles',
        action='store_true',
        help='Include singles in results (default: only albums and EPs)'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose logging'
    )
    parser.add_argument(
        '--config',
        type=str,
        help=f'Path to config file (default: {CONFIG_FILE})'
    )

    args = parser.parse_args()

    config_file_path = Path(args.config) if args.config else CONFIG_FILE
    config = load_config(config_file_path)

    setup_logging(args.verbose)
    logger = logging.getLogger(__name__)

    logger.info("=" * 60)
    logger.info("Discography Resolver v1.0.0")
    logger.info("=" * 60)

    session = create_session(config)

    try:
        band, album = parse_input(args)
        logger.info(f"Search: {band} - {album}")

        print(f"Searching for: {band} - {album}", file=sys.stderr)
        found_album = search_album(session, band, album, config)

        if not found_album:
            print(f"Album not found: {band} - {album}", file=sys.stderr)
            sys.exit(1)

        artist = found_album.get('artist')
        if not artist:
            print("Could not extract artist from album", file=sys.stderr)
            sys.exit(1)

        artist_id = artist.get('id')
        artist_name = artist.get('name', band)

        print(f"Found artist: {artist_name}", file=sys.stderr)
        logger.info(f"Found artist: {artist_name} (ID: {artist_id})")

        print("Fetching discography...", file=sys.stderr)
        albums = get_artist_discography(session, artist_id, config)

        if not albums:
            print("No albums found in discography", file=sys.stderr)
            sys.exit(1)

        # Filter by record type (exclude singles)
        filtered_albums = filter_albums(albums, include_singles=args.include_singles)
        excluded_count = len(albums) - len(filtered_albums)
        if args.include_singles:
            logger.info(f"After filtering: {len(filtered_albums)} albums (all types included)")
        else:
            logger.info(f"After filtering: {len(filtered_albums)} albums (excluded {excluded_count} singles)")

        # Filter out duplicates by title
        seen_titles = set()
        unique_albums = []
        for alb in filtered_albums:
            title = alb.get('title', '').lower()
            if title not in seen_titles:
                seen_titles.add(title)
                unique_albums.append(alb)

        if args.include_singles:
            print(f"Found {len(unique_albums)} unique albums (Albums + EPs + Singles)", file=sys.stderr)
        else:
            print(f"Found {len(unique_albums)} unique albums (EPs + Albums only)", file=sys.stderr)
        logger.info(f"Found {len(unique_albums)} unique albums")

        # Output URLs to stdout (one per line)
        for alb in unique_albums:
            url = build_album_url(alb.get('id'))
            print(url)

        sys.exit(0)

    except KeyboardInterrupt:
        logger.warning("Interrupted by user")
        print("\nInterrupted by user", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
