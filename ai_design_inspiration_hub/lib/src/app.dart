import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'ui/shell/macos_shell.dart';

class AiDesignInspirationHubApp extends StatelessWidget {
  const AiDesignInspirationHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MacosApp(
      title: 'AI Design Inspiration Hub',
      home: MacosShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

