#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Spotify (CLI)
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-spotify.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Artist" }
# @raycast.argument2 { "type": "text", "placeholder": "Album" }

# Documentation:
# @raycast.description Search Spotify for an album and download via CLI
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Spotify to Deemix CLI script
"$DEEMIXKIT_PATH/spotify/spotify-to-deemix-cli.sh" "$1" "$2"
