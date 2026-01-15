# 解决 Flutter 页面遮挡原生 Tab 栏的问题

## 问题描述

当 Flutter 模块嵌入到原生鸿蒙应用时，如果原生应用有底部 Tab 栏，Flutter 页面的高度会遮住 Tab 栏。

## 解决方案

有两种方案：
1. **原生端调整**：在原生容器中为 Flutter 预留 Tab 栏高度（推荐）
2. **Flutter 端调整**：在 Flutter 页面底部添加安全区域

---

## 方案一：原生端调整（推荐）

### 1.1 修改 Flutter 容器页面

在原生项目中，修改 `FlutterContainerPage.ets`：

```typescript
import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  @State route: string = '/discover';
  @State params: Record<string, string> = {};
  
  // Tab 栏高度（根据实际情况调整，单位：vp）
  private tabBarHeight: number = 56; // 默认 56vp，根据你的 Tab 栏实际高度调整

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.route = params['route'] || '/discover';
      this.params = params;
      // 如果传递了 Tab 栏高度，使用传递的值
      if (params['tabBarHeight']) {
        this.tabBarHeight = parseInt(params['tabBarHeight']);
      }
    }
  }

  build() {
    Column() {
      // Flutter 容器，高度减去 Tab 栏高度
      flutterModule.FlutterView({
        initialRoute: this.route,
        params: this.params
      })
      .height('100%')
      .margin({ bottom: `${this.tabBarHeight}vp` }) // 底部留出 Tab 栏高度
    }
    .width('100%')
    .height('100%')
  }
}
```

### 1.2 动态传递 Tab 栏高度

如果 Tab 栏高度是动态的，可以在跳转时传递：

```typescript
// 在原生页面中跳转时传递 Tab 栏高度
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: '56' // 传递 Tab 栏高度（单位：vp）
  }
});
```

### 1.3 使用 SafeArea（更灵活）

如果原生应用有安全区域，可以使用更灵活的方式：

```typescript
import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';
import { safeAreaInsets } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  @State route: string = '/discover';
  @State params: Record<string, string> = {};
  private tabBarHeight: number = 56;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.route = params['route'] || '/discover';
      this.params = params;
      if (params['tabBarHeight']) {
        this.tabBarHeight = parseInt(params['tabBarHeight']);
      }
    }
  }

  build() {
    Column() {
      flutterModule.FlutterView({
        initialRoute: this.route,
        params: this.params
      })
      .layoutWeight(1) // 使用权重，自动填充剩余空间
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: `${this.tabBarHeight}vp` }) // 底部内边距
  }
}
```

---

## 方案二：Flutter 端调整

### 2.1 修改 Flutter 主入口

在 Flutter 项目中，修改 `lib/main.dart`：

```dart
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
    
    return GetMaterialApp(
      title: i18nController.get('app.name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 使用 SafeArea 包装，自动处理安全区域
      builder: (context, child) {
        return SafeArea(
          // 底部留出空间（根据原生 Tab 栏高度调整）
          bottom: true, // 自动处理底部安全区域
          child: Padding(
            padding: const EdgeInsets.only(bottom: 56.0), // Tab 栏高度，单位：逻辑像素
            child: child ?? const SizedBox(),
          ),
        );
      },
      initialRoute: AppRoutes.discover,
      getPages: AppPages.routes,
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
```

### 2.2 通过参数传递 Tab 栏高度

如果需要在运行时动态获取 Tab 栏高度，可以通过原生传递参数：

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final i18nController = Get.find<I18nController>();
    
    // 从原生传递的参数中获取 Tab 栏高度
    final tabBarHeight = Get.parameters['tabBarHeight'] ?? '56';
    final bottomPadding = double.tryParse(tabBarHeight) ?? 56.0;
    
    return GetMaterialApp(
      title: i18nController.get('app.name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: child ?? const SizedBox(),
          ),
        );
      },
      initialRoute: AppRoutes.discover,
      getPages: AppPages.routes,
      // ... 其他配置
    );
  }
}
```

---

## 方案三：混合方案（最佳实践）

### 3.1 原生端：使用布局权重

```typescript
import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  @State route: string = '/discover';
  @State params: Record<string, string> = {};
  private tabBarHeight: number = 56;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.route = params['route'] || '/discover';
      this.params = params;
      if (params['tabBarHeight']) {
        this.tabBarHeight = parseInt(params['tabBarHeight']);
      }
    }
  }

  build() {
    Column() {
      // Flutter 内容区域，使用权重自动填充
      flutterModule.FlutterView({
        initialRoute: this.route,
        params: this.params
      })
      .layoutWeight(1) // 关键：使用权重，自动计算高度
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start) // 顶部对齐
  }
}
```

### 3.2 Flutter 端：使用 SafeArea

```dart
// lib/main.dart
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
      builder: (context, child) {
        return SafeArea(
          bottom: false, // 原生已处理，Flutter 不需要再处理
          child: child ?? const SizedBox(),
        );
      },
      initialRoute: AppRoutes.discover,
      getPages: AppPages.routes,
      // ... 其他配置
    );
  }
}
```

---

## 方案四：动态获取 Tab 栏高度

如果 Tab 栏高度是动态的，可以在原生应用中获取：

```typescript
// 在原生应用中获取 Tab 栏高度
import { getContext } from '@kit.ArkUI';

// 获取 Tab 栏组件的高度
const tabBarHeight = this.tabBarComponent.getHeight(); // 假设有这个方法

// 或者使用固定值
const tabBarHeight = 56; // 根据实际 Tab 栏高度设置

// 跳转时传递
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: tabBarHeight.toString()
  }
});
```

---

## 推荐方案

**推荐使用方案一（原生端调整）**，原因：
1. ✅ 更灵活，可以动态调整
2. ✅ 不依赖 Flutter 端修改
3. ✅ 性能更好，减少 Flutter 端的布局计算
4. ✅ 更容易维护

---

## 完整示例代码

### 原生端完整代码

```typescript
// FlutterContainerPage.ets
import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  @State route: string = '/discover';
  @State params: Record<string, string> = {};
  
  // Tab 栏高度，默认 56vp（根据实际情况调整）
  private tabBarHeight: number = 56;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.route = params['route'] || '/discover';
      this.params = params;
      
      // 如果传递了 Tab 栏高度，使用传递的值
      if (params['tabBarHeight']) {
        this.tabBarHeight = parseInt(params['tabBarHeight']);
      }
    }
  }

  build() {
    Column() {
      // Flutter 视图，使用权重自动填充，底部留出 Tab 栏空间
      flutterModule.FlutterView({
        initialRoute: this.route,
        params: this.params
      })
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: `${this.tabBarHeight}vp` }) // 底部内边距
  }
}
```

### 跳转时传递参数

```typescript
// 在原生页面中跳转
import { router } from '@kit.ArkUI';

// 跳转到 Flutter 页面，传递 Tab 栏高度
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',
    tabBarHeight: '56' // Tab 栏高度（单位：vp）
  }
});
```

---

## 注意事项

1. **单位转换**：
   - 原生使用 `vp`（虚拟像素）
   - Flutter 使用逻辑像素（通常 1vp ≈ 1 逻辑像素）
   - 根据设备密度可能需要调整

2. **Tab 栏高度**：
   - 标准 Tab 栏高度通常是 48-56vp
   - 根据你的实际设计调整

3. **安全区域**：
   - 如果设备有底部安全区域（如 iPhone X 系列），需要考虑额外的安全区域高度

4. **测试**：
   - 在不同设备上测试，确保布局正确
   - 检查是否有内容被遮挡

---

## 调试技巧

1. **临时添加背景色**：
   ```typescript
   Column() {
     flutterModule.FlutterView({...})
   }
   .backgroundColor(Color.Red) // 临时添加，查看实际布局区域
   ```

2. **打印高度值**：
   ```typescript
   aboutToAppear() {
     console.info(`Tab 栏高度: ${this.tabBarHeight}vp`);
   }
   ```

3. **使用 DevEco Studio 的布局检查器**：
   - 查看实际布局边界
   - 确认 Flutter 容器的实际高度

---

## 总结

解决 Flutter 遮挡原生 Tab 栏的关键：
1. ✅ 在原生容器中为 Flutter 预留 Tab 栏高度
2. ✅ 使用 `layoutWeight` 或 `padding` 调整布局
3. ✅ 可以通过参数动态传递 Tab 栏高度
4. ✅ 在 Flutter 端使用 `SafeArea` 作为补充

选择最适合你项目的方案即可！
