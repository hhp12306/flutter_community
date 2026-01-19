# Flutter 页面布局指南

## 概述

本项目中的 Flutter 模块嵌入到原生 HarmonyOS 应用中，需要处理两种页面布局场景：

1. **一级页面**：适配原生底部 Tab 栏（如 DiscoverPage）
2. **二级页面**：全屏显示（如城市选择、发帖、视频详情等）

## 一级页面适配原生底部 Tab

### 实现原理

- **原生侧（`ohos_app/entry/src/main/ets/pages/Index.ets`）**：
  - 使用 `Tabs` 组件创建底部导航栏
  - `FlutterPage` 嵌入在第一个 `TabContent` 中
  - 原生自动处理底部 Tab 栏的高度适配

- **Flutter 侧（`my_flutter_module/lib/discover/views/discover/discover_page.dart`）**：
  - `DiscoverPage` 不需要额外的 `SafeArea` 处理
  - 原生已经自动为 Flutter 页面留出底部 Tab 栏的空间
  - Flutter 页面会自动适配可用区域

### 一级页面列表

以下页面是一级页面，需要适配原生底部 Tab：

- `DiscoverPage`：发现主页（社区首页）
  - 包含多个 Tab：推荐、社区、智能、活动、口碑、直播等
  - 在原生 `Index.ets` 的第一个 Tab 中显示

## 二级页面全屏显示

### 实现原理

- **路由跳转**：使用 GetX 路由系统（`Get.toNamed()`）跳转到二级页面
- **全屏显示**：GetX 的路由跳转默认是全屏的，相当于打开一个新的页面
- **返回机制**：通过 `Get.back()` 或 `Navigator.pop()` 返回

### 二级页面列表

以下页面是二级页面，需要全屏显示：

1. **`CitySelectorPage`**：城市选择页面
   - 路由：`AppRoutes.citySelector` (`/city_selector`)
   - 跳转方式：从活动页面等跳转
   - 全屏显示：✅

2. **`PostPage`**：发帖页面
   - 路由：`AppRoutes.post` (`/post`)
   - 跳转方式：从发现页面跳转
   - 全屏显示：✅

3. **`VideoPlayerPage`**：视频播放页面
   - 路由：`AppRoutes.videoPlayer` (`/video`)
   - 跳转方式：从视频列表跳转
   - 全屏显示：✅

4. **`H5WebViewPage`**：H5 WebView 页面
   - 路由：`AppRoutes.h5WebView` (`/h5`)
   - 跳转方式：从活动、智能等页面跳转
   - 全屏显示：✅

### 路由配置

所有二级页面都在 `app_pages.dart` 中配置：

```dart
// 城市选择页面（二级页面，全屏显示）
GetPage(
  name: AppRoutes.citySelector,
  page: () {
    final currentCityParam = Get.arguments?['currentCity'];
    CityModel? currentCity;
    if (currentCityParam != null && currentCityParam is CityModel) {
      currentCity = currentCityParam;
    }
    return CitySelectorPage(currentCity: currentCity);
  },
),
```

### 跳转示例

#### 从活动页面跳转到城市选择页面

```dart
// activity_page.dart
Future<void> _openCitySelector() async {
  // 使用路由跳转，确保全屏显示
  final selectedCity = await Get.toNamed<CityModel>(
    AppRoutes.citySelector,
    arguments: {
      'currentCity': _currentCity,
    },
  );

  if (selectedCity != null) {
    setState(() {
      _currentCity = selectedCity;
    });
    // 重新加载数据
    await _loadActivityData();
  }
}
```

#### 从活动页面跳转到 H5 详情页

```dart
// activity_page.dart
void _openActivityDetailH5(String activityId) {
  Get.toNamed(
    AppRoutes.h5WebView,
    arguments: {
      'url': 'https://example.com/activity/$activityId',
      'title': '活动详情',
    },
  );
}
```

## 页面层级结构

```
原生 Index.ets (包含底部 Tab 栏)
  └─ Tab 1: 发现 (Flutter)
      └─ DiscoverPage (一级页面，适配底部 Tab)
          ├─ RecommendPage
          ├─ CommunityPage
          ├─ ActivityPage
          │   └─ 跳转到 → CitySelectorPage (二级页面，全屏) ✅
          │   └─ 跳转到 → H5WebViewPage (二级页面，全屏) ✅
          └─ ...
  └─ Tab 2: 商城 (原生)
  └─ Tab 3: 爱车 (原生)
  └─ Tab 4: 服务 (原生)
  └─ Tab 5: 我的 (原生)
```

## 注意事项

1. **一级页面**：
   - 不需要 `SafeArea` 处理（原生已处理）
   - 不要使用全屏路由跳转
   - 保持在原生 Tab 容器内

2. **二级页面**：
   - 必须通过路由跳转（`Get.toNamed()`）
   - 不要使用 `Get.to()` 直接跳转 Widget（已废弃）
   - 确保在路由配置中注册
   - 全屏显示，覆盖原生底部 Tab 栏

3. **返回逻辑**：
   - 二级页面返回使用 `Get.back()` 或 `Navigator.pop()`
   - 可以返回数据给调用页面（如城市选择返回选中的城市）

## 验证方法

1. **一级页面适配验证**：
   - 打开应用，进入发现 Tab
   - 检查底部是否显示原生 Tab 栏
   - 滚动内容时，底部 Tab 栏应该始终可见

2. **二级页面全屏验证**：
   - 从活动页面点击城市选择按钮
   - 城市选择页面应该全屏显示，底部 Tab 栏被覆盖
   - 点击返回按钮，应该返回到活动页面

## 常见问题

### Q: 为什么城市选择页面没有全屏显示？

A: 确保使用 `Get.toNamed()` 跳转，而不是 `Get.to()`。检查路由是否正确配置在 `app_pages.dart` 中。

### Q: DiscoverPage 底部被 Tab 栏遮挡怎么办？

A: 原生应该已经处理了底部 Tab 栏的高度。如果仍然被遮挡，检查 `Index.ets` 中 `FlutterPage` 的布局配置。

### Q: 如何添加新的二级页面？

A: 
1. 在 `app_routes.dart` 中添加路由常量
2. 在 `app_pages.dart` 中添加路由配置
3. 使用 `Get.toNamed()` 跳转

## 代码示例

### 完整的城市选择跳转流程

```dart
// 1. 在 app_routes.dart 中定义路由
static const String citySelector = '/city_selector';

// 2. 在 app_pages.dart 中配置路由
GetPage(
  name: AppRoutes.citySelector,
  page: () {
    final currentCityParam = Get.arguments?['currentCity'];
    CityModel? currentCity;
    if (currentCityParam != null && currentCityParam is CityModel) {
      currentCity = currentCityParam;
    }
    return CitySelectorPage(currentCity: currentCity);
  },
),

// 3. 在 activity_page.dart 中跳转
Future<void> _openCitySelector() async {
  final selectedCity = await Get.toNamed<CityModel>(
    AppRoutes.citySelector,
    arguments: {
      'currentCity': _currentCity,
    },
  );

  if (selectedCity != null) {
    // 处理返回的城市
    setState(() {
      _currentCity = selectedCity;
    });
  }
}
```
