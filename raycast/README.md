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
sed -i '' 's|/Volumes/Eksternal/Music/Tools/DeemixKit|/your/path/to/DeemixKit|g' deemix-*.sh
```

3. **Reload Raycast scripts**:
- Open Raycast (Cmd + Space)
- Type "Reload Script Commands" and press Enter

## Available Scripts

All scripts are prefixed with `deemix-` for easy discovery in Raycast:

| Script | Arguments | Description |
|--------|-----------|-------------|
| **Deemix - Deezer** | Artist, Album | Search Deezer and download |
| **Deemix - Spotify** | Artist, Album | Search Spotify and download |
| **Deemix - Discography** | Artist, Album | Download full artist discography |
| **Deemix - Global** | URL (optional) | Resolve any Spotify/Deezer URL |
| **Deemix - Playlist** | Playlist URL | Download all albums from playlist |
| **Deemix - Text File** | Service, File path | Download from text file |
| **Deemix - Rileys Resolver** | Playlist URL | Get only albums you don't have |
| **Deemix - Currently Playing** | None | Download current Spotify track |

## Usage

### In Raycast

1. Open Raycast (Cmd + Space)
2. Type "deemix" to see all DeemixKit commands
3. Select a command and press Enter
4. Fill in the arguments in the input fields
5. Press Enter to execute

### Examples

```
# Download an album from Deezer
Raycast > "deemix-deezer" > Artist: Metallica > Album: Master of Puppets

# Download an album from Spotify
Raycast > "deemix-spotify" > Artist: Pink Floyd > Album: The Wall

# Download full discography
Raycast > "deemix-discography" > Artist: Radiohead > Album: OK Computer

# Resolve a URL (or use clipboard)
Raycast > "deemix-global" > URL: https://open.spotify.com/album/...

# Download from playlist
Raycast > "deemix-playlist" > URL: https://open.spotify.com/playlist/...

# Download from text file
Raycast > "deemix-textfile" > Service: Deezer > File: /path/to/albums.txt

# Get only missing albums from playlist
Raycast > "deemix-rileys" > URL: https://open.spotify.com/playlist/...

# Download currently playing
Raycast > "deemix-currently-playing"
```

## Script Details

### Deemix - Deezer
- **Icon**: `links-deezer.png`
- **Arguments**: Artist, Album
- **Mode**: fullOutput
- **Best for**: Quick Deezer searches (no setup required)

### Deemix - Spotify
- **Icon**: `links-spotify.png`
- **Arguments**: Artist, Album
- **Mode**: fullOutput
- **Best for**: Spotify catalog searches (requires API credentials)

### Deemix - Discography
- **Icon**: `links-discography.png`
- **Arguments**: Artist, Album (to identify artist)
- **Mode**: fullOutput
- **Best for**: Complete artist catalogs

### Deemix - Global
- **Icon**: `resolver-global.png`
- **Arguments**: URL (optional)
- **Mode**: fullOutput
- **Best for**: Universal URL resolving
- **Note**: Uses clipboard if no URL provided

### Deemix - Playlist
- **Icon**: `links-playlist.png`
- **Arguments**: Playlist URL
- **Mode**: fullOutput
- **Best for**: Extracting all albums from playlists

### Deemix - Text File
- **Icon**: `links-textfile.png`
- **Arguments**: Service (dropdown), File path
- **Mode**: fullOutput
- **Best for**: Bulk downloads from text files

### Deemix - Rileys Resolver
- **Icon**: `links-rileys-resolver.png`
- **Arguments**: Playlist URL
- **Mode**: fullOutput
- **Best for**: Getting only albums you don't already have
- **Note**: Requires your local music library for matching

### Deemix - Currently Playing
- **Icon**: `links-currently-playing.png`
- **Arguments**: None
- **Mode**: fullOutput
- **Best for**: One-click downloads of current track

## Keyboard Shortcuts

Assign hotkeys in Raycast for instant access:

1. Open Raycast Settings
2. Go to Extensions → Script Commands
3. Find a DeemixKit script
4. Assign a hotkey (suggestions):
   - `⌃⌥⌘D` - Deemix - Deezer
   - `⌃⌥⌘S` - Deemix - Spotify
   - `⌃⌥⌘G` - Deemix - Global
   - `⌃⌥⌘P` - Deemix - Currently Playing

## Troubleshooting

### Scripts don't appear in Raycast

1. Make sure scripts are executable:
```bash
chmod +x ~/.config/raycast/script-commands/deemix-*.sh
```

2. Reload Raycast scripts:
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

### Output in Raycast is too long

The scripts use `fullOutput` mode to show progress. If you prefer silent operation, change `@raycast.mode fullOutput` to `@raycast.mode silent` in the script metadata.

## Tips

- **Type "deemix"** in Raycast to see all DeemixKit commands grouped together
- **Use the Global resolver** with clipboard - just copy a URL and run the script
- **Assign hotkeys** for frequently used commands like "Currently Playing"
- **Text File mode** is great for bulk downloads - create a file with album names
- **Rileys Resolver** prevents duplicates by checking your existing library
