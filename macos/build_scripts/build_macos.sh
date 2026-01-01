#!/bin/bash
# ============================================
# EBook Converter Pro - macOS Build Script
# ============================================
#
# Prerequisites:
#   1. Python 3.8+ installed (use brew or python.org)
#   2. pip install -r requirements.txt
#   3. Add icon.icns to assets folder
#
# This script creates:
#   - A .app bundle (EBook Converter Pro.app)
#   - A DMG installer (optional)
#   - A ZIP for distribution
#
# ============================================

set -e

echo ""
echo "========================================"
echo "  EBook Converter Pro - macOS Build"
echo "========================================"
echo ""

# 1a. check python
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 not found"
    echo "Install with: brew install python3"
    echo "Or download from python.org"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Using Python $PYTHON_VERSION"

# 1b. check tkinter
python3 -c "import tkinter" 2>/dev/null || {
    echo "ERROR: tkinter not installed"
    echo "If using brew python, tkinter should be included"
    echo "Otherwise reinstall python with tkinter support"
    exit 1
}

# 1c. create virtual environment
if [ ! -d "venv" ]; then
    echo ""
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

# 1d. install dependencies
echo ""
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# 1e. clean previous builds
echo ""
echo "Cleaning previous builds..."
rm -rf dist build
rm -f *.dmg

# 1f. check for icon
if [ ! -f "assets/icon.icns" ]; then
    echo ""
    echo "WARNING: No icon.icns found in assets folder"
    echo "The build will continue with default PyInstaller icon"
    echo ""
    echo "To create an icns file from a PNG:"
    echo "  mkdir icon.iconset"
    echo "  sips -z 16 16 icon.png --out icon.iconset/icon_16x16.png"
    echo "  sips -z 32 32 icon.png --out icon.iconset/icon_16x16@2x.png"
    echo "  sips -z 32 32 icon.png --out icon.iconset/icon_32x32.png"
    echo "  sips -z 64 64 icon.png --out icon.iconset/icon_32x32@2x.png"
    echo "  sips -z 128 128 icon.png --out icon.iconset/icon_128x128.png"
    echo "  sips -z 256 256 icon.png --out icon.iconset/icon_128x128@2x.png"
    echo "  sips -z 256 256 icon.png --out icon.iconset/icon_256x256.png"
    echo "  sips -z 512 512 icon.png --out icon.iconset/icon_256x256@2x.png"
    echo "  sips -z 512 512 icon.png --out icon.iconset/icon_512x512.png"
    echo "  sips -z 1024 1024 icon.png --out icon.iconset/icon_512x512@2x.png"
    echo "  iconutil -c icns icon.iconset"
    echo "  mv icon.icns assets/"
    echo ""
fi

# 1g. run pyinstaller
echo ""
echo "Building .app bundle..."
pyinstaller build_macos.spec --noconfirm

# 1h. verify app was created
if [ ! -d "dist/EBook Converter Pro.app" ]; then
    echo "ERROR: .app bundle was not created"
    exit 1
fi

echo ""
echo ".app bundle created successfully"

# 1i. create ZIP of the app
echo ""
echo "Creating ZIP package..."
cd dist
zip -r "EBookConverterPro-macOS.zip" "EBook Converter Pro.app"
cd ..

# 1j. optionally create DMG (if create-dmg is installed)
if command -v create-dmg &> /dev/null; then
    echo ""
    echo "Creating DMG installer..."
    create-dmg \
        --volname "EBook Converter Pro" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "EBook Converter Pro.app" 150 185 \
        --app-drop-link 450 185 \
        "dist/EBookConverterPro-macOS.dmg" \
        "dist/EBook Converter Pro.app"
else
    echo ""
    echo "Note: install create-dmg for fancy DMG creation:"
    echo "  brew install create-dmg"
    echo ""
    echo "Creating simple DMG with hdiutil..."
    
    # simple dmg creation using hdiutil
    hdiutil create -volname "EBook Converter Pro" \
        -srcfolder "dist/EBook Converter Pro.app" \
        -ov -format UDZO \
        "dist/EBookConverterPro-macOS.dmg" 2>/dev/null || {
        echo "DMG creation skipped (hdiutil not available or failed)"
    }
fi

# 1k. copy readme
if [ -f "docs/README.txt" ]; then
    cp docs/README.txt dist/
fi

echo ""
echo "========================================"
echo "  BUILD COMPLETE!"
echo "========================================"
echo ""
echo "Output location:"
echo "  dist/EBook Converter Pro.app"
echo ""
echo "Packages created:"
echo "  dist/EBookConverterPro-macOS.zip"
if [ -f "dist/EBookConverterPro-macOS.dmg" ]; then
    echo "  dist/EBookConverterPro-macOS.dmg"
fi
echo ""
echo "To run the app:"
echo "  open 'dist/EBook Converter Pro.app'"
echo ""
echo "To install:"
echo "  Drag 'EBook Converter Pro.app' to /Applications"
echo ""

# 1l. optional code signing reminder
echo "========================================"
echo "  CODE SIGNING (Optional)"
echo "========================================"
echo ""
echo "To distribute outside the App Store, you may want to sign the app:"
echo "  codesign --force --deep --sign 'Developer ID Application: Your Name' 'dist/EBook Converter Pro.app'"
echo ""
echo "To notarize for Gatekeeper (requires Apple Developer account):"
echo "  xcrun notarytool submit dist/EBookConverterPro-macOS.dmg --apple-id YOUR_APPLE_ID --team-id YOUR_TEAM_ID"
echo ""
