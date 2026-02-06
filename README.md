# DeemixKit

<div align="center">
  <img src="./docs/icons/deemixkit.png" alt="DeemixKit" width="300">
  <div align="center">
    <img src="./docs/icons/resolver-deezer.png" alt="DeemixKit" width="75">
    <img src="./docs/icons/resolver-spotify.png" alt="DeemixKit" width="75">
    <img src="./docs/icons/resolver-global.png" alt="DeemixKit" width="75">
  </div>
</div>

**A macOS automation toolkit for downloading music from Spotify and Deezer via Deemix**

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Python](https://img.shields.io/badge/Python-3.7+-blue?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Search albums from Spotify/Deezer → Auto-download via Deemix*


##  What is DeemixKit?

DeemixKit is a collection of automation scripts that bridge popular music services (Spotify, Deezer) with [Deemix](https://deemix.org), the popular music downloader. It helps you quickly find and download albums with minimal effort.

### Key Features

- 🎧 **Multiple Music Services**: Support for both Spotify and Deezer
- 🔍 **Flexible Search**: Search by artist, album, or currently playing track
- 📋 **Clipboard Automation**: Automatic clipboard management for seamless workflows
- 🖥️ **Multiple Interfaces**: CLI, GUI dialogs, and Keyboard Maestro macros
- 💿 **Bulk Operations**: Download entire artist discographies, playlists, batch lists
- ⚡ **One-Click Workflows**: Download what you're currently listening to instantly
- 🚫 **No External Dependencies**: Uses built-in macOS tools and standard Python libraries

---

## <img src="./docs/icons/installer.png" alt="Deezer Logo" width="28"> Quick Start

### Prerequisites

1. **macOS** (required for AppleScript automation)

2. Python 3.7+ (for most scripts)

3. Node.js 14+ (optional, for Spotify currently-playing script)

4. [Deemix](https://deemix.org/) desktop application.

5. Click icon below for direct [Download](https://deathrashed.short.gy/deemix) or go to [GitHub](https://github.com/bambanah/deemix/releases)

    [<img src="./docs/icons/deemix.png" alt="Download" width="100">](https://deathrashed.short.gy/deemix)
### Installation

#### <img src="./docs/icons/shell-deezer.png" alt="Deezer Logo" width="20"> Quick Install (Recommended)

- Paste the following into your terminal and follow the prompts

```bash
curl -s https://raw.githubusercontent.com/deathrashed/deemixkit/main/install/install.sh | bash
```

It will **automatically**:

- Download and install Deemix
- Clone DeemixKit to your specified location
- Install the required Python dependencies
- Set up your credentials file
- Prompt for Spotify API keys (optional)

See [install/README.md](install/README.md) for details.

or you can also **Double-click** `install/Install DeemixKit.command`

#### <img src="./docs/icons/shell-discography.png" alt="Deezer Logo" width="20">Manual Installation

```bash
# Clone or download this repository
git clone https://github.com/deathrashed/deemixkit.git
cd deemixkit

# Install Python dependencies
pip install requests pyperclip

# Download Deemix from https://deemix.org and install to /Applications
```

#### <img src="./docs/icons/shell-spotify.png" alt="Deezer Logo" width="20">Configuration (Spotify Only)

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

### <img src="./docs/icons/links-deezer.png" alt="Deezer Logo" width="24"> Search Deezer Album (Fastest - No Setup)

```bash
# CLI
./deezer/deezer-to-deemix.sh "Metallica" "Master of Puppets"

# GUI Dialog
osascript deezer/deezer-to-deemix.applescript
```

### <img src="./docs/icons/links-spotify.png" alt="Spotify Logo" width="24"> Search Spotify Album

```bash
# CLI
./spotify/spotify-to-deemix.sh "Pink Floyd" "The Dark Side of the Moon"

# GUI Dialog
osascript spotify/spotify-to-deemix.applescript
```

### <img src="./docs/icons/links-discography.png" alt="LP" width="24"> Download Full Discography

```bash
# Downloads all albums and EPs for an artist
./discography/discography-to-deemix.sh "Radiohead" "OK Computer"

# GUI Dialog
osascript discography/discography-to-deemix.applescript
```


### <img src="./docs/icons/links-playlist.png" alt="Playlist" width="24"> Download All Albums from Playlist

```bash
# Extract ALL albums from a playlist
./playlist/playlist-downloader.sh "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M"
```

### <img src="./docs/icons/links-textfile.png" alt="Batch" width="24"> Download from Text File

```bash
# Download multiple albums from a text file
./batch/batch-downloader.sh -f albums.txt

# Custom file with Spotify
./batch/batch-downloader.sh -f my-list.txt -s spotify
```

### <img src="./docs/icons/details.png" alt="Global" width="24"> Universal URL Resolver

```bash
# Accept ANY Spotify or Deezer URL (track, album, artist, playlist)
./global/global-resolver.sh "https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"

# Artist URLs automatically fetch ALL albums
./global/global-resolver.sh "https://www.deezer.com/artist/27"

# Uses clipboard if no argument
./global/global-resolver.sh
```
### <img src="./docs/icons/links-currently-playing.png" alt="Now Playing" width="24"> Download Currently Playing Track (Spotify)

```bash
# One-click download of what you're listening to
node spotify/currently-playing-to-deemix.js
```

---

## ϟ What's Included

#### Universal Tools

| Tool | Purpose | Input |
|------|---------|-------|
| **Global Resolver** | Accept ANY Spotify/Deezer URL | Track/Album/Artist/Playlist URL |
| **Batch Downloader** | Bulk download from text file | `albums.txt` file |
| **Playlist Downloader** | Extract ALL albums from playlist | Playlist URL |
| **Riley's Playlist Resolver** | Get only albums you DON'T have | Playlist URL + collection match |

#### Service-Specific Tools

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
| **Global Resolver** | `global/global-resolver.sh` | `global/global-resolver.applescript` | Any URL → Auto-detect → Deemix |
| **Playlist Downloader** | `playlist/playlist-downloader.sh` | `playlist/playlist-downloader.applescript` | Playlist → All albums → Deemix |
| **Batch Downloader** | `batch/batch-downloader.sh` | `batch/batch-downloader.applescript` | File list → All albums → Deemix |

#### Keyboard Maestro Macros

Comprehensive macros for [Keyboard Maestro](https://www.keyboardmaestro.com/) included in `macros/` folder:

| Macro | Description |
|-------|-------------|
| **Download** | Activate Deemix, trigger download with hotkey |
| **Discography for Deemix** | Full discography downloader - prompts for artist/album, fetches entire catalog, auto-pastes to Deemix |
| **Global Resolver** | Universal resolver - accepts any URL, auto-detects type, sends to Deemix |

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
| `scripts/rileys-collection-matcher.py` | Fuzzy matching against local collection | Python |

---

## ϟ Workflow Comparison

| Feature | Deezer | Spotify | Discography | Global | Playlist | Batch |
|---------|---------|----------|-------------|--------|----------|-------|
| **Setup Required** | None ⚡ | API credentials | None | None for Deezer | None for Deezer | None for Deezer |
| **CLI Available** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **GUI Available** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Auto-Paste to Deemix** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Bulk Download** | ❌ | ❌ | ✅ (all albums) | ✅ (artist URLs) | ✅ (all albums) | ✅ (file list) |
| **URL Input** | ❌ | ❌ | ❌ | ✅ (any URL) | ✅ (playlist) | ❌ |

---

## ϟ Quick Decision Guide

```
Found a URL? → Global Resolver (any Spotify/Deezer URL)
Found a playlist? → Playlist Downloader (all) or Riley's Playlist Resolver (missing only)
Have a list of albums? → Batch Downloader
Want full discography? → Discography to Deemix
Currently playing? → Currently Playing to Deemix
Search by name? → Deezer to Deemix (fastest) or Spotify to Deemix
```

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

**Ready-to-use Raycast scripts included** in `raycast/` folder!

### Quick Setup

```bash
# Symlink all scripts to Raycast
ln -s /path/to/DeemixKit/raycast/*.sh ~/.config/raycast/script-commands/

# Update DEEMIXKIT_PATH in each script to your installation path
```

### Available Scripts

| Script | Arguments | Description |
|--------|-----------|-------------|
| Deezer to Deemix | Artist, Album | 🎵 Search Deezer and download |
| Spotify to Deemix | Artist, Album | 🎧 Search Spotify and download |
| Discography to Deemix | Artist, Album | 💿 Download full discography |
| Global Resolver | URL (optional) | 🌐 Resolve any Spotify/Deezer URL |
| Playlist Downloader | Playlist URL | 📋 Download all albums from playlist |
| Batch Downloader | Service, File | 📝 Download from text file |
| Currently Playing | None | ▶️ Download current Spotify track |

See [raycast/README.md](raycast/README.md) for detailed setup and usage instructions.

</details>

---

## ϟ Additional

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


<details>
<summary>ϟ Project Structure</summary>

```
DeemixKit/
├── README.md                      # This file
├── LICENSE                        # MIT License
├── scripts/                       # Utility scripts
│   ├── paste-to-deemix.applescript  # Shared paste utility
│   └── rileys-collection-matcher.py  # Fuzzy matching module
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
├── global/                        # Universal resolver
│   ├── global-resolver.py         # Python resolver
│   ├── global-resolver.sh         # CLI wrapper
│   ├── global-resolver.applescript
│   └── docs/                      # Global-specific docs
├── playlist/                      # Playlist workflows
│   ├── playlist-downloader.py     # Generic playlist tool
│   ├── playlist-downloader.sh
│   ├── rileys-playlist-resolver.py # Personal tool with filtering
│   ├── rileys-playlist-resolver.sh
│   └── docs/                      # Playlist-specific docs
├── raycast/                       # Raycast script commands
│   ├── deezer-to-deemix.sh
│   ├── spotify-to-deemix.sh
│   ├── discography-to-deemix.sh
│   ├── global-resolver.sh
│   ├── playlist-downloader.sh
│   ├── batch-downloader.sh
│   ├── currently-playing.sh
│   └── README.md                  # Setup instructions
├── batch/                         # Batch download workflow
│   ├── batch-downloader.sh        # CLI wrapper
│   ├── batch-downloader.applescript
│   ├── albums.txt                 # Example file
│   └── docs/                      # Batch-specific docs
├── install/                       # Automated installer
│   ├── Install DeemixKit.command  # Double-click to install
│   ├── install.sh                 # Installer script
│   └── README.md                  # Installation guide
├── examples/                      # Example configurations
│   └── credentials.json.example
└── macros/                        # Ready-to-use Keyboard Maestro macros
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
alias global='./global/global-resolver.sh'
alias playlist='./playlist/playlist-downloader.sh'
alias batch='./batch/batch-downloader.sh'
alias now='node spotify/currently-playing-to-deemix.js'
```

Then use short commands:
```bash
deemix "Artist" "Album"
spoti "Artist" "Album"
disco "Artist" "Album"
global "https://open.spotify.com/artist/..."
playlist "https://open.spotify.com/playlist/..."
batch -f albums.txt
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
