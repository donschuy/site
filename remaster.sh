#!/bin/bash

usage() {
  echo "Usage: $0 [--delete] folder-name page-group"
  echo
  echo "Example:"
  echo "  $0 --delete secret-harbor-beach travel"
  echo
  echo "This will run:"
  echo "  clean-unused-heic.sh public/<folder>/"
  echo "  convert-to-webp.sh public/<folder>/"
  echo "  clean-unused-webp.sh public/<folder>/ src/pages/<page-group>/<folder>.md"
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

DELETE_MODE=false
FOLDER=""
PAGE_GROUP=""

# Parse args
for arg in "$@"; do
  case "$arg" in
    --delete)
      DELETE_MODE=true
      ;;
    *)
      if [ -z "$FOLDER" ]; then
        FOLDER="$arg"
      elif [ -z "$PAGE_GROUP" ]; then
        PAGE_GROUP="$arg"
      fi
      ;;
  esac
done

if [ -z "$FOLDER" ] || [ -z "$PAGE_GROUP" ]; then
  echo "Error: folder-name and page-group are required."
  echo
  usage
fi

PUBLIC_PATH="public/${FOLDER}/"
MD_PATH="src/pages/${PAGE_GROUP}/${FOLDER}.md"

# Validate paths
if [ ! -d "$PUBLIC_PATH" ]; then
  echo "Error: Folder does not exist: $PUBLIC_PATH"
  exit 1
fi

if [ ! -f "$MD_PATH" ]; then
  echo "Error: Markdown file does not exist: $MD_PATH"
  exit 1
fi

DELETE_FLAG=""
if $DELETE_MODE; then
  DELETE_FLAG="--delete"
fi

echo "Running remaster pipeline for folder: $FOLDER (page-group: $PAGE_GROUP)"
echo

echo "1. Cleaning unused HEIC files..."
./clean-unused-heic.sh "$PUBLIC_PATH" $DELETE_FLAG
echo

echo "2. Converting images to WebP..."
./convert-to-webp.sh "$PUBLIC_PATH" $DELETE_FLAG
echo

echo "3. Cleaning unused WebP files..."
./clean-unused-webp.sh $DELETE_FLAG "$PUBLIC_PATH" "$MD_PATH"
echo

echo "Remaster complete for: $FOLDER (page-group: $PAGE_GROUP)"
