import 'package:flutter/material.dart';

/// 发现页面顶部AppBar
/// 左侧：Tab，右侧：搜索图标、消息中心图标
class DiscoverAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child; // Tab栏
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessageTap;

  const DiscoverAppBar({
    Key? key,
    required this.child,
    this.onSearchTap,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      toolbarHeight: 0, // 移除标题栏高度
      automaticallyImplyLeading: false, // 移除默认的返回按钮
      surfaceTintColor: Colors.transparent, // 移除底部边框颜色
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(), // 移除边框
          ),
          child: Row(
            children: [
              // 左侧：Tab栏（占满剩余空间，左侧间距24px）
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: child,
                ),
              ),
              // 右侧：搜索图标、消息中心图标
              _buildRightActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建右侧操作按钮
  Widget _buildRightActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 搜索图标
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: onSearchTap ?? () {
            // 默认跳转搜索页
          },
        ),
        // 消息中心图标
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: onMessageTap ?? () {
            // 默认跳转消息中心
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48); // 只保留 Tab 栏的高度
}

