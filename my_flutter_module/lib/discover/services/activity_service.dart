import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/result/result.dart';
import '../models/activity_model.dart';

/// 活动服务
/// 纯网络请求层，返回 Result 类型
class ActivityService {
  final Dio _dio = ApiClient.instance;

  /// 获取活动列表
  Future<Result<List<ActivityModel>>> getActivities({
    String? cityId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/activities',
        queryParameters: {
          if (cityId != null) 'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final activities = data
            .map((json) => ActivityModel.fromJson(json))
            .toList();
        return Success(activities);
      }
      
      return Failure(
        message: '获取活动列表失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      return handleError(e, defaultMessage: '获取活动列表失败');
    }
  }
  
  /// 处理错误
  Result<T> handleError<T>(dynamic error, {String? defaultMessage}) {
    String message = defaultMessage ?? '操作失败';
    
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
    } else if (error is String) {
      message = error;
    }
    
    return Failure<T>(
      message: message,
      error: error,
    );
  }
}
