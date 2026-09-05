#!/bin/bash

# Usage message
usage() {
  echo "Usage: $0 [--delete] /path/to/images /path/to/file.md"
  echo
  echo "Deletes .webp images in the folder that are NOT referenced in the .md file."
  echo
  echo "Options:"
  echo "  --delete    Actually delete unused .webp files."
  echo "              Without this flag, the script only prints what it would delete."
  exit 1
}

# No parameters? Show usage.
if [ $# -lt 2 ]; then
  usage
fi

DELETE_MODE=false
IMG_FOLDER=""
MD_FILE=""

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --delete)
      DELETE_MODE=true
      ;;
    *)
      if [ -z "$IMG_FOLDER" ]; then
        IMG_FOLDER="$arg"
      else
        MD_FILE="$arg"
      fi
      ;;
  esac
done

# Validate folder
if [ ! -d "$IMG_FOLDER" ]; then
  echo "Error: '$IMG_FOLDER' is not a directory."
  exit 1
fi

# Validate markdown file
if [ ! -f "$MD_FILE" ]; then
  echo "Error: '$MD_FILE' is not a file."
  exit 1
fi

# Read markdown file content
MD_CONTENT=$(cat "$MD_FILE")

shopt -s nullglob

# Process .webp files
for img in "$IMG_FOLDER"/*.webp; do
  filename=$(basename "$img")

  # Check if filename appears anywhere in the markdown file
  if ! grep -q "$filename" <<< "$MD_CONTENT"; then
    if $DELETE_MODE; then
      echo "Deleting unused image: $filename"
      rm "$img"
    else
      echo "Would delete unused image: $filename"
    fi
  fi
done

shopt -u nullglob
