#!/bin/bash

# Icon Clustering Script
# This script clones GitHub repositories, converts SVG icons to PNG,
# generates perceptual hashes, and saves results in JSON format.

set -e # Exit on error

# Function to display progress bar
show_progress() {
    local processed=$1
    local total=$2
    local failed=$3
    local percentage=$((processed * 100 / total))
    local status="Processed ${processed}/${total} files, Failed: ${failed}"

    # Progress bar width (20 characters)
    local bar_width=20
    local filled=$((percentage * bar_width / 100))
    local empty=$((bar_width - filled))

    # Build progress bar dynamically
    local bar="|"
    for ((i = 0; i < filled; i++)); do
        bar+="▇"
    done
    for ((i = 0; i < empty; i++)); do
        bar+=" "
    done
    bar+="|"

    echo -ne "${bar} (${percentage}%)  $status \r"
}

echo "🐍 Setting up Python environment..."
./setup_python.sh

# Phase 1: Clone repositories
echo "📥 Cloning repositories..."
cat github-urls.txt | while read url; do
    echo "  Cloning: $url"
    git clone --depth 1 "$url" || true
done

# Phase 2: Convert SVG to PNG
echo "🔄 Converting SVG files to PNG..."

# Count total SVG files first
total_files=$(find . -name '*.svg' | wc -l)
processed=0
failed=0

# Create a temporary file list to avoid pipeline subshell issues
temp_svg_list=$(mktemp)
find . -name '*.svg' >"$temp_svg_list"

while read path; do
    png_path="${path%.svg}.png"

    # Skip if PNG already exists
    if [ -e "$png_path" ]; then
        processed=$((processed + 1))
        show_progress $processed $total_files $failed
        continue
    fi

    # Convert SVG to PNG with explicit size and error handling
    if ! magick "$path" -resize 64x64 -background transparent "$png_path" 2>/dev/null; then
        # Try with different approach for problematic SVGs
        if ! magick -size 64x64 "$path" -background transparent "$png_path" 2>/dev/null; then
            # Try with density setting for SVGs without viewBox
            if ! magick -density 96 "$path" -resize 64x64 -background transparent "$png_path" 2>/dev/null; then
                failed=$((failed + 1))
                processed=$((processed + 1))
                show_progress $processed $total_files $failed
                continue
            fi
        fi
    fi

    processed=$((processed + 1))
    show_progress $processed $total_files $failed
done <"$temp_svg_list"

# Show final progress
show_progress $processed $total_files $failed

# Clean up temporary file
rm "$temp_svg_list"

# Print final newline to complete the progress bar
echo -ne "\n"

# Phase 3: Collect file URLs
echo "📋 Collecting file URLs..."
for i in */; do
    pushd "$i" >/dev/null

    # Convert GitHub URL to raw URL
    prefix=$(git remote get-url origin | sed 's,https://github.com/,https://raw.githubusercontent.com/,g')

    # Find SVG files with corresponding PNG files
    find */ -name '*.svg' | while read path; do
        test -e "${path/.svg/.png}" && echo "$prefix/master/$path $prefix"
    done

    popd >/dev/null
done | grep -Ev '\.min\.' >urls.txt

# Phase 4: Generate hashes using both Python and Dart
echo "🔢 Generating perceptual hashes..."

# Collect PNG file paths and write to file
echo "  📋 Collecting PNG file paths..."
png_files=$(for i in */; do
    pushd "$i" >/dev/null

    prefix=$(git remote get-url origin | sed 's,https://github.com/,https://raw.githubusercontent.com/,g')

    # Find local PNG files for hashing
    find */ -name '*.svg' | while read path; do
        test -e "${path/.svg/.png}" && echo "$i/${path/.svg/.png}"
    done

    popd >/dev/null
done | grep -vE '\.min\.')

echo "$png_files" >png_files.txt
echo "  Total PNG files for hashing: $(echo "$png_files" | wc -l)"

echo "  🎯 Hashing with Dart..."
dart hashimages.dart

echo "  🐍 Hashing with Python..."
source venv/bin/activate
python hashimages.py

if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

echo "✅ Done! Check the following files for results:"
echo "📊 JSON files generated in example website:"
echo "   - ../example-website/src/lib/data/dart-hashes.json"
echo "   - ../example-website/src/lib/data/python-hashes.json"
echo "📊 You can now run the demo website to see the GitHub icons clustering!"
