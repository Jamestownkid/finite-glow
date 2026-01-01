# EBook Converter Pro & PageFlow

A collection of ebook tools for all platforms.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20iOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 🚀 Quick Downloads

| Platform | App | Instructions |
|----------|-----|--------------|
| **Windows** | [EBook Converter Pro](./windows/) | Double-click `RUN_APP.bat` |
| **Linux** | [EBook Converter Pro](./linux/) | Extract tar.gz and run |
| **macOS** | [EBook Converter Pro](./macos/) | Double-click `RUN_APP.command` |
| **iOS** | [PageFlow](./ios/) | Open in Xcode, build & run |

---

## 📚 EBook Converter Pro (Desktop)

A professional ebook batch converter with a modern GUI.

### Features
- **Batch Convert** - Convert entire folders of ebooks at once
- **18+ Formats** - EPUB, MOBI, AZW3, PDF, DOCX, TXT, HTML, and more
- **Modern UI** - Clean dark/light theme with progress tracking
- **Easy to Use** - Select folders, pick format, click convert

### Windows
1. Download the `windows` folder
2. Double-click `RUN_APP.bat`
3. Select folders, pick formats, convert!

**Requirements:** Python 3.8+ and [Calibre](https://calibre-ebook.com/download)

### Linux
1. Download `EBookConverterPro-Linux.tar.gz` from `linux/`
2. Extract: `tar -xzf EBookConverterPro-Linux.tar.gz`
3. Run: `./EBookConverterPro/ebook-converter-pro`

**Requirements:** [Calibre](https://calibre-ebook.com/download) - `sudo apt install calibre`

### macOS
1. Download the `macos` folder
2. Double-click `RUN_APP.command`
3. Or build the .app: `./build_scripts/build_macos.sh`

**Requirements:** Python 3.8+ (`brew install python3`) and [Calibre](https://calibre-ebook.com/download) (`brew install calibre`)

---

## 📖 PageFlow (iOS)

A beautiful, minimalist EPUB reader for iOS built with SwiftUI.

<p align="center">
  <img src="ios/docs/icon.png" width="100" alt="PageFlow Icon">
</p>

### Features
- **📚 Beautiful Library** - Book grid with cover art and progress tracking
- **📖 Immersive Reading** - Distraction-free, tap-to-hide controls
- **🎨 Custom Typography** - Multiple fonts, sizes, spacing, margins
- **🌓 Themes** - Dark, Light, or System automatic
- **🔒 Privacy First** - No accounts, no tracking, offline-only
- **🆓 Open Source** - MIT licensed, forever free

### Installation
1. Clone this repo
2. Open `ios/PageFlow.xcodeproj` in Xcode 15+
3. Select your iPhone/iPad and press ⌘R

### Requirements
- macOS 14+ (Sonoma)
- Xcode 15+
- iOS 17+ device or simulator

---

## 📂 Repository Structure

```
├── windows/           # Windows EBook Converter
│   ├── RUN_APP.bat   # Quick launcher
│   ├── src/          # Python source code
│   └── assets/       # App icon (.ico)
│
├── linux/            # Linux EBook Converter (pre-built)
│   └── EBookConverterPro-Linux.tar.gz
│
├── macos/            # macOS EBook Converter
│   ├── RUN_APP.command  # Quick launcher (double-click)
│   ├── src/          # Python source code
│   ├── assets/       # App icon (.png)
│   └── build_scripts/  # Build .app bundle
│
└── ios/              # iOS PageFlow Reader (Swift)
    ├── PageFlow.xcodeproj
    ├── PageFlow/     # SwiftUI source code
    └── docs/         # App Store assets
```

---

## 🛠 Building from Source

### Desktop (Windows/Linux/macOS)
```bash
cd windows  # or macos
pip install -r requirements.txt
python src/main.py  # Run directly

# Build executables:
# Windows: build_scripts\build_windows.bat
# Linux: ./build_scripts/build_linux.sh
# macOS: ./build_scripts/build_macos.sh
```

### iOS
```bash
cd ios
open PageFlow.xcodeproj
# Press ⌘R in Xcode to build and run
```

---

## 📄 License

All projects are open source under the [MIT License](LICENSE).

---

## 🙏 Credits

- **EBook Converter Pro** - Powered by [Calibre](https://calibre-ebook.com/)
- **PageFlow** - Built with SwiftUI and [ZIPFoundation](https://github.com/weichsel/ZIPFoundation)

---

<p align="center">
  Made with ❤️ for book lovers everywhere
</p>
