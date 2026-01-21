import 'package:get/get.dart';
import '../views/discover/discover_page.dart';
import '../views/post/post_page.dart';
import '../views/video/video_player_page.dart';
import '../controllers/discover_controller.dart';
import '../utils/route_guard.dart';
import 'app_routes.dart';

/// GetX 路由配置
class AppPages {
  static final List<GetPage> routes = [
    // 发现主页
    GetPage(
      name: AppRoutes.discover,
      page: () => const DiscoverPage(),
      // 支持通过参数指定初始Tab
      binding: BindingsBuilder(() {
        Get.put(DiscoverController(), tag: 'discover');
      }),
    ),
    
    // 推荐Tab
    GetPage(
      name: AppRoutes.recommend,
      page: () => const DiscoverPage(initialTabId: 'recommend'),
    ),
    
    // 社区Tab
    GetPage(
      name: AppRoutes.community,
      page: () => const DiscoverPage(initialTabId: 'community'),
    ),
    
    // 俱乐部Tab
    GetPage(
      name: AppRoutes.club,
      page: () => const DiscoverPage(initialTabId: 'club'),
    ),
    
    // 智驾Tab
    GetPage(
      name: AppRoutes.smartDrive,
      page: () => const DiscoverPage(initialTabId: 'smart-drive'),
    ),
    
    // 活动Tab
    GetPage(
      name: AppRoutes.activity,
      page: () => const DiscoverPage(initialTabId: 'activity'),
    ),
    
    // 资讯Tab
    GetPage(
      name: AppRoutes.news,
      page: () => const DiscoverPage(initialTabId: 'news'),
    ),
    
    // 圈子Tab
    GetPage(
      name: AppRoutes.circle,
      page: () => const DiscoverPage(initialTabId: 'circle'),
    ),
    
    // 直播Tab
    GetPage(
      name: AppRoutes.live,
      page: () => const DiscoverPage(initialTabId: 'live'),
    ),
    
    // 口碑Tab
    GetPage(
      name: AppRoutes.reputation,
      page: () => const DiscoverPage(initialTabId: 'reputation'),
    ),
    
    // 发帖页面
    GetPage(
      name: AppRoutes.post,
      page: () => const PostPage(),
      middlewares: [RouteGuardMiddleware()], // 路由守卫
    ),
    
    // 视频播放页
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () {
        final url = Get.parameters['url'] ?? Get.arguments?['url'] ?? '';
        final title = Get.parameters['title'] ?? Get.arguments?['title'];
        final listParam = Get.parameters['list'] ?? Get.arguments?['list'];
        
        List<String>? videoList;
        if (listParam != null) {
          if (listParam is List) {
            videoList = listParam.cast<String>();
          } else if (listParam is String) {
            videoList = listParam.split(',');
          }
        }
        
        return VideoPlayerPage(
          videoUrl: url,
          videoTitle: title,
          videoList: videoList,
        );
      },
    ),
  ];
}

/// 路由守卫中间件
class RouteGuardMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    // 检查是否需要登录
    if (page != null && RouteGuard.isLoginRequired(page.name)) {
      // 异步检查登录状态（这里简化处理，实际应该在页面内部检查）
      // GetX 的中间件是同步的，所以登录检查在页面内部进行
      return page; // 允许访问，登录检查在页面内部
    }
    return page;
  }
}
