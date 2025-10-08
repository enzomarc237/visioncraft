import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../../models/design_specification.dart';
import '../../data/repositories/design_spec_repository.dart';

class AnalysisEngineStub {
  final DesignSpecRepository _specRepo = DesignSpecRepository();
  final _uuid = const Uuid();

  Future<DesignSpecificationModel> analyzeAndSave(String screenshotId, Uint8List bytes) async {
    final palette = _extractDominantColors(bytes, count: 5);
    final spec = DesignSpecificationModel(
      id: _uuid.v4(),
      screenshotId: screenshotId,
      colorPalette: palette
          .map((c) => {
                'hex': _toHex(c),
                'role': 'palette',
              })
          .toList(),
      layoutStructure: {
        'description': 'Basic layout inference not yet implemented',
      },
      analysisTimestampIso: DateTime.now().toUtc().toIso8601String(),
      analysisEngineVersion: 'stub-0.1',
    );
    await _specRepo.upsert(spec);
    return spec;
  }

  List<img.ColorRgb8> _extractDominantColors(Uint8List bytes, {int count = 5}) {
    final image = img.decodeImage(bytes);
    if (image == null) return [];
    final reduced = img.quantize(image, numberOfColors: count);
    final unique = <int, int>{};
    for (final pixel in reduced) {
      final key = (pixel.r << 16) | (pixel.g << 8) | pixel.b;
      unique.update(key, (v) => v + 1, ifAbsent: () => 1);
    }
    final sorted = unique.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(count).map((e) => e.key).toList();
    return top
        .map((rgb) => img.ColorRgb8(((rgb >> 16) & 0xFF), ((rgb >> 8) & 0xFF), (rgb & 0xFF)))
        .toList();
  }

  String _toHex(img.ColorRgb8 c) {
    String two(int v) => v.toRadixString(16).padLeft(2, '0');
    return '#${two(c.r)}${two(c.g)}${two(c.b)}'.toUpperCase();
  }
}
