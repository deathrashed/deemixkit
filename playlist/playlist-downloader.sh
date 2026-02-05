#!/bin/bash

# Playlist Downloader
# Extracts all album URLs from a playlist and sends them to Deemix

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default URL can be passed as argument or will prompt
URL="${1:-}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# If no URL provided, read from clipboard or prompt
if [ -z "$URL" ]; then
    # Try to get from clipboard first
    CLIPBOARD=$(pbpaste 2>/dev/null)

    # Check if clipboard contains a valid playlist URL
    if [[ "$CLIPBOARD" =~ (spotify\.com/playlist/|deezer\.com/playlist/) ]]; then
        URL="$CLIPBOARD"
        echo -e "${BLUE}Using playlist URL from clipboard:${NC} $URL"
        echo ""
    else
        # Prompt for URL
        echo -e "${BLUE}Enter a Spotify or Deezer playlist URL:${NC}"
        echo ""
        read -p "> " URL
        echo ""

        if [ -z "$URL" ]; then
            echo -e "${RED}No URL provided${NC}"
            exit 1
        fi
    fi
fi

# Run the playlist downloader
echo -e "${BLUE}=== Playlist Downloader ===${NC}"
echo -e "${BLUE}Processing playlist...${NC}"
echo ""

# Call Python resolver
RESULT=$(python3 "$SCRIPT_DIR/playlist-downloader.py" "$URL" --no-clipboard 2>&1)

# Extract all album URLs from output (supports both Deezer and Spotify)
ALBUM_URLS=$(echo "$RESULT" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+' | sort | uniq)

if [ -n "$ALBUM_URLS" ]; then
    URL_COUNT=$(echo "$ALBUM_URLS" | wc -l | tr -d ' ')
    echo -e "${GREEN}✓${NC} Found $URL_COUNT unique albums in playlist"
    echo ""

    # Copy all URLs to clipboard at once (newline-separated)
    echo "$ALBUM_URLS" | pbcopy
    echo -e "${GREEN}✓${NC} Copied $URL_COUNT albums to clipboard!"

    # Paste to Deemix
    echo ""
    echo -e "${BLUE}Pasting to Deemix...${NC}"
    osascript "$SCRIPT_DIR/../scripts/paste-to-deemix.applescript" 2>/dev/null
    echo -e "${GREEN}✓${NC} Sent to Deemix!"
    echo ""
    echo -e "${GREEN}All done!${NC}"
    exit 0
fi

# If we get here, resolution failed
echo -e "${RED}✗${NC} Failed to extract albums from playlist"
echo ""
echo "Possible reasons:"
echo "  - Invalid playlist URL format"
echo "  - Private playlist (Spotify requires credentials)"
echo "  - Network error"
echo ""
echo "Note: Spotify playlists require credentials in ~/.config/deemixkit/credentials.json"
echo "      Deezer playlists work without credentials"

exit 1
