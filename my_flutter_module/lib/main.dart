import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'router/app_routes.dart';
import 'router/app_pages.dart';
import 'router/route_stack_util.dart';
import 'discover/viewmodels/i18n_viewmodel.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据 args 解析初始路由：支持 tabId（如 community）或完整路径（如 /discover/community）
  final initialRoute = _resolveInitialRoute(args);
  
  // 初始化i18n
  final i18nViewModel = I18nViewModel();
  await i18nViewModel.initialize();
  
  Get.put(i18nViewModel, permanent: true);
  
  runApp(MyApp(initialRoute: initialRoute));
}

/// 根据 main 参数或 Web URL 解析入口路由，无参、/ 或无效时返回发现页
String _resolveInitialRoute(List<String> args) {
  if (args.isEmpty) return AppRoutes.discover;
  final first = args[0].trim().toLowerCase();
  if (first.isEmpty || first == '/') return AppRoutes.discover;
  final byTabId = AppRoutes.getRouteByTabId(first);
  if (byTabId != null) return byTabId;
  if (first.startsWith('/') && first.length > 1) return args[0].trim();
  return AppRoutes.discover;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final i18nViewModel = Get.find<I18nViewModel>();
    
    final route = initialRoute == '/' ? AppRoutes.discover : initialRoute;
    return GetMaterialApp(
      title: i18nViewModel.get('app.name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: route,
      getPages: AppPages.routes,
      navigatorObservers: [RouteStackObserver.instance],
      // 未知路由处理
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => Scaffold(
          body: Center(
            child: Text('页面未找到: ${Get.currentRoute}'),
          ),
        ),
      ),
    );
  }
}
