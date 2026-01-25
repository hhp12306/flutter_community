import 'package:dio/dio.dart';
import '../result/result.dart';

/// Repository 基类
/// 提供通用的 Repository 功能
abstract class BaseRepository {
  /// 处理网络错误，转换为 Result
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
