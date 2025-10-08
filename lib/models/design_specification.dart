import 'package:json_annotation/json_annotation.dart';

part 'design_specification.g.dart';

@JsonSerializable()
class DesignSpecification {
  final String id;
  final String screenshotId;
  final LayoutStructure? layoutStructure;
  final List<UiComponent> uiComponents;
  final List<ColorInfo> colorPalette;
  final List<TypographyStyle> typography;
  final Map<String, dynamic>? generalDesignInfo;
  final DateTime analysisTimestamp;
  final String? analysisEngineVersion;

  DesignSpecification({
    required this.id,
    required this.screenshotId,
    this.layoutStructure,
    this.uiComponents = const [],
    this.colorPalette = const [],
    this.typography = const [],
    this.generalDesignInfo,
    required this.analysisTimestamp,
    this.analysisEngineVersion,
  });

  factory DesignSpecification.fromJson(Map<String, dynamic> json) =>
      _$DesignSpecificationFromJson(json);

  Map<String, dynamic> toJson() => _$DesignSpecificationToJson(this);
}

@JsonSerializable()
class LayoutStructure {
  final String type;
  final String? description;
  final Map<String, dynamic>? properties;

  LayoutStructure({
    required this.type,
    this.description,
    this.properties,
  });

  factory LayoutStructure.fromJson(Map<String, dynamic> json) =>
      _$LayoutStructureFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutStructureToJson(this);
}

@JsonSerializable()
class UiComponent {
  final String type;
  final String? label;
  final BoundingBox? boundingBox;
  final Map<String, dynamic>? properties;

  UiComponent({
    required this.type,
    this.label,
    this.boundingBox,
    this.properties,
  });

  factory UiComponent.fromJson(Map<String, dynamic> json) =>
      _$UiComponentFromJson(json);

  Map<String, dynamic> toJson() => _$UiComponentToJson(this);
}

@JsonSerializable()
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);
}

@JsonSerializable()
class ColorInfo {
  final String hex;
  final String? role;
  final String? usageContext;
  final double? proportion;

  ColorInfo({
    required this.hex,
    this.role,
    this.usageContext,
    this.proportion,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) =>
      _$ColorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ColorInfoToJson(this);
}

@JsonSerializable()
class TypographyStyle {
  final String? fontFamily;
  final double? fontSizePx;
  final dynamic fontWeight; // Can be String or int
  final String? fontStyle;
  final double? lineHeightRatio;
  final String? colorHex;
  final String? sampleText;
  final String? context;

  TypographyStyle({
    this.fontFamily,
    this.fontSizePx,
    this.fontWeight,
    this.fontStyle,
    this.lineHeightRatio,
    this.colorHex,
    this.sampleText,
    this.context,
  });

  factory TypographyStyle.fromJson(Map<String, dynamic> json) =>
      _$TypographyStyleFromJson(json);

  Map<String, dynamic> toJson() => _$TypographyStyleToJson(this);
}