import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'discover/config/app_routes.dart';
import 'discover/config/app_pages.dart';
import 'discover/viewmodels/i18n_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化i18n
  final i18nViewModel = I18nViewModel();
  // 新架构：直接调用 initialize() 方法（BaseViewModel 会在 onInit 时自动调用，但这里需要提前初始化）
  await i18nViewModel.initialize();
  
  // 注册全局 ViewModel
  Get.put(i18nViewModel, permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final i18nViewModel = Get.find<I18nViewModel>();
    
    return GetMaterialApp(
      title: i18nViewModel.get('app.name'),
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
