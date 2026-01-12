import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../config/app_routes.dart';

/// 路由卫士
/// 拦截需要登录的页面，跳转到宿主App原生登录页
class RouteGuard {
  /// 需要登录的路由列表
  static final Set<String> _loginRequiredRoutes = {
    AppRoutes.post, // 发帖页
    AppRoutes.draft, // 草稿箱
    // 注意：以下路由在特定操作时需要登录，但在访问页面时不需要
    // 这些路由的登录检查在页面内部进行
  };

  /// 需要登录的功能操作（通过参数标识）
  static final Set<String> _loginRequiredActions = {
    'message', // 消息中心
    'follow', // 关注
    'club_home', // 俱乐部首页跳转城市选择
    'activity_home', // 活动首页跳转城市选择
    'reputation_home', // 口碑首页跳转h5详情页
  };

  /// 检查路由是否需要登录
  static bool isLoginRequired(String location) {
    // 检查完整路径
    if (_loginRequiredRoutes.contains(location)) {
      return true;
    }
    
    // 检查路径前缀
    for (final route in _loginRequiredRoutes) {
      if (location.startsWith(route)) {
        return true;
      }
    }
    
    return false;
  }

  /// 检查操作是否需要登录
  static bool isActionLoginRequired(String action) {
    return _loginRequiredActions.contains(action);
  }

  /// 路由守卫拦截器
  /// 在GoRouter的redirect中使用（同步版本，用于简单检查）
  static String? guardSync(BuildContext context, GoRouterState state) {
    // 注意：GoRouter的redirect是同步的，无法在这里进行异步登录检查
    // 实际的登录检查在页面内部或使用中间件进行
    // 这里只做路由路径的简单验证
    return null;
  }

  /// 异步路由守卫拦截器
  /// 在页面跳转前调用
  static Future<String?> guardAsync(String location) async {
    // 检查是否需要登录
    if (isLoginRequired(location)) {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (!isLoggedIn) {
        // 跳转到宿主App原生登录页
        final loginResult = await AuthService.navigateToNativeLogin();
        
        if (loginResult) {
          // 登录成功，继续访问原路由
          return null;
        } else {
          // 取消登录，返回发现页
          return AppRoutes.discover;
        }
      }
    }
    
    // 不需要登录或已登录，允许访问
    return null;
  }

  /// 检查并处理需要登录的操作
  /// 返回true表示已登录或登录成功，false表示取消登录
  static Future<bool> checkLoginForAction(String action) async {
    if (!isActionLoginRequired(action)) {
      return true; // 不需要登录的操作
    }
    
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (!isLoggedIn) {
      // 跳转到宿主App原生登录页
      return await AuthService.navigateToNativeLogin();
    }
    
    return true;
  }
}
