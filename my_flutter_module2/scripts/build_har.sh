#!/bin/bash
# 构建 Flutter 模块为 HAR 包（HarmonyOS Archive）

# 不设置 set -e，允许某些步骤失败后继续

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "构建 Flutter 模块为 HAR 包"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

# 步骤 1: 检查是否已存在构建产物
echo "步骤 1/4: 检查 Flutter 构建产物..."
if [ -d ".ohos/flutter_module" ] && [ -f ".ohos/flutter_module/src/main/ets/plugins/GeneratedPluginRegistrant.ets" ]; then
    echo "✓ 发现已存在的 Flutter 构建产物，跳过 Flutter 构建步骤"
    SKIP_FLUTTER_BUILD=true
else
    echo "  未找到构建产物，开始构建 Flutter 产物..."
    SKIP_FLUTTER_BUILD=false
fi

# 步骤 2: 构建 Flutter 产物（如果需要）
if [ "$SKIP_FLUTTER_BUILD" = false ]; then
    echo ""
    echo "步骤 2/4: 构建 Flutter 产物..."
    if flutter build ohos 2>&1; then
        echo "✓ Flutter 构建成功"
    else
        echo ""
        echo "⚠️  警告: Flutter 构建失败"
        if [ -d ".ohos/flutter_module" ]; then
            echo "检测到 .ohos 目录已存在，将使用已有产物继续构建 HAR 包"
        else
            echo "错误: .ohos 目录不存在，无法继续构建 HAR 包"
            echo "请先解决 Flutter 构建问题，或手动执行 'flutter build ohos'"
            exit 1
        fi
    fi
else
    echo "步骤 2/4: 跳过 Flutter 构建（使用已有产物）"
fi

echo ""
echo "步骤 3/4: 更新 build-profile.json5 配置..."
if [ -f ".ohos/build-profile.json5" ] || [ -f ".ohos/entry/build-profile.json5" ]; then
    python3 "$SCRIPT_DIR/update_build_profile.py" || echo "⚠️  配置更新失败，但继续构建..."
else
    echo "⚠️  未找到 build-profile.json5，跳过配置更新"
fi

echo ""
echo "步骤 4/4: 构建 HAR 包..."
cd "$PROJECT_ROOT/.ohos"

# 检查是否安装了 hvigor
if ! command -v hvigor &> /dev/null; then
    echo ""
    echo "⚠️  警告: 未找到 hvigor 命令"
    echo ""
    echo "请使用以下方式之一构建 HAR 包："
    echo ""
    echo "方式 1: 使用 DevEco Studio（推荐）"
    echo "  1. 在 DevEco Studio 中打开 .ohos 目录"
    echo "  2. 右键点击 flutter_module 模块"
    echo "  3. 选择 Build -> Build HAP(s)/APP(s) -> Build HAR(s)"
    echo ""
    echo "方式 2: 配置 hvigor 环境变量"
    echo "  确保 DevEco Studio 的 hvigor 工具已添加到 PATH"
    echo ""
    echo "HAR 包将生成在："
    echo "  .ohos/flutter_module/build/default/outputs/default/flutter_module.har"
    echo ""
    exit 0
fi

# 构建 flutter_module 为 HAR 包
echo "正在构建 flutter_module HAR 包..."
if hvigor assembleHap --mode module -p module=flutter_module@default; then
    echo "✓ HAR 包构建成功"
    HAR_BUILT=true
else
    echo ""
    echo "⚠️  警告: HAR 包构建失败"
    echo "请检查错误信息，或使用 DevEco Studio 手动构建"
    HAR_BUILT=false
fi

echo ""
if [ "$HAR_BUILT" = true ]; then
    echo "=========================================="
    echo "✅ HAR 包构建完成！"
    echo "=========================================="
    echo ""
    HAR_PATH=".ohos/flutter_module/build/default/outputs/default/flutter_module.har"
    if [ -f "$HAR_PATH" ]; then
        HAR_SIZE=$(du -h "$HAR_PATH" | cut -f1)
        echo "HAR 包位置: $HAR_PATH"
        echo "HAR 包大小: $HAR_SIZE"
    else
        echo "⚠️  警告: 未找到 HAR 包文件"
        echo "预期位置: $HAR_PATH"
    fi
    echo ""
    echo "下一步："
    echo "  1. 将生成的 HAR 包复制到你的原生鸿蒙项目"
    echo "  2. 在原生项目的 oh-package.json5 中添加依赖"
    echo "  3. 参考 INTEGRATION_GUIDE.md 了解详细集成步骤"
    echo ""
else
    echo "=========================================="
    echo "❌ HAR 包构建未完成"
    echo "=========================================="
    echo ""
    echo "请检查错误信息，或使用 DevEco Studio 手动构建"
    echo ""
fi
