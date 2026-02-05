#!/usr/bin/env osascript

-- Riley's Playlist Resolver - GUI Dialog Version
-- Extracts albums from a playlist, filters out ones you already own, sends to Deemix

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""
set resolverPath to scriptDir & "/rileys-playlist-resolver.py"
set pasteScript to scriptDir & "/../scripts/paste-to-deemix.applescript"

-- Function to get URL from clipboard or prompt
on getURL()
	-- First try to get from clipboard
	set clipboardURL to do shell script "pbpaste 2>/dev/null"

	-- Check if clipboard contains a valid playlist URL
	if clipboardURL contains "spotify.com/playlist/" or clipboardURL contains "deezer.com/playlist/" then
		return clipboardURL
	end if

	-- Otherwise, prompt user
	set userURL to text returned of (display dialog "Enter a Spotify or Deezer playlist URL:

This will extract albums from the playlist, filter out the ones you already own, and send only the missing albums to Deemix.

Paste from clipboard or type manually." default answer "" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" with title "Riley's Playlist Resolver")

	return userURL
end getURL

-- Get the URL
set theURL to getURL()

if theURL is "" then
	return
end if

-- Resolve the playlist
set resolverOutput to do shell script "python3 " & quoted form of resolverPath & " " & quoted form of theURL & " 2>&1"

-- Extract summary info from output
set newCount to 0
set ownedCount to 0
try
	-- Extract "X new, Y already owned" from output
	set newCount to do shell script "echo " & quoted form of resolverOutput & " | grep -oE '[0-9]+ new' | grep -oE '[0-9]+' | head -1"
	set ownedCount to do shell script "echo " & quoted form of resolverOutput & " | grep -oE '[0-9]+ already owned' | grep -oE '[0-9]+' | head -1"
on error
	-- Fallback: count album URLs directly
	set albumURLs to do shell script "echo " & quoted form of resolverOutput & " | grep -E 'https://(www\\.)?deezer\\.com/album/[0-9]+|https://open\\.spotify\\.com/album/[a-zA-Z0-9]+' | wc -l | tr -d ' '"
	set newCount to albumURLs
end try

if newCount is not "" and newCount is not "0" then
	-- Success - URLs were copied to clipboard by the script

	-- Paste to Deemix
	do shell script "osascript " & quoted form of pasteScript

	-- Show success
	display dialog "Riley's Playlist Resolver - Success!

" & ownedCount & " albums already in your collection
" & newCount & " new albums to download

All " & newCount & " album URLs copied to clipboard and sent to Deemix." buttons {"OK"} with title "Riley's Playlist Resolver" with icon note
else
	-- Show error
	display dialog "Riley's Playlist Resolver - Failed

Could not extract albums from the playlist.

Possible reasons:
• Invalid playlist URL format
• Private playlist (Spotify requires credentials)
• Network error
• Collection matcher not found

Note: Requires CollectionMatcher at ~/scripts/rileys-collection-matcher.py
      Spotify playlists require credentials in ~/.config/deemixkit/credentials.json" buttons {"OK"} with title "Riley's Playlist Resolver" with icon stop
end if
