#!/bin/bash
# 自动查找 hvigor 并构建 HAR 包

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "查找 hvigor 并构建 HAR 包"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT/.ohos"

# 方法 1: 检查 PATH 中的 hvigor
if command -v hvigor &> /dev/null; then
    echo "✓ 找到 hvigor 命令"
    HVIGOR_CMD="hvigor"
else
    echo "⚠️  hvigor 不在 PATH 中，尝试查找..."
    
    # 方法 2: 查找常见的 DevEco Studio 安装位置
    POSSIBLE_PATHS=(
        "/Applications/DevEco Studio.app/Contents/plugins/hvigor-plugin/tools/hvigor/bin/hvigor"
        "$HOME/AppData/Local/Huawei/DevEco Studio/plugins/hvigor-plugin/tools/hvigor/bin/hvigor"
        "/opt/DevEco Studio/plugins/hvigor-plugin/tools/hvigor/bin/hvigor"
    )
    
    HVIGOR_CMD=""
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo "✓ 找到 hvigor: $path"
            HVIGOR_CMD="$path"
            break
        fi
    done
    
    # 方法 3: 使用 find 命令查找
    if [ -z "$HVIGOR_CMD" ]; then
        echo "正在搜索 hvigor..."
        FOUND_HVIGOR=$(find /Applications -name "hvigor" -type f 2>/dev/null | head -1)
        if [ -n "$FOUND_HVIGOR" ]; then
            echo "✓ 找到 hvigor: $FOUND_HVIGOR"
            HVIGOR_CMD="$FOUND_HVIGOR"
        fi
    fi
fi

# 如果还是找不到
if [ -z "$HVIGOR_CMD" ]; then
    echo ""
    echo "❌ 未找到 hvigor 命令"
    echo ""
    echo "请使用以下方式之一构建 HAR 包："
    echo ""
    echo "方式 1: 使用 DevEco Studio（推荐）"
    echo "  1. 打开 DevEco Studio"
    echo "  2. File -> Open -> 选择 .ohos 目录"
    echo "  3. 打开 Gradle 面板"
    echo "  4. 展开 flutter_module -> Tasks -> ohos"
    echo "  5. 双击 assembleHap 任务"
    echo ""
    echo "方式 2: 手动配置 hvigor 路径"
    echo "  如果知道 DevEco Studio 安装路径，可以："
    echo "  export PATH=\$PATH:/path/to/hvigor/bin"
    echo "  然后重新运行此脚本"
    echo ""
    echo "方式 3: 查看详细指南"
    echo "  参考: BUILD_HAR_NOW.md"
    echo ""
    exit 1
fi

# 构建 HAR 包
echo ""
echo "开始构建 HAR 包..."
echo "使用: $HVIGOR_CMD"
echo ""

if "$HVIGOR_CMD" assembleHap --mode module -p module=flutter_module@default; then
    echo ""
    echo "=========================================="
    echo "✅ HAR 包构建成功！"
    echo "=========================================="
    echo ""
    
    HAR_PATH="flutter_module/build/default/outputs/default/flutter_module.har"
    if [ -f "$HAR_PATH" ]; then
        HAR_SIZE=$(du -h "$HAR_PATH" | cut -f1)
        HAR_FULL_PATH="$PROJECT_ROOT/.ohos/$HAR_PATH"
        echo "HAR 包位置: $HAR_FULL_PATH"
        echo "HAR 包大小: $HAR_SIZE"
        echo ""
        echo "下一步："
        echo "  1. 将 HAR 包复制到原生项目"
        echo "  2. 在原生项目中配置依赖"
        echo "  3. 参考 INTEGRATE_TO_EXISTING_PROJECT.md"
    else
        echo "⚠️  警告: 未找到 HAR 包文件"
        echo "预期位置: $HAR_PATH"
    fi
else
    echo ""
    echo "❌ HAR 包构建失败"
    echo "请查看上面的错误信息"
    echo ""
    exit 1
fi
