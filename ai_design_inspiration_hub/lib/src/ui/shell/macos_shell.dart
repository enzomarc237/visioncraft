import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosShell extends StatefulWidget {
  const MacosShell({super.key});

  @override
  State<MacosShell> createState() => _MacosShellState();
}

class _MacosShellState extends State<MacosShell> {
  @override
  Widget build(BuildContext context) {
    return const MacosWindow(
      titleBar: TitleBar(
        title: Text('AI Design Inspiration Hub'),
      ),
      child: Center(child: Text('AI Design Inspiration Hub')),
    );
  }
}

