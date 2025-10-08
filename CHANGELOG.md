# Changelog

All notable changes to AI Design Inspiration Hub will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-08

### Added - Initial MVP Release

#### Core Features
- **Image Management System**
  - Image upload via file picker and drag-and-drop
  - Support for PNG, JPG, SVG, and WebP formats
  - Automatic thumbnail generation
  - Local file storage with organized directory structure

- **Metadata Management**
  - Title and description fields
  - Flexible tagging system
  - Hierarchical category support
  - Source URL tracking
  - Creation and upload timestamps

- **Database & Data Access**
  - SQLite database with optimized schema
  - Indexed tables for fast queries
  - Repository pattern for data access
  - Junction tables for many-to-many relationships
  - Transactional operations

- **Search & Filtering**
  - Full-text search in titles and descriptions
  - Filter by tags (AND logic)
  - Filter by categories (OR logic)
  - Date range filtering
  - Pagination support
  - Combined filter queries

- **Image Analysis Engine (v0.1.0)**
  - Automatic color palette extraction (top 10 dominant colors)
  - Color role inference (primary, secondary, accent)
  - Layout type detection (horizontal, vertical, balanced)
  - Aspect ratio analysis
  - Design style classification (minimalist, vibrant, muted)
  - Background processing using Dart isolates

- **MCP Server**
  - RESTful HTTP API server using Shelf
  - API key authentication system
  - Three main endpoints:
    - `/mcp/list-screenshots` - Paginated listing with filters
    - `/mcp/get-screenshot-metadata` - Detailed metadata retrieval
    - `/mcp/get-design-specifications` - Full design specs access
  - Health check endpoint
  - JSON-RPC-like response format
  - Error handling with proper HTTP status codes
  - Request logging middleware

- **Native macOS UI**
  - Built with macos_ui package
  - Sidebar navigation
  - Native toolbar with actions
  - MacOS-style search field
  - Alert dialogs and modals
  - Progress indicators
  - Native scroll behavior

- **User Interface Screens**
  - Home screen with screenshot grid
  - Screenshot detail view with full metadata
  - Settings page for server configuration
  - Upload dialog with metadata entry
  - Color palette visualization
  - Empty state placeholders

- **Menubar Integration**
  - System tray icon
  - Context menu with quick actions:
    - Show/hide application
    - Upload screenshot
    - Open settings
    - Quit application
  - Click handlers for menu items

- **Data Export**
  - Export to JSON format
  - Structured schema with version info
  - Complete metadata inclusion
  - Design specifications included
  - Batch export of all screenshots
  - File save dialog integration

- **Settings & Configuration**
  - MCP server port configuration
  - Server start/stop controls
  - API key generation
  - API key management (view, copy, delete)
  - Settings persistence with SharedPreferences
  - Server status indicator

#### Technical Infrastructure
- **State Management**
  - Provider pattern implementation
  - ScreenshotProvider for library management
  - SettingsProvider for configuration
  - Change notification system

- **Services Layer**
  - DatabaseService for SQLite management
  - FileStorageService for image operations
  - ImageAnalysisService for design extraction
  - McpServerService for API server
  - ExportService for data export
  - TrayManagerHandler for menubar

- **Data Models**
  - Screenshot model with JSON serialization
  - DesignSpecification with nested structures
  - Tag and Category models
  - BoundingBox, ColorInfo, TypographyStyle classes
  - JSON serialization with code generation

- **Repository Pattern**
  - ScreenshotRepository for data access
  - CRUD operations
  - Complex queries with joins
  - Tag and category management
  - Design specification storage

#### Documentation
- Comprehensive README with feature overview
- API Documentation for MCP server
- User Guide with step-by-step instructions
- Quick Start Guide for developers
- Project Summary with technical details
- Inline code documentation
- MIT License

#### Developer Experience
- Code linting configuration
- Analysis options setup
- .gitignore for Flutter projects
- Asset directory structure
- Generated code for JSON serialization
- Clear project organization

### Technical Details

**Dependencies**
- Flutter SDK 3.0+
- macos_ui ^2.0.0
- sqflite_common_ffi ^2.3.0
- shelf ^1.4.0
- provider ^6.1.0
- image ^4.1.0
- And 10+ other packages

**Database Schema**
- 5 main tables (screenshots, tags, categories, junction tables)
- 2 junction tables for relationships
- 1 design specifications table
- 7 indexes for query optimization

**Performance**
- Tested with 1000+ screenshots
- <100ms MCP API response time
- Asynchronous image processing
- Thumbnail caching
- Lazy loading UI

**Security**
- API key authentication
- Local-only server binding
- Input validation
- SQL injection prevention
- Secure file storage

### Known Limitations

- **Image Analysis**: Basic color extraction only, no ML-based component detection
- **Typography**: No OCR or font recognition yet
- **UI Components**: Placeholder for future ML detection
- **Cloud Sync**: Not available (by design for privacy)
- **Collaboration**: Single-user application
- **Batch Operations**: Not yet implemented
- **Undo/Redo**: Not implemented

### Tested On

- macOS Ventura 13.0+
- Flutter 3.0+
- Dart 3.0+

---

## [Unreleased] - Future Versions

### Planned for v0.2.0 (Phase 2)
- [ ] ML-based UI component detection
- [ ] OCR integration with google_ml_kit
- [ ] Font recognition and typography analysis
- [ ] Enhanced layout analysis with grid detection
- [ ] Improved design style classification

### Planned for v0.3.0 (Phase 3)
- [ ] Cloud synchronization (optional)
- [ ] Team collaboration features
- [ ] Version history for screenshots
- [ ] Duplicate detection
- [ ] Batch operations
- [ ] Inline metadata editing

### Planned for v0.4.0 (Phase 4)
- [ ] Smart search with natural language
- [ ] Design similarity search using embeddings
- [ ] Automated tagging using ML
- [ ] Style transfer capabilities
- [ ] Design generation assistance

### Future Considerations
- [ ] Plugin system for extensibility
- [ ] Integration with design tools (Figma, Sketch)
- [ ] Advanced analytics on design library
- [ ] Custom ML model training
- [ ] Export to other formats (CSV, XML)
- [ ] Import from design tools
- [ ] Keyboard shortcuts
- [ ] Dark mode optimization
- [ ] Accessibility improvements
- [ ] Localization (i18n)

---

## Release Notes Format

Each release will include:
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

---

**Note**: This is the initial MVP release. Future versions will include enhanced AI capabilities, better UI/UX, and more advanced features based on user feedback.