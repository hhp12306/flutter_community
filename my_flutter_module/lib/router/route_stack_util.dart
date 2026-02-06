import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_pages.dart';

/// 路由栈信息（单条）
class RouteStackItem {
  final String name;
  final Object? arguments;

  const RouteStackItem({required this.name, this.arguments});

  @override
  String toString() => 'RouteStackItem($name, $arguments)';
}

/// 监听导航栈，用于获取当前栈内所有路由
class RouteStackObserver extends NavigatorObserver {
  RouteStackObserver._();
  static final RouteStackObserver instance = RouteStackObserver._();

  final List<Route<dynamic>> _stack = [];

  /// 当前栈内所有 Route（从底到顶）
  List<Route<dynamic>> get stack => List.unmodifiable(_stack);

  /// 当前栈内所有路由名称（从底到顶）
  List<String> get routeNames =>
      _stack
          .map((r) => r.settings.name)
          .whereType<String>()
          .toList();

  /// 当前栈内所有路由信息（名称 + arguments）
  List<RouteStackItem> get routeItems => _stack.map((r) {
    final name = r.settings.name ?? 'unknown';
    return RouteStackItem(name: name, arguments: r.settings.arguments);
  }).toList();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_stack.isNotEmpty && _stack.last == route) {
      _stack.removeLast();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null && newRoute != null) {
      final i = _stack.indexOf(oldRoute);
      if (i >= 0) {
        _stack[i] = newRoute;
      }
    }
  }
}

/// 路由栈工具方法
class RouteStackUtil {
  RouteStackUtil._();

  /// 当前栈内所有路由名称（需已在 GetMaterialApp 中注册 navigatorObservers: [RouteStackObserver.instance]）
  static List<String> get currentRouteNames => RouteStackObserver.instance.routeNames;

  /// 当前栈内所有路由信息（name + arguments）
  static List<RouteStackItem> get currentRouteItems => RouteStackObserver.instance.routeItems;

  /// 当前栈深度
  static int get stackLength => RouteStackObserver.instance.stack.length;

  /// GetX 当前路由名（仅当前页）
  static String get currentRoute => Get.currentRoute;

  /// 已注册的路由配置
  static List<GetPage> get registeredRoutes => AppPages.routes;

  /// 已注册的路由名称列表
  static List<String> get registeredRouteNames =>
      AppPages.routes.map((p) => p.name).toList();
}
