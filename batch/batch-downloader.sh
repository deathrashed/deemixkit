#!/bin/bash

# Batch Downloader for DeemixKit
# Downloads multiple albums from a text file list

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
INPUT_FILE="albums.txt"
DELAY=0
DEFAULT_SERVICE="deezer"
DRY_RUN=false

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Help text
show_help() {
    cat << EOF
Batch Downloader for DeemixKit

Usage: ./batch-downloader.sh [options]

Options:
    -f, --file FILE       Input file containing albums (default: albums.txt)
    -d, --delay SECONDS   Delay between resolver calls (default: 10)
    -s, --service SERVICE Service to use: deezer or spotify (default: deezer)
    -n, --dry-run         Show what would be downloaded without downloading
    -h, --help            Show this help message

File Format:
    Each line should contain artist and album, separated by space, dash, or colon.
    Lines starting with # are comments.
    Empty lines are ignored.

    Examples:
        Metallica - Master of Puppets
        Pink Floyd: The Wall
        Radiohead OK Computer

Note: All album URLs are copied to clipboard at once, then pasted to Deemix.
      Deemix will queue all downloads automatically.

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            INPUT_FILE="$2"
            shift 2
            ;;
        -d|--delay)
            DELAY="$2"
            shift 2
            ;;
        -s|--service)
            DEFAULT_SERVICE="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: File '$INPUT_FILE' not found${NC}"
    echo ""
    echo "Create a file with one album per line:"
    echo "  Metallica - Master of Puppets"
    echo "  Pink Floyd: The Wall"
    echo ""
    echo "Or specify a different file with: -f filename"
    exit 1
fi

# Count total lines (excluding comments and empty lines)
TOTAL=$(grep -v "^#" "$INPUT_FILE" | grep -v "^[[:space:]]*$" | wc -l | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${RED}Error: No albums found in '$INPUT_FILE'${NC}"
    exit 1
fi

echo -e "${BLUE}=== Batch Downloader ===${NC}"
echo -e "File: ${YELLOW}$INPUT_FILE${NC}"
echo -e "Albums to process: ${YELLOW}$TOTAL${NC}"
echo -e "Service: ${YELLOW}$DEFAULT_SERVICE${NC}"
echo -e "Resolver delay: ${YELLOW}${DELAY}s${NC} between calls"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No downloads will be made${NC}"
fi
echo ""

# Choose resolver based on service
case "$DEFAULT_SERVICE" in
    deezer)
        RESOLVER="$SCRIPT_DIR/../deezer/deezer-resolver.py"
        ;;
    spotify)
        RESOLVER="$SCRIPT_DIR/../spotify/spotify-resolver.py"
        ;;
    *)
        echo -e "${RED}Error: Service must be 'deezer' or 'spotify'${NC}"
        exit 1
        ;;
esac

# Check if resolver exists
if [ ! -f "$RESOLVER" ]; then
    echo -e "${RED}Error: Resolver not found at $RESOLVER${NC}"
    exit 1
fi

# Array to store all URLs
declare -a ALL_URLS
COUNT=0
SUCCESS=0
FAILED=0

# Read file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
        continue
    fi

    COUNT=$((COUNT + 1))

    # Parse line - try different separators
    ARTIST=""
    ALBUM=""

    # Try " - " separator
    if [[ "$line" =~ ^(.+)[[:space:]]+-[[:space:]]+(.+)$ ]]; then
        ARTIST="${BASH_REMATCH[1]}"
        ALBUM="${BASH_REMATCH[2]}"
    # Try ":" separator
    elif [[ "$line" =~ ^(.+):[[:space:]]+(.+)$ ]]; then
        ARTIST="${BASH_REMATCH[1]}"
        ALBUM="${BASH_REMATCH[2]}"
    # Try space separator (first word is artist, rest is album)
    elif [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
        ARTIST="${BASH_REMATCH[1]}"
        ALBUM="${BASH_REMATCH[2]}"
    else
        echo -e "${YELLOW}[$COUNT/$TOTAL]${NC} ${RED}Could not parse: $line${NC}"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Trim whitespace
    ARTIST=$(echo "$ARTIST" | xargs)
    ALBUM=$(echo "$ALBUM" | xargs)

    echo -e "${BLUE}[$COUNT/$TOTAL]${NC} Resolving: ${YELLOW}$ARTIST${NC} - ${YELLOW}$ALBUM${NC}"

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${GREEN}[DRY RUN]${NC} Would resolve: $ARTIST - $ALBUM"
        SUCCESS=$((SUCCESS + 1))
    else
        # Run resolver and extract URL
        RESOLVER_OUTPUT=$(python3 "$RESOLVER" --band "$ARTIST" --album "$ALBUM" --no-clipboard 2>&1)

        # Extract just the URL from output (supports both Deezer and Spotify)
        URL=$(echo "$RESOLVER_OUTPUT" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+|https://open\.spotify\.com/album/[a-zA-Z0-9]+' | head -1)

        if [ -n "$URL" ]; then
            echo -e "  ${GREEN}✓${NC} Found: $URL"
            ALL_URLS+=("$URL")
            SUCCESS=$((SUCCESS + 1))

            # Delay before next resolver call (but not after the last one)
            if [ $COUNT -lt $TOTAL ]; then
                echo -e "  ${BLUE}Waiting ${DELAY}s before next resolver...${NC}"
                sleep "$DELAY"
            fi
        else
            echo -e "  ${RED}✗${NC} Failed to resolve"
            FAILED=$((FAILED + 1))
        fi
    fi

    echo ""

done < "$INPUT_FILE"

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Total processed: ${YELLOW}$TOTAL${NC}"
echo -e "${GREEN}Successful: $SUCCESS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ "$DRY_RUN" = false ] && [ ${#ALL_URLS[@]} -gt 0 ]; then
    # Join all URLs with newlines
    ALL_URLS_JOINED=$(printf '%s\n' "${ALL_URLS[@]}")

    echo ""
    echo -e "${BLUE}=== Copying to Clipboard ===${NC}"
    echo "$ALL_URLS_JOINED" | pbcopy
    echo -e "${GREEN}✓${NC} Copied ${#ALL_URLS[@]} album URLs to clipboard!"

    # Paste to Deemix
    echo ""
    echo -e "${BLUE}=== Pasting to Deemix ===${NC}"
    osascript "$SCRIPT_DIR/../scripts/paste-to-deemix.applescript" 2>/dev/null
    echo -e "${GREEN}✓${NC} Pasted to Deemix - all albums should now be downloading!"

    echo ""
    echo -e "${GREEN}All done! Check Deemix for your downloads.${NC}"
fi

exit 0
