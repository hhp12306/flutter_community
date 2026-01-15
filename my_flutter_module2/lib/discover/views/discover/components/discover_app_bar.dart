import 'package:flutter/material.dart';

/// 发现页面顶部AppBar
/// 左侧：Tab，右侧：搜索图标、消息中心图标
/// 支持滚动时背景色变化（超过44px显示白色）
/// 支持themeStyle切换文字和图标颜色（1为黑色，2为白色）
class DiscoverAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget child; // Tab栏
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessageTap;
  final double scrollOffset; // 滚动偏移量，用于判断背景色
  final int? themeStyle; // 主题样式：1为黑色，2为白色

  const DiscoverAppBar({
    Key? key,
    required this.child,
    this.onSearchTap,
    this.onMessageTap,
    this.scrollOffset = 0.0,
    this.themeStyle,
  }) : super(key: key);

  @override
  State<DiscoverAppBar> createState() => _DiscoverAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48); // 只保留 Tab 栏的高度
}

class _DiscoverAppBarState extends State<DiscoverAppBar> {

  @override
  Widget build(BuildContext context) {
    // 根据滚动偏移量决定背景色：超过44px显示白色不透明，否则透明
    final bool showWhiteBackground = widget.scrollOffset > 44.0;
    final Color backgroundColor = showWhiteBackground 
        ? Colors.white 
        : Colors.transparent;
    
    // 根据themeStyle决定文字和图标颜色：1为黑色，2为白色，默认黑色
    final Color textColor = widget.themeStyle == 2 ? Colors.white : Colors.black;
    final Color iconColor = widget.themeStyle == 2 ? Colors.white : Colors.black;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      toolbarHeight: 0, // 移除标题栏高度
      automaticallyImplyLeading: false, // 移除默认的返回按钮
      surfaceTintColor: Colors.transparent, // 移除底部边框颜色
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: const Border(), // 移除边框
          ),
          child: Row(
            children: [
              // 左侧：Tab栏（占满剩余空间）
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: widget.child,
                ),
              ),
              // 右侧：搜索图标、消息中心图标
              _buildRightActions(context, iconColor),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建右侧操作按钮
  Widget _buildRightActions(BuildContext context, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 搜索图标
        IconButton(
          icon: Icon(Icons.search, color: iconColor),
          onPressed: widget.onSearchTap ?? () {
            // 默认跳转搜索页
          },
        ),
        // 消息中心图标
        IconButton(
          icon: Icon(Icons.notifications_none, color: iconColor),
          onPressed: widget.onMessageTap ?? () {
            // 默认跳转消息中心
          },
        ),
      ],
    );
  }
}

