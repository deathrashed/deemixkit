#!/bin/bash

# Get artist and album from arguments
ARTIST="$1"
ALBUM="$2"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$SCRIPT_DIR/discography-resolver.py"

# Call discography resolver (show stderr to console, capture stdout to variable)
URLS=$(python3 "$RESOLVER" --band "$ARTIST" --album "$ALBUM" 2>&1)
RESOLVER_EXIT=$?

# Check if resolver succeeded
if [ $RESOLVER_EXIT -ne 0 ]; then
  echo "Error: Failed to resolve discography" >&2
  echo "$URLS" >&2
  exit 1
fi

# Extract only URLs (stderr messages start with non-URL text)
URLS_ONLY=$(echo "$URLS" | grep '^https://www\.deezer\.com/album/[0-9]')

# Count URLs
if [ -z "$URLS_ONLY" ]; then
  echo "Error: No albums found" >&2
  exit 1
fi

URL_COUNT=$(echo "$URLS_ONLY" | wc -l | tr -d ' ')

echo "Found $URL_COUNT albums. Copying to clipboard..."

# Copy all URLs at once (each on its own line)
echo "$URLS_ONLY" | pbcopy

echo "All $URL_COUNT album URLs copied to clipboard!"
echo "Now paste into Deemix to download all albums."

exit 0
