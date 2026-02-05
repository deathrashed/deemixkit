# Shell Functions

Functions to use resolvers within ZSH

```shell
# ═══════════════════════════════════════════════════════════
#                   DEEMIXKIT FUNCTIONS
# ═══════════════════════════════════════════════════════════
#  - DeemixKit: Resolve album links and download via Deemix
#  - Requires: python3, requests, pyperclip (optional)
#  - Spotify requires API credentials in ~/.config/spotify-resolver/config.json

# Deezer to Deemix - Full workflow
#  - Usage: deezer "Artist" "Album"
#  - Example: deezer "Metallica" "Master of Puppets"
deezer() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: deezer \"Artist\" \"Album\""
    echo "Example: deezer \"Metallica\" \"Master of Puppets\""
    return 1
  fi
  "/path/to/DeemixKit/deezer-to-deemix.sh" "$1" "$2"
}

# Spotify to Deemix - Full workflow
#  - Usage: spotify "Artist" "Album"
#  - Example: spotify "Pink Floyd" "The Wall"
spotify() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: spotify \"Artist\" \"Album\""
    echo "Example: spotify \"Pink Floyd\" \"The Wall\""
    return 1
  fi
  "/path/to/DeemixKit/spotify-to-deemix.sh" "$1" "$2"
}

# Deezer resolver only (clipboard, no Deemix paste)
#  - Usage: deezer-link "Artist" "Album"
#  - Example: deezer-link "Slayer" "Reign in Blood"
deezer-link() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: deezer-link \"Artist\" \"Album\""
    return 1
  fi
  python3 "/path/to/DeemixKit/deezer-resolver.py" --band "$1" --album "$2"
}

# Spotify resolver only (clipboard, no Deemix paste)
#  - Usage: spotify-link "Artist" "Album"
#  - Example: spotify-link "Cannibal Corpse" "Tomb of the Mutilated"
spotify-link() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: spotify-link \"Artist\" \"Album\""
    return 1
  fi
  python3 "/path/to/DeemixKit/spotify-resolver.py" --band "$1" --album "$2"
}

# Interactive Deezer search (prompts for input)
#  - Usage: deezer-search
deezer-search() {
  local artist album
  echo -n "Artist: "
  read artist
  echo -n "Album: "
  read album
  deezer "$artist" "$album"
}

# Interactive Spotify search (prompts for input)
#  - Usage: spotify-search
spotify-search() {
  local artist album
  echo -n "Artist: "
  read artist
  echo -n "Album: "
  read album
  spotify "$artist" "$album"
}

# Download currently playing Spotify track
#  - Usage: deemix-now
deemix-now() {
  node "/path/to/DeemixKit/Currently Playing Spotify to Deemix.js"
}
```