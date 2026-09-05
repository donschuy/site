#!/bin/bash

# Usage message
usage() {
  echo "Usage: $0 [--delete] /path/to/folder"
  echo
  echo "Scans the folder for .heic and .HEIC files and deletes those that do not"
  echo "have a corresponding lowercase .webp file (e.g., IMG_4923.webp)."
  echo
  echo "Options:"
  echo "  --delete    Actually delete the HEIC/HEIC files."
  echo "              Without this flag, the script only prints what it would delete."
  exit 1
}

# No parameters? Show usage.
if [ $# -eq 0 ]; then
  usage
fi

# Parse arguments
DELETE_MODE=false
FOLDER=""

for arg in "$@"; do
  case "$arg" in
    --delete)
      DELETE_MODE=true
      ;;
    *)
      FOLDER="$arg"
      ;;
  esac
done

# Validate folder
if [ -z "$FOLDER" ]; then
  echo "Error: No folder provided."
  echo
  usage
fi

if [ ! -d "$FOLDER" ]; then
  echo "Error: '$FOLDER' is not a directory."
  exit 1
fi

# Move into folder
cd "$FOLDER" || exit 1

# Enable case-insensitive globbing so *.heic matches .heic and .HEIC
shopt -s nocaseglob
shopt -s nullglob

# Process HEIC files
for heic in *.heic; do
  base="${heic%.*}"        # e.g., IMG_4923
  webp="${base}.webp"      # always lowercase

  if [ ! -f "$webp" ]; then
    if $DELETE_MODE; then
      echo "Deleting HEIC without matching WEBP: $heic"
      rm "$heic"
    else
      echo "Would delete HEIC without matching WEBP: $heic"
    fi
  fi
done


########################################
# Delete MOV files (only when --delete)
########################################
for mov in *.mov; do
  if $DELETE_MODE; then
    echo "Deleting MOV file: $mov"
    rm "$mov"
  else
    echo "Would delete MOV file: $mov"
  fi
done

# Restore globbing defaults
shopt -u nocaseglob
shopt -u nullglob
