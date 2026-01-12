import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'views/discover/discover_page.dart';
import 'views/discover/discover_provider.dart';
import 'views/post/post_page.dart';
import 'views/video/video_player_page.dart';
import 'config/app_routes.dart';
import 'utils/route_guard.dart';
import 'providers/i18n_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化i18n
  final i18nProvider = I18nProvider();
  await i18nProvider.init();
  
  runApp(MyApp(i18nProvider: i18nProvider));
}

class MyApp extends StatelessWidget {
  final I18nProvider i18nProvider;
  
  const MyApp({super.key, required this.i18nProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: i18nProvider),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
      ],
      child: Consumer<I18nProvider>(
        builder: (context, i18n, child) {
          return MaterialApp.router(
            title: i18n.get('app.name'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

/// 路由配置
/// 支持宿主App通过路由跳转Tab
/// 支持路由卫士拦截登录相关页面
final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.discover,
  // 路由守卫：拦截需要登录的页面（同步版本，实际登录检查在页面内部进行）
  redirect: RouteGuard.guardSync,
  routes: [
    // 发现主页
    GoRoute(
      path: AppRoutes.discover,
      builder: (context, state) {
        // 支持通过query参数指定初始Tab
        final tabId = state.uri.queryParameters['tabId'];
        final tabIndex = state.uri.queryParameters['tabIndex'];
        
        int? initialIndex;
        if (tabIndex != null) {
          initialIndex = int.tryParse(tabIndex);
        }
        
        return DiscoverPage(
          initialIndex: initialIndex,
          initialTabId: tabId,
        );
      },
      routes: [
        // 推荐Tab
        GoRoute(
          path: 'recommend',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'recommend',
          ),
        ),
        // 社区Tab
        GoRoute(
          path: 'community',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'community',
          ),
        ),
        // 俱乐部Tab
        GoRoute(
          path: 'club',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'club',
          ),
        ),
        // 智驾Tab
        GoRoute(
          path: 'smart-drive',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'smart-drive',
          ),
        ),
        // 活动Tab
        GoRoute(
          path: 'activity',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'activity',
          ),
        ),
        // 资讯Tab
        GoRoute(
          path: 'news',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'news',
          ),
        ),
        // 圈子Tab
        GoRoute(
          path: 'circle',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'circle',
          ),
        ),
        // 直播Tab
        GoRoute(
          path: 'live',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'live',
          ),
        ),
        // 口碑Tab
        GoRoute(
          path: 'reputation',
          builder: (context, state) => const DiscoverPage(
            initialTabId: 'reputation',
          ),
        ),
      ],
    ),
    
    // 发帖页面
    GoRoute(
      path: AppRoutes.post,
      builder: (context, state) => const PostPage(),
    ),
    
    // 视频播放页
    GoRoute(
      path: AppRoutes.videoPlayer,
      builder: (context, state) {
        final videoUrl = state.uri.queryParameters['url'] ?? '';
        final videoTitle = state.uri.queryParameters['title'];
        final videoListParam = state.uri.queryParameters['list'];
        
        List<String>? videoList;
        if (videoListParam != null) {
          videoList = videoListParam.split(',');
        }
        
        return VideoPlayerPage(
          videoUrl: videoUrl,
          videoTitle: videoTitle,
          videoList: videoList,
        );
      },
    ),
  ],
  
  // 错误处理
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('页面未找到: ${state.uri}'),
    ),
  ),
);
