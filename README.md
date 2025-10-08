# AI Design Inspiration Hub

A pioneering macOS desktop application engineered to serve as a centralized repository for wireframes and UI screenshots, providing a rich source of design inspiration specifically tailored for AI agents through a secure Model Context Protocol (MCP) server.

## Features

### Core Functionality
- 📸 **Image Management**: Upload, organize, and manage UI screenshots and wireframes
- 🏷️ **Metadata Management**: Add titles, descriptions, tags, and categories to your design assets
- 🔍 **Advanced Search**: Filter screenshots by tags, categories, keywords, and date ranges
- 🎨 **Automated Analysis**: Extract color palettes, layout information, and design specifications
- 🤖 **MCP Server**: Expose design data to AI agents via a secure API

### MCP Server Tools
The MCP server exposes three main tools for AI agents:

1. **listScreenshots**: Retrieve paginated and filtered lists of screenshots
2. **getScreenshotMetadata**: Get detailed metadata for specific screenshots
3. **getDesignSpecifications**: Access AI-parsable design specifications including:
   - Color palettes with hex codes and usage context
   - Layout structure and type
   - UI component detection
   - Typography analysis
   - General design information

### Additional Features
- 🌙 **Native macOS UI**: Built with macos_ui for authentic macOS look and feel
- 📊 **Data Export**: Export your entire library or selected items to JSON format
- 🔐 **API Key Authentication**: Secure MCP server access with API key management
- 📱 **Menubar Integration**: Quick access via macOS menubar icon
- 💾 **Local Storage**: All data stored locally with SQLite database

## Installation

### Prerequisites
- macOS Ventura (13.0) or later
- Flutter 3.0 or later

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd ai_design_inspiration_hub
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code (for JSON serialization):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the application:
```bash
flutter run -d macos
```

## Usage

### For Human Users

#### Uploading Screenshots
1. Click the "Upload" button in the toolbar
2. Select an image file (PNG, JPG, SVG, WebP)
3. Add metadata (title, description, tags, categories)
4. Click "Upload" to save

#### Organizing Screenshots
- Use tags to categorize screenshots (e.g., "mobile", "dashboard", "form")
- Add categories for hierarchical organization
- Use the search bar to find specific screenshots

#### Exporting Data
1. Click the "Export" button in the toolbar
2. Choose a destination for the JSON file
3. The export includes all metadata and design specifications

### For AI Agents

#### Starting the MCP Server
1. Go to Settings
2. Configure the port (default: 8080)
3. Click "Start Server"
4. Generate API keys for your AI agents

#### Connecting AI Agents
AI agents can connect to the MCP server at `http://localhost:8080` using the following endpoints:

**List Screenshots**
```json
POST /mcp/list-screenshots
Headers: {
  "Authorization": "Bearer YOUR_API_KEY"
}
Body: {
  "filter": {
    "tags": ["mobile", "login"],
    "categories": ["Authentication"],
    "title_query": "login",
    "date_from": "2024-01-01T00:00:00Z",
    "date_to": "2024-12-31T23:59:59Z"
  },
  "pagination": {
    "limit": 20,
    "offset": 0
  }
}
```

**Get Screenshot Metadata**
```json
POST /mcp/get-screenshot-metadata
Headers: {
  "Authorization": "Bearer YOUR_API_KEY"
}
Body: {
  "screenshot_id": "uuid-here"
}
```

**Get Design Specifications**
```json
POST /mcp/get-design-specifications
Headers: {
  "Authorization": "Bearer YOUR_API_KEY"
}
Body: {
  "screenshot_id": "uuid-here"
}
```

## Architecture

### Technology Stack
- **Frontend**: Flutter with macos_ui package
- **Database**: SQLite (via sqflite_common_ffi)
- **State Management**: Provider pattern
- **HTTP Server**: Shelf and Shelf Router
- **Image Analysis**: Custom engine using the `image` package

### Project Structure
```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── screenshot.dart
│   ├── design_specification.dart
│   ├── tag.dart
│   └── category.dart
├── providers/                # State management
│   ├── screenshot_provider.dart
│   └── settings_provider.dart
├── repositories/             # Data access layer
│   └── screenshot_repository.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── screenshot_detail_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── file_storage_service.dart
│   ├── image_analysis_service.dart
│   ├── mcp_server_service.dart
│   └── export_service.dart
└── widgets/                  # Reusable UI components
    └── screenshot_grid.dart
```

## Design Specification Extraction

The application automatically analyzes uploaded screenshots to extract:

### Color Palette
- Dominant colors with hex codes
- Color roles (primary, secondary, accent)
- Usage proportion

### Layout Analysis
- Layout type detection (horizontal, vertical, balanced)
- Aspect ratio calculation
- Basic structure description

### Future Enhancements (Roadmap)
- Advanced UI component detection using ML models
- OCR for text recognition and typography analysis
- Font family identification
- Spacing and grid system detection

## Data Schema

### Screenshot
```typescript
{
  id: string (UUID)
  title: string?
  description: string?
  imagePath: string
  creationDate: DateTime
  sourceUrl: string?
  uploadTimestamp: DateTime
  tags: string[]
  categories: string[]
}
```

### Design Specification
```typescript
{
  id: string (UUID)
  screenshotId: string
  layoutStructure: {
    type: string
    description: string?
    properties: Record<string, any>
  }?
  uiComponents: Array<{
    type: string
    label: string?
    boundingBox: {x, y, width, height}?
    properties: Record<string, any>
  }>
  colorPalette: Array<{
    hex: string
    role: string?
    usageContext: string?
    proportion: number?
  }>
  typography: Array<{
    fontFamily: string?
    fontSizePx: number?
    fontWeight: string | number?
    fontStyle: string?
    lineHeightRatio: number?
    colorHex: string?
    sampleText: string?
    context: string?
  }>
  generalDesignInfo: Record<string, any>
  analysisTimestamp: DateTime
  analysisEngineVersion: string?
}
```

## Security

- API keys stored locally using SharedPreferences
- MCP server only accepts connections from localhost
- All data stored locally on the user's machine
- No cloud synchronization (by design for privacy)

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Roadmap

### Phase 2: Enhanced Analysis
- ML-based UI component detection using TensorFlow Lite
- Advanced OCR integration with google_ml_kit
- Font recognition and typography extraction

### Phase 3: Advanced Features
- Cloud synchronization (optional)
- Team collaboration features
- Plugin system for extensibility
- Integration with design tools (Figma, Sketch)

### Phase 4: AI-Powered Features
- Smart search with natural language queries
- Design similarity search
- Automated tagging and categorization
- Style transfer and design generation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the excellent cross-platform framework
- macOS UI package contributors
- Model Context Protocol specification authors
- The open-source community

## Support

For issues, questions, or contributions, please visit the GitHub repository or contact the maintainers.

---

**AI Design Inspiration Hub** - Bridging the gap between design inspiration and AI creativity.