# 鸿蒙构建配置自动更新脚本

## 功能说明

这个脚本用于自动修改鸿蒙项目的 `build-profile.json5` 文件，在 `runtimeOS: "HarmonyOS"` 下面添加 `buildOption` 配置。

## 使用方法

### 推荐方式：使用包装脚本（自动化）

#### 1. 执行 flutter pub get 并自动更新配置（如果存在）

```bash
# 在项目根目录执行
./scripts/pub_get.sh

# 或者使用 Makefile
make pub-get
```

#### 2. 构建鸿蒙产物并自动更新配置

```bash
# 在项目根目录执行
./scripts/build_ohos.sh

# 或者使用 Makefile
make build-ohos
```

#### 3. 运行到鸿蒙设备并自动更新配置

```bash
# 在项目根目录执行
./scripts/run_ohos.sh

# 或者使用 Makefile
make run-ohos
```

#### 4. 仅更新配置（不构建）

如果已经构建过，只想更新配置：

```bash
# 直接执行 Python 脚本
python3 scripts/update_build_profile.py

# 或者使用 Makefile
make update-profile
```

## 配置说明

脚本会自动在 `build-profile.json5` 文件中的 `products` 或 `targets` 数组里，找到包含 `runtimeOS: "HarmonyOS"` 的项，然后添加以下配置：

```json5
"buildOption": {
  "strictMode": {
    "useNormalizedOHMUrl": true,
    "caseSensitiveCheck": true
  }
}
```

## 修改前

```json5
"products": [
  {
    "name": "default",
    "signingConfig": "default",
    "compatibleSdkVersion": "5.1.0(18)",
    "runtimeOS": "HarmonyOS"
  }
]
```

## 修改后

```json5
"products": [
  {
    "name": "default",
    "signingConfig": "default",
    "compatibleSdkVersion": "5.1.0(18)",
    "runtimeOS": "HarmonyOS",
    "buildOption": {
      "strictMode": {
        "useNormalizedOHMUrl": true,
        "caseSensitiveCheck": true
      }
    }
  }
]
```

## 文件位置

脚本会自动查找以下位置的 `build-profile.json5` 文件：

1. `.ohos/entry/build-profile.json5`（最常见）
2. `.ohos/build-profile.json5`
3. `build-profile.json5`（项目根目录）

## 注意事项

1. **生成鸿蒙产物**：在运行脚本之前，需要先运行 `flutter build ohos` 生成鸿蒙产物，这样才会生成 `.ohos` 目录和 `build-profile.json5` 文件。

2. **避免重复执行**：脚本会自动检测是否已经包含 `buildOption` 配置，如果已经存在，会跳过修改。

3. **在 Dev Studio 中打开 .ohos 目录**：
   - 在 Finder 中按 `Command + Shift + .` 显示隐藏文件
   - 或者使用终端：`open .ohos` 打开目录
   - 然后在 Dev Studio 中打开该目录

## 脚本说明

### 核心脚本

- **`update_build_profile.py`** - 核心 Python 脚本，负责修改 `build-profile.json5` 文件
  - 被其他脚本调用，也可以单独使用

### 包装脚本（推荐使用）

- **`pub_get.sh`** - 执行 `flutter pub get` 并自动更新配置（如果存在）
  - 执行 `flutter pub get` 后自动检查并更新 `build-profile.json5`

- **`build_ohos.sh`** - 构建鸿蒙产物并自动更新配置
  - 执行 `flutter build ohos` 后自动调用更新脚本

- **`run_ohos.sh`** - 运行到鸿蒙设备并自动更新配置
  - 执行 `flutter run -d ohos` 后自动检测并更新配置

### Makefile 命令

项目根目录提供了 `Makefile`，可以使用以下命令：

```bash
make pub-get        # 执行 flutter pub get 并自动更新配置（如果存在）
make build-ohos     # 构建并更新配置
make run-ohos       # 运行并更新配置
make update-profile # 仅更新配置
```

### 执行时机说明

**✅ 适合在以下时机执行：**

1. **`flutter pub get` 之后**（如果 `.ohos` 目录已存在）
   - 如果之前已经构建过，`.ohos` 目录会保留
   - 使用 `./scripts/pub_get.sh` 或 `make pub-get` 会自动检查并更新

2. **`flutter build ohos` 之后**（最推荐）
   - 专门构建鸿蒙产物，会生成 `build-profile.json5` 文件
   - 使用 `./scripts/build_ohos.sh` 或 `make build-ohos`

3. **`flutter run -d ohos` 之后**
   - 运行到鸿蒙设备时也会生成构建产物
   - 使用 `./scripts/run_ohos.sh` 或 `make run-ohos`

4. **手动执行**
   - 如果已经构建过，可以单独执行更新脚本
   - 使用 `python3 scripts/update_build_profile.py` 或 `make update-profile`

### 自动化方案

使用包装脚本可以自动执行配置更新：

```bash
# 获取依赖时（如果 .ohos 目录已存在）
./scripts/pub_get.sh

# 构建时
./scripts/build_ohos.sh

# 运行时
./scripts/run_ohos.sh
```

**推荐做法**：
- 日常开发：使用 `./scripts/pub_get.sh` 替代 `flutter pub get`
- 构建发布：使用 `./scripts/build_ohos.sh` 替代 `flutter build ohos`
- 运行调试：使用 `./scripts/run_ohos.sh` 替代 `flutter run -d ohos`

这样就不需要每次都手动执行更新脚本了。
