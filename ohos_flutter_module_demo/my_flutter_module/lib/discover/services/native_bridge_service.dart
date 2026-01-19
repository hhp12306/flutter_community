import 'package:flutter/services.dart';
import 'dart:convert';

/// Flutter与原生宿主APP通信服务
/// 统一管理所有与原生端的交互
class NativeBridgeService {
  // MethodChannel 名称，用于Flutter调用原生方法
  static const MethodChannel _methodChannel = MethodChannel('com.example.my_flutter_module2/native');
  
  // EventChannel 名称，用于原生向Flutter发送事件
  static const EventChannel _eventChannel = EventChannel('com.example.my_flutter_module2/native_events');
  
  // 单例模式
  static final NativeBridgeService _instance = NativeBridgeService._internal();
  factory NativeBridgeService() => _instance;
  NativeBridgeService._internal();

  // 事件监听流
  Stream<dynamic>? _eventStream;

  /// 获取事件监听流
  Stream<dynamic> get eventStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream();
    return _eventStream!;
  }

  /// ========== 认证相关 ==========
  
  /// 检查登录状态
  /// 返回true表示已登录，false表示未登录
  Future<bool> checkLoginStatus() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('checkLoginStatus');
      return result ?? false;
    } catch (e) {
      print('检查登录状态失败: $e');
      return false;
    }
  }

  /// 跳转到原生登录页面
  /// 返回true表示登录成功，false表示取消登录
  Future<bool> navigateToLogin() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('navigateToLogin');
      return result ?? false;
    } catch (e) {
      print('跳转登录页失败: $e');
      return false;
    }
  }

  /// 获取用户信息
  /// 返回用户信息Map，未登录返回null
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>('getUserInfo');
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _methodChannel.invokeMethod('logout');
    } catch (e) {
      print('登出失败: $e');
    }
  }

  /// ========== 页面跳转相关 ==========
  
  /// 跳转到原生页面
  /// [pageName] 页面名称（如：'profile', 'message', 'setting'等）
  /// [params] 页面参数
  Future<bool> navigateToNativePage(String pageName, {Map<String, dynamic>? params}) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'navigateToNativePage',
        {
          'pageName': pageName,
          'params': params ?? {},
        },
      );
      return result ?? false;
    } catch (e) {
      print('跳转原生页面失败: $e');
      return false;
    }
  }

  /// 使用原生WebView打开H5页面
  /// [url] H5页面URL
  /// [title] 页面标题（可选）
  /// [params] 额外参数
  Future<bool> openNativeWebView(String url, {String? title, Map<String, dynamic>? params}) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'openNativeWebView',
        {
          'url': url,
          'title': title,
          'params': params ?? {},
        },
      );
      return result ?? false;
    } catch (e) {
      print('打开原生WebView失败: $e');
      return false;
    }
  }

  /// ========== 数据共享相关 ==========
  
  /// 获取共享数据
  /// [key] 数据key
  Future<dynamic> getSharedData(String key) async {
    try {
      final result = await _methodChannel.invokeMethod('getSharedData', {'key': key});
      return result;
    } catch (e) {
      print('获取共享数据失败: $e');
      return null;
    }
  }

  /// 设置共享数据
  /// [key] 数据key
  /// [value] 数据值（支持String、int、bool、double、Map、List）
  Future<bool> setSharedData(String key, dynamic value) async {
    try {
      // 将value转换为可序列化的格式
      dynamic serializableValue = value;
      if (value is Map || value is List) {
        serializableValue = jsonEncode(value);
      }
      
      final result = await _methodChannel.invokeMethod<bool>(
        'setSharedData',
        {
          'key': key,
          'value': serializableValue,
        },
      );
      return result ?? false;
    } catch (e) {
      print('设置共享数据失败: $e');
      return false;
    }
  }

  /// ========== UI相关 ==========
  
  /// 显示原生Toast
  /// [message] Toast消息
  /// [duration] 显示时长（'short'或'long'）
  Future<void> showToast(String message, {String duration = 'short'}) async {
    try {
      await _methodChannel.invokeMethod('showToast', {
        'message': message,
        'duration': duration,
      });
    } catch (e) {
      print('显示Toast失败: $e');
    }
  }

  /// 显示原生Loading
  /// [message] Loading提示文本
  Future<void> showLoading({String? message}) async {
    try {
      await _methodChannel.invokeMethod('showLoading', {
        'message': message ?? '加载中...',
      });
    } catch (e) {
      print('显示Loading失败: $e');
    }
  }

  /// 隐藏原生Loading
  Future<void> hideLoading() async {
    try {
      await _methodChannel.invokeMethod('hideLoading');
    } catch (e) {
      print('隐藏Loading失败: $e');
    }
  }

  /// ========== 系统功能相关 ==========
  
  /// 获取系统信息
  Future<Map<String, dynamic>?> getSystemInfo() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>('getSystemInfo');
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('获取系统信息失败: $e');
      return null;
    }
  }

  /// 请求权限
  /// [permission] 权限名称（如：'camera', 'location', 'storage'等）
  Future<bool> requestPermission(String permission) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'requestPermission',
        {'permission': permission},
      );
      return result ?? false;
    } catch (e) {
      print('请求权限失败: $e');
      return false;
    }
  }
}
