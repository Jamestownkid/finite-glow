# PageFlow

<p align="center">
  <img src="docs/icon.png" width="128" alt="PageFlow Icon">
</p>

<p align="center">
  <strong>A minimalist EPUB reader for iOS</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017+-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-✓-green?style=flat-square" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" alt="License">
</p>

---

## ✨ Features

- **📚 Beautiful Library** - Organize your books with cover art and reading progress
- **📖 Immersive Reading** - Distraction-free reading experience with tap-to-hide controls
- **🎨 Customizable Typography** - Choose fonts, sizes, spacing, and margins
- **🌓 Dark & Light Themes** - Read comfortably day or night
- **🔒 Privacy First** - No accounts, no tracking, your books stay local
- **📱 Native iOS** - Built entirely with SwiftUI for butter-smooth performance
- **🆓 Free & Open Source** - MIT licensed, forever free

## 📱 Screenshots

| Library | Reader | Settings |
|---------|--------|----------|
| ![Library](docs/screenshot-library.png) | ![Reader](docs/screenshot-reader.png) | ![Settings](docs/screenshot-settings.png) |

## 🚀 Installation

### App Store
Coming soon to the App Store!

### Build from Source

**Requirements:**
- macOS 14+ (Sonoma)
- Xcode 15+
- iOS 17+ device or simulator

**Steps:**

1. Clone the repository
```bash
git clone https://github.com/your-username/PageFlow.git
cd PageFlow
```

2. Open in Xcode
```bash
open PageFlow.xcodeproj
```

3. Select your target device and press `⌘R` to build and run

## 🏗 Architecture

PageFlow uses a clean **MVVM** (Model-View-ViewModel) architecture:

```
PageFlow/
├── PageFlowApp.swift         # App entry point
├── ContentView.swift         # Main tab container
├── Views/
│   ├── LibraryView.swift     # Book grid with search
│   ├── ReaderView.swift      # Reading experience
│   └── SettingsView.swift    # App settings
├── Models/
│   └── Book.swift            # Book data model
├── ViewModels/
│   └── BookManager.swift     # Library management
├── Services/
│   └── EPUBParser.swift      # EPUB file parsing
├── Extensions/
│   └── Color+Extensions.swift
└── Resources/
    └── Assets.xcassets
```

### Key Design Decisions

- **SwiftUI Only** - No UIKit, pure declarative UI
- **iOS 17+** - Leverages latest SwiftUI features
- **Zero Dependencies** - Only ZIPFoundation for EPUB handling
- **Offline First** - Everything works without internet
- **Privacy by Design** - No analytics, no tracking, no accounts

## 🎨 Design Philosophy

PageFlow follows these principles:

1. **Minimalism** - Every pixel serves a purpose
2. **Typography First** - Beautiful reading experience is paramount
3. **Native Feel** - Follows Apple Human Interface Guidelines
4. **Performance** - 60fps everywhere, instant response
5. **Accessibility** - VoiceOver and Dynamic Type support

## 📖 Supported Formats

| Format | Read | Import |
|--------|------|--------|
| EPUB | ✅ | ✅ |
| EPUB3 | ✅ | ✅ |

## 🛠 Development

### Prerequisites

```bash
# Install Xcode command line tools
xcode-select --install

# Clone with submodules
git clone --recursive https://github.com/your-username/PageFlow.git
```

### Building

```bash
# Open project
open PageFlow.xcodeproj

# Or build from command line
xcodebuild -project PageFlow.xcodeproj -scheme PageFlow -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Testing

```bash
# Run tests
xcodebuild test -project PageFlow.xcodeproj -scheme PageFlow -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint (configuration included)
- Write meaningful commit messages
- Add tests for new features

## 📄 License

PageFlow is open source software licensed under the [MIT License](LICENSE).

```
MIT License

Copyright (c) 2024 PageFlow

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - ZIP file handling
- [Apple SF Symbols](https://developer.apple.com/sf-symbols/) - Beautiful icons
- The SwiftUI community for inspiration

---

<p align="center">
  Made with ❤️ using SwiftUI
</p>

