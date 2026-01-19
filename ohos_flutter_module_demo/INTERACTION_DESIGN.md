# Flutter与宿主原生APP交互方案设计文档

## 一、交互方案概述

本文档详细说明了Flutter模块与宿主原生APP（Android、iOS、鸿蒙Next）之间的交互方案，包括：
1. Flutter与原生APP的双向通信
2. Flutter与H5页面的双向通信
3. 二级页面的交互方案（多套对比方案）
4. 登录状态校验与跳转逻辑

---

## 二、Flutter与原生APP交互方案

### 2.1 通信机制

**使用Platform Channel（MethodChannel + EventChannel）**

- **MethodChannel**: Flutter调用原生方法（如跳转登录页、获取用户信息等）
- **EventChannel**: 原生向Flutter发送事件（如登录状态变化、用户信息更新等）

### 2.2 通信流程

```
Flutter端                    原生端
   |                          |
   |--- MethodChannel ------>|  调用原生方法
   |<-- 返回结果 ------------|
   |                          |
   |<-- EventChannel --------|  原生发送事件
   |                          |
```

### 2.3 核心服务

**NativeBridgeService** (`lib/discover/services/native_bridge_service.dart`)

提供以下功能：
- ✅ 认证相关：检查登录状态、跳转登录页、获取用户信息、登出
- ✅ 页面跳转：跳转原生页面、打开原生WebView
- ✅ 数据共享：获取/设置共享数据
- ✅ UI交互：显示Toast、Loading
- ✅ 系统功能：获取系统信息、请求权限

### 2.4 使用示例

```dart
// 检查登录状态
final nativeBridge = NativeBridgeService();
final isLoggedIn = await nativeBridge.checkLoginStatus();

// 跳转登录页
final loginResult = await nativeBridge.navigateToLogin();
if (loginResult) {
  // 登录成功，继续后续操作
}

// 获取用户信息
final userInfo = await nativeBridge.getUserInfo();

// 跳转原生页面
await nativeBridge.navigateToNativePage('profile', params: {'userId': '123'});

// 显示Toast
await nativeBridge.showToast('操作成功');
```

---

## 三、Flutter与H5页面交互方案

### 3.1 通信机制

**使用JSBridge双向通信**

- **Flutter调用H5**: 通过`WebViewController.runJavaScript()`执行JavaScript代码
- **H5调用Flutter**: 通过JavaScript Channel接收H5消息

### 3.2 通信流程

```
Flutter端                  H5页面
   |                         |
   |-- runJavaScript() ---->|  调用H5方法
   |<-- JavaScript Channel -|  H5回调结果
   |                         |
   |<-- JavaScript Channel -|  H5调用Flutter方法
   |-- 处理并返回 ---------->|
```

### 3.3 核心服务

**H5BridgeService** (`lib/discover/services/h5_bridge_service.dart`)

提供以下功能：
- ✅ Flutter调用H5方法（支持回调）
- ✅ H5调用Flutter方法（通过JavaScript Channel）
- ✅ 自动注入JS Bridge代码到H5页面
- ✅ 登录状态同步（Flutter发送登录状态给H5）

### 3.4 使用示例

**Flutter调用H5方法**：
```dart
final h5Bridge = H5BridgeService();
await h5Bridge.callH5Method(
  webViewController,
  'onLoginStatusChanged',
  params: {'isLoggedIn': true, 'userInfo': userInfo},
  callback: (result) {
    print('H5回调结果: $result');
  },
);
```

**H5调用Flutter方法**（在H5页面中）：
```javascript
// H5页面中调用Flutter方法
window.FlutterBridge.callFlutter('navigateToPost', {
  topicId: '123',
  topicName: '参与话题'
}, function(result) {
  console.log('Flutter返回结果:', result);
});
```

### 3.5 H5 WebView页面

**H5WebViewPage** (`lib/discover/views/h5/h5_webview_page.dart`)

特性：
- ✅ 支持URL参数传递
- ✅ 自动注入JS Bridge
- ✅ 自动同步登录状态
- ✅ 支持页面标题动态更新
- ✅ 支持加载进度显示
- ✅ 支持WebView返回上一页

---

## 四、二级页面交互方案对比

### 4.1 场景说明

**二级页面场景**：
1. 活动Tab → 点击活动项 → 打开活动详情页（H5） → 点击"参与话题" → 跳转发帖页
2. 社区Tab → 点击发帖按钮 → 跳转发帖页
3. 推荐Tab → 点击视频项 → 打开视频播放页
4. 帖子详情页（H5） → 点击"参与话题" → 跳转发帖页

### 4.2 方案一：全屏模态打开（推荐⭐）

**特点**：
- 二级页面全屏打开，覆盖底部导航栏
- 左上角显示返回箭头按钮
- 适合：发帖页、视频播放页、H5详情页

**实现方式**：
```dart
// 使用Get.toNamed()全屏打开
Get.toNamed(
  AppRoutes.post,
  // 默认就是全屏打开，无需额外配置
);
```

**优点**：
- ✅ 用户体验好，沉浸感强
- ✅ 实现简单，无需额外配置
- ✅ 符合移动端常见交互模式

**缺点**：
- ❌ 完全覆盖了底部导航栏（这是预期的）

### 4.3 方案二：使用原生容器打开

**特点**：
- 使用原生Activity/ViewController打开
- Flutter页面嵌入到原生容器中
- 适合：需要与原生深度集成的场景

**实现方式**：
```dart
// Flutter调用原生方法，打开原生容器
await NativeBridgeService().navigateToNativePage('flutter_page', params: {
  'route': AppRoutes.post,
});
```

**优点**：
- ✅ 可以自定义原生导航栏
- ✅ 可以添加原生侧边栏、底部栏等

**缺点**：
- ❌ 实现复杂，需要原生端配合
- ❌ 性能开销较大

### 4.4 方案三：底部Sheet弹出

**特点**：
- 从底部弹出Sheet
- 适合：快速操作、不需要全屏的场景

**实现方式**：
```dart
Get.bottomSheet(
  PostPage(),
  isScrollControlled: true,
  isDismissible: true,
);
```

**优点**：
- ✅ 不会完全遮挡原页面
- ✅ 适合快速操作

**缺点**：
- ❌ 不适合内容较多的页面（如发帖页）
- ❌ 用户体验不如全屏打开

### 4.5 方案对比总结

| 方案 | 适用场景 | 用户体验 | 实现难度 | 推荐度 |
|------|---------|---------|---------|--------|
| 方案一：全屏模态 | 发帖、视频播放、H5详情 | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 方案二：原生容器 | 需要原生定制 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 方案三：底部Sheet | 快速操作 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

**推荐使用方案一（全屏模态打开）**，这是移动端最常见的二级页面打开方式。

---

## 五、登录状态校验与跳转逻辑

### 5.1 校验流程

```
用户操作
   |
   |-- 检查是否需要登录
   |   |
   |   |-- 需要登录
   |   |   |
   |   |   |-- 检查登录状态
   |   |   |   |
   |   |   |   |-- 未登录
   |   |   |   |   |
   |   |   |   |   |-- 跳转原生登录页
   |   |   |   |   |   |
   |   |   |   |   |   |-- 登录成功 → 继续原操作
   |   |   |   |   |   |-- 取消登录 → 终止操作
   |   |   |   |   |
   |   |   |   |-- 已登录 → 继续原操作
   |   |   |
   |   |-- 不需要登录 → 直接操作
```

### 5.2 实现方式

**RouteGuard** (`lib/discover/utils/route_guard.dart`)

```dart
// 在页面跳转前检查登录状态
final redirect = await RouteGuard.guardAsync(AppRoutes.post);
if (redirect == null) {
  // 已登录或不需要登录，继续跳转
  Get.toNamed(AppRoutes.post);
} else {
  // 未登录且取消登录，不跳转
}
```

**AuthService** (`lib/discover/services/auth_service.dart`)

```dart
// 检查登录状态（优先从原生端获取）
final isLoggedIn = await AuthService.isLoggedIn();

// 跳转登录页
final loginResult = await AuthService.navigateToNativeLogin();
```

### 5.3 登录状态同步

1. **Flutter → 原生**：通过NativeBridgeService检查登录状态
2. **原生 → Flutter**：通过EventChannel发送登录状态变化事件
3. **Flutter → H5**：通过H5BridgeService发送登录状态给H5页面

---

## 六、页面跳转场景实现

### 6.1 场景1：活动Tab → 活动详情页（H5） → 发帖页

```dart
// 1. 点击活动项，打开H5详情页
void _openActivityDetail(ActivityModel activity) {
  final h5Url = 'https://example.com/activity/detail?id=${activity.id}';
  Get.toNamed(
    AppRoutes.h5WebView,
    arguments: {
      'url': h5Url,
      'title': activity.title,
    },
  );
}

// 2. H5页面中，点击"参与话题"按钮
// H5页面JavaScript代码：
window.FlutterBridge.callFlutter('navigateToPost', {
  topicId: '123',
  topicName: '参与话题'
});

// 3. Flutter接收H5消息，跳转发帖页
void _handleNavigateToPost() async {
  // 检查登录状态
  final isLoggedIn = await NativeBridgeService().checkLoginStatus();
  if (!isLoggedIn) {
    final loginResult = await NativeBridgeService().navigateToLogin();
    if (!loginResult) return;
  }
  
  // 跳转发帖页
  Get.toNamed(AppRoutes.post);
}
```

### 6.2 场景2：社区Tab → 发帖页

```dart
// 点击发帖按钮
FloatingActionButton(
  onPressed: () async {
    // 先检查登录状态
    final redirect = await RouteGuard.guardAsync(AppRoutes.post);
    if (redirect == null) {
      // 已登录或不需要登录，跳转到发帖页
      Get.toNamed(AppRoutes.post);
    }
  },
  child: Icon(Icons.add),
)
```

---

## 七、集成代码示例

### 7.1 Android集成代码

见 `INTEGRATION_ANDROID.md`

### 7.2 iOS集成代码

见 `INTEGRATION_IOS.md`

### 7.3 鸿蒙Next集成代码

见 `INTEGRATION_OHOS.md`

---

## 八、最佳实践建议

### 8.1 通信规范

1. **统一使用NativeBridgeService和H5BridgeService**，不要直接使用MethodChannel
2. **方法命名规范**：使用驼峰命名，如`navigateToLogin`、`getUserInfo`
3. **参数格式**：使用Map<String, dynamic>传递参数
4. **错误处理**：所有通信方法都应包含try-catch错误处理

### 8.2 页面跳转规范

1. **二级页面统一使用全屏模态打开**（方案一）
2. **所有需要登录的页面**，都应在跳转前检查登录状态
3. **H5页面跳转Flutter页面**，统一通过JSBridge实现

### 8.3 登录状态管理

1. **优先从原生端获取登录状态**，保证数据一致性
2. **登录状态变化时**，同步更新Flutter和H5页面
3. **使用EventChannel监听**原生端的登录状态变化事件

---

## 九、总结

本方案提供了完整的Flutter与原生APP、Flutter与H5页面的交互解决方案，具有以下特点：

- ✅ **统一规范**：使用统一的Bridge服务，便于维护
- ✅ **易于扩展**：支持添加新的通信方法
- ✅ **用户体验好**：采用全屏模态打开二级页面
- ✅ **安全性高**：统一的登录状态校验机制
- ✅ **跨平台**：支持Android、iOS、鸿蒙Next

建议按照本方案进行实现，可以满足所有交互需求。
