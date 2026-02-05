import '../../core/repository/base_repository.dart';
import '../../core/result/result.dart';
import '../models/banner_model.dart';
import '../models/diamond_model.dart';
import '../models/article_model.dart';
import '../models/component_model.dart';
import '../services/recommend_service.dart';

/// 推荐页面 Repository
/// 封装 Service 调用，处理数据转换和错误处理
class RecommendRepository extends BaseRepository {
  final RecommendService _service = RecommendService();

  /// 获取Banner列表
  Future<Result<List<BannerModel>>> getBanners() async {
    return await _service.getBanners();
  }

  /// 获取金刚区数据
  Future<Result<List<DiamondModel>>> getDiamonds() async {
    return await _service.getDiamonds();
  }

  /// 获取文章列表
  Future<Result<List<ArticleModel>>> getArticles({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _service.getArticles(page: page, pageSize: pageSize);
  }

  /// 获取功能组件
  Future<Result<List<ComponentModel>>> getComponents() async {
    return await _service.getComponents();
  }
}
