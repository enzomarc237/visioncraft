import 'dart:convert';

class ScreenshotEntity {
  final String id;
  final String? title;
  final String? description;
  final String imagePath;
  final DateTime creationDate;
  final String? sourceUrl;
  final DateTime uploadTimestamp;

  const ScreenshotEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.creationDate,
    required this.sourceUrl,
    required this.uploadTimestamp,
  });
}

class TagEntity {
  final String id;
  final String name;
  const TagEntity({required this.id, required this.name});
}

class CategoryEntity {
  final String id;
  final String name;
  final String? parentCategoryId;
  const CategoryEntity({
    required this.id,
    required this.name,
    this.parentCategoryId,
  });
}

class DesignSpecificationEntity {
  final String id;
  final String screenshotId;
  final Map<String, dynamic>? layoutStructure;
  final List<Map<String, dynamic>>? uiComponents;
  final List<Map<String, dynamic>>? colorPalette;
  final List<Map<String, dynamic>>? typography;
  final Map<String, dynamic>? generalDesignInfo;
  final DateTime analysisTimestamp;
  final String? analysisEngineVersion;

  const DesignSpecificationEntity({
    required this.id,
    required this.screenshotId,
    required this.layoutStructure,
    required this.uiComponents,
    required this.colorPalette,
    required this.typography,
    required this.generalDesignInfo,
    required this.analysisTimestamp,
    required this.analysisEngineVersion,
  });

  String? _encode(Map<String, dynamic>? value) =>
      value == null ? null : jsonEncode(value);
  String? _encodeList(List<Map<String, dynamic>>? value) =>
      value == null ? null : jsonEncode(value);
}

