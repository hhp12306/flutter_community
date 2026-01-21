import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import '../../../viewmodels/community_viewmodel.dart';
import '../../common/user_info.dart';
import '../../../config/app_routes.dart';
import '../../../utils/route_guard.dart';

/// 社区页面（MVVM 架构）
/// 包括精选、最新、关注tab，默认进入精选tab
/// 右下角悬浮显示发帖图标
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late final CommunityViewModel _viewModel;

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    // 使用 Get.put 创建 ViewModel，页面销毁时自动清理
    _viewModel = Get.put(CommunityViewModel());
    // 初始化数据
    _viewModel.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Get.put 创建的 ViewModel 会在页面销毁时自动清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Tab栏：精选、最新、关注（样式与推荐页面一致）
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: false, // 只有3个Tab，不需要滑动
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
              tabs: const [
                Tab(text: '精选'),
                Tab(text: '最新'),
                Tab(text: '关注'),
              ],
            ),
          ),
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('精选'),
                _buildTabContent('最新'),
                _buildTabContent('关注'),
              ],
            ),
          ),
        ],
      ),
      // 右下角悬浮发帖按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 跳转到发帖页面（需要登录）
          // 先检查登录状态
          final redirect = await RouteGuard.guardAsync(AppRoutes.post);
          if (redirect == null) {
            // 已登录或不需要登录，跳转到发帖页
            Get.toNamed(AppRoutes.post);
          } else {
            // 未登录且取消登录，不跳转
            // 可以显示提示信息
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 构建Tab内容
  Widget _buildTabContent(String type) {
    RefreshController controller;
    List<Map<String, dynamic>> posts;
    
    switch (type) {
      case '精选':
        controller = _viewModel.featuredRefreshController;
        posts = _viewModel.featuredPosts;
        break;
      case '最新':
        controller = _viewModel.latestRefreshController;
        posts = _viewModel.latestPosts;
        break;
      case '关注':
        controller = _viewModel.followingRefreshController;
        posts = _viewModel.followingPosts;
        break;
      default:
        controller = _viewModel.featuredRefreshController;
        posts = _viewModel.featuredPosts;
    }
    
    return Obx(() => SmartRefresher(
      controller: controller,
      enablePullDown: true, // 启用下拉刷新
      enablePullUp: true, // 启用上拉加载更多
      onRefresh: () => _viewModel.onRefresh(type),
      onLoading: () => _viewModel.onLoading(type),
      header: const ClassicHeader(
        refreshingText: '正在刷新...',
        completeText: '刷新完成',
        idleText: '下拉刷新',
        releaseText: '释放刷新',
        textStyle: TextStyle(color: Colors.black54),
      ),
      footer: ClassicFooter(
        loadingText: '正在加载...',
        noDataText: '没有更多数据了',
        idleText: '上拉加载更多',
        canLoadingText: '释放加载更多',
        textStyle: const TextStyle(color: Colors.black54),
      ),
      child: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostItem(type, index, posts[index]);
              },
            ),
    ));
  }

  /// 构建帖子项
  Widget _buildPostItem(String type, int index, Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发布人信息（使用通用组件，带关注按钮）
          Row(
            children: [
              Expanded(
                child: UserInfo(
                  avatarUrl: post['avatarUrl'],
                  userName: post['author'] ?? '发布人名称',
                  tag: post['carTag'] ?? '车型Tag',
                  authorId: post['authorId'],
                  avatarSize: 20.0,
                  fontSize: 14.0,
                  showFollowButton: true, // 显示关注按钮
                  isFollowed: post['isFollowed'] ?? false,
                  onFollowChanged: (isFollowed) {
                    // 更新 ViewModel 中的状态
                    _viewModel.updateFollowStatus(type, index, isFollowed);
                    // TODO: 调用后端API更新关注状态
                  },
                ),
              ),
              // 发布时间
              Text(
                post['time'] ?? '2小时前',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // 内容
          Text(
            post['title'] ?? '这是一条社区帖子内容，可以包含文字、图片、视频等多种形式...',
            style: const TextStyle(fontSize: 14.0),
          ),
          const SizedBox(height: 12.0),
          // 操作栏
          Row(
            children: [
              Icon(Icons.favorite_border, size: 18.0, color: Colors.grey[600]),
              const SizedBox(width: 4.0),
              Text(
                '${post['likeCount'] ?? 123}',
                style: const TextStyle(fontSize: 12.0),
              ),
              const SizedBox(width: 24.0),
              Icon(Icons.comment_outlined, size: 18.0, color: Colors.grey[600]),
              const SizedBox(width: 4.0),
              Text(
                '${post['commentCount'] ?? 45}',
                style: const TextStyle(fontSize: 12.0),
              ),
              const SizedBox(width: 24.0),
              Icon(Icons.share_outlined, size: 18.0, color: Colors.grey[600]),
            ],
          ),
        ],
      ),
    );
  }
}

/// 带圆角的下划线指示器（与推荐页面一致）
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
