---
title: "Deezer Album Resolver"
description: "Resolve Deezer album links from artist and album names via CLI"
author: riley
category: [Audio, Music]
language: python
path: ".//deezer-resolver.py"
created: "23rd January, 2026"
tags:
  - script
  - python
  - music
  - deezer
  - api
  - clipboard
  - automation
  - deemix
---

# Deezer Album Resolver

## Overview

A Python CLI tool that searches Deezer's free Web API for albums by artist and album name, retrieves the direct Deezer album URL, and automatically copies it to the clipboard. No authentication required. Perfect for finding Deezer albums and integrating into automation workflows like Deemix downloading.

## Features

- **Deezer API Integration**: Uses free Deezer Web API (no authentication required)
- **Flexible Input**: Accepts artist/album via command-line arguments, full search queries, stdin, or interactive prompts
- **Clipboard Automation**: Automatically copies album URL to clipboard (with pyperclip fallback to pbcopy on macOS)
- **Configurable**: Supports config.json for search parameters and logging
- **Error Handling**: Comprehensive error handling with detailed logging to file and stderr
- **Retry Strategy**: Built-in automatic retry with exponential backoff for network failures

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- `requests` - HTTP client for Deezer API calls
- `pyperclip` (optional) - Clipboard access (falls back to macOS pbcopy if not installed)

Installation:
```bash
pip install requests pyperclip
```

**No API Credentials Required** - Deezer API is public and doesn't require authentication

## Usage

### Basic Usage

```bash
python3 .//deezer-resolver.py --band "Metallica" --album "Master of Puppets"
```

### Using Full Search Query

```bash
python3 .//deezer-resolver.py --query "Metallica Master of Puppets"
```

### Interactive Mode

```bash
python3 .//deezer-resolver.py
# Prompts: Enter band and album name (format: "Band Name - Album Name")
```

### From Stdin (Piping)

```bash
echo "Metallica - Master of Puppets" | python3 .//deezer-resolver.py
```

### Advanced Options

```bash
# Verbose logging
python3 .//deezer-resolver.py --band "Metallica" --album "Master of Puppets" --verbose

# Print URL instead of copying to clipboard
python3 .//deezer-resolver.py --band "Metallica" --album "Master of Puppets" --no-clipboard

# Custom config file location
python3 .//deezer-resolver.py --band "Metallica" --album "Master of Puppets" --config /path/to/config.json
```

## Script Details

**File Path:** `.//deezer-resolver.py`  
**Language:** Python 3  
**Category:** Audio / Music

## Configuration

Create `~/.config/deezer-resolver/config.json` (optional):

```json
{
  "timeout": 10,
  "max_retries": 3,
  "retry_delay": 1,
  "log_level": "INFO",
  "cache_results": true,
  "cache_file": "~/.config/deezer-resolver/cache.json",
  "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
}
```

## Source Code

```python
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

    logging.basicConfig(
        level=level,
        format=format_str,
        handlers=[
            logging.FileHandler(LOG_FILE),
            logging.StreamHandler(sys.stderr)
        ]
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

    try:
        # Parse input
        query = parse_input(args)
        logger.info(f"Search query: {query}")

        # Create session
        session = create_session(config)

        # Search Deezer
        album = search_deezer_album(session, query, config)

        if not album:
            logger.error("Album not found")
            print("❌ Album not found on Deezer", file=sys.stderr)
            sys.exit(1)

        # Extract album info
        album_id = album.get('id')
        album_name = album.get('title', 'Unknown')
        artist_name = album.get('artist', {}).get('name', 'Unknown')

        if not album_id:
            logger.error("No album ID in response")
            print("❌ Invalid response from Deezer", file=sys.stderr)
            sys.exit(1)

        # Build URL
        album_url = build_album_url(album_id)

        logger.info(f"Found album: {artist_name} - {album_name}")
        logger.info(f"Album URL: {album_url}")

        # Copy to clipboard or print
        if args.no_clipboard:
            print(album_url)
        else:
            if save_to_clipboard(album_url):
                print(f"✅ Copied to clipboard: {artist_name} - {album_name}")
                print(f"   {album_url}")
                logger.info("Successfully copied URL to clipboard")
            else:
                print(f"❌ Failed to copy to clipboard")
                print(f"   URL: {album_url}")
                logger.error("Failed to copy to clipboard")
                sys.exit(1)

        sys.exit(0)

    except KeyboardInterrupt:
        logger.warning("Interrupted by user")
        print("\n⚠️  Interrupted by user", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

## Examples

### Example 1: Search by Artist and Album

```bash
python3 .//deezer-resolver.py --band "Pink Floyd" --album "The Wall"
# Output: ✅ Copied to clipboard: Pink Floyd - The Wall
#         https://www.deezer.com/album/123456789
```

### Example 2: Pipe Input from Echo

```bash
echo "The Beatles - Abbey Road" | python3 .//deezer-resolver.py
# Output: ✅ Copied to clipboard: The Beatles - Abbey Road
#         https://www.deezer.com/album/987654321
```

### Example 3: Print URL to Console

```bash
python3 .//deezer-resolver.py --band "Radiohead" --album "OK Computer" --no-clipboard
# Output: https://www.deezer.com/album/555555555 (prints to stdout)
```

### Example 4: Simple Query Syntax

```bash
python3 .//deezer-resolver.py --query "Metallica Master of Puppets"
# Output: ✅ Copied to clipboard: Metallica - Master of Puppets
#         https://www.deezer.com/album/123123123
```

## Notes

- **No Authentication Required**: Deezer API is public and free to use - no credentials needed
- **Clipboard Fallback**: Uses `pyperclip` library if available, otherwise falls back to `pbcopy` on macOS
- **Logging**: Full logs saved to `~/.local/log/deezer-resolver/deezer-resolver.log` for debugging
- **Search Accuracy**: Returns the first (most relevant) result from Deezer search; for precise results, ensure exact artist/album names
- **Network Errors**: Script gracefully handles timeouts and network errors with automatic retries
- **Exit Codes**: Returns 0 on success, 1 on error, 130 on user interrupt (Ctrl+C)
- **Simpler Than Spotify**: Unlike Spotify resolver, Deezer doesn't require API credentials, making it easier to set up
- **Difference from Spotify**: Search uses simpler syntax ("Artist Album" instead of "artist:X album:Y")

## Related Scripts

- `Spotify Album Resolver.py.md` - Similar resolver for Spotify music service
- `Spotify to Deemix.md` - Get currently playing Spotify track and open in Deemix
- `Deezer to Deemix.applescript.md` - AppleScript version for Deezer automation
