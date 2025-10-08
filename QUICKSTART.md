# Quick Start Guide - AI Design Inspiration Hub

Get up and running with AI Design Inspiration Hub in 5 minutes!

## Prerequisites

- macOS Ventura (13.0) or later
- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))

## Installation Steps

### 1. Clone and Setup

```bash
# Clone the repository (or navigate to the project directory)
cd /workspace

# Get dependencies
flutter pub get
```

### 2. Generate Required Files

```bash
# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the Application

```bash
# Launch on macOS
flutter run -d macos
```

The application will launch and you're ready to go!

## First Steps

### Upload Your First Screenshot

1. Click the **"Upload"** button in the toolbar
2. Fill in basic information:
   - **Title**: e.g., "Modern Dashboard Design"
   - **Tags**: e.g., "dashboard, analytics, dark-mode"
   - **Categories**: e.g., "Dashboards"
3. Select an image file
4. Click **"Upload"**

The app will automatically analyze the image and extract design specifications.

### Enable the MCP Server

To allow AI agents to access your design library:

1. Click **"Settings"** in the sidebar
2. Click **"Start Server"**
3. Click **"Generate New API Key"**
4. Copy the API key for your AI agent

Your MCP server is now running at `http://localhost:8080`

## Testing the MCP Server

Test the server with curl:

```bash
# Replace YOUR_API_KEY with your actual key
export API_KEY="your-api-key-here"

# Health check (no auth required)
curl http://localhost:8080/health

# List screenshots
curl -X POST http://localhost:8080/mcp/list-screenshots \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"pagination": {"limit": 5}}'

# Get design specifications (replace SCREENSHOT_ID)
curl -X POST http://localhost:8080/mcp/get-design-specifications \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"screenshot_id": "SCREENSHOT_ID"}'
```

## Python Example

```python
import requests

API_KEY = "your-api-key-here"
BASE_URL = "http://localhost:8080"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# List all screenshots
response = requests.post(
    f"{BASE_URL}/mcp/list-screenshots",
    headers=headers,
    json={"pagination": {"limit": 10}}
)

screenshots = response.json()
print(f"Found {len(screenshots['screenshots'])} screenshots")

# Get design specs for the first one
if screenshots['screenshots']:
    screenshot_id = screenshots['screenshots'][0]['id']
    specs = requests.post(
        f"{BASE_URL}/mcp/get-design-specifications",
        headers=headers,
        json={"screenshot_id": screenshot_id}
    ).json()
    
    print(f"Color palette: {specs['color_palette']}")
```

## Common Issues

### "flutter command not found"
- Install Flutter: https://docs.flutter.dev/get-started/install
- Add Flutter to your PATH

### Build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database errors
```bash
# Remove the database and restart
rm -rf ~/Library/Application\ Support/ai_design_inspiration_hub/
flutter run -d macos
```

### Tray icon not showing
- This is optional functionality
- The app will continue to work without it
- Check that `assets/icons/tray_icon.png` exists

## Next Steps

- 📖 Read the full [User Guide](USER_GUIDE.md)
- 🔧 Check out the [API Documentation](API_DOCUMENTATION.md)
- 🚀 Explore the [README](README.md) for detailed features
- 💡 Start building your design inspiration library!

## Development Mode

### Hot Reload
When running in development mode, you can use hot reload:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debug Console
Use the Flutter DevTools for debugging:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Running Tests (when available)
```bash
flutter test
```

## Building for Distribution

### Create a Release Build

```bash
# Build release version
flutter build macos --release

# The app bundle will be at:
# build/macos/Build/Products/Release/ai_design_inspiration_hub.app
```

### Create DMG (requires npm)

```bash
# Install create-dmg
npm install --global create-dmg

# Create DMG
create-dmg build/macos/Build/Products/Release/ai_design_inspiration_hub.app
```

## Project Structure

```
/workspace/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── repositories/             # Data access
│   ├── screens/                  # UI screens
│   ├── services/                 # Business logic
│   └── widgets/                  # Reusable components
├── assets/                       # Images and icons
├── macos/                        # macOS platform files
├── README.md                     # Project overview
├── API_DOCUMENTATION.md          # MCP API reference
├── USER_GUIDE.md                # End-user documentation
└── pubspec.yaml                 # Dependencies

```

## Support

- 📚 Documentation: Check the docs folder
- 🐛 Bug Reports: Open an issue on GitHub
- 💬 Questions: Start a discussion on GitHub

---

**You're all set!** Start uploading screenshots and exploring the power of AI-accessible design inspiration.

Happy designing! 🎨