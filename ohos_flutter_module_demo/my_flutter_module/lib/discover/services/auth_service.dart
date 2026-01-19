import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'native_bridge_service.dart';

/// 认证服务
/// 管理用户登录状态，与宿主App通信
class AuthService {
  static const MethodChannel _channel = MethodChannel('com.example.my_flutter_module2/auth');
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _tokenKey = 'token';
  
  // 使用NativeBridgeService进行原生通信
  static final NativeBridgeService _nativeBridge = NativeBridgeService();

  /// 检查是否已登录
  /// 优先从原生端获取登录状态，如果原生端未实现，则从本地存储读取
  static Future<bool> isLoggedIn() async {
    try {
      // 优先从原生端检查登录状态
      final nativeStatus = await _nativeBridge.checkLoginStatus();
      if (nativeStatus) {
        return true;
      }
      
      // 如果原生端返回false，再从本地存储读取（用于兼容）
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      // 如果有token，验证token是否有效
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        // TODO: 可以在这里验证token是否过期
        return isLoggedIn;
      }
      
      return false;
    } catch (e) {
      // 如果原生端方法调用失败，降级到本地存储
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_isLoggedInKey) ?? false;
      } catch (e2) {
        return false;
      }
    }
  }

  /// 设置登录状态
  static Future<void> setLoggedIn(bool isLoggedIn, {String? userId, String? token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
      
      if (userId != null) {
        await prefs.setString(_userIdKey, userId);
      }
      
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
      
      if (!isLoggedIn) {
        // 登出时清除用户信息
        await prefs.remove(_userIdKey);
        await prefs.remove(_tokenKey);
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 获取用户ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// 获取Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// 跳转到宿主App原生登录页面
  /// 返回登录结果（true表示登录成功，false表示取消登录）
  static Future<bool> navigateToNativeLogin() async {
    try {
      // 优先使用NativeBridgeService
      final result = await _nativeBridge.navigateToLogin();
      if (result) {
        // 登录成功，同步更新本地状态
        await setLoggedIn(true);
        return true;
      }
      return false;
    } catch (e) {
      // 如果NativeBridgeService失败，尝试使用旧的MethodChannel（兼容性）
      try {
        final result = await _channel.invokeMethod<bool>('navigateToLogin');
        if (result == true) {
          await setLoggedIn(true);
        }
        return result ?? false;
      } catch (e2) {
        // 如果宿主App没有实现该方法，返回false
        return false;
      }
    }
  }

  /// 登出
  static Future<void> logout() async {
    await setLoggedIn(false);
  }
}
