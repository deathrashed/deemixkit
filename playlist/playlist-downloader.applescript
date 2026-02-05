#!/usr/bin/env osascript

-- Playlist Downloader - GUI Dialog Version
-- Extracts all album URLs from a playlist and sends them to Deemix

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""
set resolverPath to scriptDir & "/playlist-downloader.py"
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

This will extract ALL albums from the playlist and send them to Deemix.

Paste from clipboard or type manually." default answer "" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" with title "Playlist Downloader")

	return userURL
end getURL

-- Get the URL
set theURL to getURL()

if theURL is "" then
	return
end if

-- Resolve the playlist
set resolverOutput to do shell script "python3 " & quoted form of resolverPath & " " & quoted form of theURL & " --no-clipboard 2>&1"

-- Extract all album URLs from output
set albumCount to 0
try
	-- Count how many album URLs we got
	set albumURLs to do shell script "echo " & quoted form of resolverOutput & " | grep -E 'https://(www\\.)?deezer\\.com/album/[0-9]+|https://open\\.spotify\\.com/album/[a-zA-Z0-9]+' | wc -l | tr -d ' '"
	set albumCount to albumURLs as integer
on error
	set albumCount to 0
end try

if albumCount > 0 then
	-- Copy all URLs to clipboard
	do shell script "echo " & quoted form of resolverOutput & " | grep -E 'https://(www\\.)?deezer\\.com/album/[0-9]+|https://open\\.spotify\\.com/album/[a-zA-Z0-9]+' | pbcopy"

	-- Paste to Deemix
	do shell script "osascript " & quoted form of pasteScript

	-- Show success
	display dialog "Playlist Downloader - Success!

Found " & albumCount & " unique albums in the playlist.

All " & albumCount & " album URLs copied to clipboard and sent to Deemix." buttons {"OK"} with title "Playlist Downloader" with icon note
else
	-- Show error
	display dialog "Playlist Downloader - Failed

Could not extract albums from the playlist.

Possible reasons:
• Invalid playlist URL format
• Private playlist (Spotify requires credentials)
• Network error

Note: Spotify playlists require credentials in ~/.config/deemixkit/credentials.json
      Deezer playlists work without credentials" buttons {"OK"} with title "Playlist Downloader" with icon stop
end if
