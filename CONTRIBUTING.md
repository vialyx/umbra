# Contributing to Umbra

Thank you for your interest in contributing to Umbra! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- macOS version and device information
- Relevant logs or screenshots

### Suggesting Features

Feature requests are welcome! Please create an issue with:
- Clear description of the feature
- Use case and benefits
- Potential implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Code Style

- Follow Swift naming conventions
- Use SwiftUI for all UI code
- Add comments for complex logic
- Keep functions focused and small
- Write descriptive commit messages

### Testing

Before submitting a PR:
1. Build and test the app locally
2. Test with real Bluetooth devices
3. Verify no crashes or memory leaks
4. Check that settings persist correctly

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/umbra.git
cd umbra

# Build the app
make build

# Run for testing
./test-app.sh
open build/Umbra.app
```

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain professionalism

## Questions?

Feel free to open an issue for any questions about contributing!
