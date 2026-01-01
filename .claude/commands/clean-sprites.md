# Clean Sprites

Remove solid color backgrounds from sprite images using ImageMagick, then resize to 256x256 (scales down nicely in-game).

## Process

1. Look for unprocessed sprites in `assets/sprites/raw/`
2. Auto-detect background color from top-left pixel
3. Remove background with 20% fuzz tolerance for AI-generated color variance
4. Resize to 256x256 pixels (default) or custom size via argument
5. Output cleaned sprites to `assets/sprites/`
6. Move processed originals to `assets/sprites/raw/completed/`

## Command

```bash
# Ensure folders exist
mkdir -p assets/sprites/raw/completed

# Get size from argument or default to 256
SIZE=${1:-256}

# Process all PNGs in raw folder
for f in assets/sprites/raw/*.png; do
  if [ -f "$f" ]; then
    filename=$(basename "$f")
    # Auto-detect background color from top-left corner
    bgcolor=$(magick "$f" -format "%[pixel:p{0,0}]" info:)
    # Remove background and resize
    magick "$f" -fuzz 20% -transparent "$bgcolor" -resize ${SIZE}x${SIZE} "assets/sprites/$filename"
    echo "Cleaned: $filename (removed $bgcolor) -> ${SIZE}x${SIZE}"
    # Move original to completed folder
    mv "$f" "assets/sprites/raw/completed/"
  fi
done
```

## Usage

Drop AI-generated sprites into `assets/sprites/raw/`, then run `/clean-sprites`. Cleaned 256x256 transparent PNGs will appear in `assets/sprites/`. Originals are moved to `assets/sprites/raw/completed/`.

Optional: specify size as argument, e.g. `/clean-sprites 128` or `/clean-sprites 512`.

$ARGUMENTS
