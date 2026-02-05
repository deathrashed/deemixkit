# DeemixKit Installer

This folder contains everything you need to install DeemixKit and its dependencies.

## What It Does

The installer automates the entire setup process:

### 1. **Deemix Installation**
- Downloads the latest Deemix app from GitHub
- Mounts the DMG and copies it to `/Applications/Deemix.app`
- Cleanly unmounts and removes the DMG file

### 2. **DeemixKit Installation**
- Clones the DeemixKit repository from GitHub
- Installs required Python dependencies (`requests`, `pyperclip`)
- Opens the installation folder in Finder when done

### 3. **Credentials Setup**
- Creates `~/.config/deemixkit/` directory
- Copies `credentials.json.example` to `credentials.json`
- Prompts you to add Spotify API credentials (optional)
  - Spotify features require API credentials from [developer.spotify.com](https://developer.spotify.com/dashboard)
  - Deezer works immediately without any credentials (public API)
- Sets secure permissions on credentials file (chmod 600)

## How to Use

### Option 1: Double-Click (Easiest)
Simply double-click **`Install DeemixKit.command`** - it will open Terminal and run everything automatically.

### Option 2: From Terminal
```bash
./install/install.sh
```

### Option 3: From Keyboard Maestro
Create a macro with an **Execute Shell Script** action:
```bash
bash /path/to/deemixkit/install/install.sh
```

## What Gets Installed

| Item | Location |
|------|----------|
| Deemix | `/Applications/Deemix.app` |
| DeemixKit | `~/deemixkit-install/deemixkit` (configurable) |
| Credentials | `~/.config/deemixkit/credentials.json` |

## Requirements

- macOS (required for AppleScript and Deemix)
- Internet connection (for downloads)
- Git (for cloning repository)
- Python 3 with pip (for Python dependencies)
- Terminal access (for `.command` file)

## After Installation

Once installed, you can run any script from the DeemixKit folder:

```bash
# Deezer (no setup required)
./deezer/deezer-to-deemix.sh "Artist" "Album"

# Spotify (requires credentials setup during install)
./spotify/spotify-to-deemix.sh "Artist" "Album"

# Full discography
./discography/discography-to-deemix.sh "Artist" "Album"
```

## Credentials Note

**Deezer** works immediately without any setup - it uses a free public API.

**Spotify** requires API credentials that you can get from:
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new application
3. Copy your **Client ID** and **Client Secret**

The installer will prompt you to add these during installation, or you can add them later by editing `~/.config/deemixkit/credentials.json`.

## Troubleshooting

### "command cannot be opened because the developer cannot be verified"
Right-click the `.command` file and select "Open" → "Open" in the dialog that appears.

### "pip: command not found"
Install Python 3 from [python.org](https://www.python.org/downloads/) or use Homebrew: `brew install python3`

### "git: command not found"
Install Xcode Command Line Tools: `xcode-select --install`

## Files in This Folder

| File | Description |
|------|-------------|
| `Install DeemixKit.command` | Double-clickable installer |
| `install.sh` | Shell script that does the actual work |
| `README.md` | This file |
