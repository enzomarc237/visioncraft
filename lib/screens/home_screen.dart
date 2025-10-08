import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/screenshot_provider.dart';
import '../providers/settings_provider.dart';
import '../services/mcp_server_service.dart';
import 'screenshot_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/screenshot_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenshotProvider = context.watch<ScreenshotProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final mcpServer = context.read<McpServerService>();

    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: _selectedIndex,
            onChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.photo_on_rectangle),
                label: Text('Screenshots'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Settings'),
              ),
            ],
          );
        },
        bottom: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MCP Server',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: mcpServer.isRunning
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mcpServer.isRunning ? 'Running' : 'Stopped',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildScreenshotsView(screenshotProvider),
          const SettingsScreen(),
        ],
      ),
    );
  }

  Widget _buildScreenshotsView(ScreenshotProvider provider) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('AI Design Inspiration Hub'),
        titleWidth: 250,
        actions: [
          ToolBarIconButton(
            label: 'Upload',
            icon: const MacosIcon(CupertinoIcons.plus),
            onPressed: () => _showUploadDialog(context),
            showLabel: true,
          ),
          ToolBarIconButton(
            label: 'Export',
            icon: const MacosIcon(CupertinoIcons.arrow_down_doc),
            onPressed: () => _handleExport(context),
            showLabel: true,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MacosSearchField(
                    controller: _searchController,
                    placeholder: 'Search screenshots...',
                    onChanged: (value) {
                      provider.setSearchQuery(value.isEmpty ? null : value);
                    },
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: ProgressCircle())
                      : provider.screenshots.isEmpty
                          ? _buildEmptyState()
                          : ScreenshotGrid(
                              screenshots: provider.screenshots,
                              onTap: (screenshot) {
                                _navigateToDetail(context, screenshot.id);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MacosIcon(
            CupertinoIcons.photo_on_rectangle,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No screenshots yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Upload your first design screenshot to get started'),
          const SizedBox(height: 16),
          PushButton(
            controlSize: ControlSize.large,
            onPressed: () => _showUploadDialog(context),
            child: const Text('Upload Screenshot'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const UploadDialog(),
    );
  }

  void _navigateToDetail(BuildContext context, String screenshotId) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ScreenshotDetailScreen(screenshotId: screenshotId),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final provider = context.read<ScreenshotProvider>();
    
    if (provider.screenshots.isEmpty) {
      showMacosAlertDialog(
        context: context,
        builder: (context) => MacosAlertDialog(
          appIcon: const MacosIcon(CupertinoIcons.info),
          title: const Text('No Screenshots'),
          message: const Text('There are no screenshots to export.'),
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ),
      );
      return;
    }

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Screenshots',
      fileName: 'design_inspiration_export.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        final exportService = provider.createExportService();
        await exportService.exportAll(result);
        
        if (context.mounted) {
          showMacosAlertDialog(
            context: context,
            builder: (context) => MacosAlertDialog(
              appIcon: const MacosIcon(CupertinoIcons.checkmark_circle),
              title: const Text('Export Successful'),
              message: Text('Exported ${provider.screenshots.length} screenshots to $result'),
              primaryButton: PushButton(
                controlSize: ControlSize.large,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showMacosAlertDialog(
            context: context,
            builder: (context) => MacosAlertDialog(
              appIcon: const MacosIcon(CupertinoIcons.xmark_circle),
              title: const Text('Export Failed'),
              message: Text('Failed to export: $e'),
              primaryButton: PushButton(
                controlSize: ControlSize.large,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ),
          );
        }
      }
    }
  }
}

class UploadDialog extends StatefulWidget {
  const UploadDialog({super.key});

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _categoriesController.dispose();
    _sourceUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(CupertinoIcons.cloud_upload),
      title: const Text('Upload Screenshot'),
      message: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MacosTextField(
              controller: _titleController,
              placeholder: 'Title',
            ),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _descriptionController,
              placeholder: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _tagsController,
              placeholder: 'Tags (comma-separated)',
            ),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _categoriesController,
              placeholder: 'Categories (comma-separated)',
            ),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _sourceUrlController,
              placeholder: 'Source URL (optional)',
            ),
          ],
        ),
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: _isUploading ? null : _handleUpload,
        child: _isUploading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: ProgressCircle(),
              )
            : const Text('Upload'),
      ),
      secondaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);

      try {
        final file = File(result.files.single.path!);
        final provider = context.read<ScreenshotProvider>();

        final tags = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final categories = _categoriesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await provider.uploadScreenshot(
          file,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          tags: tags,
          categories: categories,
          sourceUrl: _sourceUrlController.text.isEmpty ? null : _sourceUrlController.text,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showMacosAlertDialog(
            context: context,
            builder: (context) => MacosAlertDialog(
              appIcon: const MacosIcon(CupertinoIcons.xmark_circle),
              title: const Text('Upload Failed'),
              message: Text('Failed to upload: $e'),
              primaryButton: PushButton(
                controlSize: ControlSize.large,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }
}