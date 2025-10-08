import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../models/screenshot.dart';
import '../models/design_specification.dart';
import '../providers/screenshot_provider.dart';

class ScreenshotDetailScreen extends StatefulWidget {
  final String screenshotId;

  const ScreenshotDetailScreen({super.key, required this.screenshotId});

  @override
  State<ScreenshotDetailScreen> createState() => _ScreenshotDetailScreenState();
}

class _ScreenshotDetailScreenState extends State<ScreenshotDetailScreen> {
  Screenshot? _screenshot;
  DesignSpecification? _designSpec;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<ScreenshotProvider>();
    final screenshot = await provider.getScreenshotById(widget.screenshotId);
    final designSpec = await provider.getDesignSpecification(widget.screenshotId);

    setState(() {
      _screenshot = screenshot;
      _designSpec = designSpec;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        leading: MacosBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_screenshot?.title ?? 'Screenshot Details'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            if (_isLoading) {
              return const Center(child: ProgressCircle());
            }

            if (_screenshot == null) {
              return const Center(child: Text('Screenshot not found'));
            }

            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildMetadataSection(),
                  if (_designSpec != null) ...[
                    const SizedBox(height: 24),
                    _buildDesignSpecsSection(),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_screenshot!.imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metadata',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Title', _screenshot!.title ?? 'Untitled'),
        _buildInfoRow('Description', _screenshot!.description ?? 'No description'),
        _buildInfoRow('Created', _screenshot!.creationDate.toString()),
        _buildInfoRow('Uploaded', _screenshot!.uploadTimestamp.toString()),
        if (_screenshot!.sourceUrl != null)
          _buildInfoRow('Source', _screenshot!.sourceUrl!),
        if (_screenshot!.tags.isNotEmpty)
          _buildInfoRow('Tags', _screenshot!.tags.join(', ')),
        if (_screenshot!.categories.isNotEmpty)
          _buildInfoRow('Categories', _screenshot!.categories.join(', ')),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignSpecsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Design Specifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_designSpec!.colorPalette.isNotEmpty) ...[
          const Text(
            'Color Palette',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _designSpec!.colorPalette.map((color) {
              return _buildColorChip(color);
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_designSpec!.layoutStructure != null) ...[
          const Text(
            'Layout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Type: ${_designSpec!.layoutStructure!.type}'),
          if (_designSpec!.layoutStructure!.description != null)
            Text('Description: ${_designSpec!.layoutStructure!.description}'),
          const SizedBox(height: 16),
        ],
        if (_designSpec!.uiComponents.isNotEmpty) ...[
          const Text(
            'UI Components',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('${_designSpec!.uiComponents.length} components detected'),
          const SizedBox(height: 16),
        ],
        Text(
          'Analyzed: ${_designSpec!.analysisTimestamp}',
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(ColorInfo color) {
    final colorValue = _parseHexColor(color.hex);
    return Tooltip(
      message: '${color.hex}${color.role != null ? " (${color.role})" : ""}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colorValue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.systemGrey5, width: 2),
        ),
        child: Center(
          child: Text(
            color.hex,
            style: TextStyle(
              fontSize: 9,
              color: _getContrastColor(colorValue),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color _getContrastColor(Color color) {
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? CupertinoColors.black : CupertinoColors.white;
  }
}