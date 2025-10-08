class TagModel {
  final String id;
  final String name;

  const TagModel({
    required this.id,
    required this.name,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
      };

  static TagModel fromMap(Map<String, Object?> map) {
    return TagModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
