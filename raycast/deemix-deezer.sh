#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Deezer
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-deezer.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Artist" }
# @raycast.argument2 { "type": "text", "placeholder": "Album" }

# Documentation:
# @raycast.description Search Deezer for an album and download via Deemix
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Deezer to Deemix script
"$DEEMIXKIT_PATH/deezer/deezer-to-deemix.sh" "$1" "$2"


