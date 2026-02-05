#!/bin/bash

# Script to remove personal paths from all documentation files
# Usage: ./cleanup-docs.sh

echo "🧹 Removing personal paths from documentation files..."

# Define patterns to replace
OLD_PATH1="~/Scripts/Riley/Audio/DeemixKit"
OLD_PATH2="/path/to/DeemixKit"
OLD_PATH3='~/Scripts/Riley/Audio/'

# New patterns
NEW_PATH="./"
NEW_PATH2="/path/to/DeemixKit"

# List of documentation files
FILES=(
  "Currently Playing to Deemix.md"
  "Discography to Deemix.md"
  "Spotify to Deemix.md"
  "Deezer to Deemix.md"
  "Spotify Resolver.md"
  "Deezer Resolver.md"
  "Paste to Deemix.md"
  "Keyboard Maestro DeemixKit.md"
  "DeemixKit.md"
  "Shell Functions.md"
  "Deezer to Deemix.md"
  "Spotify to Deemix.md"
  "Currently Playing to Deemix.md"
)

# Process each file
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  Processing: $file"
    # Use sed for in-place replacement
    sed -i '' "s|$OLD_PATH1|./|g" "$file"
    sed -i '' "s|$OLD_PATH3|$NEW_PATH2|g" "$file"
    sed -i '' "s|~/Scripts/Riley/Audio|$NEW_PATH2|g" "$file"
  fi
done

echo "✅ Done!"
echo ""
echo "📋 Files processed: ${#FILES[@]}"
echo "💡 Next steps:"
echo "  1. Review updated files"
echo "  2. Test examples in README"
echo "  3. Commit changes to git"
