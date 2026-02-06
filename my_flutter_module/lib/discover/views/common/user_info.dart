import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../utils/route_guard.dart';

/// 用户信息卡片组件（公共）
/// 包含：用户头像、昵称、用户标签（等级/车型等）、关注按钮、可选 VIP 角标
class UserInfo extends StatefulWidget {
  final String? avatarUrl; // 头像 URL
  final String userName; // 用户昵称
  final String? tag; // 用户标签（如车型「汉EV」）
  final String? level; // 等级标签（如「D7」），有值则显示菱形+文字
  final bool isVip; // 是否 VIP，为 true 时在头像右下角显示 V 角标
  final String? authorId; // 作者 ID（用于判断是否是本人）
  final double avatarSize; // 头像大小
  final double fontSize; // 文字大小
  final Color? textColor; // 文字颜色
  final Color? tagColor; // 标签背景/文字色
  final VoidCallback? onTap; // 点击整块回调
  final bool showFollowButton; // 是否显示关注按钮
  final bool isFollowed; // 是否已关注
  final ValueChanged<bool>? onFollowChanged; // 关注状态变化回调

  const UserInfo({
    Key? key,
    this.avatarUrl,
    required this.userName,
    this.tag,
    this.level,
    this.isVip = false,
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
        children: [
          // 用户头像（含 VIP 角标）
          _buildAvatarWithVip(),
          const SizedBox(width: 10.0),
          // 昵称 + 标签行
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: defaultTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((widget.level != null && widget.level!.isNotEmpty) ||
                    (widget.tag != null && widget.tag!.isNotEmpty)) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      if (widget.level != null && widget.level!.isNotEmpty)
                        _buildLevelLabel(defaultTextColor),
                      if (widget.level != null &&
                          widget.level!.isNotEmpty &&
                          widget.tag != null &&
                          widget.tag!.isNotEmpty)
                        const SizedBox(width: 6.0),
                      if (widget.tag != null && widget.tag!.isNotEmpty)
                        _buildTag(defaultTagColor),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (shouldShowFollowButton) ...[
            const SizedBox(width: 8.0),
            _buildFollowButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelLabel(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.diamond, size: widget.fontSize, color: Colors.amber[700]),
        const SizedBox(width: 2.0),
        Text(
          widget.level!,
          style: TextStyle(
            fontSize: widget.fontSize - 2.0,
            color: textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(Color tagColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DCC8),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        widget.tag!,
        style: TextStyle(
          fontSize: widget.fontSize - 2.0,
          color: Colors.brown[800],
        ),
      ),
    );
  }

  /// 构建头像（带 VIP 角标，isVip 为 true 时显示）
  Widget _buildAvatarWithVip() {
    final avatar = _buildAvatar();
    if (!widget.isVip) return avatar;
    final badgeSize = widget.avatarSize * 0.38;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE082), width: 1.0),
            ),
            child: Center(
              child: Text(
                'V',
                style: TextStyle(
                  fontSize: badgeSize * 0.65,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
    }
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

  /// 构建关注按钮（白底灰边，与卡片风格一致）
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: _handleFollowTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey[400]!, width: 1.0),
        ),
        child: Text(
          _isFollowed ? '已关注' : '关注',
          style: TextStyle(
            fontSize: widget.fontSize,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
