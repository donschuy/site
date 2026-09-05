#!/bin/bash

set -euo pipefail

# ---- CONFIGURABLE CONSTANTS ----
WEBP_QUALITY=90        # Change this to experiment
WEBP_METHOD=6          # Better compression, same quality
LOSSLESS=false         # Set to true if you want lossless WebP
# --------------------------------

DELETE_HEIC=false

print_usage() {
  echo "Usage: $0 /path/to/image_folder [--delete]"
  echo ""
  echo "Options:"
  echo "  --delete    Remove HEIC/HEIF files after successful conversion"
  exit 1
}

# ---- Parse arguments ----
if [ $# -eq 0 ]; then
  print_usage
fi

IMG_DIR="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      DELETE_HEIC=true
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      ;;
  esac
  shift
done

if [ ! -d "$IMG_DIR" ]; then
  echo "Error: '$IMG_DIR' is not a directory."
  exit 1
fi

cd "$IMG_DIR"

CPU_CORES=$(sysctl -n hw.ncpu)
echo "Using $CPU_CORES cores."
$DELETE_HEIC && echo "HEIC/HEIF originals will be deleted after conversion."

shopt -s nullglob
FILES=( *.jpg *.jpeg *.png *.heic *.HEIC *.heif *.HEIF *.tif *.tiff *.TIF *.TIFF )
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No images found."
  exit 0
fi

convert_one() {
  f="$1"
  ext="${f##*.}"
  base="${f%.*}"
  out="${base}.webp"

  echo "Converting '$f' → '$out'..."

  magick "$f" \
    -auto-orient \
    -resize 2048x2048\> \
    -define webp:lossless=$LOSSLESS \
    -define webp:method=$WEBP_METHOD \
    -quality $WEBP_QUALITY \
    +profile "!icc,*" \
    "$out"

  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if $DELETE_HEIC && [[ "$ext_lower" == "heic" || "$ext_lower" == "heif" ]]; then
      if [[ -f "$out" ]]; then
          echo "Deleting original HEIC/HEIF: $f"
          rm "$f"
      else
          echo "Warning: WebP output missing, not deleting '$f'"
      fi
  fi
}

export -f convert_one
export DELETE_HEIC
export WEBP_QUALITY
export WEBP_METHOD
export LOSSLESS

if command -v parallel >/dev/null 2>&1; then
  printf "%s\n" "${FILES[@]}" | parallel -j "$CPU_CORES" convert_one {}
else
  running_jobs=0
  for f in "${FILES[@]}"; do
    convert_one "$f" &
    ((running_jobs++))
    if (( running_jobs >= CPU_CORES )); then
      wait
      running_jobs=0
    fi
  done
  wait
fi

echo "Done."
