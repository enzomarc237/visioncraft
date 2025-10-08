import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/mcp_server_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _portController.text = settings.mcpPort.toString();
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final mcpServer = context.read<McpServerService>();

    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Settings'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MCP Server Configuration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('Server Status:'),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: mcpServer.isRunning
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(mcpServer.isRunning ? 'Running' : 'Stopped'),
                      const SizedBox(width: 16),
                      PushButton(
                        controlSize: ControlSize.regular,
                        onPressed: () async {
                          if (mcpServer.isRunning) {
                            await mcpServer.stop();
                            await settingsProvider.setMcpEnabled(false);
                          } else {
                            await mcpServer.start();
                            await settingsProvider.setMcpEnabled(true);
                          }
                          setState(() {});
                        },
                        child: Text(mcpServer.isRunning ? 'Stop Server' : 'Start Server'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('Port:'),
                      ),
                      SizedBox(
                        width: 100,
                        child: MacosTextField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 16),
                      PushButton(
                        controlSize: ControlSize.regular,
                        onPressed: () async {
                          final port = int.tryParse(_portController.text);
                          if (port != null && port > 0 && port < 65536) {
                            await settingsProvider.setMcpPort(port);
                            if (mcpServer.isRunning) {
                              await mcpServer.stop();
                              await mcpServer.start();
                            }
                          }
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'API Keys',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'API keys are used to authenticate AI agents connecting to the MCP server.',
                    style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                  const SizedBox(height: 16),
                  PushButton(
                    controlSize: ControlSize.regular,
                    onPressed: () async {
                      final apiKey = await settingsProvider.generateApiKey();
                      if (mounted) {
                        showMacosAlertDialog(
                          context: context,
                          builder: (context) => MacosAlertDialog(
                            appIcon: const MacosIcon(CupertinoIcons.checkmark_circle),
                            title: const Text('API Key Generated'),
                            message: SelectableText(
                              apiKey,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            primaryButton: PushButton(
                              controlSize: ControlSize.large,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: apiKey));
                                Navigator.of(context).pop();
                              },
                              child: const Text('Copy & Close'),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Generate New API Key'),
                  ),
                  const SizedBox(height: 16),
                  if (settingsProvider.apiKeys.isNotEmpty) ...[
                    const Text(
                      'Active API Keys:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...settingsProvider.apiKeys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  key,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MacosIconButton(
                              icon: const MacosIcon(CupertinoIcons.doc_on_clipboard),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: key));
                              },
                            ),
                            MacosIconButton(
                              icon: const MacosIcon(CupertinoIcons.trash),
                              onPressed: () async {
                                final confirmed = await showMacosAlertDialog<bool>(
                                  context: context,
                                  builder: (context) => MacosAlertDialog(
                                    appIcon: const MacosIcon(CupertinoIcons.exclamationmark_triangle),
                                    title: const Text('Delete API Key'),
                                    message: const Text('Are you sure you want to delete this API key? AI agents using this key will no longer be able to connect.'),
                                    primaryButton: PushButton(
                                      controlSize: ControlSize.large,
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                    secondaryButton: PushButton(
                                      controlSize: ControlSize.large,
                                      secondary: true,
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                );
                                if (confirmed == true) {
                                  await settingsProvider.removeApiKey(key);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}