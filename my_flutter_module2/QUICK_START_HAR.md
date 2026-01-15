# 快速构建 HAR 包指南

## 方式一：使用 DevEco Studio（最简单，推荐）

### 步骤：

1. **打开项目**
   - 在 DevEco Studio 中，选择 `File` -> `Open`
   - 选择 `my_flutter_module2/.ohos` 目录（注意是 `.ohos` 目录，不是项目根目录）

2. **等待项目同步**
   - DevEco Studio 会自动同步项目依赖
   - 等待右下角的同步进度完成

3. **构建 HAR 包**
   - 在左侧项目结构中，找到 `flutter_module` 模块
   - 右键点击 `flutter_module`
   - 选择 `Build` -> `Build HAP(s)/APP(s)` -> `Build HAR(s)`

4. **查找生成的 HAR 包**
   - 构建完成后，HAR 包位置：
     ```
     .ohos/flutter_module/build/default/outputs/default/flutter_module.har
     ```

## 方式二：使用命令行（需要配置 hvigor）

### 前提条件：
- 已安装 DevEco Studio
- `hvigor` 命令已添加到系统 PATH

### 步骤：

```bash
# 在项目根目录执行
./scripts/build_har.sh

# 或使用 Makefile
make build-har
```

### 如果 hvigor 未找到：

1. **查找 hvigor 位置**
   - 通常在 DevEco Studio 安装目录下的 `tools/hvigor/bin` 目录

2. **添加到 PATH**
   ```bash
   # 临时添加（当前终端会话有效）
   export PATH=$PATH:/path/to/DevEcoStudio/tools/hvigor/bin
   
   # 永久添加（添加到 ~/.zshrc 或 ~/.bash_profile）
   echo 'export PATH=$PATH:/path/to/DevEcoStudio/tools/hvigor/bin' >> ~/.zshrc
   source ~/.zshrc
   ```

## 方式三：使用 npm 脚本（如果可用）

```bash
cd .ohos
npm install  # 首次需要安装依赖
npm run build:har  # 如果 package.json 中配置了此脚本
```

## 验证 HAR 包

构建完成后，检查 HAR 包是否存在：

```bash
ls -lh .ohos/flutter_module/build/default/outputs/default/flutter_module.har
```

如果文件存在，说明构建成功！

## 下一步：集成到原生应用

1. **复制 HAR 包**
   ```bash
   # 将 HAR 包复制到原生项目的 libs 目录
   cp .ohos/flutter_module/build/default/outputs/default/flutter_module.har \
      /path/to/your/native/project/libs/
   ```

2. **在原生项目中添加依赖**
   
   编辑原生项目的 `oh-package.json5`：
   ```json5
   {
     "dependencies": {
       "@ohos/flutter_module": "file:../libs/flutter_module.har"
     }
   }
   ```

3. **安装依赖**
   ```bash
   cd /path/to/your/native/project
   ohpm install
   ```

4. **使用 Flutter 模块**
   
   参考 `INTEGRATION_GUIDE.md` 了解详细的使用方法。

## 常见问题

### Q: 构建失败，提示找不到某些文件
**A:** 确保先执行了 `flutter build ohos`，或者使用脚本自动构建。

### Q: hvigor 命令找不到
**A:** 使用方式一（DevEco Studio）是最简单可靠的方法。

### Q: HAR 包构建成功但无法在原生项目中使用
**A:** 
- 检查 HAR 包的路径是否正确
- 确保原生项目的 `oh-package.json5` 配置正确
- 执行 `ohpm install` 重新安装依赖

### Q: 如何更新 HAR 包
**A:** 
- 修改 Flutter 代码后，重新执行构建步骤
- 将新的 HAR 包复制到原生项目
- 执行 `ohpm install` 更新依赖

## 相关文档

- 详细集成指南：`INTEGRATION_GUIDE.md`
- 构建脚本：`scripts/build_har.sh`
