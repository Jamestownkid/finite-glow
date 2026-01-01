# EBook Converter Pro - macOS

A professional ebook batch converter with a modern GUI. Convert between EPUB, MOBI, AZW3, PDF, DOCX, and many more formats.

## Quick Start

### Option 1: Run Directly
1. Make sure you have Python 3.8+ installed (`brew install python3`)
2. Run: `./RUN_APP.command` (double-click in Finder)
3. That's it!

### Option 2: Build .app Bundle
If you want a standalone app:
1. Run: `./build_scripts/build_macos.sh`
2. Find the app at: `dist/EBook Converter Pro.app`
3. Drag to `/Applications`

## Requirements

- **Python 3.8+** - `brew install python3`
- **Calibre** - `brew install calibre` or download from https://calibre-ebook.com/download

Calibre provides the `ebook-convert` tool that handles the actual conversions.

## Features

- Convert ebooks between 18+ formats
- Batch convert entire folders
- Filter by source format
- Modern dark/light theme UI
- Progress tracking with detailed logs
- Native macOS .app bundle support

## Supported Formats

| Format | Extensions |
|--------|-----------|
| EPUB | .epub |
| MOBI | .mobi |
| AZW3 | .azw3, .azw |
| PDF | .pdf |
| DOCX | .docx |
| TXT | .txt |
| HTML | .html, .htm |
| FB2 | .fb2 |
| RTF | .rtf |
| ODT | .odt |
| And more... | |

## Building the .app

```bash
chmod +x build_scripts/build_macos.sh
./build_scripts/build_macos.sh
```

This creates:
- `dist/EBook Converter Pro.app` - The macOS app bundle
- `dist/EBookConverterPro-macOS.zip` - Zipped app for sharing
- `dist/EBookConverterPro-macOS.dmg` - DMG installer (if hdiutil available)

## Icon

The app icon is at `assets/icon.png`. To create the `.icns` file on macOS:

```bash
mkdir icon.iconset
sips -z 16 16 assets/icon.png --out icon.iconset/icon_16x16.png
sips -z 32 32 assets/icon.png --out icon.iconset/icon_16x16@2x.png
sips -z 32 32 assets/icon.png --out icon.iconset/icon_32x32.png
sips -z 64 64 assets/icon.png --out icon.iconset/icon_32x32@2x.png
sips -z 128 128 assets/icon.png --out icon.iconset/icon_128x128.png
sips -z 256 256 assets/icon.png --out icon.iconset/icon_128x128@2x.png
sips -z 256 256 assets/icon.png --out icon.iconset/icon_256x256.png
sips -z 512 512 assets/icon.png --out icon.iconset/icon_256x256@2x.png
sips -z 512 512 assets/icon.png --out icon.iconset/icon_512x512.png
sips -z 1024 1024 assets/icon.png --out icon.iconset/icon_512x512@2x.png
iconutil -c icns icon.iconset
mv icon.icns assets/
```

## Code Signing (Optional)

For distribution outside the App Store:

```bash
codesign --force --deep --sign "Developer ID Application: Your Name" "dist/EBook Converter Pro.app"
```

## License

Free to use and modify.

