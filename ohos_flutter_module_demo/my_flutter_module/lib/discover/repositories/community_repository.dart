import '../../core/repository/base_repository.dart';
import '../../core/result/result.dart';
import '../services/community_service.dart';

/// 社区 Repository
/// 封装 Service 调用，处理数据转换和错误处理
class CommunityRepository extends BaseRepository {
  final CommunityService _service = CommunityService();

  /// 获取精选帖子
  Future<Result<List<Map<String, dynamic>>>> getFeaturedPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _service.getFeaturedPosts(page: page, pageSize: pageSize);
  }

  /// 获取最新帖子
  Future<Result<List<Map<String, dynamic>>>> getLatestPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _service.getLatestPosts(page: page, pageSize: pageSize);
  }

  /// 获取关注帖子
  Future<Result<List<Map<String, dynamic>>>> getFollowingPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _service.getFollowingPosts(page: page, pageSize: pageSize);
  }
}
