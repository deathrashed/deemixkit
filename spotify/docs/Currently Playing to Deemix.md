---
title: "Currently Playing Spotify to Deemix"
description: "Get currently playing Spotify track and open album in Deemix for downloading"
author: riley
category: [Audio, Music]
language: javascript
path: ".//currently-playing-spotify-to-deemix.js"
created: "23rd January, 2026"
tags:
  - script
  - javascript
  - nodejs
  - music
  - spotify
  - deemix
  - automation
  - applescript
---

# Currently Playing Spotify to Deemix

## Overview

A Node.js script that retrieves the currently playing track from Spotify, looks up the album using Spotify's Web API, and automatically opens the album in Deemix for downloading. Perfect for one-click downloading of the album you're listening to right now. Uses AppleScript to detect currently playing tracks and Spotify API for album lookups.

## Features

- **Current Track Detection**: Monitors what's currently playing in Spotify via AppleScript
- **Spotify API Integration**: Uses official Spotify Web API with Client Credentials authentication
- **Album Lookup**: Retrieves full album information from track metadata
- **Deemix Automation**: Automatically opens Deemix and pastes the Spotify album URL
- **Clipboard Integration**: Copies album URL to clipboard (pbcopy on macOS)
- **Smart Error Handling**: Gracefully handles no-track-playing scenarios
- **One-Command Workflow**: Single Node.js execution for complete automation

## Dependencies

**Node.js 14+** - Required for ES module syntax

**System Requirements**:
- **macOS Only** - Uses AppleScript integration with Spotify
- **Spotify Application** - Must be installed and currently playing audio
- **Deemix** - Desktop application must be installed
- **curl** - Standard macOS command-line tool

**No External Packages** - Uses only Node.js built-in `child_process` module

## Usage

### Basic Usage

```bash
node .//currently-playing-spotify-to-deemix.js
```

### In Terminal (make executable)

```bash
chmod +x .//currently-playing-spotify-to-deemix.js
.//currently-playing-spotify-to-deemix.js
```

### From Keyboard Maestro

```
Execute Shell Script: node "/path/to/DeemixKit/spotify/currently-playing-to-deemix.js"
```

### From Raycast Script

```bash
#!/bin/bash
node "/path/to/DeemixKit/spotify/currently-playing-to-deemix.js"
```

## Script Details

**File Path:** `.//currently-playing-spotify-to-deemix.js`  
**Language:** JavaScript (Node.js)  
**Category:** Audio / Music

## Source Code

```javascript
import { execSync } from "child_process";

// Spotify credentials
const CLIENT_ID = "fd98249e14764c1f8183be7f7553bd0e";
const CLIENT_SECRET = "629e21c01c0344528605d2db82ea52ea";

// Get access token
function getAccessToken() {
    const response =
        execSync(`curl -s -X POST "https://accounts.spotify.com/api/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"`);
    return JSON.parse(response.toString()).access_token;
}

// Get current track info
const applescriptTrack = `
tell application "Spotify"
  if player state is playing then
    set trackName to name of current track
    set artistName to artist of current track
    return trackName & "|||" & artistName
  else
    return "No song playing"
  end if
end tell
`;

let songInfo = execSync(`osascript -e '${applescriptTrack}'`).toString().trim();
if (songInfo === "No song playing") {
    console.error("🎵 No song is currently playing.");
    process.exit(0);
}

const [track, artist] = songInfo.split("|||");
const query = encodeURIComponent(`${track} artist:${artist}`);
const token = getAccessToken();
const searchUrl = `https://api.spotify.com/v1/search?q=${query}&type=track&limit=1`;

const response = execSync(
    `curl -s -H "Authorization: Bearer ${token}" "${searchUrl}"`
);
const trackData = JSON.parse(response.toString())?.tracks?.items?.[0];

if (!trackData || !trackData.album) {
    console.error("⚠️ Could not find album info.");
    process.exit(1);
}

const albumLink = trackData.album.external_urls.spotify;
execSync(`printf '${albumLink}' | pbcopy`);

// AppleScript to paste into Deemix
const pasteScript = `
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
  delay 0.3
  keystroke "h" using command down
end tell
`;

execSync(`osascript -e '${pasteScript}'`);

console.log(`🫟 🫟 🫟 🫟 🫟`);
```

## Examples

### Example 1: One-Click Download Current Track

1. Playing: "Master of Puppets" by Metallica in Spotify
2. Run: `node .//Currently\ Playing\ Spotify\ to\ Deemix.js`
3. Output: `🫟 🫟 🫟 🫟 🫟`
4. Deemix opens and starts downloading the album automatically

### Example 2: Keyboard Maestro Macro

Create a macro that triggers on a hotkey:

```
Display Text: "Checking Spotify..."
Execute Shell Script: node "/path/to/DeemixKit/spotify/currently-playing-to-deemix.js"
Display Text: "Album added to Deemix!"
```

### Example 3: From Terminal with Loop

```bash
# Keep checking Spotify and downloading currently playing albums
while true; do
  node .//currently-playing-spotify-to-deemix.js
  sleep 30  # Check every 30 seconds
done
```

### Example 4: No Track Playing

```bash
$ node .//currently-playing-spotify-to-deemix.js
🎵 No song is currently playing.

# Script exits gracefully without errors
```

## Workflow Breakdown

| Step | Tool | Action | Output |
|------|------|--------|--------|
| 1 | AppleScript | Get current track from Spotify | "Track Name \\|\\|\\| Artist Name" |
| 2 | Spotify API | Get access token | OAuth bearer token |
| 3 | Spotify API | Search for track/album | Album object with URL |
| 4 | pbcopy | Copy album URL to clipboard | Silent (clipboard updated) |
| 5 | AppleScript | Open/focus Deemix | Deemix window focused |
| 6 | AppleScript | Paste URL and submit | Download initiated |
| 7 | Script | Show completion | 🫟 emoji feedback |

## Notes

- **macOS Only**: Uses AppleScript and System Events - requires macOS
- **Spotify Must Be Playing**: Script checks if Spotify is playing; exits gracefully if not
- **API Credentials Hardcoded**: Client ID and Secret are embedded in the script (consider environment variables for security)
- **No NPM Dependencies**: Uses only Node.js built-in modules - no npm install needed
- **ES Module Syntax**: Uses `import` statements - ensure Node.js ES modules are enabled
- **Curl Required**: Uses curl for Spotify API calls - standard on macOS
- **Deemix Launch**: Automatically opens Deemix if not running; focuses window if already open
- **Exit Codes**: 0 on success, 1 if album not found, 0 if no track playing (graceful)
- **Output Emojis**: 🎵 = no track, ⚠️ = album not found, 🫟 = success
- **Error Output**: Errors go to stderr; use `2>&1` to capture if needed

## Configuration

**API Credentials** - Currently hardcoded:
```javascript
const CLIENT_ID = "fd98249e14764c1f8183be7f7553bd0e";
const CLIENT_SECRET = "629e21c01c0344528605d2db82ea52ea";
```

To use environment variables instead:
```javascript
const CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;
const CLIENT_SECRET = process.env.SPOTIFY_CLIENT_SECRET;
```

Then set in terminal:
```bash
export SPOTIFY_CLIENT_ID="your_id"
export SPOTIFY_CLIENT_SECRET="your_secret"
```

## Related Scripts

- `Spotify Album Resolver.py.md` - Python version with more options
- `Spotify to Deemix.sh.md` - Bash wrapper for manual artist/album input
- `Spotify to Deemix.applescript.md` - AppleScript version with dialog interface
- `Paste to Deemix.applescript.md` - Reusable Deemix pasting utility
