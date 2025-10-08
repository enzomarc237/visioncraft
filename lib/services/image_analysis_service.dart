import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../models/design_specification.dart';

class ImageAnalysisService {
  static const String engineVersion = '0.1.0';
  final _uuid = const Uuid();

  Future<DesignSpecification> analyzeImage(String imagePath, String screenshotId) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Extract color palette
    final colorPalette = await _extractColorPalette(image);

    // Analyze basic layout
    final layoutStructure = await _analyzeLayout(image);

    // Detect basic UI components (simplified for MVP)
    final uiComponents = await _detectUiComponents(image);

    // Basic typography detection (simplified)
    final typography = await _detectTypography(image);

    // General design info
    final generalDesignInfo = {
      'image_dimensions': {
        'width': image.width,
        'height': image.height,
      },
      'perceived_style': _detectDesignStyle(colorPalette),
    };

    return DesignSpecification(
      id: _uuid.v4(),
      screenshotId: screenshotId,
      layoutStructure: layoutStructure,
      uiComponents: uiComponents,
      colorPalette: colorPalette,
      typography: typography,
      generalDesignInfo: generalDesignInfo,
      analysisTimestamp: DateTime.now(),
      analysisEngineVersion: engineVersion,
    );
  }

  Future<List<ColorInfo>> _extractColorPalette(img.Image image) async {
    // Sample pixels from the image
    final Map<String, int> colorFrequency = {};
    final sampleRate = 10; // Sample every 10th pixel

    for (int y = 0; y < image.height; y += sampleRate) {
      for (int x = 0; x < image.width; x += sampleRate) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Quantize colors to reduce variation
        final quantizedR = (r ~/ 32) * 32;
        final quantizedG = (g ~/ 32) * 32;
        final quantizedB = (b ~/ 32) * 32;
        
        final hex = '#${quantizedR.toRadixString(16).padLeft(2, '0')}'
            '${quantizedG.toRadixString(16).padLeft(2, '0')}'
            '${quantizedB.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
        
        colorFrequency[hex] = (colorFrequency[hex] ?? 0) + 1;
      }
    }

    // Sort by frequency and take top colors
    final sortedColors = colorFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSamples = sortedColors.fold(0, (sum, entry) => sum + entry.value);
    
    final List<ColorInfo> palette = [];
    for (int i = 0; i < min(10, sortedColors.length); i++) {
      final entry = sortedColors[i];
      final proportion = entry.value / totalSamples;
      
      String? role;
      if (i == 0) role = 'dominant';
      else if (i == 1) role = 'secondary';
      else if (i < 5) role = 'accent';
      
      palette.add(ColorInfo(
        hex: entry.key,
        role: role,
        proportion: proportion,
      ));
    }

    return palette;
  }

  Future<LayoutStructure> _analyzeLayout(img.Image image) async {
    final aspectRatio = image.width / image.height;
    
    String layoutType;
    if (aspectRatio > 1.5) {
      layoutType = 'horizontal';
    } else if (aspectRatio < 0.67) {
      layoutType = 'vertical';
    } else {
      layoutType = 'balanced';
    }

    return LayoutStructure(
      type: layoutType,
      description: 'Basic layout analysis based on aspect ratio',
      properties: {
        'aspect_ratio': aspectRatio,
        'width': image.width,
        'height': image.height,
      },
    );
  }

  Future<List<UiComponent>> _detectUiComponents(img.Image image) async {
    // Simplified component detection for MVP
    // In a production version, this would use ML models
    final List<UiComponent> components = [];
    
    // For now, we'll just detect some basic regions based on color clustering
    // This is a placeholder for future ML-based detection
    
    return components;
  }

  Future<List<TypographyStyle>> _detectTypography(img.Image image) async {
    // Simplified typography detection
    // In production, this would use OCR and font recognition
    final List<TypographyStyle> styles = [];
    
    // Basic placeholder - in real implementation would use google_ml_kit for OCR
    
    return styles;
  }

  List<String> _detectDesignStyle(List<ColorInfo> palette) {
    final styles = <String>[];
    
    // Check if colors are mostly monochrome
    final colorVariety = palette.length;
    if (colorVariety <= 3) {
      styles.add('minimalist');
    }

    // Check for bright colors
    bool hasBrightColors = false;
    for (final color in palette) {
      if (color.hex.contains(RegExp(r'[CDEF][CDEF]'))) {
        hasBrightColors = true;
        break;
      }
    }
    
    if (hasBrightColors) {
      styles.add('vibrant');
    } else {
      styles.add('muted');
    }

    return styles;
  }

  Future<File> generateThumbnail(String imagePath, String thumbnailPath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image for thumbnail');
    }

    // Resize to thumbnail (max 300px width/height, maintain aspect ratio)
    final thumbnail = img.copyResize(
      image,
      width: min(300, image.width),
      height: min(300, image.height),
      interpolation: img.Interpolation.average,
    );

    // Save thumbnail
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(img.encodePng(thumbnail));

    return thumbnailFile;
  }
}