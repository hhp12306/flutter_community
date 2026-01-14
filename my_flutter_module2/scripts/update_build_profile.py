#!/usr/bin/env python3
"""
自动修改鸿蒙 build-profile.json5 文件
在 runtimeOS: "HarmonyOS" 下面添加 buildOption 配置
支持多种文件结构：
1. app.products[].runtimeOS (新结构)
2. targets[].runtimeOS (旧结构)
3. products[].runtimeOS (旧结构)
"""

import os
import sys
import re

def update_build_profile(file_path):
    """
    更新 build-profile.json5 文件，在 runtimeOS: "HarmonyOS" 下面添加 buildOption
    """
    if not os.path.exists(file_path):
        print(f"错误: 文件不存在: {file_path}")
        return False
    
    # 读取文件内容
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # 检查是否已经包含 buildOption（避免重复添加）
    content_str = ''.join(lines)
    if '"buildOption"' in content_str and '"useNormalizedOHMUrl"' in content_str:
        # 检查是否在 runtimeOS 之后
        pattern_check = r'"runtimeOS"\s*:\s*"HarmonyOS"[^}]*"buildOption"'
        if re.search(pattern_check, content_str, re.DOTALL):
            print(f"提示: {file_path} 已经包含 buildOption 配置，跳过")
            return True
    
    # 查找需要修改的位置
    new_lines = []
    i = 0
    modified = False
    
    while i < len(lines):
        line = lines[i]
        
        # 检查是否是 runtimeOS: "HarmonyOS" 这一行
        if re.search(r'"runtimeOS"\s*:\s*"HarmonyOS"', line):
            # 计算当前行的缩进
            indent = len(line) - len(line.lstrip())
            
            # 添加 runtimeOS 行（确保有逗号）
            if line.rstrip().endswith(','):
                new_lines.append(line)
            else:
                new_lines.append(line.rstrip() + ',\n')
            
            # 检查下一行，确定格式
            if i + 1 < len(lines):
                next_line = lines[i + 1]
                # 如果下一行是闭合括号 } 或逗号后跟闭合括号
                if re.match(r'\s*[},]', next_line):
                    # 添加 buildOption，使用与 runtimeOS 相同的缩进
                    option_indent = ' ' * indent  # 与 runtimeOS 相同的缩进
                    new_lines.append(option_indent + '"buildOption": {\n')
                    new_lines.append(option_indent + '  "strictMode": {\n')
                    new_lines.append(option_indent + '    "useNormalizedOHMUrl": true,\n')
                    new_lines.append(option_indent + '    "caseSensitiveCheck": true\n')
                    new_lines.append(option_indent + '  }\n')
                    new_lines.append(option_indent + '}\n')
                    
                    modified = True
                    i += 1
                    continue
        
        new_lines.append(line)
        i += 1
    
    # 如果修改成功，写回文件
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f"成功: 已更新 {file_path}")
        print(f"提示: 已在 runtimeOS: 'HarmonyOS' 下面添加 buildOption 配置")
        return True
    else:
        print(f"警告: 未找到需要修改的位置")
        print(f"提示: 请检查文件中是否包含 'runtimeOS': 'HarmonyOS'")
        print(f"文件内容预览（前500字符）:")
        print(content_str[:500])
        return False


def find_build_profile_files(project_root):
    """
    查找所有可能的 build-profile.json5 文件
    """
    possible_paths = [
        os.path.join(project_root, '.ohos', 'build-profile.json5'),  # 根目录的 build-profile.json5
        os.path.join(project_root, '.ohos', 'entry', 'build-profile.json5'),  # entry 模块的
        os.path.join(project_root, 'build-profile.json5'),  # 项目根目录
    ]
    
    # 也搜索所有 .ohos 目录下的 build-profile.json5
    ohos_dir = os.path.join(project_root, '.ohos')
    if os.path.exists(ohos_dir):
        for root, dirs, files in os.walk(ohos_dir):
            for file in files:
                if file == 'build-profile.json5':
                    path = os.path.join(root, file)
                    if path not in possible_paths:
                        possible_paths.append(path)
    
    return possible_paths


def main():
    # 获取项目根目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # 查找所有可能的 build-profile.json5 文件
    possible_paths = find_build_profile_files(project_root)
    
    file_path = None
    for path in possible_paths:
        if os.path.exists(path):
            file_path = path
            break
    
    if not file_path:
        print("错误: 未找到 build-profile.json5 文件")
        print("提示: 请先运行 'flutter build ohos' 或 'flutter pub get' 生成鸿蒙产物")
        print("提示: 或者在 Dev Studio 中打开 .ohos 目录")
        sys.exit(1)
    
    print(f"找到文件: {file_path}")
    # 更新文件
    success = update_build_profile(file_path)
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
