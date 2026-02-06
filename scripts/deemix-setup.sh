#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default to the deemix config directory
CONFIG_DIR="/Users/rd/.config/deemix"

PORTABLE_FLAG=""
if [ "$1" = "--portable" ]; then
  PORTABLE_FLAG="--portable"
  CONFIG_DIR="$SCRIPT_DIR/config"
fi

echo "Setting up deemix CLI..."
echo "Config directory: $CONFIG_DIR"

if [ -f "$CONFIG_DIR/.arl" ]; then
  echo "ARL token already exists at $CONFIG_DIR/.arl"
  read -p "Do you want to update it? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup complete. You can now use deemix-download.sh to download."
    exit 0
  fi
fi

echo ""
echo "To get your ARL token:"
echo "1. Open https://www.deezer.com in your browser"
echo "2. Log in to your account"
echo "3. Open browser developer tools (F12 or Cmd+Opt+I)"
echo "4. Go to the 'Application' or 'Storage' tab"
echo "5. Expand 'Cookies' and select 'https://www.deezer.com'"
echo "6. Find the 'arl' cookie and copy its value"
echo ""

read -p "Paste your ARL token here: " ARL_TOKEN

if [ -z "$ARL_TOKEN" ]; then
  echo "Error: ARL token cannot be empty"
  exit 1
fi

mkdir -p "$CONFIG_DIR"
echo "$ARL_TOKEN" > "$CONFIG_DIR/.arl"

echo ""
echo "ARL token saved to $CONFIG_DIR/.arl"
echo "Setup complete! You can now use deemix-download.sh to download."
