#!/bin/bash
# 运行到鸿蒙设备并自动更新 build-profile.json5

set -e  # 遇到错误立即退出

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "开始运行到鸿蒙设备..."
cd "$PROJECT_ROOT"

# 执行 Flutter 运行（后台执行，等待构建完成）
flutter run -d ohos &
FLUTTER_PID=$!

# 等待 .ohos 目录生成
echo "等待构建产物生成..."
while [ ! -d "$PROJECT_ROOT/.ohos/entry" ]; do
    sleep 1
done

# 等待 build-profile.json5 文件生成
while [ ! -f "$PROJECT_ROOT/.ohos/entry/build-profile.json5" ]; do
    sleep 1
done

echo ""
echo "检测到 build-profile.json5 文件，开始更新配置..."
python3 "$SCRIPT_DIR/update_build_profile.py"

# 等待 Flutter 运行完成
wait $FLUTTER_PID
