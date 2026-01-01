# EBook Converter Pro - Linux

A professional ebook batch converter with a modern GUI. Convert between EPUB, MOBI, AZW3, PDF, DOCX, and many more formats.

## Quick Start

1. Extract the archive:
   ```bash
   tar -xzf EBookConverterPro-Linux.tar.gz
   ```

2. Run the app:
   ```bash
   cd EBookConverterPro
   ./ebook-converter-pro
   ```

Or just double-click `ebook-converter-pro` in your file manager!

## Requirements

- **Calibre** - Install with:
  ```bash
  sudo apt install calibre
  ```
  Or download from https://calibre-ebook.com/download

Calibre provides the `ebook-convert` tool that handles the actual conversions.

## System-Wide Installation (Optional)

To install so you can run from anywhere:

```bash
sudo cp -r EBookConverterPro /opt/
sudo ln -s /opt/EBookConverterPro/ebook-converter-pro /usr/local/bin/ebook-converter-pro
```

Then run with: `ebook-converter-pro`

## Desktop Integration

A `.desktop` file is included. To add to your app menu:

```bash
cp EBookConverterPro/ebook-converter-pro.desktop ~/.local/share/applications/
```

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

### "Calibre not found"
```bash
sudo apt install calibre
```
Then restart the app.

### App won't start
Make sure the binary is executable:
```bash
chmod +x ebook-converter-pro
```

### GUI looks weird / missing fonts
Install required packages:
```bash
sudo apt install python3-tk fonts-dejavu
```

## License

Free to use and modify.

