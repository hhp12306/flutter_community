import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'discover/config/app_routes.dart';
import 'discover/config/app_pages.dart';
import 'discover/controllers/i18n_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化i18n
  final i18nController = I18nController();
  await i18nController.init();
  
  // 注册全局控制器
  Get.put(i18nController, permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final i18nController = Get.find<I18nController>();
    
    // 从原生传递的参数中获取 Tab 栏高度（可选）
    // 如果原生已处理，这里不需要再处理
    final tabBarHeight = Get.parameters['tabBarHeight'];
    final bottomPadding = tabBarHeight != null ? double.tryParse(tabBarHeight) ?? 0.0 : 0.0;
    
    return GetMaterialApp(
      title: i18nController.get('app.name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 如果原生已处理底部 Tab 栏高度，这里不需要 SafeArea
      // 如果需要在 Flutter 端也处理，可以取消注释下面的 builder
      // builder: (context, child) {
      //   return SafeArea(
      //     bottom: false, // 原生已处理，Flutter 不需要再处理
      //     child: child ?? const SizedBox(),
      //   );
      // },
      initialRoute: AppRoutes.discover,
      getPages: AppPages.routes,
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
