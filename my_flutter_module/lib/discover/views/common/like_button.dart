import 'package:flutter/material.dart';
import '../../utils/count_util.dart';

/// 点赞按钮组件
/// 支持点赞/取消点赞，显示点赞数量
class LikeButton extends StatefulWidget {
  final bool isLiked; // 是否已点赞
  final int likeCount; // 点赞数量
  final ValueChanged<bool>? onLikeChanged; // 点赞状态变化回调
  final Color? iconColor; // 图标颜色
  final Color? likedColor; // 已点赞时的颜色
  final double iconSize; // 图标大小
  final double fontSize; // 文字大小
  final bool showCount; // 是否显示数量

  const LikeButton({
    Key? key,
    required this.isLiked,
    required this.likeCount,
    this.onLikeChanged,
    this.iconColor,
    this.likedColor,
    this.iconSize = 18.0,
    this.fontSize = 12.0,
    this.showCount = true,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
    if (oldWidget.likeCount != widget.likeCount) {
      _likeCount = widget.likeCount;
    }
  }

  /// 处理点赞点击
  void _handleTap() {
    setState(() {
      _isLiked = !_isLiked;
      // 更新点赞数量
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
      }
    });

    // 通知外部点赞状态变化
    widget.onLikeChanged?.call(_isLiked);
    
    // TODO: 调用后端API更新点赞状态
  }

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = widget.iconColor ?? Colors.grey[600] ?? Colors.grey;
    final defaultLikedColor = widget.likedColor ?? Colors.red;

    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 点赞图标
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            size: widget.iconSize,
            color: _isLiked ? defaultLikedColor : defaultIconColor,
          ),
          // 点赞数量
          if (widget.showCount) ...[
            const SizedBox(width: 4.0),
            Text(
              CountUtil.formatLikeCount(_likeCount),
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
