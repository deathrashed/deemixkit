---
title: "Batch Downloader"
description: "Downloads multiple albums from a text file list using bulk paste to Deemix"
author: riley
category: [Audio, Music]
language: [Bash, AppleScript]
path: "batch/"
created: "3rd February, 2026"
tags:
  - script
  - bash
  - applescript
  - music
  - spotify
  - deezer
  - automation
  - deemix
  - bulk-download
  - batch
---

# Batch Downloader

## Overview

A bulk downloading tool that processes a list of albums from a text file, resolves each one to its URL, and copies all URLs to clipboard at once for pasting into Deemix. Uses the bulk paste approach (all URLs simultaneously) rather than one-by-one, making it significantly faster for large batches. Features both Bash CLI and AppleScript GUI interfaces.

## Features

- **Bulk Paste Approach**: Copies all URLs at once, pastes to Deemix once
- **Flexible Input**: Accepts text file with album lists in multiple formats
- **Multiple Parsers**: Handles "Artist - Album", "Artist: Album", or "Artist Album" formats
- **Service Selection**: Works with both Deezer and Spotify resolvers
- **Delay Control**: Configurable delay between API calls to avoid rate limits
- **Dry Run Mode**: Preview what would be downloaded without actually downloading
- **Progress Tracking**: Shows current progress and summary statistics
- **Comment Support**: Lines starting with `#` are treated as comments

## File Format

The input file should contain one album per line. Supported formats:

```text
# This is a comment - will be ignored
Metallica - Master of Puppets
Pink Floyd: The Wall
Radiohead OK Computer
The Beatles - Abbey Road
```

Accepted separators:
- `Artist - Album` (dash with spaces)
- `Artist: Album` (colon with space)
- `Artist Album` (space separator)

Lines starting with `#` are comments. Empty lines are ignored.

## Dependencies

**Required Resolvers**:
- `deezer/deezer-resolver.py` - For Deezer service
- `spotify/spotify-resolver.py` - For Spotify service

**Python 3.7+** - Required for resolvers

**External Apps**:
- Deemix (desktop application)

## Interface Comparison

| Aspect | Bash CLI | AppleScript GUI |
|--------|----------|-----------------|
| **Invocation** | ./script.sh | osascript script.applescript |
| **Input** | Command-line flags | Dialog prompts |
| **Feedback** | Colored terminal output | Notification + dialogs |
| **Speed** | Faster (no dialog overhead) | Slightly slower |
| **Best For** | Automation, scripting, KM | Interactive use, Dock |

## Usage

### Bash Wrapper (CLI)

```bash
# Default: uses albums.txt in current directory
./batch/batch-downloader.sh

# Specify custom file
./batch/batch-downloader.sh -f /path/to/albums.txt

# Use Spotify instead of Deezer
./batch/batch-downloader.sh -s spotify

# Set delay between API calls (default 10 seconds)
./batch/batch-downloader.sh -d 5

# Dry run - show what would be downloaded
./batch/batch-downloader.sh -n

# Combined options
./batch/batch-downloader.sh -f mylist.txt -s spotify -d 15

# Show help
./batch/batch-downloader.sh -h
```

### AppleScript Dialog (GUI)

```bash
# Run with osascript
osascript batch/batch-downloader.applescript

# Or save as .app and double-click
```

## Command Line Options (Bash)

| Option | Short | Description |
|--------|-------|-------------|
| `--file` | `-f` | Input file containing albums (default: albums.txt) |
| `--delay` | `-d` | Delay between resolver calls in seconds (default: 10) |
| `--service` | `-s` | Service to use: deezer or spotify (default: deezer) |
| `--dry-run` | `-n` | Show what would be downloaded without downloading |
| `--help` | `-h` | Show help message |

## Source Code

### Bash Wrapper (`batch-downloader.sh`)

```bash
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
```

## Examples

### Example 1: Basic Batch Download

```bash
./batch/batch-downloader.sh
```

Output (using default albums.txt):
```
=== Batch Downloader ===
File: albums.txt
Albums to process: 10
Service: deezer
Resolver delay: 0s between calls

[1/10] Resolving: Metallica - Master of Puppets
  ✓ Found: https://www.deezer.com/album/103248
  Waiting 10s before next resolver...

[2/10] Resolving: Pink Floyd - The Wall
  ✓ Found: https://www.deezer.com/album/67853
  Waiting 10s before next resolver...

...

=== Summary ===
Total processed: 10
Successful: 10
Failed: 0

=== Copying to Clipboard ===
✓ Copied 10 album URLs to clipboard!

=== Pasting to Deemix ===
✓ Pasted to Deemix - all albums should now be downloading!

All done! Check Deemix for your downloads.
```

### Example 2: Custom File with Spotify

```bash
./batch/batch-downloader.sh -f my-download-list.txt -s spotify -d 15
```

### Example 3: Dry Run

```bash
./batch/batch-downloader.sh -f test-list.txt -n
```

Output:
```
=== Batch Downloader ===
File: test-list.txt
Albums to process: 5
Service: deezer
Resolver delay: 0s between calls
DRY RUN MODE - No downloads will be made

[1/5] Resolving: Daft Punk - Random Access Memories
  [DRY RUN] Would resolve: Daft Punk - Random Access Memories

...

=== Summary ===
Total processed: 5
Successful: 5
Failed: 0
```

### Example 4: Sample albums.txt File

```text
# My Rock Classics Playlist
Metallica - Master of Puppets
Pink Floyd - The Dark Side of the Moon
Radiohead: OK Computer
Nirvana Nevermind

# Some Jazz
Miles Davis - Kind of Blue
John Coltrane - A Love Supreme

# Electronic
Daft Punk Random Access Memories
```

## Keyboard Maestro Setup

Create a macro for batch downloading:

**Trigger:** Hotkey (e.g., `⌃⌥B` for Batch)

**Action 1:** Prompt for User Input
```
Prompt: Enter path to album list file:
Variable: AlbumListFile
Default: /Volumes/Eksternal/Music/Tools/DeemixKit/batch/albums.txt
```

**Action 2:** Execute Shell Script
```bash
cd /Volumes/Eksternal/Music/Tools/DeemixKit && ./batch/batch-downloader.sh -f "$KMVAR_AlbumListFile"
```

## Workflow Comparison

### Old Approach (One-by-One)
```
For each album:
  1. Resolve URL (~2s)
  2. Copy to clipboard
  3. Paste to Deemix (~6s)
  4. Wait for processing
Total for 10 albums: ~80 seconds
```

### New Approach (Bulk Paste)
```
For each album:
  1. Resolve URL (~2s)
  2. Collect all URLs
Once:
  3. Copy all to clipboard
  4. Paste once to Deemix (~6s)
Total for 10 albums: ~26 seconds (3x faster!)
```

## Troubleshooting

### "File not found" Error
Ensure the input file exists at the specified path. The default is `albums.txt` in the current directory.

### "Could not parse" Error
Check that each line follows one of the supported formats:
- `Artist - Album` (recommended)
- `Artist: Album`
- `Artist Album`

### "Resolver not found" Error
Ensure the appropriate resolver exists:
- Deezer: `deezer/deezer-resolver.py`
- Spotify: `spotify/spotify-resolver.py`

### Some albums fail to resolve
This can happen if:
- Artist/album names are misspelled
- The album isn't available on the service
- Network issues
- API rate limits (increase delay with `-d` flag)

### Deemix doesn't open
Check that:
1. Deemix is installed
2. `scripts/paste-to-deemix.applescript` exists
3. System Events has accessibility permission

## Performance Tips

1. **Adjust Delay Based on Service**:
   - Deezer: Can use shorter delays (5-10s)
   - Spotify: May need longer delays (15-20s) due to rate limits

2. **Large Batches**:
   - For 50+ albums, consider splitting into smaller files
   - Use dry run first to verify all albums resolve correctly

3. **Service Choice**:
   - Use Deezer for faster/more reliable resolution
   - Use Spotify when album not available on Deezer

## Related Scripts

- **Global URL Resolver** - Universal resolver for any URL type
- **Playlist Downloader** - Extract albums from playlists
- **Deezer Resolver** - Core Deezer album resolver
- **Spotify Resolver** - Core Spotify album resolver
