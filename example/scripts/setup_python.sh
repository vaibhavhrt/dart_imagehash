#!/bin/bash

# Setup script for Python environment
# Run this once before using the icon clustering script

echo "🐍 Setting up Python environment for icon hashing..."

# Check if Python 3 is available
if ! command -v python3 &>/dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "  📦 Creating virtual environment..."
    python3 -m venv venv
else
    echo "  📦 Virtual environment already exists."
fi

# Activate virtual environment
echo "  🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "  ⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "  📥 Installing Python dependencies..."
pip install -r requirements.txt

echo "✅ Python environment setup complete!"
echo "📋 To manually activate the environment, run: source venv/bin/activate"
echo "📋 To deactivate, run: deactivate"

# Deactivate
deactivate
