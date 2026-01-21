import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/discover_controller.dart';
import 'components/discover_tab_bar.dart';
import 'components/discover_app_bar.dart';
import 'pages/recommend_page.dart';
import 'pages/community_page.dart';
import 'pages/club_page.dart';
import 'pages/smart_drive_page.dart';
import 'pages/activity_page.dart';
import 'pages/news_page.dart';
import 'pages/circle_page.dart';
import 'pages/live_page.dart';
import 'pages/reputation_page.dart';
import '../../models/tab_model.dart';
import '../../utils/route_guard.dart';

/// 发现页面（主页面）
/// 包含顶部Tab栏和各个Tab页面内容
class DiscoverPage extends StatefulWidget {
  final int? initialIndex; // 初始Tab索引，支持路由跳转
  final String? initialTabId; // 初始Tab ID

  const DiscoverPage({
    Key? key,
    this.initialIndex,
    this.initialTabId,
  }) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late final DiscoverController _controller;
  TabController? _tabController;
  PageController? _pageController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 获取或创建 DiscoverController
    _controller = Get.put(DiscoverController(), tag: 'discover');
    _initialize();
  }

  /// 初始化Tab和Page控制器
  Future<void> _initialize() async {
    // 初始化Tab列表
    await _controller.loadTabs();
    
    if (!mounted) return;
    
    // 计算初始索引
    int initialIndex = widget.initialIndex ?? 0;
    if (widget.initialTabId != null) {
      final index = _controller.getTabIndexById(widget.initialTabId!);
      if (index != null) {
        initialIndex = index;
      }
    }

    // 创建Tab控制器和Page控制器
    _tabController = TabController(
      length: _controller.visibleTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    
    _pageController = PageController(initialPage: initialIndex);

    // Tab切换监听
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging && _pageController != null) {
        _pageController!.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  /// 构建各个Tab页面
  Widget _buildPageByTab(TabModel tab) {
    switch (tab.id) {
      case 'recommend':
        return const RecommendPage();
      case 'community':
        return const CommunityPage();
      case 'club':
        return const ClubPage();
      case 'smart-drive':
        return const SmartDrivePage();
      case 'activity':
        return const ActivityPage();
      case 'news':
        return const NewsPage();
      case 'circle':
        return const CirclePage();
      case 'live':
        return const LivePage();
      case 'reputation':
        return const ReputationPage();
      default:
        return const RecommendPage();
    }
  }

  /// 处理页面滑动切换
  void _onPageChanged(int index) {
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _tabController == null || _pageController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: DiscoverAppBar(
        scrollOffset: _controller.scrollOffset,
        themeStyle: _controller.themeStyle,
        onSearchTap: () {
          // 跳转搜索页面
          // TODO: 实现搜索页面跳转
        },
        onMessageTap: () async {
          // 跳转消息中心（需要登录）
          final canAccess = await RouteGuard.checkLoginForAction('message');
          if (canAccess) {
            // TODO: 跳转消息中心页面
          }
        },
        child: _controller.visibleTabs.isEmpty
            ? const SizedBox.shrink()
            : DiscoverTabBar(
                tabs: _controller.visibleTabs,
                controller: _tabController!,
                themeStyle: _controller.themeStyle,
                onTabTap: (index) {
                  _pageController?.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
      ),
      body: _controller.visibleTabs.isEmpty || _pageController == null
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // 监听滚动，更新滚动偏移量
                if (notification is ScrollUpdateNotification) {
                  _controller.updateScrollOffset(notification.metrics.pixels);
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController!,
                onPageChanged: _onPageChanged,
                itemCount: _controller.visibleTabs.length,
                // PageView.builder 默认会保持页面状态，配合 AutomaticKeepAliveClientMixin 使用
                itemBuilder: (context, index) {
                  final tab = _controller.visibleTabs[index];
                  return _buildPageByTab(tab);
                },
              ),
            ),
    ));
  }
}

