---
title: "Keyboard Maestro DeemixKit"
description: "Keyboard Maestro macros for DeemixKit automation workflows"
author: riley
category: [Audio, Music, Automation]
language: [AppleScript, Shell]
path: ".//"
created: "23rd January, 2026"
tags:
  - keyboard-maestro
  - macros
  - music
  - spotify
  - deezer
  - deemix
  - automation
---

# Keyboard Maestro DeemixKit

## Overview

Keyboard Maestro macros provide the most convenient way to use DeemixKit workflows. With a single hotkey, you can prompt for artist/album input and have the album automatically resolved and queued in Deemix for download.

## Macros

### Deezer Link to Deemix

A macro that prompts for artist and album name, resolves the Deezer album link, and automatically pastes it into Deemix for download.

**Macro Actions:**

1. **Prompt for User Input** - "Deezer Link to Deemix"
   - Type: Text fields for band and album
   - Variables:
     - `Artist` - Band/artist name
     - `Album` - Album name
   - Buttons:
     - `OK` - Proceed with search
     - `Cancel` - Cancel macro

2. **Execute Shell Script**
   ```bash
   python3 /path/to/DeemixKit/deezer-resolver.py --band "$KMVAR_Artist" --album "$KMVAR_Album"
   ```
   - Stop macro and notify on failure

3. **Display Text Briefly**
   - Text: `Copied.`

4. **Execute AppleScript**
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
       keystroke "a" using command down
       delay 0.1
       keystroke "v" using command down
       delay 0.1
       key up command
       delay 0.1
       keystroke return
       delay 5.0
       keystroke "h" using command down
   end tell
   ```
   - Stop macro and notify on failure

5. **Display Text Briefly**
   - Text: `Added to Deemix.`

### Spotify Link to Deemix

A macro that prompts for artist and album name, resolves the Spotify album link, and automatically pastes it into Deemix for download.

**Macro Actions:**

1. **Prompt for User Input** - "Spotify Link to Deemix"
   - Type: Text fields for band and album
   - Variables:
     - `Artist` - Band/artist name
     - `Album` - Album name
   - Buttons:
     - `OK` - Proceed with search
     - `Cancel` - Cancel macro

2. **Execute Shell Script**
   ```bash
   python3 /path/to/DeemixKit/spotify-resolver.py --band "$KMVAR_Artist" --album "$KMVAR_Album"
   ```
   - Stop macro and notify on failure

3. **Display Text Briefly**
   - Text: `Copied.`

4. **Execute AppleScript**
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
       keystroke "a" using command down
       delay 0.1
       keystroke "v" using command down
       delay 0.1
       key up command
       delay 0.1
       keystroke return
       delay 5.0
       keystroke "h" using command down
   end tell
   ```
   - Stop macro and notify on failure

5. **Display Text Briefly**
   - Text: `Added to Deemix.`

## Shell Script Macros

For simpler macros that call the existing bash wrapper scripts directly, you can use these alternative approaches.

### Deezer to Deemix (Shell Script Macro)

Uses the `deezer-to-deemix.sh` wrapper which handles both resolution and pasting.

**Macro Actions:**

1. **Prompt for User Input** - "Deezer to Deemix"
   - Variables: `Artist`, `Album`
   - Buttons: `OK`, `Cancel`

2. **Execute Shell Script**
   ```bash
   /path/to/DeemixKit/deezer-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
   ```
   - Stop macro and notify on failure

3. **Display Text Briefly**
   - Text: `Album queued in Deemix.`

### Spotify to Deemix (Shell Script Macro)

Uses the `spotify-to-deemix.sh` wrapper which handles both resolution and pasting.

**Macro Actions:**

1. **Prompt for User Input** - "Spotify to Deemix"
   - Variables: `Artist`, `Album`
   - Buttons: `OK`, `Cancel`

2. **Execute Shell Script**
   ```bash
   /path/to/DeemixKit/spotify-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
   ```
   - Stop macro and notify on failure

3. **Display Text Briefly**
   - Text: `Album queued in Deemix.`

## Comparison: Python vs Shell Script Approaches

| Aspect | Python Resolver + AppleScript | Shell Script Wrapper |
|--------|------------------------------|---------------------|
| **Control** | Full control over each step | Single command |
| **Feedback** | Multiple status messages | Single message |
| **Customization** | Can modify AppleScript delays | Fixed behavior |
| **Debugging** | Easier to identify failing step | Less granular |
| **Simplicity** | More actions to configure | Fewer actions |

**Recommendation**: Use the Python resolver approach when you want fine-grained control or custom behavior. Use the shell script wrapper for simpler, faster setup.

## Script Paths Reference

| Script | Path | Purpose |
|--------|------|---------|
| Deezer Resolver | `/path/to/DeemixKit/deezer-resolver.py` | Resolve Deezer album links |
| Spotify Resolver | `/path/to/DeemixKit/spotify-resolver.py` | Resolve Spotify album links |
| Deezer Wrapper | `/path/to/DeemixKit/deezer-to-deemix.sh` | Full Deezer workflow |
| Spotify Wrapper | `/path/to/DeemixKit/spotify-to-deemix.sh` | Full Spotify workflow |
| Paste Utility | `/path/to/DeemixKit/paste-to-deemix.applescript` | Paste clipboard to Deemix |

## AppleScript Breakdown

The AppleScript used in the macros performs these steps:

1. **Check if Deemix is running** - Queries System Events for running processes
2. **Launch Deemix if needed** - Activates the app and waits for it to load
3. **Activate Deemix** - Brings it to the foreground
4. **Select All (⌘A)** - Selects any existing text in the URL field
5. **Paste (⌘V)** - Pastes the album URL from clipboard
6. **Press Return** - Submits the URL to start the download
7. **Wait for processing** - 5 second delay for Deemix to process
8. **Hide Deemix (⌘H)** - Hides the app to return to previous context

## Setup Instructions

### Creating the Deezer Macro

1. Open Keyboard Maestro
2. Create a new macro in your preferred group
3. Name it "Deezer Link to Deemix"
4. Set your preferred trigger (hotkey, typed string, etc.)
5. Add actions in order:
   - **Prompt for User Input**
     - Window Title: "Deezer Link to Deemix"
     - Add variable: `Artist` (Text Field)
     - Add variable: `Album` (Text Field)
     - Buttons: OK, Cancel (cancel macro)
   - **Execute Shell Script**
     - Script: `python3 /path/to/DeemixKit/deezer-resolver.py --band "$KMVAR_Artist" --album "$KMVAR_Album"`
     - Check: "Abort macro on shell script error"
   - **Display Text Briefly**: `Copied.`
   - **Execute AppleScript**: (paste the AppleScript above)
     - Check: "Abort macro on script error"
   - **Display Text Briefly**: `Added to Deemix.`

### Creating the Spotify Macro

Follow the same steps as above, but:
- Name it "Spotify Link to Deemix"
- Use the Spotify resolver path: `/path/to/DeemixKit/spotify-resolver.py`

### Creating Shell Script Macros

For simpler setup:
1. Create new macro
2. Add **Prompt for User Input** with `Artist` and `Album` variables
3. Add **Execute Shell Script** with the appropriate wrapper script
4. Add **Display Text Briefly** for confirmation

## Suggested Hotkeys

| Macro | Suggested Hotkey |
|-------|-----------------|
| Deezer Link to Deemix | `⌃⌥⌘D` (Control+Option+Command+D) |
| Spotify Link to Deemix | `⌃⌥⌘S` (Control+Option+Command+S) |

## Troubleshooting

### "Failed to resolve link" Error

- Verify the artist and album names are correct
- Check network connection
- For Spotify: Ensure credentials are configured in `~/.config/spotify-resolver/config.json`

### Deemix Doesn't Receive the Link

- Ensure Deemix is installed
- Check that System Events has accessibility permissions
- Try increasing the delays in the AppleScript

### Macro Stops at Shell Script

- Run the script manually in Terminal to check for errors
- Verify Python 3 is installed and in PATH
- Check that required Python packages are installed (`requests`, `pyperclip`)

## Related Documentation

- `DeemixKit.md` - Master overview of all DeemixKit scripts
- `Deezer Resolver.md` - Python resolver documentation
- `Spotify Resolver.md` - Python resolver documentation
- `Deezer to Deemix.md` - Shell wrapper documentation
- `Spotify to Deemix.md` - Shell wrapper documentation
