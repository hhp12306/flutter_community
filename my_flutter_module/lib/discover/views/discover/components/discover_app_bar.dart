import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/tab_model.dart';
import '../../../viewmodels/discover_viewmodel.dart';

/// 发现页面顶部AppBar（响应式版本）
/// 内部使用 Obx 监听 ViewModel 变化
class DiscoverAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child; // Tab栏
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessageTap;
  final DiscoverViewModel viewModel; // ViewModel 引用

  const DiscoverAppBar({
    Key? key,
    required this.child,
    required this.viewModel,
    this.onSearchTap,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(48); // 只保留 Tab 栏的高度

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 响应式更新
    return Obx(() => _DiscoverAppBarContent(
      scrollOffset: viewModel.scrollOffset,
      themeStyle: viewModel.themeStyle,
      child: child,
      onSearchTap: onSearchTap,
      onMessageTap: onMessageTap,
    ));
  }
}

/// AppBar 内容组件（非响应式）
class _DiscoverAppBarContent extends StatelessWidget implements PreferredSizeWidget {
  final Widget child; // Tab栏
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessageTap;
  final double scrollOffset; // 滚动偏移量，用于判断背景色
  final int? themeStyle; // 主题样式：1为黑色，2为白色

  const _DiscoverAppBarContent({
    Key? key,
    required this.child,
    this.onSearchTap,
    this.onMessageTap,
    required this.scrollOffset,
    required this.themeStyle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(48); // 只保留 Tab 栏的高度

  @override
  Widget build(BuildContext context) {
    // 根据滚动偏移量决定背景色：超过44px显示白色不透明，否则透明
    final bool showWhiteBackground = scrollOffset > 44.0;
    // 使用 AnimatedContainer 平滑过渡背景色变化
    final Color backgroundColor = showWhiteBackground 
        ? Colors.white 
        : Colors.transparent;
    
    // 根据themeStyle决定文字和图标颜色：1为黑色，2为白色，默认黑色
    final Color textColor = themeStyle == 2 ? Colors.white : Colors.black;
    final Color iconColor = themeStyle == 2 ? Colors.white : Colors.black;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent, // AppBar 本身保持透明
      foregroundColor: textColor,
      toolbarHeight: 0, // 移除标题栏高度
      automaticallyImplyLeading: false, // 移除默认的返回按钮
      surfaceTintColor: Colors.transparent, // 移除底部边框颜色
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // 平滑过渡动画
          curve: Curves.easeInOut,
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
                  child: child,
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
          onPressed: onSearchTap ?? () {
            // 默认跳转搜索页
          },
        ),
        // 消息中心图标
        IconButton(
          icon: Icon(Icons.notifications_none, color: iconColor),
          onPressed: onMessageTap ?? () {
            // 默认跳转消息中心
          },
        ),
      ],
    );
  }
}


/// 发现页面Tab栏组件
/// 支持Tab过多时滑动显示
/// 支持themeStyle切换文字颜色（1为黑色，2为白色）
class DiscoverTabBar extends StatelessWidget {
  final List<TabModel> tabs;
  final TabController controller;
  final ValueChanged<int>? onTabTap;
  final int? themeStyle; // 主题样式：1为黑色，2为白色

  const DiscoverTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.onTabTap,
    this.themeStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据themeStyle决定文字颜色：1为黑色，2为白色，默认黑色
    final Color labelColor = themeStyle == 2 ? Colors.white : Colors.black;
    final Color unselectedLabelColor = themeStyle == 2 
        ? Colors.white.withOpacity(0.7) 
        : Colors.black54;
    final Color indicatorColor = themeStyle == 2 ? Colors.white : Colors.black;

    return TabBar(
      controller: controller,
      isScrollable: true, // 始终可滑动
      indicatorSize: TabBarIndicatorSize.label, // 下划线长度跟随文字
      indicator: _RoundedUnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2.0,
          color: indicatorColor,
        ),
        insets: EdgeInsets.zero,
      ),
      dividerColor: Colors.transparent, // 移除底部分割线
      labelColor: labelColor, // 选中文字颜色
      unselectedLabelColor: unselectedLabelColor, // 未选中文字颜色
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.2,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12.0), // Tab之间的间距
      tabs: tabs.map((tab) {
        // Tab文案最多4个字
        String displayName = tab.name;
        if (displayName.length > 4) {
          displayName = displayName.substring(0, 4);
        }
        return Tab(text: displayName);
      }).toList(),
      onTap: onTabTap,
    );
  }
}

/// 带圆角的下划线指示器
class _RoundedUnderlineTabIndicator extends Decoration {
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;

  const _RoundedUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.black),
    this.insets = EdgeInsets.zero,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedUnderlinePainter(
      borderSide: borderSide,
      insets: insets,
      onChanged: onChanged,
    );
  }
}

class _RoundedUnderlinePainter extends BoxPainter {
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;

  _RoundedUnderlinePainter({
    required this.borderSide,
    required this.insets,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final Rect indicator = insets.resolve(TextDirection.ltr).deflateRect(rect);
    
    // 绘制带圆角的矩形（只显示底部）
    final Paint paint = Paint()
      ..color = borderSide.color
      ..strokeWidth = borderSide.width
      ..style = PaintingStyle.fill;
    
    // 创建一个带圆角的矩形路径，但只显示底部部分
    final double radius = 1.0; // 圆角半径
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        indicator.left,
        indicator.bottom - borderSide.width,
        indicator.width,
        borderSide.width,
      ),
      Radius.circular(radius),
    );
    
    canvas.drawRRect(rrect, paint);
  }
}

