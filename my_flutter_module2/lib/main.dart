import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_routes.dart';
import 'config/app_pages.dart';
import 'controllers/i18n_controller.dart';

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
    
    return GetMaterialApp(
      title: i18nController.get('app.name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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
