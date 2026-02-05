#!/bin/bash

# Double-clickable installer for DeemixKit + Deemix
# This opens a Terminal window and runs the installer

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the installer
bash "$SCRIPT_DIR/install.sh"

# Keep terminal open so user can see results
echo ""
echo "Press any key to close..."
read -n 1
