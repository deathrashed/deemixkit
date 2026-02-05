#!/usr/bin/env osascript

-- Global URL Resolver - GUI Dialog Version
-- Accepts any Spotify/Deezer URL and returns Deemix album URL

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""
set resolverPath to scriptDir & "/global-resolver.py"
set pasteScript to scriptDir & "/../scripts/paste-to-deemix.applescript"

-- Function to get URL from clipboard or prompt
on getURL()
	-- First try to get from clipboard
	set clipboardURL to do shell script "pbpaste 2>/dev/null"

	-- Check if clipboard contains a valid URL
	if clipboardURL contains "spotify.com" or clipboardURL contains "deezer.com" then
		return clipboardURL
	end if

	-- Otherwise, prompt user
	set userURL to text returned of (display dialog "Enter a Spotify or Deezer URL:

Supported:
  ¥ Tracks (returns parent album)
  ¥ Albums
  ¥ Artists (returns ALL albums - full discography!)

Paste from clipboard or type manually." default answer "" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" with title "Global URL Resolver")

	return userURL
end getURL

-- Get the URL
set theURL to getURL()

if theURL is "" then
	return
end if

-- Check if it's an artist URL - use --artist flag to get all albums
if theURL contains "spotify.com/artist/" or theURL contains "deezer.com/artist/" then
	-- Use --artist flag to get all albums
	set resolverOutput to do shell script "python3 " & quoted form of resolverPath & " " & quoted form of theURL & " --artist --no-clipboard 2>&1"
else
	-- Resolve the URL normally
	set resolverOutput to do shell script "python3 " & quoted form of resolverPath & " " & quoted form of theURL & " --no-clipboard 2>&1"
end if

-- Extract URL from output (supports both Deezer and Spotify)
set albumURL to do shell script "echo " & quoted form of resolverOutput & " | grep -E 'https://(www\\.)?deezer\\.com/album/[0-9]+|https://open\\.spotify\\.com/album/[a-zA-Z0-9]+' | head -1"

if albumURL is not "" then
	-- Check if multiple albums (newline separated)
	set albumCount to (count of paragraphs of albumURL)

	if albumCount > 1 then
		-- Multiple albums - copy all to clipboard
		do shell script "echo " & quoted form of albumURL & " | pbcopy"

		-- Paste to Deemix
		do shell script "osascript " & quoted form of pasteScript

		-- Show success
		display dialog "Global Resolver - Success!

Found " & albumCount & " albums from artist URL.

All " & albumCount & " album URLs copied to clipboard and sent to Deemix." buttons {"OK"} with title "Global URL Resolver" with icon note
	else
		-- Single album
		do shell script "echo " & quoted form of albumURL & " | pbcopy"

		-- Paste to Deemix
		do shell script "osascript " & quoted form of pasteScript

		-- Show success
		display dialog "Global Resolver - Success!

Found: " & albumURL & "

Copied to clipboard and sent to Deemix." buttons {"OK"} with title "Global URL Resolver" with icon note
	end if
else
	-- Show error
	display dialog "Global Resolver - Failed

Could not resolve the URL.

Possible reasons:
¥ Invalid URL format
¥ Network error
¥ Spotify requires credentials (check ~/.config/deemixkit/credentials.json)

Supported URLs:
¥ Spotify/Deezer tracks
¥ Spotify/Deezer albums
¥ Spotify/Deezer artists (returns first album)" buttons {"OK"} with title "Global URL Resolver" with icon stop
end if
