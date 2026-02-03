import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/result/result.dart';

/// 社区服务
/// 纯网络请求层，返回 Result 类型
class CommunityService {
  final Dio _dio = ApiClient.instance;

  /// 获取精选帖子
  Future<Result<List<Map<String, dynamic>>>> getFeaturedPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/community/featured',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Success(data.cast<Map<String, dynamic>>());
      }
      
      return Failure(
        message: '获取精选帖子失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      return _handleError(e, '获取精选帖子失败');
    }
  }

  /// 获取最新帖子
  Future<Result<List<Map<String, dynamic>>>> getLatestPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/community/latest',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Success(data.cast<Map<String, dynamic>>());
      }
      
      return Failure(
        message: '获取最新帖子失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      return _handleError(e, '获取最新帖子失败');
    }
  }

  /// 获取关注帖子
  Future<Result<List<Map<String, dynamic>>>> getFollowingPosts({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/community/following',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Success(data.cast<Map<String, dynamic>>());
      }
      
      return Failure(
        message: '获取关注帖子失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      return _handleError(e, '获取关注帖子失败');
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
