---
title: "Spotify to Deemix"
description: "Search Spotify for albums and automatically download via Deemix (CLI and GUI interfaces)"
author: riley
category: [Audio, Music]
language: [Bash, AppleScript]
path: ".//"
created: "23rd January, 2026"
tags:
  - script
  - music
  - spotify
  - deemix
  - automation
  - download
  - cli
  - gui
---

# Spotify to Deemix

## Overview

A complete Spotify-to-Deemix automation toolkit with two interfaces: a lightweight Bash CLI wrapper for command-line power users and a native macOS AppleScript app with dialog prompts for quick searching. Both resolve Spotify album links and automatically paste them into Deemix for downloading. Choose the interface that fits your workflow—quick CLI for scripting and keyboard shortcuts, or GUI dialogs for intuitive interaction.

## Quick Start

### CLI (Bash Wrapper)

```bash
.//spotify-to-deemix.sh "Metallica" "Master of Puppets"
```

### GUI (AppleScript Dialog)

```bash
osascript .//spotify-to-deemix.applescript
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

## Bash Wrapper (CLI Interface)

### Usage

```bash
.//spotify-to-deemix.sh "Artist Name" "Album Name"
```

**Examples**:
```bash
.//spotify-to-deemix.sh "Pink Floyd" "The Wall"
.//spotify-to-deemix.sh "The Beatles" "Abbey Road"
.//spotify-to-deemix.sh "Radiohead" "OK Computer"
```

**Requirements**: 2 arguments (artist and album)

### Features

- Takes artist and album as command-line arguments
- Integrates Python resolver with Deemix pasting
- Includes error checking (exits if resolver fails)
- Strategic delays for clipboard and app readiness
- Perfect for keyboard shortcuts and automation

### Integration Examples

**Keyboard Maestro Macro**:
```
Prompt user for Artist: $KMVAR_Artist
Prompt user for Album: $KMVAR_Album
Execute Shell Script: /path/to/DeemixKit/spotify/spotify-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
```

**From Another Script**:
```bash
#!/bin/bash
ARTIST="Metallica"
ALBUM="Master of Puppets"
/path/to/DeemixKit/spotify/spotify-to-deemix.sh "$ARTIST" "$ALBUM"
```

**Raycast Script**:
```bash
#!/bin/bash
# Raycast will prompt for parameters
/path/to/DeemixKit/spotify/spotify-to-deemix.sh "$artist" "$album"
```

### Source Code

```bash
#!/bin/bash

# Get artist and album from arguments
ARTIST="$1"
ALBUM="$2"

# Call Spotify resolver and copy to clipboard
python3 "/path/to/DeemixKit/spotify/spotify-resolver.py" --band "$ARTIST" --album "$ALBUM"

# Check if resolver succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to resolve Spotify link"
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
osascript .//spotify-to-deemix.applescript
```

**Input Format**: Dialog prompts for "Artist - Album"

### Features

- Native macOS dialog interface (no terminal required)
- Single input field with placeholder text
- Automatic "Artist - Album" format parsing
- Error alerts for invalid input
- macOS notifications on success
- Can be saved as standalone .app application

### Creating as Standalone App

1. Open **Script Editor** on macOS
2. Copy the source code below
3. Save as **"Spotify to Deemix"** with File Format: **Application**
4. Move to `/Applications` or your Dock
5. Double-click to run anytime

### Workflow

1. Run script → Dialog appears
2. Type in format: `Artist - Album` (e.g., "Metallica - Master of Puppets")
3. Click **OK**
4. Script searches Spotify, copies URL, opens Deemix, pastes link
5. Notification confirms completion

### Integration Examples

**Keyboard Maestro Macro**:
```
Execute Shell Script: osascript "/path/to/DeemixKit/spotify/spotify-to-deemix.applescript"
```

**Add to Dock** (as .app):
1. Save script as Application
2. Drag to Dock
3. Click to run anytime

### Source Code

```applescript
#!/usr/bin/env osascript

set scriptDir to "/Users/rd/Scripts/Riley/Audio/DeemixKit"
set pythonScript to scriptDir & "/spotify-album-resolver.py"
set pasteScript to scriptDir & "/paste-to-deemix.applescript"

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
```

## Dependencies

**Bash Wrapper**:
- `bash` 4+
- `python3` in PATH
- `osascript` (standard macOS)
- `spotify-album-resolver.py` (in DeemixKit directory)
- `paste-to-deemix.applescript` (in DeemixKit directory)

**AppleScript**:
- macOS only
- System Events for keyboard automation
- Same Python and AppleScript dependencies as Bash version

**Spotify API Credentials** (required by both):
- Create `~/.config/spotify-resolver/config.json`:
  ```json
  {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }
  ```

**External Apps**:
- Deemix (desktop application)
- Spotify (for currently playing detection, not required for manual search)

## Examples

### CLI Examples

**Example 1: Classic metal album**
```bash
.//spotify-to-deemix.sh "Metallica" "Master of Puppets"
# Output: ✅ Copied to clipboard: Metallica - Master of Puppets
#         https://open.spotify.com/album/...
#         (Deemix opens and downloads automatically)
```

**Example 2: From another script**
```bash
#!/bin/bash
albums=("Metallica:Master of Puppets" "Pink Floyd:The Wall" "The Beatles:Abbey Road")
for album in "${albums[@]}"; do
  IFS=':' read -r artist name <<< "$album"
  .//spotify-to-deemix.sh "$artist" "$name"
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
1. Run: `osascript .//Spotify\ to\ Deemix.applescript`
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
Dialog → Invalid Spotify credentials
Alert: "Failed to resolve Spotify link: 401 Unauthorized"
User fixes credentials, tries again
```

## Workflow Breakdown

Both interfaces follow this workflow:

| Step | Action | Time |
|------|--------|------|
| 1 | Get user input | ~1s (CLI args) or ~2s (dialog) |
| 2 | Call spotify-album-resolver.py | ~2s |
| 3 | - Get Spotify token | ~1s |
| 4 | - Search Spotify API | ~1s |
| 5 | - Copy to clipboard | instant |
| 6 | Wait for clipboard | 0.5s |
| 7 | Call paste-to-deemix.applescript | ~6s |
| 8 | - Check/launch Deemix | ~1-2s |
| 9 | - Paste URL and submit | ~0.5s |
| 10 | - Wait for processing | ~5s |
| **Total** | | **~10-12 seconds** |

## Notes

### General
- **macOS Only**: Both use AppleScript and System Events
- **Spotify Credentials Required**: API credentials must be configured in config.json
- **Deemix Must Be Installed**: Required for automation to work
- **Error Messages**: Bash shows text errors, AppleScript shows alert dialogs
- **Exit Codes**: Bash wrapper returns 0 on success, 1 on failure

### CLI (Bash)
- Requires exactly 2 arguments
- Perfect for scripting and keyboard shortcuts
- Can be piped or chained with other commands
- Fastest execution (no dialog overhead)
- Errors reported to stderr

### GUI (AppleScript)
- More user-friendly for one-off searches
- Can be saved as standalone .app
- Graceful error handling with alert dialogs
- Slightly slower due to dialog rendering
- Notifications provide visual feedback

## Troubleshooting

### "Spotify API credentials not configured" Error
**CLI/GUI**: Create `~/.config/spotify-resolver/config.json` with your API credentials

### "Failed to resolve Spotify link" (CLI)
Check that:
1. Artist and album names are correct
2. Spotify credentials are valid
3. Network connection is working

### Error Alert "Failed to paste into Deemix" (GUI)
Ensure:
1. Deemix is installed
2. System Events has accessibility permission
3. Try running from terminal with: `osascript "path/to/script.applescript"`

### Deemix Doesn't Open
1. Verify Deemix is installed and in standard location
2. Check System Preferences → Security & Privacy → Accessibility
3. Grant System Events permission if prompted

## Related Scripts

- **Spotify Album Resolver.py.md** - Core Python resolver with more options
- **Currently Playing Spotify to Deemix.js.md** - One-click download of current track
- **Deezer to Deemix.md** - Equivalent for Deezer
- **Paste to Deemix.applescript.md** - Reusable Deemix automation utility
- **DeemixKit.md** - Complete toolkit overview
