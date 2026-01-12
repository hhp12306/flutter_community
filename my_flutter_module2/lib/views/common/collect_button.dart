import 'package:flutter/material.dart';
import '../../utils/count_util.dart';

/// 收藏按钮组件
/// 支持收藏/取消收藏，显示收藏数量
class CollectButton extends StatefulWidget {
  final bool isCollected; // 是否已收藏
  final int collectCount; // 收藏数量
  final ValueChanged<bool>? onCollectChanged; // 收藏状态变化回调
  final Color? iconColor; // 图标颜色
  final Color? collectedColor; // 已收藏时的颜色
  final double iconSize; // 图标大小
  final double fontSize; // 文字大小
  final bool showCount; // 是否显示数量

  const CollectButton({
    Key? key,
    required this.isCollected,
    required this.collectCount,
    this.onCollectChanged,
    this.iconColor,
    this.collectedColor,
    this.iconSize = 18.0,
    this.fontSize = 12.0,
    this.showCount = true,
  }) : super(key: key);

  @override
  State<CollectButton> createState() => _CollectButtonState();
}

class _CollectButtonState extends State<CollectButton> {
  late bool _isCollected;
  late int _collectCount;

  @override
  void initState() {
    super.initState();
    _isCollected = widget.isCollected;
    _collectCount = widget.collectCount;
  }

  @override
  void didUpdateWidget(CollectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCollected != widget.isCollected) {
      _isCollected = widget.isCollected;
    }
    if (oldWidget.collectCount != widget.collectCount) {
      _collectCount = widget.collectCount;
    }
  }

  /// 处理收藏点击
  void _handleTap() {
    setState(() {
      _isCollected = !_isCollected;
      // 更新收藏数量
      if (_isCollected) {
        _collectCount++;
      } else {
        _collectCount = _collectCount > 0 ? _collectCount - 1 : 0;
      }
    });

    // 通知外部收藏状态变化
    widget.onCollectChanged?.call(_isCollected);
    
    // TODO: 调用后端API更新收藏状态
  }

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = widget.iconColor ?? Colors.grey[600] ?? Colors.grey;
    final defaultCollectedColor = widget.collectedColor ?? Colors.orange;

    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 收藏图标
          Icon(
            _isCollected ? Icons.bookmark : Icons.bookmark_border,
            size: widget.iconSize,
            color: _isCollected ? defaultCollectedColor : defaultIconColor,
          ),
          // 收藏数量
          if (widget.showCount) ...[
            const SizedBox(width: 4.0),
            Text(
              CountUtil.formatCount(_collectCount),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: defaultIconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
