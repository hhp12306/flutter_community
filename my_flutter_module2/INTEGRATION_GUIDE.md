# Flutter 模块集成到原生鸿蒙应用指南

本指南说明如何将 Flutter 模块集成到原生鸿蒙应用中。

## 方式一：使用 HAR 包（推荐用于生产环境）

### 1. 构建 HAR 包

在 Flutter 模块项目根目录执行：

```bash
# 使用脚本构建
./scripts/build_har.sh

# 或使用 Makefile
make build-har
```

构建完成后，HAR 包位置：
```
.ohos/flutter_module/build/default/outputs/default/flutter_module.har
```

### 2. 在原生鸿蒙项目中添加依赖

#### 方法 A：本地 HAR 包依赖（推荐）

1. 将 `flutter_module.har` 复制到原生项目的 `libs` 目录（如果没有则创建）

2. 在原生项目的 `oh-package.json5` 中添加依赖：

```json5
{
  "dependencies": {
    "@ohos/flutter_module": "file:../libs/flutter_module.har"
  }
}
```

#### 方法 B：通过路径依赖

在原生项目的 `oh-package.json5` 中添加：

```json5
{
  "dependencies": {
    "@ohos/flutter_module": "file:../path/to/my_flutter_module2/.ohos/flutter_module"
  }
}
```

### 3. 安装依赖

在原生项目根目录执行：

```bash
ohpm install
```

### 4. 在原生代码中使用 Flutter 模块

#### 4.1 导入 Flutter 模块

```typescript
import flutterModule from '@ohos/flutter_module';
```

#### 4.2 创建 Flutter 容器页面

```typescript
// FlutterContainerPage.ets
import flutterModule from '@ohos/flutter_module';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FlutterContainerPage {
  build() {
    Column() {
      // 使用 Flutter 模块提供的组件
      flutterModule.FlutterView({
        // 可以传递初始路由参数
        initialRoute: '/discover',
        // 其他配置参数
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

#### 4.3 路由跳转

```typescript
// 从原生页面跳转到 Flutter 页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',  // Flutter 内部路由
    tabId: 'recommend'   // 可选：指定初始 Tab
  }
});
```

## 方式二：直接使用 .ohos 目录（推荐用于开发阶段）

### 1. 在原生项目中添加路径依赖

在原生项目的 `oh-package.json5` 中添加：

```json5
{
  "dependencies": {
    "@ohos/flutter_module": "file:../path/to/my_flutter_module2/.ohos/flutter_module"
  }
}
```

### 2. 安装依赖

```bash
ohpm install
```

### 3. 使用方式同方式一的步骤 4

## 方式三：在 DevEco Studio 中直接打开

### 1. 打开 .ohos 目录

在 DevEco Studio 中：
- File -> Open
- 选择 `my_flutter_module2/.ohos` 目录

### 2. 构建 HAR 包

1. 在项目结构中，右键点击 `flutter_module` 模块
2. 选择 `Build` -> `Build HAP(s)/APP(s)` -> `Build HAR(s)`
3. 构建完成后，HAR 包在 `flutter_module/build/default/outputs/default/flutter_module.har`

## 配置说明

### Flutter 模块配置

模块的 Bundle Name 在 `pubspec.yaml` 中配置：

```yaml
module:
  ohosBundleName: com.example.my_flutter_module2
```

### 原生应用配置

确保原生应用的 `module.json5` 中配置了必要的权限：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
      // 其他需要的权限
    ]
  }
}
```

## 常见问题

### 1. HAR 包构建失败

**问题**：`hvigor` 命令未找到

**解决**：
- 确保已安装 DevEco Studio
- 配置环境变量，或使用 DevEco Studio IDE 构建

### 2. 依赖安装失败

**问题**：`ohpm install` 失败

**解决**：
- 检查路径是否正确
- 确保 HAR 包已正确构建
- 检查 `oh-package.json5` 中的依赖配置

### 3. Flutter 页面无法显示

**问题**：Flutter 页面空白或报错

**解决**：
- 确保已执行 `flutter build ohos`
- 检查资源文件是否正确打包
- 查看日志确认错误信息

### 4. 路由跳转问题

**问题**：无法跳转到 Flutter 内部路由

**解决**：
- 确保 Flutter 模块已正确初始化
- 检查路由名称是否正确（参考 `lib/discover/config/app_routes.dart`）

## 开发建议

1. **开发阶段**：使用方式二（直接路径依赖），方便调试和热重载
2. **生产环境**：使用方式一（HAR 包），便于版本管理和分发
3. **团队协作**：将 HAR 包上传到私有仓库，通过 ohpm 远程依赖

## 相关文件

- Flutter 路由配置：`lib/discover/config/app_routes.dart`
- Flutter 页面配置：`lib/discover/config/app_pages.dart`
- 模块配置：`.ohos/flutter_module/src/main/module.json5`

## 更多信息

- [HarmonyOS 应用开发文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ohos-overview-0000001477981205-V3)
- [Flutter 模块开发文档](https://docs.flutter.dev/development/add-to-app)
