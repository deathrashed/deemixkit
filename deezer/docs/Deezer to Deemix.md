---
title: "Deezer to Deemix"
description: "Search Deezer for albums and automatically download via Deemix (CLI and GUI interfaces)"
author: riley
category: [Audio, Music]
language: [Bash, AppleScript]
path: ".//"
created: "23rd January, 2026"
tags:
  - script
  - music
  - deezer
  - deemix
  - automation
  - download
  - cli
  - gui
---

# Deezer to Deemix

## Overview

A complete Deezer-to-Deemix automation toolkit with two interfaces: a lightweight Bash CLI wrapper for command-line power users and a native macOS AppleScript app with dialog prompts for quick searching. Both resolve Deezer album links (no credentials required) and automatically paste them into Deemix for downloading. Choose the interface that fits your workflow—quick CLI for scripting and keyboard shortcuts, or GUI dialogs for intuitive interaction.

## Quick Start

### CLI (Bash Wrapper)

```bash
./deezer-to-deemix.sh "Metallica" "Master of Puppets"
```

### GUI (AppleScript Dialog)

```bash
osascript ./deezer-to-deemix.applescript
```

## Interface Comparison

| Aspect | CLI (Bash) | GUI (AppleScript) |
|--------|-----------|-------------------|
| **Invocation** | Terminal/script | Terminal or double-click |
| **Input** | Command arguments | Native dialog prompt |
| **Feedback** | Console output | Notifications & alerts |
| **Speed** | Fastest | Slightly slower (dialog overhead) |
| **Best For** | Keyboard Maestro, scripts, automation | One-off searches, Dock access |
| **Learning Curve** | Need to remember format | Intuitive |
| **Errors** | Text messages | Alert dialogs |
| **Setup** | No credentials needed | No credentials needed |

## Bash Wrapper (CLI Interface)

### Usage

```bash
./deezer-to-deemix.sh "Artist Name" "Album Name"
```

**Examples**:
```bash
./deezer-to-deemix.sh "Pink Floyd" "The Wall"
./deezer-to-deemix.sh "The Beatles" "Abbey Road"
./deezer-to-deemix.sh "Radiohead" "OK Computer"
```

**Requirements**: 2 arguments (artist and album)

### Features

- Takes artist and album as command-line arguments
- Integrates Python resolver with Deemix pasting
- Includes error checking (exits if resolver fails)
- Strategic delays for clipboard and app readiness
- Perfect for keyboard shortcuts and automation
- No API credentials needed (free Deezer API)

### Integration Examples

**Keyboard Maestro Macro**:
```
Prompt user for Artist: $KMVAR_Artist
Prompt user for Album: $KMVAR_Album
Execute Shell Script: /path/to/DeemixKit/deezer/deezer-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
```

**From Another Script**:
```bash
#!/bin/bash
ARTIST="Metallica"
ALBUM="Master of Puppets"
/path/to/DeemixKit/deezer/deezer-to-deemix.sh "$ARTIST" "$ALBUM"
```

**Raycast Script**:
```bash
#!/bin/bash
# Raycast will prompt for parameters
/path/to/DeemixKit/deezer/deezer-to-deemix.sh "$artist" "$album"
```

### Source Code

```bash
#!/bin/bash

# Get artist and album from arguments
ARTIST="$1"
ALBUM="$2"

# Call Deezer resolver and copy to clipboard
python3 "/path/to/DeemixKit/deezer/deezer-resolver.py" --band "$ARTIST" --album "$ALBUM"

# Check if resolver succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to resolve Deezer link"
  exit 1
fi

# Wait for clipboard to be set
sleep 0.5

# Execute AppleScript to paste into Deemix
osascript "/path/to/DeemixKit/scripts/paste-to-deemix.applescript"

exit $?
```

## AppleScript Dialog (GUI Interface)

### Usage

```bash
osascript ./deezer-to-deemix.applescript
```

**Input Format**: Dialog prompts for "Artist - Album"

### Features

- Native macOS dialog interface (no terminal required)
- Single input field with placeholder text
- Automatic "Artist - Album" format parsing
- Error alerts for invalid input
- macOS notifications on success
- Can be saved as standalone .app application
- No API credentials needed

### Creating as Standalone App

1. Open **Script Editor** on macOS
2. Copy the source code below
3. Save as **"Deezer to Deemix"** with File Format: **Application**
4. Move to `/Applications` or your Dock
5. Double-click to run anytime

### Workflow

1. Run script → Dialog appears
2. Type in format: `Artist - Album` (e.g., "Metallica - Master of Puppets")
3. Click **OK**
4. Script searches Deezer, copies URL, opens Deemix, pastes link
5. Notification confirms completion

### Integration Examples

**Keyboard Maestro Macro**:
```
Execute Shell Script: osascript "/path/to/DeemixKit/deezer/deezer-to-deemix.applescript"
```

**Add to Dock** (as .app):
1. Save script as Application
2. Drag to Dock
3. Click to run anytime

### Source Code

```applescript
#!/usr/bin/env osascript

set scriptDir to "/path/to/DeemixKit"
set pythonScript to scriptDir & "/deezer/deezer-resolver.py"
set pasteScript to scriptDir & "/scripts/paste-to-deemix.applescript"

-- Single dialog with both inputs
try
	display dialog ¬
		"Enter your search:" default answer ¬
		"Artist - Album" with title ¬
		"Deezer to Deemix" buttons {"Cancel", "OK"} ¬
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

-- Run Deezer resolver
try
	do shell script "python3 \"" & pythonScript & "\" --band \"" & artist & "\" --album \"" & album & "\""
on error errorMsg
	display alert "Error" message "Failed to resolve Deezer link:" & return & errorMsg
	return
end try

delay 0.5

-- Run paste into Deemix
try
	do shell script "osascript \"" & pasteScript & "\""
	display notification "Album added to Deemix" with title "Deezer Resolver"
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
```

## Dependencies

**Bash Wrapper**:
- `bash` 4+
- `python3` in PATH
- `osascript` (standard macOS)
- `deezer-album-resolver.py` (in DeemixKit directory)
- `paste-to-deemix.applescript` (in DeemixKit directory)

**AppleScript**:
- macOS only
- System Events for keyboard automation
- Same Python and AppleScript dependencies as Bash version

**No API Credentials Needed**:
- Deezer uses a free, public API
- No configuration file required
- Works out of the box

**External Apps**:
- Deemix (desktop application)

## Examples

### CLI Examples

**Example 1: Classic metal album**
```bash
./deezer-to-deemix.sh "Metallica" "Master of Puppets"
# Output: ✅ Copied to clipboard: Metallica - Master of Puppets
#         https://www.deezer.com/album/...
#         (Deemix opens and downloads automatically)
```

**Example 2: From another script**
```bash
#!/bin/bash
albums=("Metallica:Master of Puppets" "Pink Floyd:The Wall" "The Beatles:Abbey Road")
for album in "${albums[@]}"; do
  IFS=':' read -r artist name <<< "$album"
  ./deezer-to-deemix.sh "$artist" "$name"
  sleep 2  # Wait between downloads
done
```

**Example 3: Keyboard Maestro workflow**
- Hotkey: Cmd+Shift+D
- Prompts for artist name
- Prompts for album name
- Runs bash wrapper with both variables
- Shows result notification

### GUI Examples

**Example 1: Interactive search**
1. Run: `osascript .//Deezer\ to\ Deemix.applescript`
2. Dialog appears with placeholder "Artist - Album"
3. Type: `Pink Floyd - The Wall`
4. Click OK
5. Notification confirms: "Album added to Deemix"

**Example 2: Invalid input handling**
1. Run script
2. Type: `Metallica` (missing album name)
3. Error alert: "Use format: Artist - Album"
4. User can retry or cancel

**Example 3: Dock integration**
1. Save as .app application
2. Drag to Dock
3. Click anytime for quick search
4. Dialog appears, search, done

**Example 4: Error handling**
```
Dialog → Album not found on Deezer
Alert: "Failed to resolve Deezer link: Album not found"
User tries different spelling or name
```

## Workflow Breakdown

Both interfaces follow this workflow:

| Step | Action | Time |
|------|--------|------|
| 1 | Get user input | ~1s (CLI args) or ~2s (dialog) |
| 2 | Call deezer-album-resolver.py | ~1s |
| 3 | - Search Deezer API | ~1s (no auth needed) |
| 4 | - Copy to clipboard | instant |
| 5 | Wait for clipboard | 0.5s |
| 6 | Call paste-to-deemix.applescript | ~6s |
| 7 | - Check/launch Deemix | ~1-2s |
| 8 | - Paste URL and submit | ~0.5s |
| 9 | - Wait for processing | ~5s |
| **Total** | | **~9-11 seconds** |

**Note**: Deezer resolver is ~1 second faster than Spotify (no token fetch needed)

## Advantages Over Spotify

| Feature | Deezer | Spotify |
|---------|--------|---------|
| **API Credentials** | Not required ✅ | Required ❌ |
| **Setup Time** | ~2 minutes | ~10 minutes |
| **Speed** | ~1s search | ~2s search |
| **Configuration** | Zero config | Needs config.json |
| **Ease of Use** | Simpler | More complex |

## Notes

### General
- **macOS Only**: Both use AppleScript and System Events
- **No Credentials Required**: Unlike Spotify, uses free public API
- **Deemix Must Be Installed**: Required for automation to work
- **Error Messages**: Bash shows text errors, AppleScript shows alert dialogs
- **Exit Codes**: Bash wrapper returns 0 on success, 1 on failure

### CLI (Bash)
- Requires exactly 2 arguments
- Perfect for scripting and keyboard shortcuts
- Can be piped or chained with other commands
- Fastest execution (no dialog overhead)
- Errors reported to stderr
- Simpler setup than Spotify version

### GUI (AppleScript)
- More user-friendly for one-off searches
- Can be saved as standalone .app
- Graceful error handling with alert dialogs
- Slightly slower due to dialog rendering
- Notifications provide visual feedback
- Best for quick, intuitive searching

## Troubleshooting

### "Failed to resolve Deezer link" (CLI)
Check that:
1. Artist and album names are correct
2. Album exists on Deezer (some regional restrictions may apply)
3. Network connection is working
4. Try simplifying the album name

### Error Alert "Failed to resolve Deezer link" (GUI)
Ensure:
1. Artist and album names are spelled correctly
2. Album is available on Deezer
3. Network connection is active

### "Failed to paste into Deemix" (Both)
Ensure:
1. Deemix is installed
2. System Events has accessibility permission
3. Try running from terminal with: `osascript "path/to/script.applescript"`

### Deemix Doesn't Open
1. Verify Deemix is installed and in standard location
2. Check System Preferences → Security & Privacy → Accessibility
3. Grant System Events permission if prompted

## Comparison: Deezer vs Spotify

**Choose Deezer if**:
- You want zero setup (no credentials)
- You prefer simplicity over configuration
- You like the Deezer music catalog
- You want slightly faster searches
- You don't want to create API credentials

**Choose Spotify if**:
- You want access to currently playing track (JS script)
- You're already a Spotify user
- You need more advanced search features
- You prefer the Spotify catalog

## Related Scripts

- **Deezer Album Resolver.py.md** - Core Python resolver with more options
- **Spotify to Deemix.md** - Equivalent for Spotify (requires API credentials)
- **Currently Playing Spotify to Deemix.js.md** - One-click download of current track
- **Paste to Deemix.applescript.md** - Reusable Deemix automation utility
- **DeemixKit.md** - Complete toolkit overview
