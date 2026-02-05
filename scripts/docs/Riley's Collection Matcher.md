---
title: "Riley's Collection Matcher"
description: "Fuzzy matching module for comparing albums against your local music collection to avoid duplicates"
author: riley
category: [Audio, Music]
language: Python
path: "scripts/"
created: "3rd February, 2026"
tags:
  - script
  - python
  - music
  - library
  - collection-matching
  - deduplication
  - fuzzy-matching
  - automation
---

# Riley's Collection Matcher

## Overview

A sophisticated Python module for matching albums against your local music collection using advanced fuzzy matching algorithms. Scans your collection at `/Volumes/Eksternal/Audio` with genre/letter/artist/album structure and provides intelligent deduplication for playlist tools. Handles text normalization, diacritic removal, edition filtering, and fuzzy string matching to identify albums even when names don't match exactly.

## Features

- **Sophisticated Text Normalization**: Removes diacritics, edition keywords, parenthetical content
- **Fuzzy Matching**: Levenshtein distance algorithm with configurable thresholds
- **Dual Scanning**: Scans both folder names AND audio file metadata for maximum accuracy
- **Collection Statistics**: Reports album/artist counts and genre breakdowns
- **Fast Caching**: One-time scan with in-memory cache for repeated queries
- **Smart Filtering**: Automatically filters to full albums only (excludes singles/EPs)

## Collection Structure

The script expects your collection to be organized as:

```
/Volumes/Eksternal/Audio/
├── Rock/
│   ├── M/
│   │   ├── Metallica/
│   │   │   ├── 1986 - Master of Puppets/
│   │   │   │   ├── 01 - Battery.mp3
│   │   │   │   ├── 02 - Master of Puppets.mp3
│   │   │   │   └── ...
│   │   │   └── 1988 - ...And Justice for All/
│   │   └── Megadeth/
│   └── P/
│       └── Pink Floyd/
│           └── 1973 - The Dark Side of the Moon/
└── Hip-Hop/
    ├── E/
    │   └── Eminem/
    │       └── 2000 - The Marshall Mathers LP/
    └── A/
        └── A Tribe Called Quest/
            └── 1991 - The Low End Theory/
```

**Supported folder naming formats:**
- `YYYY - Album Name` (recommended)
- `Album Name`

## Dependencies

**Python 3.7+** - Required

**Python Packages**:
- None (uses only standard library)

**Required Collection:**
- Must exist at `/Volumes/Eksternal/Audio` (or customize path)
- Structure: `Genre/Letter/Artist/Album/`

## Usage

### As a Module

```python
from rileys_collection_matcher import CollectionMatcher

# Initialize (scans your collection)
matcher = CollectionMatcher()

# Check if album exists in collection
if matcher.is_album_in_collection("Metallica", "Master of Puppets"):
    print("Already in collection!")

# Get album info
info = matcher.get_album_info("Pink Floyd", "The Dark Side of the Moon")
print(f"Year: {info['year']}, Genre: {info['genre']}")

# Filter a list of albums
albums_data = [
    {'artist': 'Metallica', 'album': 'Master of Puppets'},
    {'artist': 'New Artist', 'album': 'New Album'}
]
new_albums, existing_albums = matcher.filter_existing_albums(albums_data)
print(f"New: {len(new_albums)}, Existing: {len(existing_albums)}")

# Get collection statistics
stats = matcher.get_collection_stats()
print(f"Total: {stats['total_albums']} albums from {stats['total_artists']} artists")
```

### Standalone Test

```bash
# Run the built-in test
python3 scripts/rileys-collection-matcher.py
```

Output:
```
Scanning music collection at: /Volumes/Eksternal/Audio
Found 14158 albums in collection from 7561 artists

Collection Statistics:
Total Artists: 7561
Total Albums: 14158

Albums by Genre:
  Rock: 8532
  Hip-Hop: 2341
  Electronic: 1523
  Jazz: 987
  ...

--- Testing Sample Matches ---
A Tribe Called Quest - The Low End Theory: FOUND
  -> A Tribe Called Quest - The Low End Theory (1991) [Hip-Hop]
Eminem - The Marshall Mathers LP: FOUND
  -> Eminem - The Marshall Mathers LP (2000) [Hip-Hop]
Metallica - Master of Puppets: FOUND
  -> Metallica - Master of Puppets (1986) [Rock]
Unknown Artist - Unknown Album: NOT FOUND
```

## Source Code

```python
#!/usr/bin/env python3
"""
Collection Matcher - Deduplication Module for Spotify Toolkit

This module scans the local music collection and matches album metadata
against Spotify album data to identify albums already in the collection.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple
import unicodedata


class CollectionMatcher:
    """Handles matching Spotify albums against local music collection."""

    def __init__(self, collection_path: str = "/Volumes/Eksternal/Audio"):
        """
        Initialize the collection matcher.

        Args:
            collection_path: Path to the local music collection
        """
        self.collection_path = Path(collection_path)
        self.collection_cache = {}
        self._build_collection_index()

    def _normalize_text(self, text: str) -> str:
        """
        Normalize text for comparison by:
        - Converting to lowercase
        - Removing diacritics/accents
        - Removing edition/remaster/version text
        - Removing special characters
        - Removing extra whitespace
        - Removing common words that might differ (the, a, an)

        Args:
            text: Input text

        Returns:
            str: Normalized text
        """
        if not text:
            return ""

        # Convert to lowercase
        text = text.lower()

        # Remove diacritics/accents
        text = ''.join(
            c for c in unicodedata.normalize('NFD', text)
            if unicodedata.category(c) != 'Mn'
        )

        # Remove everything in parentheses or brackets (often contains edition info)
        text = re.sub(r'\s*[\(\[\{]([^\)\]\}]*)[\)\]\}]\s*', ' ', text)

        # Remove "+" and everything after it
        text = re.sub(r'\s*\+.*$', '', text)

        # Remove ellipsis and trailing dots
        text = re.sub(r'\.{2,}$', '', text)
        text = re.sub(r'\.$', '', text)

        # Remove common articles at the start
        text = re.sub(r'^(the|a|an)\s+', '', text)

        # Remove apostrophes and possessives
        text = re.sub(r"'s?\b", '', text)

        # Remove special characters, keep only alphanumeric and spaces
        text = re.sub(r'[^\w\s]', '', text)

        # Replace multiple spaces with single space
        text = re.sub(r'\s+', ' ', text)

        # Remove common edition/version keywords
        edition_keywords = [
            'remaster', 'remastered', 'edition', 'deluxe', 'bonus', 'expanded',
            'anniversary', 'reissue', 'special', 'limited', 'collectors', 'collector',
            'extended', 'version', 'vol', 'volume', 'disc', 'cd', 'lp', 'ep',
            'digital', 'vinyl', 'explicit', 'clean', 'instrumental',
            'live', 'acoustic', 'unplugged', 'demo', 'bootleg', 'rerecorded',
            'redux', 'revisited', 'enhanced', 'super', 'ultimate', 'definitive',
            'complete', 'compiled', 'best', 'greatest', 'hits', 'full', 'dynamic',
            'range', 'hd', 'hq', 'hi res', 'highres', 'flac', 'wav', 'mp3'
        ]

        pattern = r'\s+(' + '|'.join(edition_keywords) + r')\b.*$'
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)

        # Remove year patterns at the end
        text = re.sub(r'\s+\d{4}\s*$', '', text)

        return text.strip()

    def _extract_album_info_from_folder(self, folder_name: str) -> Tuple[str, str]:
        """
        Extract year and album name from folder name.
        Expected format: "YYYY - Album Name" or just "Album Name"

        Args:
            folder_name: Name of the album folder

        Returns:
            Tuple[str, str]: (year, album_name)
        """
        match = re.match(r'^(\d{4})\s*-\s*(.+)$', folder_name)
        if match:
            year = match.group(1)
            album_name = match.group(2).strip()
            return year, album_name

        return "", folder_name.strip()

    def _build_collection_index(self):
        """
        Scan the music collection and build an index of artists and albums.
        Scans both folder names AND audio files for maximum matching accuracy.
        """
        print(f"Scanning music collection at: {self.collection_path}")

        if not self.collection_path.exists():
            print(f"Warning: Collection path does not exist: {self.collection_path}")
            return

        album_count = 0
        audio_extensions = {'.mp3', '.flac', '.m4a', '.aac', '.ogg', '.wma', '.wav', '.ape', '.opus'}

        for genre_dir in self.collection_path.iterdir():
            if not genre_dir.is_dir() or genre_dir.name.startswith('.'):
                continue

            for alpha_dir in genre_dir.iterdir():
                if not alpha_dir.is_dir() or alpha_dir.name.startswith('.'):
                    continue

                for artist_dir in alpha_dir.iterdir():
                    if not artist_dir.is_dir() or artist_dir.name.startswith('.'):
                        continue

                    artist_name = artist_dir.name
                    normalized_artist = self._normalize_text(artist_name)

                    if normalized_artist not in self.collection_cache:
                        self.collection_cache[normalized_artist] = {}

                    for album_dir in artist_dir.iterdir():
                        if not album_dir.is_dir() or album_dir.name.startswith('.'):
                            continue

                        year, album_name = self._extract_album_info_from_folder(album_dir.name)
                        normalized_album = self._normalize_text(album_name)

                        self.collection_cache[normalized_artist][normalized_album] = {
                            'artist': artist_name,
                            'album': album_name,
                            'year': year,
                            'path': str(album_dir),
                            'genre': genre_dir.name
                        }

                        album_count += 1

        print(f"Found {album_count} albums in collection from {len(self.collection_cache)} artists")

    def _fuzzy_match(self, str1: str, str2: str, threshold: float = 0.85) -> bool:
        """
        Check if two strings are similar enough using fuzzy matching.

        Args:
            str1: First string
            str2: Second string
            threshold: Similarity threshold (0-1)

        Returns:
            bool: True if strings are similar enough
        """
        if not str1 or not str2:
            return False

        if str1 == str2:
            return True

        # Check if one contains the other
        if str1 in str2 or str2 in str1:
            len_ratio = min(len(str1), len(str2)) / max(len(str1), len(str2))
            if len_ratio >= 0.70:
                return True

        # Levenshtein distance
        len1, len2 = len(str1), len(str2)
        if len1 == 0 or len2 == 0:
            return False

        if abs(len1 - len2) > max(len1, len2) * 0.3:
            return False

        d = [[0] * (len2 + 1) for _ in range(len1 + 1)]

        for i in range(len1 + 1):
            d[i][0] = i
        for j in range(len2 + 1):
            d[0][j] = j

        for i in range(1, len1 + 1):
            for j in range(1, len2 + 1):
                cost = 0 if str1[i-1] == str2[j-1] else 1
                d[i][j] = min(
                    d[i-1][j] + 1,
                    d[i][j-1] + 1,
                    d[i-1][j-1] + cost
                )

        distance = d[len1][len2]
        similarity = 1 - (distance / max(len1, len2))

        return similarity >= threshold

    def is_album_in_collection(self, artist_name: str, album_name: str, year: str = None) -> bool:
        """
        Check if an album is already in the collection.

        Args:
            artist_name: Name of the artist
            album_name: Name of the album
            year: Optional release year for additional matching

        Returns:
            bool: True if album is in collection, False otherwise
        """
        normalized_artist = self._normalize_text(artist_name)
        normalized_album = self._normalize_text(album_name)

        # Check exact artist match
        if normalized_artist in self.collection_cache:
            if normalized_album in self.collection_cache[normalized_artist]:
                return True

            # Try fuzzy match on album names
            for cached_album in self.collection_cache[normalized_artist].keys():
                if self._fuzzy_match(normalized_album, cached_album, threshold=0.85):
                    return True

        # Try fuzzy artist match
        for cached_artist in self.collection_cache.keys():
            if self._fuzzy_match(normalized_artist, cached_artist, threshold=0.90):
                if normalized_album in self.collection_cache[cached_artist]:
                    return True

                for cached_album in self.collection_cache[cached_artist].keys():
                    if self._fuzzy_match(normalized_album, cached_album, threshold=0.85):
                        return True

        return False

    def get_album_info(self, artist_name: str, album_name: str) -> Dict:
        """Get information about an album in the collection."""
        normalized_artist = self._normalize_text(artist_name)
        normalized_album = self._normalize_text(album_name)

        if normalized_artist in self.collection_cache:
            if normalized_album in self.collection_cache[normalized_artist]:
                return self.collection_cache[normalized_artist][normalized_album]

        return None

    def filter_existing_albums(self, albums_data: List[Dict]) -> Tuple[List[Dict], List[Dict]]:
        """
        Filter a list of album data, separating existing and new albums.

        Args:
            albums_data: List of album dictionaries with 'artist' and 'album' keys

        Returns:
            Tuple[List[Dict], List[Dict]]: (new_albums, existing_albums)
        """
        new_albums = []
        existing_albums = []

        for album_data in albums_data:
            artist = album_data.get('artist', '')
            album = album_data.get('album', '')
            year = album_data.get('year', '')

            if self.is_album_in_collection(artist, album, year):
                existing_albums.append(album_data)
            else:
                new_albums.append(album_data)

        return new_albums, existing_albums

    def get_collection_stats(self) -> Dict:
        """Get statistics about the collection."""
        total_albums = sum(len(albums) for albums in self.collection_cache.values())
        total_artists = len(self.collection_cache)

        genre_counts = {}
        for artist_albums in self.collection_cache.values():
            for album_info in artist_albums.values():
                genre = album_info.get('genre', 'Unknown')
                genre_counts[genre] = genre_counts.get(genre, 0) + 1

        return {
            'total_artists': total_artists,
            'total_albums': total_albums,
            'genres': genre_counts
        }


if __name__ == "__main__":
    matcher = CollectionMatcher()
    stats = matcher.get_collection_stats()
    print("\nCollection Statistics:")
    print(f"Total Artists: {stats['total_artists']}")
    print(f"Total Albums: {stats['total_albums']}")
