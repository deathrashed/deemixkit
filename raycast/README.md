# DeemixKit Raycast Scripts

Raycast script commands for all DeemixKit tools.

## Installation

1. **Copy or symlink** the scripts to your Raycast script commands directory:

```bash
# Option A: Symlink (recommended - updates automatically)
ln -s /path/to/DeemixKit/raycast/*.sh ~/.config/raycast/script-commands/

# Option B: Copy
cp /path/to/DeemixKit/raycast/*.sh ~/.config/raycast/script-commands/
```

2. **Update the `DEEMIXKIT_PATH`** in each script to point to your DeemixKit installation:

```bash
# Edit each script and change this line:
DEEMIXKIT_PATH="/Volumes/Eksternal/Music/Tools/DeemixKit"
# To your actual path, for example:
DEEMIXKIT_PATH="$HOME/Music/Tools/DeemixKit"
```

Or use a bulk find/replace:

```bash
cd ~/.config/raycast/script-commands
sed -i '' 's|/Volumes/Eksternal/Music/Tools/DeemixKit|/your/path/to/DeemixKit|g' *.sh
```

## Available Scripts

| Script | Icon | Arguments | Description |
|--------|------|-----------|-------------|
| **Deezer to Deemix** | 🎵 | Artist, Album | Search Deezer and download |
| **Spotify to Deemix** | 🎧 | Artist, Album | Search Spotify and download |
| **Discography to Deemix** | 💿 | Artist, Album | Download full artist discography |
| **Global Resolver** | 🌐 | URL (optional) | Resolve any Spotify/Deezer URL |
| **Playlist Downloader** | 📋 | Playlist URL | Download all albums from playlist |
| **Batch Downloader** | 📝 | Service (dropdown), File path | Download from text file |
| **Currently Playing** | ▶️ | None | Download current Spotify track |

## Usage

### In Raycast

1. Open Raycast (Cmd + Space)
2. Type the script name (e.g., "Deezer", "Spotify", "Discography")
3. Press Enter
4. Fill in the arguments in the input fields
5. Press Enter to execute

### Examples

```
# Download an album from Deezer
Raycast > "Deezer to Deemix" > Artist: Metallica > Album: Master of Puppets

# Download an album from Spotify
Raycast > "Spotify to Deemix" > Artist: Pink Floyd > Album: The Wall

# Download full discography
Raycast > "Discography to Deemix" > Artist: Radiohead > Album: OK Computer

# Resolve a URL (or use clipboard)
Raycast > "Global Resolver" > URL: https://open.spotify.com/album/...

# Download from playlist
Raycast > "Playlist Downloader" > URL: https://open.spotify.com/playlist/...

# Download currently playing
Raycast > "Currently Playing"

# Batch download
Raycast > "Batch Downloader" > Service: Deezer > File: /path/to/albums.txt
```

## Creating Aliases

For shorter script names, you can create symlinks:

```bash
cd ~/.config/raycast/script-commands
ln -s deezer-to-deemix.sh deemix.sh
ln -s deezer-to-deemix.sh dz.sh
ln -s spotify-to-deemix.sh sp.sh
ln -s discography-to-deemix.sh disco.sh
```

Then use shorter names in Raycast:
- `deemix` or `dz` for Deezer
- `sp` for Spotify
- `disco` for Discography

## Troubleshooting

### Scripts don't appear in Raycast

1. Make sure scripts are executable:
```bash
chmod +x ~/.config/raycast/script-commands/*.sh
```

2. Refresh Raycast scripts:
- Open Raycast
- Type "Reload Script Commands" and run it

### "Command not found" errors

Make sure the `DEEMIXKIT_PATH` in each script points to your actual DeemixKit installation.

### Deemix doesn't open

1. Make sure Deemix is installed
2. Grant System Events accessibility permission:
   - System Settings → Privacy & Security → Accessibility
   - Add Terminal or Raycast

### Spotify credentials error

For Spotify features, set up your credentials:
```bash
mkdir -p ~/.config/deemixkit
nano ~/.config/deemixkit/credentials.json
```

Add your Spotify API credentials:
```json
{
  "spotify": {
    "client_id": "your_client_id",
    "client_secret": "your_client_secret"
  }
}
```

See [../docs/CREDENTIALS.md](../docs/CREDENTIALS.md) for detailed instructions.

## Tips

- Use Raycast's **Hotkeys** feature to assign keyboard shortcuts to frequently used scripts
- Enable **Quick Open** in script settings for faster access
- The **Global Resolver** works with clipboard if no URL is provided - just copy a URL and run the script
- **Currently Playing** is perfect for hotkey - one-click download of what you're listening to
