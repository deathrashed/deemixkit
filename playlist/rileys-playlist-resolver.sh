#!/bin/bash

# Playlist to Deemix - Get only albums you don't have
# Takes a playlist URL, filters out owned albums, copies missing ones to clipboard

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
echo -e "${BLUE}=== Playlist to Deemix ===${NC}"
echo -e "${BLUE}Getting albums you don't have...${NC}"
echo ""

python3 "$SCRIPT_DIR/rileys-playlist-resolver.py" "$URL"

exit $?
