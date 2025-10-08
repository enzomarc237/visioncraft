import 'package:flutter/cupertino.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayManagerHandler with TrayListener {
  static final TrayManagerHandler _instance = TrayManagerHandler._internal();
  factory TrayManagerHandler() => _instance;
  TrayManagerHandler._internal();

  Future<void> initialize() async {
    trayManager.addListener(this);
    await _updateMenu();
  }

  Future<void> _updateMenu() async {
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: 'show',
            label: 'Show AI Design Inspiration Hub',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'upload',
            label: 'Upload Screenshot...',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'settings',
            label: 'Settings',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'quit',
            label: 'Quit',
          ),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'upload':
        await windowManager.show();
        await windowManager.focus();
        // The upload dialog will be triggered from the UI
        break;
      case 'settings':
        await windowManager.show();
        await windowManager.focus();
        // Navigate to settings (would need app navigator context)
        break;
      case 'quit':
        await windowManager.destroy();
        break;
    }
  }

  void dispose() {
    trayManager.removeListener(this);
  }
}