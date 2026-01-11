import 'package:flutter/material.dart';
import '../../../models/tab_model.dart';

/// 发现页面Tab栏组件
/// 支持Tab过多时滑动显示
class DiscoverTabBar extends StatelessWidget {
  final List<TabModel> tabs;
  final TabController controller;
  final ValueChanged<int>? onTabTap;

  const DiscoverTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.onTabTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true, // 始终可滑动
      indicatorSize: TabBarIndicatorSize.label, // 下划线长度跟随文字
      indicator: _RoundedUnderlineTabIndicator(
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.black,
        ),
        insets: EdgeInsets.zero,
      ),
      dividerColor: Colors.transparent, // 移除底部分割线
      labelColor: Colors.black, // 选中文字颜色为黑色
      unselectedLabelColor: Colors.black54, // 未选中文字颜色为半透明黑色
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
