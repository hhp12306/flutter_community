import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../utils/route_guard.dart';

/// 用户信息组件
/// 包含：用户头像、用户昵称、用户tag（车型标签等）、关注按钮
class UserInfo extends StatefulWidget {
  final String? avatarUrl; // 头像URL
  final String userName; // 用户昵称
  final String? tag; // 标签（如车型Tag）
  final String? authorId; // 作者ID（用于判断是否是本人）
  final double avatarSize; // 头像大小
  final double fontSize; // 文字大小
  final Color? textColor; // 文字颜色
  final Color? tagColor; // 标签颜色
  final VoidCallback? onTap; // 点击回调
  final bool showFollowButton; // 是否显示关注按钮
  final bool isFollowed; // 是否已关注
  final ValueChanged<bool>? onFollowChanged; // 关注状态变化回调

  const UserInfo({
    Key? key,
    this.avatarUrl,
    required this.userName,
    this.tag,
    this.authorId,
    this.avatarSize = 24.0,
    this.fontSize = 12.0,
    this.textColor,
    this.tagColor,
    this.onTap,
    this.showFollowButton = false,
    this.isFollowed = false,
    this.onFollowChanged,
  }) : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool _isFollowed = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.isFollowed;
    _checkCurrentUser();
  }

  @override
  void didUpdateWidget(UserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFollowed != oldWidget.isFollowed) {
      setState(() {
        _isFollowed = widget.isFollowed;
      });
    }
    if (widget.authorId != oldWidget.authorId) {
      _checkCurrentUser();
    }
  }

  /// 检查是否是当前用户
  Future<void> _checkCurrentUser() async {
    if (widget.authorId == null) {
      setState(() {
        _isCurrentUser = false;
      });
      return;
    }
    
    final currentUserId = await AuthService.getUserId();
    setState(() {
      _isCurrentUser = currentUserId == widget.authorId;
    });
  }

  /// 处理关注按钮点击
  Future<void> _handleFollowTap() async {
    // 检查登录状态
    final canFollow = await RouteGuard.checkLoginForAction('follow');
    if (!canFollow) {
      return; // 未登录或取消登录
    }

    // 切换关注状态
    setState(() {
      _isFollowed = !_isFollowed;
    });

    // 通知父组件关注状态变化
    if (widget.onFollowChanged != null) {
      widget.onFollowChanged!(_isFollowed);
    }

    // TODO: 调用后端API更新关注状态
    try {
      // await _followService.toggleFollow(widget.authorId, _isFollowed);
    } catch (e) {
      // 如果失败，恢复原状态
      setState(() {
        _isFollowed = !_isFollowed;
      });
      if (widget.onFollowChanged != null) {
        widget.onFollowChanged!(_isFollowed);
      }
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = widget.textColor ?? Colors.black54;
    final defaultTagColor = widget.tagColor ?? Colors.blue;
    
    // 判断是否显示关注按钮：不是本人且需要显示关注按钮
    final shouldShowFollowButton = widget.showFollowButton && 
                                   !_isCurrentUser && 
                                   widget.authorId != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 用户头像
          _buildAvatar(),
          
          const SizedBox(width: 6.0),
          
          // 用户昵称
          Flexible(
            child: Text(
              widget.userName,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: defaultTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 车型Tag
          if (widget.tag != null && widget.tag!.isNotEmpty) ...[
            const SizedBox(width: 4.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: defaultTagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                widget.tag!,
                style: TextStyle(
                  fontSize: widget.fontSize - 2.0,
                  color: defaultTagColor,
                ),
              ),
            ),
          ],
          
          // 关注按钮（不是本人时显示）
          if (shouldShowFollowButton) ...[
            const SizedBox(width: 8.0),
            _buildFollowButton(),
          ],
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.avatarUrl!,
          width: widget.avatarSize,
          height: widget.avatarSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: widget.avatarSize,
            height: widget.avatarSize,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: widget.avatarSize,
            height: widget.avatarSize,
            color: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: widget.avatarSize * 0.6,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      // 默认头像
      return Container(
        width: widget.avatarSize,
        height: widget.avatarSize,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: widget.avatarSize * 0.6,
          color: Colors.white,
        ),
      );
    }
  }

  /// 构建关注按钮
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: _handleFollowTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: _isFollowed ? Colors.grey[200] : Colors.blue,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _isFollowed ? Colors.grey[400]! : Colors.blue,
            width: 1.0,
          ),
        ),
        child: Text(
          _isFollowed ? '已关注' : '关注',
          style: TextStyle(
            fontSize: widget.fontSize - 1.0,
            color: _isFollowed ? Colors.grey[700] : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
