# EBook Converter Pro - Windows

A professional ebook batch converter with a modern GUI. Convert between EPUB, MOBI, AZW3, PDF, DOCX, and many more formats.

## Quick Start

### Option 1: Run Directly (Recommended)
1. Make sure you have [Python 3.8+](https://www.python.org/downloads/) installed
2. Double-click `RUN_APP.bat`
3. That's it!

### Option 2: Build Standalone EXE
If you want a standalone executable that doesn't require Python:
1. Double-click `build_scripts\build_windows.bat`
2. Wait for the build to complete
3. Find the app in `dist\EBookConverterPro\`
4. Run `EBookConverterPro.exe`

## Requirements

- **Python 3.8+** (for Option 1) - [Download here](https://www.python.org/downloads/)
- **Calibre** - [Download here](https://calibre-ebook.com/download)

Calibre provides the `ebook-convert` tool that handles the actual conversions.

## Features

- Convert ebooks between 18+ formats
- Batch convert entire folders
- Filter by source format
- Modern dark/light theme UI
- Progress tracking with detailed logs
- Cross-platform (Windows, macOS, Linux)

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

## Troubleshooting

### "Python is not installed"
Download Python from https://www.python.org/downloads/
**Important:** Check "Add Python to PATH" during installation!

### "Calibre not found"
Download Calibre from https://calibre-ebook.com/download
After installing, restart the app.

### Build fails
Make sure you have these installed:
```
pip install customtkinter pyinstaller pillow
```

## License

Free to use and modify.

