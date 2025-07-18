#!/bin/bash

# Icon Clustering Script
# This script clones GitHub repositories, converts SVG icons to PNG,
# generates perceptual hashes, and creates HTML pages showing similar icons

set -e # Exit on error

# Setup Python environment using dedicated setup script
echo "🐍 Setting up Python environment..."
./setup_python.sh

# Phase 1: Clone repositories
echo "📥 Cloning repositories..."
cat github-urls.txt | while read url; do
    git clone "$url" 2>/dev/null || true
done

# Phase 2: Convert SVG to PNG
echo "🔄 Converting SVG files to PNG..."
find . -name '*.svg' | while read path; do
    # Skip if PNG already exists
    if [ -e "${path/.svg/.png}" ]; then
        continue
    fi

    # Convert SVG to PNG with explicit size and error handling
    echo "  Converting: $path"
    if ! magick "$path" -resize 64x64 -background transparent "${path/.svg/.png}" 2>/dev/null; then
        # Try with different approach for problematic SVGs
        if ! magick -size 64x64 "$path" -background transparent "${path/.svg/.png}" 2>/dev/null; then
            # Try with density setting for SVGs without viewBox
            if ! magick -density 96 "$path" -resize 64x64 -background transparent "${path/.svg/.png}" 2>/dev/null; then
                echo "    ⚠️  Failed to convert: $path"
                continue
            fi
        fi
    fi
done

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

# Collect PNG file paths
png_files=$(for i in */; do
    pushd "$i" >/dev/null

    prefix=$(git remote get-url origin | sed 's,https://github.com/,https://raw.githubusercontent.com/,g')

    # Find local PNG files for hashing
    find */ -name '*.svg' | while read path; do
        test -e "${path/.svg/.png}" && echo "$i/${path/.svg/.png}"
    done

    popd >/dev/null
done | grep -vE '\.min\.')

# Generate hashes with Dart
echo "  🎯 Hashing with Dart..."
echo "$png_files" | xargs dart hashimages.dart >hashes_dart.txt

# Generate hashes with Python
echo "  🐍 Hashing with Python..."
# Ensure virtual environment is activated
source venv/bin/activate
echo "$png_files" | xargs python hashimages.py >hashes_python.txt

# Deactivate virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Phase 5: Create clustering HTML pages
echo "🎯 Creating clustering HTML pages..."

for j in 2 3 4 5 6 7 8 9; do
    # Map field numbers to hash algorithm names
    case $j in
    2) algo_name="ahash" ;;
    3) algo_name="phash" ;;
    4) algo_name="dhash" ;;
    5) algo_name="whash" ;;
    6) algo_name="ahash-z" ;;
    7) algo_name="phash-z" ;;
    8) algo_name="dhash-z" ;;
    9) algo_name="whash-z" ;;
    esac

    echo "  Processing cluster level ${j} (${algo_name})..."

    # Process Dart hashes - filter out entries with zero hash in the field we're clustering on
    paste urls.txt hashes_dart.txt |
        grep -v '0000000000000000 0000000000000000 0000000000000000' |
        awk -v field=$((j + 2)) '{print $1, $2, $field}' |
        grep -v ' 0000000000000000$' >urlhashes_dart.txt

    # Process Python hashes - filter out entries with zero hash in the field we're clustering on
    paste urls.txt hashes_python.txt |
        grep -v '0000000000000000 0000000000000000 0000000000000000' |
        awk -v field=$((j + 2)) '{print $1, $2, $field}' |
        grep -v ' 0000000000000000$' >urlhashes_python.txt

    # Create HTML with split-screen layout
    cat >"${algo_name}.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Icon Clusters - ${algo_name}</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="panel dart-panel">
            <h2>🎯 Dart Hashing Results (${algo_name})</h2>
EOF

    # Generate Dart clusters
    # First, create a mapping of cluster hash to first filename for sorting
    sort -k3,3 urlhashes_dart.txt |
        uniq -f 2 -D |
        awk '{print $3}' |
        uniq |
        while read k; do
            first_file=$(awk -v cluster="$k" '($3 == cluster) {print $1; exit}' urlhashes_dart.txt)
            echo "$k $first_file"
        done | sort -k2,2 |
        while read k first_file; do
            cluster_count=$(awk -v cluster="$k" '($3 == cluster) {count++} END {print count}' urlhashes_dart.txt)
            echo "            <div class=\"cluster\">"
            echo "                <h3>Cluster: $k</h3>"
            echo "                <div class=\"cluster-count\">$cluster_count similar icons</div>"
            awk -v cluster="$k" '($3 == cluster) {
                print "                <a href=\""$2"\"><img loading=\"lazy\" src=\""$1"\" width=\"64\" alt=\"Icon\" /></a>"
            }' urlhashes_dart.txt | sort
            echo "            </div>"
        done >>"${algo_name}.html"

    cat >>"${algo_name}.html" <<EOF
        </div>
        <div class="panel python-panel">
            <h2>🐍 Python Hashing Results (${algo_name})</h2>
EOF

    # Generate Python clusters
    # First, create a mapping of cluster hash to first filename for sorting
    sort -k3,3 urlhashes_python.txt |
        uniq -f 2 -D |
        awk '{print $3}' |
        uniq |
        while read k; do
            first_file=$(awk -v cluster="$k" '($3 == cluster) {print $1; exit}' urlhashes_python.txt)
            echo "$k $first_file"
        done | sort -k2,2 |
        while read k first_file; do
            cluster_count=$(awk -v cluster="$k" '($3 == cluster) {count++} END {print count}' urlhashes_python.txt)
            echo "            <div class=\"cluster\">"
            echo "                <h3>Cluster: $k</h3>"
            echo "                <div class=\"cluster-count\">$cluster_count similar icons</div>"
            awk -v cluster="$k" '($3 == cluster) {
                print "                <a href=\""$2"\"><img loading=\"lazy\" src=\""$1"\" width=\"64\" alt=\"Icon\" /></a>"
            }' urlhashes_python.txt | sort
            echo "            </div>"
        done >>"${algo_name}.html"

    cat >>"${algo_name}.html" <<EOF
        </div>
    </div>
</body>
</html>
EOF

done

echo "✅ Done! Check the following HTML files for results:"
echo "📊 ahash.html - Average Hash clustering"
echo "📊 phash.html - Perceptual Hash clustering"
echo "📊 dhash.html - Difference Hash clustering"
echo "📊 whash.html - Wavelet Hash clustering"
echo "📊 ahash-z.html - Average Hash with Z-transform"
echo "📊 phash-z.html - Perceptual Hash with Z-transform"
echo "📊 dhash-z.html - Difference Hash with Z-transform"
echo "📊 whash-z.html - Wavelet Hash with Z-transform"
echo "📊 Dart hashes saved to: hashes_dart.txt"
echo "📊 Python hashes saved to: hashes_python.txt"
