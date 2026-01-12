import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:go_router/go_router.dart';
import '../../common/user_info.dart';
import '../../../config/app_routes.dart';
import '../../../utils/route_guard.dart';

/// 社区页面
/// 包括精选、最新、关注tab，默认进入精选tab
/// 右下角悬浮显示发帖图标
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 为每个Tab创建独立的刷新控制器
  final RefreshController _featuredRefreshController = RefreshController(initialRefresh: false);
  final RefreshController _latestRefreshController = RefreshController(initialRefresh: false);
  final RefreshController _followingRefreshController = RefreshController(initialRefresh: false);
  
  // 每个Tab的数据列表
  List<Map<String, dynamic>> _featuredPosts = [];
  List<Map<String, dynamic>> _latestPosts = [];
  List<Map<String, dynamic>> _followingPosts = [];
  
  // 每个Tab的分页状态
  int _featuredPage = 1;
  int _latestPage = 1;
  int _followingPage = 1;
  bool _featuredHasMore = true;
  bool _latestHasMore = true;
  bool _followingHasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _featuredRefreshController.dispose();
    _latestRefreshController.dispose();
    _followingRefreshController.dispose();
    super.dispose();
  }
  
  /// 加载初始数据
  void _loadInitialData() {
    _loadFeaturedData(isRefresh: true);
    _loadLatestData(isRefresh: true);
    _loadFollowingData(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
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
            context.push(AppRoutes.post);
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
        controller = _featuredRefreshController;
        posts = _featuredPosts;
        break;
      case '最新':
        controller = _latestRefreshController;
        posts = _latestPosts;
        break;
      case '关注':
        controller = _followingRefreshController;
        posts = _followingPosts;
        break;
      default:
        controller = _featuredRefreshController;
        posts = _featuredPosts;
    }
    
    return SmartRefresher(
      controller: controller,
      enablePullDown: true, // 启用下拉刷新
      enablePullUp: true, // 启用上拉加载更多
      onRefresh: () => _onRefresh(type),
      onLoading: () => _onLoading(type),
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
    );
  }
  
  /// 下拉刷新
  Future<void> _onRefresh(String type) async {
    switch (type) {
      case '精选':
        _featuredPage = 1;
        _featuredHasMore = true;
        await _loadFeaturedData(isRefresh: true);
        _featuredRefreshController.refreshCompleted();
        break;
      case '最新':
        _latestPage = 1;
        _latestHasMore = true;
        await _loadLatestData(isRefresh: true);
        _latestRefreshController.refreshCompleted();
        break;
      case '关注':
        _followingPage = 1;
        _followingHasMore = true;
        await _loadFollowingData(isRefresh: true);
        _followingRefreshController.refreshCompleted();
        break;
    }
  }
  
  /// 上拉加载更多
  Future<void> _onLoading(String type) async {
    switch (type) {
      case '精选':
        if (!_featuredHasMore) {
          _featuredRefreshController.loadNoData();
          return;
        }
        _featuredPage++;
        await _loadFeaturedData(isRefresh: false);
        if (_featuredHasMore) {
          _featuredRefreshController.loadComplete();
        } else {
          _featuredRefreshController.loadNoData();
        }
        break;
      case '最新':
        if (!_latestHasMore) {
          _latestRefreshController.loadNoData();
          return;
        }
        _latestPage++;
        await _loadLatestData(isRefresh: false);
        if (_latestHasMore) {
          _latestRefreshController.loadComplete();
        } else {
          _latestRefreshController.loadNoData();
        }
        break;
      case '关注':
        if (!_followingHasMore) {
          _followingRefreshController.loadNoData();
          return;
        }
        _followingPage++;
        await _loadFollowingData(isRefresh: false);
        if (_followingHasMore) {
          _followingRefreshController.loadComplete();
        } else {
          _followingRefreshController.loadNoData();
        }
        break;
    }
  }
  
  /// 加载精选数据
  Future<void> _loadFeaturedData({bool isRefresh = false}) async {
    // TODO: 从后端获取数据
    await Future.delayed(const Duration(seconds: 1));
    
    if (isRefresh) {
      _featuredPosts = List.generate(10, (index) => {
        'id': 'featured_$index',
        'title': '精选帖子 $index',
        'author': '发布人$index',
        'authorId': 'user_$index', // 作者ID
        'carTag': '车型Tag',
        'time': '${index}小时前',
        'likeCount': 100 + index,
        'commentCount': 50 + index,
        'isFollowed': false, // 是否已关注
      });
    } else {
      // 加载更多
      if (_featuredPage <= 5) {
        final newPosts = List.generate(10, (index) {
          final postIndex = _featuredPosts.length + index;
          return {
            'id': 'featured_$postIndex',
            'title': '精选帖子 $postIndex',
            'author': '发布人$postIndex',
            'authorId': 'user_$postIndex', // 作者ID
            'carTag': '车型Tag',
            'time': '${postIndex}小时前',
            'likeCount': 100 + postIndex,
            'commentCount': 50 + postIndex,
            'isFollowed': false, // 是否已关注
          };
        });
        _featuredPosts.addAll(newPosts);
        _featuredHasMore = _featuredPage < 5;
      } else {
        _featuredHasMore = false;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }
  
  /// 加载最新数据
  Future<void> _loadLatestData({bool isRefresh = false}) async {
    // TODO: 从后端获取数据
    await Future.delayed(const Duration(seconds: 1));
    
    if (isRefresh) {
      _latestPosts = List.generate(10, (index) => {
        'id': 'latest_$index',
        'title': '最新帖子 $index',
        'author': '发布人$index',
        'authorId': 'user_$index', // 作者ID
        'carTag': '车型Tag',
        'time': '${index}分钟前',
        'likeCount': 80 + index,
        'commentCount': 40 + index,
        'isFollowed': false, // 是否已关注
      });
    } else {
      // 加载更多
      if (_latestPage <= 5) {
        final newPosts = List.generate(10, (index) {
          final postIndex = _latestPosts.length + index;
          return {
            'id': 'latest_$postIndex',
            'title': '最新帖子 $postIndex',
            'author': '发布人$postIndex',
            'authorId': 'user_$postIndex', // 作者ID
            'carTag': '车型Tag',
            'time': '${postIndex}分钟前',
            'likeCount': 80 + postIndex,
            'commentCount': 40 + postIndex,
            'isFollowed': false, // 是否已关注
          };
        });
        _latestPosts.addAll(newPosts);
        _latestHasMore = _latestPage < 5;
      } else {
        _latestHasMore = false;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }
  
  /// 加载关注数据
  Future<void> _loadFollowingData({bool isRefresh = false}) async {
    // TODO: 从后端获取数据
    await Future.delayed(const Duration(seconds: 1));
    
    if (isRefresh) {
      _followingPosts = List.generate(10, (index) => {
        'id': 'following_$index',
        'title': '关注帖子 $index',
        'author': '关注的人$index',
        'authorId': 'user_$index', // 作者ID
        'carTag': '车型Tag',
        'time': '${index}小时前',
        'likeCount': 120 + index,
        'commentCount': 60 + index,
        'isFollowed': true, // 已关注（关注tab中的帖子都是已关注的）
      });
    } else {
      // 加载更多
      if (_followingPage <= 5) {
        final newPosts = List.generate(10, (index) {
          final postIndex = _followingPosts.length + index;
          return {
            'id': 'following_$postIndex',
            'title': '关注帖子 $postIndex',
            'author': '关注的人$postIndex',
            'authorId': 'user_$postIndex', // 作者ID
            'carTag': '车型Tag',
            'time': '${postIndex}小时前',
            'likeCount': 120 + postIndex,
            'commentCount': 60 + postIndex,
            'isFollowed': true, // 已关注（关注tab中的帖子都是已关注的）
          };
        });
        _followingPosts.addAll(newPosts);
        _followingHasMore = _followingPage < 5;
      } else {
        _followingHasMore = false;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
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
                    // 更新本地状态
                    setState(() {
                      post['isFollowed'] = isFollowed;
                    });
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
