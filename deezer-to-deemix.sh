#!/bin/bash

# Get artist and album from arguments
ARTIST="$1"
ALBUM="$2"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call Deezer resolver and copy to clipboard
python3 "$SCRIPT_DIR/deezer-resolver.py" --band "$ARTIST" --album "$ALBUM"

# Check if resolver succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to resolve Deezer link"
  exit 1
fi

# Wait for clipboard to be set
sleep 0.5

# Execute AppleScript to paste into Deemix
osascript "$SCRIPT_DIR/paste-to-deemix.applescript"

exit $?
