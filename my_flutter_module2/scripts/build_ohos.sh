#!/bin/bash
# 构建鸿蒙产物并自动更新 build-profile.json5

set -e  # 遇到错误立即退出

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "开始构建鸿蒙产物..."
cd "$PROJECT_ROOT"

# 执行 Flutter 构建
flutter build ohos

echo ""
echo "构建完成，开始更新 build-profile.json5..."
python3 "$SCRIPT_DIR/update_build_profile.py"

echo ""
echo "✅ 构建和配置更新完成！"
