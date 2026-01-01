#!/bin/bash
# ============================================
# EBook Converter Pro - Linux Build Script
# ============================================
#
# Prerequisites:
#   1. Python 3.8+ installed
#   2. pip install -r requirements.txt
#   3. (Optional) Add icon.png to assets folder
#
# ============================================

set -e

echo ""
echo "========================================"
echo "  EBook Converter Pro - Linux Build"
echo "========================================"
echo ""

# 1a. check python
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 not found"
    echo "Install with: sudo apt install python3 python3-pip python3-tk"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Using Python $PYTHON_VERSION"

# 1b. check tkinter
python3 -c "import tkinter" 2>/dev/null || {
    echo "ERROR: tkinter not installed"
    echo "Install with: sudo apt install python3-tk"
    exit 1
}

# 1c. create virtual environment (recommended)
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

# 1f. check for icon
if [ ! -f "assets/icon.png" ]; then
    echo ""
    echo "WARNING: No icon.png found in assets folder"
    echo "The build will continue without a custom icon"
    echo ""
fi

# 1g. run pyinstaller
echo ""
echo "Building executable..."
pyinstaller build_linux.spec --noconfirm

# 1h. create tar.gz package
echo ""
echo "Creating package..."
cd dist
tar -czvf EBookConverterPro-Linux.tar.gz EBookConverterPro
cd ..

# 1i. copy docs
if [ -f "docs/README.txt" ]; then
    cp docs/README.txt dist/EBookConverterPro/
fi

# 1j. create .desktop file for Linux
cat > dist/EBookConverterPro/ebook-converter-pro.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=EBook Converter Pro
Comment=Convert ebooks between formats
Exec=./ebook-converter-pro
Icon=icon
Terminal=false
Categories=Office;Utility;
EOF

chmod +x dist/EBookConverterPro/ebook-converter-pro

echo ""
echo "========================================"
echo "  BUILD COMPLETE!"
echo "========================================"
echo ""
echo "Output location:"
echo "  dist/EBookConverterPro/"
echo ""
echo "Package:"
echo "  dist/EBookConverterPro-Linux.tar.gz"
echo ""
echo "To run the app:"
echo "  ./dist/EBookConverterPro/ebook-converter-pro"
echo ""
echo "To install system-wide:"
echo "  sudo cp -r dist/EBookConverterPro /opt/"
echo "  sudo ln -s /opt/EBookConverterPro/ebook-converter-pro /usr/local/bin/"
echo ""
