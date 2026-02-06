#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Global (CLI)
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/resolver-global.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Spotify/Deezer URL", "optional": true }

# Documentation:
# @raycast.description Resolve any Spotify or Deezer URL and download via CLI
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Global Resolver CLI script
# If no argument provided, it will use clipboard
"$DEEMIXKIT_PATH/global/global-resolver-cli.sh" "$1"
