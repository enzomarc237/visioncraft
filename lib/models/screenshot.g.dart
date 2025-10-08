// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screenshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screenshot _$ScreenshotFromJson(Map<String, dynamic> json) => Screenshot(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imagePath: json['image_path'] as String,
      creationDate: DateTime.parse(json['creation_date'] as String),
      sourceUrl: json['source_url'] as String?,
      uploadTimestamp: DateTime.parse(json['upload_timestamp'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ScreenshotToJson(Screenshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_path': instance.imagePath,
      'creation_date': instance.creationDate.toIso8601String(),
      'source_url': instance.sourceUrl,
      'upload_timestamp': instance.uploadTimestamp.toIso8601String(),
      'tags': instance.tags,
      'categories': instance.categories,
    };