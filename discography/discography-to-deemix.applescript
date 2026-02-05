#!/usr/bin/env osascript

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""

set pythonScript to scriptDir & "/discography-resolver.py"

-- Single dialog with both inputs
set artist to ""
set album to ""

try
	display dialog ¬
		"Enter your search:" default answer ¬
		"Artist - Album" with title ¬
		"Discography to Deemix" buttons {"Cancel", "OK"} ¬
		default button ¬
		"OK" cancel button "Cancel"

	set dialogResult to result
	set input to text returned of dialogResult

	if input contains " - " then
		set inputParts to my splitString(input, " - ")
		if (count of inputParts) ≥ 2 then
			set artist to item 1 of inputParts
			set album to item 2 of inputParts
		end if
	end if

	if artist is "" or album is "" then
		display alert "Error" message "Use format: Artist - Album"
		return
	end if
on error
	return
end try

-- Make sure we have valid input before proceeding
if artist is "" or album is "" then
	return
end if

-- Run discography resolver and capture URLs
set urlList to ""
try
	set urlList to do shell script "python3 \"" & pythonScript & "\" --band \"" & artist & "\" --album \"" & album & "\" 2>/dev/null"
on error errorMsg
	display alert "Error" message "Failed to resolve discography:" & return & errorMsg
	return
end try

-- Split URLs into list
set urlLines to paragraphs of urlList

if (count of urlLines) is 0 then
	display alert "Error" message "No albums found in discography"
	return
end if

-- Confirm before proceeding
set albumCount to count of urlLines
set shouldProceed to false
try
	display dialog "Found " & albumCount & " albums (EPs + Albums only). Copy all to clipboard?" with title "Discography to Deemix" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel"
	set shouldProceed to true
on error
	set shouldProceed to false
end try

if shouldProceed is false then
	return
end if

-- Join URLs with newlines and copy to clipboard
set allURLs to ""
repeat with i from 1 to count of urlLines
	set currentURL to item i of urlLines
	if currentURL is not "" then
		if allURLs is "" then
			set allURLs to currentURL
		else
			set allURLs to allURLs & return & currentURL
		end if
	end if
end repeat

-- Copy all URLs to clipboard at once
set the clipboard to allURLs

-- Notify user
display notification albumCount & " album URLs copied to clipboard!" with title "Discography Resolver"

on splitString(theString, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set theArray to text items of theString
	set AppleScript's text item delimiters to oldDelimiters
	return theArray
end splitString
