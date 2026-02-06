#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Deezer (CLI)
# @raycast.mode silent
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-deezer.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Artist" }
# @raycast.argument2 { "type": "text", "placeholder": "Album" }

# Documentation:
# @raycast.description Search Deezer for an album and download via CLI
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Deezer to Deemix CLI script
"$DEEMIXKIT_PATH/deezer/deezer-to-deemix-cli.sh" "$1" "$2"
