/// 应用路由常量（GetX 统一路由管理）
/// 支持宿主 App 通过路由跳转 Tab
class AppRoutes {
  AppRoutes._();

  // 发现主页（首页）
  static const String discover = '/discover';

  // 各 Tab 页面路由
  static const String recommend = '/discover/recommend';
  static const String community = '/discover/community';
  static const String club = '/discover/club';
  static const String smartDrive = '/discover/smart-drive';
  static const String activity = '/discover/activity';
  static const String news = '/discover/news';
  static const String circle = '/discover/circle';
  static const String live = '/discover/live';
  static const String reputation = '/discover/reputation';

  // 功能页
  static const String post = '/post';
  static const String videoPlayer = '/video';
  static const String draft = '/draft';
  static const String citySelector = '/city-selector';
  static const String mapPointPicker = '/map-point-picker';

  /// 根据 Tab ID 返回对应路由
  static String? getRouteByTabId(String tabId) {
    switch (tabId) {
      case 'recommend':
        return recommend;
      case 'community':
        return community;
      case 'club':
        return club;
      case 'smart-drive':
        return smartDrive;
      case 'activity':
        return activity;
      case 'news':
        return news;
      case 'circle':
        return circle;
      case 'live':
        return live;
      case 'reputation':
        return reputation;
      default:
        return null;
    }
  }

  /// 根据路由返回 Tab 索引
  static int getTabIndexByRoute(String route) {
    switch (route) {
      case recommend:
        return 0;
      case community:
        return 1;
      case club:
        return 2;
      case smartDrive:
        return 3;
      case activity:
        return 4;
      case news:
        return 5;
      case circle:
        return 6;
      case live:
        return 7;
      case reputation:
        return 8;
      default:
        return 0;
    }
  }
}
