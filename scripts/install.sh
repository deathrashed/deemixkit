#!/bin/bash

# DeemixKit + Deemix Installer
# For use with Keyboard Maestro or manual installation

set -x

# Default install location
DEFAULT_INSTALL_DIR="$HOME/deemixkit-install"
DEEMIX_APP_PATH="/Applications/Deemix.app"

echo "=== DeemixKit + Deemix Installer ==="

# Prompt for install location using AppleScript
INSTALL_DIR=$(osascript -e 'text returned of (display dialog "Enter installation directory for DeemixKit:" default answer "'"$HOME"'/deemixkit-install" buttons {"OK"} default button "OK")' 2>/dev/null)

# If user cancelled or empty, use default
if [[ -z "$INSTALL_DIR" ]]; then
  INSTALL_DIR="$DEFAULT_INSTALL_DIR"
fi

# Expand ~ to home directory
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

echo "Install directory: $INSTALL_DIR"
echo "Deemix path: $DEEMIX_APP_PATH"

# Create dir if needed
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo "Current directory: $(pwd)"

# Check if Deemix is already installed in /Applications
if [ -d "$DEEMIX_APP_PATH" ]; then
  echo "Deemix already installed at: $DEEMIX_APP_PATH"

  # Ask if they want to reinstall
  REINSTALL=$(osascript -e 'button returned of (display dialog "Deemix is already installed. Do you want to reinstall?" buttons {"Skip", "Reinstall"} default button "Skip")' 2>/dev/null)

  if [[ "$REINSTALL" == "Reinstall" ]]; then
    echo "Removing existing Deemix..."
    rm -rf "$DEEMIX_APP_PATH"
  else
    echo "Skipping Deemix installation"
  fi
fi

# Install Deemix if not present
if [ ! -d "$DEEMIX_APP_PATH" ]; then
  echo "Deemix not installed. Installing now..."

  DMG_PATH="$INSTALL_DIR/deemix.dmg"

  echo "Downloading Deemix to: $DMG_PATH"
  curl -L -o "$DMG_PATH" "https://github.com/bambanah/deemix/releases/latest/download/Deemix.dmg"

  if [ ! -f "$DMG_PATH" ]; then
    osascript -e 'display dialog "Failed to download Deemix!" buttons {"OK"} with icon stop' 2>/dev/null
    echo "ERROR: Download failed!"
    exit 1
  fi

  echo "Mounting DMG..."
  hdiutil attach "$DMG_PATH" -quiet -readonly

  echo "Copying to /Applications..."
  ditto /Volumes/Deemix/Deemix.app "$DEEMIX_APP_PATH"

  echo "Unmounting..."
  hdiutil detach /Volumes/Deemix -quiet

  rm -f "$DMG_PATH"

  if [ -d "$DEEMIX_APP_PATH" ]; then
    echo "Deemix installed successfully!"
  else
    osascript -e 'display dialog "Failed to install Deemix!" buttons {"OK"} with icon stop' 2>/dev/null
    echo "ERROR: Deemix installation failed!"
    exit 1
  fi
fi

# Make sure we're back in the install directory
cd "$INSTALL_DIR"
echo "Working directory: $(pwd)"

# Check for existing DeemixKit
if [ -d "deemixkit" ]; then
  echo "DeemixKit already exists at: $INSTALL_DIR/deemixkit"

  # Ask if they want to re-clone
  RECLONE=$(osascript -e 'button returned of (display dialog "DeemixKit already exists. Do you want to re-clone it?" buttons {"Keep Existing", "Re-Clone"} default button "Keep Existing")' 2>/dev/null)

  if [[ "$RECLONE" == "Re-Clone" ]]; then
    echo "Removing existing DeemixKit..."
    rm -rf deemixkit
  else
    echo "Skipping DeemixKit installation"

    # Show completion dialog
    osascript -e 'display dialog "Installation already complete!

Deemix: /Applications/Deemix.app
DeemixKit: '"$INSTALL_DIR"'/deemixkit" buttons {"OK"} with icon note' 2>/dev/null

    # Open folder in Finder
    echo "Opening in Finder..."
    open "$INSTALL_DIR/deemixkit"

    exit 0
  fi
fi

# Clone DeemixKit
if [ ! -d "deemixkit" ]; then
  echo "Cloning DeemixKit..."
  git clone https://github.com/deathrashed/deemixkit.git

  if [ -d "deemixkit" ]; then
    echo "DeemixKit cloned successfully!"
    cd deemixkit

    echo "Installing Python dependencies..."
    pip3 install requests pyperclip || echo "Warning: pip install had issues, you may need to run manually"

    # Show success dialog
    osascript -e 'display dialog "Installation Complete!

✓ Deemix installed to: /Applications/Deemix.app
✓ DeemixKit installed to: '"$INSTALL_DIR"'/deemixkit
✓ Python dependencies installed

You can now run scripts from the DeemixKit folder." buttons {"OK"} with icon note' 2>/dev/null

    echo ""
    echo "=== Installation Complete ==="
    echo "Deemix: $DEEMIX_APP_PATH"
    echo "DeemixKit: $INSTALL_DIR/deemixkit"

    # Open folder in Finder
    echo "Opening in Finder..."
    open "$INSTALL_DIR/deemixkit"
  else
    osascript -e 'display dialog "Failed to clone DeemixKit!" buttons {"OK"} with icon stop' 2>/dev/null
    echo "ERROR: Failed to clone DeemixKit!"
    exit 1
  fi
fi

exit 0
