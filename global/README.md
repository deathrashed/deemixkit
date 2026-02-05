# Global Resolver

Universal URL resolver that accepts any Spotify or Deezer URL and automatically sends it to Deemix.

## Supported URL Types

| Input | Output | Action |
|-------|--------|--------|
| **Track** | Parent album | Downloads album |
| **Album** | Same album | Downloads album |
| **Artist** | ALL albums (full discography) | Downloads entire catalog |
| **Playlist** | (coming soon) | - |

## Usage

```bash
# From URL
./global/global-resolver.sh "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"
./global/global-resolver.sh "https://www.deezer.com/album/103248"

# Uses clipboard if no argument
./global/global-resolver.sh

# AppleScript version (GUI dialog)
open global/global-resolver.applescript
```

## How It Works

1. Paste any Spotify/Deezer URL (or type it in)
2. Script auto-detects the URL type
3. Resolves and copies to clipboard
4. **Automatically pastes to Deemix** and starts download

## Examples

### Artist URL → Full Discography
```
Input:  https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb
Output: 40+ albums copied and sent to Deemix
```

### Track URL → Parent Album
```
Input:  https://open.spotify.com/track/3n3Ppam7vgaVa1iaRUc9Lp
Output: https://open.spotify.com/album/2LQwUZUbAoAiwbS1eO48hE
```

### Album URL → Same Album
```
Input:  https://www.deezer.com/album/103248
Output: https://www.deezer.com/album/103248
```

## Requirements

- **Deezer**: Works without any setup
- **Spotify**: Requires `~/.config/deemixkit/credentials.json`

## Documentation

**[Global Resolver Documentation](docs/Global%20Resolver.md)** - Full documentation with source code, examples, and troubleshooting.

## Keyboard Maestro Setup

Create a macro for quick access:

**Trigger:** Hotkey (e.g., `⌃⌥G` for Global)

**Action:** Execute Shell Script
```bash
cd /Volumes/Eksternal/Music/Tools/DeemixKit && ./global/global-resolver.sh "$KMVAR_TargetURL"
```

**Action 1:** Prompt for User Input (before shell script)
```
Prompt: Enter a Spotify or Deezer URL:
Variable: TargetURL
```
