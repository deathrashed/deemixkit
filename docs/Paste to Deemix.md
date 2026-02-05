---
title: "Paste to Deemix"
description: "AppleScript to paste clipboard URL into Deemix and trigger download"
author: riley
category: [Audio, Music]
language: applescript
path: ".//paste-to-deemix.applescript"
created: "23rd January, 2026"
tags:
  - script
  - applescript
  - music
  - deemix
  - automation
  - macos
  - system-events
---

# Paste to Deemix

## Overview

An AppleScript utility that automates pasting a Spotify or Deezer album URL into Deemix for downloading. Handles application launching, keyboard automation, and window management. Used by both Spotify to Deemix and Deezer to Deemix wrapper scripts to provide a complete automated workflow.

## Features

- **Smart App Launch**: Checks if Deemix is running before launching
- **Keyboard Automation**: Uses System Events to simulate user keyboard input
- **Clipboard Integration**: Pastes URL from clipboard without manual intervention
- **Automated Submission**: Pastes URL
- **Clean Exit**: Hides Deemix window after submission
- **Timing Controls**: Includes strategic delays for app readiness and processing

## Dependencies

**macOS Only** - Uses AppleScript and System Events (macOS specific)

**Required Applications**:
- **Deemix** - Desktop application must be installed on the system
- **System Events** - Standard macOS utility

## Usage

### Standalone Usage

```bash
osascript .//paste-to-deemix.applescript
```

### From Bash Script

```bash
# Paste is called automatically by spotify-to-deemix.sh or deezer-to-deemix.sh
# URL should already be in clipboard before calling this script
```

### From Another AppleScript

```applescript
do shell script "osascript .//paste-to-deemix.applescript"
```

## Script Details

**File Path:** `.//paste-to-deemix.applescript`  
**Language:** AppleScript  
**Category:** Audio / Music

## Source Code

```applescript
tell application "System Events"
	set isRunning to false
	set appList to (get name of every process)
	if appList contains "Deemix" then set isRunning to true
end tell

if isRunning is false then
	tell application "Deemix" to activate
	delay 1
end if

tell application "Deemix" to activate
delay 0.5

tell application "System Events"
	keystroke "v" using command down
	delay 0.1
	key up command
	delay 5.0
	keystroke "h" using command down
end tell
```

## Examples

### Example 1: Manual Usage with Clipboard

```bash
# First copy a Deemix URL to clipboard manually
# Then run:
osascript .//paste-to-deemix.applescript

# Script will:
# 1. Check if Deemix is running
# 2. Launch Deemix if needed
# 3. Activate Deemix window
# 4. Paste URL (Cmd+V)
# 5. Hide Deemix (Cmd+H)
```

### Example 2: In a Bash Script

```bash
#!/bin/bash
# Get album URL from somewhere (resolver script copies to clipboard)
# Then call the paste script:
osascript .//paste-to-deemix.applescript
```

### Example 3: Complete Workflow

This script is typically used as the final step after a resolver:

```bash
#!/bin/bash
# 1. Resolve Spotify album to clipboard
python3 .//spotify-album-resolver.py --band "Metallica" --album "Master of Puppets"

# 2. Wait for clipboard to settle
sleep 0.5

# 3. Paste into Deemix
osascript .//paste-to-deemix.applescript
```

## Workflow Breakdown

| Step | Action | Delay | Purpose |
|------|--------|-------|---------|
| 1 | Check if Deemix running | - | Determine if launch needed |
| 2 | Launch Deemix | 1s | Wait for app to fully open |
| 3 | Activate Deemix | 0.5s | Ensure window is focused |
| 4 | Paste (Cmd+V) | 0.1s | Insert clipboard content |
| 5 | Key Up Cmd | 0.1s | Release modifier key |
| 6 | Wait | 5s | Allow download to process |
| 7 | Hide (Cmd+H) | - | Clean up window |

## Notes

- **macOS Only**: Uses AppleScript and System Events - not portable to other platforms
- **Requires Deemix**: Script assumes Deemix is installed on the system
- **Clipboard Dependency**: Script expects Spotify/Deezer URL to be in clipboard before execution
- **Keyboard Focus**: Requires focus capability - won't work with certain accessibility restrictions
- **Timing Critical**: Delays are tuned for typical system response times; may need adjustment on slower systems
- **System Events**: Requires permission to control System Events (may trigger accessibility prompts on first run)
- **Error Handling**: No explicit error handling; relies on System Events error reporting
- **5 Second Wait**: The 5 second delay after submission allows Deemix time to process the URL before hiding
- **Hidden Window**: Script hides Deemix at the end; user can manually show it again if needed

## Related Scripts

- `Spotify to Deemix.sh.md` - Bash wrapper that calls this script
- `Deezer to Deemix.sh.md` - Alternative wrapper for Deezer
- `Spotify to Deemix.applescript.md` - Standalone AppleScript version
- `Deezer to Deemix.applescript.md` - Standalone AppleScript version for Deezer
