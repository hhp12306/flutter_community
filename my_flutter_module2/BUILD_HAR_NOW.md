# 立即构建 HAR 包 - 操作指南

由于当前环境中 `hvigor` 命令不可用，需要通过 DevEco Studio 来构建 HAR 包。

## 快速操作步骤（5分钟）

### 方法一：使用 DevEco Studio Gradle 面板（最简单）

1. **打开 DevEco Studio**

2. **打开项目**
   - `File` -> `Open`
   - 选择：`/Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos`
   - 点击 `OK`

3. **等待同步完成**
   - 右下角显示 "Sync completed"

4. **打开 Gradle 面板**
   - 点击右侧边栏的 `Gradle` 标签
   - 如果没有，点击 `View` -> `Tool Windows` -> `Gradle`

5. **找到构建任务**
   - 在 Gradle 面板中展开：
     ```
     my_flutter_module2
     -> flutter_module
        -> Tasks
           -> ohos
              -> assembleHap  ← 双击这里
     ```

6. **等待构建完成**
   - 底部 Build 面板会显示进度
   - 完成后显示 "BUILD SUCCESSFUL"

7. **验证 HAR 包**
   - 在 Project 面板中展开：
     ```
     flutter_module
     -> build
        -> default
           -> outputs
              -> default
                 -> flutter_module.har  ✅
     ```

### 方法二：使用终端（如果 DevEco Studio 已安装）

如果你知道 DevEco Studio 的安装路径，可以尝试：

```bash
# 进入 .ohos 目录
cd /Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos

# 尝试使用可能的 hvigor 路径
# 注意：需要替换为你的实际 DevEco Studio 安装路径
/Applications/DevEco\ Studio.app/Contents/plugins/hvigor-plugin/tools/hvigor/bin/hvigor \
  assembleHap --mode module -p module=flutter_module@default
```

## 构建后的 HAR 包位置

构建成功后，HAR 包位置：
```
/Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har
```

## 验证构建是否成功

在终端中执行：

```bash
ls -lh /Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har
```

如果文件存在并显示大小（通常几 MB 到几十 MB），说明构建成功！

## 如果构建失败

### 检查清单：

- [ ] 项目已同步完成
- [ ] `flutter_module` 模块在项目结构中可见
- [ ] `flutter_module/src/main/module.json5` 中 `"type": "har"` 已配置
- [ ] 已执行过 `flutter build ohos`（确保有构建产物）

### 常见错误：

1. **找不到模块**
   - 确保已打开 `.ohos` 目录（不是项目根目录）
   - 重新同步项目

2. **构建任务不存在**
   - 刷新 Gradle：右键项目 -> `Refresh Gradle Project`
   - 检查 `hvigorfile.ts` 配置

3. **构建失败**
   - 查看 Build 面板中的错误信息
   - 确保 Flutter 产物已构建

## 构建完成后

HAR 包构建成功后，你可以：

1. **复制到原生项目**
   ```bash
   cp /Users/huhuiping/github/flutterProjects/my_flutter_module2/.ohos/flutter_module/build/default/outputs/default/flutter_module.har \
      /path/to/your/native/project/libs/
   ```

2. **在原生项目中配置依赖**
   - 参考 `INTEGRATE_TO_EXISTING_PROJECT.md`

## 需要帮助？

如果遇到问题，请告诉我：
- 具体的错误信息
- 在哪一步卡住了
- DevEco Studio 的版本信息
