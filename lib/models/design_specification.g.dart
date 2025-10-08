// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'design_specification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DesignSpecification _$DesignSpecificationFromJson(Map<String, dynamic> json) =>
    DesignSpecification(
      id: json['id'] as String,
      screenshotId: json['screenshot_id'] as String,
      layoutStructure: json['layout_structure'] == null
          ? null
          : LayoutStructure.fromJson(
              json['layout_structure'] as Map<String, dynamic>),
      uiComponents: (json['ui_components'] as List<dynamic>?)
              ?.map((e) => UiComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      colorPalette: (json['color_palette'] as List<dynamic>?)
              ?.map((e) => ColorInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      typography: (json['typography'] as List<dynamic>?)
              ?.map((e) => TypographyStyle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      generalDesignInfo: json['general_design_info'] as Map<String, dynamic>?,
      analysisTimestamp: DateTime.parse(json['analysis_timestamp'] as String),
      analysisEngineVersion: json['analysis_engine_version'] as String?,
    );

Map<String, dynamic> _$DesignSpecificationToJson(
        DesignSpecification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'screenshot_id': instance.screenshotId,
      'layout_structure': instance.layoutStructure?.toJson(),
      'ui_components': instance.uiComponents.map((e) => e.toJson()).toList(),
      'color_palette': instance.colorPalette.map((e) => e.toJson()).toList(),
      'typography': instance.typography.map((e) => e.toJson()).toList(),
      'general_design_info': instance.generalDesignInfo,
      'analysis_timestamp': instance.analysisTimestamp.toIso8601String(),
      'analysis_engine_version': instance.analysisEngineVersion,
    };

LayoutStructure _$LayoutStructureFromJson(Map<String, dynamic> json) =>
    LayoutStructure(
      type: json['type'] as String,
      description: json['description'] as String?,
      properties: json['properties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LayoutStructureToJson(LayoutStructure instance) =>
    <String, dynamic>{
      'type': instance.type,
      'description': instance.description,
      'properties': instance.properties,
    };

UiComponent _$UiComponentFromJson(Map<String, dynamic> json) => UiComponent(
      type: json['type'] as String,
      label: json['label'] as String?,
      boundingBox: json['bounding_box'] == null
          ? null
          : BoundingBox.fromJson(json['bounding_box'] as Map<String, dynamic>),
      properties: json['properties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UiComponentToJson(UiComponent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'label': instance.label,
      'bounding_box': instance.boundingBox?.toJson(),
      'properties': instance.properties,
    };

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$BoundingBoxToJson(BoundingBox instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

ColorInfo _$ColorInfoFromJson(Map<String, dynamic> json) => ColorInfo(
      hex: json['hex'] as String,
      role: json['role'] as String?,
      usageContext: json['usage_context'] as String?,
      proportion: (json['proportion'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ColorInfoToJson(ColorInfo instance) =>
    <String, dynamic>{
      'hex': instance.hex,
      'role': instance.role,
      'usage_context': instance.usageContext,
      'proportion': instance.proportion,
    };

TypographyStyle _$TypographyStyleFromJson(Map<String, dynamic> json) =>
    TypographyStyle(
      fontFamily: json['font_family'] as String?,
      fontSizePx: (json['font_size_px'] as num?)?.toDouble(),
      fontWeight: json['font_weight'],
      fontStyle: json['font_style'] as String?,
      lineHeightRatio: (json['line_height_ratio'] as num?)?.toDouble(),
      colorHex: json['color_hex'] as String?,
      sampleText: json['sample_text'] as String?,
      context: json['context'] as String?,
    );

Map<String, dynamic> _$TypographyStyleToJson(TypographyStyle instance) =>
    <String, dynamic>{
      'font_family': instance.fontFamily,
      'font_size_px': instance.fontSizePx,
      'font_weight': instance.fontWeight,
      'font_style': instance.fontStyle,
      'line_height_ratio': instance.lineHeightRatio,
      'color_hex': instance.colorHex,
      'sample_text': instance.sampleText,
      'context': instance.context,
    };