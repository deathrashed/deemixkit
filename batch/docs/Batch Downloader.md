# Batch Downloader

Download multiple albums from a text file list with automatic progression.

## Overview

The Batch Downloader reads a text file containing artist/album pairs and downloads each one sequentially with a configurable delay between downloads. Perfect for bulk downloading your wishlist or back catalog.

## Features

- 📝 **Simple file format** - Multiple formats supported
- ⏱️ **Configurable delay** - Avoid rate limits
- 🔄 **Progress tracking** - See which album is processing
- 🎯 **Deduplication** - Automatically skips duplicates in your list
- 🖥️ **CLI and GUI** - Use from terminal or with dialog prompts
- 🔍 **Dry-run mode** - Preview what will be downloaded
- 🎵 **Service choice** - Deezer (no setup) or Spotify (requires credentials)

## File Format

Create a text file with one album per line. Multiple formats are supported:

```text
# Using dash separator (most common)
Metallica - Master of Puppets
Pink Floyd - The Dark Side of the Moon

# Using colon separator
Daft Punk: Random Access Memories

# Using space separator
Radiohead OK Computer

# Comments start with #
# Empty lines are ignored
```

## Usage

### CLI (Command Line)

```bash
# Basic usage (reads albums.txt)
./batch/batch-downloader.sh

# Specify custom file
./batch/batch-downloader.sh -f my-list.txt

# Custom delay between downloads (seconds)
./batch/batch-downloader.sh -d 15

# Use Spotify instead of Deezer
./batch/batch-downloader.sh -s spotify

# Dry run (preview only)
./batch/batch-downloader.sh -n
```

**Options:**
| Option | Short | Description |
|--------|-------|-------------|
| `--file FILE` | `-f` | Input file containing albums (default: albums.txt) |
| `--delay SECONDS` | `-d` | Delay between downloads (default: 10) |
| `--service SERVICE` | `-s` | Service: deezer or spotify (default: deezer) |
| `--dry-run` | `-n` | Show what would be downloaded without downloading |
| `--help` | `-h` | Show help message |

### GUI (Dialog)

```bash
osascript batch/batch-downloader.applescript
```

The GUI version will prompt you for:
1. File path to your album list
2. Service choice (Deezer or Spotify)
3. Delay between downloads
4. Confirmation before starting

## How It Works

```
┌─────────────────────┐
│  Read albums.txt    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Parse each line     │
│ Extract Artist/Album│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ For each album:     │
│ 1. Resolve URL      │
│ 2. Copy to clipboard │
│ 3. Paste to Deemix  │
│ 4. Wait X seconds   │
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ Show summary        │
│ Success/Failed count│
└─────────────────────┘
```

## Examples

### Download your wishlist
```text
# wishlist.txt
AC/DC - Back in Black
Led Zeppelin - IV
Nirvana - Nevermind
Queen - A Night at the Opera
```

```bash
./batch/batch-downloader.sh -f wishlist.txt -d 15
```

### Download recent favorites
```text
# recent.txt
Taylor Swift - Midnights
Billie Eilish: Hit Me Hard and Soft
Kendrick Lamar - Mr. Morale & The Big Steppers
```

```bash
./batch/batch-downloader.sh -f recent.txt -s spotify
```

### Preview before downloading
```bash
./batch/batch-downloader.sh -f large-list.txt -n
```

Output:
```
=== Batch Downloader ===
File: large-list.txt
Albums to process: 50
Service: deezer
Delay: 10s between downloads
DRY RUN MODE - No downloads will be made

[1/50] Processing: Metallica - Master of Puppets
  [DRY RUN] Would download: Metallica - Master of Puppets

[2/50] Processing: Pink Floyd - The Wall
  [DRY RUN] Would download: Pink Floyd - The Wall
...
```

## Tips

- **Start with Deezer** - No credentials needed, faster to get started
- **Adjust delay** - Default 10s works well, reduce for faster, increase for reliability
- **Use comments** - Organize your list with sections using `#`
- **Dry run first** - Verify your list format before downloading
- **Check Deemix** - Monitor downloads in the Deemix app

## Troubleshooting

### "File not found"
Make sure the file path is correct. Use absolute paths if unsure:
```bash
./batch/batch-downloader.sh -f /Users/yourname/albums.txt
```

### "Could not parse line"
Check the line format. Use one of these formats:
- `Artist - Album` (recommended)
- `Artist: Album`
- `Artist Album` (first word is artist)

### Downloads fail intermittently
Increase the delay:
```bash
./batch/batch-downloader.sh -d 20
```

### "Resolver not found"
Make sure you're running from the DeemixKit root directory, or use the full path to the script.

## File Location

Scripts are located in:
```
DeemixKit/
├── batch/
│   ├── batch-downloader.sh       # CLI version
│   ├── batch-downloader.applescript  # GUI version
│   ├── albums.txt.example         # Example list
│   └── docs/
│       └── Batch Downloader.md   # This file
```
