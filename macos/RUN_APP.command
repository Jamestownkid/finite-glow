#!/bin/bash
# ========================================
# EBook Converter Pro - Quick Launcher
# ========================================
#
# Double-click this file to run the app
# Or run from terminal: ./RUN_APP.command
#
# ========================================

cd "$(dirname "$0")"

echo "Starting EBook Converter Pro..."

# Check Python
if ! command -v python3 &> /dev/null; then
    echo ""
    echo "ERROR: Python 3 not found"
    echo ""
    echo "Install with Homebrew:"
    echo "  brew install python3"
    echo ""
    echo "Or download from:"
    echo "  https://www.python.org/downloads/"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Install dependencies if needed
if [ ! -f ".deps_installed" ]; then
    echo "Installing dependencies..."
    pip3 install -r requirements.txt
    touch .deps_installed
fi

# Run the app
python3 src/main.py

