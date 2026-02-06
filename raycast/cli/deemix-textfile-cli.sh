#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Text File (CLI)
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-textfile.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "dropdown", "placeholder": "Service", "data": [{"title": "Deezer", "value": "deezer"}, {"title": "Spotify", "value": "spotify"}], "optional": true }
# @raycast.argument2 { "type": "text", "placeholder": "File path (optional)", "optional": true }

# Documentation:
# @raycast.description Download multiple albums from a text file via CLI
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Build command arguments
ARGS=()
if [ -n "$1" ]; then
  ARGS+=("-s" "$1")
fi
if [ -n "$2" ]; then
  ARGS+=("-f" "$2")
fi

# Call the Batch Downloader CLI script
"$DEEMIXKIT_PATH/batch/batch-downloader-cli.sh" "${ARGS[@]}"
