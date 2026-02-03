import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../discover/config/app_config.dart';

/// 统一的网络客户端
/// 提供单例 Dio 实例，统一配置和拦截器
class ApiClient {
  static Dio? _dio;
  
  /// 获取 Dio 实例（单例）
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }
  
  /// 创建 Dio 实例
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // 添加拦截器
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    // 可以添加更多拦截器
    // dio.interceptors.add(AuthInterceptor());
    // dio.interceptors.add(ErrorInterceptor());
    
    return dio;
  }
  
  /// 初始化（可选，用于动态配置）
  static void init({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    final options = instance.options;
    if (baseUrl != null) {
      options.baseUrl = baseUrl;
    }
    if (connectTimeout != null) {
      options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      options.receiveTimeout = receiveTimeout;
    }
  }
  
  /// 重置（用于测试）
  static void reset() {
    _dio = null;
  }
}
