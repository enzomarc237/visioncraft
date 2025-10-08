import '../dao/design_spec_dao.dart';
import '../../models/design_specification.dart';

class DesignSpecRepository {
  final DesignSpecDao _dao = DesignSpecDao();

  Future<void> upsert(DesignSpecificationModel spec) => _dao.upsert(spec);
  Future<DesignSpecificationModel?> getByScreenshotId(String screenshotId) => _dao.getByScreenshotId(screenshotId);
}
