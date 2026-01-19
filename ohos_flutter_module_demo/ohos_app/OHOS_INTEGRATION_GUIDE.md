# 鸿蒙原生页面交互实现指南

## 📋 已实现的功能

### 1. ✅ MethodChannel通信

**文件**: `entry/src/main/ets/entryability/EntryAbility.ets`

在EntryAbility中设置了MethodChannel，支持Flutter调用以下原生方法：
- `checkLoginStatus` - 检查登录状态
- `navigateToLogin` - 跳转登录页
- `getUserInfo` - 获取用户信息
- `logout` - 登出
- `navigateToNativePage` - 跳转原生页面
- `openNativeWebView` - 打开原生WebView
- `getSharedData` - 获取共享数据
- `setSharedData` - 设置共享数据
- `showToast` - 显示Toast
- `showLoading` - 显示Loading
- `hideLoading` - 隐藏Loading
- `getSystemInfo` - 获取系统信息
- `requestPermission` - 请求权限

### 2. ✅ 数据存储工具

**文件**: `entry/src/main/ets/utils/DataPreferencesUtil.ets`

实现了数据持久化功能：
- 用户登录状态存储
- 用户信息存储
- 共享数据存储

### 3. ✅ 登录页面

**文件**: `entry/src/main/ets/pages/LoginPage.ets`

实现了登录页面，支持：
- 用户名和密码输入
- 登录验证（模拟）
- 登录成功后保存用户信息
- 取消登录功能

### 4. ✅ WebView页面

**文件**: `entry/src/main/ets/pages/WebViewPage.ets`

实现了WebView页面，支持：
- 加载H5页面
- 显示页面标题
- 返回按钮

### 5. ✅ Bridge处理器

**文件**: `entry/src/main/ets/utils/FlutterBridgeHandler.ets`

统一处理Flutter通过MethodChannel调用的所有原生方法。

### 6. ✅ 主页面更新

**文件**: `entry/src/main/ets/pages/Index.ets`

更新了主页面，支持：
- 底部导航栏：发现（Flutter）、商城、爱车、服务、我的
- Flutter页面嵌入

---

## 🔧 使用方法

### Flutter端调用示例

```dart
// 1. 检查登录状态
final nativeBridge = NativeBridgeService();
final isLoggedIn = await nativeBridge.checkLoginStatus();

// 2. 跳转登录页
final loginResult = await nativeBridge.navigateToLogin();
if (loginResult) {
  print('登录成功');
} else {
  print('取消登录');
}

// 3. 获取用户信息
final userInfo = await nativeBridge.getUserInfo();
print('用户信息: $userInfo');

// 4. 打开原生WebView
await nativeBridge.openNativeWebView(
  'https://example.com/detail',
  title: '详情页',
);

// 5. 显示Toast
await nativeBridge.showToast('操作成功');

// 6. 获取系统信息
final systemInfo = await nativeBridge.getSystemInfo();
print('系统信息: $systemInfo');
```

---

## 📁 文件结构

```
ohos_app/entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets          # 主Ability，设置MethodChannel
├── pages/
│   ├── Index.ets                 # 主页面（包含底部导航栏）
│   ├── LoginPage.ets            # 登录页面
│   └── WebViewPage.ets          # WebView页面
└── utils/
    ├── DataPreferencesUtil.ets  # 数据存储工具
    └── FlutterBridgeHandler.ets # Flutter Bridge处理器
```

---

## ⚠️ 注意事项

### 1. MethodChannel API

由于flutter_ohos库的API可能在不同版本中有所不同，如果遇到编译错误，请检查：

1. **MethodChannel创建方式**：
   ```typescript
   // 如果上述方式不工作，可能需要使用：
   this.methodChannel = flutterEngine.getMethodChannel('com.example.my_flutter_module2/native');
   ```

2. **BinaryMessenger获取方式**：
   ```typescript
   // 可能需要使用：
   const binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();
   ```

### 2. 路由配置

确保在 `main_pages.json` 中注册了所有页面：
```json
{
  "src": [
    "pages/Index",
    "pages/LoginPage",
    "pages/WebViewPage"
  ]
}
```

### 3. 权限配置

在 `module.json5` 中配置必要的权限：
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "需要网络权限加载H5页面",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

### 4. 登录结果回调

由于鸿蒙路由的限制，登录结果通过以下方式传递：
1. 登录成功后，通过 `DataPreferencesUtil` 保存登录状态
2. Flutter端通过延迟检查登录状态来获取结果
3. 或者可以通过EventChannel实现更优雅的回调机制

---

## 🚀 测试步骤

### 1. 编译Flutter模块

```bash
cd my_flutter_module
flutter build ohos
```

### 2. 运行鸿蒙应用

```bash
cd ohos_app
# 使用DevEco Studio运行，或使用命令行
```

### 3. 测试交互功能

1. **测试登录功能**：
   - 在Flutter页面点击需要登录的操作
   - 应该弹出原生登录页面
   - 输入用户名和密码，点击登录
   - 登录成功后应该返回Flutter页面

2. **测试WebView功能**：
   - 在Flutter页面打开H5详情页
   - 应该打开原生WebView页面
   - 可以正常加载和显示H5内容

3. **测试数据存储**：
   - 登录后，关闭应用
   - 重新打开应用，应该保持登录状态

---

## 🔍 调试技巧

### 1. 查看日志

在DevEco Studio的Log窗口中查看日志：
- Flutter调用原生方法时会打印：`Flutter调用原生方法: xxx`
- 原生方法执行结果会打印在日志中

### 2. 检查MethodChannel

如果Flutter无法调用原生方法，检查：
1. MethodChannel名称是否匹配：`com.example.my_flutter_module2/native`
2. EntryAbility是否正确初始化了MethodChannel
3. Flutter Engine是否正确配置

### 3. 检查路由

如果页面无法跳转，检查：
1. 页面是否在 `main_pages.json` 中注册
2. 路由路径是否正确
3. 页面文件是否存在

---

## 📝 待完善功能

1. **EventChannel实现**：实现原生向Flutter发送事件（如登录状态变化）
2. **Loading Dialog**：实现完整的Loading显示和隐藏
3. **权限请求**：实现完整的权限请求逻辑
4. **错误处理**：增强错误处理和用户提示
5. **更多原生页面**：实现ProfilePage、MessagePage等页面

---

## 📚 参考文档

- [HarmonyOS开发文档](https://developer.harmonyos.com/)
- [Flutter for HarmonyOS](https://gitee.com/openharmony-sig/flutter_flutter)
- [ArkUI开发指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkui-overview-0000001504764721)

---

**版本**: 1.0.0  
**最后更新**: 2024年
