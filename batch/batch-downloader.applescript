#!/usr/bin/env osascript

# Batch Downloader - GUI Dialog Version
# Prompts for file and downloads albums from the list using bulk paste

-- Get the directory where this script is located
tell application "System Events"
	set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""

-- Get resolver path
set deezerResolver to scriptDir & "/../deezer/deezer-resolver.py"
set spotifyResolver to scriptDir & "/../spotify/spotify-resolver.py"
set pasteScript to scriptDir & "/../scripts/paste-to-deemix.applescript"

-- Function to split string
on splitString(theString, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set theArray to text items of theString
	set AppleScript's text item delimiters to oldDelimiters
	return theArray
end splitString

-- Function to read file
on readFile(filePath)
	try
		set fileContent to do shell script "cat " & quoted form of filePath
		return fileContent
	on error errorMsg
		return ""
	end try
end readFile

-- Prompt for file path
try
	set filePath to text returned of (display dialog "Enter path to file containing albums:" default answer (scriptDir & "/albums.txt") buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" with title "Batch Downloader")
on error
	return
end try

-- Check if file exists
set fileExists to do shell script "test -f " & quoted form of filePath & " && echo yes || echo no"
if fileExists is not "yes" then
	display alert "File Not Found" message "The file '" & filePath & "' does not exist." buttons {"OK"} as critical
	return
end if

-- Prompt for service
set serviceChoice to button returned of (display dialog "Which service to use?" buttons {"Spotify", "Deezer"} default button "Deezer" with title "Batch Downloader")

if serviceChoice is "Deezer" then
	set resolverPath to deezerResolver
	set serviceName to "Deezer"
else
	set resolverPath to spotifyResolver
	set serviceName to "Spotify"
end if

-- Prompt for delay
set delayText to text returned of (display dialog "Delay between resolver calls (seconds):" default answer "10" buttons {"OK"} default button "OK" with title "Batch Downloader")
set downloadDelay to delayText as integer

-- Read file
set fileContent to readFile(filePath)

if fileContent is "" then
	display alert "Error" message "Could not read file or file is empty." buttons {"OK"} as critical
	return
end if

-- Count lines (excluding comments and empty)
set lineCount to do shell script "echo " & quoted form of fileContent & " | grep -v '^#' | grep -v '^[[:space:]]*$' | wc -l | tr -d ' '"

if lineCount is "0" then
	display alert "No Albums Found" message "No valid albums found in the file." buttons {"OK"} as warning
	return
end if

-- Confirm
set shouldProceed to button returned of (display dialog "Found " & lineCount & " albums to download using " & serviceName & ". Proceed?" buttons {"Cancel", "Start"} default button "Start" with title "Batch Downloader")

if shouldProceed is not "Start" then
	return
end if

-- Process each line and collect URLs
set allLines to paragraphs of fileContent
set allURLs to {}
set successCount to 0
set failCount to 0
set totalCount to 0

repeat with currentLine in allLines
	-- Trim whitespace
	set currentLine to do shell script "echo " & quoted form of currentLine & " | xargs"

	-- Skip comments and empty lines
	if currentLine starts with "#" or currentLine is "" then
	else
		set totalCount to totalCount + 1

		-- Parse line - try different separators
		set artistName to ""
		set albumName to ""

		-- Try " - " separator
		if currentLine contains " - " then
			set parts to splitString(currentLine, " - ")
			if (count of parts) ≥ 2 then
				set artistName to item 1 of parts
				set albumName to item 2 of parts
			end if
		-- Try ":" separator
		else if currentLine contains ":" then
			set parts to splitString(currentLine, ":")
			if (count of parts) ≥ 2 then
				set artistName to item 1 of parts
				set albumName to item 2 of parts
			end if
		-- Try space separator
		else if (count of words of currentLine) ≥ 2 then
			set artistName to word 1 of currentLine
			set albumName to (text 1 ((length of (word 1 of currentLine)) + 1) thru -1 of currentLine)
		end if

		-- Trim whitespace
		set artistName to do shell script "echo " & quoted form of artistName & " | xargs"
		set albumName to do shell script "echo " & quoted form of albumName & " | xargs"

		if artistName is "" or albumName is "" then
			set failCount to failCount + 1
		else
			-- Show progress
			display notification "Resolving (" & totalCount & " of " & lineCount & "): " & artistName & " - " & albumName with title "Batch Downloader"

			-- Run resolver
			try
				set resolverOutput to do shell script "python3 " & quoted form of resolverPath & " --band " & quoted form of artistName & " --album " & quoted form of albumName & " --no-clipboard 2>&1"

				-- Extract URL from output (supports both Deezer and Spotify)
				set theURL to do shell script "echo " & quoted form of resolverOutput & " | grep -E 'https://(www\\.)?deezer\\.com/album/[0-9]+|https://open\\.spotify\\.com/album/[a-zA-Z0-9]+' | head -1"

				if theURL is not "" then
					-- Add to list
					set end of allURLs to theURL
					set successCount to successCount + 1

					-- Wait before next resolver call (but not after last one)
					if totalCount < (lineCount as integer) then
						do shell script "sleep " & downloadDelay
					end if
				else
					set failCount to failCount + 1
				end if
			on error
				set failCount to failCount + 1
			end try
		end if
	end if
end repeat

-- Summary and bulk paste
if (count of allURLs) > 0 then
	-- Join all URLs with newlines
	set allURLsText to ""
	repeat with i from 1 to count of allURLs
		if i is 1 then
			set allURLsText to item i of allURLs
		else
			set allURLsText to allURLsText & return & (item i of allURLs)
		end if
	end repeat

	-- Copy all URLs to clipboard at once
	do shell script "echo " & quoted form of allURLsText & " | pbcopy"

	-- Paste to Deemix once
	do shell script "osascript " & quoted form of pasteScript

	-- Show success dialog
	display dialog "Batch Download Complete!

Total albums: " & totalCount & "
Successful: " & successCount & "
Failed: " & failCount & "

All " & successCount & " album URLs were copied to clipboard and pasted to Deemix.
Check Deemix for your downloads." buttons {"OK"} with title "Batch Downloader" with icon note
else
	-- Show failure dialog
	display dialog "Batch Download Failed

No albums could be resolved. Please check:
- File format is correct (Artist - Album)
- Network connection is working
- Service (" & serviceName & ") is available" buttons {"OK"} with title "Batch Downloader" with icon stop
end if
