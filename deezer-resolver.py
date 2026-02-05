#!/usr/bin/env python3
"""
Deezer Album Link Resolver

Resolves Deezer album links from band and album names.
Searches Deezer API and copies the album URL to clipboard.

Version: 1.0.0
Author: cursor
Created: December 23rd, 2025
"""

import sys
import json
import logging
import argparse
import urllib.parse
from pathlib import Path
from typing import Optional, Dict, Any
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Try to import clipboard functionality
try:
    import pyperclip
    CLIPBOARD_AVAILABLE = True
except ImportError:
    CLIPBOARD_AVAILABLE = False
    # Fallback for macOS using pbcopy
    import subprocess


# Configuration
CONFIG_DIR = Path.home() / ".config" / "deezer-resolver"
CONFIG_FILE = CONFIG_DIR / "config.json"
LOG_DIR = Path.home() / ".local" / "log" / "deezer-resolver"
LOG_FILE = LOG_DIR / "deezer-resolver.log"

# Deezer URLs and API endpoints
DEEZER_ALBUM_BASE = "https://www.deezer.com/album/"
DEEZER_SEARCH_URL = "https://api.deezer.com/search/album"


def setup_logging(verbose: bool = False) -> None:
    """Set up logging configuration."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    level = logging.DEBUG if verbose else logging.INFO
    format_str = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

    handlers = [logging.FileHandler(LOG_FILE)]
    # Only log to stderr in verbose mode
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
        "cache_results": True,
        "cache_file": str(CONFIG_DIR / "cache.json"),
        "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "deezer_id": None,
        "deezer_secret": None
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


def save_to_clipboard(text: str) -> bool:
    """Copy text to clipboard. Returns True if successful."""
    try:
        if CLIPBOARD_AVAILABLE:
            pyperclip.copy(text)
            logging.debug(f"Copied to clipboard using pyperclip: {text[:50]}...")
            return True
        else:
            # macOS fallback using pbcopy
            process = subprocess.Popen(
                ['pbcopy'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            process.communicate(input=text.encode('utf-8'))
            if process.returncode == 0:
                logging.debug(f"Copied to clipboard using pbcopy: {text[:50]}...")
                return True
            else:
                logging.error("Failed to copy to clipboard using pbcopy")
                return False
    except Exception as e:
        logging.error(f"Error copying to clipboard: {e}")
        return False


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
        'User-Agent': config.get("user_agent", "Deezer-Resolver/1.0"),
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9'
    })

    return session


def search_deezer_album(session: requests.Session, query: str, config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """
    Search Deezer for an album using the free Web API.
    Deezer doesn't require authentication for basic search.
    """
    # Build search query
    search_query = query

    # Set up search parameters
    params = {
        'q': search_query,
        'limit': 20
    }

    try:
        logging.info(f"Searching Deezer API for: {search_query}")

        response = session.get(
            DEEZER_SEARCH_URL,
            params=params,
            timeout=config.get("timeout", 10)
        )
        response.raise_for_status()

        data = response.json()
        albums = data.get('data', [])

        if not albums:
            logging.warning(f"No albums found for query: {search_query}")
            return None

        logging.info(f"Found {len(albums)} album(s)")
        return albums[0]  # Return the first (most relevant) result

    except requests.exceptions.Timeout:
        logging.error("Request timed out while searching Deezer")
        return None
    except requests.exceptions.RequestException as e:
        logging.error(f"Network error searching Deezer: {e}")
        if hasattr(e, 'response') and e.response is not None:
            logging.error(f"Response status: {e.response.status_code}")
            logging.error(f"Response body: {e.response.text[:200]}")
        return None
    except (KeyError, json.JSONDecodeError) as e:
        logging.error(f"Error parsing Deezer response: {e}")
        return None


def build_album_url(album_id: str) -> str:
    """Build Deezer album URL from album ID."""
    return f"{DEEZER_ALBUM_BASE}{album_id}"


def parse_input(args: argparse.Namespace) -> str:
    """Parse input from arguments or prompt user."""
    if args.band and args.album:
        return f"{args.band} {args.album}"
    elif args.query:
        return args.query
    else:
        # Interactive mode - prompt user
        if sys.stdin.isatty():
            print("Enter band and album name:")
            print("Format: 'Band Name - Album Name' or just paste the text")
            user_input = input("> ").strip()
            if not user_input:
                logging.error("No input provided")
                sys.exit(1)

            # Try to parse "Band - Album" format
            if " - " in user_input:
                parts = user_input.split(" - ", 1)
                return f"{parts[0].strip()} {parts[1].strip()}"
            else:
                return user_input
        else:
            # Read from stdin (for piping)
            user_input = sys.stdin.read().strip()
            if not user_input:
                logging.error("No input from stdin")
                sys.exit(1)
            return user_input


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Resolve Deezer album links from band and album names",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --band "Metallica" --album "Master of Puppets"
  %(prog)s --query "Metallica Master of Puppets"
  echo "Metallica - Master of Puppets" | %(prog)s
  %(prog)s  # Interactive mode
        """
    )

    parser.add_argument(
        '--band', '-b',
        help='Band/artist name'
    )
    parser.add_argument(
        '--album', '-a',
        help='Album name'
    )
    parser.add_argument(
        '--query', '-q',
        help='Full search query (e.g., "Metallica Master of Puppets")'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose logging'
    )
    parser.add_argument(
        '--no-clipboard',
        action='store_true',
        help='Print URL instead of copying to clipboard'
    )
    parser.add_argument(
        '--config',
        type=str,
        help=f'Path to config file (default: {CONFIG_FILE})'
    )

    args = parser.parse_args()

    # Load config
    config_file_path = Path(args.config) if args.config else CONFIG_FILE
    config = load_config(config_file_path)

    # Setup logging
    setup_logging(args.verbose)
    logger = logging.getLogger(__name__)

    logger.info("=" * 60)
    logger.info("Deezer Album Resolver v1.0.0")
    logger.info("=" * 60)

    # Print header
    print("=" * 44)
    print("Deezer Album Resolver")
    print("=" * 44)

    try:
        # Parse input
        query = parse_input(args)
        logger.info(f"Search query: {query}")

        # Create session
        session = create_session(config)

        # Search Deezer
        print("Searching Deezer API...")
        album = search_deezer_album(session, query, config)

        if not album:
            logger.error("Album not found")
            print("Album not found on Deezer")
            sys.exit(1)

        # Extract album info
        album_id = album.get('id')
        album_name = album.get('title', 'Unknown')
        artist_name = album.get('artist', {}).get('name', 'Unknown')

        if not album_id:
            logger.error("No album ID in response")
            print("Invalid response from Deezer")
            sys.exit(1)

        # Build URL
        album_url = build_album_url(album_id)

        print(f"Found album: {artist_name} - {album_name}")
        logger.info(f"Found album: {artist_name} - {album_name}")
        logger.info(f"Album URL: {album_url}")

        # Copy to clipboard or print
        if args.no_clipboard:
            print(f"\n{album_url}")
        else:
            print("Copying URL to clipboard...")
            if save_to_clipboard(album_url):
                print(f"\n{album_url}")
                logger.info("Successfully copied URL to clipboard")
            else:
                print(f"Failed to copy to clipboard")
                print(f"\n{album_url}")
                logger.error("Failed to copy to clipboard")
                sys.exit(1)

        sys.exit(0)

    except KeyboardInterrupt:
        logger.warning("Interrupted by user")
        print("\nInterrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
