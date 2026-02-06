#!/bin/bash

# Deezer to Deemix CLI
# Resolves Deezer album/artist and downloads directly via CLI

# Get artist and album from arguments
ARTIST="$1"
ALBUM="$2"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call Deezer resolver and get URL
URL=$(python3 "$SCRIPT_DIR/deezer-resolver.py" --band "$ARTIST" --album "$ALBUM" 2>&1)

# Check if resolver succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to resolve Deezer link"
  exit 1
fi

# Extract URL from output
ALBUM_URL=$(echo "$URL" | grep -E 'https://(www\.)?deezer\.com/album/[0-9]+' | head -1)

if [ -z "$ALBUM_URL" ]; then
  echo "Error: No URL found"
  exit 1
fi

echo "Found: $ALBUM_URL"
echo "Downloading..."

# Download directly via CLI
"$SCRIPT_DIR/../scripts/deemix-download.sh" "$ALBUM_URL"
