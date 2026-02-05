# DeemixKit
<div align="center">
<img src="./docs/deemixkit-icon.png" alt="DeemixKit" width="300">

**A macOS automation toolkit for downloading music from Spotify and Deezer via Deemix**

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Python](https://img.shields.io/badge/Python-3.7+-blue?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Search albums from Spotify/Deezer → Auto-download via Deemix*

</div>

##  What is DeemixKit?

DeemixKit is a collection of automation scripts that bridge popular music services (Spotify, Deezer) with [Deemix](https://deemix.org), the popular music downloader. It helps you quickly find and download albums with minimal effort.

### Key Features

- 🎧 **Multiple Music Services**: Support for both Spotify and Deezer
- 🔍 **Flexible Search**: Search by artist, album, or currently playing track
- 📋 **Clipboard Automation**: Automatic clipboard management for seamless workflows
- 🖥️ **Multiple Interfaces**: CLI, GUI dialogs, and Keyboard Maestro macros
- 💿 **Bulk Operations**: Download entire artist discographies
- ⚡ **One-Click Workflows**: Download what you're currently listening to instantly
- 🚫 **No External Dependencies**: Uses built-in macOS tools and standard Python libraries

---

## ϟ Quick Start

### Prerequisites

1. **macOS** (required for AppleScript automation)

2. [Deemix](https://deemix.org/) desktop application.

   [Click this to directly Download](https://deathrashed.short.gy/deemix) or go to [GitHub](https://github.com/bambanah/deemix/releases)

3. Python 3.7+ (for most scripts)

4. Node.js 14+ (optional, for Spotify currently-playing script)

### Installation

#### ⚡ Quick Install (Recommended)

**Double-click** `install/Install DeemixKit.command` to automatically:
- Download and install Deemix
- Clone DeemixKit
- Install Python dependencies
- Set up credentials file
- Prompt for Spotify API keys (optional)

See [install/README.md](install/README.md) for details.

#### Manual Installation

```bash
# Clone or download this repository
git clone https://github.com/deathrashed/deemixkit.git
cd deemixkit

# Install Python dependencies
pip install requests pyperclip

# Download Deemix from https://deemix.org and install to /Applications
```

#### Configuration (Spotify Only)

<details>
<summary>Click to expand Spotify setup</summary>

If you plan to use Spotify features, you'll need API credentials:

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new application
3. Copy your **Client ID** and **Client Secret**
4. Create `~/.config/deemixkit/credentials.json`:

```json
{
  "spotify": {
    "client_id": "your_spotify_client_id",
    "client_secret": "your_spotify_client_secret"
  }
}
```

**Deezer requires no configuration** - it uses a free public API!

</details>

---

## ϟ Usage Examples

### <img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/deezer-icon.png" alt="Deezer Logo" width="22"> Search Deezer Album (Fastest - No Setup)

```bash
# CLI
./deezer/deezer-to-deemix.sh "Metallica" "Master of Puppets"

# GUI Dialog
osascript deezer/deezer-to-deemix.applescript
```

### <img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/spotify.png" alt="Spotify Logo" width="22"> Search Spotify Album

```bash
# CLI
./spotify/spotify-to-deemix.sh "Pink Floyd" "The Dark Side of the Moon"

# GUI Dialog
osascript spotify/spotify-to-deemix.applescript
```

### <img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/lp.png" alt="LP" width="24"> Download Full Discography

```bash
# Downloads all albums and EPs for an artist
./discography/discography-to-deemix.sh "Radiohead" "OK Computer"

# GUI Dialog
osascript discography/discography-to-deemix.applescript
```

### <img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/resolver-spotify.png" alt="Now Playing" width="24"> Download Currently Playing Track (Spotify)

```bash
# One-click download of what you're listening to
node spotify/currently-playing-to-deemix.js
```

---

## ϟ What's Included

#### Core Resolvers

| Script | Purpose | Credentials |
|--------|---------|-------------|
| `deezer/deezer-resolver.py` | Search Deezer API | Not required ✅ |
| `spotify/spotify-resolver.py` | Search Spotify API | Required ❌ |
| `discography/discography-resolver.py` | Fetch full discography | Not required ✅ |

#### Complete Workflows

| Workflow | CLI | GUI | Description |
|----------|------|------|-------------|
| **Deezer to Deemix** | `deezer/deezer-to-deemix.sh` | `deezer/deezer-to-deemix.applescript` | Search Deezer → Auto-paste to Deemix |
| **Spotify to Deemix** | `spotify/spotify-to-deemix.sh` | `spotify/spotify-to-deemix.applescript` | Search Spotify → Auto-paste to Deemix |
| **Discography to Deemix** | `discography/discography-to-deemix.sh` | `discography/discography-to-deemix.applescript` | Get all albums → Bulk paste to Deemix |

#### Keyboard Maestro Macros

Comprehensive macros for [Keyboard Maestro](https://www.keyboardmaestro.com/) included in `macros/` folder:

| Macro | Description |
|-------|-------------|
| **Download** | Activate Deemix, trigger download with hotkey |
| **Discography for Deemix** | Full discography downloader - prompts for artist/album, fetches entire catalog, auto-pastes to Deemix |

<details>
<summary>Click to expand Discography Macro Details</summary>

The **Discography for Deemix** macro provides a complete workflow:

1. **Prompts** you for Artist and Album name (uses album to identify correct artist among duplicates)
2. **Fetches** complete discography from Deezer (albums + EPs only, excludes singles by default)
3. **Copies** all album URLs to clipboard automatically
4. **Activates** Deemix and pastes all URLs for bulk downloading
5. **Notifies** you when complete

**Features:**
- Artist disambiguation (finds correct "America" or "Boston" among duplicate band names)
- Smart filtering (albums + EPs only, singles excluded)
- Bulk paste (all URLs pasted at once for simultaneous download)
- Handles large discographies (100+ albums via API pagination)
- Duplicate filtering removes duplicate album titles

**Setup:** Update the macro's `Execute Shell Script` path to your DeemixKit location.

</details>

#### Special Scripts

| Script | Purpose | Language |
|--------|---------|----------|
| `spotify/currently-playing-to-deemix.js` | Download currently playing Spotify track | Node.js |
| `scripts/paste-to-deemix.applescript` | Paste clipboard into Deemix | AppleScript |

---

## ϟ Workflow Comparison

| Feature | Deezer | Spotify | Discography | Currently Playing |
|---------|---------|----------|-------------|-------------------|
| **Setup Required** | None ⚡ | API credentials | None | API credentials |
| **CLI Available** | ✅ | ✅ | ✅ | ❌ |
| **GUI Available** | ✅ | ✅ | ✅ | ❌ |
| **Auto-Paste to Deemix** | ✅ | ✅ | ✅ | ✅ |
| **Bulk Download** | ❌ | ❌ | ✅ (all albums) | ❌ |
| **One-Click** | ❌ | ❌ | ❌ | ✅ |

---

## ϟ Advanced Usage

<details>
<summary><img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/py.png" alt="Python" width="18"> Python Resolver Options</summary>

All Python resolvers support these options:

```bash
# Verbose logging
python3 deezer/deezer-resolver.py --band "Artist" --album "Album" --verbose

# Print URL instead of clipboard
python3 deezer/deezer-resolver.py --band "Artist" --album "Album" --no-clipboard

# Full search query
python3 deezer/deezer-resolver.py --query "Artist Album"

# Interactive mode (prompts for input)
python3 deezer/deezer-resolver.py

# Pipe from stdin
echo "Artist - Album" | python3 deezer/deezer-resolver.py
```

</details>

<details>
<summary><img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/keyboard-maestro-icon.png" alt="Keyboard Maestro" width="22"> Keyboard Maestro Integration</summary>

**Ready-to-use macros included** in `macros/` folder - just import and use!

For custom macros, here's a basic example for album downloads:

1. **Prompt for Input**: Artist name
2. **Prompt for Input**: Album name
3. **Execute Shell Script**:
   ```bash
   /path/to/deemixkit/deezer/deezer-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
   ```
4. **Display Text**: "Album added to Deemix!"

See `docs/Keyboard Maestro DeemixKit.md` for detailed macro examples and the macros/ folder for complete pre-built workflows.

</details>

<details>
<summary><img src="https://raw.githubusercontent.com/deathrashed/iconography/main/color/misc/raycast.png" alt="Raycast" width="22"> Raycast Integration</summary>

Create a Raycast script:

```bash
#!/bin/bash
cd /path/to/deemixkit
osascript deezer/deezer-to-deemix.applescript
```

Save as `deemix-search.sh` in your Raycast scripts directory.

</details>

---

<details>
<summary>ϟ Troubleshooting</summary>

#### "Spotify API credentials not configured"

**Solution**: Set up credentials file as described in the Configuration section above.

#### "Failed to resolve link"

**Solutions**:
- Check spelling of artist/album names
- Verify network connection
- For Spotify: Ensure your API credentials are valid
- Try a different album name (some may not be available)

#### AppleScript permission errors

**Solution**: Grant System Events accessibility permission:
- System Settings → Privacy & Security → Accessibility
- Add Terminal or Script Editor to the list
- Or grant permission when prompted

#### Deemix doesn't open

**Solutions**:
- Ensure Deemix is installed from [deemix.org](https://deemix.org)
- Check that Deemix is in your Applications folder
- Try launching Deemix manually first

#### "Failed to copy to clipboard"

**Solutions**:
```bash
# Install pyperclip library
pip install pyperclip
```

</details>

---

<details>
<summary>ϟ Project Structure</summary>

```
DeemixKit/
├── README.md                      # This file
├── LICENSE                        # MIT License
├── scripts/paste-to-deemix.applescript  # Shared paste utility
├── docs/                          # Documentation
│   ├── CREDENTIALS.md             # API credentials setup
│   ├── AGENTS.md                  # Developer guide for AI agents
│   ├── DeemixKit.md               # Project overview
│   ├── Keyboard Maestro DeemixKit.md
│   └── ...
├── deezer/                        # Deezer workflows
│   ├── deezer-resolver.py         # Python resolver
│   ├── deezer-to-deemix.sh        # CLI wrapper
│   ├── deezer-to-deemix.applescript
│   └── docs/                      # Deezer-specific docs
├── spotify/                       # Spotify workflows
│   ├── spotify-resolver.py        # Python resolver
│   ├── spotify-to-deemix.sh       # CLI wrapper
│   ├── spotify-to-deemix.applescript
│   ├── currently-playing-to-deemix.js
│   └── docs/                      # Spotify-specific docs
├── discography/                   # Discography workflow
│   ├── discography-resolver.py    # Python resolver
│   ├── discography-to-deemix.sh   # CLI wrapper
│   ├── discography-to-deemix.applescript
│   └── docs/                      # Discography-specific docs
├── scripts/                       # Utility scripts
│   └── cleanup-docs.sh
├── install/                       # Automated installer
│   ├── Install DeemixKit.command  # Double-click to install
│   ├── install.sh                 # Installer script
│   └── README.md                  # Installation guide
├── examples/                      # Example configurations
│   └── credentials.json.example
└── macros/                        # Ready-to-use Keyboard Maestro macros (Download, Discography, etc.)
```

</details>

<details>
<summary>ϟ Security & Contributing</summary>

## Security

- **Never commit credentials**: The `.gitignore` file prevents accidental commits of API keys
- **Use credentials.example**: Commit only example files, never real credentials
- **File permissions**: Set restrictive permissions on credentials files: `chmod 600 ~/.config/deemixkit/credentials.json`

## Contributing

When adding new scripts:

1. Follow existing patterns (see `docs/AGENTS.md` for developer guide)
2. Read credentials from `~/.config/deemixkit/credentials.json`
3. Create or update documentation
4. Update `examples/credentials.json.example` if adding new services
5. Test with and without credentials present

</details>

<details>
<summary>ϟ Documentation</summary>

- [docs/CREDENTIALS.md](docs/CREDENTIALS.md) - Detailed credentials setup
- [docs/AGENTS.md](docs/AGENTS.md) - Developer guide for AI agents
- [docs/DeemixKit.md](docs/DeemixKit.md) - Project overview
- Individual service folders contain docs for each tool

</details>

<details>
<summary>ϟ Tips & Tricks</summary>

### Save AppleScripts as Dock Apps

1. Open Script Editor
2. Copy content from `deezer/deezer-to-deemix.applescript`
3. Save as "Deezer to Deemix" with File Format: Application
4. Drag to Dock for one-click access

### Create Shell Aliases

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
alias deemix='./deezer/deezer-to-deemix.sh'
alias spoti='./spotify/spotify-to-deemix.sh'
alias disco='./discography/discography-to-deemix.sh'
alias now='node spotify/currently-playing-to-deemix.js'
```

Then use short commands:
```bash
deemix "Artist" "Album"
spoti "Artist" "Album"
disco "Artist" "Album"
now
```

### Batch Downloads

```bash
#!/bin/bash
# Download multiple albums at once
albums=("Metallica:Master of Puppets" "Pink Floyd:The Wall" "Radiohead:OK Computer")
for album in "${albums[@]}"; do
  IFS=':' read -r artist name <<< "$album"
  ./deezer/deezer-to-deemix.sh "$artist" "$name"
  sleep 10  # Wait between downloads
done
```

</details>

---

<details>
<summary>ϟ Acknowledgments</summary>

- [Deemix](https://deemix.org) - Music downloader application
- [Spotify Web API](https://developer.spotify.com/) - Music service API
- [Deezer API](https://developers.deezer.com/) - Music service API

</details>

<details>
<summary>ϟ Support</summary>

For issues, questions, or suggestions:

1. Check the Troubleshooting section above
2. Review individual script documentation files
3. Open an issue on GitHub

</details>

---

**Made for music enthusiasts**
