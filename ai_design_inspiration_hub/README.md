AI Design Inspiration Hub (Scaffold)

This repository contains a scaffold for the AI Design Inspiration Hub Flutter app targeting macOS aesthetics with `macos_ui`.

Contents:
- Data models and SQLite schema via `sqflite`
- Repositories and DAOs
- Storage service for images under the app support directory
- Stubs for upload, image analysis (color palette), MCP server, menubar, and JSON export

Structure:
- lib/app.dart, lib/main.dart: App shell (macOS styled)
- lib/services/database.dart: SQLite init and schema
- lib/services/storage_service.dart: File storage helpers
- lib/models/*: Domain models
- lib/data/dao/*: DAOs
- lib/data/repositories/*: Repositories
- lib/features/*: Feature stubs (upload, analysis, export, MCP, menubar)

Getting Started:
- Install Flutter SDK (3.22+) and Dart SDK.
- Run:
- flutter pub get
- flutter run -d macos

Note: Flutter may not be installed in this environment. Once Flutter is available locally, the app should run.

Roadmap (MVP):
- Implement real MCP server per spec (listScreenshots, getScreenshotMetadata, getDesignSpecifications)
- Wire tags/categories and search filters
- Add drag-and-drop and file picker upload UI
- Expand analysis beyond color palette (OCR, layout heuristics)
- Menubar actions: show window, upload, start/stop MCP
- JSON export options in UI

Data:
- Database: Application Support/AI Design Inspiration Hub/inspiration_hub.db
- Images: Application Support/AI Design Inspiration Hub/Images/

Security:
- MCP stub includes API key placeholder. Replace with secure storage and validation.

License: TBD
