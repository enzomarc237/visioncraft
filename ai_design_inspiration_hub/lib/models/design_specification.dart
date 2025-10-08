class DesignSpecificationModel {
  final String id;
  final String screenshotId;
  final Map<String, Object?>? layoutStructure;
  final List<Map<String, Object?>>? uiComponents;
  final List<Map<String, Object?>>? colorPalette;
  final List<Map<String, Object?>>? typography;
  final Map<String, Object?>? generalDesignInfo;
  final String? analysisTimestampIso;
  final String? analysisEngineVersion;

  const DesignSpecificationModel({
    required this.id,
    required this.screenshotId,
    this.layoutStructure,
    this.uiComponents,
    this.colorPalette,
    this.typography,
    this.generalDesignInfo,
    this.analysisTimestampIso,
    this.analysisEngineVersion,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'screenshot_id': screenshotId,
        'layout_structure': layoutStructure == null ? null : _encode(layoutStructure!),
        'ui_components': uiComponents == null ? null : _encode(uiComponents!),
        'color_palette': colorPalette == null ? null : _encode(colorPalette!),
        'typography': typography == null ? null : _encode(typography!),
        'general_design_info': generalDesignInfo == null ? null : _encode(generalDesignInfo!),
        'analysis_timestamp': analysisTimestampIso,
        'analysis_engine_version': analysisEngineVersion,
      };

  static DesignSpecificationModel fromMap(Map<String, Object?> map) {
    return DesignSpecificationModel(
      id: map['id'] as String,
      screenshotId: map['screenshot_id'] as String,
      layoutStructure: _maybeDecodeMap(map['layout_structure'] as String?),
      uiComponents: _maybeDecodeList(map['ui_components'] as String?),
      colorPalette: _maybeDecodeList(map['color_palette'] as String?),
      typography: _maybeDecodeList(map['typography'] as String?),
      generalDesignInfo: _maybeDecodeMap(map['general_design_info'] as String?),
      analysisTimestampIso: map['analysis_timestamp'] as String?,
      analysisEngineVersion: map['analysis_engine_version'] as String?,
    );
  }

  static String _encode(Object value) => _Json.encode(value);
  static Map<String, Object?>? _maybeDecodeMap(String? json) => json == null ? null : (_Json.decode(json) as Map).cast<String, Object?>();
  static List<Map<String, Object?>>? _maybeDecodeList(String? json) => json == null ? null : List<Map<String, Object?>>.from((_Json.decode(json) as List).map((e) => (e as Map).cast<String, Object?>()));
}

// Lightweight JSON helpers to avoid importing dart:convert in many files.
class _Json {
  static String encode(Object? value) => _encoder.convert(value);
  static Object decode(String source) => _decoder.convert(source);
}

const _encoder = JsonEncoder();
const _decoder = JsonDecoder();

// Minimal copies to avoid an explicit import at call sites. If desired, replace with dart:convert.
class JsonEncoder {
  const JsonEncoder();
  String convert(Object? value) => _jsonEncode(value);
}

class JsonDecoder {
  const JsonDecoder();
  Object convert(String source) => _jsonDecode(source);
}

// Implemented via dart:convert but inlined to keep this file standalone.
// In real app, prefer: import 'dart:convert'; then jsonEncode/jsonDecode.
Object _jsonDecode(String source) => _realJsonDecode(source);
String _jsonEncode(Object? value) => _realJsonEncode(value);

// Deferred actual functions from dart:convert to keep file clear; re-export below.
import 'dart:convert' as _dart_convert show jsonDecode, jsonEncode;
Object _realJsonDecode(String source) => _dart_convert.jsonDecode(source);
String _realJsonEncode(Object? value) => _dart_convert.jsonEncode(value);
