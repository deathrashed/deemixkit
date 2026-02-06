#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BITRATE="3"
OUTPUT_PATH=""
PORTABLE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--bitrate)
      BITRATE="$2"
      shift 2
      ;;
    -p|--path)
      OUTPUT_PATH="-p $2"
      shift 2
      ;;
    --portable)
      PORTABLE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS] URL..."
      echo ""
      echo "Options:"
      echo "  -b, --bitrate TEXT    Bitrate: 1 (MP3 128), 3 (MP3 320), 9 (FLAC)"
      echo "  -p, --path TEXT       Download directory"
      echo "  --portable            Use portable config folder"
      echo "  -h, --help            Show this message"
      echo ""
      echo "Examples:"
      echo "  $0 https://www.deezer.com/en/album/123456"
      echo "  $0 -b 9 https://www.deezer.com/en/playlist/789012"
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -eq 0 ]; then
  echo "Error: No URLs provided"
  echo "Use -h or --help for usage information"
  exit 1
fi

PORTABLE_FLAG=""
if [ "$PORTABLE" = true ]; then
  PORTABLE_FLAG="--portable"
fi

# Run deemix directly from the installed location
DEEMIX_MAIN="/Users/rd/.config/deemix/deemix-py/__main__.py"
DEEMIX_CONFIG_DIR="/Users/rd/.config/deemix"
export DEEMIX_DATA_DIR="$DEEMIX_CONFIG_DIR"

# Clean URLs - remove backslash escapes that some shells add
clean_urls=()
for url in "$@"; do
  clean_url="${url//\\\?/?}"
  clean_url="${clean_url//\=/=}"
  clean_url="${clean_url//\\\&/&}"
  clean_urls+=("$clean_url")
done

python3 "$DEEMIX_MAIN" $PORTABLE_FLAG -b "$BITRATE" $OUTPUT_PATH "${clean_urls[@]}"
