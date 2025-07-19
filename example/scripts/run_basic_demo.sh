#!/bin/bash

# Basic Demo Hash Generation Script
# This script generates perceptual hashes for the sample images

set -e # Exit on error

echo "🔢 Generating hashes for basic demo..."

echo "🐍 Setting up Python environment..."
./setup_python.sh

echo "  🎯 Hashing with Dart..."
dart basic_demo_hashes.dart ../../sample_images/cat1.JPG ../../sample_images/cat1-modified.JPG ../../sample_images/cat2.JPG

echo "  🐍 Hashing with Python..."
source venv/bin/activate
python3 basic_demo_hashes.py ../../sample_images/cat1.JPG ../../sample_images/cat1-modified.JPG ../../sample_images/cat2.JPG

if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

echo "✅ Done! Basic demo JSON files generated:"
echo "📊 Files generated:"
echo "   - ../example-website/src/lib/data/basic-demo-dart.json"
echo "   - ../example-website/src/lib/data/basic-demo-python.json"
