import 'package:json_annotation/json_annotation.dart';

part 'screenshot.g.dart';

@JsonSerializable()
class Screenshot {
  final String id;
  final String? title;
  final String? description;
  final String imagePath;
  final DateTime creationDate;
  final String? sourceUrl;
  final DateTime uploadTimestamp;
  final List<String> tags;
  final List<String> categories;

  Screenshot({
    required this.id,
    this.title,
    this.description,
    required this.imagePath,
    required this.creationDate,
    this.sourceUrl,
    required this.uploadTimestamp,
    this.tags = const [],
    this.categories = const [],
  });

  factory Screenshot.fromJson(Map<String, dynamic> json) =>
      _$ScreenshotFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenshotToJson(this);

  Screenshot copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    DateTime? creationDate,
    String? sourceUrl,
    DateTime? uploadTimestamp,
    List<String>? tags,
    List<String>? categories,
  }) {
    return Screenshot(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      creationDate: creationDate ?? this.creationDate,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      uploadTimestamp: uploadTimestamp ?? this.uploadTimestamp,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
    );
  }
}