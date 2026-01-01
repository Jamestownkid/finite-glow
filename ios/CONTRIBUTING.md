# Contributing to PageFlow

First off, thank you for considering contributing to PageFlow! It's people like you that make PageFlow such a great tool.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct: be respectful, inclusive, and considerate.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When creating a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs **actual behavior**
- **Screenshots** if applicable
- **Device info**: iOS version, device model
- **App version**: Found in Settings > About

### Suggesting Features

Feature requests are welcome! Please:

- Check existing issues first
- Describe the feature and why it's useful
- Consider how it fits with PageFlow's minimalist philosophy

### Pull Requests

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create a branch** for your changes: `git checkout -b feature/your-feature`
4. **Make your changes** following our code style
5. **Test** your changes thoroughly
6. **Commit** with clear messages
7. **Push** to your fork
8. **Open a PR** with a clear description

## Code Style Guidelines

### Swift

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions small and focused
- Add documentation comments for public APIs

### SwiftUI

- Prefer composition over large views
- Extract reusable components
- Use `@ViewBuilder` for conditional content
- Keep views declarative

### File Organization

```swift
// MARK: - Properties

// MARK: - Body

// MARK: - Subviews

// MARK: - Helpers
```

### Commit Messages

Use conventional commits:

```
feat: add dark mode toggle
fix: resolve crash when importing large EPUB
docs: update README with new screenshots
style: format code with SwiftFormat
refactor: simplify EPUB parser logic
test: add unit tests for BookManager
```

## Development Setup

1. Install Xcode 15+
2. Clone the repo
3. Open `PageFlow.xcodeproj`
4. Build and run

## Testing

- Write tests for new features
- Ensure existing tests pass
- Test on multiple device sizes
- Test both light and dark modes

## Questions?

Feel free to open an issue for any questions!

Thank you for contributing! 🎉

