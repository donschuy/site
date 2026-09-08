#!/bin/bash

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 /path/to/image.webp"
  exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: '$INPUT' is not a file."
  exit 1
fi

DIR="$(dirname "$INPUT")"
OUT="$DIR/preview.webp"

# Target Open Graph preview size
WIDTH=1200
HEIGHT=627

# Resize to fit within 1200x627 while preserving aspect ratio,
# cropping as needed.
magick "$INPUT" \
  -auto-orient \
  -resize "${WIDTH}x${HEIGHT}^" \
  -gravity center \
  -crop "${WIDTH}x${HEIGHT}+0+0" +repage \
  -define webp:lossless=false \
  -define webp:method=6 \
  -quality 70 \
  "$OUT"

echo "Preview image created: $OUT (1200x627)"
