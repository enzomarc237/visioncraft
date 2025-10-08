# Build Instructions - AI Design Inspiration Hub

Detailed instructions for building, testing, and distributing the application.

## Development Setup

### Prerequisites

1. **macOS**: Version 13.0 (Ventura) or later
2. **Flutter SDK**: Version 3.0 or later
3. **Xcode**: Latest version from Mac App Store
4. **Git**: For version control

### Installing Flutter

If you haven't installed Flutter yet:

```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

### Project Setup

```bash
# Navigate to project directory
cd /workspace

# Install dependencies
flutter pub get

# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs

# Verify Flutter configuration
flutter doctor -v
```

## Development Build

### Running in Debug Mode

```bash
# List available devices
flutter devices

# Run on macOS
flutter run -d macos

# Run with verbose logging
flutter run -d macos -v
```

### Hot Reload

While the app is running in debug mode:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debugging

```bash
# Run with DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Then run your app and open the DevTools URL shown
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/screenshot_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
open coverage/html/index.html
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check for issues
dart fix --dry-run
dart fix --apply
```

## Production Build

### Release Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release version
flutter build macos --release

# Output location:
# build/macos/Build/Products/Release/ai_design_inspiration_hub.app
```

### Build Configuration

The release build includes:
- Optimized Dart code
- Tree-shaking for smaller size
- No debug symbols
- Production-ready assets

## Creating Distributable Packages

### Option 1: ZIP Archive

```bash
# Navigate to build directory
cd build/macos/Build/Products/Release

# Create ZIP
zip -r ai_design_inspiration_hub.zip ai_design_inspiration_hub.app

# The ZIP can now be distributed
```

### Option 2: DMG Installer

```bash
# Install create-dmg (requires Node.js)
npm install --global create-dmg

# Create DMG
cd build/macos/Build/Products/Release
create-dmg ai_design_inspiration_hub.app

# Or with custom options
create-dmg \
  --overwrite \
  --volname "AI Design Inspiration Hub" \
  --volicon "../../../../../../assets/icons/app_icon.icns" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "ai_design_inspiration_hub.app" 200 190 \
  --hide-extension "ai_design_inspiration_hub.app" \
  --app-drop-link 600 185 \
  "AIDesignInspirationHub.dmg" \
  "ai_design_inspiration_hub.app"
```

### Option 3: Mac App Store (Future)

To distribute via Mac App Store:

1. **Apple Developer Account**: Required ($99/year)
2. **App Signing**: Configure signing certificates
3. **Sandboxing**: Enable App Sandbox
4. **Entitlements**: Configure required permissions
5. **App Store Connect**: Create app listing
6. **Review Process**: Submit for Apple review

See [Mac App Store Distribution Guide](https://developer.apple.com/macos/submit/)

## Code Signing (Optional)

### Developer ID Signing

For distribution outside Mac App Store:

```bash
# Sign the app bundle
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/ai_design_inspiration_hub.app

# Verify signing
codesign --verify --verbose \
  build/macos/Build/Products/Release/ai_design_inspiration_hub.app

# Check if app is notarized
spctl -a -v build/macos/Build/Products/Release/ai_design_inspiration_hub.app
```

### Notarization

For macOS Catalina and later:

```bash
# Create a ZIP for notarization
ditto -c -k --keepParent \
  build/macos/Build/Products/Release/ai_design_inspiration_hub.app \
  ai_design_inspiration_hub.zip

# Submit for notarization
xcrun notarytool submit ai_design_inspiration_hub.zip \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "TEAM_ID" \
  --wait

# Staple the notarization ticket
xcrun stapler staple \
  build/macos/Build/Products/Release/ai_design_inspiration_hub.app
```

## Continuous Integration

### GitHub Actions (Example)

Create `.github/workflows/build.yml`:

```yaml
name: Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Run tests
      run: flutter test
    
    - name: Build macOS
      run: flutter build macos --release
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: macos-build
        path: build/macos/Build/Products/Release/
```

## Versioning

### Updating Version Number

Edit `pubspec.yaml`:

```yaml
version: 0.2.0+2  # version+build_number
```

### Build Numbers

- **Version**: User-facing (e.g., 0.1.0, 1.0.0, 1.2.3)
- **Build Number**: Internal (e.g., 1, 2, 3...)
- Format: `version+build`

## Asset Management

### Adding New Assets

1. Place files in appropriate directories:
   - `assets/images/` for images
   - `assets/icons/` for icons

2. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/new_image.png
    - assets/icons/new_icon.png
```

3. Run:
```bash
flutter pub get
```

### App Icon

To update the app icon:

1. Create icon at various sizes (16x16 to 1024x1024)
2. Use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
3. Or manually update `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

## Troubleshooting Build Issues

### Common Issues

**Issue: "flutter: command not found"**
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

**Issue: "Unable to find bundled Java version"**
```bash
# Update Flutter
flutter upgrade
flutter doctor
```

**Issue: "Build failed with CocoaPods"**
```bash
cd macos
pod install
cd ..
flutter clean
flutter build macos
```

**Issue: "SQLite not found"**
```bash
# Rebuild dependencies
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue: "Generated files out of sync"**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build

When all else fails:

```bash
# Nuclear option - complete clean
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build macos --release
```

## Performance Optimization

### Build Optimizations

```bash
# Build with additional optimizations
flutter build macos --release \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --tree-shake-icons
```

### Size Optimization

```bash
# Analyze build size
flutter build macos --release --analyze-size

# Remove unused code
flutter build macos --release --split-debug-info=./debug-info
```

## Documentation Generation

### API Documentation

```bash
# Generate dartdoc
flutter pub global activate dartdoc
dartdoc

# View documentation
open doc/api/index.html
```

## Development Tools

### Recommended VS Code Extensions

- Flutter
- Dart
- Flutter Widget Snippets
- Pubspec Assist
- Error Lens

### Recommended Xcode Settings

- Enable Developer Mode: `sudo DevToolsSecurity -enable`
- Install Command Line Tools: `xcode-select --install`

## Release Checklist

Before releasing a new version:

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run all tests: `flutter test`
- [ ] Run code analysis: `flutter analyze`
- [ ] Build release version: `flutter build macos --release`
- [ ] Test the release build thoroughly
- [ ] Create signed build (if distributing)
- [ ] Generate release notes
- [ ] Tag release in Git
- [ ] Create GitHub release
- [ ] Upload distributable files

## Support

For build issues:
1. Check Flutter documentation: https://docs.flutter.dev
2. Review GitHub issues
3. Ask in Flutter Discord/Slack
4. Post on Stack Overflow with `flutter` tag

---

**Happy Building!** 🚀