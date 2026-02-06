#!/bin/bash

# Playlist to Deemix CLI - Get only albums you don't have
# Takes a playlist URL, filters out owned albums, downloads missing ones via CLI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLLECTION_PATH="${COLLECTION_PATH:-/Volumes/Eksternal/Audio}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get URL from argument, clipboard, or prompt
URL="${1:-}"

if [ -z "$URL" ]; then
    CLIPBOARD=$(pbpaste 2>/dev/null)

    if [[ "$CLIPBOARD" =~ (spotify\.com/playlist/|deezer\.com/playlist/) ]]; then
        URL="$CLIPBOARD"
        echo -e "${BLUE}Using playlist URL from clipboard:${NC} $URL"
        echo ""
    else
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

# Run the script
echo -e "${BLUE}=== Playlist to Deemix (CLI) ===${NC}"
echo -e "${BLUE}Getting albums you don't have and downloading...${NC}"
echo ""

# Get the URLs from the Python script
URLS=$(python3 "$SCRIPT_DIR/rileys-playlist-resolver.py" "$URL" --no-clipboard 2>&1)

# Extract and download each URL
echo "$URLS" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+' | while IFS= read -r url; do
    if [ -n "$url" ]; then
        echo -e "${BLUE}Downloading:${NC} $url"
        "$SCRIPT_DIR/../scripts/deemix-download.sh" "$url"
    fi
done

echo ""
echo -e "${GREEN}All done!${NC}"

exit $?
