# EBook Converter Pro

A professional ebook batch converter with a modern GUI.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey)

## Download

| Platform | Download | Instructions |
|----------|----------|--------------|
| **Windows** | [windows/](./windows/) | Double-click `RUN_APP.bat` |
| **Linux** | [linux/](./linux/) | Extract and run `ebook-converter-pro` |

## Features

- **Batch Convert** - Convert entire folders of ebooks at once
- **18+ Formats** - EPUB, MOBI, AZW3, PDF, DOCX, TXT, HTML, and more
- **Modern UI** - Clean dark/light theme with progress tracking
- **Easy to Use** - Select folders, pick format, click convert

## Screenshots

The app features a clean, modern interface:
- Source folder selection
- Output folder selection  
- Format dropdowns (convert FROM → TO)
- Progress bar with detailed log
- Dark/light theme toggle

## Requirements

### Calibre (Required)
This app uses Calibre's `ebook-convert` for actual conversions.

- **Windows**: Download from https://calibre-ebook.com/download
- **Linux**: `sudo apt install calibre`
- **macOS**: `brew install calibre`

### For Windows Users
Python 3.8+ is required to run directly. Or build a standalone EXE using the included build script.

## Quick Start

### Windows
1. Download the `windows` folder
2. Double-click `RUN_APP.bat`
3. Select folders, pick formats, convert!

### Linux
1. Download `EBookConverterPro-Linux.tar.gz` from the `linux` folder
2. Extract: `tar -xzf EBookConverterPro-Linux.tar.gz`
3. Run: `./EBookConverterPro/ebook-converter-pro`

## Supported Formats

| Can Convert FROM | Can Convert TO |
|-----------------|----------------|
| EPUB, MOBI, AZW3, AZW | EPUB, MOBI, AZW3 |
| PDF, DOCX, TXT, RTF | PDF, DOCX, TXT, RTF |
| HTML, HTM, FB2, ODT | HTML, FB2, ODT |
| LIT, PDB, SNB, TCR | HTMLZ, TXTZ |
| CBZ, CBR, CBC | CBZ |

## Building from Source

### Windows
```batch
cd windows
pip install -r requirements.txt
build_scripts\build_windows.bat
```

### Linux
```bash
# Source files are in the tar.gz if you need to rebuild
pip install -r requirements.txt
./build_scripts/build_linux.sh
```

## License

Free to use and modify. Powered by [Calibre](https://calibre-ebook.com/).

