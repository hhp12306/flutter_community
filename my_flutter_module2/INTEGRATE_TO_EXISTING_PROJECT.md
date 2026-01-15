# 集成 Flutter 模块到已有鸿蒙项目 - 详细指南

## 场景说明

你已经有一个原生鸿蒙项目（项目A），现在要将 Flutter 模块（my_flutter_module2）集成到项目A中。

---

## 第一步：准备 HAR 包

### 1.1 构建 HAR 包

在 Flutter 模块项目中：

1. **打开 DevEco Studio**
2. **打开 Flutter 模块的 .ohos 目录**
   - `File` -> `Open`
   - 选择：`my_flutter_module2/.ohos`
3. **构建 HAR 包**
   - 右键 `flutter_module` -> `Build` -> `Build HAP(s)/APP(s)` -> `Build HAR(s)`
4. **找到生成的 HAR 包**
   - 位置：`my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har`
   - 记住这个文件的完整路径

---

## 第二步：在原生项目中添加 HAR 包

### 方法 A：复制 HAR 包到项目内（推荐）

#### 2.1 创建 libs 目录

在你的原生鸿蒙项目根目录下：

```bash
cd /path/to/your/existing/harmonyos/project
mkdir -p libs
```

#### 2.2 复制 HAR 包

```bash
# 复制 HAR 包到原生项目的 libs 目录
cp /path/to/my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har \
   libs/flutter_module.har
```

或者在 Finder 中：
- 找到 HAR 包文件
- 复制到原生项目的 `libs` 目录

#### 2.3 配置依赖

编辑原生项目的 `oh-package.json5`（在项目根目录）：

```json5
{
  "name": "your_existing_project",
  "version": "1.0.0",
  "dependencies": {
    "@ohos/flutter_module": "file:../libs/flutter_module.har"
  }
}
```

**注意**：路径是相对于项目根目录的，`../libs` 表示项目根目录下的 `libs` 文件夹。

#### 2.4 安装依赖

```bash
cd /path/to/your/existing/harmonyos/project
ohpm install
```

或者在 DevEco Studio 中：
- 右键点击项目根目录
- 选择 `Sync Project` 或 `ohpm install`

---

### 方法 B：使用绝对路径（开发阶段推荐）

如果你经常更新 Flutter 模块，可以使用绝对路径依赖，这样每次更新后不需要重新复制 HAR 包。

#### 2.1 配置依赖

编辑原生项目的 `oh-package.json5`：

```json5
{
  "name": "your_existing_project",
  "version": "1.0.0",
  "dependencies": {
    "@ohos/flutter_module": "file:/absolute/path/to/my_flutter_module2/.ohos/flutter_module"
  }
}
```

**示例**（macOS）：
```json5
{
  "dependencies": {
    "@ohos/flutter_module": "file:/Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos/flutter_module"
  }
}
```

**注意**：使用绝对路径时，需要指向 `.ohos/flutter_module` 目录，而不是 HAR 文件。

#### 2.2 安装依赖

```bash
ohpm install
```

---

## 第三步：在原生代码中使用 Flutter 模块

### 3.1 创建 Flutter 容器页面

在你的原生项目中创建新页面：

**文件位置**：`entry/src/main/ets/pages/FlutterContainerPage.ets`

**代码**：

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

编辑 `entry/src/main/resources/base/profile/main_pages.json`：

```json
{
  "src": [
    "pages/Index",
    "pages/FlutterContainerPage"
    // ... 你的其他页面
  ]
}
```

### 3.3 从现有页面跳转

在你的现有页面中（例如 `Index.ets` 或其他页面）：

```typescript
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 你的现有内容
      Text('原生应用首页')
      
      // 添加跳转按钮
      Button('打开 Flutter 发现页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover'
            }
          });
        })
    }
  }
}
```

---

## 第四步：配置权限

### 4.1 检查 Flutter 模块需要的权限

Flutter 模块需要的权限在 `module.json5` 中定义：
- `ohos.permission.INTERNET`（网络权限）

### 4.2 在原生项目中添加权限

编辑原生项目的 `entry/src/main/module.json5`：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "Flutter 模块需要网络权限",
        "usedScene": {
          "abilities": ["*"],
          "when": "inuse"
        }
      }
      // ... 你的其他权限
    ]
  }
}
```

---

## 第五步：测试验证

### 5.1 运行项目

1. **连接设备或启动模拟器**
2. **运行原生应用**
3. **点击跳转按钮**，测试是否能正常打开 Flutter 页面

### 5.2 验证步骤

- ✅ 应用能正常启动
- ✅ 能跳转到 Flutter 页面
- ✅ Flutter 页面正常显示
- ✅ Flutter 内部路由正常工作

---

## 常见问题排查

### 问题 1：依赖安装失败

**错误信息**：`ohpm install` 失败

**解决方案**：
1. 检查 HAR 包路径是否正确
2. 确认 HAR 包文件存在
3. 删除 `oh_modules` 目录，重新执行 `ohpm install`
4. 检查 `oh-package.json5` 格式是否正确

### 问题 2：找不到模块

**错误信息**：`Cannot find module '@ohos/flutter_module'`

**解决方案**：
1. 确认已执行 `ohpm install`
2. 检查 `oh_modules` 目录是否存在
3. 在 DevEco Studio 中执行 `Sync Project`
4. 重启 DevEco Studio

### 问题 3：Flutter 页面空白

**错误信息**：页面显示空白或报错

**解决方案**：
1. 检查日志，查看具体错误信息
2. 确认 Flutter 模块已正确构建（执行过 `flutter build ohos`）
3. 检查资源文件是否正确打包
4. 确认权限已正确配置

### 问题 4：路由跳转失败

**错误信息**：无法跳转到 Flutter 页面

**解决方案**：
1. 检查 `main_pages.json` 中是否添加了路由
2. 确认路由名称拼写正确
3. 检查 `FlutterContainerPage.ets` 文件是否存在
4. 查看日志中的错误信息

### 问题 5：路径问题

**错误信息**：`file:../libs/flutter_module.har` 找不到

**解决方案**：
1. 确认 `libs` 目录在项目根目录下
2. 确认 HAR 包文件名正确
3. 尝试使用绝对路径
4. 检查文件权限

---

## 项目结构示例

集成后的项目结构应该是这样的：

```
your_existing_project/
├── entry/                    # 你的现有 entry 模块
│   ├── src/
│   │   └── main/
│   │       ├── ets/
│   │       │   └── pages/
│   │       │       ├── Index.ets          # 你的现有页面
│   │       │       └── FlutterContainerPage.ets  # 新增的 Flutter 容器页面
│   │       └── resources/
│   │           └── base/
│   │               └── profile/
│   │                   └── main_pages.json      # 添加路由配置
│   └── module.json5          # 添加权限配置
├── libs/                     # 新增：存放 HAR 包
│   └── flutter_module.har
├── oh_modules/               # ohpm 安装的依赖
│   └── @ohos/
│       └── flutter_module/
├── oh-package.json5          # 添加依赖配置
└── ... 你的其他文件
```

---

## 更新 Flutter 模块

当你更新了 Flutter 模块代码后：

### 方法 A：使用 HAR 包

1. **重新构建 HAR 包**（在 Flutter 模块项目中）
2. **替换原生项目中的 HAR 包**
   ```bash
   cp /path/to/new/flutter_module.har libs/flutter_module.har
   ```
3. **重新安装依赖**
   ```bash
   ohpm install
   ```

### 方法 B：使用路径依赖

1. **在 Flutter 模块项目中重新构建**
   ```bash
   cd /path/to/my_flutter_module2
   flutter build ohos
   ```
2. **在原生项目中同步**
   - DevEco Studio 会自动检测变化
   - 或执行 `ohpm install`

---

## 开发建议

### 1. 开发阶段

- **使用路径依赖**（方法 B），方便调试和热重载
- 每次修改 Flutter 代码后，只需重新构建，原生项目会自动更新

### 2. 生产环境

- **使用 HAR 包**（方法 A），便于版本管理和分发
- 可以控制具体使用的版本

### 3. 团队协作

- 将 HAR 包上传到私有仓库
- 使用远程依赖：
  ```json5
  {
    "dependencies": {
      "@ohos/flutter_module": "https://your-repo.com/flutter_module.har"
    }
  }
  ```

---

## 完整示例：从现有页面跳转

假设你有一个现有的首页 `Index.ets`：

```typescript
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 你现有的内容
      Text('欢迎使用应用')
        .fontSize(24)
        .margin({ bottom: 30 })

      // 添加跳转到 Flutter 的按钮
      Button('进入发现页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover'
            }
          });
        })
        .width('80%')
        .height(50)
        .margin({ bottom: 10 })

      Button('进入推荐页面')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FlutterContainerPage',
            params: {
              route: '/discover/recommend'
            }
          });
        })
        .width('80%')
        .height(50)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 总结

集成到已有项目的步骤：

1. ✅ **构建 HAR 包** - 在 Flutter 模块项目中构建
2. ✅ **复制 HAR 包** - 复制到原生项目的 `libs` 目录
3. ✅ **配置依赖** - 在 `oh-package.json5` 中添加依赖
4. ✅ **安装依赖** - 执行 `ohpm install`
5. ✅ **创建容器页面** - 创建 `FlutterContainerPage.ets`
6. ✅ **配置路由** - 在 `main_pages.json` 中添加路由
7. ✅ **添加权限** - 在 `module.json5` 中添加权限
8. ✅ **测试验证** - 运行应用并测试跳转

按照以上步骤操作即可完成集成！
