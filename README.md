<div align="center">

# DeemixKit

**A macOS automation toolkit for downloading music from Spotify and Deezer via Deemix**

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Python](https://img.shields.io/badge/Python-3.7+-blue?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Search albums from Spotify/Deezer → Auto-download via Deemix*

</div>

## 🎵 What is DeemixKit?

DeemixKit is a collection of automation scripts that bridge popular music services (Spotify, Deezer) with [Deemix](https://deemix.app), the popular music downloader. It helps you quickly find and download albums with minimal effort.

### Key Features

- 🎧 **Multiple Music Services**: Support for both Spotify and Deezer
- 🔍 **Flexible Search**: Search by artist, album, or currently playing track
- 📋 **Clipboard Automation**: Automatic clipboard management for seamless workflows
- 🖥️ **Multiple Interfaces**: CLI, GUI dialogs, and Keyboard Maestro macros
- 💿 **Bulk Operations**: Download entire artist discographies
- ⚡ **One-Click Workflows**: Download what you're currently listening to instantly
- 🚫 **No External Dependencies**: Uses built-in macOS tools and standard Python libraries

---

## ⚡ Quick Start

### Prerequisites

1. **macOS** (required for AppleScript automation)
2. [Deemix](https://deemix.app) desktop application
3. Python 3.7+ (for most scripts)
4. Node.js 14+ (optional, for Spotify currently-playing script)

### Installation

```bash
# Clone or download this repository
git clone https://github.com/yourusername/DeemixKit.git
cd DeemixKit

# Install Python dependencies
pip install requests pyperclip
```

### Configuration (Spotify Only)

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

---

## 📖 Usage Examples

### Search Deezer Album (Fastest - No Setup)

```bash
# CLI
./deezer-to-deemix.sh "Metallica" "Master of Puppets"

# GUI Dialog
osascript deezer-to-deemix.applescript
```

### Search Spotify Album

```bash
# CLI
./spotify-to-deemix.sh "Pink Floyd" "The Dark Side of the Moon"

# GUI Dialog
osascript spotify-to-deemix.applescript
```

### Download Currently Playing Track (Spotify)

```bash
# One-click download of what you're listening to
node currently-playing-to-deemix.js
```

### Download Full Discography

```bash
# Downloads all albums and EPs for an artist
./discography-to-deemix.sh "Radiohead" "OK Computer"

# GUI Dialog
osascript discography-to-deemix.applescript
```

---

## 🗂️ What's Included

### Core Resolvers (Python)

| Script | Purpose | Credentials |
|--------|---------|-------------|
| `deezer-resolver.py` | Search Deezer API | Not required ✅ |
| `spotify-resolver.py` | Search Spotify API | Required ❌ |
| `discography-resolver.py` | Fetch full discography | Not required ✅ |

### Complete Workflows

| Workflow | CLI | GUI | Description |
|----------|------|------|-------------|
| **Deezer to Deemix** | `deezer-to-deemix.sh` | `deezer-to-deemix.applescript` | Search Deezer → Auto-paste to Deemix |
| **Spotify to Deemix** | `spotify-to-deemix.sh` | `spotify-to-deemix.applescript` | Search Spotify → Auto-paste to Deemix |
| **Discography to Deemix** | `discography-to-deemix.sh` | `discography-to-deemix.applescript` | Get all albums → Bulk paste to Deemix |

### Special Scripts

| Script | Purpose | Language |
|--------|---------|----------|
| `currently-playing-to-deemix.js` | Download currently playing Spotify track | Node.js |
| `paste-to-deemix.applescript` | Paste clipboard into Deemix | AppleScript |

---

## 🎯 Workflow Comparison

| Feature | Deezer | Spotify | Discography | Currently Playing |
|---------|---------|----------|-------------|-------------------|
| **Setup Required** | None ⚡ | API credentials | None | API credentials |
| **CLI Available** | ✅ | ✅ | ✅ | ❌ |
| **GUI Available** | ✅ | ✅ | ✅ | ❌ |
| **Auto-Paste to Deemix** | ✅ | ✅ | ✅ | ✅ |
| **Bulk Download** | ❌ | ❌ | ✅ (all albums) | ❌ |
| **One-Click** | ❌ | ❌ | ❌ | ✅ |

---

## 📚 Advanced Usage

### Python Resolver Options

All Python resolvers support these options:

```bash
# Verbose logging
python3 deezer-resolver.py --band "Artist" --album "Album" --verbose

# Print URL instead of clipboard
python3 deezer-resolver.py --band "Artist" --album "Album" --no-clipboard

# Full search query
python3 deezer-resolver.py --query "Artist Album"

# Interactive mode (prompts for input)
python3 deezer-resolver.py

# Pipe from stdin
echo "Artist - Album" | python3 deezer-resolver.py
```

### Keyboard Maestro Integration

Example macro for album downloads:

1. **Prompt for Input**: Artist name
2. **Prompt for Input**: Album name
3. **Execute Shell Script**:
   ```bash
   ./deezer-to-deemix.sh "$KMVAR_Artist" "$KMVAR_Album"
   ```
4. **Display Text**: "Album added to Deemix!"

See `Keyboard Maestro DeemixKit.md` for detailed macro examples.

### Raycast Integration

Create a Raycast script:

```bash
#!/bin/bash
osascript deezer-to-deemix.applescript
```

Save as `deemix-search.sh` in your Raycast scripts directory.

---

## 🛠️ Troubleshooting

### "Spotify API credentials not configured"

**Solution**: Set up credentials file as described in the Configuration section above.

### "Failed to resolve link"

**Solutions**:
- Check spelling of artist/album names
- Verify network connection
- For Spotify: Ensure your API credentials are valid
- Try a different album name (some may not be available)

### AppleScript permission errors

**Solution**: Grant System Events accessibility permission:
- System Preferences → Security & Privacy → Privacy → Accessibility
- Add Terminal or Script Editor to the list
- Or grant permission when prompted

### Deemix doesn't open

**Solutions**:
- Ensure Deemix is installed from [deemix.app](https://deemix.app)
- Check that Deemix is in your Applications folder
- Try launching Deemix manually first

### "Failed to copy to clipboard"

**Solutions**:
```bash
# Install pyperclip library
pip install pyperclip
```

---

## 📁 Project Structure

```
DeemixKit/
├── README.md                      # This file
├── CREDENTIALS.md                 # Setup guide for API credentials
├── AGENTS.md                     # Guide for AI agents
├── *.py                          # Python resolvers
├── *.sh                          # Bash wrappers
├── *.applescript                 # GUI dialogs
├── *.js                          # Node.js scripts
└── Macros/                       # Keyboard Maestro macros
```

---

## 🔐 Security

- **Never commit credentials**: The `.gitignore` file prevents accidental commits of API keys
- **Use credentials.example**: Commit only example files, never real credentials
- **File permissions**: Set restrictive permissions on credentials files: `chmod 600 ~/.config/deemixkit/credentials.json`

---

## 📄 License

This project is free to use and modify for personal use.

---

## 🤝 Contributing

When adding new scripts:

1. Follow existing patterns (see `AGENTS.md` for developer guide)
2. Read credentials from `~/.config/deemixkit/credentials.json`
3. Create or update documentation
4. Update `credentials.json.example` if adding new services
5. Test with and without credentials present

---

## 📖 Documentation

- [CREDENTIALS.md](CREDENTIALS.md) - Detailed credentials setup
- [AGENTS.md](AGENTS.md) - Developer guide for AI agents
- Individual script documentation for each tool

---

## 💡 Tips & Tricks

### Save AppleScripts as Dock Apps

1. Open Script Editor
2. Copy content from `deezer-to-deemix.applescript`
3. Save as "Deezer to Deemix" with File Format: Application
4. Drag to Dock for one-click access

### Create Shell Aliases

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
alias deemix='./deezer-to-deemix.sh'
alias spoti='./spotify-to-deemix.sh'
alias disco='./discography-to-deemix.sh'
alias now='node currently-playing-to-deemix.js'
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
  ./deezer-to-deemix.sh "$artist" "$name"
  sleep 10  # Wait between downloads
done
```

---

## 🙏 Acknowledgments

- [Deemix](https://deemix.app) - Music downloader application
- [Spotify Web API](https://developer.spotify.com/) - Music service API
- [Deezer API](https://developers.deezer.com/) - Music service API

---

## 📧 Support

For issues, questions, or suggestions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review individual script documentation files
3. Open an issue on GitHub

---

**Made with ❤️ for music enthusiasts**
