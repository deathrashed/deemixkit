# DeemixKit - Agent Guide

This guide helps AI agents understand and work effectively with the DeemixKit codebase.

## Project Overview

DeemixKit is a collection of macOS scripts and tools for integrating music services (Spotify, Deezer, Last.fm) with the Deemix desktop application. The project enables easy music downloading and library management through multiple interfaces.

### Key Characteristics

- **Platform**: macOS only (requires AppleScript, System Events, pbcopy/pbpaste)
- **Architecture**: Multi-language (Python, Node.js, Bash, AppleScript)
- **Purpose**: Music service integration and album downloading
- **Interface Types**: CLI, GUI dialogs, Keyboard Maestro macros

## Project Structure

```
DeemixKit/
├── *.py                 # Python resolvers (core logic)
├── *.js                 # Node.js scripts (Spotify integration)
├── *.sh                 # Bash wrappers for Python scripts
├── *.applescript        # GUI dialogs and automation
├── *.md                # Documentation files
├── .gitignore           # Git ignore rules
├── credentials.json.example  # Credentials template
└── macros/             # Keyboard Maestro macro files
```

## Script Types and Patterns

### Python Resolvers (`*-resolver.py`)

These are the core scripts that handle API communication and data retrieval.

**Naming Convention:** `<service>-resolver.py` or `<functionality>-resolver.py`

**Standard Pattern:**

```python
#!/usr/bin/env python3
"""
Brief Description

Version: X.Y.Z
Author: <name>
Created: <date>
"""

# Imports (standard order)
import sys
import json
import logging
import argparse
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any, List
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Configuration paths (XDG Base Directory)
CONFIG_DIR = Path.home() / ".config" / "<script-name>"
CONFIG_FILE = CONFIG_DIR / "config.json"
CREDENTIALS_FILE = Path.home() / ".config" / "deemixkit" / "credentials.json"
LOG_DIR = Path.home() / ".local" / "log" / "<script-name>"
LOG_FILE = LOG_DIR / "<script-name>.log"

# API endpoints/constants
API_URL = "https://api.example.com/endpoint"

# Functions: setup_logging, load_config, create_session, main functions, etc.

if __name__ == "__main__":
    main()
```

**Key Functions:**
- `setup_logging(verbose: bool)` - Configure logging to file and optionally stderr
- `load_config(config_file: Optional[Path])` - Load config from file with defaults
- `create_session(config: Dict[str, Any])` - Create requests session with retry strategy
- `search_*` functions - API interaction logic
- `parse_input(args: argparse.Namespace)` - Handle CLI input (args, stdin, interactive)
- `main()` - Entry point with argparse setup

**Exit Codes:**
- `0` - Success
- `1` - Error
- `130` - Keyboard interrupt (Ctrl+C)

### Bash Wrappers (`*-to-deemix.sh`)

Lightweight CLI wrappers that call Python resolvers and handle clipboard/AppleScript operations.

**Standard Pattern:**

```bash
#!/bin/bash

# Get arguments
ARTIST="$1"
ALBUM="$2"

# Call Python resolver
python3 "/path/to/resolver.py" --band "$ARTIST" --album "$ALBUM"

# Check exit code
if [ $? -ne 0 ]; then
  echo "Error: Failed" >&2
  exit 1
fi

# Wait for clipboard
sleep 0.5

# Execute AppleScript to paste into Deemix
osascript "/path/to/paste-to-deemix.applescript"

exit $?
```

**Notes:**
- Redirect stderr to console with `>&2`
- Use `pbcopy` for clipboard operations (macOS built-in)
- Call AppleScript utilities for GUI automation

### AppleScript Files (`*.applescript`)

Two types of AppleScript files:

**1. GUI Dialog Wrappers (`*-to-deemix.applescript`)**

```applescript
#!/usr/bin/env osascript

set scriptDir to "/path/to/DeemixKit"
set pythonScript to scriptDir & "/resolver.py"
set pasteScript to scriptDir & "/paste-to-deemix.applescript"

-- Single dialog with both inputs
try
	display dialog ¬
		"Enter your search:" default answer ¬
		"Artist - Album" with title ¬
		"Script Name" buttons {"Cancel", "OK"} ¬
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

-- Run resolver
try
	do shell script "python3 \"" & pythonScript & "\" --band \"" & artist & "\" --album \"" & album & "\""
on error errorMsg
	display alert "Error" message "Failed:" & return & errorMsg
	return
end try

delay 0.5

-- Run paste into Deemix
try
	do shell script "osascript \"" & pasteScript & "\""
	display notification "Album added to Deemix" with title "Resolver"
on error errorMsg
	display alert "Error" message "Failed to paste:" & return & errorMsg
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

**2. Utility Scripts (`paste-to-deemix.applescript`)**

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
	delay 5.0  -- Wait for download to process
	keystroke "h" using command down  -- Hide app
end tell
```

### Node.js Scripts (`*.js`)

Used for Spotify-specific integrations (e.g., currently-playing-to-deemix.js).

**Pattern:**

```javascript
import { execSync } from "child_process";
import { readFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";

// Get credentials from unified config
function getCredentials() {
    const configPath = join(homedir(), '.config', 'deemixkit', 'credentials.json');
    try {
        const config = JSON.parse(readFileSync(configPath, 'utf8'));
        return config.service?.credential_name;
    } catch (err) {
        console.error(`Error reading config: ${err.message}`);
        process.exit(1);
    }
}

// Use execSync for shell commands (osascript, curl)
// Use AppleScript via osascript for Spotify integration
```

## Configuration

### Unified Credentials File

**Location:** `~/.config/deemixkit/credentials.json`

All scripts read credentials from this centralized file.

**Structure:**

```json
{
  "spotify": {
    "client_id": "your_client_id",
    "client_secret": "your_client_secret"
  },
  "deezer": {
    "api_key": "your_api_key",
    "api_secret": "your_api_secret"
  },
  "lastfm": {
    "api_key": "your_api_key",
    "api_secret": "your_api_secret"
  },
  "youtube": {
    "api_key": "your_api_key"
  },
  "discogs": {
    "consumer_key": "your_key",
    "consumer_secret": "your_secret",
    "access_token": "your_token",
    "access_secret": "your_secret"
  }
}
```

**Reading Credentials:**

**Python:**
```python
from pathlib import Path
import json

creds_path = Path.home() / '.config' / 'deemixkit' / 'credentials.json'
with open(creds_path, 'r') as f:
    creds = json.load(f)
    client_id = creds.get('spotify', {}).get('client_id')
```

**Node.js:**
```javascript
import { readFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";

const configPath = join(homedir(), '.config', 'deemixkit', 'credentials.json');
const config = JSON.parse(readFileSync(configPath, 'utf8'));
const clientId = config.spotify?.client_id;
```

### Script-Specific Configuration

Each Python resolver has its own config at `~/.config/<script-name>/config.json`.

**Example Structure:**

```json
{
  "timeout": 10,
  "max_retries": 3,
  "retry_delay": 1,
  "log_level": "INFO",
  "cache_results": true,
  "cache_file": "~/.config/<script-name>/cache.json",
  "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
}
```

## Logging

### Log Location

**XDG Base Directory Specification:**
- Python scripts: `~/.local/log/<script-name>/<script-name>.log`
- Log directories auto-created with `Path.mkdir(parents=True, exist_ok=True)`

### Logging Pattern

```python
def setup_logging(verbose: bool = False) -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    level = logging.DEBUG if verbose else logging.INFO
    format_str = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

    handlers = [logging.FileHandler(LOG_FILE)]
    if verbose:
        handlers.append(logging.StreamHandler(sys.stderr))

    logging.basicConfig(level=level, format=format_str, handlers=handlers)
```

**Usage:**
- Always log errors: `logging.error(f"Error message: {e}")`
- Use verbose flag for stderr output: `--verbose` or `-v`
- User messages go to stdout via `print()`, not logging

## Code Patterns

### HTTP Requests with Retry

```python
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def create_session(config: Dict[str, Any]) -> requests.Session:
    session = requests.Session()

    retry_strategy = Retry(
        total=config.get("max_retries", 3),
        backoff_factor=config.get("retry_delay", 1),
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"]
    )

    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    session.headers.update({
        'User-Agent': config.get("user_agent", "Your-App/1.0"),
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9'
    })

    return session
```

### Error Handling Pattern

```python
try:
    response = session.get(url, timeout=10)
    response.raise_for_status()
    data = response.json()
except requests.exceptions.Timeout:
    logging.error("Request timed out")
    return None
except requests.exceptions.RequestException as e:
    logging.error(f"Network error: {e}")
    if hasattr(e, 'response') and e.response is not None:
        logging.error(f"Response status: {e.response.status_code}")
    return None
except (KeyError, json.JSONDecodeError) as e:
    logging.error(f"Parse error: {e}")
    return None
```

### Input Handling

```python
def parse_input(args: argparse.Namespace) -> str:
    if args.band and args.album:
        return f"{args.band} {args.album}"
    elif args.query:
        return args.query
    else:
        # Interactive mode
        if sys.stdin.isatty():
            user_input = input("> ").strip()
            return user_input
        else:
            # Read from stdin (piping)
            user_input = sys.stdin.read().strip()
            return user_input
```

### Clipboard Operations

```python
import subprocess

def save_to_clipboard(text: str) -> bool:
    try:
        import pyperclip
        pyperclip.copy(text)
        return True
    except ImportError:
        # macOS fallback
        process = subprocess.Popen(
            ['pbcopy'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        process.communicate(input=text.encode('utf-8'))
        return process.returncode == 0
```

## Working with Scripts

### Running Python Resolvers

```bash
# Direct with arguments
python3 deezer-resolver.py --band "Metallica" --album "Master of Puppets"

# With query
python3 spotify-resolver.py --query "artist:Metallica album:Master of Puppets"

# Piped input
echo "Metallica - Master of Puppets" | python3 deezer-resolver.py

# Interactive mode
python3 deezer-resolver.py

# Verbose logging
python3 deezer-resolver.py --verbose --band "Metallica" --album "Master of Puppets"

# Print URL instead of clipboard
python3 deezer-resolver.py --no-clipboard --band "Metallica" --album "Master of Puppets"
```

### Running Bash Wrappers

```bash
# CLI usage
./deezer-to-deemix.sh "Metallica" "Master of Puppets"
./discography-to-deemix.sh "Radiohead" "OK Computer"
./spotify-to-deemix.sh "The Beatles" "Abbey Road"
```

### Running AppleScript

```bash
# GUI dialog (opens dialog box)
osascript deezer-to-deemix.applescript

# Or execute directly if shebang is set
./deezer-to-deemix.applescript
```

### Running Node.js Scripts

```bash
node currently-playing-to-deemix.js
```

## Adding New Scripts

When adding a new script to DeemixKit:

1. **Follow existing patterns** - Use the same structure as similar scripts
2. **Use unified credentials** - Read from `~/.config/deemixkit/credentials.json` for API keys
3. **Add docstring** - Include description, version, author, date
4. **Create documentation** - Create or update `.md` documentation file
5. **Update example** - Add new service to `credentials.json.example` if needed
6. **Add bash wrapper** - Create `*-to-deemix.sh` for CLI usage
7. **Add AppleScript wrapper** - Create `*.applescript` for GUI dialogs (if applicable)
8. **Test** - Verify with and without credentials present
9. **Use standard paths** - Follow XDG Base Directory for config and logs

### New Service Checklist

- [ ] Python resolver script created
- [ ] Reads from `~/.config/deemixkit/credentials.json`
- [ ] Logs to `~/.local/log/<script-name>/`
- [ ] Bash wrapper script created
- [ ] AppleScript wrapper created (optional for GUI)
- [ ] Documentation `.md` file created
- [ ] `credentials.json.example` updated
- [ ] Tested with valid credentials
- [ ] Tested with missing credentials (graceful failure)
- [ ] Exit codes correct (0=success, 1=error, 130=interrupt)
- [ ] Shebang lines correct (`#!/usr/bin/env python3`, `#!/bin/bash`, `#!/usr/bin/env osascript`)

## Security Considerations

### Never Commit Credentials

The `.gitignore` explicitly protects:
- `credentials.json`
- `.env`
- `*_secret.json`
- `*_credentials.json`
- `*.pem`, `*.key`

### Only Commit Example File

Commit `credentials.json.example` with placeholder values:
```json
{
  "service": {
    "client_id": "your_client_id_here",
    "client_secret": "your_client_secret_here"
  }
}
```

### File Permissions

Set restrictive permissions on credentials:
```bash
chmod 600 ~/.config/deemixkit/credentials.json
```

## macOS Specifics

### Clipboard Operations

- **Copy to clipboard**: `pbcopy` (built-in macOS command)
- **Paste from clipboard**: `pbpaste` (built-in macOS command)
- **Clipboard in Python**: Use `pyperclip` library with `pbcopy` fallback

### Application Control via AppleScript

Activate applications, send keystrokes, check if apps are running:
```applescript
tell application "Deemix" to activate
tell application "System Events"
    keystroke "v" using command down
end tell
```

### osascript for AppleScript

Execute AppleScript from shell:
```bash
osascript -e 'tell application "System Events" to keystroke "v" using command down'
osascript "/path/to/script.applescript"
```

### Shebang Lines

- Python: `#!/usr/bin/env python3`
- Bash: `#!/bin/bash`
- AppleScript: `#!/usr/bin/env osascript`

## Dependencies

### Required (System)

- **macOS** - All scripts require macOS
- **Deemix Desktop** - Must be installed for paste functionality
- **curl** - For API calls (standard on macOS)
- **python3** - For Python resolvers
- **node** - For Node.js scripts (optional)

### Python Dependencies

Install via pip:
```bash
pip install requests
pip install pyperclip  # Optional, falls back to pbcopy
```

## Testing

This project **does not have a formal test suite**. Testing should be done manually:

1. Test with valid credentials
2. Test with missing credentials (should fail gracefully)
3. Test all input methods (args, stdin, interactive)
4. Test clipboard operations
5. Test GUI dialogs (AppleScript)
6. Verify exit codes
7. Check log files are created

## Debugging

### Enable Verbose Logging

```bash
python3 <resolver>.py --verbose <args>
```

### Check Log Files

```bash
cat ~/.local/log/<script-name>/<script-name>.log
```

### Check Config Files

```bash
cat ~/.config/deemixkit/credentials.json
cat ~/.config/<script-name>/config.json
```

### Test Python Scripts Directly

```bash
python3 -m pdb <script>.py <args>  # Debugger
python3 <script>.py --no-clipboard --verbose <args>  # Verbose + print to stdout
```

## Gotchas and Non-Obvious Patterns

### Hardcoded Paths in Bash/AppleScript

Some scripts contain hardcoded paths like `/Users/rd/Scripts/Riley/Audio/DeemixKit`. When modifying or running these scripts, be aware they may need to be updated for your environment.

### Exit Code Handling

Always check exit codes in Bash wrappers:
```bash
python3 script.py --args
if [ $? -ne 0 ]; then
  echo "Error" >&2
  exit 1
fi
```

### Stdout vs Stderr

- **Stdout**: Results (URLs, data) - for piping
- **Stderr**: Status messages, errors - for console display

Example from discography-resolver.py:
```python
print(f"Searching for: {band} - {album}", file=sys.stderr)  # Status message
print(url)  # URL to stdout for piping
```

### Deezer API is Free (No Auth Required)

Unlike Spotify, Deezer's basic search API does not require authentication. The deezer-resolver.py can work without API credentials.

### Spotify Requires Client Credentials Flow

Spotify API requires OAuth 2.0 Client Credentials flow:
1. Get token from `https://accounts.spotify.com/api/token`
2. Use token in Authorization header
3. Token expires and must be refreshed

### AppleScript Dialog Behavior

AppleScript dialogs in macOS have specific behaviors:
- Dialogs appear in front of all windows
- User can cancel via button or close window
- Errors trigger `on error` block which should `return` to exit gracefully

### Clipboard Timing

When copying to clipboard then pasting via AppleScript:
```bash
python3 resolver.py  # Copies to clipboard
sleep 0.5  # Wait for clipboard to be set
osascript paste.applescript  # Paste
```

The delay is necessary because clipboard operations aren't always instantaneous.

### Discography Resolver Output

The discography resolver outputs URLs to stdout (one per line), while status messages go to stderr. This allows piping:
```bash
# Extract only URLs from mixed output
URLS=$(python3 discography-resolver.py --band "Artist" --album "Album" 2>&1)
URLS_ONLY=$(echo "$URLS" | grep '^https://www\.deezer\.com/album/[0-9]')
```

## Workflow Examples

### Complete Workflow: Download a Deezer Album

1. **CLI method:**
   ```bash
   ./deezer-to-deemix.sh "Metallica" "Master of Puppets"
   ```

2. **GUI method:**
   ```bash
   ./deezer-to-deemix.applescript
   # Enter "Metallica - Master of Puppets" in dialog
   ```

3. **Manual method:**
   ```bash
   python3 deezer-resolver.py --band "Metallica" --album "Master of Puppets"
   # URL is copied to clipboard
   # Switch to Deemix and Cmd+V to paste
   ```

### Complete Workflow: Download Artist Discography

```bash
./discography-to-deemix.sh "Radiohead" "OK Computer"
# All album URLs copied to clipboard
# Paste into Deemix to download all
```

### Complete Workflow: Download Currently Playing Spotify Album

```bash
node currently-playing-to-deemix.js
# Automatically detects playing track, finds album, copies URL, pastes into Deemix
```

## File Reference

### Core Scripts

| File | Language | Purpose |
|------|----------|---------|
| `deezer-resolver.py` | Python | Search Deezer for album, copy URL |
| `spotify-resolver.py` | Python | Search Spotify for album, copy URL |
| `discography-resolver.py` | Python | Get artist's full discography from Deezer |
| `currently-playing-to-deemix.js` | Node.js | Download currently playing Spotify album |
| `paste-to-deemix.applescript` | AppleScript | Paste clipboard into Deemix app |

### Wrapper Scripts

| File | Language | Purpose |
|------|----------|---------|
| `deezer-to-deemix.sh` | Bash | CLI wrapper for Deezer resolver |
| `spotify-to-deemix.sh` | Bash | CLI wrapper for Spotify resolver |
| `discography-to-deemix.sh` | Bash | CLI wrapper for discography resolver |
| `deezer-to-deemix.applescript` | AppleScript | GUI dialog for Deezer resolver |
| `spotify-to-deemix.applescript` | AppleScript | GUI dialog for Spotify resolver |
| `discography-to-deemix.applescript` | AppleScript | GUI dialog for discography resolver |

### Documentation

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation |
| `CREDENTIALS.md` | Credentials setup guide |
| `DeemixKit.md` | Project overview |
| `Deezer Resolver.md` | Deezer resolver documentation |
| `Spotify Resolver.md` | Spotify resolver documentation |
| `Deezer to Deemix.md` | Deezer workflow documentation |
| `Spotify to Deemix.md` | Spotify workflow documentation |
| `Currently Playing to Deemix.md` | Currently playing workflow documentation |
| `Discography to Deemix.md` | Discography workflow documentation |
| `Shell Functions.md` | Shell function examples |

### Configuration

| File | Purpose |
|------|---------|
| `credentials.json.example` | Template for credentials file |
| `.gitignore` | Files to exclude from git |

## Keyboard Maestro Integration

Keyboard Maestro macros are available in the `macros/` directory. These enable hotkey access to common workflows:

- `Deemix from Spotify.kmmacros` - Download currently playing album
- `Deemix from Deezer.kmmacros` - Download specific Deezer album (via dialog)
- `Band Discography to Deemix.kmmacros` - Download full artist catalog (via dialog)

When creating new macros, follow the existing patterns and ensure paths are updated to match the DeemixKit installation location.
