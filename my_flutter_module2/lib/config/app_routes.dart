/// 应用路由配置
/// 支持宿主App通过路由跳转Tab
class AppRoutes {
  // 发现主页（首页）
  static const String discover = '/discover';
  
  // 各个Tab页面路由
  static const String recommend = '/discover/recommend'; // 推荐
  static const String community = '/discover/community'; // 社区
  static const String club = '/discover/club'; // 俱乐部
  static const String smartDrive = '/discover/smart-drive'; // 智驾
  static const String activity = '/discover/activity'; // 活动
  static const String news = '/discover/news'; // 资讯
  static const String circle = '/discover/circle'; // 圈子
  static const String live = '/discover/live'; // 直播
  static const String reputation = '/discover/reputation'; // 口碑
  
  // 功能页面
  static const String post = '/post'; // 发帖页
  static const String videoPlayer = '/video'; // 视频播放页
  static const String draft = '/draft'; // 草稿箱

  /// 根据Tab ID获取路由
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

  /// 根据路由获取Tab索引
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

