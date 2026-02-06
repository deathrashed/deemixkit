#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Discography
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-discography.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Artist" }
# @raycast.argument2 { "type": "text", "placeholder": "Album (to identify artist)" }

# Documentation:
# @raycast.description Download an artist's full discography via Deemix
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Discography to Deemix script
"$DEEMIXKIT_PATH/discography/discography-to-deemix.sh" "$1" "$2"

# Call the paste-to-deemix AppleScript
osascript "$DEEMIXKIT_PATH/scripts/paste-to-deemix.applescript"

