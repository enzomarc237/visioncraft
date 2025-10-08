import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class InspirationHubApp extends StatelessWidget {
  const InspirationHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Design Inspiration Hub',
      theme: MacosThemeData(
        brightness: Brightness.light,
      ),
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({super.key});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      titleBar: const TitleBar(
        title: Text('AI Design Inspiration Hub'),
      ),
      child: MacosScaffold(
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Welcome to AI Design Inspiration Hub'),
                    SizedBox(height: 8),
                    Text('Scaffold placeholder — add screenshots to get started'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
