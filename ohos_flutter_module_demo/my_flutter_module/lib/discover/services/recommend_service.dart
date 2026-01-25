import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/result/result.dart';
import '../models/banner_model.dart';
import '../models/diamond_model.dart';
import '../models/article_model.dart';
import '../models/component_model.dart';

/// 推荐页面服务
/// 纯网络请求层，返回 Result 类型
class RecommendService {
  final Dio _dio = ApiClient.instance;

  /// 获取Banner列表
  Future<Result<List<BannerModel>>> getBanners() async {
    try {
      final response = await _dio.get('/api/recommend/banners');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final banners = data.map((json) => BannerModel.fromJson(json)).toList();
        return Success(banners);
      }
      return Failure(message: '获取Banner失败', code: '${response.statusCode}');
    } catch (e) {
      return _handleError(e, '获取Banner失败');
    }
  }

  /// 获取金刚区数据
  Future<Result<List<DiamondModel>>> getDiamonds() async {
    try {
      final response = await _dio.get('/api/recommend/diamonds');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final diamonds = data.map((json) => DiamondModel.fromJson(json)).toList();
        return Success(diamonds);
      }
      return Failure(message: '获取金刚区失败', code: '${response.statusCode}');
    } catch (e) {
      return _handleError(e, '获取金刚区失败');
    }
  }

  /// 获取文章列表
  Future<Result<List<ArticleModel>>> getArticles({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recommend/articles',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final articles = data.map((json) => ArticleModel.fromJson(json)).toList();
        return Success(articles);
      }
      return Failure(message: '获取文章列表失败', code: '${response.statusCode}');
    } catch (e) {
      return _handleError(e, '获取文章列表失败');
    }
  }

  /// 获取功能组件
  Future<Result<List<ComponentModel>>> getComponents() async {
    try {
      final response = await _dio.get('/api/recommend/components');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final components = data.map((json) => ComponentModel.fromJson(json)).toList();
        return Success(components);
      }
      return Failure(message: '获取功能组件失败', code: '${response.statusCode}');
    } catch (e) {
      return _handleError(e, '获取功能组件失败');
    }
  }

  /// 处理错误
  Result<T> _handleError<T>(dynamic error, String defaultMessage) {
    String message = defaultMessage;
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = '网络超时，请检查网络连接';
          break;
        case DioExceptionType.badResponse:
          message = '服务器错误: ${error.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          message = '请求已取消';
          break;
        default:
          message = '网络错误，请稍后重试';
      }
    }
    
    return Failure<T>(
      message: message,
      error: error,
    );
  }
}
