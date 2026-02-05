#!/usr/bin/env osascript

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""

set pythonScript to scriptDir & "/spotify-resolver.py"
set pasteScript to scriptDir & "/../paste-to-deemix.applescript"

-- Single dialog with both inputs
try
	display dialog ¬
		"Enter your search:" default answer ¬
		"Artist - Album" with title ¬
		"Spotify to Deemix" buttons {"Cancel", "OK"} ¬
		default button ¬
		"OK" cancel button "Cancel"
	
	set input to text returned of result
	set {artist, album} to my splitString(input, " - ")
	
	if artist is "" or album is "" then
		display alert "Error" message "Use format: Artist - Album"
		return
	end if
	
on error
	return
end try

-- Run Spotify resolver
try
	do shell script "python3 \"" & pythonScript & "\" --band \"" & artist & "\" --album \"" & album & "\""
on error errorMsg
	display alert "Error" message "Failed to resolve Spotify link:" & return & errorMsg
	return
end try

delay 0.5

-- Run paste into Deemix
try
	do shell script "osascript \"" & pasteScript & "\""
	display notification "Album added to Deemix" with title "Spotify Resolver"
on error errorMsg
	display alert "Error" message "Failed to paste into Deemix:" & return & errorMsg
	return
end try

on splitString(theString, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set theArray to text items of theString
	set AppleScript's text item delimiters to oldDelimiters
	return theArray
end splitString