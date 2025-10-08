# AI Design Inspiration Hub (MVP skeleton)

Prereqs:
- Flutter SDK (we vendor under `/workspace/flutter`).
- Python 3.11+ (for the simple MCP-like server skeleton).

Run app (Linux/macOS dev host):
```bash
export PATH=/workspace/flutter/bin:$PATH
cd ai_design_inspiration_hub
flutter run -d linux
```

Run MCP-like server:
```bash
cd ai_design_inspiration_hub
# Point to the same DB the app creates in platform support dir
export AIDH_DB_PATH="$(fd ai_design_inspiration_hub.db -HI ~ 2>/dev/null | head -n1)"
python3 tools/mcp_server.py --port 8765
```

This repo includes:
- `lib/src/data/db/app_database.dart`: SQLite schema creation via sqflite_common_ffi.
- `lib/src/ui/shell/macos_shell.dart`: Minimal macOS-style shell using macos_ui.
- `tools/mcp_server.py`: Minimal HTTP JSON endpoints approximating MCP tool surface.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
