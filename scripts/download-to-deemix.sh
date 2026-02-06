#!/bin/bash

# Deemix Download Helper
# Handles both GUI and CLI download modes
# Usage: download-to-deemix.sh [URL1] [URL2] ...

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEEMIX_DOWNLOAD="$SCRIPT_DIR/deemix-download.sh"

# Check DEEMIX_MODE env var, default to 'gui' for backward compatibility
DEEMIX_MODE="${DEEMIX_MODE:-gui}"

# Clean URLs - remove backslash escapes that some shells add
clean_urls=()
for url in "$@"; do
  clean_url="${url//\\\?/?}"
  clean_url="${clean_url//\=/=}"
  clean_url="${clean_url//\\\&/&}"
  clean_urls+=("$clean_url")
done

if [ "$DEEMIX_MODE" = "cli" ]; then
  # CLI Mode: Download directly via deemix-py
  for url in "${clean_urls[@]}"; do
    "$DEEMIX_DOWNLOAD" "$url"
  done
else
  # GUI Mode: Copy to clipboard and paste to Deemix app (legacy behavior)
  for url in "${clean_urls[@]}"; do
    echo "$url"
  done | pbcopy

  # Launch/activate Deemix and paste
  osascript "$SCRIPT_DIR/paste-to-deemix.applescript" 2>/dev/null
fi
