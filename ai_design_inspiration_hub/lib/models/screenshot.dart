class ScreenshotModel {
  final String id;
  final String? title;
  final String? description;
  final String imagePath;
  final String? creationDateIso;
  final String? sourceUrl;
  final String uploadTimestampIso;

  const ScreenshotModel({
    required this.id,
    required this.imagePath,
    required this.uploadTimestampIso,
    this.title,
    this.description,
    this.creationDateIso,
    this.sourceUrl,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'image_path': imagePath,
        'creation_date': creationDateIso,
        'source_url': sourceUrl,
        'upload_timestamp': uploadTimestampIso,
      };

  static ScreenshotModel fromMap(Map<String, Object?> map) {
    return ScreenshotModel(
      id: map['id'] as String,
      imagePath: map['image_path'] as String,
      uploadTimestampIso: map['upload_timestamp'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      creationDateIso: map['creation_date'] as String?,
      sourceUrl: map['source_url'] as String?,
    );
  }
}
