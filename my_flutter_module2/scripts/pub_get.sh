#!/bin/bash
# 执行 flutter pub get 并自动更新 build-profile.json5（如果存在）

set -e  # 遇到错误立即退出

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "开始执行 flutter pub get..."
cd "$PROJECT_ROOT"

# 执行 Flutter pub get
flutter pub get

echo ""
echo "检查是否需要更新 build-profile.json5..."

# 检查 build-profile.json5 文件是否存在（优先查找根目录的）
possible_paths=(
    "$PROJECT_ROOT/.ohos/build-profile.json5"
    "$PROJECT_ROOT/.ohos/entry/build-profile.json5"
    "$PROJECT_ROOT/build-profile.json5"
)

file_path=""
for path in "${possible_paths[@]}"; do
    if [ -f "$path" ]; then
        file_path="$path"
        break
    fi
done

if [ -n "$file_path" ]; then
    echo "找到 build-profile.json5 文件: $file_path"
    echo "开始更新配置..."
    python3 "$SCRIPT_DIR/update_build_profile.py"
else
    echo "未找到 build-profile.json5 文件，跳过配置更新"
    echo "提示: 请先运行 'flutter build ohos' 或 'flutter run -d ohos' 生成鸿蒙产物"
fi

echo ""
echo "✅ flutter pub get 完成！"
