import '../dao/category_dao.dart';
import '../../models/category.dart';

class CategoryRepository {
  final CategoryDao _dao = CategoryDao();

  Future<void> createIfMissing(CategoryModel category) => _dao.insert(category);
  Future<List<CategoryModel>> listAll() => _dao.listAll();
}
