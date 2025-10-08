import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

import 'services/database_service.dart';
import 'services/mcp_server_service.dart';
import 'services/tray_manager_handler.dart';
import 'providers/screenshot_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'AI Design Inspiration Hub',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  // Initialize tray manager
  try {
    await trayManager.setIcon(
      'assets/icons/tray_icon.png',
      isTemplate: true,
    );
    final trayHandler = TrayManagerHandler();
    await trayHandler.initialize();
  } catch (e) {
    print('Tray manager initialization failed: $e');
    // Continue without tray support
  }
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<ScreenshotProvider>(
          create: (context) => ScreenshotProvider(
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        Provider<McpServerService>(
          create: (context) => McpServerService(
            databaseService: context.read<DatabaseService>(),
            settingsProvider: context.read<SettingsProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'AI Design Inspiration Hub',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}