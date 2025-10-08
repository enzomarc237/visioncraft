class CategoryModel {
  final String id;
  final String name;
  final String? parentCategoryId;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentCategoryId,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'parent_category_id': parentCategoryId,
      };

  static CategoryModel fromMap(Map<String, Object?> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      parentCategoryId: map['parent_category_id'] as String?,
    );
  }
}
