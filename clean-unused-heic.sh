#!/bin/bash

# Usage message
usage() {
  echo "Usage: $0 [--delete] /path/to/folder"
  echo
  echo "Scans the folder for HEIC files and deletes those that do not have"
  echo "a matching WEBP file (e.g., hello.heic is deleted if hello.webp does not exist)."
  echo
  echo "When --delete is provided, any .mov files in the folder are also deleted."
  echo
  echo "Options:"
  echo "  --delete    Actually delete the HEIC and MOV files."
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

shopt -s nullglob

########################################
# Delete HEIC files with no matching WEBP
########################################
for heic in *.heic; do
  base="${heic%.*}"
  webp="${base}.webp"

  if [ ! -f "$webp" ]; then
    if $DELETE_MODE; then
      echo "Deleting unused HEIC: $heic"
      rm "$heic"
    else
      echo "Would delete unused HEIC: $heic"
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

shopt -u nullglob
