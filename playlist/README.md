# Playlist Scripts

This folder contains tools for extracting albums from Spotify and Deezer playlists.

## Generic Tools (For Anyone)

### Playlist Downloader
Extracts **all albums** from a playlist and sends them to Deemix.

**Files:**
- `playlist-downloader.py`
- `playlist-downloader.sh`
- `playlist-downloader.applescript`

**Usage:**
```bash
./playlist/playlist-downloader.sh "https://www.deezer.com/playlist/..."
```

**What it does:**
1. Takes a playlist URL (Spotify or Deezer)
2. Extracts all unique album URLs from the playlist
3. Copies all albums to clipboard (newline-separated)
4. Pastes to Deemix → downloads everything

**Features:**
- Works with Deezer (no credentials needed)
- Works with Spotify (requires `~/.config/deemixkit/credentials.json`)
- Handles large playlists with pagination
- Removes duplicate albums automatically

---

## Personal Tools (Customized for Riley's Collection)

### Riley's Playlist Resolver
Extracts albums from a playlist, **filters out albums you already own**, and sends only the missing ones to Deemix.

**Files:**
- `rileys-playlist-resolver.py`
- `rileys-playlist-resolver.sh`

**Usage:**
```bash
./playlist/rileys-playlist-resolver.sh "https://open.spotify.com/playlist/..."
```

**What it does:**
1. Takes a playlist URL (Spotify or Deezer)
2. Extracts all unique album URLs from the playlist
3. **Compares against your local music collection** (14,000+ albums)
4. Copies **only missing albums** to clipboard
5. Pastes to Deemix → downloads only what you need

**Requirements:**
- `CollectionMatcher` at `~/scripts/rileys-collection-matcher.py`
- Spotify credentials for Spotify playlists
- Collection path: `/Volumes/Eksternal/Audio`

**Features:**
- Filters to full albums only (no singles/EPs)
- Uses sophisticated fuzzy matching to find albums in your collection
- Shows summary: "X new, Y already owned"

**Output example:**
```
Scanning collection...
Found 14158 albums in collection from 7561 artists

Fetching playlist albums...
Found 191 unique albums in playlist

Summary: 25 new, 166 already owned

Copied 25 album URLs to clipboard!
Paste into Deemix to download.
```

---

## Documentation

- **[Playlist Downloader Documentation](docs/Playlist%20Downloader.md)** - Full documentation with source code
- **[Riley's Playlist Resolver Documentation](docs/Riley's%20Playlist%20Resolver.md)** - Full documentation with source code

## Which One Should I Use?

| Use case | Tool |
|----------|------|
| **Public sharing** | `playlist-downloader` - Get all albums |
| **Personal use** | `rileys-playlist-resolver` - Get only what you don't have |
| **New to DeemixKit** | `playlist-downloader` - Simpler, no setup needed |
| **Existing library owner** | `rileys-playlist-resolver` - Avoids duplicates |
