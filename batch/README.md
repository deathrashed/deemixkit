# Batch Downloader

Download multiple albums from a text file list using bulk paste to Deemix.

## Features

- 📝 **Simple file format** - Multiple formats supported
- ⏱️ **Configurable delay** - Avoid rate limits
- 🔄 **Progress tracking** - See which album is processing
- 🎯 **Bulk paste approach** - All URLs copied at once, pasted once (3x faster!)
- 🖥️ **CLI and GUI** - Use from terminal or with dialog prompts
- 🔍 **Dry-run mode** - Preview what will be downloaded
- 🎵 **Service choice** - Deezer (no setup) or Spotify (requires credentials)

## Quick Start

```bash
# Default: uses albums.txt in current directory
./batch/batch-downloader.sh

# Specify custom file
./batch/batch-downloader.sh -f my-list.txt

# Use Spotify instead of Deezer
./batch/batch-downloader.sh -s spotify

# Dry run (preview only)
./batch/batch-downloader.sh -n
```

## File Format

Create `albums.txt` with one album per line:

```text
# Comments start with #
Metallica - Master of Puppets
Pink Floyd: The Dark Side of the Moon
Radiohead OK Computer
```

Accepted formats:
- `Artist - Album` (dash separator)
- `Artist: Album` (colon separator)
- `Artist Album` (space separator)

## Documentation

**[Batch Downloader Documentation](docs/Batch%20Downloader.md)** - Full documentation with source code, examples, and troubleshooting.

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--file FILE` | `-f` | Input file (default: albums.txt) |
| `--delay SECONDS` | `-d` | Delay between API calls (default: 10) |
| `--service SERVICE` | `-s` | Service: deezer or spotify (default: deezer) |
| `--dry-run` | `-n` | Show what would be downloaded |
| `--help` | `-h` | Show help message |

## How It Works

```
Read albums.txt → Parse each line → Resolve URLs →
Copy ALL to clipboard → Paste ONCE to Deemix → Download all
```

This bulk approach is ~3x faster than pasting each album individually!
