#!/bin/bash

# Global URL Resolver Wrapper
# Accepts any Spotify/Deezer URL and returns Deemix album URL

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

    # Check if clipboard contains a valid URL
    if [[ "$CLIPBOARD" =~ (spotify\.com|deezer\.com) ]]; then
        URL="$CLIPBOARD"
        echo -e "${BLUE}Using URL from clipboard:${NC} $URL"
        echo ""
    else
        # Prompt for URL
        echo -e "${BLUE}Enter a Spotify or Deezer URL:${NC}"
        echo "  (track, album, playlist, or artist)"
        echo ""
        read -p "> " URL
        echo ""

        if [ -z "$URL" ]; then
            echo -e "${RED}No URL provided${NC}"
            exit 1
        fi
    fi
fi

# Run the resolver
echo -e "${BLUE}=== Global URL Resolver ===${NC}"
echo -e "${BLUE}Resolving:${NC} $URL"
echo ""

# Check if it's an artist URL - special handling for multiple albums
if [[ "$URL" =~ (spotify\.com/artist/|deezer\.com/artist/) ]]; then
    echo -e "${YELLOW}Artist URL detected - fetching all albums...${NC}"
    echo ""

    # Call Python resolver with --artist flag to get all albums
    RESULT=$(python3 "$SCRIPT_DIR/global-resolver.py" "$URL" --artist --no-clipboard 2>&1)

    # Extract all album URLs from output
    ALBUM_URLS=$(echo "$RESULT" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+')

    if [ -n "$ALBUM_URLS" ]; then
        URL_COUNT=$(echo "$ALBUM_URLS" | wc -l | tr -d ' ')
        echo -e "${GREEN}✓${NC} Found $URL_COUNT albums"
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
fi

# Call Python resolver for single album (track/album)
RESULT=$(python3 "$SCRIPT_DIR/global-resolver.py" "$URL" --no-clipboard 2>&1)

# Check if result contains a URL
if [[ "$RESULT" =~ https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+ ]]; then
    # Extract the URL
    ALBUM_URL=$(echo "$RESULT" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+' | head -1)

    if [ -n "$ALBUM_URL" ]; then
        echo -e "${GREEN}✓${NC} Found: $ALBUM_URL"
        echo ""

        # Copy to clipboard
        echo "$ALBUM_URL" | pbcopy
        echo -e "${GREEN}✓${NC} Copied to clipboard!"

        # Paste to Deemix
        echo ""
        echo -e "${BLUE}Pasting to Deemix...${NC}"
        osascript "$SCRIPT_DIR/../scripts/paste-to-deemix.applescript" 2>/dev/null
        echo -e "${GREEN}✓${NC} Sent to Deemix!"
        echo ""
        echo -e "${GREEN}All done!${NC}"
        exit 0
    fi
fi

# If we get here, resolution failed
echo -e "${RED}✗${NC} Failed to resolve URL"
echo ""
echo "Possible reasons:"
echo "  - Invalid URL format"
echo "  - Network error"
echo "  - Service requires credentials (Spotify)"
echo ""
echo "Supported URL types:"
echo "  Spotify/Deezer tracks"
echo "  Spotify/Deezer albums"
echo "  Spotify/Deezer artists (returns first album)"
echo ""
echo "Note: For full artist discographies, use the discography tool."

exit 1
