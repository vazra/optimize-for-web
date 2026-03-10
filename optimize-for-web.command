#!/usr/bin/env bash
# optimize-for-web — zero-dependency Mac app for web image/video optimization
set -uo pipefail

RESOURCES_DIR="$(dirname "$0")/../Resources"
CWEBP="$RESOURCES_DIR/cwebp"
FFMPEG="$RESOURCES_DIR/ffmpeg"

# ── Helpers ──────────────────────────────────────────────────────────

show_dialog() {
  osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with icon $2 with title \"Optimize for Web\""
}

notify_done() {
  osascript -e "display notification \"$1\" with title \"Optimize for Web\" sound name \"Glass\""
}

format_size() {
  local bytes=$1
  if [ "$bytes" -ge 1048576 ]; then
    echo "$(echo "scale=1; $bytes / 1048576" | bc)MB"
  else
    echo "$(echo "scale=0; $bytes / 1024" | bc)KB"
  fi
}

# ── File & Folder Pickers ────────────────────────────────────────────

pick_files() {
  osascript <<'APPLESCRIPT'
    set fileList to choose file with prompt "Select images or videos to optimize" of type {"public.jpeg", "public.png", "public.mpeg-4", "com.apple.quicktime-movie"} with multiple selections allowed
    set posixList to {}
    repeat with f in fileList
      set end of posixList to POSIX path of f
    end repeat
    set AppleScript's text item delimiters to linefeed
    return posixList as text
APPLESCRIPT
}

pick_output_folder() {
  osascript <<'APPLESCRIPT'
    set outFolder to choose folder with prompt "Choose output folder for optimized files"
    return POSIX path of outFolder
APPLESCRIPT
}

# ── Image Optimization (cwebp) ──────────────────────────────────────

optimize_image() {
  local input="$1"
  local outdir="$2"
  local basename
  basename=$(basename "$input" | sed 's/\.[^.]*$//')
  local outfile="$outdir/${basename}.webp"

  # Get input dimensions
  local width
  width=$(sips -g pixelWidth "$input" 2>/dev/null | awk '/pixelWidth/{print $2}')

  local resize_args=""
  if [ -n "$width" ] && [ "$width" -gt 1920 ]; then
    resize_args="-resize 1920 0"
  fi

  "$CWEBP" -q 90 -metadata none $resize_args "$input" -o "$outfile" 2>/dev/null

  local in_size out_size
  in_size=$(stat -f%z "$input")
  out_size=$(stat -f%z "$outfile")
  echo "$in_size $out_size"
}

# ── Video Optimization (ffmpeg) ──────────────────────────────────────

optimize_video() {
  local input="$1"
  local outdir="$2"
  local basename
  basename=$(basename "$input" | sed 's/\.[^.]*$//')
  local out_mp4="$outdir/${basename}.mp4"
  local out_webm="$outdir/${basename}.webm"

  # H.264 MP4
  "$FFMPEG" -y -i "$input" \
    -c:v libx264 \
    -crf 28 \
    -preset slow \
    -profile:v baseline \
    -level 3.0 \
    -movflags +faststart \
    -an \
    -map_metadata -1 \
    "$out_mp4" 2>/dev/null

  # VP9 WebM
  "$FFMPEG" -y -i "$input" \
    -c:v libvpx-vp9 \
    -crf 42 \
    -b:v 0 \
    -deadline good \
    -cpu-used 3 \
    -an \
    -map_metadata -1 \
    "$out_webm" 2>/dev/null
}

# ── Main ─────────────────────────────────────────────────────────────

# Pick files
selected_files=$(pick_files) || exit 0
if [ -z "$selected_files" ]; then exit 0; fi

# Pick output folder
output_dir=$(pick_output_folder) || exit 0

# Open a Terminal-like log window via osascript
LOG_FILE=$(mktemp /tmp/optimize-for-web-log.XXXXXX)

total_in=0
total_out=0
file_count=0
errors=0

{
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║       Optimize for Web               ║"
  echo "╚══════════════════════════════════════╝"
  echo ""
  echo "Output folder: $output_dir"
  echo ""

  while IFS= read -r filepath; do
    ext="${filepath##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    name=$(basename "$filepath")

    case "$ext" in
      jpg|jpeg|png)
        printf "  IMAGE  %-40s " "$name"
        if result=$(optimize_image "$filepath" "$output_dir" 2>&1); then
          read -r in_size out_size <<< "$result"
          printf "%s → %s\n" "$(format_size "$in_size")" "$(format_size "$out_size")"
          total_in=$((total_in + in_size))
          total_out=$((total_out + out_size))
          file_count=$((file_count + 1))
        else
          printf "ERROR\n"
          echo "    $result"
          errors=$((errors + 1))
        fi
        ;;
      mp4|mov)
        printf "  VIDEO  %-40s " "$name"
        orig_size=$(stat -f%z "$filepath")
        if optimize_video "$filepath" "$output_dir" 2>&1; then
          basename_noext=$(basename "$filepath" | sed 's/\.[^.]*$//')
          mp4_size=$(stat -f%z "$output_dir/${basename_noext}.mp4")
          webm_size=$(stat -f%z "$output_dir/${basename_noext}.webm")
          printf "%s → MP4: %s / WebM: %s\n" "$(format_size "$orig_size")" "$(format_size "$mp4_size")" "$(format_size "$webm_size")"
          total_in=$((total_in + orig_size))
          total_out=$((total_out + mp4_size))
          file_count=$((file_count + 1))
        else
          printf "ERROR\n"
          errors=$((errors + 1))
        fi
        ;;
      *)
        printf "  SKIP   %-40s (unsupported format)\n" "$name"
        ;;
    esac
  done <<< "$selected_files"

  echo ""
  echo "════════════════════════════════════════"
  echo "  Files optimized: $file_count"
  if [ $errors -gt 0 ]; then
    echo "  Errors:          $errors"
  fi
  if [ $total_in -gt 0 ]; then
    echo "  Total: $(format_size $total_in) → $(format_size $total_out)"
  fi
  echo "  Output: $output_dir"
  echo "════════════════════════════════════════"
} > "$LOG_FILE" 2>&1

# Show results in a Terminal window
open -a Terminal "$LOG_FILE" 2>/dev/null || true

notify_done "$file_count file(s) optimized. Check your output folder."

if [ $errors -gt 0 ]; then
  show_dialog "$file_count file(s) optimized with $errors error(s). Check the log for details." "caution"
else
  show_dialog "$file_count file(s) optimized successfully!" "note"
fi
