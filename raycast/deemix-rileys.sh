#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deemix - Rileys Resolver
# @raycast.mode fullOutput
# @raycast.packageName DeemixKit

# Optional parameters:
# @raycast.icon /Volumes/Eksternal/Music/Tools/DeemixKit/docs/icons/links-rileys-resolver.png
# @raycast.currentDirectoryPath ~
# @raycast.argument1 { "type": "text", "placeholder": "Playlist URL" }

# Documentation:
# @raycast.description Download all albums from a Spotify/Deezer playlist
# @raycast.author deathrashed
# @raycast.authorURL https://github.com/deathrashed

# Set the path to DeemixKit
# Users should update this to their installation path
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"

# Call the Playlist Downloader script
"$DEEMIXKIT_PATH/playlist/rileys-playlist-resolver.sh" "$1"

# Call the paste-to-deemix AppleScript
osascript "$DEEMIXKIT_PATH/scripts/paste-to-deemix.applescript"

