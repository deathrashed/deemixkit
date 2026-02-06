#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Currently Playing
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-currently-playing.png
# @raycast.currentDirectoryPath ~

# Documentation:
# @raycast.description Download the currently playing Spotify track via Deemix
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Currently Playing script
node "$DEEMIXKIT_PATH/spotify/currently-playing-to-deemix.js"
