import 'package:get/get.dart';
import '../discover/views/discover/discover_page.dart';
import '../discover/views/post/post_page.dart';
import '../discover/views/video/video_player_page.dart';
import '../discover/views/common/city_selector_page.dart';
import '../discover/views/common/map_point_picker_page.dart';
import '../discover/viewmodels/discover_viewmodel.dart';
import '../discover/models/city_model.dart';
import '../discover/utils/route_guard.dart';
import 'app_routes.dart';

/// GetX 路由表（统一在 router 中管理）
class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: '/',
      page: () => const DiscoverPage(),
      binding: BindingsBuilder(() {
        Get.put(DiscoverViewModel(), tag: 'discover');
      }),
    ),
    GetPage(
      name: AppRoutes.discover,
      page: () => const DiscoverPage(),
      binding: BindingsBuilder(() {
        Get.put(DiscoverViewModel(), tag: 'discover');
      }),
    ),
    GetPage(
      name: AppRoutes.recommend,
      page: () => const DiscoverPage(initialTabId: 'recommend'),
    ),
    GetPage(
      name: AppRoutes.community,
      page: () => const DiscoverPage(initialTabId: 'community'),
    ),
    GetPage(
      name: AppRoutes.club,
      page: () => const DiscoverPage(initialTabId: 'club'),
    ),
    GetPage(
      name: AppRoutes.smartDrive,
      page: () => const DiscoverPage(initialTabId: 'smart-drive'),
    ),
    GetPage(
      name: AppRoutes.activity,
      page: () => const DiscoverPage(initialTabId: 'activity'),
    ),
    GetPage(
      name: AppRoutes.news,
      page: () => const DiscoverPage(initialTabId: 'news'),
    ),
    GetPage(
      name: AppRoutes.circle,
      page: () => const DiscoverPage(initialTabId: 'circle'),
    ),
    GetPage(
      name: AppRoutes.live,
      page: () => const DiscoverPage(initialTabId: 'live'),
    ),
    GetPage(
      name: AppRoutes.reputation,
      page: () => const DiscoverPage(initialTabId: 'reputation'),
    ),
    GetPage(
      name: AppRoutes.post,
      page: () => const PostPage(),
      middlewares: [RouteGuardMiddleware()],
    ),
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
    GetPage(
      name: AppRoutes.citySelector,
      page: () {
        final currentCity = Get.arguments as CityModel?;
        return CitySelectorPage(currentCity: currentCity);
      },
    ),
    GetPage(
      name: AppRoutes.mapPointPicker,
      page: () => const MapPointPickerPage(),
    ),
  ];
}

/// 路由守卫中间件（需登录等）
class RouteGuardMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null && RouteGuard.isLoginRequired(page.name)) {
      return page;
    }
    return page;
  }
}
