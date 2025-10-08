import '../dao/tag_dao.dart';
import '../../models/tag.dart';

class TagRepository {
  final TagDao _dao = TagDao();

  Future<void> createIfMissing(TagModel tag) => _dao.insert(tag);
  Future<TagModel?> getByName(String name) => _dao.getByName(name);
  Future<List<TagModel>> listAll() => _dao.listAll();
}
