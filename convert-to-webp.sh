#!/bin/bash

# Default settings
DELETE_ORIGINALS=false
QUALITY=82

print_usage() {
  echo "Usage: $0 /path/to/image_folder [--delete] [--quality <value>]"
  echo ""
  echo "Options:"
  echo "  --delete            Delete original files after successful conversion"
  echo "  --quality <value>   Set WebP quality (0–100). Default: 82"
  exit 1
}

# No parameters → show usage
if [ $# -eq 0 ]; then
  print_usage
fi

IMG_DIR="$1"
shift

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      DELETE_ORIGINALS=true
      ;;
    --quality)
      shift
      if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ ]]; then
        echo "Error: --quality requires a numeric value."
        exit 1
      fi
      QUALITY="$1"
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      ;;
  esac
  shift
done

echo "WebP quality set to $QUALITY"
$DELETE_ORIGINALS && echo "Originals will be deleted after conversion."

# Validate directory
if [ ! -d "$IMG_DIR" ]; then
  echo "Error: '$IMG_DIR' is not a directory."
  exit 1
fi

cd "$IMG_DIR" || exit 1

CPU_CORES=$(sysctl -n hw.ncpu)
echo "Detected $CPU_CORES CPU cores."

shopt -s nullglob
FILES=( *.jpeg *.jpg *.png *.heic )
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No images found."
  exit 0
fi

convert_one() {
  f="$1"
  ext="${f##*.}"
  base="${f%.*}"
  tmp="$base.tmp.png"

  # HEIC → PNG first, at up to 2048px width
  if [[ "$ext" == "heic" ]]; then
    echo "Converting HEIC → PNG (max width 2048) for '$f'..."
    sips --resampleWidth 2048 -s format png "$f" --out "$tmp" >/dev/null 2>&1
    input="$tmp"
  else
    input="$f"
  fi

  out="${base}.webp"
  echo "Converting '$input' → '$out' (quality $QUALITY)..."

  if cwebp -q "$QUALITY" -metadata icc "$input" -o "$out" >/dev/null 2>&1; then
    echo "Created: $out"

    if $DELETE_ORIGINALS; then
      echo "Deleting original: $f"
      rm "$f"
    fi
  else
    echo "Failed to convert '$f'"
  fi

  [[ -f "$tmp" ]] && rm "$tmp"
}

export -f convert_one
export DELETE_ORIGINALS
export QUALITY

# Parallel processing
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
