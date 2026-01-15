# Flutter 模块集成到原生鸿蒙应用 - 详细步骤

## 前置条件

- ✅ Flutter 模块项目已构建（`.ohos` 目录存在）
- ✅ 原生鸿蒙应用项目已创建
- ✅ DevEco Studio 已安装

---

## 第一步：构建 HAR 包

### 方法 A：使用 DevEco Studio（推荐）

1. **打开 Flutter 模块的 .ohos 目录**
   - 打开 DevEco Studio
   - 选择 `File` -> `Open`
   - 浏览到 `my_flutter_module2/.ohos` 目录
   - 点击 `OK` 打开

2. **等待项目同步**
   - DevEco Studio 会自动同步项目
   - 等待右下角同步完成（通常需要 1-2 分钟）

3. **构建 HAR 包**
   - 在左侧项目结构中，找到 `flutter_module` 模块
   - 右键点击 `flutter_module`
   - 选择 `Build` -> `Build HAP(s)/APP(s)` -> `Build HAR(s)`
   - 等待构建完成（底部会显示构建进度）

4. **验证 HAR 包**
   - 构建成功后，HAR 包位置：
     ```
     .ohos/flutter_module/build/default/outputs/default/flutter_module.har
     ```
   - 在 Finder 中验证文件是否存在

### 方法 B：使用命令行（如果已配置 hvigor）

```bash
cd /path/to/my_flutter_module2
./scripts/build_har.sh
# 或
make build-har
```

---

## 第二步：在原生鸿蒙项目中添加依赖

### 2.1 复制 HAR 包到原生项目

1. **创建 libs 目录**（如果不存在）
   ```bash
   cd /path/to/your/native/harmonyos/project
   mkdir -p libs
   ```

2. **复制 HAR 包**
   ```bash
   cp /path/to/my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har \
      libs/flutter_module.har
   ```

   或者直接在 Finder 中：
   - 找到 HAR 包文件
   - 复制到原生项目的 `libs` 目录

### 2.2 配置依赖

1. **打开原生项目的 `oh-package.json5` 文件**
   - 位置：原生项目根目录下的 `oh-package.json5`

2. **添加依赖配置**

   在 `dependencies` 部分添加：
   ```json5
   {
     "dependencies": {
       "@ohos/flutter_module": "file:../libs/flutter_module.har"
     }
   }
   ```

   完整示例：
   ```json5
   {
     "name": "your_native_app",
     "version": "1.0.0",
     "dependencies": {
       "@ohos/flutter_module": "file:../libs/flutter_module.har"
     }
   }
   ```

3. **安装依赖**
   ```bash
   cd /path/to/your/native/harmonyos/project
   ohpm install
   ```

   或者在 DevEco Studio 中：
   - 右键点击项目根目录
   - 选择 `Sync Project` 或 `ohpm install`

---

## 第三步：在原生代码中使用 Flutter 模块

### 3.1 创建 Flutter 容器页面

1. **在原生项目中创建新页面**

   例如：`entry/src/main/ets/pages/FlutterContainerPage.ets`

2. **编写页面代码**

   ```typescript
   import flutterModule from '@ohos/flutter_module';
   import { router } from '@kit.ArkUI';

   @Entry
   @Component
   struct FlutterContainerPage {
     // 接收路由参数
     @State route: string = '/discover';
     @State params: Record<string, string> = {};

     aboutToAppear() {
       // 获取传递的参数
       const params = router.getParams() as Record<string, string>;
       if (params) {
         this.route = params['route'] || '/discover';
         this.params = params;
       }
     }

     build() {
       Column() {
         // 使用 Flutter 模块
         flutterModule.FlutterView({
           initialRoute: this.route,
           params: this.params
         })
       }
       .width('100%')
       .height('100%')
     }
   }
   ```

### 3.2 配置路由

1. **在 `main_pages.json` 中添加路由**

   编辑 `entry/src/main/resources/base/profile/main_pages.json`：

   ```json
   {
     "src": [
       "pages/Index",
       "pages/FlutterContainerPage"
     ]
   }
   ```

### 3.3 从原生页面跳转到 Flutter 页面

在原生页面的代码中（例如 `Index.ets`）：

```typescript
import { router } from '@kit.ArkUI';

// 跳转到 Flutter 发现页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover',        // Flutter 内部路由
    tabId: 'recommend'         // 可选：指定初始 Tab
  }
});

// 跳转到 Flutter 推荐页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover/recommend'
  }
});

// 跳转到 Flutter 活动页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover/activity'
  }
});
```

---

## 第四步：配置权限（如果需要）

### 4.1 检查 Flutter 模块需要的权限

查看 `my_flutter_module2/.ohos/flutter_module/src/main/module.json5`：

```json5
{
  "module": {
    "requestPermissions": [
      {"name": "ohos.permission.INTERNET"}
    ]
  }
}
```

### 4.2 在原生应用中添加相同权限

编辑原生项目的 `module.json5`：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "需要网络权限访问 API",
        "usedScene": {
          "abilities": ["*"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

---

## 第五步：测试验证

### 5.1 运行原生应用

1. **连接设备或启动模拟器**
   - 在 DevEco Studio 中连接设备
   - 或启动 HarmonyOS 模拟器

2. **运行应用**
   - 点击运行按钮
   - 或使用快捷键运行

3. **测试跳转**
   - 从原生页面跳转到 Flutter 页面
   - 验证 Flutter 页面是否正常显示
   - 测试 Flutter 内部的路由跳转

### 5.2 常见问题排查

#### 问题 1：HAR 包找不到
- **检查**：HAR 包路径是否正确
- **解决**：确认 `oh-package.json5` 中的路径与实际文件位置一致

#### 问题 2：依赖安装失败
- **检查**：`ohpm install` 是否成功
- **解决**：删除 `oh_modules` 目录，重新执行 `ohpm install`

#### 问题 3：Flutter 页面空白
- **检查**：查看日志是否有错误信息
- **解决**：确保已执行 `flutter build ohos`，资源文件已正确打包

#### 问题 4：路由跳转失败
- **检查**：路由名称是否正确（参考 `lib/discover/config/app_routes.dart`）
- **解决**：确认传递的路由参数格式正确

---

## 可用的 Flutter 路由

根据 `lib/discover/config/app_routes.dart`，可用的路由包括：

| 路由 | 说明 |
|------|------|
| `/discover` | 发现主页（默认） |
| `/discover/recommend` | 推荐页面 |
| `/discover/community` | 社区页面 |
| `/discover/club` | 俱乐部页面 |
| `/discover/smart-drive` | 智驾页面 |
| `/discover/activity` | 活动页面 |
| `/discover/news` | 资讯页面 |
| `/discover/circle` | 圈子页面 |
| `/discover/live` | 直播页面 |
| `/discover/reputation` | 口碑页面 |
| `/post` | 发帖页面 |
| `/video` | 视频播放页面 |

### 路由参数示例

```typescript
// 跳转到推荐页面
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover/recommend'
  }
});

// 跳转到活动页面，并传递城市参数
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/discover/activity',
    cityId: 'beijing'
  }
});

// 跳转到视频播放页面，传递视频 URL
router.pushUrl({
  url: 'pages/FlutterContainerPage',
  params: {
    route: '/video',
    url: 'https://example.com/video.mp4',
    title: '视频标题'
  }
});
```

---

## 开发建议

### 1. 开发阶段

- 使用路径依赖（不打包 HAR）：
  ```json5
  {
    "dependencies": {
      "@ohos/flutter_module": "file:../path/to/my_flutter_module2/.ohos/flutter_module"
    }
  }
  ```
  这样可以方便调试和热重载。

### 2. 生产环境

- 使用 HAR 包依赖，便于版本管理和分发。

### 3. 版本管理

- 每次更新 Flutter 代码后，重新构建 HAR 包
- 更新原生项目中的 HAR 包
- 执行 `ohpm install` 更新依赖

---

## 完整示例代码

### 原生页面完整示例

```typescript
// Index.ets
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('原生应用首页')
        .fontSize(20)
        .margin({ bottom: 20 })

      Button('跳转到 Flutter 发现页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover'
            }
          });
        })
        .margin({ bottom: 10 })

      Button('跳转到 Flutter 推荐页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover/recommend'
            }
          });
        })
        .margin({ bottom: 10 })

      Button('跳转到 Flutter 活动页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover/activity'
            }
          });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 总结

集成步骤总结：

1. ✅ **构建 HAR 包** - 在 DevEco Studio 中打开 `.ohos` 目录并构建
2. ✅ **复制 HAR 包** - 复制到原生项目的 `libs` 目录
3. ✅ **配置依赖** - 在 `oh-package.json5` 中添加依赖
4. ✅ **安装依赖** - 执行 `ohpm install`
5. ✅ **创建容器页面** - 创建 Flutter 容器页面
6. ✅ **配置路由** - 在 `main_pages.json` 中添加路由
7. ✅ **测试验证** - 运行应用并测试跳转

按照以上步骤操作即可完成集成！
